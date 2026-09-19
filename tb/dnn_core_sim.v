`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// dnn_core_sim
// Direct testbench against DNN_Digit_Recog -- no AXI, no wrapper. This is the
// one to run the full 10000-sample sweep through, since accuracy is a property
// of the MAC/weights/fixed-point scaling, not the AXI plumbing around it.
//////////////////////////////////////////////////////////////////////////////////

`include "C:/Users/pavan/Documents/CNN/src/includes.v"

// Bump to 10000 for the full sweep once a small batch looks right.
`define NUM_TEST_SAMPLES 3000

// If your test_data_*.txt files aren't visible from the sim run directory,
// set this to an absolute path ending in a slash, e.g.
// "C:/Users/pavan/Documents/CNN/testdata/"  -- leave empty to read from
// whatever directory the simulator is run from.
`define TEST_DATA_DIR "C:/Users/pavan/Documents/CNN/testsimfiles/"

module dnn_core_sim(
    );

    reg                       clk;
    reg                       s_axis_aresetn;
    reg                       dnn_soft_resetn;
    reg  [`dataWidth-1:0]     s_axis_tdata;
    reg                       s_axis_tdata_valid;
    wire                      s_axis_tdata_ready;
    wire [31:0]               digit_val;
    wire                      hardmax_valid;

    reg  [`dataWidth-1:0]     in_mem [784:0];
    reg  [8*100-1:0]          fileName;
    reg  [`dataWidth-1:0]     expected;

    integer right = 0;
    integer wrong = 0;

    DNN_Digit_Recog dut (
        .S_AXIS_ACLK          (clk),
        .S_AXIS_ARESETN       (s_axis_aresetn),
        .S_AXIS_TDATA         (s_axis_tdata),
        .S_AXIS_TDATA_VALID   (s_axis_tdata_valid),
        .S_AXIS_TDATA_READY   (s_axis_tdata_ready),
        .DNN_SOFT_RESETN      (dnn_soft_resetn),
        .digit_Val            (digit_val),
        .hardmax_output_valid (hardmax_valid)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    //------------------------------------------------------------
    // Stream one 784-pixel frame in from in_mem, one pixel per clock
    //------------------------------------------------------------
    task sendData();
        integer t;
    begin
        $readmemb(fileName, in_mem);

        @(posedge clk);
        @(posedge clk);
        @(posedge clk);

        for (t = 0; t < 784; t = t + 1) begin
            @(posedge clk);
            s_axis_tdata       <= in_mem[t];
            s_axis_tdata_valid <= 1'b1;
        end

        @(posedge clk);
        s_axis_tdata_valid <= 1'b0;

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
        s_axis_aresetn      = 1'b0;
        dnn_soft_resetn     = 1'b0;
        s_axis_tdata_valid  = 1'b0;
        s_axis_tdata        = 0;

        #100;
        s_axis_aresetn  = 1'b1;
        #20;
        dnn_soft_resetn = 1'b1; // release -> start

        start = $time;
        $display("Weights/bias load from .mif files at elaboration -- no runtime config needed.");

        for (testDataCount = 0; testDataCount < `NUM_TEST_SAMPLES; testDataCount = testDataCount + 1)
        begin
            $sformat(fileName, "%stest_data_%04d.txt", `TEST_DATA_DIR, testDataCount);
            
            $display("DEBUG: about to read file: %0s", fileName);

            sendData();

            @(posedge hardmax_valid);
            @(posedge clk); // let digit_Val settle one cycle past the valid pulse

            if (digit_val[`dataWidth-1:0] == expected)
                right = right + 1;
            else
                wrong = wrong + 1;

            $display("%0d. Accuracy: %f, Detected number: %0x, Expected: %x",
                      testDataCount + 1,
                      right * 100.0 / (testDataCount + 1),
                      digit_val,
                      expected);
        end

        $display("Total execution time",,,,$time-start,,"ns");
        $display("Accuracy: %f", right * 100.0 / `NUM_TEST_SAMPLES);
        $stop;
    end

endmodule
