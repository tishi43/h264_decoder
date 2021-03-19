//--------------------------------------------------------------------------------------------------
// Design    : bitstream_p
// Author(s) : qiu bin, shi tian qi
// Email     : chat1@126.com, tishi1@126.com
// Copyright (C) 2013 qiu bin 
// All rights reserved                
//-------------------------------------------------------------------------------------------------


`include "defines.v"

module inter_pred_fsm
(
	clk,
	rst_n,
	ena,
	
	start,
	valid,
	
	ref_x,
	ref_y,
	
	ref_mem_ready,
	
	blk4x4_counter,
	chroma_cb_sel,
	chroma_cr_sel,	

	state,
	counter,
	ref_nword_left
);

input  clk;
input  rst_n;
input  ena;

input  start;
output valid;

input  [`mb_x_bits + 5:0] ref_x;
input  [`mb_y_bits + 5:0] ref_y;

input  ref_mem_ready;

input  [4:0] blk4x4_counter;

output chroma_cb_sel;
output chroma_cr_sel;

output [2:0] state;
output [7:0] counter;
input  [7:0] ref_nword_left;

//FF
reg [2:0] state;
reg [7:0] counter;
reg valid;

//comb
reg chroma_cb_sel;
reg chroma_cr_sel;

wire load_end;
assign load_end = ref_nword_left == 0;
always @(posedge clk or negedge rst_n)
if (!rst_n) begin
	state <= `inter_pred_idle_s;
end
else begin
	case (state)
	`inter_pred_idle_s: begin
		if (start)
			state <= `inter_pred_load_s;
	end
	`inter_pred_load_s: begin
		if (load_end)
			state <= `inter_pred_calc_s;
	end
	`inter_pred_calc_s: begin
		if (counter == 0) 
			state <= `inter_pred_idle_s;
	end
	endcase
end

always @(posedge clk or negedge rst_n)
if (!rst_n)
	valid <= 0;
else if (ena) begin
	if (state == `inter_pred_idle_s && start)
		valid <= 0;
	else if (state == `inter_pred_calc_s && counter == 0)
		valid <= 1;
end

always @(posedge clk or negedge rst_n)
if (!rst_n)
	counter <= 0;
else if (ena)
	case (state)
	`inter_pred_idle_s : begin
		if (start) begin
			if (!chroma_cb_sel && !chroma_cr_sel) begin
				 if (ref_x[1:0] == 0 && ref_y[1:0] == 0)
				 	counter <= 5;
				 else if (ref_x[1:0] == 0)
				 	counter <= 10;
				 else if (ref_y[1:0] == 0)
				 	counter <= 13;
				 else
				 	counter <= 28;
			end
			else begin
				if (ref_x[2:0] == 0 && ref_y[2:0] == 0)
					counter <= 5;
				else
					counter <= 11;
			end
		end
	end
	`inter_pred_load_s : begin
		if (!chroma_cb_sel && !chroma_cr_sel) begin
			if (load_end && ref_x[1:0] == 0 && ref_y[1:0] == 0)
				counter <= 0;
			else if (load_end)
				counter <= 3;
			else if (counter > 0 && ref_mem_ready)
				counter <= counter - 1;
		end
		else begin
			if (load_end && ref_x[2:0] == 0 && ref_y[2:0] == 0)
				counter <= 0;
			else if (load_end)
				counter <= 3;
			else if (counter > 0 && ref_mem_ready)
				counter <= counter - 1;
		end
	end
	`inter_pred_calc_s : begin
		counter <= counter - 1;
	end
	endcase

always @(*)
if (blk4x4_counter < 16)begin
	chroma_cb_sel <= 0;
	chroma_cr_sel <= 0;
end
else if (blk4x4_counter >= 16 && blk4x4_counter < 20)begin
	chroma_cb_sel <= 1;
	chroma_cr_sel <= 0;
end
else begin
	chroma_cb_sel <= 0;
	chroma_cr_sel <= 1;
end 

endmodule