`timescale 1ns / 1ps
///////////////////////////////////////////////////////////////////////////////
// Filename: rle_enc_beh_tb.sv
// Module Name: rle_enc_beh
///////////////////////////////////////////////////////////////////////////////

module rle_enc_beh_tb();

logic clk; // Give simulation a tick. The module does not need this
logic rst;
logic [DATA_WIDTH-1:0] input_stream;
logic valid;
logic [DATA_WIDTH+CTR_WIDTH-1:0] output_stream;
logic [5:0] i=0;

int data_in[0:23] = { 8'hA5, 8'hA5, 8'hA5, 8'hA5, 8'hA5, 8'hA5, 8'hA5, 8'hA5, 8'hA5, 8'hA5, 8'hA5, 8'hA5, 8'hA5, 8'hA5, 8'hA5, 8'hA5, 8'hA5, 8'hA5, 8'hbb, 8'hbb,  8'hbb, 8'hbb,  8'hbc, 8'hbd};

localparam DATA_WIDTH = 8;
localparam CTR_WIDTH = 6;

// Instantiate the module
//rle_encoder_beh #(.DATA_WIDTH(8),.CTR_WIDTH(4)) UUT ( .clk(clk), .rst(rst), .stream_in(input_stream), .compressed_stream(output_stream), .valid(valid) );
rle_encoder_beh #(.DATA_WIDTH(DATA_WIDTH),.CTR_WIDTH(CTR_WIDTH)) UUT ( .clk(clk), .rst(rst), .stream_in(input_stream), .compressed_stream(output_stream), .valid(valid) );

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
    input_stream = data_in[i];
    i <= (i == 23) ? 0 : i + 1;  
    if (valid)
        $display("ctr=%d (in fact=%d), sequence = 0x%x", output_stream[DATA_WIDTH+CTR_WIDTH-1:DATA_WIDTH], (output_stream[DATA_WIDTH+CTR_WIDTH-1:DATA_WIDTH]+1), output_stream[DATA_WIDTH-1:0]); 
end
endmodule