module Relu_Function_Mod #(
    parameter dataWidth  = 16, weightIntegerWidth = 4) 
(
    input                                   clk,
    input           [2*dataWidth - 1:0]     modIn_i,
    output  reg     [dataWidth - 1:0]       outputMod_o
);
    always @ (posedge clk) 
    begin
        if ($signed(modIn_i) >= 0  ) 
        begin
            if ((|modIn_i[ 2*dataWidth - 1-:weightIntegerWidth+1])) 
            begin
                outputMod_o     <= {1'b0,{(dataWidth - 1){1'b1}}};
            end
            else
            begin
                outputMod_o     <= modIn_i[2*dataWidth - 1 - weightIntegerWidth - : dataWidth];
            end

        end
        else
            outputMod_o     <= 0;
    end
endmodule
