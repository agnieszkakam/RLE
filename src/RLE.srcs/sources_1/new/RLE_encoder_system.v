`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: AGH
// Engineer: Agnieszka Kamien
// 
// Create Date: 29.07.2021 18:28:57
// Design Name: RLE 
// Module Name: RLE_encoder_system
// 
//////////////////////////////////////////////////////////////////////////////////

module RLE_encoder_system(
    input wire clk,
    input wire clk_400MHz,
    input wire rst,
    input wire wr_en,
    input wire rd_en,
    input wire [31:0] ASCII_package_in,
    output wire [15:0] output_data
);
    
wire [7:0] nucleotide_ASCII_single;

unpackager unpackager (
    .clk(clk),
    .clk_400MHz(clk_400MHz),
    .rst(rst),
    .wr_en(wr_en),
    .rd_en(rd_en),
    .ASCII_package_in(ASCII_package_in),
    .ASCII_char(nucleotide_ASCII_single)
);

wire [1:0] nucleotide_code_single;
wire valid_nucleo_code;

nucleo_encoder nucleo_enc (
    .clk(clk_400MHz),
    .rst(rst),
    .nucleotide_ASCII(nucleotide_ASCII_single),
    .valid(valid_nucleo_code),
    .nucleotide_code(nucleotide_code_single)
);

wire [2:0] compressed_stream;
wire valid;

rle_encoder_beh #(.DATA_WIDTH(2),.CTR_WIDTH(1)) RLE_enc ( 
    .clk(clk_400MHz),
    .rst(rst),
    .ready(valid_nucleo_code),
    .stream_in(nucleotide_code_single),
    .compressed_stream(compressed_stream),
    .valid(valid)
);
    
packager packager (
    .clk(clk),
    .clk_400MHz(clk_400MHz),
    .rst(rst),
    .compressed_stream(compressed_stream),
    .ready(valid),
    .output_data(output_data)
);
    
endmodule
