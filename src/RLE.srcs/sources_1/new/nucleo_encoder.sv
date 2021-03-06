`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: AGH
// Engineer: Agnieszka Kamien
// 
// Create Date: 07.05.2021 10:32:03
// Design Name: RLE 
// Module Name: nucleo_encoder
// 
//////////////////////////////////////////////////////////////////////////////////

module nucleo_encoder(
    input clk,
    input rst,
    input [7:0] nucleotide_ASCII,
    output reg valid,
    output reg [1:0] nucleotide_code
);

// Nucleotide encoding
localparam a = 2'b00;          
localparam c = 2'b01;
localparam g = 2'b10;
localparam t = 2'b11;
localparam invalid_code = 2'b0;

always @(posedge clk) begin
    valid = 1'b1;
    if ( !rst ) begin
        nucleotide_code <= 2'b0;
        valid <= 1'b0;
    end
    else begin
        case( nucleotide_ASCII)
            8'h61: nucleotide_code <= a;
            8'h63: nucleotide_code <= c;
            8'h67: nucleotide_code <= g;
            8'h74: nucleotide_code <= t;
            default:
            begin
                nucleotide_code <= invalid_code;
                valid <= 1'b0;
            end
        endcase
    end
end

endmodule
