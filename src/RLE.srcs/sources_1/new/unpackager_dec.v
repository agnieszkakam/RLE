`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: AGH
// Engineer: 
// 
// Create Date: 11.08.2021 12:23:49
// Design Name: RLE
// Module Name: unpackager_dec
// 
//////////////////////////////////////////////////////////////////////////////////


module unpackager_dec(      
    input clk_400MHz,     
    input rst,
    input [15:0] input_stream,
    input new_pack,
    output reg [3:0] output_nuc_4b
    );

reg [2:0] ctr = 0;
reg [3:0] packets [0:2];

always @(posedge clk_400MHz) begin
    if (!rst) begin
        output_nuc_4b <= 4'b0000;
        ctr <= 3'b000;
        end
    else begin
        if ( new_pack & (ctr == 3 )) begin
            packets[0] <= input_stream[11:8];
            packets[1] <= input_stream[7:4];
            packets[2] <= input_stream[3:0];
            output_nuc_4b <= input_stream[15:12];
            ctr <= 0;
        end
        else if (ctr != 3) begin
            output_nuc_4b <= packets[ctr];
            ctr <= ctr + 1;
        end
    end
end
    
endmodule
