//--------------------------------------------------------------------------------------------------
// Design    : bitstream_p
// Author(s) : qiu bin, shi tian qi
// Email     : chat1@126.com, tishi1@126.com
// Copyright (C) 2013 qiu bin 
// All rights reserved                
//-------------------------------------------------------------------------------------------------


`include "defines.v"

module transform_top
(
	clk,
	rst_n,
	ena,
	start,
	QP,
	QP_C,
	residual_state,
	luma4x4BlkIdx_residual,
	chroma4x4BlkIdx_residual,
	start_of_MB,
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
	TotalCoeff,
	residual_out_0,
	residual_out_1,
	residual_out_2,
	residual_out_3,
	residual_out_4,
	residual_out_5,
	residual_out_6,
	residual_out_7,
	residual_out_8,
	residual_out_9,
	residual_out_10,
	residual_out_11,
	residual_out_12,
	residual_out_13,
	residual_out_14,
	residual_out_15,
	valid
);

//----------------------
//ports
//----------------------
input	clk;
input	rst_n;
input	ena;
input   start;
input	[5:0] QP;
input	[5:0] QP_C;
input   [3:0] residual_state;
input   [3:0] luma4x4BlkIdx_residual;
input   [1:0] chroma4x4BlkIdx_residual;
input	start_of_MB;
input   [15:0]	coeff_0; 
input	[15:0]	coeff_1; 
input	[15:0]	coeff_2; 
input	[15:0]	coeff_3; 
input	[15:0]	coeff_4;
input	[15:0]	coeff_5; 
input	[15:0]	coeff_6; 
input	[15:0]	coeff_7; 
input	[15:0]	coeff_8; 
input	[15:0]	coeff_9; 
input	[15:0]	coeff_10;
input	[15:0]	coeff_11;
input	[15:0]	coeff_12;
input	[15:0]	coeff_13;
input	[15:0]	coeff_14;
input	[15:0]	coeff_15;
input   [4:0]   TotalCoeff;

output  [8:0]	residual_out_0; 
output	[8:0]	residual_out_1; 
output	[8:0]	residual_out_2; 
output	[8:0]	residual_out_3; 
output	[8:0]	residual_out_4; 
output	[8:0]	residual_out_5; 
output	[8:0]	residual_out_6; 
output	[8:0]	residual_out_7; 
output	[8:0]	residual_out_8; 
output	[8:0]	residual_out_9; 
output	[8:0]	residual_out_10;
output	[8:0]	residual_out_11;
output	[8:0]	residual_out_12;
output	[8:0]	residual_out_13;
output	[8:0]	residual_out_14;
output	[8:0]	residual_out_15;
output valid;


//-----------------------
//inverse_zigzag
//-----------------------
wire [2:0] block_type;
wire [15:0] curr_DC;
wire [2:0] counter;

wire [15:0] inverse_zigzag_out_0;
wire [15:0] inverse_zigzag_out_1;
wire [15:0] inverse_zigzag_out_2;
wire [15:0] inverse_zigzag_out_3;

transform_inverse_zigzag transform_inverse_zigzag
(
	.col_counter(counter[1:0]),
	.block_type(block_type),
	.curr_DC(curr_DC),
	.coeff_0(coeff_0),
	.coeff_1(coeff_1),
	.coeff_2(coeff_2),
	.coeff_3(coeff_3),
	.coeff_4(coeff_4),
	.coeff_5(coeff_5),
	.coeff_6(coeff_6),
	.coeff_7(coeff_7),
	.coeff_8(coeff_8),
	.coeff_9(coeff_9),
	.coeff_10(coeff_10),
	.coeff_11(coeff_11),
	.coeff_12(coeff_12),
	.coeff_13(coeff_13),
	.coeff_14(coeff_14),
	.coeff_15(coeff_15),
	.inverse_zigzag_out_0(inverse_zigzag_out_0),
	.inverse_zigzag_out_1(inverse_zigzag_out_1),
	.inverse_zigzag_out_2(inverse_zigzag_out_2),
	.inverse_zigzag_out_3(inverse_zigzag_out_3)
);



//------------------
// inverse_quant
//------------------
wire [5:0] curr_QP;

wire [15:0] IQ_in_0; 
wire [15:0] IQ_in_1; 
wire [15:0] IQ_in_2; 
wire [15:0] IQ_in_3; 

wire [15:0] IQ_out_0;
wire [15:0] IQ_out_1;
wire [15:0] IQ_out_2;
wire [15:0] IQ_out_3; 
 
transform_inverse_quant transform_inverse_quant
(
	.block_type(block_type),
	.QP(curr_QP),
	.counter(counter[1:0]),
	
	.p_in_0(IQ_in_0),
	.p_in_1(IQ_in_1),
	.p_in_2(IQ_in_2),
	.p_in_3(IQ_in_3),
		
	.p_out_0(IQ_out_0), 
	.p_out_1(IQ_out_1),
	.p_out_2(IQ_out_2),
	.p_out_3(IQ_out_3)
);

wire IQ_wr_comb;
wire [15:0] oneD_out_0;
wire [15:0] oneD_out_1;
wire [15:0] oneD_out_2;
wire [15:0] oneD_out_3;

transform_prepare_IQ transform_prepare_IQ
(
	.IQ_wr(IQ_wr_comb),
	.block_type(block_type),
	.inverse_zigzag_out_0(inverse_zigzag_out_0),
	.inverse_zigzag_out_1(inverse_zigzag_out_1),
	.inverse_zigzag_out_2(inverse_zigzag_out_2),
	.inverse_zigzag_out_3(inverse_zigzag_out_3),
	.oneD_out_0(oneD_out_0),
	.oneD_out_1(oneD_out_1), 
	.oneD_out_2(oneD_out_2),
	.oneD_out_3(oneD_out_3),
	.IQ_in_0(IQ_in_0),
	.IQ_in_1(IQ_in_1),
	.IQ_in_2(IQ_in_2),
	.IQ_in_3(IQ_in_3)
);

//----------------------
// butterfly
//----------------------
wire [15:0] butterfly_in_0;
wire [15:0] butterfly_in_1;
wire [15:0] butterfly_in_2;
wire [15:0] butterfly_in_3;

wire [15:0] butterfly_out_0;
wire [15:0] butterfly_out_1;
wire [15:0] butterfly_out_2;
wire [15:0] butterfly_out_3;

wire [3:0]  state;

transform_butterfly transform_butterfly
(
	.DHT_sel(state[`transform_DHT_bit]),
	.butterfly_in_0(butterfly_in_0),
	.butterfly_in_1(butterfly_in_1),
	.butterfly_in_2(butterfly_in_2),
	.butterfly_in_3(butterfly_in_3),
	.butterfly_out_0(butterfly_out_0),
	.butterfly_out_1(butterfly_out_1),
	.butterfly_out_2(butterfly_out_2),
	.butterfly_out_3(butterfly_out_3)
);


transform_prepare_butterfly transform_prepare_butterfly
(
	.oneD_sel(counter[2]),
	.state(state),
	
	.inverse_zigzag_out_0(inverse_zigzag_out_0),
	.inverse_zigzag_out_1(inverse_zigzag_out_1),
	.inverse_zigzag_out_2(inverse_zigzag_out_2),
	.inverse_zigzag_out_3(inverse_zigzag_out_3),
	
	.oneD_out_0(oneD_out_0),
	.oneD_out_1(oneD_out_1),
	.oneD_out_2(oneD_out_2),
	.oneD_out_3(oneD_out_3),
    
	.butterfly_in_0(butterfly_in_0),
	.butterfly_in_1(butterfly_in_1),
	.butterfly_in_2(butterfly_in_2),
	.butterfly_in_3(butterfly_in_3)
);

//---------------------
// regs
//---------------------
wire AC_all_0_wr_comb;
wire DHT_wr_comb;
wire IDCT_wr_comb;
wire rd_comb;

transform_regs transform_regs
(
	.clk(clk),
	.rst_n(rst_n),
	.ena(ena),
	
	.curr_DC(curr_DC),

	.AC_all_0_wr(AC_all_0_wr_comb),
	.IQ_wr(IQ_wr_comb),
	.DHT_wr(DHT_wr_comb),
	.IDCT_wr(IDCT_wr_comb),
		
	.wr_col(counter[2]),
	.wr_idx(counter[1:0]),

	.rd_idx(counter[1:0]),
	.rd(rd_comb),
	.rd_col(counter[2]),
	.block_type(block_type),

	.IQ_out_0(IQ_out_0),
	.IQ_out_1(IQ_out_1),
	.IQ_out_2(IQ_out_2),
	.IQ_out_3(IQ_out_3),
	.butterfly_out_0(butterfly_out_0),
	.butterfly_out_1(butterfly_out_1),
	.butterfly_out_2(butterfly_out_2),
	.butterfly_out_3(butterfly_out_3),
	
	.data_out_0(oneD_out_0),
	.data_out_1(oneD_out_1),
	.data_out_2(oneD_out_2),
	.data_out_3(oneD_out_3),
	
	.rounding_out_0(residual_out_0),
	.rounding_out_1(residual_out_1),
	.rounding_out_2(residual_out_2),
	.rounding_out_3(residual_out_3),
	.rounding_out_4(residual_out_4),
	.rounding_out_5(residual_out_5),
	.rounding_out_6(residual_out_6),
	.rounding_out_7(residual_out_7),
	.rounding_out_8(residual_out_8),
	.rounding_out_9(residual_out_9),
	.rounding_out_10(residual_out_10),
	.rounding_out_11(residual_out_11),
	.rounding_out_12(residual_out_12),
	.rounding_out_13(residual_out_13),
	.rounding_out_14(residual_out_14),
	.rounding_out_15(residual_out_15)	
);

wire [3:0]  DC_rd_idx;
wire DC_wr_comb;

transform_DC_regs transform_DC_regs
(
	.clk(clk),
	.rst_n(rst_n),
	.ena(ena),
	.residual_state(residual_state),
	.wr(DC_wr_comb),
	.wr_idx(counter[1:0]),
	.clr(start_of_MB),
	.rd_idx(DC_rd_idx),
	.rd(start),
	.data_in_0(IQ_out_0),
	.data_in_1(IQ_out_1),
	.data_in_2(IQ_out_2),
	.data_in_3(IQ_out_3),
	
	.data_out(curr_DC)
);

//-----------------------
// transform_fsm
//-----------------------
transform_fsm transform_fsm
(
	.clk(clk),
	.rst_n(rst_n),
	.ena(ena),
	.start(start),
	.TotalCoeff(TotalCoeff),
	.residual_state(residual_state),
	.luma4x4BlkIdx_residual(luma4x4BlkIdx_residual),
	.chroma4x4BlkIdx_residual(chroma4x4BlkIdx_residual),
	.QP(QP),
	.QP_C(QP_C),
	.curr_QP(curr_QP),
	.state(state),
	.block_type(block_type),
	.counter(counter),
	.AC_all_0_wr_comb(AC_all_0_wr_comb),
	.DC_wr_comb(DC_wr_comb),
	.DC_rd_idx(DC_rd_idx),
	.IQ_wr_comb(IQ_wr_comb),
	.DHT_wr_comb(DHT_wr_comb),
	.IDCT_wr_comb(IDCT_wr_comb),
	.rd_comb(rd_comb),
	.valid(valid)
);
endmodule

module transform_prepare_butterfly
(
	oneD_sel,
	state,	
	inverse_zigzag_out_0,
	inverse_zigzag_out_1,
	inverse_zigzag_out_2,
	inverse_zigzag_out_3,
	
	oneD_out_0,
	oneD_out_1,
	oneD_out_2,
	oneD_out_3,
    
	butterfly_in_0,
	butterfly_in_1,
	butterfly_in_2,
	butterfly_in_3
);
input oneD_sel;
input [3:0] state;

input [15:0] inverse_zigzag_out_0;
input [15:0] inverse_zigzag_out_1;
input [15:0] inverse_zigzag_out_2;
input [15:0] inverse_zigzag_out_3;
    
input [15:0] oneD_out_0;
input [15:0] oneD_out_1;
input [15:0] oneD_out_2;
input [15:0] oneD_out_3;

output [15:0] butterfly_in_0; 
output [15:0] butterfly_in_1;
output [15:0] butterfly_in_2;
output [15:0] butterfly_in_3;

reg [15:0] butterfly_in_0; 
reg [15:0] butterfly_in_1;
reg [15:0] butterfly_in_2;
reg [15:0] butterfly_in_3;

always @(*)
if (state == `transform_DHT_s) begin
    butterfly_in_0 = oneD_sel ? inverse_zigzag_out_0 : oneD_out_0;
    butterfly_in_1 = oneD_sel ? inverse_zigzag_out_1 : oneD_out_1;
    butterfly_in_2 = oneD_sel ? inverse_zigzag_out_2 : oneD_out_2;
    butterfly_in_3 = oneD_sel ? inverse_zigzag_out_3 : oneD_out_3;
end
else if (state == `transform_IDCT_s) begin
    butterfly_in_0 = oneD_out_0;
    butterfly_in_1 = oneD_out_1;
    butterfly_in_2 = oneD_out_2;
    butterfly_in_3 = oneD_out_3;
end
else if (state == `transform_DHT2_s) begin
    butterfly_in_0 = inverse_zigzag_out_0;
    butterfly_in_1 = inverse_zigzag_out_1;
    butterfly_in_2 = inverse_zigzag_out_2;
    butterfly_in_3 = inverse_zigzag_out_3;
end
else begin
    butterfly_in_0 = 0;
    butterfly_in_1 = 0;
    butterfly_in_2 = 0;   
    butterfly_in_3 = 0;   
end

endmodule

module transform_prepare_IQ
(
	IQ_wr,
	block_type,
	inverse_zigzag_out_0,
	inverse_zigzag_out_1,
	inverse_zigzag_out_2,
	inverse_zigzag_out_3,
	oneD_out_0,
	oneD_out_1, 
	oneD_out_2,
	oneD_out_3,
	IQ_in_0,
	IQ_in_1,
	IQ_in_2,
	IQ_in_3
);
input       IQ_wr;
input [2:0] block_type;
input [15:0] inverse_zigzag_out_0;
input [15:0] inverse_zigzag_out_1;
input [15:0] inverse_zigzag_out_2;
input [15:0] inverse_zigzag_out_3;

input [15:0] oneD_out_0;
input [15:0] oneD_out_1;
input [15:0] oneD_out_2;
input [15:0] oneD_out_3;
                     
output [15:0] IQ_in_0;    
output [15:0] IQ_in_1;    
output [15:0] IQ_in_2;    
output [15:0] IQ_in_3;    
      
reg [15:0] IQ_in_0;        
reg [15:0] IQ_in_1;  
reg [15:0] IQ_in_2;  
reg [15:0] IQ_in_3;  


always @(*)
if (IQ_wr == 0) begin
	IQ_in_0 = 0;
	IQ_in_1 = 0;
	IQ_in_2 = 0;
	IQ_in_3 = 0;	
end
else if (block_type == 1 || block_type == 5) begin
	IQ_in_0 = oneD_out_0;
	IQ_in_1 = oneD_out_1;
	IQ_in_2 = oneD_out_2;
	IQ_in_3 = oneD_out_3;
end
else begin
	IQ_in_0 = inverse_zigzag_out_0;
	IQ_in_1 = inverse_zigzag_out_1;
	IQ_in_2 = inverse_zigzag_out_2;
	IQ_in_3 = inverse_zigzag_out_3;	
end

endmodule
