//--------------------------------------------------------------------------------------------------
// Design    : bitstream_p
// Author(s) : qiu bin, shi tian qi
// Email     : chat1@126.com, tishi1@126.com
// Copyright (C) 2013 qiu bin 
// All rights reserved                
//-------------------------------------------------------------------------------------------------


module residual_top 
(
    clk,
    rst_n,
    ena,
    
    residual_start,
    rbsp,
    nC,
    max_coeff_num,
    residual_state,
    luma4x4BlkIdx_residual,
    chroma4x4BlkIdx_residual,
    start_of_MB,
    qp,
    qp_c,
    
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
    TotalCoeff,
    len_comb,
    cavlc_idle,
    residual_valid
);
//------------------------
// ports
//------------------------
input   clk, rst_n;
input   ena;
input   residual_start;
input   [0:15]  rbsp;
input   signed [5:0]    nC;
input   [4:0]   max_coeff_num;
input   [3:0]   luma4x4BlkIdx_residual;
input   [1:0]   chroma4x4BlkIdx_residual;
input 	start_of_MB;

input   [3:0]   residual_state;
input   [5:0]   qp;
input   [5:0]   qp_c;

output  signed [8:0]    residual_0;
output  signed [8:0]    residual_1;
output  signed [8:0]    residual_2;
output  signed [8:0]    residual_3;
output  signed [8:0]    residual_4;
output  signed [8:0]    residual_5;
output  signed [8:0]    residual_6;
output  signed [8:0]    residual_7;
output  signed [8:0]    residual_8;
output  signed [8:0]    residual_9;
output  signed [8:0]    residual_10;
output  signed [8:0]    residual_11;
output  signed [8:0]    residual_12;
output  signed [8:0]    residual_13;
output  signed [8:0]    residual_14;
output  signed [8:0]    residual_15;            
            


output  [4:0]   TotalCoeff;
output  [4:0]   len_comb;
output  cavlc_idle;
output  residual_valid;

wire cavlc_start;
wire signed [11:0]    coeff_0; 
wire signed [11:0]    coeff_1; 
wire signed [11:0]    coeff_2; 
wire signed [11:0]    coeff_3; 
wire signed [11:0]    coeff_4; 
wire signed [11:0]    coeff_5; 
wire signed [11:0]    coeff_6; 
wire signed [11:0]    coeff_7; 
wire signed [11:0]    coeff_8; 
wire signed [11:0]    coeff_9; 
wire signed [11:0]    coeff_10;
wire signed [11:0]    coeff_11;
wire signed [11:0]    coeff_12;
wire signed [11:0]    coeff_13;
wire signed [11:0]    coeff_14;
wire signed [11:0]    coeff_15;
wire cavlc_valid;

cavlc_top cavlc_dut(
    .clk(clk),
    .rst_n(rst_n),
    .ena(ena),
    .start(cavlc_start),
    .rbsp(rbsp),
    .nC(nC),
    .max_coeff_num(max_coeff_num),

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
    .TotalCoeff(TotalCoeff),
    .len_comb(len_comb),
    .idle(cavlc_idle),
    .valid(cavlc_valid)
);

wire transform_start;
wire transform_valid;
transform_top transform_dut(
    .clk(clk),
    .rst_n(rst_n),
    .ena(ena),
    .start(transform_start),
	.QP(qp),
	.QP_C(qp_c),
    .residual_state(residual_state),
    .luma4x4BlkIdx_residual(luma4x4BlkIdx_residual),
    .chroma4x4BlkIdx_residual(chroma4x4BlkIdx_residual),
    .start_of_MB(start_of_MB),
    .coeff_0({{4{coeff_0[11]}},coeff_0}), 
    .coeff_1({{4{coeff_1[11]}},coeff_1}),
    .coeff_2({{4{coeff_2[11]}},coeff_2}),
    .coeff_3({{4{coeff_3[11]}},coeff_3}),
    .coeff_4({{4{coeff_4[11]}},coeff_4}),
    .coeff_5({{4{coeff_5[11]}},coeff_5}),
    .coeff_6({{4{coeff_6[11]}},coeff_6}),
    .coeff_7({{4{coeff_7[11]}},coeff_7}),
    .coeff_8({{4{coeff_8[11]}},coeff_8}),
    .coeff_9({{4{coeff_9[11]}},coeff_9}),
    .coeff_10({{4{coeff_10[11]}},coeff_10}),
    .coeff_11({{4{coeff_11[11]}},coeff_11}),
    .coeff_12({{4{coeff_12[11]}},coeff_12}),
    .coeff_13({{4{coeff_13[11]}},coeff_13}),
    .coeff_14({{4{coeff_14[11]}},coeff_14}),
    .coeff_15({{4{coeff_15[11]}},coeff_15}),
   .TotalCoeff(TotalCoeff),
     
    .residual_out_0(residual_0),
	.residual_out_1(residual_1),
	.residual_out_2(residual_2),
	.residual_out_3(residual_3),
	.residual_out_4(residual_4),
	.residual_out_5(residual_5),
	.residual_out_6(residual_6),
	.residual_out_7(residual_7),
	.residual_out_8(residual_8),
	.residual_out_9(residual_9),
	.residual_out_10(residual_10),
	.residual_out_11(residual_11),
	.residual_out_12(residual_12),
	.residual_out_13(residual_13),
	.residual_out_14(residual_14),
	.residual_out_15(residual_15),
    .valid(transform_valid)
);

residual_ctrl residual_ctrl(
	.clk(clk),
	.rst_n(rst_n),
	.ena(ena),
	.residual_state(residual_state),
	.residual_start(residual_start),
	.residual_valid(residual_valid),
	.cavlc_start(cavlc_start),
	.cavlc_valid(cavlc_valid),
	.transform_start(transform_start),
	.transform_valid(transform_valid)
);

endmodule
