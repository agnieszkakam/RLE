`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: AGH
// Engineer: Agnieszka Kamien
// 
// Create Date: 07.05.2021 20:38:41
// Design Name: RLE 
// Module Name: top
// 
//////////////////////
////////////////////////////////////////////////////////////

module top(
    input wire clk,
    input wire rst,
    input wire [31:0] nucleotide_ASCII_package,
    output wire valid,
    output wire [2:0] output_stream
);

wire clk_400MHz;

clk_wiz_0 clk_divider   (
    .clk_100MHz(clk),
    .clk_400MHz(clk_400MHz)
);

wire [7:0] nucleotide_ASCII_single;

unpackager unpackager (
    .clk(clk),
    .clk_400MHz(clk_400MHz),
    .rst(rst),
    .ASCII_package_in(nucleotide_ASCII_package),
    .ASCII_char(nucleotide_ASCII_single)
);

wire [1:0] nucleotide_code_single;

nucleo_encoder nucleo_enc (
    .clk(clk_400MHz),
    .rst(rst),
    .nucleotide_ASCII(nucleotide_ASCII_single),
    .nucleotide_code(nucleotide_code_single)
);

rle_encoder_beh #(.DATA_WIDTH(2),.CTR_WIDTH(1)) RLE_enc ( 
    .clk(clk_400MHz),
    .rst(rst),
    .stream_in(nucleotide_code_single),
    .compressed_stream(output_stream),
    .valid(valid)
);

endmodule
