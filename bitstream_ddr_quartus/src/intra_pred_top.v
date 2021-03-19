//--------------------------------------------------------------------------------------------------
// Design    : bitstream_p
// Author(s) : qiu bin, shi tian qi
// Email     : chat1@126.com, tishi1@126.com
// Copyright (C) 2013 qiu bin 
// All rights reserved                
//-------------------------------------------------------------------------------------------------

`include "defines.v"

module intra_pred_top
(
	clk,
	rst_n,
	ena,
	start,
	mb_pred_mode,
	mb_pred_inter_sel,
	I4_pred_mode,
	I16_pred_mode,	
	intra_pred_mode_chroma,
	sum_valid,
	mb_x,
	mb_y,
	blk4x4_counter,
	pic_width_in_mbs_minus1,
	sum_right_colum,
	sum_bottom_row,
	
	line_ram_luma_addr,
	line_ram_chroma_addr,
	line_ram_luma_wr_n,
	line_ram_cb_wr_n,
	line_ram_cr_wr_n,
	line_ram_luma_data,
	line_ram_cb_data,
	line_ram_cr_data,
	
	intra_pred_0,
	intra_pred_1,                 
	intra_pred_2,                 
	intra_pred_3,                 
	intra_pred_4,                 
	intra_pred_5,                 
	intra_pred_6,                 
	intra_pred_7,                 
	intra_pred_8,                 
	intra_pred_9,                  
	intra_pred_10,                 
	intra_pred_11,                 
	intra_pred_12,                 
	intra_pred_13,                 
	intra_pred_14,                 
	intra_pred_15,        
	valid        
);
input clk;
input rst_n;
input ena;
input start;
input sum_valid;
input [`mb_x_bits - 1:0] mb_x;
input [`mb_y_bits - 1:0] mb_y;
input [4:0] blk4x4_counter;
input [`mb_x_bits - 1:0] pic_width_in_mbs_minus1;
input [31:0] sum_right_colum;
input [31:0] sum_bottom_row;
input [3:0] mb_pred_mode;
input mb_pred_inter_sel;
input [3:0] I4_pred_mode;
input [1:0] I16_pred_mode;
input [1:0] intra_pred_mode_chroma;

output [`mb_x_bits + 1:0] line_ram_luma_addr;
output [`mb_x_bits :0]    line_ram_chroma_addr;
output line_ram_luma_wr_n;
output line_ram_cb_wr_n;
output line_ram_cr_wr_n;
input  [31:0] line_ram_luma_data;
input  [31:0] line_ram_cb_data;
input  [31:0] line_ram_cr_data;

output [7:0] intra_pred_0;
output [7:0] intra_pred_1; 
output [7:0] intra_pred_2; 
output [7:0] intra_pred_3; 
output [7:0] intra_pred_4; 
output [7:0] intra_pred_5; 
output [7:0] intra_pred_6; 
output [7:0] intra_pred_7; 
output [7:0] intra_pred_8; 
output [7:0] intra_pred_9; 
output [7:0] intra_pred_10;
output [7:0] intra_pred_11;
output [7:0] intra_pred_12;
output [7:0] intra_pred_13;
output [7:0] intra_pred_14;
output [7:0] intra_pred_15;
output valid;

//
//intra_pred_PE
//
wire  calc_ena;
wire  up_avail;
wire  left_avail;
wire  [7:0] PE_0;
wire  [7:0] PE_1;
wire  [7:0] PE_2;
wire  [7:0] PE_3;

wire [4:0] blk4x4_counter;
wire [1:0] calc_counter;

wire [11:0] b;
wire [11:0] c;
wire [14:0] seed;

wire [7:0] up_mb_0;
wire [7:0] up_mb_1;
wire [7:0] up_mb_2;
wire [7:0] up_mb_3;
wire [7:0] up_mb_4;
wire [7:0] up_mb_5;
wire [7:0] up_mb_6;
wire [7:0] up_mb_7;
wire [7:0] up_mb_8;
wire [7:0] up_mb_9;
wire [7:0] up_mb_10;
wire [7:0] up_mb_11;
wire [7:0] up_mb_12;
wire [7:0] up_mb_13;
wire [7:0] up_mb_14;
wire [7:0] up_mb_15;

wire [7:0] left_mb_0;
wire [7:0] left_mb_1;
wire [7:0] left_mb_2;
wire [7:0] left_mb_3;
wire [7:0] left_mb_4;
wire [7:0] left_mb_5;
wire [7:0] left_mb_6;
wire [7:0] left_mb_7;
wire [7:0] left_mb_8;
wire [7:0] left_mb_9;
wire [7:0] left_mb_10;
wire [7:0] left_mb_11;
wire [7:0] left_mb_12;
wire [7:0] left_mb_13;
wire [7:0] left_mb_14;
wire [7:0] left_mb_15;

wire [7:0] up_left_0;
wire [7:0] up_left_1;
wire [7:0] up_left_2;
wire [7:0] up_left_3;
wire [7:0] up_left_4;
wire [7:0] up_left_5;
wire [7:0] up_left_6;
wire [7:0] up_left_7;

wire [7:0] up_right_0;
wire [7:0] up_right_1;
wire [7:0] up_right_2;
wire [7:0] up_right_3;

wire [14:0] PE0_sum_reg;
wire [14:0] PE3_sum_reg;

intra_pred_PE intra_pred_PE
(
	.clk(clk),
	.rst_n(rst_n),
	.ena(calc_ena),
	.calc_counter(calc_counter),
	.blk4x4_counter(blk4x4_counter),
	.mb_pred_mode(mb_pred_mode),
	.I16_pred_mode(I16_pred_mode),
	.I4_pred_mode(I4_pred_mode),
	.intra_pred_mode_chroma(intra_pred_mode_chroma),
	.up_avail(up_avail),
	.left_avail(left_avail),
	.up_right_avail(up_right_avail),
		
	.b(b),
	.c(c),
	.seed(seed),
	
	.up_mb_0(up_mb_0),
	.up_mb_1(up_mb_1),
	.up_mb_2(up_mb_2),
	.up_mb_3(up_mb_3),
	.up_mb_4(up_mb_4),
	.up_mb_5(up_mb_5),
	.up_mb_6(up_mb_6),
	.up_mb_7(up_mb_7),
	.up_mb_8(up_mb_8),
	.up_mb_9(up_mb_9),
	.up_mb_10(up_mb_10),
	.up_mb_11(up_mb_11),
	.up_mb_12(up_mb_12),
	.up_mb_13(up_mb_13),
	.up_mb_14(up_mb_14),
	.up_mb_15(up_mb_15),

	.left_mb_0(left_mb_0),
	.left_mb_1(left_mb_1), 
	.left_mb_2(left_mb_2), 
	.left_mb_3(left_mb_3), 
	.left_mb_4(left_mb_4), 
	.left_mb_5(left_mb_5), 
	.left_mb_6(left_mb_6), 
	.left_mb_7(left_mb_7), 
	.left_mb_8(left_mb_8), 
	.left_mb_9(left_mb_9), 
	.left_mb_10(left_mb_10),
	.left_mb_11(left_mb_11),
	.left_mb_12(left_mb_12),
	.left_mb_13(left_mb_13),
	.left_mb_14(left_mb_14),
	.left_mb_15(left_mb_15),

	.up_left_0(up_left_0),
	.up_left_1(up_left_1),
	.up_left_2(up_left_2),
	.up_left_3(up_left_3),
	.up_left_4(up_left_4),
	.up_left_5(up_left_5),
	.up_left_6(up_left_6),
	.up_left_7(up_left_7),
	
	.up_right_0(up_right_0),
	.up_right_1(up_right_1),
	.up_right_2(up_right_2),
	.up_right_3(up_right_3),              
	          
	.intra_pred_0(intra_pred_0),
	.intra_pred_1(intra_pred_1),
	.intra_pred_2(intra_pred_2),
	.intra_pred_4(intra_pred_4),
	.intra_pred_5(intra_pred_5),
	.intra_pred_6(intra_pred_6),
	.intra_pred_8(intra_pred_8),
	.intra_pred_9(intra_pred_9), 
	.intra_pred_10(intra_pred_10),
	.intra_pred_12(intra_pred_12),
	.intra_pred_13(intra_pred_13),
	.intra_pred_14(intra_pred_14),
	
	.PE0_out(PE_0),
	.PE1_out(PE_1),
	.PE2_out(PE_2),
	.PE3_out(PE_3),
	
	.PE0_sum_reg(PE0_sum_reg),
	.PE3_sum_reg(PE3_sum_reg)
);

//
//intra_pred_regs
//
wire  [1:0] addr;
wire  wr;
wire [1:0] left_mb_luma_addr;
wire  left_mb_luma_wr;
wire [1:0] up_mb_luma_addr;
wire  up_mb_luma_wr;
wire  DC_wr;
wire [2:0] up_left_addr;
wire [31:0] line_ram_luma_data;
wire [31:0] line_ram_cb_data;
wire [31:0] line_ram_cr_data;
wire [2:0] preload_counter;
wire [7:0] up_left_cb;
wire [7:0] up_left_cr;
wire up_left_wr;
wire up_left_7_wr;
wire up_left_cb_wr;
wire up_left_cr_wr;
wire left_mb_cb_wr;
wire left_mb_cr_wr;
wire left_mb_cb_addr;
wire left_mb_cr_addr;

intra_pred_regs intra_pred_regs
(
	.clk(clk),         
	.rst_n(rst_n),       
	.ena(ena),         
	.blk4x4_counter(blk4x4_counter),
	.addr(addr),
	.wr(wr),
	.left_mb_luma_addr(left_mb_luma_addr),
	.left_mb_luma_wr(left_mb_luma_wr),    
	.sum_right_colum(sum_right_colum),
	.up_mb_luma_addr(up_mb_luma_addr),
	.up_mb_luma_wr(up_mb_luma_wr),  
	.sum_bottom_row(sum_bottom_row),
	.line_ram_luma_data(line_ram_luma_data),
	.line_ram_cb_data(line_ram_cb_data),
	.line_ram_cr_data(line_ram_cr_data),
	.preload_counter(preload_counter),
	.up_left_addr(up_left_addr),
	.up_left_wr(up_left_wr),
	.up_left_7_wr(up_left_7_wr),
	.up_left_cb_wr(up_left_cb_wr),
	.up_left_cr_wr(up_left_cr_wr),
	.DC_wr(DC_wr),
	
	.left_mb_cb_wr(left_mb_cb_wr),
	.left_mb_cr_wr(left_mb_cr_wr),
	.left_mb_cb_addr(left_mb_cb_addr),
	.left_mb_cr_addr(left_mb_cr_addr),
	
	.PE_0(PE_0),        
	.PE_1(PE_1),        
	.PE_2(PE_2),        
	.PE_3(PE_3),        
	
	.intra_pred_0(intra_pred_0),
	.intra_pred_1(intra_pred_1),
	.intra_pred_2(intra_pred_2),
	.intra_pred_3(intra_pred_3),
	.intra_pred_4(intra_pred_4),
	.intra_pred_5(intra_pred_5),
	.intra_pred_6(intra_pred_6),
	.intra_pred_7(intra_pred_7),
	.intra_pred_8(intra_pred_8),
	.intra_pred_9(intra_pred_9), 
	.intra_pred_10(intra_pred_10),
	.intra_pred_11(intra_pred_11),
	.intra_pred_12(intra_pred_12),
	.intra_pred_13(intra_pred_13),
	.intra_pred_14(intra_pred_14),
	.intra_pred_15(intra_pred_15),
	.left_mb_0(left_mb_0),
	.left_mb_1(left_mb_1), 
	.left_mb_2(left_mb_2), 
	.left_mb_3(left_mb_3), 
	.left_mb_4(left_mb_4), 
	.left_mb_5(left_mb_5), 
	.left_mb_6(left_mb_6), 
	.left_mb_7(left_mb_7), 
	.left_mb_8(left_mb_8), 
	.left_mb_9(left_mb_9), 
	.left_mb_10(left_mb_10),
	.left_mb_11(left_mb_11),
	.left_mb_12(left_mb_12),
	.left_mb_13(left_mb_13),
	.left_mb_14(left_mb_14),
	.left_mb_15(left_mb_15),
	.up_mb_0(up_mb_0),
	.up_mb_1(up_mb_1),
	.up_mb_2(up_mb_2),
	.up_mb_3(up_mb_3),
	.up_mb_4(up_mb_4),
	.up_mb_5(up_mb_5),
	.up_mb_6(up_mb_6),
	.up_mb_7(up_mb_7),
	.up_mb_8(up_mb_8),
	.up_mb_9(up_mb_9),
	.up_mb_10(up_mb_10),
	.up_mb_11(up_mb_11),
	.up_mb_12(up_mb_12),
	.up_mb_13(up_mb_13),
	.up_mb_14(up_mb_14),
	.up_mb_15(up_mb_15),
	.up_left_0(up_left_0),
	.up_left_1(up_left_1),
	.up_left_2(up_left_2),
	.up_left_3(up_left_3),
	.up_left_4(up_left_4),
	.up_left_5(up_left_5),
	.up_left_6(up_left_6),
	.up_left_7(up_left_7),
    .up_left_cb(up_left_cb),
    .up_left_cr(up_left_cr),

	.up_right_0(up_right_0),
	.up_right_1(up_right_1),
	.up_right_2(up_right_2),
	.up_right_3(up_right_3)
);


//
//precalc for plane mode
//
wire [3:0] precalc_counter;
wire abc_latch;
wire seed_latch;
wire seed_wr;

intra_pred_precalc intra_pred_precalc
(
	.clk(clk),
	.rst_n(rst_n),
	.ena(ena),
	.abc_latch(abc_latch),
	.seed_latch(seed_latch),
	.seed_wr(seed_wr),
	.precalc_counter(precalc_counter),
	.blk4x4_counter(blk4x4_counter),
	.up_mb_0(up_mb_0),
	.up_mb_1(up_mb_1),
	.up_mb_2(up_mb_2),
	.up_mb_3(up_mb_3),
	.up_mb_4(up_mb_4),
	.up_mb_5(up_mb_5),
	.up_mb_6(up_mb_6),
	.up_mb_7(up_mb_7),
	.up_mb_8(up_mb_8),
	.up_mb_9(up_mb_9),
	.up_mb_10(up_mb_10),
	.up_mb_11(up_mb_11),
	.up_mb_12(up_mb_12),
	.up_mb_13(up_mb_13),
	.up_mb_14(up_mb_14),
	.up_mb_15(up_mb_15),
   
   	.left_mb_0(left_mb_0),
	.left_mb_1(left_mb_1), 
	.left_mb_2(left_mb_2), 
	.left_mb_3(left_mb_3), 
	.left_mb_4(left_mb_4), 
	.left_mb_5(left_mb_5), 
	.left_mb_6(left_mb_6), 
	.left_mb_7(left_mb_7), 
	.left_mb_8(left_mb_8), 
	.left_mb_9(left_mb_9), 
	.left_mb_10(left_mb_10),
	.left_mb_11(left_mb_11),
	.left_mb_12(left_mb_12),
	.left_mb_13(left_mb_13),
	.left_mb_14(left_mb_14),
	.left_mb_15(left_mb_15),
	
    .up_left_7(up_left_7),
    .up_left_cb(up_left_cb),
    .up_left_cr(up_left_cr),

	.PE0_sum_reg(PE0_sum_reg),
	.PE3_sum_reg(PE3_sum_reg),
	    
	.b(b),
	.c(c),
	.seed(seed)
);


intra_pred_fsm intra_pred_fsm
(
	.clk(clk),
	.rst_n(rst_n),
	.ena(ena),
	.start(start),
	.mb_x(mb_x),
	.mb_y(mb_y),
	.pic_width_in_mbs_minus1(pic_width_in_mbs_minus1),
	.sum_valid(sum_valid),
	.mb_pred_mode(mb_pred_mode),
	.mb_pred_inter_sel(mb_pred_inter_sel),
	.I4_pred_mode(I4_pred_mode),
	.I16_pred_mode(I16_pred_mode),
	.intra_pred_mode_chroma(intra_pred_mode_chroma),
	.blk4x4_counter(blk4x4_counter),
	.precalc_counter(precalc_counter),
	.up_avail(up_avail),
	.left_avail(left_avail),
	.up_right_avail(up_right_avail),
	.calc_counter(calc_counter),
	.addr(addr),
	.wr(wr),
	.DC_wr(DC_wr),
	.left_mb_luma_addr(left_mb_luma_addr),
	.left_mb_luma_wr(left_mb_luma_wr),
	.up_mb_luma_addr(up_mb_luma_addr),
	.up_mb_luma_wr(up_mb_luma_wr),
	.preload_counter(preload_counter),
	.up_left_addr(up_left_addr),
	.up_left_wr(up_left_wr),
	.up_left_7_wr(up_left_7_wr),
	.up_left_cb_wr(up_left_cb_wr),
	.up_left_cr_wr(up_left_cr_wr),
	.left_mb_cb_wr(left_mb_cb_wr),
	.left_mb_cr_wr(left_mb_cr_wr),
	.left_mb_cb_addr(left_mb_cb_addr),
	.left_mb_cr_addr(left_mb_cr_addr),
	.calc_ena(calc_ena),
	.abc_latch(abc_latch),
	.seed_latch(seed_latch),
	.seed_wr(seed_wr),
	.line_ram_luma_wr_n(line_ram_luma_wr_n),
	.line_ram_cb_wr_n(line_ram_cb_wr_n),
	.line_ram_cr_wr_n(line_ram_cr_wr_n),
	.line_ram_luma_addr(line_ram_luma_addr),
	.line_ram_chroma_addr(line_ram_chroma_addr),
	.valid(valid)
);

endmodule

