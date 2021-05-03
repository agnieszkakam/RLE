`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.04.2021 10:18:44
// Design Name: 
// Module Name: rle_decoder_beh
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


module rle_decoder_beh
(
    input clk,
    input rst,
    input [13:0] compressed_stream_in,   // 6 bitow na licznik, 8 bitow na dane  
    output reg [7:0] initial_stream,     // 8 bitow danych
    output reg [5:0] curr_count,
    output reg rd_flag
);

reg [7:0] curr_word;
//reg [5:0] curr_count;

//11a5, 03bb, 00bc, 00bd, 11a5, 04bb, 00bc, 00bd

always @(posedge clk) begin
    if (!rst) begin
        initial_stream <= 8'b00000000;
        curr_word <= 8'b00000000;
        curr_count <= 6'b000000;
    end
    else begin
        if (rd_flag == 1'b0) begin
        curr_count <= compressed_stream_in[13:8] + 1'b1;
        curr_word <= compressed_stream_in[7:0];
        rd_flag <= 1;
        end
        if (curr_count == 6'b000000) begin
            rd_flag <= 0;
        end
        else begin
            initial_stream <= curr_word;
            curr_count <= curr_count - 1'b1;
        end
    end
end
endmodule
