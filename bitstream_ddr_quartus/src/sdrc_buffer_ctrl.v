//--------------------------------------------------------------------------------------------------
// Design    : bitstream_p
// Author(s) : qiu bin, shi tian qi
// Email     : chat1@126.com, tishi1@126.com
// Copyright (C) 2013 qiu bin 
// All rights reserved                
//-------------------------------------------------------------------------------------------------


`include "defines.v"

module sdrc_buffer_ctrl
(
	host_clk,
	sdrc_clk,
	rst_n,
	burst,
	burst_len_minus1,
	addr,
	rd,
	wr,
	d,
	q,
	full,
	valid,
	
	//to sdrc
	sdrc_act,
	sdrc_cmd,
	sdrc_data_in,
	sdrc_data_in_req,
	
	sdrc_ready,
	sdrc_read_done,
	sdrc_data_out,
	sdrc_data_out_valid,
	fifo_read_info_data_out
);
input host_clk;
input sdrc_clk;
input rst_n;
input burst;
input [4:0] burst_len_minus1;
input [`ext_buf_mem_addr_width-1:0] addr;
input rd;
input wr;
input  [`ext_buf_mem_data_width-1:0] d;
output [`ext_buf_mem_data_width-1:0] q;
output full;
output valid;

output sdrc_act;
output [`ext_buf_mem_addr_width+5:0] sdrc_cmd;
output [`ext_buf_mem_data_width-1:0] sdrc_data_in;
input [`ext_buf_mem_data_width-1:0] sdrc_data_out;
input  sdrc_data_in_req;
input  sdrc_ready;
input  sdrc_read_done;
input  sdrc_data_out_valid;
output [6:0] fifo_read_info_data_out;

reg burst_s;
reg [2:0] cmd_state;
reg [`ext_buf_mem_addr_width+5:0] sdrc_cmd;

parameter
CmdIdle = 3'b000,
CmdWait1 = 3'b001,
CmdWait2 = 3'b011,
CmdWait3 = 3'b010,
CmdReadWait = 3'b110;

reg cmd_fifo_rd;
reg sdrc_act;
reg valid;

wire [`ext_buf_mem_addr_width+5:0] cmd_fifo_data_in;
assign cmd_fifo_data_in = rd ? {1'b0,burst_len_minus1,addr} : {1'b1,burst_len_minus1,addr};

//data format {read(1'b0)/write(1'b1),burst_len_minus1(5bits),addr(ext_buf_mem_addr_width bits)}
wire [`ext_buf_mem_addr_width+5:0] cmd_fifo_data_out;

//??burst???2???burst_length?8,addr?12????addr?12?addr?16??burst
reg [`ext_buf_mem_data_width-1:0] sdrc_data_out_reg;
reg [`ext_buf_mem_data_width-1:0] sdrc_data_out_tmp;


reg [`ext_buf_mem_data_width-1:0] read_burst2_addr;
reg [4:0] rd_len;
reg read_fifo_wr;

wire cmd_fifo_rd_empty;
wire cmd_fifo_full;
cmd_fifo cmd_fifo (
	.aclr(!rst_n),
	.data(cmd_fifo_data_in),
	.rdclk(sdrc_clk),
	.rdreq(cmd_fifo_rd),
	.wrclk(host_clk),
	.wrreq(burst_s),
	.q(cmd_fifo_data_out),
	.rdempty(cmd_fifo_rd_empty),
	.rdusedw(),
	.wrfull(cmd_fifo_full)
);

wire [6:0] fifo_read_info_data_out;
always @(*)
	read_fifo_wr = rd_len > 0 && rd_len <= fifo_read_info_data_out[6:2] + 1 && sdrc_data_out_valid;

fifo_read_info fifo_read_info (
	.clock(sdrc_clk),
	.data({cmd_fifo_data_out[`ext_buf_mem_addr_width+4:`ext_buf_mem_addr_width],cmd_fifo_data_out[1:0]}),
	.rdreq(sdrc_read_done),
	.wrreq(cmd_fifo_data_out[`ext_buf_mem_addr_width+5] == 1'b0 && sdrc_act),
	.empty(fifo_read_info_empty),
	.full(fifo_read_info_full),
	.q(fifo_read_info_data_out)
);

wire read_fifo_empty;
read_fifo read_fifo (
	.aclr(!rst_n),
	.data(sdrc_data_out_tmp),
	.rdclk(host_clk),
	.rdreq(rd),
	.wrclk(sdrc_clk),
	.wrreq(read_fifo_wr),
	.q(q),
	.rdempty(read_fifo_empty),
	.rdusedw(),
	.wrfull()
);

wire write_fifo_full;
wire [6:0] write_fifo_nword;
write_fifo write_fifo (
	.aclr(!rst_n),
	.data(d),
	.rdclk(sdrc_clk),
	.rdreq(sdrc_data_in_req),
	.wrclk(host_clk),
	.wrreq(wr),
	.q(sdrc_data_in),
	.rdempty(),
	.rdusedw(write_fifo_nword),
	.wrfull(write_fifo_full)
);

assign full = cmd_fifo_full || write_fifo_full;

always @(posedge host_clk or negedge rst_n)
if (!rst_n)
	burst_s <= 0;
else
	burst_s <= burst;

always @(posedge sdrc_clk or negedge rst_n)
if (!rst_n) begin
	cmd_state <= CmdIdle;
	cmd_fifo_rd <= 0;
	sdrc_act <= 0;
end
else begin
	case (cmd_state)
	CmdIdle : begin
		if (cmd_fifo_rd_empty != 1 && sdrc_ready) begin
			cmd_state <= CmdWait1;
			cmd_fifo_rd <= 1;
		end
	end
	CmdWait1 : begin
		cmd_fifo_rd <= 0;
		cmd_state <= CmdWait2;
	end
	CmdWait2 : begin
		cmd_fifo_rd <= 0;
		if (cmd_fifo_data_out[`ext_buf_mem_addr_width+5] == 1'b0 ||  
			cmd_fifo_data_out[`ext_buf_mem_addr_width+5] == 1'b1 &&
			write_fifo_nword >= cmd_fifo_data_out[`ext_buf_mem_addr_width+4:`ext_buf_mem_addr_width])begin
			sdrc_act <= 1;
			cmd_state <= CmdWait3;
		end
	end
	CmdWait3 : begin
		sdrc_act <= 0;
		cmd_state <= CmdIdle;
	end
	endcase
end


//read
always @(posedge sdrc_clk or negedge rst_n)
if (!rst_n) begin
	rd_len <= 0;
end
else begin
	if (sdrc_read_done) 
		rd_len <= 0;
	else if (sdrc_data_out_valid)
		rd_len <= rd_len + 1;
end

always @(posedge sdrc_clk or negedge rst_n)
if (!rst_n)
	sdrc_data_out_reg <= 0;
else if (sdrc_data_out_valid)
	sdrc_data_out_reg <= sdrc_data_out;
	
always @(*)
if (fifo_read_info_data_out[1:0] == 0)
	sdrc_data_out_tmp <= {sdrc_data_out_reg[31:0]};
else if (fifo_read_info_data_out[1:0] == 1)
	sdrc_data_out_tmp <= {sdrc_data_out[7:0], sdrc_data_out_reg[31:8]};
else if (fifo_read_info_data_out[1:0] == 2)
	sdrc_data_out_tmp <= {sdrc_data_out[15:0], sdrc_data_out_reg[31:16]};
else
	sdrc_data_out_tmp <= {sdrc_data_out[23:0], sdrc_data_out_reg[31:24]};

always @(*)
	read_burst2_addr = (cmd_fifo_data_out[`ext_buf_mem_addr_width-1:4] + 1) * 16;
	
always @(*)
	sdrc_cmd = cmd_fifo_data_out;
	
always @(posedge host_clk or negedge rst_n)
if (!rst_n)
	valid <= 0;
else if (rd && read_fifo_empty == 0)
	valid <= 1;
else
	valid <= 0;
	

endmodule
