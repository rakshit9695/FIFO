`timescale 1ns/1ps

module sync_fifo_tb;

    // Parameters
    localparam DATA_WIDTH = 8;
    localparam DEPTH = 16;
    localparam ADDR_BITS = $clog2(DEPTH);

    // DUT signals
    reg clk;
    reg rst_n;
    reg wr_en;
    reg [DATA_WIDTH-1:0] wr_data;
    reg rd_en;
    wire [DATA_WIDTH-1:0] rd_data;
    wire full, empty, almost_full, almost_empty;
    wire [ADDR_BITS:0] count;
    wire overflow, underflow;

    // Instantiate DUT
    sync_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH),
        .ADDR_BITS(ADDR_BITS)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(wr_en),
        .wr_data(wr_data),
        .rd_en(rd_en),
        .rd_data(rd_data),
        .full(full),
        .empty(empty),
        .almost_full(almost_full),
        .almost_empty(almost_empty),
        .overflow(overflow),
        .underflow(underflow),
        .count(count)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk; // 100 MHz

     initial begin
        $dumpfile("dump.vcd");         // Name of the VCD file to generate
        $dumpvars(0, sync_fifo_tb);   // Dump all signals in this testbench
    end

    // Test sequence
    initial begin
        $display("Starting Synchronous FIFO Testbench...");
        wr_en = 0; rd_en = 0; wr_data = 0;
        rst_n = 0;
        #20;
        rst_n = 1;
        #10;

        // 1. Check reset state
        if (!empty || count != 0) $display("FAIL: FIFO not empty after reset");

        // 2. Fill FIFO completely
        $display("Filling FIFO...");
        repeat (DEPTH) begin
            @(negedge clk);
            wr_en = 1; wr_data = $random;
            rd_en = 0;
        end
        @(negedge clk);
        wr_en = 0;

        if (!full) $display("FAIL: FIFO not full after filling");
        if (count != DEPTH) $display("FAIL: Count mismatch after filling");

        // 3. Try writing when full (should set overflow)
        @(negedge clk);
        wr_en = 1; wr_data = 8'hAA;
        @(negedge clk);
        wr_en = 0;
        if (!overflow) $display("FAIL: Overflow not detected on full FIFO");

        // 4. Read all data out
        $display("Draining FIFO...");
        repeat (DEPTH) begin
            @(negedge clk);
            wr_en = 0;
            rd_en = 1;
        end
        @(negedge clk);
        rd_en = 0;

        if (!empty) $display("FAIL: FIFO not empty after draining");
        if (count != 0) $display("FAIL: Count mismatch after draining");

        // 5. Try reading when empty (should set underflow)
        @(negedge clk);
        rd_en = 1;
        @(negedge clk);
        rd_en = 0;
        if (!underflow) $display("FAIL: Underflow not detected on empty FIFO");

        // 6. Simultaneous read and write
        $display("Testing simultaneous read/write...");
        wr_data = 8'h55;
        wr_en = 1; rd_en = 1;
        @(negedge clk);
        wr_en = 0; rd_en = 0;

        // 7. Check almost_full and almost_empty flags
        $display("Testing almost_full/almost_empty...");
        // Fill to almost_full
        repeat (DEPTH-2) begin
            @(negedge clk);
            wr_en = 1; wr_data = $random;
            rd_en = 0;
        end
        @(negedge clk);
        wr_en = 0;
        if (!almost_full) $display("FAIL: almost_full not asserted");

        // Drain to almost_empty
        repeat (DEPTH-2) begin
            @(negedge clk);
            wr_en = 0;
            rd_en = 1;
        end
        @(negedge clk);
        rd_en = 0;
        if (!almost_empty) $display("FAIL: almost_empty not asserted");

        // 8. Reset during operation
        $display("Testing reset during operation...");
        wr_en = 1; wr_data = 8'hFF;
        @(negedge clk);
        rst_n = 0;
        @(negedge clk);
        rst_n = 1;
        wr_en = 0;
        if (!empty || count != 0) $display("FAIL: FIFO not empty after mid-operation reset");

        $display("All test cases completed.");
        $finish;
    end

endmodule
