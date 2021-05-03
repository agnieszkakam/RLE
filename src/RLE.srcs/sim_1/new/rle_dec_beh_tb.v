`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.04.2021 10:48:36
// Design Name: 
// Module Name: rle_dec_beh_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module rle_dec_beh_tb();

logic clk;
logic rst;
logic [DATA_WIDTH + CTR_WIDTH - 1:0] compressed_stream_in;
logic [DATA_WIDTH - 1:0] initial_stream;
logic [3:0] i = 0;
logic [CTR_WIDTH - 1:0] curr_count;
logic rd_flag;

localparam DATA_WIDTH = 8;
localparam CTR_WIDTH = 6;

int input_tab[0:14] = { 14'h11a5, 14'h03bb, 14'h00bc, 14'h00bd, 14'h11a5, 14'h04bb, 14'h00bc, 14'h00bd, 14'h05a2, 14'h01ba, 14'h01a2, 14'h03a1, 14'h00a3, 14'h00bb, 14'h12bc };

rle_decoder_beh my_dec ( .clk(clk), .rst(rst), .compressed_stream_in(compressed_stream_in), .initial_stream(initial_stream), .curr_count(curr_count), .rd_flag(rd_flag) );

initial begin
    rst = 1'b0;
    compressed_stream_in = 14'h11a5;
    #10 rst = 1'b1;
end

always
begin
    clk = 1'b0;
    #5; 
    clk = 1'b1;
    #5; // high for 5 * timescale = 5 ns
end

always@(posedge clk) begin

    if ((rd_flag == 0) && (curr_count == 0)) begin
        compressed_stream_in = input_tab[i];
        i = i + 1;
    end
//   i <= (i == 7) ? 0 : i + 1;
    $display("compressed_stream_in=%h, initial_stream=%h", compressed_stream_in, initial_stream); 
end

endmodule
