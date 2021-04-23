`timescale 1ns / 1ps
///////////////////////////////////////////////////////////////////////////////
// Filename: rle_enc_beh_tb.sv
// Module Name: rle_enc_beh
///////////////////////////////////////////////////////////////////////////////

module rle_enc_beh_tb();

logic clk; // Give simulation a tick. The module does not need this
logic rst;
logic [7:0] input_stream;
logic valid;
logic [11:0] output_stream;
logic [5:0] i=0;

int arctan[0:23] = { 8'hA5, 8'hA5, 8'hA5, 8'hA5, 8'hA5, 8'hA5, 8'hA5, 8'h55, 8'h55, 8'hA5, 8'hA5, 8'hA5, 8'hA5, 8'hA5, 8'hA5, 8'hA5, 8'hA5, 8'hA5, 8'hbb, 8'hbb,  8'hbb, 8'hbb,  8'hbc, 8'hbd};

// Instantiate the module
rle_encoder_beh UUT ( .clk(clk), .rst(rst), .stream_in(input_stream), .compressed_stream(output_stream), .valid(valid) );

initial begin
    rst = 1'b0;
    input_stream = 8'hA5;
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
    input_stream = arctan[i];
    i <= (i == 23) ? 0 : i + 1;  
    if (valid)
        $display("ctr=%d, sequence=%x", output_stream[11:8], output_stream[7:0]); 
end
endmodule