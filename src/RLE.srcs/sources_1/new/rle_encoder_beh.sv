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
    
reg [7:0] stream_in_prev = 8'b0;
//reg valid_nxt;
//reg [11:0] compressed_stream_nxt;
reg [4:0] seq_counter = 5'b0;
    
always @(posedge clk)    
begin
    if (!rst) begin
        valid <= 1'b0;
        compressed_stream <= 12'b0;
        stream_in_prev <= 8'b0;
    end else begin
        stream_in_prev <= stream_in; 
        if (stream_in == stream_in_prev) begin
            valid <= 1'b0;
            seq_counter <= seq_counter + 1;
        end else begin
            valid <= 1'b1;
            //seq_counter = seq_counter-1;      //to be modified later
            compressed_stream <= {seq_counter[3:0], stream_in_prev};
            seq_counter <= 5'b0;
        end
    end
end    
    /*
always @* begin
    if (stream_in == stream_in_prev) begin
        valid_nxt = 1'b0;
        seq_counter = seq_counter + 1;
    end else begin
        valid_nxt = 1'b1;
        seq_counter = seq_counter;      //to be modified later
        compressed_stream_nxt = {seq_counter[3:0], stream_in_prev};
        seq_counter = 5'b0;
    end
end  */
    
endmodule
