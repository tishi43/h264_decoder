//--------------------------------------------------------------------------------------------------
// Design    : bitstream_p
// Author(s) : qiu bin, shi tian qi
// Email     : chat1@126.com, tishi1@126.com
// Copyright (C) 2013 qiu bin 
// All rights reserved                
//-------------------------------------------------------------------------------------------------


//2011-8-16 initiial revision
// p[i]*dequant_coef[qp][0]+(1<<(1-qbits)) ) >> (2-qbits); 
//is performed as p[i]*dequant_coef[qp][0] >> (2-qbits));
module transform_inverse_quant
(
	block_type,
	QP,
	counter,
	
	p_in_0,
	p_in_1,
	p_in_2,
	p_in_3,
		
	p_out_0,
	p_out_1,
	p_out_2,
	p_out_3
);	
//----------------------
//ports
//----------------------
input	[5:0]	QP;
input	[2:0]	block_type;
// block_type =	1:  Intra16x16LumaDC
//				2:	Intra16x16LumaAC
//				3:  Luma4x4
//				
//				5:  ChromaDC
//				6:  ChromaAC
//	
input	[1:0] counter;
//inverse quant is performed in rows

input	signed	[15:0]	p_in_0;
input	signed	[15:0]	p_in_1;
input	signed	[15:0]	p_in_2;
input	signed	[15:0]	p_in_3;

output	signed	[15:0]	p_out_0;
output	signed	[15:0]	p_out_1;
output	signed	[15:0]	p_out_2;
output	signed	[15:0]	p_out_3;

//----------------------
//regs
//----------------------
reg 	signed	[15:0]	p_out_0;
reg 	signed	[15:0]	p_out_1;
reg 	signed	[15:0]	p_out_2;
reg 	signed	[15:0]	p_out_3;

reg		[2:0]	qp;
reg		[2:0]	l_shift_bits_num;
reg		[1:0]	r_shift_bits_num;

reg		[4:0]	dequant_coeff_0;
reg		[4:0]	dequant_coeff_1;
reg		[4:0]	dequant_coeff_2;
reg		[4:0]	dequant_coeff_3;



wire odd_col_sel;
assign odd_col_sel = counter[0];

//----------------------
// modules
//----------------------
wire signed [15:0]	mult_shift_out_0;
wire signed [15:0]	mult_shift_out_1;
wire signed [15:0]	mult_shift_out_2;
wire signed [15:0]	mult_shift_out_3;


wire		[4:0]	mult_coeff_0;
wire		[4:0]	mult_coeff_1;
wire		[4:0]	mult_coeff_2;
wire		[4:0]	mult_coeff_3;

assign mult_coeff_0 = dequant_coeff_0;
assign mult_coeff_1 = (block_type == 1 || block_type == 5)? dequant_coeff_0 : dequant_coeff_1;
assign mult_coeff_2 = (block_type == 1 || block_type == 5)? dequant_coeff_0 : dequant_coeff_2;
assign mult_coeff_3 = (block_type == 1 || block_type == 5)? dequant_coeff_0 : dequant_coeff_3;

mult_shifter mult_shifter_0
(
	p_in_0,
	mult_coeff_0,
	l_shift_bits_num,
	mult_shift_out_0
);

mult_shifter mult_shifter_1
(
	p_in_1,
	mult_coeff_1,
	l_shift_bits_num,
	mult_shift_out_1
);

mult_shifter mult_shifter_2
(
	p_in_2,
	mult_coeff_2,
	l_shift_bits_num,
	mult_shift_out_2
);

mult_shifter mult_shifter_3
(
	p_in_3,
	mult_coeff_3,
	l_shift_bits_num,
	mult_shift_out_3
);


//----------------------
// qp
//----------------------
always @ (QP)
case (QP)
	0, 6,12,18,24,30,36,42,48:qp <= 0;
	1, 7,13,19,25,31,37,43,49:qp <= 1;
	2, 8,14,20,26,32,38,44,50:qp <= 2;
	3, 9,15,21,27,33,39,45,51:qp <= 3;
	4,10,16,22,28,34,40,46   :qp <= 4;
	5,11,17,23,29,35,41,47   :qp <= 5;
	default                  :qp <= 'bx;
endcase

always @ (QP)
case (QP)
	18,19,20,21,22,23:	l_shift_bits_num <= 1;
	24,25,26,27,28,29:	l_shift_bits_num <= 2;
	30,31,32,33,34,35:	l_shift_bits_num <= 3;
	36,37,38,39,40,41:	l_shift_bits_num <= 4;
	42,43,44,45,46,47:	l_shift_bits_num <= 5;
	48,49,50,51      :	l_shift_bits_num <= 6;
	default          :	l_shift_bits_num <= 0;	//qbits <= 2
endcase

always @ (QP)
case (QP)
	0, 1, 2, 3, 4, 5 :	r_shift_bits_num <= 2;
	6, 7, 8, 9, 10,11:	r_shift_bits_num <= 1;
	default          :	r_shift_bits_num <= 0;	//qbits >= 2
endcase

//----------------------
//dequant_coef
//----------------------
always @(*)
case (qp)
	0	: begin
		dequant_coeff_0	= (odd_col_sel && block_type != 1 )? 13:10;
		dequant_coeff_1	= odd_col_sel? 16:13;
		dequant_coeff_2	= odd_col_sel? 13:10;
		dequant_coeff_3	= odd_col_sel? 16:13;																													
	end
	1	: begin
		dequant_coeff_0	= (odd_col_sel && block_type != 1 )? 14:11;
		dequant_coeff_1	= odd_col_sel? 18:14;
		dequant_coeff_2	= odd_col_sel? 14:11;
		dequant_coeff_3	= odd_col_sel? 18:14;	
	end
	2	:begin
		dequant_coeff_0	= (odd_col_sel && block_type != 1 )? 16:13;
		dequant_coeff_1	= odd_col_sel? 20:16;
		dequant_coeff_2	= odd_col_sel? 16:13;
		dequant_coeff_3	= odd_col_sel? 20:16;	
	end
	3	:begin
		dequant_coeff_0	= (odd_col_sel && block_type != 1 )? 18:14;
		dequant_coeff_1	= odd_col_sel? 23:18;
		dequant_coeff_2	= odd_col_sel? 18:14;
		dequant_coeff_3	= odd_col_sel? 23:18;	
	end
	4	:begin
		dequant_coeff_0	= (odd_col_sel && block_type != 1 )? 20:16;
		dequant_coeff_1	= odd_col_sel? 25:20;
		dequant_coeff_2	= odd_col_sel? 20:16;
		dequant_coeff_3	= odd_col_sel? 25:20;	
	end
	5	:begin
		dequant_coeff_0	= (odd_col_sel && block_type != 1 )? 23:18;
		dequant_coeff_1	= odd_col_sel? 29:23;
		dequant_coeff_2	= odd_col_sel? 23:18;
		dequant_coeff_3	= odd_col_sel? 29:23;
	end
	default:begin
		dequant_coeff_0	= 'bx;
		dequant_coeff_1	= 'bx;
		dequant_coeff_2	= 'bx;
		dequant_coeff_3	= 'bx;
	end
endcase

//----------------------
//p_out_0
//----------------------
always @(*)
case (block_type)
	1	: begin
		if (r_shift_bits_num == 2)
			p_out_0 <= mult_shift_out_0 >>> 2;
		else if (r_shift_bits_num == 1)
			p_out_0 <= mult_shift_out_0 >>> 1;
		else
			p_out_0 <= mult_shift_out_0;
	end
	3: begin
		if (r_shift_bits_num == 0)
			p_out_0 <= mult_shift_out_0 <<< 2;
		else if (r_shift_bits_num == 1)
			p_out_0 <= mult_shift_out_0 <<< 1;
		else
			p_out_0 <= mult_shift_out_0;
	end
	2,6:begin
		if (counter == 0)
			p_out_0 <= p_in_0;
		else if (r_shift_bits_num == 0)
			p_out_0 <= mult_shift_out_0 <<< 2;
		else if (r_shift_bits_num == 1)
			p_out_0 <= mult_shift_out_0 <<< 1;
		else
			p_out_0 <= mult_shift_out_0;
	end
	5	: begin
		if (r_shift_bits_num == 0)	//qbits >= 2
			p_out_0 <= mult_shift_out_0 <<< 1;
		else if (r_shift_bits_num == 1) //qbits == 1
			p_out_0 <= mult_shift_out_0;
		else	//qbits == 0
			p_out_0 <= mult_shift_out_0 >>> 1;
	end
	default : p_out_0 <= 'b0;
endcase

//----------------------
//p_out_1
//----------------------
always @(*)
case (block_type)
	1	: begin
		if (r_shift_bits_num == 2)
			p_out_1 <= mult_shift_out_1 >>> 2;
		else if (r_shift_bits_num == 1)
			p_out_1 <= mult_shift_out_1 >>> 1;
		else
			p_out_1 <= mult_shift_out_1;
	end
	2,3,6:	begin
		if (r_shift_bits_num == 0)
			p_out_1 <= mult_shift_out_1 <<< 2;
		else if (r_shift_bits_num == 1)
			p_out_1 <= mult_shift_out_1 <<< 1;
		else
			p_out_1 <= mult_shift_out_1;
	end
	5	: begin
		if (r_shift_bits_num == 0)	//qbits >= 2
			p_out_1 <= mult_shift_out_1 <<< 1;
		else if (r_shift_bits_num == 1) //qbits == 1
			p_out_1 <= mult_shift_out_1;
		else	//qbits == 0
			p_out_1 <= mult_shift_out_1 >>> 1;
	end
	default : p_out_1 <= 'b0;
endcase

//----------------------
//p_out_2
//----------------------
always @(*)
case (block_type)
	1	: begin
		if (r_shift_bits_num == 2)
			p_out_2 <= mult_shift_out_2 >>> 2;
		else if (r_shift_bits_num == 1)
			p_out_2 <= mult_shift_out_2 >>> 1;
		else
			p_out_2 <= mult_shift_out_2;
	end
	2,3,6: begin
		if (r_shift_bits_num == 0)
			p_out_2 <= mult_shift_out_2 <<< 2;
		else if (r_shift_bits_num == 1)
			p_out_2 <= mult_shift_out_2 <<< 1;
		else
			p_out_2 <= mult_shift_out_2;
	end
	5	: begin
		if (r_shift_bits_num == 0)	//qbits >= 2
			p_out_2 <= mult_shift_out_2 <<< 1;
		else if (r_shift_bits_num == 1) //qbits == 1
			p_out_2 <= mult_shift_out_2;
		else	//qbits == 0
			p_out_2 <= mult_shift_out_2 >>> 1;
	end
	default : p_out_2 <= 'b0;
endcase

//----------------------
//p_out_3
//----------------------
always @(*)
case (block_type)
	1	: begin
		if (r_shift_bits_num == 2)
			p_out_3 <= mult_shift_out_3 >>> 2;
		else if (r_shift_bits_num == 1)
			p_out_3 <= mult_shift_out_3 >>> 1;
		else
			p_out_3 <= mult_shift_out_3;
	end
	2,3,6:begin
		if (r_shift_bits_num == 0)
			p_out_3 <= mult_shift_out_3 <<< 2;
		else if (r_shift_bits_num == 1)
			p_out_3 <= mult_shift_out_3 <<< 1;
		else
			p_out_3 <= mult_shift_out_3;
	end
	5	: begin
		if (r_shift_bits_num == 0)	//qbits >= 2
			p_out_3 <= mult_shift_out_3 <<< 1;
		else if (r_shift_bits_num == 1) //qbits == 1
			p_out_3 <= mult_shift_out_3;
		else	//qbits == 0
			p_out_3 <= mult_shift_out_3 >>> 1;
	end
	default : p_out_3 <= 'b0;
endcase

endmodule

module mult_shifter
(
	p_in,
	dequant_coeff,
	l_shift_bits_num,
	mult_shift_out
);
input	signed [15:0]	p_in;
input	[4:0]	dequant_coeff;
input 	[2:0]	l_shift_bits_num;
output	signed [15:0]	mult_shift_out;
assign	mult_shift_out = p_in * dequant_coeff <<< l_shift_bits_num;
endmodule


