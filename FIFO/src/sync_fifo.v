// Synchronous FIFO Design Module
`timescale 1ns/1ps

module sync_fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 16,
    parameter ADDR_BITS = $clog2(DEPTH)
)(
    input  wire                     clk,
    input  wire                     rst_n,
    input  wire                     wr_en,
    input  wire [DATA_WIDTH-1:0]    wr_data,
    input  wire                     rd_en,
    output reg  [DATA_WIDTH-1:0]    rd_data,
    output wire                     full,
    output wire                     empty,
    output wire                     almost_full,
    output wire                     almost_empty,
    output reg                      overflow,
    output reg                      underflow,
    output wire [ADDR_BITS:0]       count
);

    // Memory array
    reg [DATA_WIDTH-1:0] fifo_mem [0:DEPTH-1];
    
    // Pointers - one extra bit to distinguish between full and empty
    reg [ADDR_BITS:0] wr_ptr, rd_ptr;
    
    // Status flags
    assign full = (wr_ptr[ADDR_BITS] != rd_ptr[ADDR_BITS]) && 
                  (wr_ptr[ADDR_BITS-1:0] == rd_ptr[ADDR_BITS-1:0]);
    assign empty = (wr_ptr == rd_ptr);
    assign almost_full = (count >= DEPTH - 1);
    assign almost_empty = (count <= 1);
    assign count = wr_ptr - rd_ptr;
    
    // Write operation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= 0;
            overflow <= 0;
        end else begin
            overflow <= 0;
            if (wr_en && !full) begin
                fifo_mem[wr_ptr[ADDR_BITS-1:0]] <= wr_data;
                wr_ptr <= wr_ptr + 1;
            end else if (wr_en && full) begin
                overflow <= 1;
            end
        end
    end
    
    // Read operation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_ptr <= 0;
            rd_data <= 0;
            underflow <= 0;
        end else begin
            underflow <= 0;
            if (rd_en && !empty) begin
                rd_data <= fifo_mem[rd_ptr[ADDR_BITS-1:0]];
                rd_ptr <= rd_ptr + 1;
            end else if (rd_en && empty) begin
                underflow <= 1;
            end
        end
    end

endmodule
