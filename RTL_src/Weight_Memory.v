`include "includes.v"
module Weight_Memory_Mod #(
    parameter Num_Weight = 3, Neuron_Num = 5, Layer_Num = 1, addressWidth = 10, dataWidth = 16, FileForWeight = "w_1_0.mif") (
    input                             clk,
//    input                             Write_En,
    input                             Read_En,
//    input   [addressWidth - 1:0]      Write_Addr,
    input   [addressWidth - 1:0]      Read_Addr,
//    input   [dataWidth - 1:0]         Weight_In,
    output  reg [dataWidth - 1:0]     Weight_Out
);
    reg     [dataWidth - 1:0]         Mem       [Num_Weight - 1:0];

        initial begin
            $readmemb(FileForWeight, Mem);

        end
//    `else
//        always @(posedge clk)
//        begin
//            if(Write_En)
//            begin
//                Mem[Write_Addr] <= Weight_In;
        
//            end
//        end


always @ (posedge clk)
begin
        if (Read_En) begin
            Weight_Out <= Mem[Read_Addr];
        end
end
endmodule
