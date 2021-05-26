// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Thu May 20 08:16:13 2021
// Host        : DESKTOP-KQE9A5B running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub c:/git/RLE/src/RLE.srcs/sources_1/ip/clk_wiz_0_1/clk_wiz_0_stub.v
// Design      : clk_wiz_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg484-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module clk_wiz_0(clk_400MHz, clk_100MHz)
/* synthesis syn_black_box black_box_pad_pin="clk_400MHz,clk_100MHz" */;
  output clk_400MHz;
  input clk_100MHz;
endmodule
