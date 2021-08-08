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
logic [15:0] output_data;

int k = 0;
int file, output_file;             //file handle
int i, idx, data_in [NR_OF_VECTORS];

/**
 * Parameters
 */
 
`define wrclk_period 40
`define rdclk_period 10  
localparam NR_OF_VECTORS = 25;

/**
 * UUT placement
 */
 
top RLE_system (
    .clk(clk),
    .rst(rst),
    .wr_en(wr_en),
    .rd_en(rd_en),
    .nucleotide_ASCII_package(nucleotide_ASCII_package),
    .output_data(output_data)
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
    
    //Load test vectors
    $display("Loading testvectors.");
    $readmemh("encoder_testvectors.mem", data_in);
        
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
/*
initial begin

    output_file = $fopen ("encoder_vectors_out.txt", "w");
    if (output_file)
        $display("Output file was opened successfully : %0d", output_file);
    else
        $display("Output file was not opened successfully : %0d", output_file);
    
    for (int j = 0; j < 1000; j++) begin
        @(posedge RLE_system.clk_400MHz);
        if (valid) begin
            $display("Output=%3b",output_stream[2:0]);
            $fdisplay(output_file,"%3b",output_stream[2:0]);
         end
    end
    
    $fclose(output_file);
    $stop;
end*/

always @(posedge clk) begin
    if (!RLE_system.RLE_encoder_system_IP.unpackager.full) begin
        //Start writing to FIFO
        wr_en <= 1'b1;
        nucleotide_ASCII_package = data_in[k];
        k <= (k == NR_OF_VECTORS - 1)? 0 : k + 1;
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
