"""
Digit_Recognition_Gui.py

A Tkinter front-end for the DFX-reconfigurable MNIST DNN.

WHAT THIS SCRIPT DOES, IN PLAIN WORDS
--------------------------------------
- Shows three buttons (sigmoid-5 / sigmoid-8 / sigmoid-10). Clicking one
  sends a short "magic" command over TCP telling the board to
  partial-reconfigure (devcfg/PCAP) into that variant. The board is
  expected to echo the same command back once the swap is done -- only
  THEN do we update the "VARIANT SELECTED" box, so the UI always shows
  what the board actually confirmed, not just what we clicked.

- Shows a 28x28 drawing grid. You draw a digit on it with the mouse.
  Each cell remembers a brightness from 0 (black/background) to 255
  (full white ink), same as a real MNIST pixel.

- "Detect" converts the 28x28 grid into the same fixed-point format the
  DNN's training data used (Q1.15, i.e. brightness*128 -- see the big
  comment near PIXEL_SCALE below for why), sends it to the board with a
  leading command byte, and waits for the board to send back the
  digit it recognised.

- "Reset" just clears the drawing grid back to all-black.

WHY EVERYTHING NETWORK-RELATED RUNS ON A BACKGROUND THREAD
------------------------------------------------------------
Tkinter is not thread-safe -- you're only allowed to touch widgets from
the same thread that's running root.mainloop(). But socket.recv() can
block for a long time (or forever, if the board never replies), and if
that call happens on the main thread, the whole window freezes -- which
is exactly the hang you described in your earlier version.

The fix used here: every button press starts a small background thread
that does the slow networking. When that thread has an answer (or an
error), it doesn't touch the UI directly -- it just drops a message
into a thread-safe queue.Queue(). The main thread checks that queue
every 100ms (via root.after(...)) and only THEN updates labels/buttons.
This is the standard, safe way to mix threads with Tkinter.

TESTING WITHOUT THE BOARD
--------------------------
Set DEMO_MODE = True below to try the whole UI without any hardware
connected. In demo mode, "sending" a variant or a detect request just
waits half a second and then fakes a plausible reply, so you can check
that all the widgets, colours, and threading behave correctly before
you ever touch the real board.
"""

import tkinter as tk
import socket
import struct
import threading
import queue
import time
import random

# ============================================================================
# CONFIGURATION -- the things you're most likely to need to change
# ============================================================================

# Set this True to click around the UI with no board attached at all.
# Every "network" action will just fake a response after a short delay.
DEMO_MODE = False

# Where the board's TCP server is listening. Change to match your setup
# (this matches the static IP printed by your lwIP example earlier).
DEVICE_IP = "192.168.1.10"
DEVICE_PORT = 7

# How long (seconds) we'll wait for the board to reply before giving up.
NETWORK_TIMEOUT = 5.0

# --- Variant-switch protocol -------------------------------------------
# Sending a variant command means: write these 3 raw bytes to the socket.
# 0xFA 0xCE is just a fixed "this is a variant-select command" marker,
# and the third byte says which variant. We read 3 bytes back afterward
# and only accept it as confirmation if they match exactly what we sent
# -- that's what "it will be echoed back using lwIP" means in practice.
VARIANT_CODES = {
    "sigmoid-5":  0x05,
    "sigmoid-8":  0x08,
    "sigmoid-10": 0x0A,
}
VARIANT_MAGIC_PREFIX = bytes([0xFA, 0xCE])   # the fixed first two bytes
VARIANT_RESPONSE_BYTES = 3                    # we expect all 3 bytes echoed back

# --- Detect protocol -----------------------------------------------------
# Sending a detect request means: one command byte (0xDA), then 784
# pixels as 16-bit values, low-byte-first (Zynq/ARM is little-endian,
# so this must match however your firmware unpacks the stream).
DETECT_COMMAND_BYTE = 0xDA
NUM_PIXELS = 28 * 28





# =====================================================================
# ===================== CHANGED SECTION (1 of 2) ======================
# =====================================================================
#
# The board echoes every chunk of the pixel data back as it arrives,
# so the detect reply is NOT simply "the first byte that comes back".
# Instead the firmware marks the real answer with a 3-byte header:
#
#       0xDE 0xED 0xAF <digit>
#
# So we read the incoming stream until we spot those three bytes, and
# take the very next byte as the predicted digit. Everything arriving
# before the marker is just echoed pixel data and gets discarded.
DETECT_RESULT_MARKER = bytes([0xDE, 0xED, 0xAF])
#
# =====================================================================
# =================== END CHANGED SECTION (1 of 2) ====================
# =====================================================================




# --- Pixel scaling: turning a 0-255 brush stroke into Q1.15 -------------
# Your DNN expects pixels in Q1.15 fixed point (1 sign/integer bit +
# 15 fractional bits). We already confirmed from real training data
# (test_data_0001.txt) that a fully-white pixel (255) was encoded as
# 32640, and 255 * 128 = 32640 exactly. So the conversion is just:
#
#       q15_value = brightness_0_to_255 * 128
#
# which is what PIXEL_SCALE is used for below.
PIXEL_SCALE = 128

# ============================================================================
# COLOURS -- picked to match the dark "Digit Recognition Tool" design
# ============================================================================

COL_BG          = "#0b0f19"   # main window background
COL_PANEL       = "#141a29"   # card/panel background
COL_PANEL_EDGE  = "#232b3d"   # card border colour
COL_TEXT        = "#e5e7eb"   # normal light text
COL_TEXT_DIM    = "#8b93a7"   # dimmer secondary text
COL_ACCENT      = "#3b82f6"   # the blue used for selection/primary button
COL_ACCENT_DARK = "#1d4ed8"   # pressed/darker blue
COL_BTN_IDLE    = "#1b2536"   # unselected variant button colour
COL_GRID_BG     = "#0d1420"   # drawing canvas background (black-ish)
COL_GRID_LINE   = "#1f2937"   # faint grid lines on the canvas
COL_DANGER      = "#3a2330"   # reset button background (muted red-ish)
COL_DANGER_EDGE = "#5b2b3a"


# ============================================================================
# NETWORK HELPERS
# ============================================================================

def recv_exact(sock, num_bytes):
    """
    Plain socket.recv() is allowed to hand back fewer bytes than you
    asked for (TCP is a stream, not a set of neat little packets). This
    keeps calling recv() in a loop until we actually have num_bytes, or
    the connection closes / times out. Returns None if we couldn't get
    the full amount.
    """
    data = b""
    while len(data) < num_bytes:
        chunk = sock.recv(num_bytes - len(data))
        if not chunk:
            # Peer closed the connection before sending everything.
            return None
        data += chunk
    return data


def send_variant_command(variant_name):
    """
    Runs on a BACKGROUND THREAD (see App._start_variant_request).
    Connects, sends the 3-byte variant command, waits for the echoed
    reply, and returns (success, info_string).
    """
    code = VARIANT_CODES[variant_name]
    payload = VARIANT_MAGIC_PREFIX + bytes([code])

    if DEMO_MODE:
        # Pretend this took some time and then "confirm" it, so you can
        # see the whole flow working without any real hardware.
        time.sleep(0.5)
        return True, "(demo) confirmed " + variant_name

    try:
        with socket.create_connection((DEVICE_IP, DEVICE_PORT), timeout=NETWORK_TIMEOUT) as sock:
            sock.settimeout(NETWORK_TIMEOUT)
            sock.sendall(payload)
            reply = recv_exact(sock, VARIANT_RESPONSE_BYTES)
    except (socket.timeout, OSError) as exc:
        return False, "connection error: %s" % exc

    if reply is None:
        
        return False, "board closed connection before replying"
    if reply != payload:
        
        return False, "unexpected echo: %r" % (reply,)

    return True, "confirmed " + variant_name


def send_detect_request(pixel_grid_0_to_255):
    """
    Runs on a BACKGROUND THREAD (see App._start_detect_request).

    pixel_grid_0_to_255 is a 28x28 list of ints, each 0-255, in the
    same row-major order as the training .txt files (row 0 first,
    left-to-right within each row).

    Returns (success, digit_or_error_message).
    """
    # Flatten the 28x28 grid into one 784-long list, then scale each
    # value from plain 0-255 brightness into Q1.15 fixed point.
    flat_pixels = []
    for row in pixel_grid_0_to_255:
        for brightness in row:
            flat_pixels.append(brightness * PIXEL_SCALE)

    # Build the exact byte layout the board expects:
    #   [ 0xDA ][ pixel0 low, pixel0 high ][ pixel1 low, pixel1 high ]...
    # "<784H" means "little-endian, 784 unsigned 16-bit values".
    payload = bytes([DETECT_COMMAND_BYTE]) + struct.pack("<%dH" % NUM_PIXELS, *flat_pixels)

    if DEMO_MODE:
        time.sleep(0.5)
        return True, random.randint(0, 9)   # fake a plausible digit




    # =================================================================
    # ==================== CHANGED SECTION (2 of 2) ===================
    # =================================================================
    #
    # Old behaviour: read exactly 1 byte and call it the digit.
    # That breaks now, because the board echoes the pixel data back
    # first -- the first byte to arrive is echoed pixel data, not the
    # answer.
    #
    # New behaviour: keep reading until the 0xDEEDAF marker shows up,
    # then take the byte straight after it. Everything before the
    # marker is discarded as echo.
    try:
        with socket.create_connection((DEVICE_IP, DEVICE_PORT), timeout=NETWORK_TIMEOUT) as sock:
            sock.settimeout(NETWORK_TIMEOUT)
            sock.sendall(payload)

            buf = b""
            digit = None

            while True:
                chunk = sock.recv(4096)
                if not chunk:
                    # Board closed the connection. If the marker never
                    # arrived, there's nothing more coming.
                    break

                buf += chunk

                idx = buf.find(DETECT_RESULT_MARKER)
                if idx != -1:
                    # Marker found. The digit is the next byte after it --
                    # but that byte may not have arrived yet, so only
                    # take it once the buffer is actually long enough.
                    digit_pos = idx + len(DETECT_RESULT_MARKER)
                    if len(buf) > digit_pos:
                        digit = buf[digit_pos]
                        break

                # Guard against the buffer growing without bound if the
                # marker never turns up (e.g. firmware mismatch). The
                # echo is ~1569 bytes, so this is a generous ceiling.
                if len(buf) > 8192:
                    return False, "no 0xDEEDAF marker in reply"

            # ---- DRAIN ----
            # We have the digit, but the board is still echoing the rest
            # of the pixel data back at us. If we just close now, that
            # data sits unread in the board's send buffer, holding lwIP
            # pbufs and the PCB. Do that a couple of times and the board
            # runs out and stops answering new connections entirely.
            # So keep reading and throwing the remainder away until the
            # board closes or goes quiet. A short timeout is used here
            # so a chatty board can't stall the UI thread.
            if digit is not None:
                sock.settimeout(0.5)
                try:
                    while True:
                        leftover = sock.recv(4096)
                        if not leftover:
                            break          # board closed -- all drained
                except (socket.timeout, OSError):
                    pass                   # nothing more coming; fine

    except (socket.timeout, OSError) as exc:
        return False, "connection error: %s" % exc

    if digit is None:
        return False, "board closed connection before sending a result"

    if not (0 <= digit <= 9):
        return False, "got out-of-range digit: %d" % digit

    return True, digit
    #
    # =================================================================
    # ================== END CHANGED SECTION (2 of 2) =================
    # =================================================================




# ============================================================================
# THE MAIN APPLICATION
# ============================================================================

class DigitRecognitionApp:

    def __init__(self, root):
        self.root = root
        self.root.title("Digit Recognition Tool")
        self.root.configure(bg=COL_BG)

        # ------------------------------------------------------------
        # Drawing-grid state. This is the "source of truth" for what's
        # been drawn -- the canvas rectangles are just a picture of it.
        # ------------------------------------------------------------
        self.grid_size = 28
        self.cell_px = 20   # each grid cell is drawn this many screen pixels wide
        self.pixel_grid = [[0] * self.grid_size for _ in range(self.grid_size)]
        self.cell_rect_ids = {}   # (row, col) -> canvas rectangle id, for fast redraws

        # Which variant the BOARD has actually confirmed (not just clicked).
        self.confirmed_variant = None

        # Prevents you from mashing buttons while a request is already
        # in flight -- avoids piling up sockets/threads needlessly.
        self.request_in_progress = False

        # This is how background threads hand results back to the main
        # thread safely. See _poll_queue() for the receiving end.
        self.result_queue = queue.Queue()

        self._build_ui()

        # Start the queue-polling loop. This is what makes the thread ->
        # UI handoff safe; see the big comment at the top of the file.
        self.root.after(100, self._poll_queue)

    # ------------------------------------------------------------------
    # UI CONSTRUCTION
    # ------------------------------------------------------------------

    def _build_ui(self):
        # ---- Header ----------------------------------------------------
        header = tk.Frame(self.root, bg=COL_BG)
        header.pack(fill="x", pady=(18, 6))

        tk.Label(
            header, text="DIGIT RECOGNITION TOOL",
            font=("Segoe UI", 22, "bold"), fg=COL_ACCENT, bg=COL_BG,
        ).pack()
        tk.Label(
            header, text="Draw a digit and detect using the DFX-reconfigurable DNN",
            font=("Segoe UI", 10), fg=COL_TEXT_DIM, bg=COL_BG,
        ).pack(pady=(2, 0))

        # ---- Body: three columns side by side --------------------------
        body = tk.Frame(self.root, bg=COL_BG)
        body.pack(fill="both", expand=True, padx=20, pady=10)

        self._build_left_panel(body)
        self._build_center_panel(body)
        self._build_right_panel(body)

        # ---- Status bar at the very bottom ------------------------------
        self.status_var = tk.StringVar(value="Ready." + ("  [DEMO MODE]" if DEMO_MODE else ""))
        status = tk.Label(
            self.root, textvariable=self.status_var,
            font=("Segoe UI", 9), fg=COL_TEXT_DIM, bg=COL_BG, anchor="w",
        )
        status.pack(fill="x", padx=20, pady=(0, 10))

    def _panel(self, parent, title):
        """
        Small helper: builds one of the rounded-look "card" boxes used
        throughout the design (a bordered frame with a title label on
        top). Returns (outer_frame, inner_frame) -- put your content
        into inner_frame.
        """
        outer = tk.Frame(parent, bg=COL_PANEL, highlightbackground=COL_PANEL_EDGE,
                          highlightthickness=1, bd=0)
        tk.Label(
            outer, text=title, font=("Segoe UI", 10, "bold"),
            fg=COL_TEXT_DIM, bg=COL_PANEL, anchor="w",
        ).pack(fill="x", padx=14, pady=(12, 6))
        inner = tk.Frame(outer, bg=COL_PANEL)
        inner.pack(fill="both", expand=True, padx=14, pady=(0, 14))
        return outer, inner

    def _build_left_panel(self, parent):
        left = tk.Frame(parent, bg=COL_BG, width=220)
        left.pack(side="left", fill="y", padx=(0, 14))
        left.pack_propagate(False)

        # --- "SELECT VARIANT" card with the three buttons ---
        variant_card, variant_inner = self._panel(left, "SELECT VARIANT")
        variant_card.pack(fill="x", pady=(0, 14))

        self.variant_buttons = {}
        for name in ("sigmoid-5", "sigmoid-8", "sigmoid-10"):
            btn = tk.Button(
                variant_inner, text=name, font=("Segoe UI", 11, "bold"),
                fg=COL_TEXT, bg=COL_BTN_IDLE, activebackground=COL_ACCENT_DARK,
                activeforeground=COL_TEXT, relief="flat", bd=0, pady=10,
                command=lambda n=name: self._on_variant_clicked(n),
            )
            btn.pack(fill="x", pady=5)
            self.variant_buttons[name] = btn

        # --- "VARIANT SELECTED" card, showing the BOARD-CONFIRMED variant ---
        selected_card, selected_inner = self._panel(left, "VARIANT SELECTED")
        selected_card.pack(fill="x")

        self.variant_selected_var = tk.StringVar(value="-")
        tk.Label(
            selected_inner, textvariable=self.variant_selected_var,
            font=("Segoe UI", 15, "bold"), fg=COL_ACCENT, bg=COL_PANEL,
            wraplength=180, justify="center",
        ).pack(pady=10)

    def _build_center_panel(self, parent):
        center = tk.Frame(parent, bg=COL_BG)
        center.pack(side="left", fill="both", expand=True, padx=14)

        card, inner = self._panel(center, "DRAW DIGIT (28x28 GRID)")
        card.pack(fill="both", expand=True)

        canvas_size = self.grid_size * self.cell_px
        self.canvas = tk.Canvas(
            inner, width=canvas_size, height=canvas_size,
            bg=COL_GRID_BG, highlightthickness=1, highlightbackground=COL_PANEL_EDGE,
        )
        self.canvas.pack(pady=(4, 14))

        # Pre-create one rectangle per cell so drawing is just "recolour
        # an existing rectangle" -- much faster than redrawing everything
        # on every mouse-move event.
        for row in range(self.grid_size):
            for col in range(self.grid_size):
                x0 = col * self.cell_px
                y0 = row * self.cell_px
                rect_id = self.canvas.create_rectangle(
                    x0, y0, x0 + self.cell_px, y0 + self.cell_px,
                    fill=COL_GRID_BG, outline=COL_GRID_LINE,
                )
                self.cell_rect_ids[(row, col)] = rect_id

        # Left mouse button drag = paint.
        self.canvas.bind("<Button-1>", self._on_canvas_paint)
        self.canvas.bind("<B1-Motion>", self._on_canvas_paint)

        # --- Detect / Reset buttons, side by side under the grid ---
        button_row = tk.Frame(inner, bg=COL_PANEL)
        button_row.pack()

        self.detect_button = tk.Button(
            button_row, text="Detect", font=("Segoe UI", 11, "bold"),
            fg="white", bg=COL_ACCENT, activebackground=COL_ACCENT_DARK,
            activeforeground="white", relief="flat", bd=0, padx=24, pady=10,
            command=self._on_detect_clicked,
        )
        self.detect_button.pack(side="left", padx=(0, 10))

        self.reset_button = tk.Button(
            button_row, text="Reset", font=("Segoe UI", 11, "bold"),
            fg=COL_TEXT, bg=COL_DANGER, activebackground=COL_DANGER_EDGE,
            activeforeground=COL_TEXT, relief="flat", bd=0, padx=24, pady=10,
            command=self._on_reset_clicked,
        )
        self.reset_button.pack(side="left")

    def _build_right_panel(self, parent):
        right = tk.Frame(parent, bg=COL_BG, width=220)
        right.pack(side="left", fill="y", padx=(14, 0))
        right.pack_propagate(False)

        card, inner = self._panel(right, "PREDICTION")
        card.pack(fill="both", expand=True)

        self.prediction_var = tk.StringVar(value="?")
        self.prediction_label = tk.Label(
            inner, textvariable=self.prediction_var,
            font=("Segoe UI", 60, "bold"), fg=COL_TEXT_DIM, bg=COL_PANEL,
        )
        self.prediction_label.pack(expand=True, pady=(30, 6))

        self.prediction_hint_var = tk.StringVar(value="Digit will appear here")
        tk.Label(
            inner, textvariable=self.prediction_hint_var,
            font=("Segoe UI", 9), fg=COL_TEXT_DIM, bg=COL_PANEL,
        ).pack(pady=(0, 20))

    # ------------------------------------------------------------------
    # DRAWING GRID
    # ------------------------------------------------------------------

    def _on_canvas_paint(self, event):
        col = event.x // self.cell_px
        row = event.y // self.cell_px
        if not (0 <= row < self.grid_size and 0 <= col < self.grid_size):
            return   # mouse is outside the grid (e.g. right at the edge)

        # A small soft brush: the cell under the cursor gets full
        # brightness, and its immediate neighbours get a bit of
        # brightness too, so strokes look like a real pen mark instead
        # of a single hard-edged square. We use "only increase" logic
        # rather than overwriting, so drawing back over an
        # already-bright area never makes it dimmer.
        brush = {
            (0, 0): 255,
            (-1, 0): 140, (1, 0): 140, (0, -1): 140, (0, 1): 140,
            (-1, -1): 70, (-1, 1): 70, (1, -1): 70, (1, 1): 70,
        }
        for (dr, dc), brightness in brush.items():
            r, c = row + dr, col + dc
            if 0 <= r < self.grid_size and 0 <= c < self.grid_size:
                if brightness > self.pixel_grid[r][c]:
                    self.pixel_grid[r][c] = brightness
                    self._redraw_cell(r, c)

    def _redraw_cell(self, row, col):
        brightness = self.pixel_grid[row][col]
        # A brightness of 0-255 becomes a grayscale hex colour like
        # "#8a8a8a" -- equal red/green/blue channels give plain gray.
        hex_val = "#%02x%02x%02x" % (brightness, brightness, brightness)
        self.canvas.itemconfig(self.cell_rect_ids[(row, col)], fill=hex_val)

    def _on_reset_clicked(self):
        for row in range(self.grid_size):
            for col in range(self.grid_size):
                self.pixel_grid[row][col] = 0
                self.canvas.itemconfig(self.cell_rect_ids[(row, col)], fill=COL_GRID_BG)
        self.prediction_var.set("?")
        self.prediction_label.configure(fg=COL_TEXT_DIM)
        self.prediction_hint_var.set("Digit will appear here")
        self.status_var.set("Cleared.")

    # ------------------------------------------------------------------
    # VARIANT SELECTION (network action #1)
    # ------------------------------------------------------------------

    def _on_variant_clicked(self, variant_name):
        if self.request_in_progress:
            return   # ignore clicks while something else is already in flight

        self.request_in_progress = True
        self._set_buttons_enabled(False)
        self.status_var.set("Requesting %s ... (waiting for board)" % variant_name)

        # The actual network call happens on a background thread so the
        # window doesn't freeze while we wait for a reply.
        def worker():
            success, info = send_variant_command(variant_name)
            # Don't touch any widgets here -- we're on the wrong thread!
            # Just hand the result to the main thread via the queue.
            self.result_queue.put(("variant", variant_name, success, info))

        threading.Thread(target=worker, daemon=True).start()

    def _handle_variant_result(self, variant_name, success, info):
        self.request_in_progress = False
        self._set_buttons_enabled(True)

        if success:
            self.confirmed_variant = variant_name
            self.variant_selected_var.set(variant_name)
            self.status_var.set(info)
            self._highlight_selected_variant_button()
        else:
            self.status_var.set("Variant switch failed: %s" % info)

    def _highlight_selected_variant_button(self):
        for name, btn in self.variant_buttons.items():
            if name == self.confirmed_variant:
                btn.configure(bg=COL_ACCENT)
            else:
                btn.configure(bg=COL_BTN_IDLE)

    # ------------------------------------------------------------------
    # DETECT (network action #2)
    # ------------------------------------------------------------------

    def _on_detect_clicked(self):
        if self.request_in_progress:
            return

        self.request_in_progress = True
        self._set_buttons_enabled(False)
        self.status_var.set("Sending drawing to board ...")

        # Copy the grid now (on the main thread, where it's safe to read
        # self.pixel_grid) so the background thread has its own snapshot
        # and there's no risk of it changing mid-send if you keep drawing.
        grid_snapshot = [row[:] for row in self.pixel_grid]

        def worker():
            success, result = send_detect_request(grid_snapshot)
            self.result_queue.put(("detect", None, success, result))

        threading.Thread(target=worker, daemon=True).start()

    def _handle_detect_result(self, success, result):
        self.request_in_progress = False
        self._set_buttons_enabled(True)

        if success:
            digit = result
            self.prediction_var.set(str(digit))
            self.prediction_label.configure(fg=COL_ACCENT)   # make it stand out now
            self.prediction_hint_var.set("Detected digit")
            self.status_var.set("Detected: %s" % digit)
        else:
            self.status_var.set("Detect failed: %s" % result)

    # ------------------------------------------------------------------
    # QUEUE POLLING -- the thread-safe handoff point
    # ------------------------------------------------------------------

    def _poll_queue(self):
        """
        Runs on the MAIN thread, on a timer (every 100ms). This is the
        only place background-thread results are turned into widget
        updates, which is what keeps this safe with Tkinter.
        """
        try:
            while True:   # drain everything currently waiting
                kind, name, success, data = self.result_queue.get_nowait()
                if kind == "variant":
                    self._handle_variant_result(name, success, data)
                elif kind == "detect":
                    self._handle_detect_result(success, data)
        except queue.Empty:
            pass

        # Reschedule ourselves. This is what makes it a loop without
        # ever blocking the UI thread.
        self.root.after(100, self._poll_queue)

    # ------------------------------------------------------------------
    # SMALL HELPERS
    # ------------------------------------------------------------------

    def _set_buttons_enabled(self, enabled):
        state = "normal" if enabled else "disabled"
        self.detect_button.configure(state=state)
        self.reset_button.configure(state=state)
        for btn in self.variant_buttons.values():
            btn.configure(state=state)


# ============================================================================
# ENTRY POINT
# ============================================================================

if __name__ == "__main__":
    root = tk.Tk()
    root.geometry("980x680")
    app = DigitRecognitionApp(root)
    root.mainloop()
