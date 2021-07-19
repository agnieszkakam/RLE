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
    input wr_en, 
    input rd_en,
    input [31:0] ASCII_package_in,
    output reg [7:0] ASCII_char
);

wire empty_fifo, valid, full;
wire [31:0] ASCII_package_out;

fifo_generator_0 fifo (
    .rst    (!rst),
    .wr_clk (clk),
    .rd_clk (clk_400MHz),
    .din    (ASCII_package_in),
    .wr_en  (wr_en),
    .rd_en  (rd_en),
    .dout   (ASCII_package_out),
    .full   (full),
    .wr_ack (),
    .overflow(),
    .empty  (empty_fifo),
    .valid  (valid),
    .underflow(),
    .rd_data_count (),
    .wr_data_count ()    
);

reg [2:0] ctr = 0;
reg [7:0] packets [0:2];

always @(posedge clk_400MHz) begin
    if (valid) begin
        packets[0] <= ASCII_package_out[23:16];
        packets[1] <= ASCII_package_out[15:8];
        packets[2] <= ASCII_package_out[7:0];
        ASCII_char <= ASCII_package_out[31:24];
        ctr <= 0;
    end
    else if (ctr != 3) begin
        ASCII_char <= packets[ctr];
        ctr <= ctr + 1;  
    end
end


endmodule
