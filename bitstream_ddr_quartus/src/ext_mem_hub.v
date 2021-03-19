//--------------------------------------------------------------------------------------------------
// Design    : bitstream_p
// Author(s) : qiu bin, shi tian qi
// Email     : chat1@126.com, tishi1@126.com
// Copyright (C) 2013 qiu bin 
// All rights reserved                
//-------------------------------------------------------------------------------------------------

`include "defines.v"

module ext_mem_hub
(
	clk,
	rst_n,
	
	ena,
	
	ext_mem_writer_burst,
	ext_mem_writer_burst_len_minus1,
	ext_mem_writer_ready,
	ext_mem_writer_addr,
	ext_mem_writer_display_buf_addr,
    ext_mem_writer_data,
    ext_mem_writer_wr,
    
	ref_mem_burst,
	ref_mem_burst_len_minus1,
	ref_mem_ready,
	ref_mem_valid,
	ref_mem_addr,
	ref_mem_data,
	ref_mem_rd,

	ext_mem_init_done,
	ext_mem_burst,
	ext_mem_burst_len_minus1,
	ext_mem_addr,
	ext_mem_rd,
	ext_mem_wr,
	ext_mem_d,
	ext_mem_q,
	ext_mem_full,
	ext_mem_valid,
	
	ext_display_buf_mem_burst,
	ext_display_buf_addr
);
//global signals
input									clk;			
input									rst_n;
input									ena;

//interface to ext_mem_writer
input									ext_mem_writer_burst; 
input [4:0]								ext_mem_writer_burst_len_minus1;
output									ext_mem_writer_ready;
input [`ext_buf_mem_addr_width-1:0]		ext_mem_writer_addr;
input [`ext_buf_mem_addr_width-1:0]		ext_mem_writer_display_buf_addr;
input [`ext_buf_mem_data_width-1:0]		ext_mem_writer_data;
input									ext_mem_writer_wr;

//interface to inter_pred
input									ref_mem_burst;
input [4:0]								ref_mem_burst_len_minus1;
output									ref_mem_ready;
output									ref_mem_valid;
input [`ext_buf_mem_addr_width-1:0]		ref_mem_addr;
output [`ext_buf_mem_data_width-1:0]	ref_mem_data;
input									ref_mem_rd;

//interface to external buffer memory controller
input									ext_mem_init_done;	
output									ext_mem_burst;
output                                  ext_display_buf_mem_burst;
output [4:0]							ext_mem_burst_len_minus1;
output [`ext_buf_mem_addr_width-1:0]	ext_mem_addr;
output [`ext_buf_mem_addr_width-1:0]	ext_display_buf_addr;
output									ext_mem_rd;
output									ext_mem_wr;
output [`ext_buf_mem_data_width-1:0]	ext_mem_d;
input  [`ext_buf_mem_data_width-1:0]	ext_mem_q;
input									ext_mem_full;
input 									ext_mem_valid;

reg [1:0] state;
parameter 
Idle = 2'b00,
Read = 2'b10,
Write = 2'b01;
reg [4:0] burst_counter;
reg [`ext_buf_mem_addr_width-1:0]	ext_mem_addr;
reg [`ext_buf_mem_addr_width-1:0]	ext_display_buf_addr;

always @(posedge clk or negedge rst_n)
if (!rst_n)
	ext_mem_addr <= 0;
else if (ena) begin
	if (ext_mem_writer_burst)
		ext_mem_addr <= ext_mem_writer_addr;
	else if (ref_mem_burst)
		ext_mem_addr <= ref_mem_addr;
	else if (state == Write && !ext_mem_full || 
			 state == Read)
		ext_mem_addr <= ext_mem_addr + 4;
end

always @(posedge clk or negedge rst_n)
if (!rst_n)
	ext_display_buf_addr <= 0;
else if (ena) begin
	if (ext_mem_writer_burst)
		ext_display_buf_addr <= ext_mem_writer_display_buf_addr;
	else if (state == Write && !ext_mem_full)
		ext_display_buf_addr <= ext_display_buf_addr + 4;
end

always @(posedge clk or negedge rst_n)
if (!rst_n)
	burst_counter <= 0;
else if (ena) begin
	if (ext_mem_writer_burst || ref_mem_burst)
		burst_counter <= 0;
	else if (state == Write && !ext_mem_full || 
			 state == Read && ext_mem_valid)
		burst_counter <= burst_counter + 1;
end

always @(posedge clk or negedge rst_n)
if (!rst_n)
	state <= Idle;
else if (ena) begin
	case (state)
	Idle: begin
		if (ext_mem_writer_burst)
			state <= Write;
		else if (ref_mem_burst)
			state <= Read;
		else
			state <= Idle;
	end
	Write: begin
		if (burst_counter == ext_mem_writer_burst_len_minus1 && !ext_mem_writer_burst)
			state <= Idle;
		else
			state <= Write;
	end
	Read: begin
		if (burst_counter == ref_mem_burst_len_minus1 && !ref_mem_burst)
			state <= Idle;
		else
			state <= Read;
	end
	default: state <= Idle;
	endcase
end

assign ext_mem_burst = ext_mem_writer_burst | ref_mem_burst;
assign ext_display_buf_mem_burst = ext_mem_writer_burst;

assign ext_mem_burst_len_minus1 = (ext_mem_writer_burst | ext_mem_writer_wr) ? 
								ext_mem_writer_burst_len_minus1:ref_mem_burst_len_minus1;
assign ext_mem_rd = ref_mem_rd;
	
assign ext_mem_wr = ext_mem_writer_wr;

assign ext_mem_d = ext_mem_writer_data;
	
assign ref_mem_data = ext_mem_q;

assign ext_mem_writer_ready = !ext_mem_full;
assign ref_mem_ready = !ext_mem_full;

assign ref_mem_valid = ext_mem_valid;

endmodule
