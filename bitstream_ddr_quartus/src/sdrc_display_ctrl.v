//--------------------------------------------------------------------------------------------------
// Design    : bitstream_p
// Author(s) : qiu bin, shi tian qi
// Email     : chat1@126.com, tishi1@126.com
// Copyright (C) 2013 qiu bin 
// All rights reserved                
//-------------------------------------------------------------------------------------------------


`include "defines.v"

module sdrc_display_ctrl
(
	host_clk,
	sdrc_clk,
	rst_n,
	burst,
	read_req,
	burst_len_minus1,
	addr,
	wr,
	d,
	full,
	
	//to sdrc
	sdrc_act,
	sdrc_cmd,
	sdrc_data_in,
	sdrc_data_in_req,
	
	sdrc_ready
);
input host_clk;
input sdrc_clk;
input rst_n;
input burst;
input read_req;
input [4:0] burst_len_minus1;
input [`ext_buf_mem_addr_width-1:0] addr;
input wr;
input  [`ext_buf_mem_data_width-1:0] d;
output full;

output sdrc_act;
output [`ext_buf_mem_addr_width+5:0] sdrc_cmd;
output [`ext_buf_mem_data_width-1:0] sdrc_data_in;
input  sdrc_data_in_req;
input  sdrc_ready;

reg burst_s;
reg [2:0] cmd_state;
parameter
CmdIdle = 3'b000,
WriteCmdState1 = 3'b001,
WriteCmdState2 = 3'b011,
WriteCmdState3 = 3'b010,
ReadCmdState1 = 3'b100,
ReadCmdState2 = 3'b110;


reg cmd_fifo_rd;
reg sdrc_act;

wire [`ext_buf_mem_addr_width+5:0] cmd_fifo_data_in;
assign cmd_fifo_data_in = wr ? {1'b1,burst_len_minus1,addr}:{1'b0,burst_len_minus1,addr};

//data format {read(1'b0)/write(1'b1),burst_len_minus1(5bits),addr(ext_buf_mem_addr_width bits)}
wire [`ext_buf_mem_addr_width+5:0] cmd_fifo_data_out;
assign sdrc_cmd = (cmd_state == ReadCmdState1 || cmd_state ==  ReadCmdState2)?
				{1'b0,5'b0,addr}:cmd_fifo_data_out;

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
		if (read_req && sdrc_ready) begin
			cmd_state <= ReadCmdState1;
			sdrc_act <= 1;
		end
		else if (cmd_fifo_rd_empty != 1 && sdrc_ready) begin
			cmd_state <= WriteCmdState1;
			cmd_fifo_rd <= 1;
		end
	end
	WriteCmdState1 : begin
		cmd_fifo_rd <= 0;
		cmd_state <= WriteCmdState2;
	end
	WriteCmdState2 : begin
		cmd_fifo_rd <= 0;
		if (cmd_fifo_data_out[`ext_buf_mem_addr_width+5] == 1'b1 &&
			write_fifo_nword > cmd_fifo_data_out[`ext_buf_mem_addr_width+4:`ext_buf_mem_addr_width])begin
			sdrc_act <= 1;
			cmd_state <= WriteCmdState3;
		end
	end
	WriteCmdState3 : begin
		sdrc_act <= 0;
		cmd_state <= CmdIdle;
	end
	ReadCmdState1 : begin
		sdrc_act <= 0;
		cmd_state <= ReadCmdState2;
	end
	ReadCmdState2 : begin
		if (sdrc_ready)
			cmd_state <= CmdIdle;
	end
	endcase
end
	

endmodule
