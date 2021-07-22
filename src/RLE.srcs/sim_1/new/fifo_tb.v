`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: AGH
// Engineer: Agnieszka Kamien
// 
// Create Date: 14.07.2021 10:00:49
// Design Name: RLE 
// Module Name: fifo_tb
// 
////////////////////////////////////////////////////////////

module fifo_tb();

/**
 * Parameters
 */
 
`define wrclk_period 40
`define rdclk_period 10 


/**
 * Local variables and signals
 */
 
reg  rst, clk_100MHz, clk_400MHz, wr_en, rd_en; 
reg [31:0] din;

wire [31:0] dout;
wire [3:0] rd_data_count, wr_data_count;
wire full, empty, overflow, underflow, valid, wr_ack;

integer i,j,k;


/**
 * UUT placement
 */

fifo_generator_0 fifo_UUT (
    .rst    (rst),
    .wr_clk (clk_100MHz),
    .rd_clk (clk_400MHz),
    .din    (din),
    .wr_en  (wr_en),
    .rd_en  (rd_en),
    .dout   (dout),
    .full   (full),
    .wr_ack (wr_ack),
    .overflow(overflow),
    .empty  (empty),
    .valid  (valid),
    .underflow(underflow),
    .rd_data_count (rd_data_count),
    .wr_data_count (wr_data_count)    
  );    
    
    
/**
*  Clocks generation
*/

initial clk_400MHz = 1'b1;
always #(`rdclk_period/2)  clk_400MHz = ~clk_400MHz;

initial clk_100MHz = 1'b1;
always #(`wrclk_period/2)  clk_100MHz = ~clk_100MHz;
   
   
/**
* Test
*/
    
initial begin

    //Initialization
    rst = 1'b0;
    din = 32'b0;
    wr_en = 1'b0;
    rd_en = 1'b0;
    #`wrclk_period;
    
    // Reset 
    rst = 1'b1;
    #(`wrclk_period * 3);
    rst = 1'b0;
    #(`wrclk_period * 27);           //according to docs
    
    for (k = 0; k < 5; k = k + 1) begin
        //Start writing to FIFO
        #(`wrclk_period);
        for(i = 0; i < 5; i = i + 1) begin
            wr_en = 1'b1;
            din = k + i;
            #`wrclk_period;
        end
        
        //Stop writing to FIFO
        wr_en = 1'b0;
        #`wrclk_period;
        
        //Start reading from FIFO
        #`rdclk_period; 
        for(j = 0; j < 5; j = j + 1) begin
            rd_en = 1'b1;   
            #`rdclk_period;
        end
        
        //Stop reading from FIFO
        rd_en = 1'b0;
        #(`rdclk_period*2);
    end
    $stop;
end    
    
endmodule
