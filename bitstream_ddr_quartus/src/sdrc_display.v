//--------------------------------------------------------------------------------------------------
// Design    : bitstream_p
// Author(s) : qiu bin, shi tian qi
// Email     : chat1@126.com, tishi1@126.com
// Copyright (C) 2013 qiu bin 
// All rights reserved                
//-------------------------------------------------------------------------------------------------


`include "defines.v"

module sdrc_display
(
    clk,
    dec_clk,
    vga_clk,
    rst_n,
    
    init_done,
	burst,
	burst_len_minus1,
	addr,
	wr,
	d,
	full,
	
	y_addr,
	u_addr,
	v_addr,
	display_addr_load,
	vga_valid,
	y_rd,
	uv_rd,
	y_data,
	u_data,
	v_data,

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

input           clk;      
input           rst_n;
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
inout           ddr_clk;
inout           ddr_clk_n;

input	dec_clk;
input   vga_clk;

output init_done;
input  burst;
input [4:0] burst_len_minus1;
input [`ext_buf_mem_addr_width-1:0] addr;
input wr;
input  [`ext_buf_mem_data_width-1:0] d;
output full;

input [`ext_buf_mem_addr_width-1:0] y_addr;
input [`ext_buf_mem_addr_width-1:0] u_addr;
input [`ext_buf_mem_addr_width-1:0] v_addr;
input								display_addr_load;
input 			vga_valid;
input				y_rd;
input				uv_rd;
output [31:0]		y_data;
output [31:0]		u_data;
output [31:0]		v_data;
                
wire sdrc_act;
wire [`ext_buf_mem_addr_width+5:0] sdrc_cmd;
wire [`ext_buf_mem_data_width-1:0] sdrc_data_in;

reg sdrc_burst_idle;
reg [4:0] rw_len;
reg [4:0] read_len;
reg [`ext_buf_mem_addr_width-3:0] addr_display;	
reg [4:0] burst_len_minus1_display;
wire sdrc_data_in_req;
reg read_req;
reg [2:0] rd_mask;

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
	local_address = sdrc_cmd[`ext_buf_mem_addr_width+5] ? sdrc_cmd[`ext_buf_mem_addr_width-2:2] :
                                      addr_display[`ext_buf_mem_addr_width-4:0];
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

assign sdrc_data_in_req = !sdrc_burst_idle && local_ready && local_write_req;
sdrc_display_ctrl sdrc_display_ctrl
(
	.host_clk(dec_clk),
	.sdrc_clk(phy_clk),
	.rst_n(rst_n),
	.burst(burst),
	.read_req(read_req),
	.burst_len_minus1(burst_len_minus1),
	.addr(addr),
	.wr(wr),
	.d(d),
	.full(full),
	
	.sdrc_act(sdrc_act),
	.sdrc_cmd(sdrc_cmd),
	.sdrc_data_in(sdrc_data_in),
	.sdrc_data_in_req(sdrc_data_in_req),
	
	.sdrc_ready(sdrc_burst_idle)
);

always @(posedge phy_clk or negedge rst_n)
if (!rst_n)
	rw_len <= 0;
else if (sdrc_act)
	rw_len <= 0;
else if ((local_read_req || local_write_req) && local_ready && !sdrc_burst_idle)
	rw_len <= rw_len + 1;

wire rw_done;
assign rw_done = local_ready && local_write_req && rw_len == sdrc_cmd[`ext_buf_mem_addr_width+4:`ext_buf_mem_addr_width] ||
                 local_ready && local_read_req && rw_len == burst_len_minus1_display;


wire read_done;
assign read_done = local_rdata_valid && read_len == burst_len_minus1_display;

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

//////////////////////////////////////////////
reg [`ext_buf_mem_addr_width-3:0] y_addr_reg;
reg [`ext_buf_mem_addr_width-3:0] u_addr_reg;
reg [`ext_buf_mem_addr_width-3:0] v_addr_reg;
wire [3:0] y_fifo_nword;
wire [3:0] u_fifo_nword;
wire [3:0] v_fifo_nword;
wire       y_fifo_rdempty;
wire       u_fifo_rdempty;
wire       v_fifo_rdempty;
reg [5:0] rd_req_list;
reg [2:0] rd_req_id;
reg read_ena;
reg vga_valid_d;

pixel_fifo y_fifo(
	.aclr(display_addr_load),
	.data(local_rdata),
	.rdclk(vga_clk),
	.rdreq(y_rd),
	.wrclk(phy_clk),
	.wrreq(local_rdata_valid&&rd_req_list[1:0] == 1),
	.q(y_data),
	.rdempty(y_fifo_rdempty),
	.wrusedw(y_fifo_nword),
	.wrfull()
);
	
pixel_fifo u_fifo(
	.aclr(display_addr_load),
	.data(local_rdata),
	.rdclk(vga_clk),
	.rdreq(uv_rd),
	.wrclk(phy_clk),
	.wrreq(local_rdata_valid&&rd_req_list[3:2] == 1),
	.q(u_data),
	.rdempty(u_fifo_rdempty),
	.wrusedw(u_fifo_nword),
	.wrfull()
);

pixel_fifo v_fifo(
	.aclr(display_addr_load),
	.data(local_rdata),
	.rdclk(vga_clk),
	.rdreq(uv_rd),
	.wrclk(phy_clk),
	.wrreq(local_rdata_valid&&rd_req_list[5:4] == 1),
	.q(v_data),
	.rdempty(v_fifo_rdempty),
	.wrusedw(v_fifo_nword),
	.wrfull()
);
	
always @(posedge phy_clk or negedge rst_n)
if (!rst_n) begin
	y_addr_reg <= 0;
	u_addr_reg <= 0;
	v_addr_reg <= 0;
end
else begin
	if(display_addr_load)
		y_addr_reg	<=	y_addr[`ext_buf_mem_addr_width-1:2];
	else if(local_read_req && rw_done & rd_mask[0])
		y_addr_reg	<=	y_addr_reg + 4;
	if(display_addr_load)
		u_addr_reg	<=	u_addr[`ext_buf_mem_addr_width-1:2];
	else if(local_read_req && rw_done & rd_mask[1])
		u_addr_reg	<=	u_addr_reg + 4;
	if(display_addr_load)
		v_addr_reg	<=	v_addr[`ext_buf_mem_addr_width-1:2];
	else if(local_read_req && rw_done & rd_mask[2])
		v_addr_reg	<=	v_addr_reg + 4;
end

always @(posedge vga_clk or negedge rst_n)
if (!rst_n) begin
	read_ena <= 0;
	vga_valid_d <= 0;
end
else begin
	vga_valid_d <= vga_valid;
	if (display_addr_load)
		read_ena <= 1;
	else if (vga_valid_d && !vga_valid)
	   read_ena <= 0; 
end
		
always @ (posedge phy_clk or negedge rst_n)
if (!rst_n) begin
	addr_display				<=	0;
	read_req              		<=  0;
	burst_len_minus1_display	<=	0;
	rd_mask						<=	3'b000;
	rd_req_list					<= 0;
	rd_req_id                   <= 1;
end
else begin
	if(read_req == 0 && init_done && read_ena && !read_done)begin
		if(rd_req_list[1:0] == 0 && y_fifo_nword < 8) begin
			addr_display				<=	y_addr_reg;
			read_req 					<=  1;
			burst_len_minus1_display	<=	3;
			rd_mask						<=	3'b001;
			rd_req_list[1:0]            <=  rd_req_id;
			rd_req_id                   <=  rd_req_id + 1;
		end
		else if(rd_req_list[3:2] == 0 && u_fifo_nword < 8 && u_fifo_nword < v_fifo_nword) begin
			addr_display				<=	u_addr_reg;
			read_req 					<=  1;
			burst_len_minus1_display	<=	3;
			rd_mask						<=	3'b010;
			rd_req_list[3:2]            <=  rd_req_id;
			rd_req_id                   <=  rd_req_id + 1;
		end
		else if(rd_req_list[5:4] == 0 && v_fifo_nword < 8) begin
			addr_display				<=	v_addr_reg;
			read_req 					<=  1;
			burst_len_minus1_display	<=	3;
			rd_mask						<=	3'b100;
			rd_req_list[5:4]            <=  rd_req_id;
			rd_req_id                   <=  rd_req_id + 1;
		end
	end
	if (local_read_req && rw_done && rd_mask != 0) begin
		//addr_display				<=	0;
		read_req                    <=  0;
		//burst_len_minus1_display	<=	0;
		rd_mask						<=	3'b000;
	end
	if (read_done) begin
		rd_req_id                   <=  rd_req_id - 1;
		if (rd_req_list[1:0])
			rd_req_list[1:0] <= rd_req_list[1:0] - 1;
		if (rd_req_list[3:2])
			rd_req_list[3:2] <= rd_req_list[3:2] - 1;
		if (rd_req_list[5:4])
			rd_req_list[5:4] <= rd_req_list[5:4] - 1;
	end
end

//synthesis translate_off
always @(posedge vga_clk)
if (y_rd && y_fifo_rdempty)
	$display("%t : read while y_fifo is empty", $time);

always @(posedge vga_clk)
if (uv_rd && u_fifo_rdempty)
	$display("%t : read while u_fifo is empty", $time);
	
always @(posedge vga_clk)
if (uv_rd && v_fifo_rdempty)
	$display("%t : read while v_fifo is empty", $time);
//synthesis translate_on

endmodule
