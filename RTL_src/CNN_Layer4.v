module layer_4_10N #(parameter NueronNumber_L4 = 10, dataWidth = 16, Layer_Number_L4 = 4, num_Weight_L4 = 10, SigmoidSize_L4 = 10, weightIntegerWidth_L4 = 4, actuationType_L4 = "relu") (
    input                                          clk,
    input                                          rstn,
//    input                                          weight_Valid_L4,
//    input   [31:0]                                 weight_Value_L4,
//    input                                          bias_Valid_L4,
//    input   [31:0]                                 bias_Value_L4,
//    input   [31:0]                                 config_Layer_Num_L4,
//    input   [31:0]                                 config_Neuron_Num_L4,
    input                                          module_Function_In_Valid_L4,
    input   [dataWidth - 1 : 0]                    module_Function_In_L4,
    output  [NueronNumber_L4 - 1:0]                output_Valid_L4,
    output  [NueronNumber_L4 * dataWidth -1:0]     layer4_out_o
);

    singl_neuron_mod #(.layerVal(Layer_Number_L4), .actutationType(actuationType_L4), .weightIntWidth(weightIntegerWidth_L4), .FileForBias("b_4_0.mif"), .FileForWeight("w_4_0.mif"),.NeuronNum(0), .NumWeight(num_Weight_L4), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L4)) n0_L41_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L4),
    .dataIn_Valid(module_Function_In_Valid_L4),
    // .weight_Valid(weight_Valid_L4),
    // .weight_Value(weight_Value_L4),
    // .bias_Valid(bias_Valid_L4),
    // .bias_Value(bias_Value_L4),
    // .configLayer_Num(config_L4ayer_Num_L4),
    // .configNeuron_Num(config_Neuron_Num_L4),
    .out_o(layer4_out_o[0 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L4[0])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L4), .actutationType(actuationType_L4), .weightIntWidth(weightIntegerWidth_L4), .FileForBias("b_4_1.mif"), .FileForWeight("w_4_1.mif"),.NeuronNum(1), .NumWeight(num_Weight_L4), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L4)) n1_L41_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L4),
    .dataIn_Valid(module_Function_In_Valid_L4),
    // .weight_Valid(weight_Valid_L4),
    // .weight_Value(weight_Value_L4),
    // .bias_Valid(bias_Valid_L4),
    // .bias_Value(bias_Value_L4),
    // .configLayer_Num(config_L4ayer_Num_L4),
    // .configNeuron_Num(config_Neuron_Num_L4),
    .out_o(layer4_out_o[1 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L4[1])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L4), .actutationType(actuationType_L4), .weightIntWidth(weightIntegerWidth_L4), .FileForBias("b_4_2.mif"), .FileForWeight("w_4_2.mif"),.NeuronNum(2), .NumWeight(num_Weight_L4), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L4)) n2_L41_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L4),
    .dataIn_Valid(module_Function_In_Valid_L4),
    // .weight_Valid(weight_Valid_L4),
    // .weight_Value(weight_Value_L4),
    // .bias_Valid(bias_Valid_L4),
    // .bias_Value(bias_Value_L4),
    // .configLayer_Num(config_L4ayer_Num_L4),
    // .configNeuron_Num(config_Neuron_Num_L4),
    .out_o(layer4_out_o[2 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L4[2])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L4), .actutationType(actuationType_L4), .weightIntWidth(weightIntegerWidth_L4), .FileForBias("b_4_3.mif"), .FileForWeight("w_4_3.mif"),.NeuronNum(3), .NumWeight(num_Weight_L4), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L4)) n3_L41_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L4),
    .dataIn_Valid(module_Function_In_Valid_L4),
    // .weight_Valid(weight_Valid_L4),
    // .weight_Value(weight_Value_L4),
    // .bias_Valid(bias_Valid_L4),
    // .bias_Value(bias_Value_L4),
    // .configLayer_Num(config_L4ayer_Num_L4),
    // .configNeuron_Num(config_Neuron_Num_L4),
    .out_o(layer4_out_o[3 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L4[3])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L4), .actutationType(actuationType_L4), .weightIntWidth(weightIntegerWidth_L4), .FileForBias("b_4_4.mif"), .FileForWeight("w_4_4.mif"),.NeuronNum(4), .NumWeight(num_Weight_L4), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L4)) n4_L41_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L4),
    .dataIn_Valid(module_Function_In_Valid_L4),
    // .weight_Valid(weight_Valid_L4),
    // .weight_Value(weight_Value_L4),
    // .bias_Valid(bias_Valid_L4),
    // .bias_Value(bias_Value_L4),
    // .configLayer_Num(config_L4ayer_Num_L4),
    // .configNeuron_Num(config_Neuron_Num_L4),
    .out_o(layer4_out_o[4 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L4[4])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L4), .actutationType(actuationType_L4), .weightIntWidth(weightIntegerWidth_L4), .FileForBias("b_4_5.mif"), .FileForWeight("w_4_5.mif"),.NeuronNum(5), .NumWeight(num_Weight_L4), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L4)) n5_L41_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L4),
    .dataIn_Valid(module_Function_In_Valid_L4),
    // .weight_Valid(weight_Valid_L4),
    // .weight_Value(weight_Value_L4),
    // .bias_Valid(bias_Valid_L4),
    // .bias_Value(bias_Value_L4),
    // .configLayer_Num(config_L4ayer_Num_L4),
    // .configNeuron_Num(config_Neuron_Num_L4),
    .out_o(layer4_out_o[5 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L4[5])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L4), .actutationType(actuationType_L4), .weightIntWidth(weightIntegerWidth_L4), .FileForBias("b_4_6.mif"), .FileForWeight("w_4_6.mif"),.NeuronNum(6), .NumWeight(num_Weight_L4), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L4)) n6_L41_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L4),
    .dataIn_Valid(module_Function_In_Valid_L4),
    // .weight_Valid(weight_Valid_L4),
    // .weight_Value(weight_Value_L4),
    // .bias_Valid(bias_Valid_L4),
    // .bias_Value(bias_Value_L4),
    // .configLayer_Num(config_L4ayer_Num_L4),
    // .configNeuron_Num(config_Neuron_Num_L4),
    .out_o(layer4_out_o[6 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L4[6])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L4), .actutationType(actuationType_L4), .weightIntWidth(weightIntegerWidth_L4), .FileForBias("b_4_7.mif"), .FileForWeight("w_4_7.mif"),.NeuronNum(7), .NumWeight(num_Weight_L4), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L4)) n7_L41_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L4),
    .dataIn_Valid(module_Function_In_Valid_L4),
    // .weight_Valid(weight_Valid_L4),
    // .weight_Value(weight_Value_L4),
    // .bias_Valid(bias_Valid_L4),
    // .bias_Value(bias_Value_L4),
    // .configLayer_Num(config_L4ayer_Num_L4),
    // .configNeuron_Num(config_Neuron_Num_L4),
    .out_o(layer4_out_o[7 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L4[7])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L4), .actutationType(actuationType_L4), .weightIntWidth(weightIntegerWidth_L4), .FileForBias("b_4_8.mif"), .FileForWeight("w_4_8.mif"),.NeuronNum(8), .NumWeight(num_Weight_L4), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L4)) n8_L41_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L4),
    .dataIn_Valid(module_Function_In_Valid_L4),
    // .weight_Valid(weight_Valid_L4),
    // .weight_Value(weight_Value_L4),
    // .bias_Valid(bias_Valid_L4),
    // .bias_Value(bias_Value_L4),
    // .configLayer_Num(config_L4ayer_Num_L4),
    // .configNeuron_Num(config_Neuron_Num_L4),
    .out_o(layer4_out_o[8 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L4[8])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L4), .actutationType(actuationType_L4), .weightIntWidth(weightIntegerWidth_L4), .FileForBias("b_4_9.mif"), .FileForWeight("w_4_9.mif"),.NeuronNum(9), .NumWeight(num_Weight_L4), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L4)) n9_L41_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L4),
    .dataIn_Valid(module_Function_In_Valid_L4),
    // .weight_Valid(weight_Valid_L4),
    // .weight_Value(weight_Value_L4),
    // .bias_Valid(bias_Valid_L4),
    // .bias_Value(bias_Value_L4),
    // .configLayer_Num(config_L4ayer_Num_L4),
    // .configNeuron_Num(config_Neuron_Num_L4),
    .out_o(layer4_out_o[9 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L4[9])
);



endmodule
