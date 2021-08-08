`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: AGH
// Engineer: Agnieszka Kamien
// 
// Create Date: 07.05.2021 20:38:41
// Design Name: RLE 
// Module Name: top
// 
////////////////////////////////////////////////////////////

module top(
    input wire clk,
    input wire rst,
    input wire wr_en,
    input wire rd_en,
    input wire [31:0] nucleotide_ASCII_package,
    output wire [15:0] output_data
);

wire clk_400MHz;

clk_wiz_0 clk_divider   (
    .clk_100MHz(clk),
    .clk_400MHz(clk_400MHz)
);

RLE_encoder_system RLE_encoder_system_IP (
    .clk(clk),
    .clk_400MHz(clk_400MHz),
    .rst(rst),
    .wr_en(wr_en),
    .rd_en(rd_en),
    .ASCII_package_in(nucleotide_ASCII_package),
    .output_data(output_data)
);

endmodule
