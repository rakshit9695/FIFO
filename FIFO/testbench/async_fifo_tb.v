`timescale 1ns/1ps

module async_fifo_tb;

    // Parameters
    localparam DATA_WIDTH = 8;
    localparam DEPTH = 16;
    localparam ADDR_BITS = $clog2(DEPTH);

    // DUT signals
    reg wr_clk, rd_clk;
    reg wr_rst_n, rd_rst_n;
    reg wr_en, rd_en;
    reg [DATA_WIDTH-1:0] wr_data;
    wire [DATA_WIDTH-1:0] rd_data;
    wire wr_full, rd_empty;

    // Reference model for data checking
    reg [DATA_WIDTH-1:0] ref_mem [0:DEPTH-1];
    integer ref_wr_ptr, ref_rd_ptr, ref_count;

    // Instantiate DUT
    async_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH),
        .ADDR_BITS(ADDR_BITS)
    ) dut (
        .wr_clk(wr_clk),
        .wr_rst_n(wr_rst_n),
        .wr_en(wr_en),
        .wr_data(wr_data),
        .wr_full(wr_full),
        .rd_clk(rd_clk),
        .rd_rst_n(rd_rst_n),
        .rd_en(rd_en),
        .rd_data(rd_data),
        .rd_empty(rd_empty)
    );

    // Write clock: 10ns period (100 MHz)
    initial wr_clk = 0;
    always #5 wr_clk = ~wr_clk;

    // Read clock: 14ns period (~71 MHz)
    initial rd_clk = 0;
    always #7 rd_clk = ~rd_clk;

    // Test sequence
    initial begin
        $display("Starting Asynchronous FIFO Testbench...");
        wr_en = 0; rd_en = 0; wr_data = 0;
        wr_rst_n = 0; rd_rst_n = 0;
        ref_wr_ptr = 0; ref_rd_ptr = 0; ref_count = 0;
        #20;
        wr_rst_n = 1; rd_rst_n = 1;
        #20;

        // 1. Check reset state
        if (!rd_empty) $display("FAIL: FIFO not empty after reset");

        // 2. Fill FIFO completely
        $display("Filling FIFO...");
        repeat (DEPTH) begin
            @(negedge wr_clk);
            wr_en = 1; wr_data = $random;
            if (!wr_full) begin
                ref_mem[ref_wr_ptr] = wr_data;
                ref_wr_ptr = (ref_wr_ptr + 1) % DEPTH;
                ref_count = ref_count + 1;
            end
        end
        @(negedge wr_clk);
        wr_en = 0;

        if (!wr_full) $display("FAIL: FIFO not full after filling");

        // 3. Try writing when full (should not change FIFO)
        @(negedge wr_clk);
        wr_en = 1; wr_data = 8'hAA;
        @(negedge wr_clk);
        wr_en = 0;

        // 4. Read all data out
        $display("Draining FIFO...");
        repeat (DEPTH) begin
            @(negedge rd_clk);
            rd_en = 1;
            if (!rd_empty) begin
                if (rd_data !== ref_mem[ref_rd_ptr])
                    $display("FAIL: Data mismatch at read %0d: got %h, expected %h", ref_rd_ptr, rd_data, ref_mem[ref_rd_ptr]);
                ref_rd_ptr = (ref_rd_ptr + 1) % DEPTH;
                ref_count = ref_count - 1;
            end
        end
        @(negedge rd_clk);
        rd_en = 0;

        if (!rd_empty) $display("FAIL: FIFO not empty after draining");

        // 5. Try reading when empty (should not change FIFO)
        @(negedge rd_clk);
        rd_en = 1;
        @(negedge rd_clk);
        rd_en = 0;

        // 6. Simultaneous read and write (ping-pong)
        $display("Testing simultaneous read/write...");
        wr_data = 8'h55;
        wr_en = 1; rd_en = 1;
        @(negedge wr_clk);
        @(negedge rd_clk);
        wr_en = 0; rd_en = 0;

        // 7. Reset during operation
        $display("Testing reset during operation...");
        wr_en = 1; wr_data = 8'hFF;
        @(negedge wr_clk);
        wr_rst_n = 0; rd_rst_n = 0;
        @(negedge wr_clk);
        wr_rst_n = 1; rd_rst_n = 1;
        wr_en = 0;
        if (!rd_empty) $display("FAIL: FIFO not empty after mid-operation reset");

        $display("All test cases completed.");
        $finish;
    end

endmodule
