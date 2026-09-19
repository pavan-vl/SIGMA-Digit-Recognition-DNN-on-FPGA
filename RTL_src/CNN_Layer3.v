module layer_3_10N #(parameter NueronNumber_L3 = 10, dataWidth = 16, Layer_Number_L3 = 3, num_Weight_L3 = 30, SigmoidSize_L3 = 10, weightIntegerWidth_L3 = 4, actuationType_L3 = "relu") (
    input                                          clk,
    input                                          rstn,
//    input                                          weight_Valid_L3,
//    input   [31:0]                                 weight_Value_L3,
//    input                                          bias_Valid_L3,
//    input   [31:0]                                 bias_Value_L3,
//    input   [31:0]                                 config_Layer_Num_L3,
//    input   [31:0]                                 config_Neuron_Num_L3,
    input                                          module_Function_In_Valid_L3,
    input   [dataWidth - 1 : 0]                    module_Function_In_L3,
    output  [NueronNumber_L3 - 1:0]                output_Valid_L3,
    output  [NueronNumber_L3 * dataWidth -1:0]     layer3_out_o
);

    singl_neuron_mod #(.layerVal(Layer_Number_L3), .actutationType(actuationType_L3), .weightIntWidth(weightIntegerWidth_L3), .FileForBias("b_3_0.mif"), .FileForWeight("w_3_0.mif"),.NeuronNum(0), .NumWeight(num_Weight_L3), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L3)) n0_L31_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L3),
    .dataIn_Valid(module_Function_In_Valid_L3),
    // .weight_Valid(weight_Valid_L3),
    // .weight_Value(weight_Value_L3),
    // .bias_Valid(bias_Valid_L3),
    // .bias_Value(bias_Value_L3),
    // .configLayer_Num(config_L3ayer_Num_L3),
    // .configNeuron_Num(config_Neuron_Num_L3),
    .out_o(layer3_out_o[0 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L3[0])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L3), .actutationType(actuationType_L3), .weightIntWidth(weightIntegerWidth_L3), .FileForBias("b_3_1.mif"), .FileForWeight("w_3_1.mif"),.NeuronNum(1), .NumWeight(num_Weight_L3), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L3)) n1_L31_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L3),
    .dataIn_Valid(module_Function_In_Valid_L3),
    // .weight_Valid(weight_Valid_L3),
    // .weight_Value(weight_Value_L3),
    // .bias_Valid(bias_Valid_L3),
    // .bias_Value(bias_Value_L3),
    // .configLayer_Num(config_L3ayer_Num_L3),
    // .configNeuron_Num(config_Neuron_Num_L3),
    .out_o(layer3_out_o[1 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L3[1])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L3), .actutationType(actuationType_L3), .weightIntWidth(weightIntegerWidth_L3), .FileForBias("b_3_2.mif"), .FileForWeight("w_3_2.mif"),.NeuronNum(2), .NumWeight(num_Weight_L3), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L3)) n2_L31_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L3),
    .dataIn_Valid(module_Function_In_Valid_L3),
    // .weight_Valid(weight_Valid_L3),
    // .weight_Value(weight_Value_L3),
    // .bias_Valid(bias_Valid_L3),
    // .bias_Value(bias_Value_L3),
    // .configLayer_Num(config_L3ayer_Num_L3),
    // .configNeuron_Num(config_Neuron_Num_L3),
    .out_o(layer3_out_o[2 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L3[2])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L3), .actutationType(actuationType_L3), .weightIntWidth(weightIntegerWidth_L3), .FileForBias("b_3_3.mif"), .FileForWeight("w_3_3.mif"),.NeuronNum(3), .NumWeight(num_Weight_L3), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L3)) n3_L31_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L3),
    .dataIn_Valid(module_Function_In_Valid_L3),
    // .weight_Valid(weight_Valid_L3),
    // .weight_Value(weight_Value_L3),
    // .bias_Valid(bias_Valid_L3),
    // .bias_Value(bias_Value_L3),
    // .configLayer_Num(config_L3ayer_Num_L3),
    // .configNeuron_Num(config_Neuron_Num_L3),
    .out_o(layer3_out_o[3 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L3[3])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L3), .actutationType(actuationType_L3), .weightIntWidth(weightIntegerWidth_L3), .FileForBias("b_3_4.mif"), .FileForWeight("w_3_4.mif"),.NeuronNum(4), .NumWeight(num_Weight_L3), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L3)) n4_L31_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L3),
    .dataIn_Valid(module_Function_In_Valid_L3),
    // .weight_Valid(weight_Valid_L3),
    // .weight_Value(weight_Value_L3),
    // .bias_Valid(bias_Valid_L3),
    // .bias_Value(bias_Value_L3),
    // .configLayer_Num(config_L3ayer_Num_L3),
    // .configNeuron_Num(config_Neuron_Num_L3),
    .out_o(layer3_out_o[4 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L3[4])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L3), .actutationType(actuationType_L3), .weightIntWidth(weightIntegerWidth_L3), .FileForBias("b_3_5.mif"), .FileForWeight("w_3_5.mif"),.NeuronNum(5), .NumWeight(num_Weight_L3), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L3)) n5_L31_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L3),
    .dataIn_Valid(module_Function_In_Valid_L3),
    // .weight_Valid(weight_Valid_L3),
    // .weight_Value(weight_Value_L3),
    // .bias_Valid(bias_Valid_L3),
    // .bias_Value(bias_Value_L3),
    // .configLayer_Num(config_L3ayer_Num_L3),
    // .configNeuron_Num(config_Neuron_Num_L3),
    .out_o(layer3_out_o[5 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L3[5])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L3), .actutationType(actuationType_L3), .weightIntWidth(weightIntegerWidth_L3), .FileForBias("b_3_6.mif"), .FileForWeight("w_3_6.mif"),.NeuronNum(6), .NumWeight(num_Weight_L3), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L3)) n6_L31_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L3),
    .dataIn_Valid(module_Function_In_Valid_L3),
    // .weight_Valid(weight_Valid_L3),
    // .weight_Value(weight_Value_L3),
    // .bias_Valid(bias_Valid_L3),
    // .bias_Value(bias_Value_L3),
    // .configLayer_Num(config_L3ayer_Num_L3),
    // .configNeuron_Num(config_Neuron_Num_L3),
    .out_o(layer3_out_o[6 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L3[6])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L3), .actutationType(actuationType_L3), .weightIntWidth(weightIntegerWidth_L3), .FileForBias("b_3_7.mif"), .FileForWeight("w_3_7.mif"),.NeuronNum(7), .NumWeight(num_Weight_L3), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L3)) n7_L31_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L3),
    .dataIn_Valid(module_Function_In_Valid_L3),
    // .weight_Valid(weight_Valid_L3),
    // .weight_Value(weight_Value_L3),
    // .bias_Valid(bias_Valid_L3),
    // .bias_Value(bias_Value_L3),
    // .configLayer_Num(config_L3ayer_Num_L3),
    // .configNeuron_Num(config_Neuron_Num_L3),
    .out_o(layer3_out_o[7 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L3[7])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L3), .actutationType(actuationType_L3), .weightIntWidth(weightIntegerWidth_L3), .FileForBias("b_3_8.mif"), .FileForWeight("w_3_8.mif"),.NeuronNum(8), .NumWeight(num_Weight_L3), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L3)) n8_L31_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L3),
    .dataIn_Valid(module_Function_In_Valid_L3),
    // .weight_Valid(weight_Valid_L3),
    // .weight_Value(weight_Value_L3),
    // .bias_Valid(bias_Valid_L3),
    // .bias_Value(bias_Value_L3),
    // .configLayer_Num(config_L3ayer_Num_L3),
    // .configNeuron_Num(config_Neuron_Num_L3),
    .out_o(layer3_out_o[8 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L3[8])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L3), .actutationType(actuationType_L3), .weightIntWidth(weightIntegerWidth_L3), .FileForBias("b_3_9.mif"), .FileForWeight("w_3_9.mif"),.NeuronNum(9), .NumWeight(num_Weight_L3), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L3)) n9_L31_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L3),
    .dataIn_Valid(module_Function_In_Valid_L3),
    // .weight_Valid(weight_Valid_L3),
    // .weight_Value(weight_Value_L3),
    // .bias_Valid(bias_Valid_L3),
    // .bias_Value(bias_Value_L3),
    // .configLayer_Num(config_L3ayer_Num_L3),
    // .configNeuron_Num(config_Neuron_Num_L3),
    .out_o(layer3_out_o[9 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L3[9])
);



endmodule
