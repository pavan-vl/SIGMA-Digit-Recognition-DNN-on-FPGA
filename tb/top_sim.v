`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// top_sim
// Testbench for myip2 (DNN_Digit_Recog wrapped with S00_AXIS pixel stream +
// S01_AXI status/control). Streams pixels for test_data_NNNN.txt, reads back
// the recognized digit over AXI4-Lite, compares against the label on line 785
// of each file, and reports running + final accuracy across the sweep.
//////////////////////////////////////////////////////////////////////////////////

`include "C:/Users/pavan/Documents/CNN/src/includes.v"

// Set to 10000 for the full sweep (test_data_0000.txt .. test_data_9999.txt).
// Left smaller by default so a first run doesn't take longer than necessary --
// bump this up once you've confirmed everything passes on a small batch.
`define NUM_TEST_SAMPLES 10000

module top_sim(
    );

    // ---- AXI4-Stream (pixel input) ----
    reg                          s00_axis_aclk;
    reg                          s00_axis_aresetn;
    wire                         s00_axis_tready;
    reg  [`dataWidth-1:0]        s00_axis_tdata;
    reg  [(`dataWidth/8)-1:0]    s00_axis_tstrb;
    reg                          s00_axis_tlast;
    reg                          s00_axis_tvalid;

    // ---- AXI4-Lite (status/control) ----
    reg                          s01_axi_aclk;
    reg                          s01_axi_aresetn;
    reg  [4:0]                   s01_axi_awaddr;
    reg  [2:0]                   s01_axi_awprot;
    reg                          s01_axi_awvalid;
    wire                         s01_axi_awready;
    reg  [31:0]                  s01_axi_wdata;
    reg  [3:0]                   s01_axi_wstrb;
    reg                          s01_axi_wvalid;
    wire                         s01_axi_wready;
    wire [1:0]                   s01_axi_bresp;
    wire                         s01_axi_bvalid;
    reg                          s01_axi_bready;
    reg  [4:0]                   s01_axi_araddr;
    reg  [2:0]                   s01_axi_arprot;
    reg                          s01_axi_arvalid;
    wire                         s01_axi_arready;
    wire [31:0]                  s01_axi_rdata;
    wire [1:0]                   s01_axi_rresp;
    wire                         s01_axi_rvalid;
    reg                          s01_axi_rready;

    // ---- register map on S01_AXI (byte offsets) ----
    localparam ADDR_CTRL      = 5'h00; // R/W  bit0: 0=hold in reset, 1=run
    localparam ADDR_DIGIT_VAL = 5'h04; // R    recognized digit
    localparam ADDR_DONE      = 5'h08; // R    argmax-done flag (replicated across all bits)

    reg  [`dataWidth-1:0]        in_mem [784:0];
    reg  [8*24-1:0]              fileName;
    reg  [31:0]                  axiRdData;
    reg  [`dataWidth-1:0]        expected;

    integer right = 0;
    integer wrong = 0;

    myip2 #(
        .C_S00_AXIS_TDATA_WIDTH(`dataWidth),
        .C_S01_AXI_DATA_WIDTH(32),
        .C_S01_AXI_ADDR_WIDTH(5)
    ) dut (
        .s00_axis_aclk    (s00_axis_aclk),
        .s00_axis_aresetn (s00_axis_aresetn),
        .s00_axis_tready  (s00_axis_tready),
        .s00_axis_tdata   (s00_axis_tdata),
        .s00_axis_tstrb   (s00_axis_tstrb),
        .s00_axis_tlast   (s00_axis_tlast),
        .s00_axis_tvalid  (s00_axis_tvalid),

        .s01_axi_aclk     (s01_axi_aclk),
        .s01_axi_aresetn  (s01_axi_aresetn),
        .s01_axi_awaddr   (s01_axi_awaddr),
        .s01_axi_awprot   (s01_axi_awprot),
        .s01_axi_awvalid  (s01_axi_awvalid),
        .s01_axi_awready  (s01_axi_awready),
        .s01_axi_wdata    (s01_axi_wdata),
        .s01_axi_wstrb    (s01_axi_wstrb),
        .s01_axi_wvalid   (s01_axi_wvalid),
        .s01_axi_wready   (s01_axi_wready),
        .s01_axi_bresp    (s01_axi_bresp),
        .s01_axi_bvalid   (s01_axi_bvalid),
        .s01_axi_bready   (s01_axi_bready),
        .s01_axi_araddr   (s01_axi_araddr),
        .s01_axi_arprot   (s01_axi_arprot),
        .s01_axi_arvalid  (s01_axi_arvalid),
        .s01_axi_arready  (s01_axi_arready),
        .s01_axi_rdata    (s01_axi_rdata),
        .s01_axi_rresp    (s01_axi_rresp),
        .s01_axi_rvalid   (s01_axi_rvalid),
        .s01_axi_rready   (s01_axi_rready)
    );

    // single shared clock for both interfaces
    initial begin
        s00_axis_aclk = 1'b0;
        s01_axi_aclk  = 1'b0;
    end
    always #5 s00_axis_aclk = ~s00_axis_aclk;
    always @(s00_axis_aclk) s01_axi_aclk = s00_axis_aclk;

    always @(posedge s01_axi_aclk)
    begin
        s01_axi_bready <= s01_axi_bvalid;
        s01_axi_rready <= s01_axi_rvalid;
    end

    //------------------------------------------------------------
    // AXI4-Lite write task
    //------------------------------------------------------------
    task writeAxi(
        input [31:0] address,
        input [31:0] data
    );
    begin
        @(posedge s01_axi_aclk);
        s01_axi_awvalid <= 1'b1;
        s01_axi_awaddr  <= address[4:0];
        s01_axi_wdata   <= data;
        s01_axi_wstrb   <= 4'hF;
        s01_axi_wvalid  <= 1'b1;
        wait (s01_axi_awready && s01_axi_wready);
        @(posedge s01_axi_aclk);
        s01_axi_awvalid <= 1'b0;
        s01_axi_wvalid  <= 1'b0;
        @(posedge s01_axi_aclk);
    end
    endtask

    //------------------------------------------------------------
    // AXI4-Lite read task
    //------------------------------------------------------------
    task readAxi(
        input [31:0] address
    );
    begin
        @(posedge s01_axi_aclk);
        s01_axi_arvalid <= 1'b1;
        s01_axi_araddr  <= address[4:0];
        wait (s01_axi_arready);
        @(posedge s01_axi_aclk);
        s01_axi_arvalid <= 1'b0;
        wait (s01_axi_rvalid);
        @(posedge s01_axi_aclk);
        axiRdData <= s01_axi_rdata;
        @(posedge s01_axi_aclk);
    end
    endtask

    //------------------------------------------------------------
    // Stream one 784-pixel frame in from in_mem, one pixel per clock
    //------------------------------------------------------------
    task sendData();
        integer t;
    begin
        $readmemb(fileName, in_mem);

        @(posedge s00_axis_aclk);
        @(posedge s00_axis_aclk);
        @(posedge s00_axis_aclk);

        for (t = 0; t < 784; t = t + 1) begin
            @(posedge s00_axis_aclk);
            s00_axis_tdata  <= in_mem[t];
            s00_axis_tvalid <= 1'b1;
            s00_axis_tstrb  <= {(`dataWidth/8){1'b1}};
            s00_axis_tlast  <= (t == 783) ? 1'b1 : 1'b0;
        end

        @(posedge s00_axis_aclk);
        s00_axis_tvalid <= 1'b0;
        s00_axis_tlast  <= 1'b0;

        expected = in_mem[784]; // label on line 785 of the file
    end
    endtask

    //------------------------------------------------------------
    // Main test sweep
    //------------------------------------------------------------
    integer testDataCount;
    integer start;

    initial
    begin
        s00_axis_aresetn = 1'b0;
        s01_axi_aresetn  = 1'b0;
        s00_axis_tvalid  = 1'b0;
        s00_axis_tlast   = 1'b0;
        s00_axis_tstrb   = 0;
        s01_axi_awvalid  = 1'b0;
        s01_axi_wvalid   = 1'b0;
        s01_axi_bready   = 1'b0;
        s01_axi_arvalid  = 1'b0;
        s01_axi_rready   = 1'b0;

        #100;
        s00_axis_aresetn = 1'b1;
        s01_axi_aresetn  = 1'b1;
        #100;

        // Demonstrate the soft-reset/start-bit workflow: hold, then release.
        writeAxi(ADDR_CTRL, 32'h0000_0000); // hold DNN in reset
        #20;
        writeAxi(ADDR_CTRL, 32'h0000_0001); // release -> start

        start = $time;
        $display("Weights/bias load from .mif files at elaboration -- no runtime config needed.");

        for (testDataCount = 0; testDataCount < `NUM_TEST_SAMPLES; testDataCount = testDataCount + 1)
        begin
            $sformat(fileName, "test_data_%04d.txt", testDataCount);

            sendData();

            // Wait for the argmax result to land, then read it back over AXI.
            // Polling the raw pulse directly would be unreliable if it's only
            // asserted for a single cycle; wait on the internal done wire
            // (stands in for a real interrupt line, same role `intr` played
            // in the original testbench) before doing the AXI readout.
            @(posedge dut.My_DNN_Output_Done_w);
            @(posedge s01_axi_aclk);
            @(posedge s01_axi_aclk);

            readAxi(ADDR_DIGIT_VAL);

            if (axiRdData[`dataWidth-1:0] == expected)
                right = right + 1;
            else
                wrong = wrong + 1;

            $display("%0d. Accuracy: %f, Detected: %0d, Expected: %0d, File: %0s",
                      testDataCount + 1,
                      right * 100.0 / (testDataCount + 1),
                      axiRdData,
                      expected,
                      fileName);
        end

        $display("Total execution time: %0d ns", $time - start);
        $display("Final Accuracy: %f%% (%0d correct, %0d wrong, %0d total)",
                  right * 100.0 / `NUM_TEST_SAMPLES, right, wrong, `NUM_TEST_SAMPLES);
        $stop;
    end

endmodule
