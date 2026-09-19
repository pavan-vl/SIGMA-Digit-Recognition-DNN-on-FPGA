# bin_to_carray_simple.py
#
# Converts sigf.bin, sige.bin, sigt.bin into C header files.
# Just edit the paths below and run this file. That's it.

import os

# ============================================================
# EDIT THESE THREE LINES -- put the path to each .bin file here
# ============================================================
SIGF_BIN_PATH = "C:/Users/pavan/Documents/CNN/Vivado/finalHW4/finalHW4.runs/child_0_impl_1/DigitDNN_i_rp_r5_inst_0_partial.bin"   # <-- path to your Sig5 .bin file
SIGE_BIN_PATH = "C:/Users/pavan/Documents/CNN/Vivado/finalHW4/finalHW4.runs/child_1_impl_1/DigitDNN_i_rp_r8_inst_0_partial.bin"   # <-- path to your Sig8 .bin file
SIGT_BIN_PATH = "C:/Users/pavan/Documents/CNN/Vivado/finalHW4/finalHW4.runs/impl_1/DigitDNN_i_rp_r10_inst_0_partial.bin"   # <-- path to your Sig10 .bin file

# ============================================================
# EDIT THIS -- folder where the generated .h files will be saved
# ============================================================
OUTPUT_FOLDER = "C:/Users/pavan/Documents/CNN/pyscripts"   # <-- "." means "same folder as this script"


def make_header(bin_path, array_name, out_path):
    with open(bin_path, "rb") as f:
        data = f.read()

    lines = []
    lines.append("#ifndef %s_H\n" % array_name.upper())
    lines.append("#define %s_H\n\n" % array_name.upper())
    lines.append("#include <stdint.h>\n\n")
    lines.append("static const uint8_t %s[] = {\n" % array_name)

    for i in range(0, len(data), 12):
        chunk = data[i:i + 12]
        hex_bytes = ", ".join("0x%02X" % b for b in chunk)
        lines.append("    " + hex_bytes + ",\n")

    lines.append("};\n\n")
    lines.append("#define %s_SIZE (sizeof(%s))\n\n" % (array_name.upper(), array_name))
    lines.append("#endif\n")

    with open(out_path, "w") as f:
        f.writelines(lines)

    print("%-12s -> %-24s (%d bytes)" % (bin_path, out_path, len(data)))


if __name__ == "__main__":
    make_header(SIGF_BIN_PATH, "sigf_bin", os.path.join(OUTPUT_FOLDER, "sigf_bitstream.h"))
    make_header(SIGE_BIN_PATH, "sige_bin", os.path.join(OUTPUT_FOLDER, "sige_bitstream.h"))
    make_header(SIGT_BIN_PATH, "sigt_bin", os.path.join(OUTPUT_FOLDER, "sigt_bitstream.h"))
    print("Done.")