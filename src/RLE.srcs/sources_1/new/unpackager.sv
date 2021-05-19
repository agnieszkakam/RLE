`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: AGH
// Engineer: Agnieszka Kamien
// 
// Create Date: 07.05.2021 17:00:50
// Design Name: RLE 
// Module Name: unpackager
// 
//////////////////////////////////////////////////////////////////////////////////

module unpackager   (
    input clk,              
    input clk_400MHz,     
    input rst,
    input [31:0] ASCII_package_in,
    output reg [7:0] ASCII_char
);

wire empty_fifo;
wire [31:0] ASCII_package_out;

fifo_generator_0 fifo   (
    .rst(rst),
    .wr_clk(clk),
    .rd_clk(clk_400MHz), 
    .din(ASCII_package_in),
    .wr_en(clk),
    .rd_en(clk_400MHz),
    .dout(ASCII_package_out),
    .full(),
    .empty(empty_fifo)
);

reg [2:0] ctr = 0;
reg [7:0] packets [0:2];

always @(posedge clk_400MHz) begin
    if (!empty_fifo) begin
        packets[0] <= ASCII_package_in[23:16];
        packets[1] <= ASCII_package_in[15:8];
        packets[2] <= ASCII_package_in[7:0];
        ASCII_char <= ASCII_package_in[31:24];
        ctr <= 0;
    end
    else if (ctr != 3) begin
        ASCII_char <= packets[ctr];
        ctr <= ctr + 1;  
    end
end


endmodule
