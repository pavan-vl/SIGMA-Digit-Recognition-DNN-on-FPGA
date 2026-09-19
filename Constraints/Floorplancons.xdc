create_pblock pblock_1
add_cells_to_pblock [get_pblocks pblock_1] [get_cells -quiet [list DigitDNN_i/rp]]
resize_pblock [get_pblocks pblock_1] -add {SLICE_X32Y2:SLICE_X113Y148}
resize_pblock [get_pblocks pblock_1] -add {DSP48_X2Y2:DSP48_X4Y57}
resize_pblock [get_pblocks pblock_1] -add {RAMB18_X2Y2:RAMB18_X5Y57}
resize_pblock [get_pblocks pblock_1] -add {RAMB36_X2Y1:RAMB36_X5Y28}
set_property EXCLUDE_PLACEMENT 1 [get_pblocks pblock_1]
set_property CONTAIN_ROUTING 1 [get_pblocks pblock_1]
set_property IS_SOFT FALSE [get_pblocks pblock_1]
