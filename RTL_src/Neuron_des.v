`include "includes.v"
module singl_neuron_mod #(parameter layerVal=0, actutationType="sigmoid", weightIntWidth=1, FileForBias="b_1_0.mif", FileForWeight="w_1_0.mif",NeuronNum=0, NumWeight=784, dataWidth=16, sigmoidSize=10)(
    input                       clk,
    input                       rstn,
    input   [dataWidth - 1:0]   dataIn,
    input                       dataIn_Valid,
//    input                       weight_Valid,
//    input   [31:0]              weight_Value,
//    input                       bias_Valid,
//    input   [31:0]              bias_Value,
//    input   [31:0]              configLayer_Num,
//    input   [31:0]              configNeuron_Num,
    output  [dataWidth - 1:0]   out_o,
    output  reg                 out_Valid_o
);

parameter addressWidth = $clog2(NumWeight);

wire                            ReadEn;
wire    [dataWidth - 1:0]       W_out;
wire                            Mux_Valid_reg;
//reg                             WriteEn;
//reg     [addressWidth - 1:0]    W_Addr;
reg     [addressWidth:0]        R_Addr; // Read must be accessible up untill NumWeight
//reg     [dataWidth - 1:0]       W_in;
reg     [2*dataWidth - 1:0]     Bias;  
reg     [2*dataWidth - 1:0]     Mult;
reg     [2*dataWidth - 1:0]     Sum;
reg     [31:0]                  BiasReg[0:0];
reg                             Weight_Valid_reg;
reg                             Multiply_Valid_reg;
reg                             Sigmoid_Valid_reg;
wire     [2*dataWidth:0]        Comb_Add;
wire     [2*dataWidth:0]        Bias_Add;
reg      [dataWidth - 1:0]      dataIn_reg;
reg                             muxValid_d;
reg                             muxValid_f;
reg                             addr = 0;



 
assign Mux_Valid_reg  = Multiply_Valid_reg;
(* use_dsp = "no" *) assign Comb_Add       = Mult + Sum;
(* use_dsp = "no" *) assign Bias_Add       = Bias + Sum;
assign ReadEn         = dataIn_Valid;


    initial begin
        $readmemb(FileForBias, BiasReg);
    end
    always @ (posedge clk)
    begin
        Bias <= {BiasReg[addr][dataWidth - 1:0],{dataWidth{1'b0}}}; 
    end


always @ (posedge clk)
begin
    if (out_Valid_o | !rstn) begin
        R_Addr <= 0;
        Bias    <=0;
    end
    else if (dataIn_Valid)
    begin
        R_Addr <= R_Addr + 1;
    end
end

always @ (posedge clk)
begin
    Mult <= $signed(dataIn_reg) * $signed(W_out);
end


always @ (posedge clk)
begin
    if (out_Valid_o | !rstn) begin
        Sum <= 0;
    end

    else if ((R_Addr == NumWeight) & muxValid_f) begin
        if (!Bias[2*dataWidth - 1] &!Sum[2*dataWidth - 1] & Bias_Add[2*dataWidth - 1])  
        begin
            Sum[2*dataWidth - 1]        <= 1'b0;
            Sum[2*dataWidth - 2:0]      <= {2*dataWidth - 1{1'b1}};
        end
        else if (Bias[2*dataWidth - 1] & Sum[2*dataWidth - 1] & !Bias_Add[2*dataWidth - 1])  
        begin
            Sum[2*dataWidth - 1]        <= 1'b1;
            Sum[2*dataWidth - 2:0]      <= {2*dataWidth - 1{1'b0}};
        end

        else
        begin
            Sum                     <= Bias_Add;
        end
    end

    
    else if (Mux_Valid_reg) 
    begin
        if(Mult[2*dataWidth - 1] & Sum[2*dataWidth - 1] & !Comb_Add[2*dataWidth - 1])
        begin
            Sum[2*dataWidth - 1]     <= 1'b1;
            Sum[2*dataWidth - 2 : 0] <= {2*dataWidth-1{1'b0}};
        end

        else if(!Mult[2*dataWidth - 1] & !Sum[2*dataWidth - 1] & Comb_Add[2*dataWidth - 1])
        begin
            Sum[2*dataWidth - 1]     <= 1'b0;
            Sum[2*dataWidth - 2 : 0] <= {2*dataWidth-1{1'b1}};
        end

        else
        begin
            Sum                  <= Comb_Add;
        end
    end
end

always @ (posedge clk)
begin
    dataIn_reg <= dataIn;
    Weight_Valid_reg <= dataIn_Valid;
    Multiply_Valid_reg <= Weight_Valid_reg;
    Sigmoid_Valid_reg <= ((R_Addr == NumWeight) & muxValid_f) ? 1'b1 : 1'b0;
    out_Valid_o <= Sigmoid_Valid_reg;
    muxValid_d <= Mux_Valid_reg;
    muxValid_f <= !Mux_Valid_reg & muxValid_d;
end

// Step 5 : Memory instance for storing the weights

    Weight_Memory_Mod #(.Num_Weight(NumWeight), .Neuron_Num(NeuronNum), .Layer_Num(layerVal), .addressWidth(addressWidth), .dataWidth(dataWidth), .FileForWeight(FileForWeight)) WeightMem_inst_1(
    .clk(clk)           ,
//    .Write_En(WriteEn)  ,
    .Read_En(ReadEn)   ,
//    .Write_Addr(W_Addr) ,
    .Read_Addr(R_Addr)  ,
//    .Weight_In(W_in)     ,
    .Weight_Out(W_out)   
);


generate
    if (actutationType == "sigmoid") begin
        begin:Sig_inst
            Sigmoid_ROM_Mod #(.input_Width(sigmoidSize), .dataWidth(dataWidth)) sigmoid_inst_1 
            (
                .clk(clk),
                .SigMod_in_i(Sum[2*dataWidth - 1- : sigmoidSize]),
                .output_o(out_o)
            );
        end
    end
    else if (actutationType == "relu") begin
        begin:Relu_inst
            Relu_Function_Mod #(.dataWidth(dataWidth), .weightIntegerWidth(weightIntWidth)) Relu_inst_1
            (
                .clk(clk),
                .modIn_i(Sum),
                .outputMod_o(out_o)
            );
        end
    end
endgenerate


endmodule
