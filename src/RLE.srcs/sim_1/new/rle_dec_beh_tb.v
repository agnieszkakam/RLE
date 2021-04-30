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
logic [13:0] compressed_stream_in;
logic [7:0] initial_stream;
logic valid;
logic [3:0] i = 0;

int input_tab[0:7] = { 14'h11a5, 14'h03bb, 14'h00bc, 14'h00bd, 14'h11a5, 14'h04bb, 14'h00bc, 14'h00bd };

rle_decoder_beh my_dec ( .clk(clk), .rst(rst), .compressed_stream_in(compressed_stream_in), .initial_stream(initial_stream), .valid(valid) );

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
    compressed_stream_in = input_tab[i];
    i <= (i == 8) ? 0 : i + 1;  
    if (valid)
        $display("compressed_stream_in=%d, initial_stream=%d", compressed_stream_in, initial_stream); 
end

endmodule
