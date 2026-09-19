module layer_1_30N #(parameter NueronNumber_L1 = 30, dataWidth = 16, Layer_Number_L1 = 1, num_Weight_L1 = 784, SigmoidSize_L1 = 10, weightIntegerWidth_L1 = 4, actuationType_L1 = "relu") (
    input                                          clk,
    input                                          rstn,
//    input                                          weight_Valid_L1,
//    input   [31:0]                                 weight_Value_L1,
//    input                                          bias_Valid_L1,
//    input   [31:0]                                 bias_Value_L1,
//    input   [31:0]                                 config_Layer_Num_L1,
//    input   [31:0]                                 config_Neuron_Num_L1,
    input                                          module_Function_In_Valid_L1,
    input   [dataWidth - 1 : 0]                    module_Function_In_L1,
    output  [NueronNumber_L1 - 1:0]                output_Valid_L1,
    output  [NueronNumber_L1 * dataWidth -1:0]     layer1_out_o
);

    singl_neuron_mod #(.layerVal(Layer_Number_L1), .actutationType(actuationType_L1), .weightIntWidth(weightIntegerWidth_L1), .FileForBias("b_1_0.mif"), .FileForWeight("w_1_0.mif"),.NeuronNum(0), .NumWeight(num_Weight_L1), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L1)) n0_L11_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L1),
    .dataIn_Valid(module_Function_In_Valid_L1),
    // .weight_Valid(weight_Valid_L1),
    // .weight_Value(weight_Value_L1),
    // .bias_Valid(bias_Valid_L1),
    //.bias_Value(bias_Value_L1),
    // .configLayer_Num(config_L1ayer_Num_L1),
    // .configNeuron_Num(config_Neuron_Num_L1),
    .out_o(layer1_out_o[0 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L1[0])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L1), .actutationType(actuationType_L1), .weightIntWidth(weightIntegerWidth_L1), .FileForBias("b_1_1.mif"), .FileForWeight("w_1_1.mif"),.NeuronNum(1), .NumWeight(num_Weight_L1), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L1)) n1_L11_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L1),
    .dataIn_Valid(module_Function_In_Valid_L1),
    // .weight_Valid(weight_Valid_L1),
    // .weight_Value(weight_Value_L1),
    // .bias_Valid(bias_Valid_L1),
    //.bias_Value(bias_Value_L1),
    // .configLayer_Num(config_L1ayer_Num_L1),
    // .configNeuron_Num(config_Neuron_Num_L1),
    .out_o(layer1_out_o[1 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L1[1])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L1), .actutationType(actuationType_L1), .weightIntWidth(weightIntegerWidth_L1), .FileForBias("b_1_2.mif"), .FileForWeight("w_1_2.mif"),.NeuronNum(2), .NumWeight(num_Weight_L1), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L1)) n2_L11_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L1),
    .dataIn_Valid(module_Function_In_Valid_L1),
    // .weight_Valid(weight_Valid_L1),
    // .weight_Value(weight_Value_L1),
    // .bias_Valid(bias_Valid_L1),
    //.bias_Value(bias_Value_L1),
    // .configLayer_Num(config_L1ayer_Num_L1),
    // .configNeuron_Num(config_Neuron_Num_L1),
    .out_o(layer1_out_o[2 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L1[2])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L1), .actutationType(actuationType_L1), .weightIntWidth(weightIntegerWidth_L1), .FileForBias("b_1_3.mif"), .FileForWeight("w_1_3.mif"),.NeuronNum(3), .NumWeight(num_Weight_L1), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L1)) n3_L11_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L1),
    .dataIn_Valid(module_Function_In_Valid_L1),
    // .weight_Valid(weight_Valid_L1),
    // .weight_Value(weight_Value_L1),
    // .bias_Valid(bias_Valid_L1),
    //.bias_Value(bias_Value_L1),
    // .configLayer_Num(config_L1ayer_Num_L1),
    // .configNeuron_Num(config_Neuron_Num_L1),
    .out_o(layer1_out_o[3 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L1[3])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L1), .actutationType(actuationType_L1), .weightIntWidth(weightIntegerWidth_L1), .FileForBias("b_1_4.mif"), .FileForWeight("w_1_4.mif"),.NeuronNum(4), .NumWeight(num_Weight_L1), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L1)) n4_L11_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L1),
    .dataIn_Valid(module_Function_In_Valid_L1),
    // .weight_Valid(weight_Valid_L1),
    // .weight_Value(weight_Value_L1),
    // .bias_Valid(bias_Valid_L1),
    //.bias_Value(bias_Value_L1),
    // .configLayer_Num(config_L1ayer_Num_L1),
    // .configNeuron_Num(config_Neuron_Num_L1),
    .out_o(layer1_out_o[4 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L1[4])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L1), .actutationType(actuationType_L1), .weightIntWidth(weightIntegerWidth_L1), .FileForBias("b_1_5.mif"), .FileForWeight("w_1_5.mif"),.NeuronNum(5), .NumWeight(num_Weight_L1), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L1)) n5_L11_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L1),
    .dataIn_Valid(module_Function_In_Valid_L1),
    // .weight_Valid(weight_Valid_L1),
    // .weight_Value(weight_Value_L1),
    // .bias_Valid(bias_Valid_L1),
    //.bias_Value(bias_Value_L1),
    // .configLayer_Num(config_L1ayer_Num_L1),
    // .configNeuron_Num(config_Neuron_Num_L1),
    .out_o(layer1_out_o[5 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L1[5])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L1), .actutationType(actuationType_L1), .weightIntWidth(weightIntegerWidth_L1), .FileForBias("b_1_6.mif"), .FileForWeight("w_1_6.mif"),.NeuronNum(6), .NumWeight(num_Weight_L1), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L1)) n6_L11_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L1),
    .dataIn_Valid(module_Function_In_Valid_L1),
    // .weight_Valid(weight_Valid_L1),
    // .weight_Value(weight_Value_L1),
    // .bias_Valid(bias_Valid_L1),
    //.bias_Value(bias_Value_L1),
    // .configLayer_Num(config_L1ayer_Num_L1),
    // .configNeuron_Num(config_Neuron_Num_L1),
    .out_o(layer1_out_o[6 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L1[6])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L1), .actutationType(actuationType_L1), .weightIntWidth(weightIntegerWidth_L1), .FileForBias("b_1_7.mif"), .FileForWeight("w_1_7.mif"),.NeuronNum(7), .NumWeight(num_Weight_L1), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L1)) n7_L11_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L1),
    .dataIn_Valid(module_Function_In_Valid_L1),
    // .weight_Valid(weight_Valid_L1),
    // .weight_Value(weight_Value_L1),
    // .bias_Valid(bias_Valid_L1),
    //.bias_Value(bias_Value_L1),
    // .configLayer_Num(config_L1ayer_Num_L1),
    // .configNeuron_Num(config_Neuron_Num_L1),
    .out_o(layer1_out_o[7 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L1[7])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L1), .actutationType(actuationType_L1), .weightIntWidth(weightIntegerWidth_L1), .FileForBias("b_1_8.mif"), .FileForWeight("w_1_8.mif"),.NeuronNum(8), .NumWeight(num_Weight_L1), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L1)) n8_L11_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L1),
    .dataIn_Valid(module_Function_In_Valid_L1),
    // .weight_Valid(weight_Valid_L1),
    // .weight_Value(weight_Value_L1),
    // .bias_Valid(bias_Valid_L1),
    //.bias_Value(bias_Value_L1),
    // .configLayer_Num(config_L1ayer_Num_L1),
    // .configNeuron_Num(config_Neuron_Num_L1),
    .out_o(layer1_out_o[8 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L1[8])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L1), .actutationType(actuationType_L1), .weightIntWidth(weightIntegerWidth_L1), .FileForBias("b_1_9.mif"), .FileForWeight("w_1_9.mif"),.NeuronNum(9), .NumWeight(num_Weight_L1), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L1)) n9_L11_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L1),
    .dataIn_Valid(module_Function_In_Valid_L1),
    // .weight_Valid(weight_Valid_L1),
    // .weight_Value(weight_Value_L1),
    // .bias_Valid(bias_Valid_L1),
    //.bias_Value(bias_Value_L1),
    // .configLayer_Num(config_L1ayer_Num_L1),
    // .configNeuron_Num(config_Neuron_Num_L1),
    .out_o(layer1_out_o[9 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L1[9])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L1), .actutationType(actuationType_L1), .weightIntWidth(weightIntegerWidth_L1), .FileForBias("b_1_10.mif"), .FileForWeight("w_1_10.mif"),.NeuronNum(10), .NumWeight(num_Weight_L1), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L1)) n10_L11_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L1),
    .dataIn_Valid(module_Function_In_Valid_L1),
    // .weight_Valid(weight_Valid_L1),
    // .weight_Value(weight_Value_L1),
    // .bias_Valid(bias_Valid_L1),
    //.bias_Value(bias_Value_L1),
    // .configLayer_Num(config_L1ayer_Num_L1),
    // .configNeuron_Num(config_Neuron_Num_L1),
    .out_o(layer1_out_o[10 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L1[10])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L1), .actutationType(actuationType_L1), .weightIntWidth(weightIntegerWidth_L1), .FileForBias("b_1_11.mif"), .FileForWeight("w_1_11.mif"),.NeuronNum(11), .NumWeight(num_Weight_L1), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L1)) n11_L11_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L1),
    .dataIn_Valid(module_Function_In_Valid_L1),
    // .weight_Valid(weight_Valid_L1),
    // .weight_Value(weight_Value_L1),
    // .bias_Valid(bias_Valid_L1),
    //.bias_Value(bias_Value_L1),
    // .configLayer_Num(config_L1ayer_Num_L1),
    // .configNeuron_Num(config_Neuron_Num_L1),
    .out_o(layer1_out_o[11 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L1[11])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L1), .actutationType(actuationType_L1), .weightIntWidth(weightIntegerWidth_L1), .FileForBias("b_1_12.mif"), .FileForWeight("w_1_12.mif"),.NeuronNum(12), .NumWeight(num_Weight_L1), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L1)) n12_L11_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L1),
    .dataIn_Valid(module_Function_In_Valid_L1),
    // .weight_Valid(weight_Valid_L1),
    // .weight_Value(weight_Value_L1),
    // .bias_Valid(bias_Valid_L1),
    //.bias_Value(bias_Value_L1),
    // .configLayer_Num(config_L1ayer_Num_L1),
    // .configNeuron_Num(config_Neuron_Num_L1),
    .out_o(layer1_out_o[12 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L1[12])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L1), .actutationType(actuationType_L1), .weightIntWidth(weightIntegerWidth_L1), .FileForBias("b_1_13.mif"), .FileForWeight("w_1_13.mif"),.NeuronNum(13), .NumWeight(num_Weight_L1), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L1)) n13_L11_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L1),
    .dataIn_Valid(module_Function_In_Valid_L1),
    // .weight_Valid(weight_Valid_L1),
    // .weight_Value(weight_Value_L1),
    // .bias_Valid(bias_Valid_L1),
    //.bias_Value(bias_Value_L1),
    // .configLayer_Num(config_L1ayer_Num_L1),
    // .configNeuron_Num(config_Neuron_Num_L1),
    .out_o(layer1_out_o[13 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L1[13])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L1), .actutationType(actuationType_L1), .weightIntWidth(weightIntegerWidth_L1), .FileForBias("b_1_14.mif"), .FileForWeight("w_1_14.mif"),.NeuronNum(14), .NumWeight(num_Weight_L1), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L1)) n14_L11_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L1),
    .dataIn_Valid(module_Function_In_Valid_L1),
    // .weight_Valid(weight_Valid_L1),
    // .weight_Value(weight_Value_L1),
    // .bias_Valid(bias_Valid_L1),
    //.bias_Value(bias_Value_L1),
    // .configLayer_Num(config_L1ayer_Num_L1),
    // .configNeuron_Num(config_Neuron_Num_L1),
    .out_o(layer1_out_o[14 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L1[14])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L1), .actutationType(actuationType_L1), .weightIntWidth(weightIntegerWidth_L1), .FileForBias("b_1_15.mif"), .FileForWeight("w_1_15.mif"),.NeuronNum(15), .NumWeight(num_Weight_L1), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L1)) n15_L11_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L1),
    .dataIn_Valid(module_Function_In_Valid_L1),
    // .weight_Valid(weight_Valid_L1),
    // .weight_Value(weight_Value_L1),
    // .bias_Valid(bias_Valid_L1),
    //.bias_Value(bias_Value_L1),
    // .configLayer_Num(config_L1ayer_Num_L1),
    // .configNeuron_Num(config_Neuron_Num_L1),
    .out_o(layer1_out_o[15 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L1[15])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L1), .actutationType(actuationType_L1), .weightIntWidth(weightIntegerWidth_L1), .FileForBias("b_1_16.mif"), .FileForWeight("w_1_16.mif"),.NeuronNum(16), .NumWeight(num_Weight_L1), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L1)) n16_L11_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L1),
    .dataIn_Valid(module_Function_In_Valid_L1),
    // .weight_Valid(weight_Valid_L1),
    // .weight_Value(weight_Value_L1),
    // .bias_Valid(bias_Valid_L1),
    //.bias_Value(bias_Value_L1),
    // .configLayer_Num(config_L1ayer_Num_L1),
    // .configNeuron_Num(config_Neuron_Num_L1),
    .out_o(layer1_out_o[16 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L1[16])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L1), .actutationType(actuationType_L1), .weightIntWidth(weightIntegerWidth_L1), .FileForBias("b_1_17.mif"), .FileForWeight("w_1_17.mif"),.NeuronNum(17), .NumWeight(num_Weight_L1), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L1)) n17_L11_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L1),
    .dataIn_Valid(module_Function_In_Valid_L1),
    // .weight_Valid(weight_Valid_L1),
    // .weight_Value(weight_Value_L1),
    // .bias_Valid(bias_Valid_L1),
    //.bias_Value(bias_Value_L1),
    // .configLayer_Num(config_L1ayer_Num_L1),
    // .configNeuron_Num(config_Neuron_Num_L1),
    .out_o(layer1_out_o[17 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L1[17])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L1), .actutationType(actuationType_L1), .weightIntWidth(weightIntegerWidth_L1), .FileForBias("b_1_18.mif"), .FileForWeight("w_1_18.mif"),.NeuronNum(18), .NumWeight(num_Weight_L1), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L1)) n18_L11_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L1),
    .dataIn_Valid(module_Function_In_Valid_L1),
    // .weight_Valid(weight_Valid_L1),
    // .weight_Value(weight_Value_L1),
    // .bias_Valid(bias_Valid_L1),
    //.bias_Value(bias_Value_L1),
    // .configLayer_Num(config_L1ayer_Num_L1),
    // .configNeuron_Num(config_Neuron_Num_L1),
    .out_o(layer1_out_o[18 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L1[18])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L1), .actutationType(actuationType_L1), .weightIntWidth(weightIntegerWidth_L1), .FileForBias("b_1_19.mif"), .FileForWeight("w_1_19.mif"),.NeuronNum(19), .NumWeight(num_Weight_L1), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L1)) n19_L11_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L1),
    .dataIn_Valid(module_Function_In_Valid_L1),
    // .weight_Valid(weight_Valid_L1),
    // .weight_Value(weight_Value_L1),
    // .bias_Valid(bias_Valid_L1),
    //.bias_Value(bias_Value_L1),
    // .configLayer_Num(config_L1ayer_Num_L1),
    // .configNeuron_Num(config_Neuron_Num_L1),
    .out_o(layer1_out_o[19 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L1[19])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L1), .actutationType(actuationType_L1), .weightIntWidth(weightIntegerWidth_L1), .FileForBias("b_1_20.mif"), .FileForWeight("w_1_20.mif"),.NeuronNum(20), .NumWeight(num_Weight_L1), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L1)) n20_L11_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L1),
    .dataIn_Valid(module_Function_In_Valid_L1),
    // .weight_Valid(weight_Valid_L1),
    // .weight_Value(weight_Value_L1),
    // .bias_Valid(bias_Valid_L1),
    //.bias_Value(bias_Value_L1),
    // .configLayer_Num(config_L1ayer_Num_L1),
    // .configNeuron_Num(config_Neuron_Num_L1),
    .out_o(layer1_out_o[20 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L1[20])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L1), .actutationType(actuationType_L1), .weightIntWidth(weightIntegerWidth_L1), .FileForBias("b_1_21.mif"), .FileForWeight("w_1_21.mif"),.NeuronNum(21), .NumWeight(num_Weight_L1), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L1)) n21_L11_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L1),
    .dataIn_Valid(module_Function_In_Valid_L1),
    // .weight_Valid(weight_Valid_L1),
    // .weight_Value(weight_Value_L1),
    // .bias_Valid(bias_Valid_L1),
    //.bias_Value(bias_Value_L1),
    // .configLayer_Num(config_L1ayer_Num_L1),
    // .configNeuron_Num(config_Neuron_Num_L1),
    .out_o(layer1_out_o[21 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L1[21])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L1), .actutationType(actuationType_L1), .weightIntWidth(weightIntegerWidth_L1), .FileForBias("b_1_22.mif"), .FileForWeight("w_1_22.mif"),.NeuronNum(22), .NumWeight(num_Weight_L1), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L1)) n22_L11_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L1),
    .dataIn_Valid(module_Function_In_Valid_L1),
    // .weight_Valid(weight_Valid_L1),
    // .weight_Value(weight_Value_L1),
    // .bias_Valid(bias_Valid_L1),
    //.bias_Value(bias_Value_L1),
    // .configLayer_Num(config_L1ayer_Num_L1),
    // .configNeuron_Num(config_Neuron_Num_L1),
    .out_o(layer1_out_o[22 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L1[22])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L1), .actutationType(actuationType_L1), .weightIntWidth(weightIntegerWidth_L1), .FileForBias("b_1_23.mif"), .FileForWeight("w_1_23.mif"),.NeuronNum(23), .NumWeight(num_Weight_L1), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L1)) n23_L11_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L1),
    .dataIn_Valid(module_Function_In_Valid_L1),
    // .weight_Valid(weight_Valid_L1),
    // .weight_Value(weight_Value_L1),
    // .bias_Valid(bias_Valid_L1),
    //.bias_Value(bias_Value_L1),
    // .configLayer_Num(config_L1ayer_Num_L1),
    // .configNeuron_Num(config_Neuron_Num_L1),
    .out_o(layer1_out_o[23 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L1[23])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L1), .actutationType(actuationType_L1), .weightIntWidth(weightIntegerWidth_L1), .FileForBias("b_1_24.mif"), .FileForWeight("w_1_24.mif"),.NeuronNum(24), .NumWeight(num_Weight_L1), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L1)) n24_L11_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L1),
    .dataIn_Valid(module_Function_In_Valid_L1),
    // .weight_Valid(weight_Valid_L1),
    // .weight_Value(weight_Value_L1),
    // .bias_Valid(bias_Valid_L1),
    //.bias_Value(bias_Value_L1),
    // .configLayer_Num(config_L1ayer_Num_L1),
    // .configNeuron_Num(config_Neuron_Num_L1),
    .out_o(layer1_out_o[24 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L1[24])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L1), .actutationType(actuationType_L1), .weightIntWidth(weightIntegerWidth_L1), .FileForBias("b_1_25.mif"), .FileForWeight("w_1_25.mif"),.NeuronNum(25), .NumWeight(num_Weight_L1), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L1)) n25_L11_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L1),
    .dataIn_Valid(module_Function_In_Valid_L1),
    // .weight_Valid(weight_Valid_L1),
    // .weight_Value(weight_Value_L1),
    // .bias_Valid(bias_Valid_L1),
    //.bias_Value(bias_Value_L1),
    // .configLayer_Num(config_L1ayer_Num_L1),
    // .configNeuron_Num(config_Neuron_Num_L1),
    .out_o(layer1_out_o[25 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L1[25])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L1), .actutationType(actuationType_L1), .weightIntWidth(weightIntegerWidth_L1), .FileForBias("b_1_26.mif"), .FileForWeight("w_1_26.mif"),.NeuronNum(26), .NumWeight(num_Weight_L1), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L1)) n26_L11_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L1),
    .dataIn_Valid(module_Function_In_Valid_L1),
    // .weight_Valid(weight_Valid_L1),
    // .weight_Value(weight_Value_L1),
    // .bias_Valid(bias_Valid_L1),
    //.bias_Value(bias_Value_L1),
    // .configLayer_Num(config_L1ayer_Num_L1),
    // .configNeuron_Num(config_Neuron_Num_L1),
    .out_o(layer1_out_o[26 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L1[26])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L1), .actutationType(actuationType_L1), .weightIntWidth(weightIntegerWidth_L1), .FileForBias("b_1_27.mif"), .FileForWeight("w_1_27.mif"),.NeuronNum(27), .NumWeight(num_Weight_L1), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L1)) n27_L11_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L1),
    .dataIn_Valid(module_Function_In_Valid_L1),
    // .weight_Valid(weight_Valid_L1),
    // .weight_Value(weight_Value_L1),
    // .bias_Valid(bias_Valid_L1),
    //.bias_Value(bias_Value_L1),
    // .configLayer_Num(config_L1ayer_Num_L1),
    // .configNeuron_Num(config_Neuron_Num_L1),
    .out_o(layer1_out_o[27 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L1[27])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L1), .actutationType(actuationType_L1), .weightIntWidth(weightIntegerWidth_L1), .FileForBias("b_1_28.mif"), .FileForWeight("w_1_28.mif"),.NeuronNum(28), .NumWeight(num_Weight_L1), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L1)) n28_L11_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L1),
    .dataIn_Valid(module_Function_In_Valid_L1),
    // .weight_Valid(weight_Valid_L1),
    // .weight_Value(weight_Value_L1),
    // .bias_Valid(bias_Valid_L1),
    //.bias_Value(bias_Value_L1),
    // .configLayer_Num(config_L1ayer_Num_L1),
    // .configNeuron_Num(config_Neuron_Num_L1),
    .out_o(layer1_out_o[28 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L1[28])
);


    singl_neuron_mod #(.layerVal(Layer_Number_L1), .actutationType(actuationType_L1), .weightIntWidth(weightIntegerWidth_L1), .FileForBias("b_1_29.mif"), .FileForWeight("w_1_29.mif"),.NeuronNum(29), .NumWeight(num_Weight_L1), .dataWidth(dataWidth), .sigmoidSize(SigmoidSize_L1)) n29_L11_inst (
    .clk(clk),
    .rstn(rstn),
    .dataIn(module_Function_In_L1),
    .dataIn_Valid(module_Function_In_Valid_L1),
    // .weight_Valid(weight_Valid_L1),
    // .weight_Value(weight_Value_L1),
    // .bias_Valid(bias_Valid_L1),
    //.bias_Value(bias_Value_L1),
    // .configLayer_Num(config_L1ayer_Num_L1),
    // .configNeuron_Num(config_Neuron_Num_L1),
    .out_o(layer1_out_o[29 * dataWidth+: dataWidth]),
    .out_Valid_o(output_Valid_L1[29])
);


endmodule
