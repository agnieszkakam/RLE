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
    input [DATA_WIDTH + CTR_WIDTH - 1:0] compressed_stream_in, 
    output reg [DATA_WIDTH - 1:0] initial_stream,
    output reg [CTR_WIDTH - 1:0] curr_count,
    output reg rd_flag
);

parameter DATA_WIDTH=8,
          CTR_WIDTH=6;

reg [7:0] curr_word;

always @(posedge clk) begin
    if (!rst) begin
        initial_stream <= 0;
        curr_word <= 0;
        curr_count <= 0;
    end
    else begin
        if (rd_flag == 1'b0) begin
        curr_count <= compressed_stream_in[DATA_WIDTH + CTR_WIDTH - 1:DATA_WIDTH] + 1'b1;
        curr_word <= compressed_stream_in[DATA_WIDTH - 1:0];
        rd_flag <= 1;
        end
        if (curr_count == 0) begin
            rd_flag <= 0;
        end
        else begin
            initial_stream <= curr_word;
            curr_count <= curr_count - 1'b1;
        end
    end
end
endmodule
