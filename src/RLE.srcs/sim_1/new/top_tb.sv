`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: AGH
// Engineer: Agnieszka Kamien
// 
// Create Date: 10.05.2021 20:38:41
// Design Name: RLE 
// Module Name: top_tb
// 
//////////////////////////////////////////////////////////////////////////////////


module top_tb();

logic clk; // Give simulation a tick. The module does not need this
logic rst;
logic [31:0] nucleotide_ASCII_package;
logic valid;
logic [2:0] output_stream;

int data_in[0:7] = { 32'h61636361, 32'h61746774, 32'h74616363, 32'h61636361, 32'h61636361, 32'h61746774, 32'h61646161, 32'h74746774 };
int i = 0;

// Instantiate the module
top RLE_system ( .clk(clk), .rst(rst), .nucleotide_ASCII_package(nucleotide_ASCII_package), .valid(valid), .output_stream(output_stream) );

initial begin
    rst = 1'b0;
    #10 rst = 1'b1;
end

always
begin
    clk = 1'b0;
    #5; 
    clk = 1'b1;
    #5;
end

always@(posedge clk) begin
    nucleotide_ASCII_package = data_in[i];
    if ( i == 8 )
        $finish;
    else
        i <= i + 1; 
end

endmodule
