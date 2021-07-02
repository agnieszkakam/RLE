`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: AGH
// Engineer: Agnieszka Kamien
// 
// Create Date: 12.05.2021 18:16:06
// Design Name: RLE 
// Module Name: top_noFIFO
// 
//////////////////////////////////////////////////////////////////////////////////


module top_noFIFO(
    input wire clk_100MHz,
    input wire clk_400MHz,
    input wire rst,
    input wire [31:0] nucleotide_ASCII_package,
    input wire new_ASCII_package,
    output wire valid,
    output wire [2:0] output_stream
);
  
wire [7:0] nucleo_single;  
  
pkg2char_parser parser (
    .clk(clk_100MHz),            
    .clk_400MHz(clk_400MHz),     
    .rst(rst),
    .ASCII_package_in(nucleotide_ASCII_package),
    .new_package(new_ASCII_package),
    .ASCII_char(nucleo_single)
);  

wire [1:0] nucleotide_code_single;

nucleo_encoder nucleo_enc (
    .clk(clk_400MHz),
    .rst(rst),
    .nucleotide_ASCII(nucleo_single),
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
