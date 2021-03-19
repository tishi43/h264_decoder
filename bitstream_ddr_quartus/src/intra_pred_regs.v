//--------------------------------------------------------------------------------------------------
// Design    : bitstream_p
// Author(s) : qiu bin, shi tian qi
// Email     : chat1@126.com, tishi1@126.com
// Copyright (C) 2013 qiu bin 
// All rights reserved                
//-------------------------------------------------------------------------------------------------


`include "defines.v"

module intra_pred_regs
(
	clk,         
	rst_n,       
	ena,         
	blk4x4_counter,
	addr,        
	wr,
	DC_wr,
	left_mb_luma_addr,
	left_mb_luma_wr,
	sum_right_colum,
	up_mb_luma_addr,
	up_mb_luma_wr,
	sum_bottom_row,
	line_ram_luma_data,
	line_ram_cb_data,
	line_ram_cr_data,
	preload_counter,
	up_left_addr,
	up_left_wr,
	up_left_7_wr,
	up_left_cb_wr,
	up_left_cr_wr,
	left_mb_cb_wr,
	left_mb_cr_wr,
	left_mb_cb_addr,
	left_mb_cr_addr,
	
	PE_0,
	PE_1,
	PE_2,
	PE_3,
	
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
	left_mb_0,
	left_mb_1, 
	left_mb_2, 
	left_mb_3, 
	left_mb_4, 
	left_mb_5, 
	left_mb_6, 
	left_mb_7, 
	left_mb_8, 
	left_mb_9, 
	left_mb_10,
	left_mb_11,
	left_mb_12,
	left_mb_13,
	left_mb_14,
	left_mb_15,

    up_mb_0,
    up_mb_1,
    up_mb_2,
    up_mb_3,
    up_mb_4,
    up_mb_5,
    up_mb_6,
    up_mb_7,
    up_mb_8,
    up_mb_9,
    up_mb_10,
    up_mb_11,
    up_mb_12,
    up_mb_13,
    up_mb_14,
    up_mb_15,
    
    up_left_0,
    up_left_1,
    up_left_2,
    up_left_3,
    up_left_4,
    up_left_5,
    up_left_6,
    up_left_7,
    up_left_cb,
    up_left_cr,
    
    up_right_1,
    up_right_2,
    up_right_3,
    up_right_0
); 
input clk;
input rst_n;
input ena;
input [4:0] blk4x4_counter;
input [1:0] addr;
input wr;
input [1:0] left_mb_luma_addr;
input left_mb_luma_wr;
input [31:0] sum_right_colum;
input [1:0]  up_mb_luma_addr;
input up_mb_luma_wr;
input [31:0] sum_bottom_row;
input [31:0] line_ram_luma_data;
input [31:0] line_ram_cb_data;
input [31:0] line_ram_cr_data;
input [2:0] preload_counter;
input [2:0] up_left_addr;
input up_left_wr;
input up_left_7_wr;
input up_left_cb_wr;
input up_left_cr_wr;
input DC_wr;
input left_mb_cb_wr;
input left_mb_cr_wr;
input left_mb_cb_addr;
input left_mb_cr_addr;

input [7:0] PE_0;
input [7:0] PE_1;
input [7:0] PE_2;
input [7:0] PE_3;

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

output [7:0] left_mb_0;
output [7:0] left_mb_1;
output [7:0] left_mb_2;
output [7:0] left_mb_3;
output [7:0] left_mb_4;
output [7:0] left_mb_5;
output [7:0] left_mb_6;
output [7:0] left_mb_7;
output [7:0] left_mb_8;
output [7:0] left_mb_9;
output [7:0] left_mb_10;
output [7:0] left_mb_11;
output [7:0] left_mb_12;
output [7:0] left_mb_13;
output [7:0] left_mb_14;
output [7:0] left_mb_15;

output [7:0] up_mb_0;
output [7:0] up_mb_1;
output [7:0] up_mb_2;
output [7:0] up_mb_3;
output [7:0] up_mb_4;
output [7:0] up_mb_5;
output [7:0] up_mb_6;
output [7:0] up_mb_7;
output [7:0] up_mb_8;
output [7:0] up_mb_9;
output [7:0] up_mb_10;
output [7:0] up_mb_11;
output [7:0] up_mb_12;
output [7:0] up_mb_13;
output [7:0] up_mb_14;
output [7:0] up_mb_15;

output [7:0] up_left_0;
output [7:0] up_left_1;
output [7:0] up_left_2;
output [7:0] up_left_3;
output [7:0] up_left_4;
output [7:0] up_left_5;
output [7:0] up_left_6;
output [7:0] up_left_7;
output [7:0] up_left_cb;
output [7:0] up_left_cr;

output [7:0] up_right_0;
output [7:0] up_right_1;
output [7:0] up_right_2;                     
output [7:0] up_right_3;                     
                     
//FFs                
reg [7:0] intra_pred_0;
reg [7:0] intra_pred_1; 
reg [7:0] intra_pred_2; 
reg [7:0] intra_pred_3; 
reg [7:0] intra_pred_4; 
reg [7:0] intra_pred_5; 
reg [7:0] intra_pred_6; 
reg [7:0] intra_pred_7; 
reg [7:0] intra_pred_8; 
reg [7:0] intra_pred_9; 
reg [7:0] intra_pred_10;
reg [7:0] intra_pred_11;
reg [7:0] intra_pred_12;
reg [7:0] intra_pred_13;
reg [7:0] intra_pred_14;
reg [7:0] intra_pred_15;

reg [7:0] left_mb_0;
reg [7:0] left_mb_1;
reg [7:0] left_mb_2;
reg [7:0] left_mb_3;
reg [7:0] left_mb_4;                     
reg [7:0] left_mb_5;                     
reg [7:0] left_mb_6;                     
reg [7:0] left_mb_7;                     
reg [7:0] left_mb_8;                     
reg [7:0] left_mb_9;                     
reg [7:0] left_mb_10;                     
reg [7:0] left_mb_11;                     
reg [7:0] left_mb_12;                     
reg [7:0] left_mb_13;                     
reg [7:0] left_mb_14;                     
reg [7:0] left_mb_15;    

reg [7:0] left_mb_luma_0;  
reg [7:0] left_mb_luma_1;  
reg [7:0] left_mb_luma_2;  
reg [7:0] left_mb_luma_3;  
reg [7:0] left_mb_luma_4;  
reg [7:0] left_mb_luma_5;  
reg [7:0] left_mb_luma_6;  
reg [7:0] left_mb_luma_7;  
reg [7:0] left_mb_luma_8;  
reg [7:0] left_mb_luma_9;  
reg [7:0] left_mb_luma_10; 
reg [7:0] left_mb_luma_11; 
reg [7:0] left_mb_luma_12; 
reg [7:0] left_mb_luma_13; 
reg [7:0] left_mb_luma_14; 
reg [7:0] left_mb_luma_15; 
     
reg [7:0] up_mb_0;     
reg [7:0] up_mb_1;     
reg [7:0] up_mb_2;     
reg [7:0] up_mb_3;     
reg [7:0] up_mb_4;     
reg [7:0] up_mb_5;     
reg [7:0] up_mb_6;     
reg [7:0] up_mb_7;     
reg [7:0] up_mb_8;     
reg [7:0] up_mb_9;     
reg [7:0] up_mb_10;    
reg [7:0] up_mb_11;    
reg [7:0] up_mb_12;    
reg [7:0] up_mb_13;
reg [7:0] up_mb_14;
reg [7:0] up_mb_15;

reg [7:0] up_mb_luma_0;     
reg [7:0] up_mb_luma_1;     
reg [7:0] up_mb_luma_2;     
reg [7:0] up_mb_luma_3;     
reg [7:0] up_mb_luma_4;     
reg [7:0] up_mb_luma_5;     
reg [7:0] up_mb_luma_6;     
reg [7:0] up_mb_luma_7;     
reg [7:0] up_mb_luma_8;     
reg [7:0] up_mb_luma_9;     
reg [7:0] up_mb_luma_10;    
reg [7:0] up_mb_luma_11;    
reg [7:0] up_mb_luma_12;    
reg [7:0] up_mb_luma_13;
reg [7:0] up_mb_luma_14;
reg [7:0] up_mb_luma_15;

reg [7:0] up_mb_cb_0;
reg [7:0] up_mb_cb_1;
reg [7:0] up_mb_cb_2;
reg [7:0] up_mb_cb_3;
reg [7:0] up_mb_cb_4;
reg [7:0] up_mb_cb_5;
reg [7:0] up_mb_cb_6;
reg [7:0] up_mb_cb_7;

reg [7:0] up_mb_cr_0;
reg [7:0] up_mb_cr_1;
reg [7:0] up_mb_cr_2;
reg [7:0] up_mb_cr_3;
reg [7:0] up_mb_cr_4;
reg [7:0] up_mb_cr_5;
reg [7:0] up_mb_cr_6;
reg [7:0] up_mb_cr_7;

reg [7:0] left_mb_cb_0;
reg [7:0] left_mb_cb_1;
reg [7:0] left_mb_cb_2;
reg [7:0] left_mb_cb_3;
reg [7:0] left_mb_cb_4;
reg [7:0] left_mb_cb_5;
reg [7:0] left_mb_cb_6;
reg [7:0] left_mb_cb_7;
                       
reg [7:0] left_mb_cr_0;
reg [7:0] left_mb_cr_1;
reg [7:0] left_mb_cr_2;
reg [7:0] left_mb_cr_3;
reg [7:0] left_mb_cr_4;
reg [7:0] left_mb_cr_5;
reg [7:0] left_mb_cr_6;
reg [7:0] left_mb_cr_7;

reg [7:0] up_left_0;
reg [7:0] up_left_1;
reg [7:0] up_left_2;
reg [7:0] up_left_3;
reg [7:0] up_left_4;
reg [7:0] up_left_5;
reg [7:0] up_left_6;
reg [7:0] up_left_7;
reg [7:0] up_left_cb;
reg [7:0] up_left_cr;

reg [7:0] up_right_0;
reg [7:0] up_right_1;
reg [7:0] up_right_2;
reg [7:0] up_right_3;

always @(posedge clk or negedge rst_n)
if (!rst_n) begin
	intra_pred_0 <= 0;
	intra_pred_1 <= 0;
	intra_pred_2 <= 0;
	intra_pred_3 <= 0;
	intra_pred_4 <= 0;
	intra_pred_5 <= 0;
	intra_pred_6 <= 0;
	intra_pred_7 <= 0;
	intra_pred_8 <= 0;
	intra_pred_9 <= 0;
	intra_pred_10 <= 0;
	intra_pred_11 <= 0;
	intra_pred_12 <= 0;
	intra_pred_13 <= 0;
	intra_pred_14 <= 0;
	intra_pred_15 <= 0;
end
else if (ena && DC_wr) begin
	intra_pred_0 <= PE_0;
	intra_pred_1 <= PE_0;
	intra_pred_2 <= PE_0;
	intra_pred_3 <= PE_0;
	intra_pred_4 <= PE_0;
	intra_pred_5 <= PE_0;
	intra_pred_6 <= PE_0;
	intra_pred_7 <= PE_0;
	intra_pred_8 <= PE_0;
	intra_pred_9 <= PE_0;
	intra_pred_10 <= PE_0;
	intra_pred_11 <= PE_0;
	intra_pred_12 <= PE_0;
	intra_pred_13 <= PE_0;
	intra_pred_14 <= PE_0;
	intra_pred_15 <= PE_0;
end
else if (ena && wr)
	case(addr)
	3: begin
		intra_pred_0 <= PE_0; 	intra_pred_4 <= PE_1;
		intra_pred_8 <= PE_2;	intra_pred_12<= PE_3;
	end
	2:begin
		intra_pred_1 <= PE_0; 	intra_pred_5 <= PE_1;
		intra_pred_9 <= PE_2;	intra_pred_13<= PE_3;
	end
	1:begin
		intra_pred_2 <= PE_0; 	intra_pred_6 <= PE_1;
		intra_pred_10 <= PE_2;	intra_pred_14<= PE_3;
	end
	0:begin
		intra_pred_3 <= PE_0; 	intra_pred_7 <= PE_1;
		intra_pred_11 <= PE_2;	intra_pred_15<= PE_3;
	end
	endcase


always @(posedge clk or negedge rst_n)
if (!rst_n) begin
	up_mb_luma_0 <= 0;
	up_mb_luma_1 <= 0;
	up_mb_luma_2 <= 0;
	up_mb_luma_3 <= 0;
	up_mb_luma_4 <= 0;
	up_mb_luma_5 <= 0;
	up_mb_luma_6 <= 0;
	up_mb_luma_7 <= 0;
	up_mb_luma_8 <= 0;
	up_mb_luma_9 <= 0;
	up_mb_luma_10 <= 0;
	up_mb_luma_11 <= 0;
	up_mb_luma_12 <= 0;
	up_mb_luma_13 <= 0;
	up_mb_luma_14 <= 0;
	up_mb_luma_15 <= 0;
end
else if (ena && preload_counter > 0 && preload_counter <= 4)
	case(preload_counter)
	4: begin
		up_mb_luma_0 <= line_ram_luma_data[7:0]; 	up_mb_luma_1 <= line_ram_luma_data[15:8];
		up_mb_luma_2 <= line_ram_luma_data[23:16];	up_mb_luma_3 <= line_ram_luma_data[31:24];
	end
	3:begin
		up_mb_luma_4 <= line_ram_luma_data[7:0]; 	up_mb_luma_5 <= line_ram_luma_data[15:8];
		up_mb_luma_6 <= line_ram_luma_data[23:16];	up_mb_luma_7 <= line_ram_luma_data[31:24];
	end
	2:begin
		up_mb_luma_8 <= line_ram_luma_data[7:0]; 	up_mb_luma_9 <= line_ram_luma_data[15:8];
		up_mb_luma_10<= line_ram_luma_data[23:16];	up_mb_luma_11<= line_ram_luma_data[31:24];
	end
	1:begin
		up_mb_luma_12 <= line_ram_luma_data[7:0];  up_mb_luma_13 <= line_ram_luma_data[15:8];
		up_mb_luma_14 <= line_ram_luma_data[23:16];up_mb_luma_15 <= line_ram_luma_data[31:24];
	end
	endcase
else if (ena && up_mb_luma_wr)
	case(up_mb_luma_addr)
	0: begin
		up_mb_luma_0 <= sum_bottom_row[7:0]; 	up_mb_luma_1 <= sum_bottom_row[15:8];
		up_mb_luma_2 <= sum_bottom_row[23:16];	up_mb_luma_3 <= sum_bottom_row[31:24];
	end
	1:begin
		up_mb_luma_4 <= sum_bottom_row[7:0]; 	up_mb_luma_5 <= sum_bottom_row[15:8];
		up_mb_luma_6 <= sum_bottom_row[23:16];	up_mb_luma_7 <= sum_bottom_row[31:24];
	end
	2:begin
		up_mb_luma_8 <= sum_bottom_row[7:0]; 	up_mb_luma_9 <= sum_bottom_row[15:8];
		up_mb_luma_10<= sum_bottom_row[23:16];	up_mb_luma_11<= sum_bottom_row[31:24];
	end
	3:begin
		up_mb_luma_12 <= sum_bottom_row[7:0];  up_mb_luma_13 <= sum_bottom_row[15:8];
		up_mb_luma_14 <= sum_bottom_row[23:16];up_mb_luma_15 <= sum_bottom_row[31:24];
	end
	endcase

	

always @(posedge clk or negedge rst_n)
if (!rst_n)begin
	up_mb_cb_0 <= 0;
	up_mb_cb_1 <= 0;
	up_mb_cb_2 <= 0;
	up_mb_cb_3 <= 0;
	up_mb_cb_4 <= 0;
	up_mb_cb_5 <= 0;
	up_mb_cb_6 <= 0;
	up_mb_cb_7 <= 0;
end
else if (ena && (preload_counter == 1 || preload_counter == 2))begin
	case(preload_counter)
	2:begin
		up_mb_cb_0 <= line_ram_cb_data[7:0];
		up_mb_cb_1 <= line_ram_cb_data[15:8];
		up_mb_cb_2 <= line_ram_cb_data[23:16];
		up_mb_cb_3 <= line_ram_cb_data[31:24];
	end
	1:begin
		up_mb_cb_4 <= line_ram_cb_data[7:0];
		up_mb_cb_5 <= line_ram_cb_data[15:8];
		up_mb_cb_6 <= line_ram_cb_data[23:16];
		up_mb_cb_7 <= line_ram_cb_data[31:24];
	end
	endcase
end

always @(posedge clk or negedge rst_n)
if (!rst_n)begin
	up_mb_cr_0 <= 0;
	up_mb_cr_1 <= 0;
	up_mb_cr_2 <= 0;
	up_mb_cr_3 <= 0;
	up_mb_cr_4 <= 0;
	up_mb_cr_5 <= 0;
	up_mb_cr_6 <= 0;
	up_mb_cr_7 <= 0;
end
else if (ena && (preload_counter == 1 || preload_counter == 2))begin
	case(preload_counter)
	2:begin
		up_mb_cr_0 <= line_ram_cr_data[7:0];
		up_mb_cr_1 <= line_ram_cr_data[15:8];
		up_mb_cr_2 <= line_ram_cr_data[23:16];
		up_mb_cr_3 <= line_ram_cr_data[31:24];
	end
	1:begin
		up_mb_cr_4 <= line_ram_cr_data[7:0];
		up_mb_cr_5 <= line_ram_cr_data[15:8];
		up_mb_cr_6 <= line_ram_cr_data[23:16];
		up_mb_cr_7 <= line_ram_cr_data[31:24];
	end
	endcase
end

always @(*)
if(blk4x4_counter<16)begin
	up_mb_0 <= up_mb_luma_0;
	up_mb_1 <= up_mb_luma_1;
	up_mb_2 <= up_mb_luma_2;
	up_mb_3 <= up_mb_luma_3;
	up_mb_4 <= up_mb_luma_4;
	up_mb_5 <= up_mb_luma_5;
	up_mb_6 <= up_mb_luma_6;
	up_mb_7 <= up_mb_luma_7;
	up_mb_8 <= up_mb_luma_8;
	up_mb_9 <= up_mb_luma_9;  
	up_mb_10 <= up_mb_luma_10;  
	up_mb_11 <= up_mb_luma_11;  
	up_mb_12 <= up_mb_luma_12;  
	up_mb_13 <= up_mb_luma_13;  
	up_mb_14 <= up_mb_luma_14;  
	up_mb_15 <= up_mb_luma_15;  
end   
else if (blk4x4_counter >= 16 && blk4x4_counter <= 19)begin
	up_mb_0 <= up_mb_cb_0;
	up_mb_1 <= up_mb_cb_1;
	up_mb_2 <= up_mb_cb_2;
	up_mb_3 <= up_mb_cb_3;
	up_mb_4 <= up_mb_cb_4;
	up_mb_5 <= up_mb_cb_5;
	up_mb_6 <= up_mb_cb_6;
	up_mb_7 <= up_mb_cb_7;
	up_mb_8 <= 0;
	up_mb_9 <= 0;
	up_mb_10 <= 0;
	up_mb_11 <= 0;
	up_mb_12 <= 0;
	up_mb_13 <= 0;
	up_mb_14 <= 0;
	up_mb_15 <= 0;
end
else begin
	up_mb_0 <= up_mb_cr_0;
	up_mb_1 <= up_mb_cr_1;
	up_mb_2 <= up_mb_cr_2;
	up_mb_3 <= up_mb_cr_3;
	up_mb_4 <= up_mb_cr_4;
	up_mb_5 <= up_mb_cr_5;
	up_mb_6 <= up_mb_cr_6;
	up_mb_7 <= up_mb_cr_7;
	up_mb_8 <= 0;
	up_mb_9 <= 0;
	up_mb_10 <= 0;
	up_mb_11 <= 0;
	up_mb_12 <= 0;
	up_mb_13 <= 0;
	up_mb_14 <= 0;
	up_mb_15 <= 0;
end


always @(posedge clk or negedge rst_n)
if (!rst_n) begin
	left_mb_luma_0 <= 0;
	left_mb_luma_1 <= 0;
	left_mb_luma_2 <= 0;
	left_mb_luma_3 <= 0;
	left_mb_luma_4 <= 0;
	left_mb_luma_5 <= 0;
	left_mb_luma_6 <= 0;
	left_mb_luma_7 <= 0;
	left_mb_luma_8 <= 0;
	left_mb_luma_9 <= 0;
	left_mb_luma_10 <= 0;
	left_mb_luma_11 <= 0;
	left_mb_luma_12 <= 0;
	left_mb_luma_13 <= 0;
	left_mb_luma_14 <= 0;
	left_mb_luma_15 <= 0;
end
else if (ena && left_mb_luma_wr)
	case(left_mb_luma_addr)
	0: begin
		left_mb_luma_0 <= sum_right_colum[7:0]; 	left_mb_luma_1 <= sum_right_colum[15:8];
		left_mb_luma_2 <= sum_right_colum[23:16];left_mb_luma_3 <= sum_right_colum[31:24];
	end
	1:begin
		left_mb_luma_4 <= sum_right_colum[7:0]; 	left_mb_luma_5 <= sum_right_colum[15:8];
		left_mb_luma_6 <= sum_right_colum[23:16];left_mb_luma_7 <= sum_right_colum[31:24];
	end
	2:begin
		left_mb_luma_8 <= sum_right_colum[7:0]; 	left_mb_luma_9 <= sum_right_colum[15:8];
		left_mb_luma_10<= sum_right_colum[23:16];left_mb_luma_11<= sum_right_colum[31:24];
	end
	3:begin
		left_mb_luma_12 <= sum_right_colum[7:0];  left_mb_luma_13 <= sum_right_colum[15:8];
		left_mb_luma_14 <= sum_right_colum[23:16];left_mb_luma_15 <= sum_right_colum[31:24];
	end
	endcase
	
always @(posedge clk or negedge rst_n)
if (!rst_n)begin
	left_mb_cb_0 <= 0;
	left_mb_cb_1 <= 0;
	left_mb_cb_2 <= 0;
	left_mb_cb_3 <= 0;
	left_mb_cb_4 <= 0;
	left_mb_cb_5 <= 0;
	left_mb_cb_6 <= 0;
	left_mb_cb_7 <= 0;
end
else if (ena && left_mb_cb_wr)begin
	case(left_mb_cb_addr)
	0:begin
		left_mb_cb_0 <= sum_right_colum[7:0];
		left_mb_cb_1 <= sum_right_colum[15:8];
		left_mb_cb_2 <= sum_right_colum[23:16];
		left_mb_cb_3 <= sum_right_colum[31:24];
	end
	1:begin
		left_mb_cb_4 <= sum_right_colum[7:0];
		left_mb_cb_5 <= sum_right_colum[15:8];
		left_mb_cb_6 <= sum_right_colum[23:16];
		left_mb_cb_7 <= sum_right_colum[31:24];
	end
	endcase
end

always @(posedge clk or negedge rst_n)
if (!rst_n)begin
	left_mb_cr_0 <= 0;
	left_mb_cr_1 <= 0;
	left_mb_cr_2 <= 0;
	left_mb_cr_3 <= 0;
	left_mb_cr_4 <= 0;
	left_mb_cr_5 <= 0;
	left_mb_cr_6 <= 0;
	left_mb_cr_7 <= 0;
end
else if (ena && left_mb_cr_wr)begin
	case(left_mb_cr_addr)
	0:begin
		left_mb_cr_0 <= sum_right_colum[7:0];
		left_mb_cr_1 <= sum_right_colum[15:8];
		left_mb_cr_2 <= sum_right_colum[23:16];
		left_mb_cr_3 <= sum_right_colum[31:24];
	end
	1:begin
		left_mb_cr_4 <= sum_right_colum[7:0];
		left_mb_cr_5 <= sum_right_colum[15:8];
		left_mb_cr_6 <= sum_right_colum[23:16];
		left_mb_cr_7 <= sum_right_colum[31:24];
	end
	endcase
end

always @(*)
if(blk4x4_counter<16)begin
	left_mb_0 <= left_mb_luma_0;
	left_mb_1 <= left_mb_luma_1;
	left_mb_2 <= left_mb_luma_2;
	left_mb_3 <= left_mb_luma_3;
	left_mb_4 <= left_mb_luma_4;
	left_mb_5 <= left_mb_luma_5;
	left_mb_6 <= left_mb_luma_6;
	left_mb_7 <= left_mb_luma_7;
	left_mb_8 <= left_mb_luma_8;
	left_mb_9 <= left_mb_luma_9;
	left_mb_10 <= left_mb_luma_10;
	left_mb_11 <= left_mb_luma_11;
	left_mb_12 <= left_mb_luma_12;
	left_mb_13 <= left_mb_luma_13;
	left_mb_14 <= left_mb_luma_14;
	left_mb_15 <= left_mb_luma_15;
end
else if (blk4x4_counter >= 16 && blk4x4_counter <= 19)begin
	left_mb_0 <= left_mb_cb_0;
	left_mb_1 <= left_mb_cb_1;
	left_mb_2 <= left_mb_cb_2;
	left_mb_3 <= left_mb_cb_3;
	left_mb_4 <= left_mb_cb_4;
	left_mb_5 <= left_mb_cb_5;
	left_mb_6 <= left_mb_cb_6;
	left_mb_7 <= left_mb_cb_7;
	left_mb_8 <= 0;
	left_mb_9 <= 0;
	left_mb_10 <= 0;
	left_mb_11 <= 0;
	left_mb_12 <= 0;
	left_mb_13 <= 0;
	left_mb_14 <= 0;
	left_mb_15 <= 0;
end
else begin
	left_mb_0 <= left_mb_cr_0;
	left_mb_1 <= left_mb_cr_1;
	left_mb_2 <= left_mb_cr_2;
	left_mb_3 <= left_mb_cr_3;
	left_mb_4 <= left_mb_cr_4;
	left_mb_5 <= left_mb_cr_5;
	left_mb_6 <= left_mb_cr_6;
	left_mb_7 <= left_mb_cr_7;
	left_mb_8 <= 0;
	left_mb_9 <= 0;
	left_mb_10 <= 0;
	left_mb_11 <= 0;
	left_mb_12 <= 0;
	left_mb_13 <= 0;
	left_mb_14 <= 0;
	left_mb_15 <= 0;
end

always @(posedge clk or negedge rst_n)
if (!rst_n) begin
	up_left_0 <= 0;
	up_left_1 <= 0;
	up_left_2 <= 0;
	up_left_3 <= 0;
	up_left_4 <= 0;
	up_left_5 <= 0;
	up_left_6 <= 0;
end
else if (ena && preload_counter >0)
	case(preload_counter)
		4:up_left_4 <= line_ram_luma_data[31:24];
		3:up_left_5 <= line_ram_luma_data[31:24];
		2:up_left_6 <= line_ram_luma_data[31:24];
	endcase
else if (ena && up_left_wr)
	case(up_left_addr)
		0:up_left_0 <= sum_bottom_row[31:24];
		1:up_left_1 <= sum_bottom_row[31:24];
		2:up_left_2 <= sum_bottom_row[31:24];
		3:up_left_3 <= sum_bottom_row[31:24];
		default:up_left_4 <= sum_bottom_row[31:24];
	endcase



always @(posedge clk or negedge rst_n)		//for blk 0,2,8,10, update at blk 15,0,2,8
if (!rst_n)
	up_left_7 <= 0;
else if (ena && up_left_7_wr)
	case(blk4x4_counter)
	0:up_left_7 <= left_mb_3;
	2:up_left_7 <= left_mb_7;
	8:up_left_7 <= left_mb_11;
	15:up_left_7 <= line_ram_luma_data[31:24];     
	endcase

always @(posedge clk or negedge rst_n)
if (!rst_n)
	up_left_cb <= 0;
else if (ena && up_left_cb_wr)
	up_left_cb <= line_ram_cb_data[31:24];

always @(posedge clk or negedge rst_n)
if (!rst_n)
	up_left_cr <= 0;
else if (ena && up_left_cr_wr)
	up_left_cr <= line_ram_cr_data[31:24];

	
always @(posedge clk or negedge rst_n)
if (!rst_n) begin
	up_right_0 <= 0;
	up_right_1 <= 0;
	up_right_2 <= 0;
	up_right_3 <= 0;
end
else if (ena && preload_counter == 5)begin
	up_right_0 <= line_ram_luma_data[7:0];
	up_right_1 <= line_ram_luma_data[15:8];
	up_right_2 <= line_ram_luma_data[23:16];
	up_right_3 <= line_ram_luma_data[31:24];
end

endmodule
