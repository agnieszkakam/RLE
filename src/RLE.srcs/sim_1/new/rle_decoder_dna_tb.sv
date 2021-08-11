`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: AGH
// Engineer: 
// 
// Create Date: 11.08.2021 14:53:10
// Design Name: RLE
// Module Name: rle_decoder_dna_tb
//////////////////////////////////////////////////////////////////////////////////


module rle_decoder_dna_tb();

logic clk_100MHz;
logic clk_400MHz;
logic rst;
//logic [15:0] dna_stream_in;
logic [3:0] data_4b_nuc_unpack;
logic [1:0] dna_stream;
logic curr_count;
logic rd_flag;
logic ready;
logic [2:0] i = 0;

//localparam DATA_WIDTH = 3;
//localparam CTR_WIDTH = 1;

//Data for testing
//int data_in[0:2] = { 16'b11000101111001111000, 16'b01000101011001110000, 16'b11001101111011111000};
int data_in_for_dna_dec[0:2] = { 4'b1110, 4'b0100, 4'b1100};
 
//Instantiate modules
//unpackager_dec my_unpack_dec ( .clk(clk_100MHz), .clk_400MHz(clk_400MHz), .rst(rst), .input_stream(dna_stream_in), .output_nuc_4b(4b_data_nuc_unpack) );
rle_decoder_dna my_dna_dec ( .clk(clk_100MHz), .rst(rst), .dna_stream_in(data_4b_nuc_unpack), .dna_stream(dna_stream), .curr_count(curr_count), .rd_flag(rd_flag), .ready(ready) );

initial begin
    rst = 1'b0;
    #100 rst = 1'b1;
end

always
begin
    clk_400MHz = 1'b0;
    #5; 
    clk_400MHz = 1'b1;
    #5;
end

always
begin
    clk_100MHz = 1'b0;
    #20; 
    clk_100MHz = 1'b1;
    #20;
end

always @(posedge clk_100MHz) begin

    if ( (rd_flag == 0) && (curr_count == 0) ) begin
        data_4b_nuc_unpack = data_in_for_dna_dec[i];
        i = i + 1;
    end

end

endmodule
