`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: AGH
// Engineer: Agnieszka Kamien
// 
// Create Date: 07.05.2021 22:38:41
// Design Name: RLE 
// Module Name: nucleo_enc_tb
// 
//////////////////////////////////////////////////////////////////////////////////

module nucleo_enc_tb();
    
logic clk; // Give simulation a tick. The module does not need this
logic rst;
logic [7:0] ASCII_stream;
logic [1:0] nucleo_code;

int i=0;
int dna_seq[0:27] = {  8'h67, 8'h74, 8'h63, 8'h61, 8'h63, 8'h67, 8'h67, 8'h74, 8'h67, 8'h67, 8'h67, 8'h63, 8'h74, 8'h63, 8'h61, 8'h74, 8'h74, 8'h67, 8'h67, 8'h74, 8'h61, 8'h61, 8'h61, 8'h74, 8'h74, 8'h74, 8'h74, 8'h74};
typedef enum bit [1:0]  {a,c,g,t}  nucleo;

nucleo current_nucleotide;

// Instantiate the module
nucleo_encoder #(.DATA_WIDTH(8)) UUT ( .clk(clk), .rst(rst), .nucleotide_ASCII(ASCII_stream), .nucleotide_code(nucleo_code) );

initial begin
    rst = 1'b0;
    #10 rst = 1'b1;
end

always
begin
    clk = 1'b0;
    #5; 
    clk = 1'b1;
    #5; // high for 5 * timescale = 5 ns
end

always@(posedge clk) begin
    ASCII_stream <= dna_seq[i];
    case (nucleo_code)
        2'b00: current_nucleotide = a;
        2'b01: current_nucleotide = c;
        2'b10: current_nucleotide = g;
        2'b11: current_nucleotide = t;
    endcase
    $display("8'h%x --> 2'b%b (%s)",ASCII_stream,nucleo_code, current_nucleotide.name);
    if (i == 30) 
        $finish;
    else
        i <= i + 1;
end
    
endmodule
