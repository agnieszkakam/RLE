`timescale 1 ns / 1 ps

	module RLE_encoder_v1_0_S00_AXI #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line

		// Width of S_AXI data bus
		parameter integer C_S_AXI_DATA_WIDTH	= 32,
		// Width of S_AXI address bus
		parameter integer C_S_AXI_ADDR_WIDTH	= 4
	)
	(
		// Users to add ports here

		// User ports ends
		// Do not modify the ports beyond this line

		// Global Clock Signal
		input wire  S_AXI_ACLK,
		// Global Reset Signal. This Signal is Active LOW
		input wire  S_AXI_ARESETN,
		// Write address (issued by master, acceped by Slave)
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
		// Write channel Protection type. This signal indicates the
    		// privilege and security level of the transaction, and whether
    		// the transaction is a data access or an instruction access.
		input wire [2 : 0] S_AXI_AWPROT,
		// Write address valid. This signal indicates that the master signaling
    		// valid write address and control information.
		input wire  S_AXI_AWVALID,
		// Write address ready. This signal indicates that the slave is ready
    		// to accept an address and associated control signals.
		output wire  S_AXI_AWREADY,
		// Write data (issued by master, acceped by Slave) 
		input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
		// Write strobes. This signal indicates which byte lanes hold
    		// valid data. There is one write strobe bit for each eight
    		// bits of the write data bus.    
		input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
		// Write valid. This signal indicates that valid write
    		// data and strobes are available.
		input wire  S_AXI_WVALID,
		// Write ready. This signal indicates that the slave
    		// can accept the write data.
		output wire  S_AXI_WREADY,
		// Write response. This signal indicates the status
    		// of the write transaction.
		output wire [1 : 0] S_AXI_BRESP,
		// Write response valid. This signal indicates that the channel
    		// is signaling a valid write response.
		output wire  S_AXI_BVALID,
		// Response ready. This signal indicates that the master
    		// can accept a write response.
		input wire  S_AXI_BREADY,
		// Read address (issued by master, acceped by Slave)
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
		// Protection type. This signal indicates the privilege
    		// and security level of the transaction, and whether the
    		// transaction is a data access or an instruction access.
		input wire [2 : 0] S_AXI_ARPROT,
		// Read address valid. This signal indicates that the channel
    		// is signaling valid read address and control information.
		input wire  S_AXI_ARVALID,
		// Read address ready. This signal indicates that the slave is
    		// ready to accept an address and associated control signals.
		output wire  S_AXI_ARREADY,
		// Read data (issued by slave)
		output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
		// Read response. This signal indicates the status of the
    		// read transfer.
		output wire [1 : 0] S_AXI_RRESP,
		// Read valid. This signal indicates that the channel is
    		// signaling the required read data.
		output wire  S_AXI_RVALID,
		// Read ready. This signal indicates that the master can
    		// accept the read data and response information.
		input wire  S_AXI_RREADY
	);

	// AXI4LITE signals
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr;
	reg  	axi_awready;
	reg  	axi_wready;
	reg [1 : 0] 	axi_bresp;
	reg  	axi_bvalid;
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_araddr;
	reg  	axi_arready;
	reg [C_S_AXI_DATA_WIDTH-1 : 0] 	axi_rdata;
	reg [1 : 0] 	axi_rresp;
	reg  	axi_rvalid;

	// Example-specific design signals
	// local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
	// ADDR_LSB is used for addressing 32/64 bit registers/memories
	// ADDR_LSB = 2 for 32 bits (n downto 2)
	// ADDR_LSB = 3 for 64 bits (n downto 3)
	localparam integer ADDR_LSB = (C_S_AXI_DATA_WIDTH/32) + 1;
	localparam integer OPT_MEM_ADDR_BITS = 1;
	//----------------------------------------------
	//-- Signals for user logic register space example
	//------------------------------------------------
	//-- Number of Slave Registers 4
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg0;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg1;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg2;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg3;
	wire	 slv_reg_rden;
	wire	 slv_reg_wren;
	reg [C_S_AXI_DATA_WIDTH-1:0]	 reg_data_out;
	integer	 byte_index;
	reg	 aw_en;

	// I/O Connections assignments

	assign S_AXI_AWREADY	= axi_awready;
	assign S_AXI_WREADY	= axi_wready;
	assign S_AXI_BRESP	= axi_bresp;
	assign S_AXI_BVALID	= axi_bvalid;
	assign S_AXI_ARREADY	= axi_arready;
	assign S_AXI_RDATA	= axi_rdata;
	assign S_AXI_RRESP	= axi_rresp;
	assign S_AXI_RVALID	= axi_rvalid;
	// Implement axi_awready generation
	// axi_awready is asserted for one S_AXI_ACLK clock cycle when both
	// S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
	// de-asserted when reset is low.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_awready <= 1'b0;
	      aw_en <= 1'b1;
	    end 
	  else
	    begin    
	      if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en)
	        begin
	          // slave is ready to accept write address when 
	          // there is a valid write address and write data
	          // on the write address and data bus. This design 
	          // expects no outstanding transactions. 
	          axi_awready <= 1'b1;
	          aw_en <= 1'b0;
	        end
	        else if (S_AXI_BREADY && axi_bvalid)
	            begin
	              aw_en <= 1'b1;
	              axi_awready <= 1'b0;
	            end
	      else           
	        begin
	          axi_awready <= 1'b0;
	        end
	    end 
	end       

	// Implement axi_awaddr latching
	// This process is used to latch the address when both 
	// S_AXI_AWVALID and S_AXI_WVALID are valid. 

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_awaddr <= 0;
	    end 
	  else
	    begin    
	      if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en)
	        begin
	          // Write Address latching 
	          axi_awaddr <= S_AXI_AWADDR;
	        end
	    end 
	end       

	// Implement axi_wready generation
	// axi_wready is asserted for one S_AXI_ACLK clock cycle when both
	// S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is 
	// de-asserted when reset is low. 

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_wready <= 1'b0;
	    end 
	  else
	    begin    
	      if (~axi_wready && S_AXI_WVALID && S_AXI_AWVALID && aw_en )
	        begin
	          // slave is ready to accept write data when 
	          // there is a valid write address and write data
	          // on the write address and data bus. This design 
	          // expects no outstanding transactions. 
	          axi_wready <= 1'b1;
	        end
	      else
	        begin
	          axi_wready <= 1'b0;
	        end
	    end 
	end       

	// Implement memory mapped register select and write logic generation
	// The write data is accepted and written to memory mapped registers when
	// axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
	// select byte enables of slave registers while writing.
	// These registers are cleared when reset (active low) is applied.
	// Slave register write enable is asserted when valid address and data are available
	// and the slave is ready to accept the write address and write data.
	assign slv_reg_wren = axi_wready && S_AXI_WVALID && axi_awready && S_AXI_AWVALID;

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      slv_reg0 <= 0;
	      slv_reg1 <= 0;
	      //slv_reg2 <= 0;
	      //slv_reg3 <= 0;
	    end 
	  else begin
	    if (slv_reg_wren)
	      begin
	        case ( axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
	          2'h0:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 0
	                slv_reg0[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          2'h1:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 1
	                slv_reg1[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          2'h2:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 2
	                //slv_reg2[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          2'h3:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 3
	                //slv_reg3[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          default : begin
	                      slv_reg0 <= slv_reg0;
	                      slv_reg1 <= slv_reg1;
	                      //slv_reg2 <= slv_reg2;
	                      //slv_reg3 <= slv_reg3;
	                    end
	        endcase
	      end
	  end
	end    

	// Implement write response logic generation
	// The write response and response valid signals are asserted by the slave 
	// when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.  
	// This marks the acceptance of address and indicates the status of 
	// write transaction.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_bvalid  <= 0;
	      axi_bresp   <= 2'b0;
	    end 
	  else
	    begin    
	      if (axi_awready && S_AXI_AWVALID && ~axi_bvalid && axi_wready && S_AXI_WVALID)
	        begin
	          // indicates a valid write response is available
	          axi_bvalid <= 1'b1;
	          axi_bresp  <= 2'b0; // 'OKAY' response 
	        end                   // work error responses in future
	      else
	        begin
	          if (S_AXI_BREADY && axi_bvalid) 
	            //check if bready is asserted while bvalid is high) 
	            //(there is a possibility that bready is always asserted high)   
	            begin
	              axi_bvalid <= 1'b0; 
	            end  
	        end
	    end
	end   

	// Implement axi_arready generation
	// axi_arready is asserted for one S_AXI_ACLK clock cycle when
	// S_AXI_ARVALID is asserted. axi_awready is 
	// de-asserted when reset (active low) is asserted. 
	// The read address is also latched when S_AXI_ARVALID is 
	// asserted. axi_araddr is reset to zero on reset assertion.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_arready <= 1'b0;
	      axi_araddr  <= 32'b0;
	    end 
	  else
	    begin    
	      if (~axi_arready && S_AXI_ARVALID)
	        begin
	          // indicates that the slave has acceped the valid read address
	          axi_arready <= 1'b1;
	          // Read address latching
	          axi_araddr  <= S_AXI_ARADDR;
	        end
	      else
	        begin
	          axi_arready <= 1'b0;
	        end
	    end 
	end       

	// Implement axi_arvalid generation
	// axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both 
	// S_AXI_ARVALID and axi_arready are asserted. The slave registers 
	// data are available on the axi_rdata bus at this instance. The 
	// assertion of axi_rvalid marks the validity of read data on the 
	// bus and axi_rresp indicates the status of read transaction.axi_rvalid 
	// is deasserted on reset (active low). axi_rresp and axi_rdata are 
	// cleared to zero on reset (active low).  
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_rvalid <= 0;
	      axi_rresp  <= 0;
	    end 
	  else
	    begin    
	      if (axi_arready && S_AXI_ARVALID && ~axi_rvalid)
	        begin
	          // Valid read data is available at the read data bus
	          axi_rvalid <= 1'b1;
	          axi_rresp  <= 2'b0; // 'OKAY' response
	        end   
	      else if (axi_rvalid && S_AXI_RREADY)
	        begin
	          // Read data is accepted by the master
	          axi_rvalid <= 1'b0;
	        end                
	    end
	end    

	// Implement memory mapped register select and read logic generation
	// Slave register read enable is asserted when valid address is available
	// and the slave is ready to accept the read address.
	assign slv_reg_rden = axi_arready & S_AXI_ARVALID & ~axi_rvalid;
	always @(*)
	begin
	      // Address decoding for reading registers
	      case ( axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
	        2'h0   : reg_data_out <= slv_reg0;
	        2'h1   : reg_data_out <= slv_reg1;
	        2'h2   : reg_data_out <= slv_reg2;
	        2'h3   : reg_data_out <= slv_reg3;
	        default : reg_data_out <= 0;
	      endcase
	end

	// Output register or memory read data
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_rdata  <= 0;
	    end 
	  else
	    begin    
	      // When there is a valid read address (S_AXI_ARVALID) with 
	      // acceptance of read address by the slave (axi_arready), 
	      // output the read dada 
	      if (slv_reg_rden)
	        begin
	          axi_rdata <= reg_data_out;     // register read data
	        end   
	    end
	end    

	// Add user logic here
    
    //Reset signal
    wire ARESET;
    assign ARESET = ~S_AXI_ARESETN;
    
    //Transfer output from RLE encoder to output registers
    wire [C_S_AXI_DATA_WIDTH-1:0] slv_wire2;
    
    always @( posedge S_AXI_ACLK )
    begin
        slv_reg2 <= slv_wire2;
    end
    
    //Assign zeros to unused bits
    assign slv_wire2[31:16] = 31'b0;
    
    top RLE_system (
        .clk(S_AXI_ACLK),
        .rst(ARESET),
        .wr_en(slv_reg0[0]),
        .rd_en(slv_reg0[1]),
        .nucleotide_ASCII_package(slv_reg1),
        .output_data(slv_wire2[15:0])
    );

	// User logic ends

	endmodule
//*******************************************************************************/

module fifo_generator_0 (
  rst,
  wr_clk,
  rd_clk,
  din,
  wr_en,
  rd_en,
  dout,
  full,
  wr_ack,
  overflow,
  empty,
  valid,
  underflow,
  rd_data_count,
  wr_data_count
);

input wire rst;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME write_clk, FREQ_HZ 100000000, PHASE 0.000, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 write_clk CLK" *)
input wire wr_clk;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME read_clk, FREQ_HZ 100000000, PHASE 0.000, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 read_clk CLK" *)
input wire rd_clk;
(* X_INTERFACE_INFO = "xilinx.com:interface:fifo_write:1.0 FIFO_WRITE WR_DATA" *)
input wire [31 : 0] din;
(* X_INTERFACE_INFO = "xilinx.com:interface:fifo_write:1.0 FIFO_WRITE WR_EN" *)
input wire wr_en;
(* X_INTERFACE_INFO = "xilinx.com:interface:fifo_read:1.0 FIFO_READ RD_EN" *)
input wire rd_en;
(* X_INTERFACE_INFO = "xilinx.com:interface:fifo_read:1.0 FIFO_READ RD_DATA" *)
output wire [31 : 0] dout;
(* X_INTERFACE_INFO = "xilinx.com:interface:fifo_write:1.0 FIFO_WRITE FULL" *)
output wire full;
output wire wr_ack;
output wire overflow;
(* X_INTERFACE_INFO = "xilinx.com:interface:fifo_read:1.0 FIFO_READ EMPTY" *)
output wire empty;
output wire valid;
output wire underflow;
output wire [3 : 0] rd_data_count;
output wire [3 : 0] wr_data_count;

  fifo_generator_v13_2_3 #(
    .C_COMMON_CLOCK(0),
    .C_SELECT_XPM(0),
    .C_COUNT_TYPE(0),
    .C_DATA_COUNT_WIDTH(4),
    .C_DEFAULT_VALUE("BlankString"),
    .C_DIN_WIDTH(32),
    .C_DOUT_RST_VAL("0"),
    .C_DOUT_WIDTH(32),
    .C_ENABLE_RLOCS(0),
    .C_FAMILY("zynq"),
    .C_FULL_FLAGS_RST_VAL(1),
    .C_HAS_ALMOST_EMPTY(0),
    .C_HAS_ALMOST_FULL(0),
    .C_HAS_BACKUP(0),
    .C_HAS_DATA_COUNT(0),
    .C_HAS_INT_CLK(0),
    .C_HAS_MEMINIT_FILE(0),
    .C_HAS_OVERFLOW(1),
    .C_HAS_RD_DATA_COUNT(1),
    .C_HAS_RD_RST(0),
    .C_HAS_RST(1),
    .C_HAS_SRST(0),
    .C_HAS_UNDERFLOW(1),
    .C_HAS_VALID(1),
    .C_HAS_WR_ACK(1),
    .C_HAS_WR_DATA_COUNT(1),
    .C_HAS_WR_RST(0),
    .C_IMPLEMENTATION_TYPE(2),
    .C_INIT_WR_PNTR_VAL(0),
    .C_MEMORY_TYPE(2),
    .C_MIF_FILE_NAME("BlankString"),
    .C_OPTIMIZATION_MODE(0),
    .C_OVERFLOW_LOW(0),
    .C_PRELOAD_LATENCY(1),
    .C_PRELOAD_REGS(0),
    .C_PRIM_FIFO_TYPE("512x36"),
    .C_PROG_EMPTY_THRESH_ASSERT_VAL(2),
    .C_PROG_EMPTY_THRESH_NEGATE_VAL(3),
    .C_PROG_EMPTY_TYPE(0),
    .C_PROG_FULL_THRESH_ASSERT_VAL(13),
    .C_PROG_FULL_THRESH_NEGATE_VAL(12),
    .C_PROG_FULL_TYPE(0),
    .C_RD_DATA_COUNT_WIDTH(4),
    .C_RD_DEPTH(16),
    .C_RD_FREQ(1),
    .C_RD_PNTR_WIDTH(4),
    .C_UNDERFLOW_LOW(0),
    .C_USE_DOUT_RST(1),
    .C_USE_ECC(0),
    .C_USE_EMBEDDED_REG(0),
    .C_USE_PIPELINE_REG(0),
    .C_POWER_SAVING_MODE(0),
    .C_USE_FIFO16_FLAGS(0),
    .C_USE_FWFT_DATA_COUNT(0),
    .C_VALID_LOW(0),
    .C_WR_ACK_LOW(0),
    .C_WR_DATA_COUNT_WIDTH(4),
    .C_WR_DEPTH(16),
    .C_WR_FREQ(1),
    .C_WR_PNTR_WIDTH(4),
    .C_WR_RESPONSE_LATENCY(1),
    .C_MSGON_VAL(1),
    .C_ENABLE_RST_SYNC(1),
    .C_EN_SAFETY_CKT(0),
    .C_ERROR_INJECTION_TYPE(0),
    .C_SYNCHRONIZER_STAGE(2),
    .C_INTERFACE_TYPE(0),
    .C_AXI_TYPE(1),
    .C_HAS_AXI_WR_CHANNEL(1),
    .C_HAS_AXI_RD_CHANNEL(1),
    .C_HAS_SLAVE_CE(0),
    .C_HAS_MASTER_CE(0),
    .C_ADD_NGC_CONSTRAINT(0),
    .C_USE_COMMON_OVERFLOW(0),
    .C_USE_COMMON_UNDERFLOW(0),
    .C_USE_DEFAULT_SETTINGS(0),
    .C_AXI_ID_WIDTH(1),
    .C_AXI_ADDR_WIDTH(32),
    .C_AXI_DATA_WIDTH(64),
    .C_AXI_LEN_WIDTH(8),
    .C_AXI_LOCK_WIDTH(1),
    .C_HAS_AXI_ID(0),
    .C_HAS_AXI_AWUSER(0),
    .C_HAS_AXI_WUSER(0),
    .C_HAS_AXI_BUSER(0),
    .C_HAS_AXI_ARUSER(0),
    .C_HAS_AXI_RUSER(0),
    .C_AXI_ARUSER_WIDTH(1),
    .C_AXI_AWUSER_WIDTH(1),
    .C_AXI_WUSER_WIDTH(1),
    .C_AXI_BUSER_WIDTH(1),
    .C_AXI_RUSER_WIDTH(1),
    .C_HAS_AXIS_TDATA(1),
    .C_HAS_AXIS_TID(0),
    .C_HAS_AXIS_TDEST(0),
    .C_HAS_AXIS_TUSER(1),
    .C_HAS_AXIS_TREADY(1),
    .C_HAS_AXIS_TLAST(0),
    .C_HAS_AXIS_TSTRB(0),
    .C_HAS_AXIS_TKEEP(0),
    .C_AXIS_TDATA_WIDTH(8),
    .C_AXIS_TID_WIDTH(1),
    .C_AXIS_TDEST_WIDTH(1),
    .C_AXIS_TUSER_WIDTH(4),
    .C_AXIS_TSTRB_WIDTH(1),
    .C_AXIS_TKEEP_WIDTH(1),
    .C_WACH_TYPE(0),
    .C_WDCH_TYPE(0),
    .C_WRCH_TYPE(0),
    .C_RACH_TYPE(0),
    .C_RDCH_TYPE(0),
    .C_AXIS_TYPE(0),
    .C_IMPLEMENTATION_TYPE_WACH(2),
    .C_IMPLEMENTATION_TYPE_WDCH(1),
    .C_IMPLEMENTATION_TYPE_WRCH(2),
    .C_IMPLEMENTATION_TYPE_RACH(2),
    .C_IMPLEMENTATION_TYPE_RDCH(1),
    .C_IMPLEMENTATION_TYPE_AXIS(1),
    .C_APPLICATION_TYPE_WACH(0),
    .C_APPLICATION_TYPE_WDCH(0),
    .C_APPLICATION_TYPE_WRCH(0),
    .C_APPLICATION_TYPE_RACH(0),
    .C_APPLICATION_TYPE_RDCH(0),
    .C_APPLICATION_TYPE_AXIS(0),
    .C_PRIM_FIFO_TYPE_WACH("512x36"),
    .C_PRIM_FIFO_TYPE_WDCH("1kx36"),
    .C_PRIM_FIFO_TYPE_WRCH("512x36"),
    .C_PRIM_FIFO_TYPE_RACH("512x36"),
    .C_PRIM_FIFO_TYPE_RDCH("1kx36"),
    .C_PRIM_FIFO_TYPE_AXIS("1kx18"),
    .C_USE_ECC_WACH(0),
    .C_USE_ECC_WDCH(0),
    .C_USE_ECC_WRCH(0),
    .C_USE_ECC_RACH(0),
    .C_USE_ECC_RDCH(0),
    .C_USE_ECC_AXIS(0),
    .C_ERROR_INJECTION_TYPE_WACH(0),
    .C_ERROR_INJECTION_TYPE_WDCH(0),
    .C_ERROR_INJECTION_TYPE_WRCH(0),
    .C_ERROR_INJECTION_TYPE_RACH(0),
    .C_ERROR_INJECTION_TYPE_RDCH(0),
    .C_ERROR_INJECTION_TYPE_AXIS(0),
    .C_DIN_WIDTH_WACH(1),
    .C_DIN_WIDTH_WDCH(64),
    .C_DIN_WIDTH_WRCH(2),
    .C_DIN_WIDTH_RACH(32),
    .C_DIN_WIDTH_RDCH(64),
    .C_DIN_WIDTH_AXIS(1),
    .C_WR_DEPTH_WACH(16),
    .C_WR_DEPTH_WDCH(1024),
    .C_WR_DEPTH_WRCH(16),
    .C_WR_DEPTH_RACH(16),
    .C_WR_DEPTH_RDCH(1024),
    .C_WR_DEPTH_AXIS(1024),
    .C_WR_PNTR_WIDTH_WACH(4),
    .C_WR_PNTR_WIDTH_WDCH(10),
    .C_WR_PNTR_WIDTH_WRCH(4),
    .C_WR_PNTR_WIDTH_RACH(4),
    .C_WR_PNTR_WIDTH_RDCH(10),
    .C_WR_PNTR_WIDTH_AXIS(10),
    .C_HAS_DATA_COUNTS_WACH(0),
    .C_HAS_DATA_COUNTS_WDCH(0),
    .C_HAS_DATA_COUNTS_WRCH(0),
    .C_HAS_DATA_COUNTS_RACH(0),
    .C_HAS_DATA_COUNTS_RDCH(0),
    .C_HAS_DATA_COUNTS_AXIS(0),
    .C_HAS_PROG_FLAGS_WACH(0),
    .C_HAS_PROG_FLAGS_WDCH(0),
    .C_HAS_PROG_FLAGS_WRCH(0),
    .C_HAS_PROG_FLAGS_RACH(0),
    .C_HAS_PROG_FLAGS_RDCH(0),
    .C_HAS_PROG_FLAGS_AXIS(0),
    .C_PROG_FULL_TYPE_WACH(0),
    .C_PROG_FULL_TYPE_WDCH(0),
    .C_PROG_FULL_TYPE_WRCH(0),
    .C_PROG_FULL_TYPE_RACH(0),
    .C_PROG_FULL_TYPE_RDCH(0),
    .C_PROG_FULL_TYPE_AXIS(0),
    .C_PROG_FULL_THRESH_ASSERT_VAL_WACH(1023),
    .C_PROG_FULL_THRESH_ASSERT_VAL_WDCH(1023),
    .C_PROG_FULL_THRESH_ASSERT_VAL_WRCH(1023),
    .C_PROG_FULL_THRESH_ASSERT_VAL_RACH(1023),
    .C_PROG_FULL_THRESH_ASSERT_VAL_RDCH(1023),
    .C_PROG_FULL_THRESH_ASSERT_VAL_AXIS(1023),
    .C_PROG_EMPTY_TYPE_WACH(0),
    .C_PROG_EMPTY_TYPE_WDCH(0),
    .C_PROG_EMPTY_TYPE_WRCH(0),
    .C_PROG_EMPTY_TYPE_RACH(0),
    .C_PROG_EMPTY_TYPE_RDCH(0),
    .C_PROG_EMPTY_TYPE_AXIS(0),
    .C_PROG_EMPTY_THRESH_ASSERT_VAL_WACH(1022),
    .C_PROG_EMPTY_THRESH_ASSERT_VAL_WDCH(1022),
    .C_PROG_EMPTY_THRESH_ASSERT_VAL_WRCH(1022),
    .C_PROG_EMPTY_THRESH_ASSERT_VAL_RACH(1022),
    .C_PROG_EMPTY_THRESH_ASSERT_VAL_RDCH(1022),
    .C_PROG_EMPTY_THRESH_ASSERT_VAL_AXIS(1022),
    .C_REG_SLICE_MODE_WACH(0),
    .C_REG_SLICE_MODE_WDCH(0),
    .C_REG_SLICE_MODE_WRCH(0),
    .C_REG_SLICE_MODE_RACH(0),
    .C_REG_SLICE_MODE_RDCH(0),
    .C_REG_SLICE_MODE_AXIS(0)
  ) inst (
    .backup(1'D0),
    .backup_marker(1'D0),
    .clk(1'D0),
    .rst(rst),
    .srst(1'D0),
    .wr_clk(wr_clk),
    .wr_rst(1'D0),
    .rd_clk(rd_clk),
    .rd_rst(1'D0),
    .din(din),
    .wr_en(wr_en),
    .rd_en(rd_en),
    .prog_empty_thresh(4'B0),
    .prog_empty_thresh_assert(4'B0),
    .prog_empty_thresh_negate(4'B0),
    .prog_full_thresh(4'B0),
    .prog_full_thresh_assert(4'B0),
    .prog_full_thresh_negate(4'B0),
    .int_clk(1'D0),
    .injectdbiterr(1'D0),
    .injectsbiterr(1'D0),
    .sleep(1'D0),
    .dout(dout),
    .full(full),
    .almost_full(),
    .wr_ack(wr_ack),
    .overflow(overflow),
    .empty(empty),
    .almost_empty(),
    .valid(valid),
    .underflow(underflow),
    .data_count(),
    .rd_data_count(rd_data_count),
    .wr_data_count(wr_data_count),
    .prog_full(),
    .prog_empty(),
    .sbiterr(),
    .dbiterr(),
    .wr_rst_busy(),
    .rd_rst_busy(),
    .m_aclk(1'D0),
    .s_aclk(1'D0),
    .s_aresetn(1'D0),
    .m_aclk_en(1'D0),
    .s_aclk_en(1'D0),
    .s_axi_awid(1'B0),
    .s_axi_awaddr(32'B0),
    .s_axi_awlen(8'B0),
    .s_axi_awsize(3'B0),
    .s_axi_awburst(2'B0),
    .s_axi_awlock(1'B0),
    .s_axi_awcache(4'B0),
    .s_axi_awprot(3'B0),
    .s_axi_awqos(4'B0),
    .s_axi_awregion(4'B0),
    .s_axi_awuser(1'B0),
    .s_axi_awvalid(1'D0),
    .s_axi_awready(),
    .s_axi_wid(1'B0),
    .s_axi_wdata(64'B0),
    .s_axi_wstrb(8'B0),
    .s_axi_wlast(1'D0),
    .s_axi_wuser(1'B0),
    .s_axi_wvalid(1'D0),
    .s_axi_wready(),
    .s_axi_bid(),
    .s_axi_bresp(),
    .s_axi_buser(),
    .s_axi_bvalid(),
    .s_axi_bready(1'D0),
    .m_axi_awid(),
    .m_axi_awaddr(),
    .m_axi_awlen(),
    .m_axi_awsize(),
    .m_axi_awburst(),
    .m_axi_awlock(),
    .m_axi_awcache(),
    .m_axi_awprot(),
    .m_axi_awqos(),
    .m_axi_awregion(),
    .m_axi_awuser(),
    .m_axi_awvalid(),
    .m_axi_awready(1'D0),
    .m_axi_wid(),
    .m_axi_wdata(),
    .m_axi_wstrb(),
    .m_axi_wlast(),
    .m_axi_wuser(),
    .m_axi_wvalid(),
    .m_axi_wready(1'D0),
    .m_axi_bid(1'B0),
    .m_axi_bresp(2'B0),
    .m_axi_buser(1'B0),
    .m_axi_bvalid(1'D0),
    .m_axi_bready(),
    .s_axi_arid(1'B0),
    .s_axi_araddr(32'B0),
    .s_axi_arlen(8'B0),
    .s_axi_arsize(3'B0),
    .s_axi_arburst(2'B0),
    .s_axi_arlock(1'B0),
    .s_axi_arcache(4'B0),
    .s_axi_arprot(3'B0),
    .s_axi_arqos(4'B0),
    .s_axi_arregion(4'B0),
    .s_axi_aruser(1'B0),
    .s_axi_arvalid(1'D0),
    .s_axi_arready(),
    .s_axi_rid(),
    .s_axi_rdata(),
    .s_axi_rresp(),
    .s_axi_rlast(),
    .s_axi_ruser(),
    .s_axi_rvalid(),
    .s_axi_rready(1'D0),
    .m_axi_arid(),
    .m_axi_araddr(),
    .m_axi_arlen(),
    .m_axi_arsize(),
    .m_axi_arburst(),
    .m_axi_arlock(),
    .m_axi_arcache(),
    .m_axi_arprot(),
    .m_axi_arqos(),
    .m_axi_arregion(),
    .m_axi_aruser(),
    .m_axi_arvalid(),
    .m_axi_arready(1'D0),
    .m_axi_rid(1'B0),
    .m_axi_rdata(64'B0),
    .m_axi_rresp(2'B0),
    .m_axi_rlast(1'D0),
    .m_axi_ruser(1'B0),
    .m_axi_rvalid(1'D0),
    .m_axi_rready(),
    .s_axis_tvalid(1'D0),
    .s_axis_tready(),
    .s_axis_tdata(8'B0),
    .s_axis_tstrb(1'B0),
    .s_axis_tkeep(1'B0),
    .s_axis_tlast(1'D0),
    .s_axis_tid(1'B0),
    .s_axis_tdest(1'B0),
    .s_axis_tuser(4'B0),
    .m_axis_tvalid(),
    .m_axis_tready(1'D0),
    .m_axis_tdata(),
    .m_axis_tstrb(),
    .m_axis_tkeep(),
    .m_axis_tlast(),
    .m_axis_tid(),
    .m_axis_tdest(),
    .m_axis_tuser(),
    .axi_aw_injectsbiterr(1'D0),
    .axi_aw_injectdbiterr(1'D0),
    .axi_aw_prog_full_thresh(4'B0),
    .axi_aw_prog_empty_thresh(4'B0),
    .axi_aw_data_count(),
    .axi_aw_wr_data_count(),
    .axi_aw_rd_data_count(),
    .axi_aw_sbiterr(),
    .axi_aw_dbiterr(),
    .axi_aw_overflow(),
    .axi_aw_underflow(),
    .axi_aw_prog_full(),
    .axi_aw_prog_empty(),
    .axi_w_injectsbiterr(1'D0),
    .axi_w_injectdbiterr(1'D0),
    .axi_w_prog_full_thresh(10'B0),
    .axi_w_prog_empty_thresh(10'B0),
    .axi_w_data_count(),
    .axi_w_wr_data_count(),
    .axi_w_rd_data_count(),
    .axi_w_sbiterr(),
    .axi_w_dbiterr(),
    .axi_w_overflow(),
    .axi_w_underflow(),
    .axi_w_prog_full(),
    .axi_w_prog_empty(),
    .axi_b_injectsbiterr(1'D0),
    .axi_b_injectdbiterr(1'D0),
    .axi_b_prog_full_thresh(4'B0),
    .axi_b_prog_empty_thresh(4'B0),
    .axi_b_data_count(),
    .axi_b_wr_data_count(),
    .axi_b_rd_data_count(),
    .axi_b_sbiterr(),
    .axi_b_dbiterr(),
    .axi_b_overflow(),
    .axi_b_underflow(),
    .axi_b_prog_full(),
    .axi_b_prog_empty(),
    .axi_ar_injectsbiterr(1'D0),
    .axi_ar_injectdbiterr(1'D0),
    .axi_ar_prog_full_thresh(4'B0),
    .axi_ar_prog_empty_thresh(4'B0),
    .axi_ar_data_count(),
    .axi_ar_wr_data_count(),
    .axi_ar_rd_data_count(),
    .axi_ar_sbiterr(),
    .axi_ar_dbiterr(),
    .axi_ar_overflow(),
    .axi_ar_underflow(),
    .axi_ar_prog_full(),
    .axi_ar_prog_empty(),
    .axi_r_injectsbiterr(1'D0),
    .axi_r_injectdbiterr(1'D0),
    .axi_r_prog_full_thresh(10'B0),
    .axi_r_prog_empty_thresh(10'B0),
    .axi_r_data_count(),
    .axi_r_wr_data_count(),
    .axi_r_rd_data_count(),
    .axi_r_sbiterr(),
    .axi_r_dbiterr(),
    .axi_r_overflow(),
    .axi_r_underflow(),
    .axi_r_prog_full(),
    .axi_r_prog_empty(),
    .axis_injectsbiterr(1'D0),
    .axis_injectdbiterr(1'D0),
    .axis_prog_full_thresh(10'B0),
    .axis_prog_empty_thresh(10'B0),
    .axis_data_count(),
    .axis_wr_data_count(),
    .axis_rd_data_count(),
    .axis_sbiterr(),
    .axis_dbiterr(),
    .axis_overflow(),
    .axis_underflow(),
    .axis_prog_full(),
    .axis_prog_empty()
  );
endmodule


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


module rle_encoder_beh 
(
    input clk,
    input rst,
    input ready,
    input [DATA_WIDTH - 1: 0] stream_in,
    output reg [DATA_WIDTH + CTR_WIDTH - 1 :0] compressed_stream,
    output reg valid
); 

parameter DATA_WIDTH = 2,
          CTR_WIDTH = 1;
    
localparam CTR_MAX = (1<<CTR_WIDTH) - 1;     
    
reg [DATA_WIDTH-1:0] stream_in_prev;
reg [CTR_WIDTH:0] seq_counter = 0;
reg ready_prev;
    
initial begin
    $display("CTR MAX=%d, DATA WIDTH=%d, CTR WIDTH=%d", CTR_MAX, DATA_WIDTH, CTR_WIDTH);
end
    
always @(posedge clk)    
begin
    stream_in_prev <= stream_in; 
    ready_prev <= ready;
    if (ready_prev & ready) begin 
        if (!rst) begin
            valid <= 1'b0;
            compressed_stream <= 0;
        end else begin
            if (stream_in == stream_in_prev) begin
                if (seq_counter != CTR_MAX) begin
                    valid <= 1'b0;
                    seq_counter <= seq_counter + 1;
                end else begin
                    valid <= 1'b1;
                    compressed_stream <= {seq_counter[CTR_WIDTH-1:0], stream_in_prev};
                    seq_counter <= 0;
                end
            end else begin
                valid <= 1'b1;
                compressed_stream <= {seq_counter[CTR_WIDTH-1:0], stream_in_prev};
                seq_counter <= 0;
            end
        end
    end else begin
        valid <= 1'b0;
    end
end   
    
endmodule


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

module clk_wiz_0_clk_wiz 

 (// Clock in ports
  // Clock out ports
  output        clk_400MHz,
  input         clk_100MHz
 );
  // Input buffering
  //------------------------------------
wire clk_100MHz_clk_wiz_0;
wire clk_in2_clk_wiz_0;
  IBUF clkin1_ibufg
   (.O (clk_100MHz_clk_wiz_0),
    .I (clk_100MHz));




  // Clocking PRIMITIVE
  //------------------------------------

  // Instantiation of the MMCM PRIMITIVE
  //    * Unused inputs are tied off
  //    * Unused outputs are labeled unused

  wire        clk_400MHz_clk_wiz_0;
  wire        clk_out2_clk_wiz_0;
  wire        clk_out3_clk_wiz_0;
  wire        clk_out4_clk_wiz_0;
  wire        clk_out5_clk_wiz_0;
  wire        clk_out6_clk_wiz_0;
  wire        clk_out7_clk_wiz_0;

  wire [15:0] do_unused;
  wire        drdy_unused;
  wire        psdone_unused;
  wire        locked_int;
  wire        clkfbout_clk_wiz_0;
  wire        clkfbout_buf_clk_wiz_0;
  wire        clkfboutb_unused;
    wire clkout0b_unused;
   wire clkout1_unused;
   wire clkout1b_unused;
   wire clkout2_unused;
   wire clkout2b_unused;
   wire clkout3_unused;
   wire clkout3b_unused;
   wire clkout4_unused;
  wire        clkout5_unused;
  wire        clkout6_unused;
  wire        clkfbstopped_unused;
  wire        clkinstopped_unused;

  MMCME2_ADV
  #(.BANDWIDTH            ("OPTIMIZED"),
    .CLKOUT4_CASCADE      ("FALSE"),
    .COMPENSATION         ("ZHOLD"),
    .STARTUP_WAIT         ("FALSE"),
    .DIVCLK_DIVIDE        (1),
    .CLKFBOUT_MULT_F      (10.000),
    .CLKFBOUT_PHASE       (0.000),
    .CLKFBOUT_USE_FINE_PS ("FALSE"),
    .CLKOUT0_DIVIDE_F     (2.500),
    .CLKOUT0_PHASE        (0.000),
    .CLKOUT0_DUTY_CYCLE   (0.500),
    .CLKOUT0_USE_FINE_PS  ("FALSE"),
    .CLKIN1_PERIOD        (10.000))
  mmcm_adv_inst
    // Output clocks
   (
    .CLKFBOUT            (clkfbout_clk_wiz_0),
    .CLKFBOUTB           (clkfboutb_unused),
    .CLKOUT0             (clk_400MHz_clk_wiz_0),
    .CLKOUT0B            (clkout0b_unused),
    .CLKOUT1             (clkout1_unused),
    .CLKOUT1B            (clkout1b_unused),
    .CLKOUT2             (clkout2_unused),
    .CLKOUT2B            (clkout2b_unused),
    .CLKOUT3             (clkout3_unused),
    .CLKOUT3B            (clkout3b_unused),
    .CLKOUT4             (clkout4_unused),
    .CLKOUT5             (clkout5_unused),
    .CLKOUT6             (clkout6_unused),
     // Input clock control
    .CLKFBIN             (clkfbout_buf_clk_wiz_0),
    .CLKIN1              (clk_100MHz_clk_wiz_0),
    .CLKIN2              (1'b0),
     // Tied to always select the primary input clock
    .CLKINSEL            (1'b1),
    // Ports for dynamic reconfiguration
    .DADDR               (7'h0),
    .DCLK                (1'b0),
    .DEN                 (1'b0),
    .DI                  (16'h0),
    .DO                  (do_unused),
    .DRDY                (drdy_unused),
    .DWE                 (1'b0),
    // Ports for dynamic phase shift
    .PSCLK               (1'b0),
    .PSEN                (1'b0),
    .PSINCDEC            (1'b0),
    .PSDONE              (psdone_unused),
    // Other control and status signals
    .LOCKED              (locked_int),
    .CLKINSTOPPED        (clkinstopped_unused),
    .CLKFBSTOPPED        (clkfbstopped_unused),
    .PWRDWN              (1'b0),
    .RST                 (1'b0));

// Clock Monitor clock assigning
//--------------------------------------
 // Output buffering
  //-----------------------------------

  BUFG clkf_buf
   (.O (clkfbout_buf_clk_wiz_0),
    .I (clkfbout_clk_wiz_0));






  BUFG clkout1_buf
   (.O   (clk_400MHz),
    .I   (clk_400MHz_clk_wiz_0));




endmodule



module RLE_encoder_system(
    input wire clk,
    input wire clk_400MHz,
    input wire rst,
    input wire wr_en,
    input wire rd_en,
    input wire [31:0] ASCII_package_in,
    output wire [15:0] output_data
);
    
wire [7:0] nucleotide_ASCII_single;

unpackager unpackager (
    .clk(clk),
    .clk_400MHz(clk_400MHz),
    .rst(rst),
    .wr_en(wr_en),
    .rd_en(rd_en),
    .ASCII_package_in(ASCII_package_in),
    .ASCII_char(nucleotide_ASCII_single)
);

wire [1:0] nucleotide_code_single;
wire valid_nucleo_code;

nucleo_encoder nucleo_enc (
    .clk(clk_400MHz),
    .rst(rst),
    .nucleotide_ASCII(nucleotide_ASCII_single),
    .valid(valid_nucleo_code),
    .nucleotide_code(nucleotide_code_single)
);

wire [2:0] compressed_stream;
wire valid;

rle_encoder_beh #(.DATA_WIDTH(2),.CTR_WIDTH(1)) RLE_enc ( 
    .clk(clk_400MHz),
    .rst(rst),
    .ready(valid_nucleo_code),
    .stream_in(nucleotide_code_single),
    .compressed_stream(compressed_stream),
    .valid(valid)
);
    
packager packager (
    .clk(clk),
    .clk_400MHz(clk_400MHz),
    .rst(rst),
    .compressed_stream(compressed_stream),
    .ready(valid),
    .output_data(output_data)
);
    
endmodule

module top(
    input wire clk,
    input wire rst,
    input wire wr_en,
    input wire rd_en,
    input wire [31:0] nucleotide_ASCII_package,
    output wire [15:0] output_data
);

wire clk_400MHz;

clk_wiz_0_clk_wiz clk_divider   (
    .clk_100MHz(clk),
    .clk_400MHz(clk_400MHz)
);

RLE_encoder_system RLE_encoder_system_IP (
    .clk(clk),
    .clk_400MHz(clk_400MHz),
    .rst(rst),
    .wr_en(wr_en),
    .rd_en(rd_en),
    .ASCII_package_in(nucleotide_ASCII_package),
    .output_data(output_data)
);

endmodule