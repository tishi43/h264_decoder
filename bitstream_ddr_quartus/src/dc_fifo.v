//--------------------------------------------------------------------------------------------------
// Design    : bitstream_p
// Author(s) : qiu bin, shi tian qi
// Email     : chat1@126.com, tishi1@126.com
// Copyright (C) 2013 qiu bin 
// All rights reserved                
//-------------------------------------------------------------------------------------------------


module dc_fifo
(
	aclr,

	wr_clk,
	wr,
	data_in,
	afull,
		
	rd_clk,
	rd,
	data_out,
	nword,
	valid
);
parameter addr_bits = 7;
parameter data_bits = 16;
input  aclr;
input  wr_clk;
input  wr;
input  [data_bits-1:0] data_in;
output afull;

input  rd_clk;
input  rd;
output [data_bits-1:0] data_out;
output [addr_bits-1:0] nword;
output valid;

reg [data_bits-1:0] data_out;

reg [addr_bits-1:0] wr_addr;
reg [data_bits-1:0] wr_data[0: (1 << addr_bits) - 1];

reg [addr_bits-1:0] rd_addr;
reg [addr_bits-1:0] wr_addr_s;
reg [addr_bits-1:0] nword;
reg afull;
reg valid;


always @(posedge wr_clk)
if (aclr) 
	wr_addr <= 0;
else if (wr && (wr_addr != rd_addr - 1)) begin
	wr_addr <= wr_addr + 1;
	wr_data[wr_addr] <= data_in;
end

always @(posedge rd_clk or posedge aclr)
if (aclr)
	wr_addr_s <= 0;
else 
	wr_addr_s <= wr_addr;

always @(posedge rd_clk or posedge aclr)
if (aclr)
	nword <= 0;
else 
	nword <= wr_addr_s > rd_addr ? wr_addr_s - rd_addr : wr_addr_s + (1 << addr_bits)- rd_addr ;

always @(posedge rd_clk or posedge aclr)
if (aclr) begin
	rd_addr <= 0;
	data_out <= 0;
end
else if (rd && wr_addr_s != rd_addr) begin
	rd_addr <= rd_addr + 1;
	data_out <= wr_data[rd_addr];
end

always @(*)
if (wr_addr_s != rd_addr)
	valid <= 1;
else
	valid <= 0;
	
always @(posedge rd_clk or posedge aclr)
if (aclr) begin
	afull = 0;
end
else begin
	afull = (1 << addr_bits) - nword < 8;
end

//synopsys translate_off
always @(posedge wr_clk)
if (wr && (wr_addr == rd_addr - 1))
	$display("%t : %m, write while fifo is full", $time);

always @(posedge rd_clk)
if (rd && wr_addr_s == rd_addr)
	$display("%t : %m, read while fifo is empty", $time);

always @(posedge rd_clk)
if (rd && wr)
	$display("%t : %m, read during write", $time);
//synopsys translate_on

endmodule
