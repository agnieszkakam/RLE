`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: AGH
// Engineer: 
// 
// Create Date: 30.04.2021 10:18:44
// Design Name: RLE
// Module Name: rle_decoder_dna

//////////////////////////////////////////////////////////////////////////////////


module rle_decoder_dna
(
    input clk,
    input rst,
    input [3:0] dna_stream_in,
    output reg [1:0] dna_stream,
    output reg ready,
    output reg [1:0] curr_count,
    output reg rd_flag,
    output reg new_pack
);

//parameter DATA_WIDTH=3,
//          CTR_WIDTH=1;

reg [1:0] curr_word;

always @(posedge clk) begin
    if (!rst) begin
        dna_stream <= 0;
        curr_word <= 0;
        curr_count <= 0;
        ready <= 0;
        new_pack <= 0;
    end
    else begin
        if (rd_flag == 1'b0) begin
            ready <= dna_stream_in[3];              //Last bit for ready state
            curr_count <= dna_stream_in[2] + 1'b1;         // Last but one bit for data count (plus 1, as binary data presents 1 occurrence of dna data less)
            curr_word <= dna_stream_in[1:0];        // Remaining bits for dna data (a,c,g,t)
            rd_flag <= 1;
        end
        if (curr_count == 0) begin
            rd_flag <= 0;
        end
        else begin
            if (ready != 0) begin
                dna_stream <= curr_word;
                curr_count <= curr_count - 1'b1;
            end
            else begin
                dna_stream <= 2'bxx;
                curr_count <= curr_count - 1'b1;
                new_pack <= 1;
            end
        end
    end
end
endmodule
