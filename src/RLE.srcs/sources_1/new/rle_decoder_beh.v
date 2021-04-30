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
    output reg valid
);

integer i, idx;
reg [7:0] curr_val;
reg [7:0] seq_counter = 0;

//11a5, 03bb, 00bc, 00bd, 11a5, 04bb, 00bc, 00bd

always @(posedge clk) begin
    if (!rst) begin
        initial_stream <= 8'b00000000;
        curr_val <= 14'b00000000000000;
        valid <= 1'b0;
        idx <= 0;
    end
    else begin
        if (compressed_stream_in[13:8] == 0) begin
            curr_val <= compressed_stream_in[7:0];
            initial_stream <= curr_val;
        end
        else begin
            curr_val <= compressed_stream_in[7:0];
            for ( i = 0; i < compressed_stream_in[13:8] + 2; i = i + 1) begin
                initial_stream <= curr_val[7:0];
            end
        i <= 0;
        end
    end
end

endmodule
