
`timescale 1 ns / 1 ps

	module DNN_Digit_Recog_Sig5 #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface S00_AXIS
		parameter integer C_S00_AXIS_TDATA_WIDTH	= 32,

		// Parameters of Axi Slave Bus Interface s00_axi
		parameter integer C_s00_axi_DATA_WIDTH	= 32,
		parameter integer C_s00_axi_ADDR_WIDTH	= 5
	)
	(
		// Users to add ports here

		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Slave Bus Interface S00_AXIS
		input wire  s00_axis_aclk,
		input wire  s00_axis_aresetn,
		output wire  s00_axis_tready,
		input wire [C_S00_AXIS_TDATA_WIDTH-1 : 0] s00_axis_tdata,
		input wire [(C_S00_AXIS_TDATA_WIDTH/8)-1 : 0] s00_axis_tstrb,
		input wire  s00_axis_tlast,
		input wire  s00_axis_tvalid,

		// Ports of Axi Slave Bus Interface s00_axi
		input wire  s00_axi_aclk,
		input wire  s00_axi_aresetn,
		input wire [C_s00_axi_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
		input wire [2 : 0] s00_axi_awprot,
		input wire  s00_axi_awvalid,
		output wire  s00_axi_awready,
		input wire [C_s00_axi_DATA_WIDTH-1 : 0] s00_axi_wdata,
		input wire [(C_s00_axi_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
		input wire  s00_axi_wvalid,
		output wire  s00_axi_wready,
		output wire [1 : 0] s00_axi_bresp,
		output wire  s00_axi_bvalid,
		input wire  s00_axi_bready,
		input wire [C_s00_axi_ADDR_WIDTH-1 : 0] s00_axi_araddr,
		input wire [2 : 0] s00_axi_arprot,
		input wire  s00_axi_arvalid,
		output wire  s00_axi_arready,
		output wire [C_s00_axi_DATA_WIDTH-1 : 0] s00_axi_rdata,
		output wire [1 : 0] s00_axi_rresp,
		output wire  s00_axi_rvalid,
		input wire  s00_axi_rready
	);
// Instantiation of Axi Bus Interface S00_AXIS

	
	wire   [ 31 : 0 ]                          My_DNN_Output_Number_w;
	wire                                       My_DNN_Output_Done_w;
	wire                                       My_DNN_SOFT_RESETN_w;
	
	DNN_Digit_Recog DNN_Digit_Recog_Sig5_slave_stream_v1_0_S00_AXIS_inst(
    .S_AXIS_ACLK(s00_axis_aclk),
    .S_AXIS_ARESETN(s00_axis_aresetn),
    .S_AXIS_TDATA(s00_axis_tdata),
    .S_AXIS_TDATA_VALID(s00_axis_tvalid),
    .S_AXIS_TDATA_READY(s00_axis_tready),
    .DNN_SOFT_RESETN(My_DNN_SOFT_RESETN_w),
    .digit_Val(My_DNN_Output_Number_w),
    .hardmax_output_valid(My_DNN_Output_Done_w)
);
	

// Instantiation of Axi Bus Interface s00_axi
		DNN_Digit_Recog_Sig5_slave_lite_v1_0_S00_AXI
 # ( 
		.C_S_AXI_DATA_WIDTH(C_s00_axi_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_s00_axi_ADDR_WIDTH)
	) DNN_Digit_Recog_Sig5_slave_lite_v1_0_S00_AXI_inst (
	    .DNN_SOFT_RESETN(My_DNN_SOFT_RESETN_w),
	    .My_DNN_Output_Number_AXILITE(My_DNN_Output_Number_w),
	    .My_DNN_Output_Done_AXILITE(My_DNN_Output_Done_w),
		.S_AXI_ACLK(s00_axi_aclk),
		.S_AXI_ARESETN(s00_axi_aresetn),
		.S_AXI_AWADDR(s00_axi_awaddr),
		.S_AXI_AWPROT(s00_axi_awprot),
		.S_AXI_AWVALID(s00_axi_awvalid),
		.S_AXI_AWREADY(s00_axi_awready),
		.S_AXI_WDATA(s00_axi_wdata),
		.S_AXI_WSTRB(s00_axi_wstrb),
		.S_AXI_WVALID(s00_axi_wvalid),
		.S_AXI_WREADY(s00_axi_wready),
		.S_AXI_BRESP(s00_axi_bresp),
		.S_AXI_BVALID(s00_axi_bvalid),
		.S_AXI_BREADY(s00_axi_bready),
		.S_AXI_ARADDR(s00_axi_araddr),
		.S_AXI_ARPROT(s00_axi_arprot),
		.S_AXI_ARVALID(s00_axi_arvalid),
		.S_AXI_ARREADY(s00_axi_arready),
		.S_AXI_RDATA(s00_axi_rdata),
		.S_AXI_RRESP(s00_axi_rresp),
		.S_AXI_RVALID(s00_axi_rvalid),
		.S_AXI_RREADY(s00_axi_rready)
	);

	// Add user logic here

	// User logic ends

	endmodule
