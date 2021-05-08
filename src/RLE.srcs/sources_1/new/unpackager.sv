`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.05.2021 17:00:50
// Design Name: 
// Module Name: unpackager
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module unpackager   (
    input clk,      // ASCII clk: 100 MHz
    input clk_400MHz,      // ASCII clk: 100 MHz
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
reg [7:0] ASCII_char_nxt;
reg [2:0] ctr = 0;

int packets [0:3];

always @(posedge clk_400MHz) begin
    if (!rst) begin
        ASCII_char <= 8'b0;
    end
    else begin
        ASCII_char <= ASCII_char_nxt;
    end
end

always @* begin
    if (!empty_fifo) begin
        packets[0] = ASCII_package_out[31:24];
        packets[1] = ASCII_package_out[23:16];
        packets[2] = ASCII_package_out[15:8];
        packets[3] = ASCII_package_out[7:0];
        ctr = 0;
    end
    else if (ctr < 4) begin
        ASCII_char_nxt = packets[ctr];
        ctr = ctr + 1;
    end
end


endmodule
