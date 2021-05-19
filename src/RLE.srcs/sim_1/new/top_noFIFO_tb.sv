`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: AGH
// Engineer: Agnieszka Kamien
// 
// Create Date: 12.05.2021 18:16:22
// Design Name: RLE 
// Module Name: top_noFIFO_tb
// 
/////////////////////////////////////////////////////////////////////////////////

module top_noFIFO_tb();
    

logic clk_100MHz;       // Give simulation a tick. The module does not need this
logic clk_400MHz;       // artificial clk400M generation
logic rst, valid;
logic [31:0] nucleotide_ASCII_package;
logic [2:0] output_stream;

int data_in[0:7] = { 32'h61636361, 32'h61746774, 32'h74616363, 32'h61636361, 32'h61636361, 32'h61746774, 32'h61636161, 32'h74746774 };
int i = 0;

// Instantiate the module
top_noFIFO RLE_system ( .clk_100MHz(clk_100MHz), .clk_400MHz(clk_400MHz), .rst(rst), .nucleotide_ASCII_package(nucleotide_ASCII_package), .valid(valid), .output_stream(output_stream) );

initial begin
    rst = 1'b0;
    #10 rst = 1'b1;
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

always@(posedge clk_100MHz) begin
    nucleotide_ASCII_package = data_in[i];
    if ( i == 8 )
        $finish;
    else
        i <= i + 1; 
end   
    
endmodule
