// Asynchronous FIFO Design Module
// Uses Gray code counters for safe clock domain crossing
`timescale 1ns/1ps

module async_fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 16,
    parameter ADDR_BITS = $clog2(DEPTH)
)(
    // Write side
    input  wire                     wr_clk,
    input  wire                     wr_rst_n,
    input  wire                     wr_en,
    input  wire [DATA_WIDTH-1:0]    wr_data,
    output wire                     wr_full,
    
    // Read side
    input  wire                     rd_clk,
    input  wire                     rd_rst_n,
    input  wire                     rd_en,
    output reg  [DATA_WIDTH-1:0]    rd_data,
    output wire                     rd_empty
);

    // Memory array
    reg [DATA_WIDTH-1:0] fifo_mem [0:DEPTH-1];
    
    // Gray code pointers
    reg [ADDR_BITS:0] wr_gray, wr_binary;
    reg [ADDR_BITS:0] rd_gray, rd_binary;
    
    // Synchronized pointers
    reg [ADDR_BITS:0] wr_gray_sync1, wr_gray_sync2;
    reg [ADDR_BITS:0] rd_gray_sync1, rd_gray_sync2;
    
    // Next pointers
    wire [ADDR_BITS:0] wr_binary_next, wr_gray_next;
    wire [ADDR_BITS:0] rd_binary_next, rd_gray_next;
    
    // Binary to Gray conversion
    assign wr_binary_next = wr_binary + (wr_en & ~wr_full);
    assign wr_gray_next = (wr_binary_next >> 1) ^ wr_binary_next;
    
    assign rd_binary_next = rd_binary + (rd_en & ~rd_empty);
    assign rd_gray_next = (rd_binary_next >> 1) ^ rd_binary_next;
    
    // Status flags
    assign wr_full = (wr_gray_next == rd_gray_sync2);
    assign rd_empty = (rd_gray == wr_gray_sync2);
    
    // Write domain logic
    always @(posedge wr_clk or negedge wr_rst_n) begin
        if (!wr_rst_n) begin
            wr_binary <= 0;
            wr_gray <= 0;
        end else begin
            wr_binary <= wr_binary_next;
            wr_gray <= wr_gray_next;
        end
    end
    
    // Write memory
    always @(posedge wr_clk) begin
        if (wr_en && !wr_full) begin
            fifo_mem[wr_binary[ADDR_BITS-1:0]] <= wr_data;
        end
    end
    
    // Read domain logic
    always @(posedge rd_clk or negedge rd_rst_n) begin
        if (!rd_rst_n) begin
            rd_binary <= 0;
            rd_gray <= 0;
        end else begin
            rd_binary <= rd_binary_next;
            rd_gray <= rd_gray_next;
        end
    end
    
    // Read memory
    always @(posedge rd_clk) begin
        if (rd_en && !rd_empty) begin
            rd_data <= fifo_mem[rd_binary[ADDR_BITS-1:0]];
        end
    end
    
    // Synchronize write gray pointer to read domain
    always @(posedge rd_clk or negedge rd_rst_n) begin
        if (!rd_rst_n) begin
            wr_gray_sync1 <= 0;
            wr_gray_sync2 <= 0;
        end else begin
            wr_gray_sync1 <= wr_gray;
            wr_gray_sync2 <= wr_gray_sync1;
        end
    end
    
    // Synchronize read gray pointer to write domain
    always @(posedge wr_clk or negedge wr_rst_n) begin
        if (!wr_rst_n) begin
            rd_gray_sync1 <= 0;
            rd_gray_sync2 <= 0;
        end else begin
            rd_gray_sync1 <= rd_gray;
            rd_gray_sync2 <= rd_gray_sync1;
        end
    end

endmodule
