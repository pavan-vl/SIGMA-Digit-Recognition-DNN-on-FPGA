module layer_2_30N #(parameter NueronNumber_L2 = 30, dataWidth = 16, Layer_Number_L2 = 2, num_Weight_L2 = 30, SigmoidSize_L2 = 10, weightIntegerWidth_L2 = 4, actuationType_L2 = "relu") (
    input                                          clk,
    input                                          rstn,
//    input                                          weight_Valid_L2,
//    input   [31:0]                                 weight_Value_L2,
//    input                                          bias_Valid_L2,
//    input   [31:0]                                 bias_Value_L2,
//    input   [31:0]                                 config_Layer_Num_L2,
//    input   [31:0]                                 config_Neuron_Num_L2,
    input                                          module_Function_In_Valid_L2,
    input   [dataWidth - 1 : 0]                    module_Function_In_L2,
    output  [NueronNumber_L2 - 1:0]                output_Valid_L2,
    output  [NueronNumber_L2 * dataWidth -1:0]     layer2_out_o
);

    singl_neuron_mod #(.layerVal(Layer_Number_L2), .actutationType(actuationType_L2), .weightIntWidth(weightIntegerWidth_L2), .FileForBias("b_2_0.mif"), .FileForWeight("w_2_0.mif"),.NeuronNum(0), .NumWeight(num_Weight_L2), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L2)) n0_L21_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L2),
    .dataIn_Valid(module_Function_In_Valid_L2),
    // .weight_Valid(weight_Valid_L2),
    // .weight_Value(weight_Value_L2),
    // .bias_Valid(bias_Valid_L2),
    // .bias_Value(bias_Value_L2),
    // .configLayer_Num(config_L2ayer_Num_L2),
    //.configNeuron_Num(config_Neuron_Num_L2),
    .out_o(layer2_out_o[0 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L2[0])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L2), .actutationType(actuationType_L2), .weightIntWidth(weightIntegerWidth_L2), .FileForBias("b_2_1.mif"), .FileForWeight("w_2_1.mif"),.NeuronNum(1), .NumWeight(num_Weight_L2), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L2)) n1_L21_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L2),
    .dataIn_Valid(module_Function_In_Valid_L2),
    // .weight_Valid(weight_Valid_L2),
    // .weight_Value(weight_Value_L2),
    // .bias_Valid(bias_Valid_L2),
    // .bias_Value(bias_Value_L2),
    // .configLayer_Num(config_L2ayer_Num_L2),
    //.configNeuron_Num(config_Neuron_Num_L2),
    .out_o(layer2_out_o[1 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L2[1])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L2), .actutationType(actuationType_L2), .weightIntWidth(weightIntegerWidth_L2), .FileForBias("b_2_2.mif"), .FileForWeight("w_2_2.mif"),.NeuronNum(2), .NumWeight(num_Weight_L2), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L2)) n2_L21_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L2),
    .dataIn_Valid(module_Function_In_Valid_L2),
    // .weight_Valid(weight_Valid_L2),
    // .weight_Value(weight_Value_L2),
    // .bias_Valid(bias_Valid_L2),
    // .bias_Value(bias_Value_L2),
    // .configLayer_Num(config_L2ayer_Num_L2),
    //.configNeuron_Num(config_Neuron_Num_L2),
    .out_o(layer2_out_o[2 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L2[2])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L2), .actutationType(actuationType_L2), .weightIntWidth(weightIntegerWidth_L2), .FileForBias("b_2_3.mif"), .FileForWeight("w_2_3.mif"),.NeuronNum(3), .NumWeight(num_Weight_L2), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L2)) n3_L21_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L2),
    .dataIn_Valid(module_Function_In_Valid_L2),
    // .weight_Valid(weight_Valid_L2),
    // .weight_Value(weight_Value_L2),
    // .bias_Valid(bias_Valid_L2),
    // .bias_Value(bias_Value_L2),
    // .configLayer_Num(config_L2ayer_Num_L2),
    //.configNeuron_Num(config_Neuron_Num_L2),
    .out_o(layer2_out_o[3 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L2[3])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L2), .actutationType(actuationType_L2), .weightIntWidth(weightIntegerWidth_L2), .FileForBias("b_2_4.mif"), .FileForWeight("w_2_4.mif"),.NeuronNum(4), .NumWeight(num_Weight_L2), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L2)) n4_L21_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L2),
    .dataIn_Valid(module_Function_In_Valid_L2),
    // .weight_Valid(weight_Valid_L2),
    // .weight_Value(weight_Value_L2),
    // .bias_Valid(bias_Valid_L2),
    // .bias_Value(bias_Value_L2),
    // .configLayer_Num(config_L2ayer_Num_L2),
    //.configNeuron_Num(config_Neuron_Num_L2),
    .out_o(layer2_out_o[4 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L2[4])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L2), .actutationType(actuationType_L2), .weightIntWidth(weightIntegerWidth_L2), .FileForBias("b_2_5.mif"), .FileForWeight("w_2_5.mif"),.NeuronNum(5), .NumWeight(num_Weight_L2), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L2)) n5_L21_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L2),
    .dataIn_Valid(module_Function_In_Valid_L2),
    // .weight_Valid(weight_Valid_L2),
    // .weight_Value(weight_Value_L2),
    // .bias_Valid(bias_Valid_L2),
    // .bias_Value(bias_Value_L2),
    // .configLayer_Num(config_L2ayer_Num_L2),
    //.configNeuron_Num(config_Neuron_Num_L2),
    .out_o(layer2_out_o[5 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L2[5])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L2), .actutationType(actuationType_L2), .weightIntWidth(weightIntegerWidth_L2), .FileForBias("b_2_6.mif"), .FileForWeight("w_2_6.mif"),.NeuronNum(6), .NumWeight(num_Weight_L2), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L2)) n6_L21_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L2),
    .dataIn_Valid(module_Function_In_Valid_L2),
    // .weight_Valid(weight_Valid_L2),
    // .weight_Value(weight_Value_L2),
    // .bias_Valid(bias_Valid_L2),
    // .bias_Value(bias_Value_L2),
    // .configLayer_Num(config_L2ayer_Num_L2),
    //.configNeuron_Num(config_Neuron_Num_L2),
    .out_o(layer2_out_o[6 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L2[6])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L2), .actutationType(actuationType_L2), .weightIntWidth(weightIntegerWidth_L2), .FileForBias("b_2_7.mif"), .FileForWeight("w_2_7.mif"),.NeuronNum(7), .NumWeight(num_Weight_L2), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L2)) n7_L21_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L2),
    .dataIn_Valid(module_Function_In_Valid_L2),
    // .weight_Valid(weight_Valid_L2),
    // .weight_Value(weight_Value_L2),
    // .bias_Valid(bias_Valid_L2),
    // .bias_Value(bias_Value_L2),
    // .configLayer_Num(config_L2ayer_Num_L2),
    //.configNeuron_Num(config_Neuron_Num_L2),
    .out_o(layer2_out_o[7 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L2[7])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L2), .actutationType(actuationType_L2), .weightIntWidth(weightIntegerWidth_L2), .FileForBias("b_2_8.mif"), .FileForWeight("w_2_8.mif"),.NeuronNum(8), .NumWeight(num_Weight_L2), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L2)) n8_L21_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L2),
    .dataIn_Valid(module_Function_In_Valid_L2),
    // .weight_Valid(weight_Valid_L2),
    // .weight_Value(weight_Value_L2),
    // .bias_Valid(bias_Valid_L2),
    // .bias_Value(bias_Value_L2),
    // .configLayer_Num(config_L2ayer_Num_L2),
    //.configNeuron_Num(config_Neuron_Num_L2),
    .out_o(layer2_out_o[8 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L2[8])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L2), .actutationType(actuationType_L2), .weightIntWidth(weightIntegerWidth_L2), .FileForBias("b_2_9.mif"), .FileForWeight("w_2_9.mif"),.NeuronNum(9), .NumWeight(num_Weight_L2), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L2)) n9_L21_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L2),
    .dataIn_Valid(module_Function_In_Valid_L2),
    // .weight_Valid(weight_Valid_L2),
    // .weight_Value(weight_Value_L2),
    // .bias_Valid(bias_Valid_L2),
    // .bias_Value(bias_Value_L2),
    // .configLayer_Num(config_L2ayer_Num_L2),
    //.configNeuron_Num(config_Neuron_Num_L2),
    .out_o(layer2_out_o[9 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L2[9])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L2), .actutationType(actuationType_L2), .weightIntWidth(weightIntegerWidth_L2), .FileForBias("b_2_10.mif"), .FileForWeight("w_2_10.mif"),.NeuronNum(10), .NumWeight(num_Weight_L2), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L2)) n10_L21_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L2),
    .dataIn_Valid(module_Function_In_Valid_L2),
    // .weight_Valid(weight_Valid_L2),
    // .weight_Value(weight_Value_L2),
    // .bias_Valid(bias_Valid_L2),
    // .bias_Value(bias_Value_L2),
    // .configLayer_Num(config_L2ayer_Num_L2),
    //.configNeuron_Num(config_Neuron_Num_L2),
    .out_o(layer2_out_o[10 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L2[10])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L2), .actutationType(actuationType_L2), .weightIntWidth(weightIntegerWidth_L2), .FileForBias("b_2_11.mif"), .FileForWeight("w_2_11.mif"),.NeuronNum(11), .NumWeight(num_Weight_L2), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L2)) n11_L21_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L2),
    .dataIn_Valid(module_Function_In_Valid_L2),
    // .weight_Valid(weight_Valid_L2),
    // .weight_Value(weight_Value_L2),
    // .bias_Valid(bias_Valid_L2),
    // .bias_Value(bias_Value_L2),
    // .configLayer_Num(config_L2ayer_Num_L2),
    //.configNeuron_Num(config_Neuron_Num_L2),
    .out_o(layer2_out_o[11 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L2[11])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L2), .actutationType(actuationType_L2), .weightIntWidth(weightIntegerWidth_L2), .FileForBias("b_2_12.mif"), .FileForWeight("w_2_12.mif"),.NeuronNum(12), .NumWeight(num_Weight_L2), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L2)) n12_L21_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L2),
    .dataIn_Valid(module_Function_In_Valid_L2),
    // .weight_Valid(weight_Valid_L2),
    // .weight_Value(weight_Value_L2),
    // .bias_Valid(bias_Valid_L2),
    // .bias_Value(bias_Value_L2),
    // .configLayer_Num(config_L2ayer_Num_L2),
    //.configNeuron_Num(config_Neuron_Num_L2),
    .out_o(layer2_out_o[12 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L2[12])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L2), .actutationType(actuationType_L2), .weightIntWidth(weightIntegerWidth_L2), .FileForBias("b_2_13.mif"), .FileForWeight("w_2_13.mif"),.NeuronNum(13), .NumWeight(num_Weight_L2), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L2)) n13_L21_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L2),
    .dataIn_Valid(module_Function_In_Valid_L2),
    // .weight_Valid(weight_Valid_L2),
    // .weight_Value(weight_Value_L2),
    // .bias_Valid(bias_Valid_L2),
    // .bias_Value(bias_Value_L2),
    // .configLayer_Num(config_L2ayer_Num_L2),
    //.configNeuron_Num(config_Neuron_Num_L2),
    .out_o(layer2_out_o[13 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L2[13])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L2), .actutationType(actuationType_L2), .weightIntWidth(weightIntegerWidth_L2), .FileForBias("b_2_14.mif"), .FileForWeight("w_2_14.mif"),.NeuronNum(14), .NumWeight(num_Weight_L2), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L2)) n14_L21_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L2),
    .dataIn_Valid(module_Function_In_Valid_L2),
    // .weight_Valid(weight_Valid_L2),
    // .weight_Value(weight_Value_L2),
    // .bias_Valid(bias_Valid_L2),
    // .bias_Value(bias_Value_L2),
    // .configLayer_Num(config_L2ayer_Num_L2),
    //.configNeuron_Num(config_Neuron_Num_L2),
    .out_o(layer2_out_o[14 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L2[14])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L2), .actutationType(actuationType_L2), .weightIntWidth(weightIntegerWidth_L2), .FileForBias("b_2_15.mif"), .FileForWeight("w_2_15.mif"),.NeuronNum(15), .NumWeight(num_Weight_L2), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L2)) n15_L21_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L2),
    .dataIn_Valid(module_Function_In_Valid_L2),
    // .weight_Valid(weight_Valid_L2),
    // .weight_Value(weight_Value_L2),
    // .bias_Valid(bias_Valid_L2),
    // .bias_Value(bias_Value_L2),
    // .configLayer_Num(config_L2ayer_Num_L2),
    //.configNeuron_Num(config_Neuron_Num_L2),
    .out_o(layer2_out_o[15 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L2[15])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L2), .actutationType(actuationType_L2), .weightIntWidth(weightIntegerWidth_L2), .FileForBias("b_2_16.mif"), .FileForWeight("w_2_16.mif"),.NeuronNum(16), .NumWeight(num_Weight_L2), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L2)) n16_L21_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L2),
    .dataIn_Valid(module_Function_In_Valid_L2),
    // .weight_Valid(weight_Valid_L2),
    // .weight_Value(weight_Value_L2),
    // .bias_Valid(bias_Valid_L2),
    // .bias_Value(bias_Value_L2),
    // .configLayer_Num(config_L2ayer_Num_L2),
    //.configNeuron_Num(config_Neuron_Num_L2),
    .out_o(layer2_out_o[16 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L2[16])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L2), .actutationType(actuationType_L2), .weightIntWidth(weightIntegerWidth_L2), .FileForBias("b_2_17.mif"), .FileForWeight("w_2_17.mif"),.NeuronNum(17), .NumWeight(num_Weight_L2), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L2)) n17_L21_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L2),
    .dataIn_Valid(module_Function_In_Valid_L2),
    // .weight_Valid(weight_Valid_L2),
    // .weight_Value(weight_Value_L2),
    // .bias_Valid(bias_Valid_L2),
    // .bias_Value(bias_Value_L2),
    // .configLayer_Num(config_L2ayer_Num_L2),
    //.configNeuron_Num(config_Neuron_Num_L2),
    .out_o(layer2_out_o[17 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L2[17])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L2), .actutationType(actuationType_L2), .weightIntWidth(weightIntegerWidth_L2), .FileForBias("b_2_18.mif"), .FileForWeight("w_2_18.mif"),.NeuronNum(18), .NumWeight(num_Weight_L2), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L2)) n18_L21_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L2),
    .dataIn_Valid(module_Function_In_Valid_L2),
    // .weight_Valid(weight_Valid_L2),
    // .weight_Value(weight_Value_L2),
    // .bias_Valid(bias_Valid_L2),
    // .bias_Value(bias_Value_L2),
    // .configLayer_Num(config_L2ayer_Num_L2),
    //.configNeuron_Num(config_Neuron_Num_L2),
    .out_o(layer2_out_o[18 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L2[18])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L2), .actutationType(actuationType_L2), .weightIntWidth(weightIntegerWidth_L2), .FileForBias("b_2_19.mif"), .FileForWeight("w_2_19.mif"),.NeuronNum(19), .NumWeight(num_Weight_L2), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L2)) n19_L21_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L2),
    .dataIn_Valid(module_Function_In_Valid_L2),
    // .weight_Valid(weight_Valid_L2),
    // .weight_Value(weight_Value_L2),
    // .bias_Valid(bias_Valid_L2),
    // .bias_Value(bias_Value_L2),
    // .configLayer_Num(config_L2ayer_Num_L2),
    //.configNeuron_Num(config_Neuron_Num_L2),
    .out_o(layer2_out_o[19 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L2[19])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L2), .actutationType(actuationType_L2), .weightIntWidth(weightIntegerWidth_L2), .FileForBias("b_2_20.mif"), .FileForWeight("w_2_20.mif"),.NeuronNum(20), .NumWeight(num_Weight_L2), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L2)) n20_L21_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L2),
    .dataIn_Valid(module_Function_In_Valid_L2),
    // .weight_Valid(weight_Valid_L2),
    // .weight_Value(weight_Value_L2),
    // .bias_Valid(bias_Valid_L2),
    // .bias_Value(bias_Value_L2),
    // .configLayer_Num(config_L2ayer_Num_L2),
    //.configNeuron_Num(config_Neuron_Num_L2),
    .out_o(layer2_out_o[20 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L2[20])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L2), .actutationType(actuationType_L2), .weightIntWidth(weightIntegerWidth_L2), .FileForBias("b_2_21.mif"), .FileForWeight("w_2_21.mif"),.NeuronNum(21), .NumWeight(num_Weight_L2), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L2)) n21_L21_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L2),
    .dataIn_Valid(module_Function_In_Valid_L2),
    // .weight_Valid(weight_Valid_L2),
    // .weight_Value(weight_Value_L2),
    // .bias_Valid(bias_Valid_L2),
    // .bias_Value(bias_Value_L2),
    // .configLayer_Num(config_L2ayer_Num_L2),
    //.configNeuron_Num(config_Neuron_Num_L2),
    .out_o(layer2_out_o[21 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L2[21])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L2), .actutationType(actuationType_L2), .weightIntWidth(weightIntegerWidth_L2), .FileForBias("b_2_22.mif"), .FileForWeight("w_2_22.mif"),.NeuronNum(22), .NumWeight(num_Weight_L2), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L2)) n22_L21_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L2),
    .dataIn_Valid(module_Function_In_Valid_L2),
    // .weight_Valid(weight_Valid_L2),
    // .weight_Value(weight_Value_L2),
    // .bias_Valid(bias_Valid_L2),
    // .bias_Value(bias_Value_L2),
    // .configLayer_Num(config_L2ayer_Num_L2),
    //.configNeuron_Num(config_Neuron_Num_L2),
    .out_o(layer2_out_o[22 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L2[22])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L2), .actutationType(actuationType_L2), .weightIntWidth(weightIntegerWidth_L2), .FileForBias("b_2_23.mif"), .FileForWeight("w_2_23.mif"),.NeuronNum(23), .NumWeight(num_Weight_L2), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L2)) n23_L21_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L2),
    .dataIn_Valid(module_Function_In_Valid_L2),
    // .weight_Valid(weight_Valid_L2),
    // .weight_Value(weight_Value_L2),
    // .bias_Valid(bias_Valid_L2),
    // .bias_Value(bias_Value_L2),
    // .configLayer_Num(config_L2ayer_Num_L2),
    //.configNeuron_Num(config_Neuron_Num_L2),
    .out_o(layer2_out_o[23 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L2[23])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L2), .actutationType(actuationType_L2), .weightIntWidth(weightIntegerWidth_L2), .FileForBias("b_2_24.mif"), .FileForWeight("w_2_24.mif"),.NeuronNum(24), .NumWeight(num_Weight_L2), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L2)) n24_L21_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L2),
    .dataIn_Valid(module_Function_In_Valid_L2),
    // .weight_Valid(weight_Valid_L2),
    // .weight_Value(weight_Value_L2),
    // .bias_Valid(bias_Valid_L2),
    // .bias_Value(bias_Value_L2),
    // .configLayer_Num(config_L2ayer_Num_L2),
    //.configNeuron_Num(config_Neuron_Num_L2),
    .out_o(layer2_out_o[24 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L2[24])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L2), .actutationType(actuationType_L2), .weightIntWidth(weightIntegerWidth_L2), .FileForBias("b_2_25.mif"), .FileForWeight("w_2_25.mif"),.NeuronNum(25), .NumWeight(num_Weight_L2), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L2)) n25_L21_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L2),
    .dataIn_Valid(module_Function_In_Valid_L2),
    // .weight_Valid(weight_Valid_L2),
    // .weight_Value(weight_Value_L2),
    // .bias_Valid(bias_Valid_L2),
    // .bias_Value(bias_Value_L2),
    // .configLayer_Num(config_L2ayer_Num_L2),
    //.configNeuron_Num(config_Neuron_Num_L2),
    .out_o(layer2_out_o[25 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L2[25])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L2), .actutationType(actuationType_L2), .weightIntWidth(weightIntegerWidth_L2), .FileForBias("b_2_26.mif"), .FileForWeight("w_2_26.mif"),.NeuronNum(26), .NumWeight(num_Weight_L2), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L2)) n26_L21_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L2),
    .dataIn_Valid(module_Function_In_Valid_L2),
    // .weight_Valid(weight_Valid_L2),
    // .weight_Value(weight_Value_L2),
    // .bias_Valid(bias_Valid_L2),
    // .bias_Value(bias_Value_L2),
    // .configLayer_Num(config_L2ayer_Num_L2),
    //.configNeuron_Num(config_Neuron_Num_L2),
    .out_o(layer2_out_o[26 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L2[26])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L2), .actutationType(actuationType_L2), .weightIntWidth(weightIntegerWidth_L2), .FileForBias("b_2_27.mif"), .FileForWeight("w_2_27.mif"),.NeuronNum(27), .NumWeight(num_Weight_L2), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L2)) n27_L21_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L2),
    .dataIn_Valid(module_Function_In_Valid_L2),
    // .weight_Valid(weight_Valid_L2),
    // .weight_Value(weight_Value_L2),
    // .bias_Valid(bias_Valid_L2),
    // .bias_Value(bias_Value_L2),
    // .configLayer_Num(config_L2ayer_Num_L2),
    //.configNeuron_Num(config_Neuron_Num_L2),
    .out_o(layer2_out_o[27 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L2[27])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L2), .actutationType(actuationType_L2), .weightIntWidth(weightIntegerWidth_L2), .FileForBias("b_2_28.mif"), .FileForWeight("w_2_28.mif"),.NeuronNum(28), .NumWeight(num_Weight_L2), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L2)) n28_L21_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L2),
    .dataIn_Valid(module_Function_In_Valid_L2),
    // .weight_Valid(weight_Valid_L2),
    // .weight_Value(weight_Value_L2),
    // .bias_Valid(bias_Valid_L2),
    // .bias_Value(bias_Value_L2),
    // .configLayer_Num(config_L2ayer_Num_L2),
    //.configNeuron_Num(config_Neuron_Num_L2),
    .out_o(layer2_out_o[28 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L2[28])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L2), .actutationType(actuationType_L2), .weightIntWidth(weightIntegerWidth_L2), .FileForBias("b_2_29.mif"), .FileForWeight("w_2_29.mif"),.NeuronNum(29), .NumWeight(num_Weight_L2), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L2)) n29_L21_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L2),
    .dataIn_Valid(module_Function_In_Valid_L2),
    // .weight_Valid(weight_Valid_L2),
    // .weight_Value(weight_Value_L2),
    // .bias_Valid(bias_Valid_L2),
    // .bias_Value(bias_Value_L2),
    // .configLayer_Num(config_L2ayer_Num_L2),
    //.configNeuron_Num(config_Neuron_Num_L2),
    .out_o(layer2_out_o[29 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L2[29])
);


endmodule
