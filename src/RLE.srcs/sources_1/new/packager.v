`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: AGH
// Engineer: Agnieszka Kamien
// 
// Create Date: 04.08.2021 19:21:06
// Design Name: RLE 
// Module Name: packager
// 
//////////////////////////////////////////////////////////////////////////////////

module packager(
    input wire clk,
    input wire clk_400MHz,
    input wire rst,
    input wire [2:0] compressed_stream,
    input wire ready,
    output reg [15:0] output_data
);


/**
 * Local variables and signals
*/

reg [1:0] pkg_counter = 2'd3;
reg [15:0] package, package_nxt = 16'b0;


/**
 * Module description
*/
 
always @* begin
    package_nxt [ 4*pkg_counter +: 4 ] <= {ready, compressed_stream};
end 
 
always @(posedge clk_400MHz)    
begin
    package <= package_nxt;
    pkg_counter <= (pkg_counter == 0) ? 3 : pkg_counter - 1;
end

always @(posedge clk)    
begin
    pkg_counter <= 2'd3;
    if (!rst) 
        output_data <= 16'b0;
    else
        output_data <= package;
end

endmodule

