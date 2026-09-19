`include "includes.v"
module DNN_Digit_Recog (
    input                                       S_AXIS_ACLK,
    input                                       S_AXIS_ARESETN,
    input   [`dataWidth - 1 : 0]                S_AXIS_TDATA,
    input                                       S_AXIS_TDATA_VALID,
    input                                       DNN_SOFT_RESETN,
    output                                      S_AXIS_TDATA_READY,
    output  [31 : 0]                            digit_Val,
    output                                      hardmax_output_valid
);

localparam HOLD = 0, TRANSFER = 1;

// My input wires
wire clk, rstn;

assign clk      =       S_AXIS_ACLK;
assign rstn     =       S_AXIS_ARESETN & DNN_SOFT_RESETN;


// Assert Ready

assign S_AXIS_TDATA_READY       =   1'b1;


wire    [31 : 0]    hwmax_out_w;
wire                hwmax_oValid_w;
assign  digit_Val       =   hwmax_out_w;
assign hardmax_output_valid   = hwmax_oValid_w;
// Layer 1
wire [`NumberOfNeurons_L1 - 1 : 0]                  dataOutValid_X1;
wire [`NumberOfNeurons_L1 * `dataWidth - 1: 0]      dataOut_X1;
reg  [`NumberOfNeurons_L1 * `dataWidth - 1: 0]      dataBuf_X1;
reg  [`dataWidth - 1: 0]                            layer1Out_Buf;
reg                                                 layer1Out_BufValid;
reg                             state_L1;
integer                         count_L1;

// Layer 2
wire [`NumberOfNeurons_L2 - 1 : 0]                  dataOutValid_X2;
wire [`NumberOfNeurons_L2 * `dataWidth - 1: 0]      dataOut_X2;
reg  [`NumberOfNeurons_L2 * `dataWidth - 1: 0]      dataBuf_X2;
reg  [`dataWidth - 1: 0]                            layer2Out_Buf;
reg                                                 layer2Out_BufValid;
reg                             state_L2;
integer                         count_L2;

// Layer 3
wire [`NumberOfNeurons_L3 - 1 : 0]                  dataOutValid_X3;
wire [`NumberOfNeurons_L3 * `dataWidth - 1: 0]      dataOut_X3;
reg  [`NumberOfNeurons_L3 * `dataWidth - 1: 0]      dataBuf_X3;
reg  [`dataWidth - 1: 0]                            layer3Out_Buf;
reg                                                 layer3Out_BufValid;
reg                             state_L3;
integer                         count_L3;

// Layer 4
wire [`NumberOfNeurons_L4 - 1 : 0]                  dataOutValid_X4;
wire [`NumberOfNeurons_L4 * `dataWidth - 1: 0]      dataOut_X4;
reg  [`NumberOfNeurons_L4 * `dataWidth - 1: 0]      dataBuf_X4;
reg  [`dataWidth - 1: 0]                            layer4Out_Buf;
reg                                                 layer4Out_BufValid;
reg                             state_L4;
integer                         count_L4;

layer_1_30N #(.NueronNumber_L1(`NumberOfNeurons_L1), .dataWidth(`dataWidth), .Layer_Number_L1(1), .num_Weight_L1(`num_Weight_L1), .SigmoidSize_L1(`Size_Sigmoid_L1), .weightIntegerWidth_L1(`weight_integer_Width_L1), .actuationType_L1(`actuation_Type_L1)) layer1_inst (
    .clk(clk),                           
    .rstn(rstn),
//    .weight_Valid_L1(weightValid_AXI),
//    .weight_Value_L1(weightValue_AXI),
//    .bias_Valid_L1(biasValid_AXI),
//    .bias_Value_L1(biasValue_AXI),
//    .config_Layer_Num_L1(configLayerNum_AXI),
//    .config_Neuron_Num_L1(configNeuronNum_AXI),
    .module_Function_In_Valid_L1( S_AXIS_TDATA_VALID ),
    .module_Function_In_L1(S_AXIS_TDATA),
    .output_Valid_L1(dataOutValid_X1),
    .layer1_out_o(dataOut_X1)
);


always @(posedge clk) 
begin
    if (!rstn) 
    begin
        state_L1            <= HOLD;
        count_L1            <= 0;
        layer1Out_BufValid  <= 0;
    end
    else
    begin
        case (state_L1)
            HOLD: begin
                count_L1            <= 0;
                layer1Out_BufValid  <= 0;
                if (dataOutValid_X1[0] == 1'b1)
                begin
                    dataBuf_X1      <= dataOut_X1;
                    state_L1        <= TRANSFER;
                end
            end
            TRANSFER: begin
                layer1Out_Buf       <= dataBuf_X1[`dataWidth - 1: 0];
                dataBuf_X1          <= dataBuf_X1>>`dataWidth;
                count_L1            <= count_L1 +1;
                layer1Out_BufValid  <= 1'b1;
                if (count_L1 == `NumberOfNeurons_L1) begin
                    state_L1                <= HOLD;
                    layer1Out_BufValid      <= 1'b0;
                end
            end     
            default: begin
                state_L1            <= HOLD;
                count_L1            <= 0;
                layer1Out_BufValid  <= 1'b0;
            end 
        endcase
    end
end


layer_2_30N #(.NueronNumber_L2(`NumberOfNeurons_L2), .dataWidth(`dataWidth), .Layer_Number_L2(2), .num_Weight_L2(`num_Weight_L2), .SigmoidSize_L2(`Size_Sigmoid_L2), .weightIntegerWidth_L2(`weight_integer_Width_L2), .actuationType_L2(`actuation_Type_L2)) layer2_inst (
    .clk(clk),                           
    .rstn(rstn),
//    .weight_Valid_L2(weightValid_AXI),
//    .weight_Value_L2(weightValue_AXI),
//    .bias_Valid_L2(biasValid_AXI),
//    .bias_Value_L2(biasValue_AXI),
//    .config_Layer_Num_L2(configLayerNum_AXI),
//    .config_Neuron_Num_L2(configNeuronNum_AXI),
    .module_Function_In_Valid_L2(layer1Out_BufValid),
    .module_Function_In_L2(layer1Out_Buf),
    .output_Valid_L2(dataOutValid_X2),
    .layer2_out_o(dataOut_X2)
);


always @(posedge clk) 
begin
    if (!rstn) 
    begin
        state_L2            <= HOLD;
        count_L2            <= 0;
        layer2Out_BufValid  <= 0;
    end
    else
    begin
        case (state_L2)
            HOLD: begin
                count_L2            <= 0;
                layer2Out_BufValid  <= 0;
                if (dataOutValid_X2[0] == 1'b1)
                begin
                    dataBuf_X2      <= dataOut_X2;
                    state_L2        <= TRANSFER;
                end
            end
            TRANSFER: begin
                layer2Out_Buf       <= dataBuf_X2[`dataWidth - 1: 0];
                dataBuf_X2          <= dataBuf_X2>>`dataWidth;
                count_L2            <= count_L2 +1;
                layer2Out_BufValid  <= 1'b1;
                if (count_L2 == `NumberOfNeurons_L2) begin
                    state_L2                <= HOLD;
                    layer2Out_BufValid      <= 1'b0;
                end
            end     
            default: begin
                state_L2            <= HOLD;
                count_L2            <= 0;
                layer2Out_BufValid  <= 1'b0;
            end 
        endcase
    end
end


layer_3_10N #(.NueronNumber_L3(`NumberOfNeurons_L3), .dataWidth(`dataWidth), .Layer_Number_L3(3), .num_Weight_L3(`num_Weight_L3), .SigmoidSize_L3(`Size_Sigmoid_L3), .weightIntegerWidth_L3(`weight_integer_Width_L3), .actuationType_L3(`actuation_Type_L3)) layer3_inst (
    .clk(clk),                           
    .rstn(rstn),
//    .weight_Valid_L3(weightValid_AXI),
//    .weight_Value_L3(weightValue_AXI),
//    .bias_Valid_L3(biasValid_AXI),
//    .bias_Value_L3(biasValue_AXI),
//    .config_Layer_Num_L3(configLayerNum_AXI),
//    .config_Neuron_Num_L3(configNeuronNum_AXI),
    .module_Function_In_Valid_L3(layer2Out_BufValid),
    .module_Function_In_L3(layer2Out_Buf),
    .output_Valid_L3(dataOutValid_X3),
    .layer3_out_o(dataOut_X3)
);


always @(posedge clk) 
begin
    if (!rstn) 
    begin
        state_L3            <= HOLD;
        count_L3            <= 0;
        layer3Out_BufValid  <= 0;
    end
    else
    begin
        case (state_L3)
            HOLD: begin
                count_L3            <= 0;
                layer3Out_BufValid  <= 0;
                if (dataOutValid_X3[0] == 1'b1)
                begin
                    dataBuf_X3      <= dataOut_X3;
                    state_L3        <= TRANSFER;
                end
            end
            TRANSFER: begin
                layer3Out_Buf       <= dataBuf_X3[`dataWidth - 1: 0];
                dataBuf_X3          <= dataBuf_X3>>`dataWidth;
                count_L3            <= count_L3 +1;
                layer3Out_BufValid  <= 1'b1;
                if (count_L3 == `NumberOfNeurons_L3) begin
                    state_L3                <= HOLD;
                    layer3Out_BufValid      <= 1'b0;
                end
            end     
            default: begin
                state_L3            <= HOLD;
                count_L3            <= 0;
                layer3Out_BufValid  <= 1'b0;
            end 
        endcase
    end
end

layer_4_10N #(.NueronNumber_L4(`NumberOfNeurons_L4), .dataWidth(`dataWidth), .Layer_Number_L4(4), .num_Weight_L4(`num_Weight_L4), .SigmoidSize_L4(`Size_Sigmoid_L4), .weightIntegerWidth_L4(`weight_integer_Width_L4), .actuationType_L4(`actuation_Type_L4)) layer4_inst (
    .clk(clk),                           
    .rstn(rstn),
//    .weight_Valid_L4(weightValid_AXI),
//    .weight_Value_L4(weightValue_AXI),
//    .bias_Valid_L4(biasValid_AXI),
//    .bias_Value_L4(biasValue_AXI),
//    .config_Layer_Num_L4(configLayerNum_AXI),
//    .config_Neuron_Num_L4(configNeuronNum_AXI),
    .module_Function_In_Valid_L4(layer3Out_BufValid),
    .module_Function_In_L4(layer3Out_Buf),
    .output_Valid_L4(dataOutValid_X4),
    .layer4_out_o(dataOut_X4)
);


//always @(posedge clk) 
//begin
//    if (!rstn) 
//    begin
//        state_L4            <= HOLD;
//        count_L4            <= 0;
//        layer4Out_BufValid  <= 0;
//    end
//    else
//    begin
//        case (state_L4)
//            HOLD: begin
//                count_L4            <= 0;
//                layer4Out_BufValid  <= 0;
//                if (dataOutValid_X4[0] == 1'b1)
//                begin
//                    dataBuf_X4      <= dataOut_X4;
//                    state_L4        <= TRANSFER;
//                end
//            end
//            TRANSFER: begin
//                layer4Out_Buf       <= dataBuf_X4[`dataWidth - 1: 0];
//                dataBuf_X4          <= dataBuf_X4>>`dataWidth;
//                count_L4            <= count_L4 +1;
//                layer4Out_BufValid  <= 1'b1;
//                if (count_L4 == `NumberOfNeurons_L4) begin
//                    state_L4                <= HOLD;
//                    layer4Out_BufValid      <= 1'b0;
//                end
//            end     
//            default: begin
//                state_L4            <= HOLD;
//                count_L4            <= 0;
//                layer4Out_BufValid  <= 1'b0;
//            end 
//        endcase
//    end
//end



DNN_Hardware_max_function  hardware_maximum_probability_finder_inst  (
    .clk(clk),
    .in_Valid_i( dataOutValid_X4 ),
    .in_data_i(dataOut_X4),
    .out_data_o(hwmax_out_w),
    .out_valid_o(hwmax_oValid_w)
);

endmodule
