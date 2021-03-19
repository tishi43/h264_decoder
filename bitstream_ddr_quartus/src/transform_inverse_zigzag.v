//--------------------------------------------------------------------------------------------------
// Design    : bitstream_p
// Author(s) : qiu bin, shi tian qi
// Email     : chat1@126.com, tishi1@126.com
// Copyright (C) 2013 qiu bin 
// All rights reserved                
//-------------------------------------------------------------------------------------------------


module transform_inverse_zigzag
(
	col_counter,
	block_type,
	curr_DC,
	coeff_0,
	coeff_1,
	coeff_2,
	coeff_3,
	coeff_4,
	coeff_5,
	coeff_6,
	coeff_7,
	coeff_8,
	coeff_9,
	coeff_10,
	coeff_11,
	coeff_12,
	coeff_13,
	coeff_14,
	coeff_15,
	inverse_zigzag_out_0,
	inverse_zigzag_out_1,
	inverse_zigzag_out_2,
	inverse_zigzag_out_3
);
//-------------------
//ports
//--------------------
input [1:0] col_counter;
input [2:0]	block_type;
input [15:0] curr_DC;
input [15:0] coeff_0;
input [15:0] coeff_1;
input [15:0] coeff_2;
input [15:0] coeff_3;
input [15:0] coeff_4;
input [15:0] coeff_5;
input [15:0] coeff_6;
input [15:0] coeff_7;
input [15:0] coeff_8;
input [15:0] coeff_9;
input [15:0] coeff_10;
input [15:0] coeff_11;
input [15:0] coeff_12;
input [15:0] coeff_13;
input [15:0] coeff_14;
input [15:0] coeff_15;

output [15:0] inverse_zigzag_out_0;
output [15:0] inverse_zigzag_out_1;
output [15:0] inverse_zigzag_out_2;
output [15:0] inverse_zigzag_out_3;


//----------------------
// regs
//----------------------
reg [15:0] inverse_zigzag_out_0;
reg [15:0] inverse_zigzag_out_1;
reg [15:0] inverse_zigzag_out_2;
reg [15:0] inverse_zigzag_out_3;

//--------------------
//inverse_zigzag_out
//--------------------
always @(*)
if (block_type == 2 || block_type == 6) begin //AC
	if (col_counter == 0 ) begin
		inverse_zigzag_out_0 = curr_DC;
		inverse_zigzag_out_1 = coeff_1;
		inverse_zigzag_out_2 = coeff_2;
		inverse_zigzag_out_3 = coeff_8;
	end
	else if (col_counter == 1) begin
		inverse_zigzag_out_0 = coeff_0;
		inverse_zigzag_out_1 = coeff_3;
		inverse_zigzag_out_2 = coeff_7;
		inverse_zigzag_out_3 = coeff_9;
	end
	else if (col_counter == 2) begin
		inverse_zigzag_out_0 = coeff_4;
		inverse_zigzag_out_1 = coeff_6;
		inverse_zigzag_out_2 = coeff_10;
		inverse_zigzag_out_3 = coeff_13;
	end
	else begin
		inverse_zigzag_out_0 = coeff_5;
		inverse_zigzag_out_1 = coeff_11;
		inverse_zigzag_out_2 = coeff_12;
		inverse_zigzag_out_3 = coeff_14;
	end
end
else if (block_type == 5) begin	//Chroma DC
	inverse_zigzag_out_0 = coeff_0;
	inverse_zigzag_out_1 = coeff_1;
	inverse_zigzag_out_2 = coeff_2;
	inverse_zigzag_out_3 = coeff_3;
end
else begin	//Luma4x4 or LumaDC
	if (col_counter == 0 ) begin
		inverse_zigzag_out_0 = coeff_0;
		inverse_zigzag_out_1 = coeff_2;
		inverse_zigzag_out_2 = coeff_3;
		inverse_zigzag_out_3 = coeff_9;
	end
	else if (col_counter == 1) begin
		inverse_zigzag_out_0 = coeff_1;
		inverse_zigzag_out_1 = coeff_4;
		inverse_zigzag_out_2 = coeff_8;
		inverse_zigzag_out_3 = coeff_10;
	end
	else if (col_counter == 2) begin
		inverse_zigzag_out_0 = coeff_5;
		inverse_zigzag_out_1 = coeff_7;
		inverse_zigzag_out_2 = coeff_11;
		inverse_zigzag_out_3 = coeff_14;
	end
	else begin
		inverse_zigzag_out_0 = coeff_6;
		inverse_zigzag_out_1 = coeff_12;
		inverse_zigzag_out_2 = coeff_13;
		inverse_zigzag_out_3 = coeff_15;
	end
end
endmodule
