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

//int packets [0:3];

always @(posedge clk_400MHz) begin
    if (!rst) begin
        ASCII_char <= 8'b0;
        ctr <= 3'd3;
    end
    else begin
        if ((clk_400MHz & clk) & (ctr == 3)) begin
            ASCII_char <= ASCII_package_in [31:24];
            ctr <= 2;
        end else if (ctr != 3) begin
            ASCII_char <= ASCII_package_in [ ctr*8 +: 8];
            ctr <= (ctr == 0)? 3 : ctr - 1;         
        end
    end
end

endmodule
