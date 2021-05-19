`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: AGH
// Engineer: Agnieszka Kamien
// 
// Create Date: 23.04.2021 09:53:06
// Design Name: RLE 
// Module Name: rle_encoder_beh
// 
//////////////////////////////////////////////////////////////////////////////////

module rle_encoder_beh 
(
    input clk,
    input rst,
    input [DATA_WIDTH - 1: 0] stream_in,
    output reg [DATA_WIDTH + CTR_WIDTH - 1 :0] compressed_stream,
    output reg valid
); 

parameter DATA_WIDTH=8,
          CTR_WIDTH=4;
    
localparam CTR_MAX = (1<<CTR_WIDTH) - 1;     
    
reg [DATA_WIDTH-1:0] stream_in_prev;
reg [CTR_WIDTH:0] seq_counter = 0;
    
initial begin
    $display("CTR MAX=%d, DATA WIDTH=%d, CTR WIDTH=%d", CTR_MAX, DATA_WIDTH, CTR_WIDTH);
end
    
always @(posedge clk)    
begin
    $display("stream_prev=%b, stream_in=%b", stream_in_prev, stream_in);
    stream_in_prev <= stream_in; 
    if (!rst) begin
        valid <= 1'b0;
        compressed_stream <= 0;
        $display("case I");
    end else begin
        if ((stream_in_prev == 2'bx) || (stream_in_prev == 2'bz)) begin
            valid <= 1'b0;
            seq_counter <= 0;
            $display("case II");
        end else if (stream_in == stream_in_prev) begin
            $display("case III");
            if (seq_counter != CTR_MAX) begin
                valid <= 1'b0;
                seq_counter <= seq_counter + 1;
            end else begin
                valid <= 1'b1;
                compressed_stream <= {seq_counter[CTR_WIDTH-1:0], stream_in_prev};
                seq_counter <= 0;
            end 
        end else begin
                $display("case IV");
                valid <= 1'b1;
                compressed_stream <= {seq_counter[CTR_WIDTH-1:0], stream_in_prev};
                seq_counter <= 0;
        end
    end
end   
    
endmodule