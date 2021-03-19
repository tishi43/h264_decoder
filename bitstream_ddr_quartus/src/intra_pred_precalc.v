//--------------------------------------------------------------------------------------------------
// Design    : bitstream_p
// Author(s) : qiu bin, shi tian qi
// Email     : chat1@126.com, tishi1@126.com
// Copyright (C) 2013 qiu bin 
// All rights reserved                
//-------------------------------------------------------------------------------------------------


module intra_pred_precalc
(
    clk,
    rst_n,
    ena,
    precalc_counter,
    blk4x4_counter,
    abc_latch,
	seed_latch,
	seed_wr,
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
    
    up_left_7,
    up_left_cb,
	up_left_cr,
   
	PE0_sum_reg,
	PE3_sum_reg,
   
    b,
    c,
    seed
);
input clk;
input rst_n;
input ena;
input abc_latch;
input seed_latch;
input seed_wr;
input [3:0] precalc_counter;
input [4:0] blk4x4_counter;
input [7:0] up_mb_0;
input [7:0] up_mb_1;
input [7:0] up_mb_2;
input [7:0] up_mb_3;
input [7:0] up_mb_4;
input [7:0] up_mb_5;
input [7:0] up_mb_6;
input [7:0] up_mb_7;
input [7:0] up_mb_8;
input [7:0] up_mb_9;
input [7:0] up_mb_10;
input [7:0] up_mb_11;
input [7:0] up_mb_12;
input [7:0] up_mb_13;
input [7:0] up_mb_14;
input [7:0] up_mb_15;
input [7:0] left_mb_0;
input [7:0] left_mb_1;
input [7:0] left_mb_2;
input [7:0] left_mb_3;
input [7:0] left_mb_4;
input [7:0] left_mb_5;
input [7:0] left_mb_6;
input [7:0] left_mb_7;
input [7:0] left_mb_8;
input [7:0] left_mb_9;
input [7:0] left_mb_10;
input [7:0] left_mb_11;
input [7:0] left_mb_12;
input [7:0] left_mb_13;
input [7:0] left_mb_14;
input [7:0] left_mb_15;

input [7:0] up_left_7;
input [7:0] up_left_cb;
input [7:0] up_left_cr;

input [14:0] PE0_sum_reg;
input [14:0] PE3_sum_reg;

output [11:0] b;
output [11:0] c;

output [14:0] seed;


reg signed [15:0] H;
reg signed [15:0] V;

reg [7:0] H_a;
reg [7:0] H_b;
reg [7:0] V_a;
reg [7:0] V_b;

reg [14:0] seed;

//FFs
reg signed [15:0] H_sum;
reg signed [15:0] V_sum;
reg [8:0] a;
reg signed [11:0] b;
reg signed [11:0] c;
reg signed [14:0] seed_0;
reg signed [14:0] seed_1;
reg signed [14:0] seed_2;

always @(posedge clk or negedge rst_n)
if (!rst_n)begin
    H_sum <= 0;
    V_sum <= 0;
end
else if (ena && blk4x4_counter == 0)begin
	if (precalc_counter == 8)begin
	    H_sum <= H;
	    V_sum <= V;
	end
	else if (precalc_counter >= 1 && precalc_counter < 8)begin
	    H_sum <= H_sum + H;
	    V_sum <= V_sum + V;
	end
end
else if(ena) begin
	if (precalc_counter == 4)begin
	    H_sum <= H;
	    V_sum <= V;
	end
	else if (precalc_counter >= 1 && precalc_counter < 4)begin
	    H_sum <= H_sum + H;
	    V_sum <= V_sum + V;
	end
end

always @(*)
if(blk4x4_counter == 0) begin
	case (precalc_counter)
	8:begin
	    H_a <= up_mb_15;    H_b <= up_left_7;
	    V_a <= left_mb_15;  V_b <= up_left_7;
	end
	7:begin
	    H_a <= up_mb_14;    H_b <= up_mb_0;
	    V_a <= left_mb_14;  V_b <= left_mb_0;
	end
	6:begin
	    H_a <= up_mb_13;    H_b <= up_mb_1;
	    V_a <= left_mb_13;  V_b <= left_mb_1;
	end
	5:begin
	    H_a <= up_mb_12;    H_b <= up_mb_2;
	    V_a <= left_mb_12;  V_b <= left_mb_2;
	end
	4:begin
	    H_a <= up_mb_11;    H_b <= up_mb_3;
	    V_a <= left_mb_11;  V_b <= left_mb_3;
	end
	3:begin
	    H_a <= up_mb_10;    H_b <= up_mb_4;
	    V_a <= left_mb_10;  V_b <= left_mb_4;
	end
	2:begin
	    H_a <= up_mb_9;     H_b <= up_mb_5;
	    V_a <= left_mb_9;   V_b <= left_mb_5;
	end
	1:begin
	    H_a <= up_mb_8;     H_b <= up_mb_6;
	    V_a <= left_mb_8;   V_b <= left_mb_6;
	end
	default:begin
	    H_a <= 0;   H_b <= 0;
	    V_a <= 0;   V_b <= 0;
	end
	endcase
end
else begin
	case (precalc_counter)
	4:begin
	    H_a <= up_mb_7;    H_b <= blk4x4_counter == 16?up_left_cb:up_left_cr;
	    V_a <= left_mb_7;  V_b <= blk4x4_counter == 16?up_left_cb:up_left_cr;
	end
	3:begin
	    H_a <= up_mb_6;    H_b <= up_mb_0;
	    V_a <= left_mb_6;  V_b <= left_mb_0;
	end
	2:begin
	    H_a <= up_mb_5;     H_b <= up_mb_1;
	    V_a <= left_mb_5;   V_b <= left_mb_1;
	end
	1:begin
	    H_a <= up_mb_4;     H_b <= up_mb_2;
	    V_a <= left_mb_4;   V_b <= left_mb_2;
	end
	default:begin
	    H_a <= 0;   H_b <= 0;
	    V_a <= 0;   V_b <= 0;
	end
	endcase
end

always @(*)
begin
    H <= precalc_counter*(H_a - H_b);
    V <= precalc_counter*(V_a - V_b);
end

always @(posedge clk or negedge rst_n)
if (!rst_n)begin
	a <= 0;
	b <= 0;
	c <= 0;
end
else if (ena && abc_latch)begin
	if (blk4x4_counter == 0) begin
		a <= (up_mb_15 + left_mb_15);
	    b <= ((H_sum <<< 2) + H_sum + 32)>>>6;
	    c <= ((V_sum <<< 2) + V_sum + 32)>>>6;
	end
	else begin
		a <= (up_mb_7 + left_mb_7);
	    b <= ((H_sum <<< 4) + H_sum + 16)>>>5;
	    c <= ((V_sum <<< 4) + V_sum + 16)>>>5;	
	end
end


//seed for blk 0, 2, 4, 8, 10, 12 ,14, 16, 18, 20, 22 is needed by intra_pred_PE

//|seed      |seed+1*b         |seed+2*b        |seed+3*b|seed+4*b |seed+5*b|seed+6*b|seed+7*b         
//|seed+1*c  |seed+1*b+1*c     |seed+2*b+1*c    |        |         |        |        |         
//|seed+2*c  |seed+1*b+2*c     |seed+2*b+2*c    |        |         |        |        |         
//|seed+3*c  |seed+1*b+3*c     |seed+2*b+3*c    |        |         |        |        |         


always @ (posedge clk or negedge rst_n)
if (!rst_n)begin
	seed_0 <= 0;
	seed_1 <= 0;
	seed_2 <= 0;
end
else if (ena) begin
	if(seed_latch && blk4x4_counter == 0)//generate seed for blk 0
		seed_0 <= {1'b0,a,4'b0} - {b,3'b0} - {c,3'b0} + {{3{b[11]}},b} + {{3{c[11]}},c};  //16 * a - 7 * b - 7 * c
	else if(seed_latch) //generate seed for blk 16, 20
		seed_0 <= {1'b0,a,4'b0} - {b[11],b,2'b0} - {c[11],c,2'b0} + {{3{b[11]}},b} + {{3{c[11]}},c}; //16 * a - 3 * b - 3 * c
	else if (seed_wr)
		case (blk4x4_counter)
			0,2,8,16,20	:seed_0 <= PE3_sum_reg+{{3{c[11]}},c};	//generate seed for blk 2, 8, 10, 18, 22 
			1,9			:seed_1 <= PE0_sum_reg+{{3{b[11]}},b};  //generate seed for blk 4, 12
			3,11		:seed_2 <= PE0_sum_reg+{{3{b[11]}},b};  //generate seed for blk 6, 14
		endcase
end

always @ (*)
case (blk4x4_counter)
	4,12	:seed <= seed_1;
	6,14	:seed <= seed_2;
	default :seed <= seed_0;
endcase

endmodule
