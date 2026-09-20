# digit_recognition_gui.py
# Tkinter front-end for the DFX-reconfigurable MNIST DNN on the Arty Z7-20.

import tkinter as tk
import socket
import struct
import threading
import queue
import time
import random

# ============================================================================
# CONFIGURATION
# ============================================================================

DEMO_MODE = False           # True = fake replies, no board needed

DEVICE_IP = "192.168.1.10"
DEVICE_PORT = 7
NETWORK_TIMEOUT = 5.0       # seconds to wait for a reply

# Variant select: 0xFA 0xCE <code>, echoed back by the board as confirmation
VARIANT_CODES = {
    "sigmoid-5":  0x05,
    "sigmoid-8":  0x08,
    "sigmoid-10": 0x0A,
}
VARIANT_MAGIC_PREFIX = bytes([0xFA, 0xCE])
VARIANT_RESPONSE_BYTES = 3

# Detect: 0xDA + 784 pixels as 16-bit little-endian = 1569 bytes
DETECT_COMMAND_BYTE = 0xDA
NUM_PIXELS = 28 * 28

# Board tags the real answer with this header, since the pixel data is echoed back too
DETECT_RESULT_MARKER = bytes([0xDE, 0xED, 0xAF])

PIXEL_SCALE = 128           # 0-255 brightness -> Q1.15 (255 * 128 = 32640)

# ============================================================================
# COLOURS
# ============================================================================

COL_BG          = "#0b0f19"   # window background
COL_PANEL       = "#141a29"   # card background
COL_PANEL_EDGE  = "#232b3d"   # card border
COL_TEXT        = "#e5e7eb"   # normal text
COL_TEXT_DIM    = "#8b93a7"   # secondary text
COL_ACCENT      = "#3b82f6"   # selection / primary button
COL_ACCENT_DARK = "#1d4ed8"   # pressed blue
COL_BTN_IDLE    = "#1b2536"   # unselected variant button
COL_GRID_BG     = "#0d1420"   # canvas background
COL_GRID_LINE   = "#1f2937"   # grid lines
COL_DANGER      = "#3a2330"   # reset button
COL_DANGER_EDGE = "#5b2b3a"


# ============================================================================
# NETWORK
# ============================================================================

def recv_exact(sock, num_bytes):
    # TCP is a stream, so recv() can return short. Loop until we have it all.
    data = b""
    while len(data) < num_bytes:
        chunk = sock.recv(num_bytes - len(data))
        if not chunk:
            return None
        data += chunk
    return data


def send_variant_command(variant_name):
    # Runs on a background thread. Returns (success, info_string).

    # Step 1: build the 3-byte command
    code = VARIANT_CODES[variant_name]
    payload = VARIANT_MAGIC_PREFIX + bytes([code])

    if DEMO_MODE:
        time.sleep(0.5)
        return True, "(demo) confirmed " + variant_name

    # Step 2: send it and wait for the echo
    try:
        with socket.create_connection((DEVICE_IP, DEVICE_PORT), timeout=NETWORK_TIMEOUT) as sock:
            sock.settimeout(NETWORK_TIMEOUT)
            sock.sendall(payload)
            reply = recv_exact(sock, VARIANT_RESPONSE_BYTES)
    except (socket.timeout, OSError) as exc:
        return False, "connection error: %s" % exc

    # Step 3: only accept it if the echo matches exactly
    if reply is None:
        return False, "board closed connection before replying"
    if reply != payload:
        return False, "unexpected echo: %r" % (reply,)

    return True, "confirmed " + variant_name


def send_detect_request(pixel_grid_0_to_255):
    # Runs on a background thread. Returns (success, digit_or_error).

    # Step 1: flatten the 28x28 grid and scale each pixel to Q1.15
    flat_pixels = []
    for row in pixel_grid_0_to_255:
        for brightness in row:
            flat_pixels.append(brightness * PIXEL_SCALE)

    # Step 2: build the packet - command byte then 784 little-endian 16-bit pixels
    payload = bytes([DETECT_COMMAND_BYTE]) + struct.pack("<%dH" % NUM_PIXELS, *flat_pixels)

    if DEMO_MODE:
        time.sleep(0.5)
        return True, random.randint(0, 9)

    try:
        with socket.create_connection((DEVICE_IP, DEVICE_PORT), timeout=NETWORK_TIMEOUT) as sock:
            sock.settimeout(NETWORK_TIMEOUT)

            # Step 3: send the frame
            sock.sendall(payload)

            buf = b""
            digit = None

            # Step 4: read until the 0xDEEDAF marker shows up
            while True:
                chunk = sock.recv(4096)
                if not chunk:
                    break

                buf += chunk

                # Step 4.1: marker found - the digit is the byte right after it
                idx = buf.find(DETECT_RESULT_MARKER)
                if idx != -1:
                    digit_pos = idx + len(DETECT_RESULT_MARKER)
                    if len(buf) > digit_pos:
                        digit = buf[digit_pos]
                        break

                # Step 4.2: bail out if the marker never turns up
                if len(buf) > 8192:
                    return False, "no 0xDEEDAF marker in reply"

            # Step 5: drain the leftover echo so the board can free its pbufs
            if digit is not None:
                sock.settimeout(0.5)
                try:
                    while True:
                        leftover = sock.recv(4096)
                        if not leftover:
                            break
                except (socket.timeout, OSError):
                    pass

    except (socket.timeout, OSError) as exc:
        return False, "connection error: %s" % exc

    # Step 6: sanity check the result
    if digit is None:
        return False, "board closed connection before sending a result"
    if not (0 <= digit <= 9):
        return False, "got out-of-range digit: %d" % digit

    return True, digit


# ============================================================================
# APPLICATION
# ============================================================================

class DigitRecognitionApp:

    def __init__(self, root):
        self.root = root
        self.root.title("Digit Recognition Tool")
        self.root.configure(bg=COL_BG)

        # Step 1: drawing state - pixel_grid is the source of truth, canvas just shows it
        self.grid_size = 28
        self.cell_px = 20
        self.pixel_grid = [[0] * self.grid_size for _ in range(self.grid_size)]
        self.cell_rect_ids = {}

        # Step 2: what the board has actually confirmed, not just what was clicked
        self.confirmed_variant = None

        # Step 3: blocks new requests while one is already in flight
        self.request_in_progress = False

        # Step 4: how background threads hand results back to the UI thread
        self.result_queue = queue.Queue()

        self._build_ui()

        # Step 5: start the queue poll - this is what keeps Tkinter thread-safe
        self.root.after(100, self._poll_queue)

    # ------------------------------------------------------------------
    # UI CONSTRUCTION
    # ------------------------------------------------------------------

    def _build_ui(self):
        # Step 1: header
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

        # Step 2: three columns side by side
        body = tk.Frame(self.root, bg=COL_BG)
        body.pack(fill="both", expand=True, padx=20, pady=10)

        self._build_left_panel(body)
        self._build_center_panel(body)
        self._build_right_panel(body)

        # Step 3: status bar
        self.status_var = tk.StringVar(value="Ready." + ("  [DEMO MODE]" if DEMO_MODE else ""))
        status = tk.Label(
            self.root, textvariable=self.status_var,
            font=("Segoe UI", 9), fg=COL_TEXT_DIM, bg=COL_BG, anchor="w",
        )
        status.pack(fill="x", padx=20, pady=(0, 10))

    def _panel(self, parent, title):
        # Builds one titled card. Returns (outer, inner) - put content in inner.
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

        # Step 1: the three variant buttons
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

        # Step 2: box showing the board-confirmed variant
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

        # Step 1: the drawing canvas
        canvas_size = self.grid_size * self.cell_px
        self.canvas = tk.Canvas(
            inner, width=canvas_size, height=canvas_size,
            bg=COL_GRID_BG, highlightthickness=1, highlightbackground=COL_PANEL_EDGE,
        )
        self.canvas.pack(pady=(4, 14))

        # Step 2: pre-create one rectangle per cell so painting is just a recolour
        for row in range(self.grid_size):
            for col in range(self.grid_size):
                x0 = col * self.cell_px
                y0 = row * self.cell_px
                rect_id = self.canvas.create_rectangle(
                    x0, y0, x0 + self.cell_px, y0 + self.cell_px,
                    fill=COL_GRID_BG, outline=COL_GRID_LINE,
                )
                self.cell_rect_ids[(row, col)] = rect_id

        # Step 3: left-click and drag paints
        self.canvas.bind("<Button-1>", self._on_canvas_paint)
        self.canvas.bind("<B1-Motion>", self._on_canvas_paint)

        # Step 4: Detect and Reset buttons
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
        # Step 1: which cell is under the cursor
        col = event.x // self.cell_px
        row = event.y // self.cell_px
        if not (0 <= row < self.grid_size and 0 <= col < self.grid_size):
            return

        # Step 2: soft 3x3 brush so strokes have gradient edges like real MNIST
        brush = {
            (0, 0): 255,
            (-1, 0): 140, (1, 0): 140, (0, -1): 140, (0, 1): 140,
            (-1, -1): 70, (-1, 1): 70, (1, -1): 70, (1, 1): 70,
        }

        # Step 3: only ever brighten a cell, never dim it
        for (dr, dc), brightness in brush.items():
            r, c = row + dr, col + dc
            if 0 <= r < self.grid_size and 0 <= c < self.grid_size:
                if brightness > self.pixel_grid[r][c]:
                    self.pixel_grid[r][c] = brightness
                    self._redraw_cell(r, c)

    def _redraw_cell(self, row, col):
        # Brightness 0-255 becomes a grey hex colour
        brightness = self.pixel_grid[row][col]
        hex_val = "#%02x%02x%02x" % (brightness, brightness, brightness)
        self.canvas.itemconfig(self.cell_rect_ids[(row, col)], fill=hex_val)

    def _on_reset_clicked(self):
        # Step 1: clear every cell
        for row in range(self.grid_size):
            for col in range(self.grid_size):
                self.pixel_grid[row][col] = 0
                self.canvas.itemconfig(self.cell_rect_ids[(row, col)], fill=COL_GRID_BG)

        # Step 2: reset the prediction display
        self.prediction_var.set("?")
        self.prediction_label.configure(fg=COL_TEXT_DIM)
        self.prediction_hint_var.set("Digit will appear here")
        self.status_var.set("Cleared.")

    # ------------------------------------------------------------------
    # VARIANT SELECTION
    # ------------------------------------------------------------------

    def _on_variant_clicked(self, variant_name):
        if self.request_in_progress:
            return

        # Step 1: lock the UI while the request is out
        self.request_in_progress = True
        self._set_buttons_enabled(False)
        self.status_var.set("Requesting %s ... (waiting for board)" % variant_name)

        # Step 2: do the networking on a background thread, hand the result back via the queue
        def worker():
            success, info = send_variant_command(variant_name)
            self.result_queue.put(("variant", variant_name, success, info))

        threading.Thread(target=worker, daemon=True).start()

    def _handle_variant_result(self, variant_name, success, info):
        # Step 1: unlock the UI
        self.request_in_progress = False
        self._set_buttons_enabled(True)

        # Step 2: only update the display if the board confirmed it
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
    # DETECT
    # ------------------------------------------------------------------

    def _on_detect_clicked(self):
        if self.request_in_progress:
            return

        # Step 1: lock the UI
        self.request_in_progress = True
        self._set_buttons_enabled(False)
        self.status_var.set("Sending drawing to board ...")

        # Step 2: snapshot the grid so the worker has its own copy
        grid_snapshot = [row[:] for row in self.pixel_grid]

        # Step 3: send it on a background thread
        def worker():
            success, result = send_detect_request(grid_snapshot)
            self.result_queue.put(("detect", None, success, result))

        threading.Thread(target=worker, daemon=True).start()

    def _handle_detect_result(self, success, result):
        # Step 1: unlock the UI
        self.request_in_progress = False
        self._set_buttons_enabled(True)

        # Step 2: show the digit
        if success:
            digit = result
            self.prediction_var.set(str(digit))
            self.prediction_label.configure(fg=COL_ACCENT)
            self.prediction_hint_var.set("Detected digit")
            self.status_var.set("Detected: %s" % digit)
        else:
            self.status_var.set("Detect failed: %s" % result)

    # ------------------------------------------------------------------
    # QUEUE POLLING
    # ------------------------------------------------------------------

    def _poll_queue(self):
        # Runs on the main thread every 100ms. Only place widgets get updated
        # from background results, which is what keeps Tkinter safe.
        try:
            while True:
                kind, name, success, data = self.result_queue.get_nowait()
                if kind == "variant":
                    self._handle_variant_result(name, success, data)
                elif kind == "detect":
                    self._handle_detect_result(success, data)
        except queue.Empty:
            pass

        self.root.after(100, self._poll_queue)

    # ------------------------------------------------------------------
    # HELPERS
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
