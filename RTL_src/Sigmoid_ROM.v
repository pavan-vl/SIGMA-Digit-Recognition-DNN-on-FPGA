`include "includes.v"
module Sigmoid_ROM_Mod #(parameter input_Width = 10, dataWidth = 16) (
    input                               clk,
    input   [input_Width - 1:0]         SigMod_in_i,
    output  [dataWidth - 1 :0]          output_o
);

(* dont_touch="true" *) reg     [dataWidth - 1:0]           Mem_ROM     [2**input_Width - 1:0];
reg     [input_Width - 1:0]         y;
initial begin
//    $readmemb("SigmoidFuncVals_5.mif", Mem_ROM);

    $readmemb("SigmoidFuncVals_8.mif", Mem_ROM);

//    $readmemb("SigmoidFuncVals_10.mif", Mem_ROM);

end

always @ (posedge clk) begin
    if ($signed(SigMod_in_i) >= 0) begin
        y       <= SigMod_in_i + (2** (input_Width - 1));
    end
    else
    begin
        y       <= SigMod_in_i - (2** (input_Width - 1));
    end     
    
end
assign output_o = Mem_ROM[y];

endmodule 
