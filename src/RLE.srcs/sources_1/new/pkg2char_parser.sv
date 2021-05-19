`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: AGH
// Engineer: Agnieszka Kamien
// 
// Create Date: 12.05.2021 18:32:09
// Design Name: RLE 
// Module Name: pkg2char_parser
// 
//////////////////////////////////////////////////////////////////////////////////

module pkg2char_parser(
    input clk,            
    input clk_400MHz,     
    input rst,
    input [31:0] ASCII_package_in,
    output reg [7:0] ASCII_char
);

reg [7:0] ASCII_char_nxt;
reg [2:0] ctr = 0, ctr_nxt = 0;

reg [7:0] packets [0:2];

always @(posedge clk_400MHz) begin
    if (!rst) begin
        ASCII_char <= 8'bxx;
        ctr <= 3'd0;
    end
    else begin
        if ((clk_400MHz & clk) & (ctr == 3)) begin
            packets[2] <= ASCII_package_in[7:0];
            packets[1] <= ASCII_package_in[15:8];
            packets[0] <= ASCII_package_in[23:16];
            ASCII_char <= ASCII_package_in[31:24];
            ctr <= 0;
        end else if (ctr != 3) begin
            ASCII_char <= packets[ctr];
            ctr <= ctr + 1;         
        end
    end
end


endmodule
