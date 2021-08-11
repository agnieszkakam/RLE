`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.08.2021 12:30:11
// Design Name: 
// Module Name: unpackager_dec_tb
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


module unpackager_dec_tb();

logic clk_100MHz;
logic clk_400MHz;
reg rst;
reg [15:0] input_stream;
wire [3:0] output_nuc_4b;
    
int data_in[0:2] = { 16'b11000101111001111000, 16'b01000101011001110000, 16'b11001101111011111000};
   
unpackager_dec unpackager_dec( .clk(clk_100MHz), .clk_400MHz(clk_400MHz), .rst(rst), .input_stream(input_stream), .output_nuc_4b(output_nuc_4b) );

initial begin
    rst = 1'b1;
    #10 rst = 1'b0;
end

always
begin
    clk_400MHz = 1'b1;
    #5; 
    clk_400MHz = 1'b0;
    #5;
end

always
begin
    clk_100MHz = 1'b0;
    #20; 
    clk_100MHz = 1'b1;
    #20;
end

int i=0;

always @(posedge clk_100MHz) begin
    if ( i != 3 ) begin
        input_stream = data_in[i];
        i = i + 1;
    end
    else if ( i == 3) begin
        i = 0;
    end
end
endmodule
