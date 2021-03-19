//--------------------------------------------------------------------------------------------------
// Design    : bitstream_p
// Author(s) : qiu bin, shi tian qi
// Email     : chat1@126.com, tishi1@126.com
// Copyright (C) 2013 qiu bin 
// All rights reserved                
//-------------------------------------------------------------------------------------------------


`include "defines.v"

module sdrc_buffer
(
    clk,
    dec_clk,
    rst_n,
    
 	init_done,
	burst,
	burst_len_minus1,
	addr,
	rd,
	wr,
	d,
	q,
	full,
	valid,

	ddr_data,
	ddr_dqs,
	ddr_dqm,
	ddr_ras_n,
	ddr_cas_n,
	ddr_we_n,  
	ddr_cs_n, 
	ddr_cke,  
	ddr_ba,
	ddr_addr,
	ddr_clk,
	ddr_clk_n
);
input          clk;      
input	         dec_clk;
input          rst_n;
inout  [15:0] 	ddr_data;
inout  [1:0]  	ddr_dqs; 
output [1:0]  	ddr_dqm;
output 			ddr_ras_n;
output 			ddr_cas_n;
output 			ddr_we_n;   
output 			ddr_cs_n; 
output 			ddr_cke;   
output [1:0]	ddr_ba;
output [12:0]	ddr_addr;
inout          ddr_clk;
inout          ddr_clk_n;

output init_done;
input  burst;
input [4:0] burst_len_minus1;
input [`ext_buf_mem_addr_width-1:0] addr;
input rd;
input wr;
input  [`ext_buf_mem_data_width-1:0] d;
output [`ext_buf_mem_data_width-1:0] q;
output full;
output valid;
      
wire sdrc_act;
wire [`ext_buf_mem_addr_width+5:0] sdrc_cmd;
wire [`ext_buf_mem_data_width-1:0] sdrc_data_in;
wire sdrc_data_in_req;
reg sdrc_burst_idle;
reg [4:0] rw_len;
reg [4:0] read_len;

reg                init_done;
reg    [22 :0]     local_address;
reg    [22 :0]     local_address_reg;
wire               init_done_wire;
wire               local_burstbegin;
wire               local_ready;
wire               local_read_req;
wire   [31 :0]     local_rdata;
wire               local_rdata_valid;
wire               local_write_req;
wire               phy_clk;


always @(posedge phy_clk or negedge rst_n)
if (!rst_n)
	local_address <= 0;
else if (sdrc_act)
	local_address = sdrc_cmd[`ext_buf_mem_addr_width-2:2];
else if ((local_read_req || local_write_req) && local_ready && !sdrc_burst_idle)
	local_address <= local_address + 1'b1;

always @(posedge phy_clk or negedge rst_n)
if (!rst_n)
	local_address_reg <= 0;
else
	local_address_reg <= local_address;
	
assign local_burstbegin = !sdrc_burst_idle && (local_address != local_address_reg || rw_len == 0);
assign local_read_req = sdrc_cmd[`ext_buf_mem_addr_width+5] == 0 && !sdrc_burst_idle;
assign local_write_req = sdrc_cmd[`ext_buf_mem_addr_width+5] == 1 && !sdrc_burst_idle;

always @(posedge phy_clk or negedge rst_n)
if (!rst_n)
	init_done <= 0;
else
	init_done <= init_done_wire;

ddr ddr_inst
(
  .aux_full_rate_clk (),
  .aux_half_rate_clk (),
  .global_reset_n (rst_n),
  .local_address (local_address),
  .local_be (4'b1111),
  .local_burstbegin (local_burstbegin),
  .local_init_done (init_done_wire),
  .local_rdata (local_rdata),
  .local_rdata_valid (local_rdata_valid),
  .local_read_req (local_read_req),
  .local_ready (local_ready),
  .local_refresh_ack (),
  .local_size (1'b1),
  .local_wdata (sdrc_data_in),
  .local_wdata_req (),
  .local_write_req (local_write_req),
  .mem_addr (ddr_addr),
  .mem_ba (ddr_ba),
  .mem_cas_n (ddr_cas_n),
  .mem_cke (ddr_cke),
  .mem_clk (ddr_clk),
  .mem_clk_n (ddr_clk_n),
  .mem_cs_n (ddr_cs_n),
  .mem_dm (ddr_dqm),
  .mem_dq (ddr_data),
  .mem_dqs (ddr_dqs),
  .mem_ras_n (ddr_ras_n),
  .mem_we_n (ddr_we_n),
  .phy_clk (phy_clk),
  .pll_ref_clk (clk),
  .reset_phy_clk_n (),
  .reset_request_n (),
  .soft_reset_n (1'b1)
);

wire read_done;
wire rw_done;
wire [6:0] fifo_read_info_data_out;
sdrc_buffer_ctrl sdrc_buffer_ctrl
(
	.host_clk(dec_clk),
	.sdrc_clk(phy_clk),
	.rst_n(rst_n),
	.burst(burst),
	.burst_len_minus1(burst_len_minus1),
	.addr(addr),
	.rd(rd),
	.wr(wr),
	.d(d),
	.q(q),
	.full(full),
	.valid(valid),
	
	.sdrc_act(sdrc_act),
	.sdrc_cmd(sdrc_cmd),
	.sdrc_data_in(sdrc_data_in),
	.sdrc_data_in_req(sdrc_data_in_req),
	
	.sdrc_ready(sdrc_burst_idle),
	.sdrc_read_done(read_done),
	.sdrc_data_out(local_rdata),
	.sdrc_data_out_valid(local_rdata_valid),
	.fifo_read_info_data_out (fifo_read_info_data_out)
);

always @(posedge phy_clk or negedge rst_n)
if (!rst_n)
	rw_len <= 0;
else if (sdrc_act)
	rw_len <= 0;
else if ((local_read_req || local_write_req) && local_ready && !sdrc_burst_idle)
	rw_len <= rw_len + 1;

assign sdrc_data_in_req = !sdrc_burst_idle && local_ready && local_write_req;

assign rw_done = local_ready && local_write_req && rw_len == sdrc_cmd[`ext_buf_mem_addr_width+4:`ext_buf_mem_addr_width] ||
                 local_ready && local_read_req && rw_len == sdrc_cmd[`ext_buf_mem_addr_width+4:`ext_buf_mem_addr_width] + 1;


assign read_done = local_rdata_valid && read_len == fifo_read_info_data_out[6:2] + 1;

always @(posedge phy_clk or negedge rst_n)
if (!rst_n)
	read_len <= 0;
else if (read_done)
	read_len <= 0;
else if (local_rdata_valid)
	read_len <= read_len + 1;

always @(posedge phy_clk or negedge rst_n)
if (!rst_n)
	sdrc_burst_idle <= 1;
else begin
	if (rw_done)
		sdrc_burst_idle <= 1;
	else if (sdrc_act)
		sdrc_burst_idle <= 0;
end

endmodule
