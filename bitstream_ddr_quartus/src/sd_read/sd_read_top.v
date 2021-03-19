//--------------------------------------------------------------------------------------------------
// Design    : bitstream_p
// Author(s) : qiu bin, shi tian qi
// Email     : chat1@126.com, tishi1@126.com
// Copyright (C) 2013 qiu bin 
// All rights researved                
//-------------------------------------------------------------------------------------------------


// synopsys translate_off
`include "timescale.v"
// synopsys translate_on

module sd_read_top(
    clk0,
    rst_n,

    sck_o,  
    mosi_o, 
    miso_i, 
    csn_o,
    
	file_read_req,
	file_data,
	file_data_valid,
	file_reach_end
); 

input clk0;
input rst_n;

output      sck_o;  	//sd card spi clock
output      mosi_o; 	//sd card spi data in
input       miso_i; 	//sd card spi data out
output 	    csn_o; 		//sd card spi chip select

input file_read_req;	//request read 512 bytes from file
output [7:0] file_data; //file data output
output file_data_valid; //file data valid
output file_reach_end;  //end of file reached

wire clk_i;
assign clk_i = clk0;

reg			rst_r;
reg			rst_i;

always @(posedge clk_i or negedge rst_n)
	if (~rst_n)
		rst_r <= 1'b1;
	else
		rst_r <= #1 1'b0;

always @(posedge clk_i)
	rst_i <= #1 rst_r;	   
		
//
// spiMaster core slave i/f wires
//
wire[7:0]		spi_master_addr_i;
wire[7:0]   	spi_master_data_i;
wire[7:0]   	spi_master_data_o;
wire			spi_master_stb_i;
wire			spi_master_we_i;
wire			spi_master_ack_o;
spiMaster u_spiMaster (
 
  .clk_i     (clk_i),
  .rst_i     (rst_i),
  .address_i (spi_master_addr_i),
  .data_i    (spi_master_data_i),
  .data_o    (spi_master_data_o),
  .strobe_i  (spi_master_stb_i),
  .we_i      (spi_master_we_i),
  .ack_o     (spi_master_ack_o),

 
  .spiSysClk  (clk0),
  .spiClkOut  (sck_o    ),
  .spiDataIn  (miso_i   ),
  .spiDataOut (mosi_o   ),
  .spiCS_n    (csn_o    )
);

wire init_done;
wire sector_rd_start;
wire [22:0] sector_rd_addr;
wire [8:0]  addr_o;
wire [7:0]  data_o;
wire wr_o;
wire reading;
wire read_done;
spi_master_ctrl spi_master_ctrl(	
	.wb_clk_i  ( clk_i         ),
	.wb_rst_i  ( rst_i         ),
	.wb_adr_o  ( spi_master_addr_i),
	.wb_dat_i  ( spi_master_data_o),
	.wb_dat_o  ( spi_master_data_i),
	.wb_we_o   ( spi_master_we_i ), 
	.wb_stb_o  ( spi_master_stb_i),
	.wb_ack_i  ( spi_master_ack_o),
	
	.init_done(init_done),
	.sector_rd_start(sector_rd_start),
	.sector_rd_addr(sector_rd_addr),
	.addr_o(addr_o),
	.data_o(data_o),
	.wr_o(wr_o),
	.reading(reading),
	.read_done(read_done)
);

fat32_read_file fat32_read_file
(
	.clk(clk_i),
	.rst(rst_i),
	
	.init_done(init_done),
	.sector_rd_start(sector_rd_start),
	.sector_rd_addr(sector_rd_addr),
	.addr_i(addr_o),
	.data_i(data_o),
	.wr_i(wr_o),
	.reading(reading),
	.read_done(read_done),
	.file_reach_end(file_reach_end),
	
	.file_read_req(file_read_req),
	.file_data(file_data),
	.file_data_valid(file_data_valid)
);
endmodule
