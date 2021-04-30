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
    output reg rd_flag
);

integer i;
//reg rd_flag;
reg [7:0] curr_word;
reg [5:0] curr_count;

//11a5, 03bb, 00bc, 00bd, 11a5, 04bb, 00bc, 00bd

always @(posedge clk) begin
    if (!rst) begin
        initial_stream <= 8'b00000000;
        curr_word <= 14'b00000000000000;
        curr_count <= 6'b000000;
        i <= 0;
        rd_flag <= 0;
    end
    else begin
        curr_word <= compressed_stream_in[7:0];
        curr_count <= compressed_stream_in[13:8];
        if (curr_count == 6'b000000) begin
            initial_stream <= curr_word;
            rd_flag <= 1;
        end
        else begin
            curr_word <= compressed_stream_in[7:0];
            for ( i = 0; i < curr_count + 2; i = i + 1) begin
                $display("loop is working, i is %d", i);
                initial_stream <= curr_word;
            end
            rd_flag <= 1;
        end
        i <= 0;
        rd_flag <= 0;
    end
end

endmodule
