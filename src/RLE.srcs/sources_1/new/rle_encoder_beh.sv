`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 23.04.2021 09:53:06
// Module Name: rle_encoder_beh
//////////////////////////////////////////////////////////////////////////////////

module rle_encoder_beh(
    input clk,
    input rst,
    input [7:0] stream_in,
    output reg [11:0] compressed_stream,
    output reg valid
);
    
reg [7:0] stream_in_prev;
reg [4:0] seq_counter = 5'b0;
    
always @(posedge clk)    
begin
    stream_in_prev <= stream_in; 
    if (!rst) begin
        valid <= 1'b0;
        compressed_stream <= 12'b0;
    end else begin
        if (stream_in == stream_in_prev) begin
            valid <= 1'b0;
            seq_counter <= seq_counter + 1;
        end else begin
            valid <= 1'b1;
            compressed_stream <= {seq_counter[3:0], stream_in_prev};
            seq_counter <= 5'b0;
        end
    end
end   
    
endmodule
