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

/**
 * Local variables and signals
*/

logic clk, rst, wr_en, rd_en, valid;
logic [31:0] nucleotide_ASCII_package;
logic [2:0] output_stream;

int data_in[0:7] = { 32'h61636361, 32'h61746774, 32'h74616363, 32'h61636361, 32'h61636361, 32'h61746774, 32'h61646161, 32'h74746774 };
int k = 0;


/**
 * Parameters
 */
 
`define wrclk_period 40
`define rdclk_period 10  


/**
 * UUT placement
 */
 
top RLE_system (
    .clk(clk),
    .rst(rst),
    .wr_en(wr_en),
    .rd_en(rd_en),
    .nucleotide_ASCII_package(nucleotide_ASCII_package),
    .valid(valid),
    .output_stream(output_stream)
);


/**
*  Clocks generation
*/

initial clk = 1'b1;
always #(`wrclk_period/2)  clk = ~clk;


/**
* Test
*/

initial begin
    
    //Initialization
    rst = 1'b1;
    nucleotide_ASCII_package = 32'b0;
    wr_en = 1'b0;
    rd_en = 1'b0;
    #`wrclk_period;
    
    // Reset 
    rst = 1'b0;
    #(`wrclk_period * 3);
    rst = 1'b1;
    #(`wrclk_period * 27);           //according to docs
    
end

always @(posedge clk) begin
    if (!RLE_system.unpackager.full) begin
        //Start writing to FIFO
        wr_en <= 1'b1;
        nucleotide_ASCII_package = data_in[k];
        k <= (k == 7)? 0 : k + 1;
        #`wrclk_period;
        
        //Stop writing to FIFO
        wr_en <= 1'b0;
        #`wrclk_period;
    end
end

always @(posedge clk) begin
    //Start reading from FIFO
    rd_en <= 1'b1;       
    #`rdclk_period;
    
    //Stop reading from FIFO
    rd_en <= 1'b0;
    #`rdclk_period;
end

endmodule
