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

module rle_encoder_dna 
(
    input clk,
    input rst,
    input [DATA_WIDTH - 1: 0] stream_in,
    output reg [CTR_WIDTH + 2 - 1 :0] compressed_stream,
    output reg valid
); 

parameter DATA_WIDTH=8,
          CTR_WIDTH=4;
    
localparam CTR_MAX = (1<<CTR_WIDTH) - 1;     

// Nucleotide encoding (compressing)
localparam a = 2'b00;          
localparam c = 2'b01;
localparam g = 2'b10;
localparam t = 2'b11;
    
reg [DATA_WIDTH-1:0] stream_in_prev;
reg [CTR_WIDTH:0] seq_counter = 0;
reg [1:0] compressed_data;    
    
initial begin
    $display("CTR MAX=%d, DATA WIDTH=%d, CTR WIDTH=%d", CTR_MAX, DATA_WIDTH, CTR_WIDTH);
end
    
always @(posedge clk)    
begin
    stream_in_prev <= stream_in; 
    
    case(stream_in)
        8'h61: compressed_data <= a;
        8'h63: compressed_data <= c;
        8'h67: compressed_data <= g;
        8'h74: compressed_data <= t;
        default: compressed_data <= 8'hzz;
    endcase
    
    if (!rst) begin
        valid <= 1'b0;
        compressed_stream <= 0;
    end else begin
        if (stream_in == stream_in_prev) begin
            if (seq_counter != CTR_MAX) begin
                valid <= 1'b0;
                seq_counter <= seq_counter + 1;
            end else begin
                valid <= 1'b1;
                compressed_stream <= {seq_counter[CTR_WIDTH-1:0], compressed_data};
                seq_counter <= 0;
            end
        end else begin
            valid <= 1'b1;
            compressed_stream <= {seq_counter[CTR_WIDTH-1:0], compressed_data};
            seq_counter <= 0;
        end
    end
end   
    
endmodule