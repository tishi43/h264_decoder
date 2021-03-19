//--------------------------------------------------------------------------------------------------
// Design    : bitstream_p
// Author(s) : qiu bin, shi tian qi
// Email     : chat1@126.com, tishi1@126.com
// Copyright (C) 2013 qiu bin 
// All rights reserved                
//-------------------------------------------------------------------------------------------------


`include "defines.v"

module sum
(
	clk,
	rst_n,
	ena,
	start,
	mb_pred_mode,
	
    residual_0,
    residual_1, 
    residual_2, 
    residual_3, 
    residual_4, 
    residual_5, 
    residual_6, 
    residual_7, 
    residual_8, 
    residual_9, 
    residual_10,
    residual_11,
    residual_12,
    residual_13,
    residual_14,	
    residual_15,
	
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
	
	inter_pred_0,
	inter_pred_1,
	inter_pred_2,
	inter_pred_3,
	inter_pred_4,
	inter_pred_5,
	inter_pred_6,
	inter_pred_7,
	inter_pred_8,
	inter_pred_9, 
	inter_pred_10,
	inter_pred_11,
	inter_pred_12,
	inter_pred_13,
	inter_pred_14,
	inter_pred_15,
	
	sum_0,
	sum_1,
	sum_2,
	sum_3,
	sum_4,
	sum_5,
	sum_6,
	sum_7,
	sum_8,
	sum_9,
	sum_10,
	sum_11,
	sum_12,
	sum_13,
	sum_14,
	sum_15,	
	sum_right_colum,
	sum_bottom_row,
	write_to_ram_start,
	write_to_ram_valid,
	valid
);
input clk;
input rst_n;
input ena;

input start;
input [3:0] mb_pred_mode;

input [8:0] residual_0;
input [8:0] residual_1;
input [8:0] residual_2;
input [8:0] residual_3;
input [8:0] residual_4;
input [8:0] residual_5;
input [8:0] residual_6;
input [8:0] residual_7;
input [8:0] residual_8;
input [8:0] residual_9;
input [8:0] residual_10;
input [8:0] residual_11;
input [8:0] residual_12;
input [8:0] residual_13;
input [8:0] residual_14;
input [8:0] residual_15;

input [7:0] intra_pred_0; 
input [7:0] intra_pred_1; 
input [7:0] intra_pred_2; 
input [7:0] intra_pred_3; 
input [7:0] intra_pred_4; 
input [7:0] intra_pred_5; 
input [7:0] intra_pred_6; 
input [7:0] intra_pred_7; 
input [7:0] intra_pred_8; 
input [7:0] intra_pred_9; 
input [7:0] intra_pred_10;
input [7:0] intra_pred_11;
input [7:0] intra_pred_12;
input [7:0] intra_pred_13;
input [7:0] intra_pred_14;
input [7:0] intra_pred_15;

input [7:0] inter_pred_0; 
input [7:0] inter_pred_1; 
input [7:0] inter_pred_2; 
input [7:0] inter_pred_3; 
input [7:0] inter_pred_4; 
input [7:0] inter_pred_5; 
input [7:0] inter_pred_6; 
input [7:0] inter_pred_7; 
input [7:0] inter_pred_8; 
input [7:0] inter_pred_9; 
input [7:0] inter_pred_10;
input [7:0] inter_pred_11;
input [7:0] inter_pred_12;
input [7:0] inter_pred_13;
input [7:0] inter_pred_14;
input [7:0] inter_pred_15;

output [7:0] sum_0;
output [7:0] sum_1;
output [7:0] sum_2;
output [7:0] sum_3;
output [7:0] sum_4;
output [7:0] sum_5;
output [7:0] sum_6;
output [7:0] sum_7;
output [7:0] sum_8;
output [7:0] sum_9;
output [7:0] sum_10;
output [7:0] sum_11;
output [7:0] sum_12;
output [7:0] sum_13;
output [7:0] sum_14;
output [7:0] sum_15;

output [31:0] sum_right_colum;
output [31:0] sum_bottom_row;

input  write_to_ram_valid;
output write_to_ram_start;

output valid;
//FFs
parameter
Idle  = 0,
Sum   = 1,
Waite = 2,
Write = 3;

reg [1:0] sum_counter;
reg [1:0] state;
reg write_to_ram_start;
reg valid;
reg [7:0] sum_0;
reg [7:0] sum_1;
reg [7:0] sum_2;
reg [7:0] sum_3;
reg [7:0] sum_4;
reg [7:0] sum_5;
reg [7:0] sum_6;
reg [7:0] sum_7;
reg [7:0] sum_8;
reg [7:0] sum_9;
reg [7:0] sum_10;
reg [7:0] sum_11;
reg [7:0] sum_12;
reg [7:0] sum_13;
reg [7:0] sum_14;
reg [7:0] sum_15;

//regs
reg [31:0] sum_right_colum;
reg [31:0] sum_bottom_row;
//module
reg [8:0] sum_PE0_a;
reg [7:0] sum_PE0_b;
wire [7:0] sum_PE_0;

reg [8:0] sum_PE1_a;
reg [7:0] sum_PE1_b;
wire[7:0] sum_PE_1;

reg [8:0] sum_PE2_a;
reg [7:0] sum_PE2_b;
wire[7:0] sum_PE_2;

reg [8:0] sum_PE3_a;
reg [7:0] sum_PE3_b;
wire[7:0] sum_PE_3;

sum_PE sum_PE0
(
	.a(sum_PE0_a),
	.b(sum_PE0_b),
	.sum(sum_PE_0)
);
sum_PE sum_PE1
(
	.a(sum_PE1_a),
	.b(sum_PE1_b),
	.sum(sum_PE_1)
);
sum_PE sum_PE2
(
	.a(sum_PE2_a),
	.b(sum_PE2_b),
	.sum(sum_PE_2)
);

sum_PE sum_PE3
(
	.a(sum_PE3_a),
	.b(sum_PE3_b),
	.sum(sum_PE_3)
);

always @(posedge clk or negedge rst_n)
if (!rst_n)
begin
	state <= 0;
	sum_counter <= 0;
	write_to_ram_start <= 0;
	valid <= 0;
end
else if (ena)
begin
	case(state)
		Idle: begin
			if (start) begin
				state <= Sum;
				sum_counter <= 3;
				valid <= 0;
			end
		end
		Sum: begin
			if(sum_counter == 0) begin
				state <= Write;
				write_to_ram_start <= 1;
			end
			else
				sum_counter <= sum_counter - 1;	
		end          
		Write: begin
			if (write_to_ram_start)
				write_to_ram_start <= 0;
			else if (write_to_ram_valid) begin
				state <= Idle;
				valid <= 1;	
			end
		end
	endcase
end

always @(posedge clk or negedge rst_n)
if (!rst_n) begin
	sum_0 <= 0;
	sum_1 <= 0;
	sum_2 <= 0;
	sum_3 <= 0;
	sum_4 <= 0;
	sum_5 <= 0;
	sum_6 <= 0;
	sum_7 <= 0;
	sum_8 <= 0;
	sum_9 <= 0;
	sum_10 <= 0;
	sum_11 <= 0;
	sum_12 <= 0;
	sum_13 <= 0;
	sum_14 <= 0;
	sum_15 <= 0;
end
else if (ena && state == 1) begin
	case (sum_counter)
		0 : begin
			sum_0 <= sum_PE_0;
			sum_1 <= sum_PE_1;
			sum_2 <= sum_PE_2;
			sum_3 <= sum_PE_3;
		end			
		1 : begin
			sum_4 <= sum_PE_0;
			sum_5 <= sum_PE_1;
			sum_6 <= sum_PE_2;
			sum_7 <= sum_PE_3;
		end		
		2 : begin
			sum_8 <= sum_PE_0;
			sum_9 <= sum_PE_1;
			sum_10 <= sum_PE_2;
			sum_11 <= sum_PE_3;		
		end
		3 : begin
			sum_12 <= sum_PE_0;
			sum_13 <= sum_PE_1;
			sum_14 <= sum_PE_2;
			sum_15 <= sum_PE_3;		
		end
	endcase
end

always @(*)
	begin
		sum_right_colum[7:0]  <= sum_3;
		sum_right_colum[15:8] <= sum_7;
		sum_right_colum[23:16] <= sum_11;
		sum_right_colum[31:24] <= sum_15;
	end

always @(*)
	begin
		sum_bottom_row[7:0]  <= sum_12;
		sum_bottom_row[15:8] <= sum_13;
		sum_bottom_row[23:16] <= sum_14;
		sum_bottom_row[31:24] <= sum_15;
	end
	
always @(*)
if (mb_pred_mode == `mb_pred_mode_P_SKIP) begin
	sum_PE0_a <= 0;
	sum_PE1_a <= 0;
	sum_PE2_a <= 0;
	sum_PE3_a <= 0;
end
else begin
	case (sum_counter)
	0 : begin
		sum_PE0_a <= residual_0;
		sum_PE1_a <= residual_1;
		sum_PE2_a <= residual_2;
		sum_PE3_a <= residual_3;
	end			
	1 : begin
		sum_PE0_a <= residual_4;
		sum_PE1_a <= residual_5;
		sum_PE2_a <= residual_6;
		sum_PE3_a <= residual_7;	
	end
	2 : begin
		sum_PE0_a <= residual_8;
		sum_PE1_a <= residual_9;
		sum_PE2_a <= residual_10;
		sum_PE3_a <= residual_11;	
	end
	3 : begin
		sum_PE0_a <= residual_12;
		sum_PE1_a <= residual_13;
		sum_PE2_a <= residual_14;
		sum_PE3_a <= residual_15;
	end
	endcase
end

always @(*)
if (mb_pred_mode == `mb_pred_mode_PRED_L0 ||
    mb_pred_mode == `mb_pred_mode_P_REF0 ||
    mb_pred_mode == `mb_pred_mode_P_SKIP)
	case (sum_counter)
	0 : begin
		sum_PE0_b <= inter_pred_0;
		sum_PE1_b <= inter_pred_1;
		sum_PE2_b <= inter_pred_2;
		sum_PE3_b <= inter_pred_3;
	end			
	1 : begin   
		sum_PE0_b <= inter_pred_4;
		sum_PE1_b <= inter_pred_5;
		sum_PE2_b <= inter_pred_6;
		sum_PE3_b <= inter_pred_7;	
	end
	2 : begin   
		sum_PE0_b <= inter_pred_8;
		sum_PE1_b <= inter_pred_9;
		sum_PE2_b <= inter_pred_10;
		sum_PE3_b <= inter_pred_11;	
	end         
	3 : begin  
		sum_PE0_b <= inter_pred_12;
		sum_PE1_b <= inter_pred_13;
		sum_PE2_b <= inter_pred_14;
		sum_PE3_b <= inter_pred_15;
	end
	endcase
else
	case (sum_counter)
	0 : begin
		sum_PE0_b <= intra_pred_0;
		sum_PE1_b <= intra_pred_1;
		sum_PE2_b <= intra_pred_2;
		sum_PE3_b <= intra_pred_3;
	end			
	1 : begin   
		sum_PE0_b <= intra_pred_4;
		sum_PE1_b <= intra_pred_5;
		sum_PE2_b <= intra_pred_6;
		sum_PE3_b <= intra_pred_7;	
	end
	2 : begin   
		sum_PE0_b <= intra_pred_8;
		sum_PE1_b <= intra_pred_9;
		sum_PE2_b <= intra_pred_10;
		sum_PE3_b <= intra_pred_11;	
	end         
	3 : begin  
		sum_PE0_b <= intra_pred_12;
		sum_PE1_b <= intra_pred_13;
		sum_PE2_b <= intra_pred_14;
		sum_PE3_b <= intra_pred_15;
	end
	endcase

endmodule

module sum_PE
(
	a,
	b,
	sum
);
input signed [8:0] a;
input [7:0] b;
output [7:0] sum;
reg [7:0] sum;

wire signed [9:0] c;
wire signed [8:0] b_signed;
 
assign b_signed = {1'b0,b};
assign c = a + b_signed;

always @(*)
	if (c < 0)
		sum = 0;
	else if (c>255)
		sum = 255;
	else
		sum = c[7:0];
endmodule
