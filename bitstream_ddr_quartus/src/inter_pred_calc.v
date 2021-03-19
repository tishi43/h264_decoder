//--------------------------------------------------------------------------------------------------
// Design    : bitstream_p
// Author(s) : qiu bin, shi tian qi
// Email     : chat1@126.com, tishi1@126.com
// Copyright (C) 2013 qiu bin 
// All rights reserved                
//-------------------------------------------------------------------------------------------------


`include "defines.v"

module inter_pred_calc
(
	clk,
	rst_n,
	ena,
	
	calc,
	counter,
	
	chroma_cb_sel,
	chroma_cr_sel,
	
	ref_x,
	ref_y,
	
    ref_00,
    ref_01,
    ref_02,
    ref_03,
    ref_04,
    ref_05,
    ref_06,
    ref_07,
    ref_08,
    ref_10,
    ref_11,
    ref_12,
    ref_13,
    ref_14,
    ref_15,
    ref_16,
    ref_17,
    ref_18,
    ref_20,
    ref_21,
    ref_22,
    ref_23,
    ref_24,
    ref_25,
    ref_26,
    ref_27,
    ref_28,
    ref_30,
    ref_31,
    ref_32,
    ref_33,
    ref_34,
    ref_35,
    ref_36,
    ref_37,
    ref_38,
    ref_40,
    ref_41,
    ref_42,
    ref_43,
    ref_44,
    ref_45,
    ref_46,
    ref_47,
    ref_48,
    ref_50,
    ref_51,
    ref_52,
    ref_53,
    ref_54,
    ref_55,
    ref_56,
    ref_57,
    ref_58,
    ref_60,
    ref_61,
    ref_62,
    ref_63,
    ref_64,
    ref_65,
    ref_66,
    ref_67,
    ref_68,
    ref_70,
    ref_71,
    ref_72,
    ref_73,
    ref_74,
    ref_75,
    ref_76,
    ref_77,
    ref_78,
    ref_80,
    ref_81,
    ref_82,
    ref_83,
    ref_84,
    ref_85,
    ref_86,
    ref_87,
    ref_88,
	
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
	inter_pred_15
);
input  clk;
input  rst_n;
input  ena;

input  calc;
input [1:0] counter;

input  chroma_cb_sel;
input  chroma_cr_sel;

input  [2:0] ref_x;
input  [2:0] ref_y;

input [7:0] ref_00;
input [7:0] ref_01;
input [7:0] ref_02;
input [7:0] ref_03;
input [7:0] ref_04;
input [7:0] ref_05;
input [7:0] ref_06;
input [7:0] ref_07;
input [7:0] ref_08;
input [7:0] ref_10;
input [7:0] ref_11;
input [7:0] ref_12;
input [7:0] ref_13;
input [7:0] ref_14;
input [7:0] ref_15;
input [7:0] ref_16;
input [7:0] ref_17;
input [7:0] ref_18;
input [7:0] ref_20;
input [7:0] ref_21;
input [7:0] ref_22;
input [7:0] ref_23;
input [7:0] ref_24;
input [7:0] ref_25;
input [7:0] ref_26;
input [7:0] ref_27;
input [7:0] ref_28;
input [7:0] ref_30;
input [7:0] ref_31;
input [7:0] ref_32;
input [7:0] ref_33;
input [7:0] ref_34;
input [7:0] ref_35;
input [7:0] ref_36;
input [7:0] ref_37;
input [7:0] ref_38;
input [7:0] ref_40;
input [7:0] ref_41;
input [7:0] ref_42;
input [7:0] ref_43;
input [7:0] ref_44;
input [7:0] ref_45;
input [7:0] ref_46;
input [7:0] ref_47;
input [7:0] ref_48;
input [7:0] ref_50;
input [7:0] ref_51;
input [7:0] ref_52;
input [7:0] ref_53;
input [7:0] ref_54;
input [7:0] ref_55;
input [7:0] ref_56;
input [7:0] ref_57;
input [7:0] ref_58;
input [7:0] ref_60;
input [7:0] ref_61;
input [7:0] ref_62;
input [7:0] ref_63;
input [7:0] ref_64;
input [7:0] ref_65;
input [7:0] ref_66;
input [7:0] ref_67;
input [7:0] ref_68;
input [7:0] ref_70;
input [7:0] ref_71;
input [7:0] ref_72;
input [7:0] ref_73;
input [7:0] ref_74;
input [7:0] ref_75;
input [7:0] ref_76;
input [7:0] ref_77;
input [7:0] ref_78;
input [7:0] ref_80;
input [7:0] ref_81;
input [7:0] ref_82;
input [7:0] ref_83;
input [7:0] ref_84;
input [7:0] ref_85;
input [7:0] ref_86;
input [7:0] ref_87;
input [7:0] ref_88;

output [7:0] inter_pred_0; 
output [7:0] inter_pred_1; 
output [7:0] inter_pred_2; 
output [7:0] inter_pred_3; 
output [7:0] inter_pred_4; 
output [7:0] inter_pred_5; 
output [7:0] inter_pred_6; 
output [7:0] inter_pred_7; 
output [7:0] inter_pred_8; 
output [7:0] inter_pred_9; 
output [7:0] inter_pred_10;
output [7:0] inter_pred_11;
output [7:0] inter_pred_12;
output [7:0] inter_pred_13;
output [7:0] inter_pred_14;
output [7:0] inter_pred_15;

reg [7:0] inter_pred_0; 
reg [7:0] inter_pred_1; 
reg [7:0] inter_pred_2; 
reg [7:0] inter_pred_3; 
reg [7:0] inter_pred_4; 
reg [7:0] inter_pred_5; 
reg [7:0] inter_pred_6; 
reg [7:0] inter_pred_7; 
reg [7:0] inter_pred_8; 
reg [7:0] inter_pred_9; 
reg [7:0] inter_pred_10;
reg [7:0] inter_pred_11;
reg [7:0] inter_pred_12;
reg [7:0] inter_pred_13;
reg [7:0] inter_pred_14;
reg [7:0] inter_pred_15;

reg  [7:0] luma_filter0_a;
reg  [7:0] luma_filter0_b;
reg  [7:0] luma_filter0_c;
reg  [7:0] luma_filter0_d;
reg  [7:0] luma_filter0_e;
reg  [7:0] luma_filter0_f;
wire [14:0] luma_filter0_out;
wire [7:0] luma_filter0_round_out;

luma_filter luma_filter0
(
	.a(luma_filter0_a),
	.b(luma_filter0_b),
	.c(luma_filter0_c),
	.d(luma_filter0_d),
	.e(luma_filter0_e),
	.f(luma_filter0_f),
	.out(luma_filter0_out),
	.round_out(luma_filter0_round_out)
);

reg  [7:0] luma_filter1_a;
reg  [7:0] luma_filter1_b;
reg  [7:0] luma_filter1_c;
reg  [7:0] luma_filter1_d;
reg  [7:0] luma_filter1_e;
reg  [7:0] luma_filter1_f;
wire [14:0] luma_filter1_out;
wire [7:0] luma_filter1_round_out;

luma_filter luma_filter1
(
	.a(luma_filter1_a),
	.b(luma_filter1_b),
	.c(luma_filter1_c),
	.d(luma_filter1_d),
	.e(luma_filter1_e),
	.f(luma_filter1_f),
	.out(luma_filter1_out),
	.round_out(luma_filter1_round_out)
);

reg  [7:0] luma_filter2_a;
reg  [7:0] luma_filter2_b;
reg  [7:0] luma_filter2_c;
reg  [7:0] luma_filter2_d;
reg  [7:0] luma_filter2_e;
reg  [7:0] luma_filter2_f;
wire [14:0] luma_filter2_out;
wire [7:0] luma_filter2_round_out;

luma_filter luma_filter2
(
	.a(luma_filter2_a),
	.b(luma_filter2_b),
	.c(luma_filter2_c),
	.d(luma_filter2_d),
	.e(luma_filter2_e),
	.f(luma_filter2_f),
	.out(luma_filter2_out),
	.round_out(luma_filter2_round_out)
);

reg  [7:0] luma_filter3_a;
reg  [7:0] luma_filter3_b;
reg  [7:0] luma_filter3_c;
reg  [7:0] luma_filter3_d;
reg  [7:0] luma_filter3_e;
reg  [7:0] luma_filter3_f;
wire [14:0] luma_filter3_out;
wire [7:0] luma_filter3_round_out;

luma_filter luma_filter3
(
	.a(luma_filter3_a),
	.b(luma_filter3_b),
	.c(luma_filter3_c),
	.d(luma_filter3_d),
	.e(luma_filter3_e),
	.f(luma_filter3_f),
	.out(luma_filter3_out),
	.round_out(luma_filter3_round_out)
);

reg  [7:0] luma_filter4_a;
reg  [7:0] luma_filter4_b;
reg  [7:0] luma_filter4_c;
reg  [7:0] luma_filter4_d;
reg  [7:0] luma_filter4_e;
reg  [7:0] luma_filter4_f;
wire [14:0] luma_filter4_out;
wire [7:0] luma_filter4_round_out;

luma_filter luma_filter4
(
	.a(luma_filter4_a),
	.b(luma_filter4_b),
	.c(luma_filter4_c),
	.d(luma_filter4_d),
	.e(luma_filter4_e),
	.f(luma_filter4_f),
	.out(luma_filter4_out),
	.round_out(luma_filter4_round_out)
);

reg  [7:0] luma_filter5_a;
reg  [7:0] luma_filter5_b;
reg  [7:0] luma_filter5_c;
reg  [7:0] luma_filter5_d;
reg  [7:0] luma_filter5_e;
reg  [7:0] luma_filter5_f;
wire [14:0] luma_filter5_out;
wire [7:0] luma_filter5_round_out;

luma_filter luma_filter5
(
	.a(luma_filter5_a),
	.b(luma_filter5_b),
	.c(luma_filter5_c),
	.d(luma_filter5_d),
	.e(luma_filter5_e),
	.f(luma_filter5_f),
	.out(luma_filter5_out),
	.round_out(luma_filter5_round_out)
);

reg  [7:0] luma_filter6_a;
reg  [7:0] luma_filter6_b;
reg  [7:0] luma_filter6_c;
reg  [7:0] luma_filter6_d;
reg  [7:0] luma_filter6_e;
reg  [7:0] luma_filter6_f;
wire [14:0] luma_filter6_out;
wire [7:0] luma_filter6_round_out;

luma_filter luma_filter6
(
	.a(luma_filter6_a),
	.b(luma_filter6_b),
	.c(luma_filter6_c),
	.d(luma_filter6_d),
	.e(luma_filter6_e),
	.f(luma_filter6_f),
	.out(luma_filter6_out),
	.round_out(luma_filter6_round_out)
);

reg  [7:0] luma_filter7_a;
reg  [7:0] luma_filter7_b;
reg  [7:0] luma_filter7_c;
reg  [7:0] luma_filter7_d;
reg  [7:0] luma_filter7_e;
reg  [7:0] luma_filter7_f;
wire [14:0] luma_filter7_out;
wire [7:0] luma_filter7_round_out;

luma_filter luma_filter7
(
	.a(luma_filter7_a),
	.b(luma_filter7_b),
	.c(luma_filter7_c),
	.d(luma_filter7_d),
	.e(luma_filter7_e),
	.f(luma_filter7_f),
	.out(luma_filter7_out),
	.round_out(luma_filter7_round_out)
);

reg  [7:0] luma_filter8_a;
reg  [7:0] luma_filter8_b;
reg  [7:0] luma_filter8_c;
reg  [7:0] luma_filter8_d;
reg  [7:0] luma_filter8_e;
reg  [7:0] luma_filter8_f;
wire [14:0] luma_filter8_out;
wire [7:0] luma_filter8_round_out;

luma_filter luma_filter8
(
	.a(luma_filter8_a),
	.b(luma_filter8_b),
	.c(luma_filter8_c),
	.d(luma_filter8_d),
	.e(luma_filter8_e),
	.f(luma_filter8_f),
	.out(luma_filter8_out),
	.round_out(luma_filter8_round_out)
);


reg  [14:0] luma_filter9_a;
reg  [14:0] luma_filter9_b;
reg  [14:0] luma_filter9_c;
reg  [14:0] luma_filter9_d;
reg  [14:0] luma_filter9_e;
reg  [14:0] luma_filter9_f;
wire [7:0] luma_filter9_round_out;

luma_filter2 luma_filter9
(
	.a(luma_filter9_a),
	.b(luma_filter9_b),
	.c(luma_filter9_c),
	.d(luma_filter9_d),
	.e(luma_filter9_e),
	.f(luma_filter9_f),
	.round_out(luma_filter9_round_out)
);
//
reg  [14:0] luma_filter10_a;
reg  [14:0] luma_filter10_b;
reg  [14:0] luma_filter10_c;
reg  [14:0] luma_filter10_d;
reg  [14:0] luma_filter10_e;
reg  [14:0] luma_filter10_f;
wire [7:0] luma_filter10_round_out;

luma_filter2 luma_filter10
(
	.a(luma_filter10_a),
	.b(luma_filter10_b),
	.c(luma_filter10_c),
	.d(luma_filter10_d),
	.e(luma_filter10_e),
	.f(luma_filter10_f),
	.round_out(luma_filter10_round_out)
);

reg  [14:0] luma_filter11_a;
reg  [14:0] luma_filter11_b;
reg  [14:0] luma_filter11_c;
reg  [14:0] luma_filter11_d;
reg  [14:0] luma_filter11_e;
reg  [14:0] luma_filter11_f;
wire [7:0] luma_filter11_round_out;

luma_filter2 luma_filter11
(
	.a(luma_filter11_a),
	.b(luma_filter11_b),
	.c(luma_filter11_c),
	.d(luma_filter11_d),
	.e(luma_filter11_e),
	.f(luma_filter11_f),
	.round_out(luma_filter11_round_out)
);

reg  [14:0] luma_filter12_a;
reg  [14:0] luma_filter12_b;
reg  [14:0] luma_filter12_c;
reg  [14:0] luma_filter12_d;
reg  [14:0] luma_filter12_e;
reg  [14:0] luma_filter12_f;
wire [7:0] luma_filter12_round_out;

luma_filter2 luma_filter12
(
	.a(luma_filter12_a),
	.b(luma_filter12_b),
	.c(luma_filter12_c),
	.d(luma_filter12_d),
	.e(luma_filter12_e),
	.f(luma_filter12_f),
	.round_out(luma_filter12_round_out)
);

reg  [7:0] chroma_filter0_a;
reg  [7:0] chroma_filter0_b;
reg  [7:0] chroma_filter0_c;
reg  [7:0] chroma_filter0_d;
wire [7:0] chroma_filter0_out;

chroma_filter chroma_filter0
(
	.dx(ref_x[2:0]),
	.dy(ref_y[2:0]),
	.a(chroma_filter0_a),
	.b(chroma_filter0_b),
	.c(chroma_filter0_c),
	.d(chroma_filter0_d),
	.out(chroma_filter0_out)
);

reg  [7:0] chroma_filter1_a;
reg  [7:0] chroma_filter1_b;
reg  [7:0] chroma_filter1_c;
reg  [7:0] chroma_filter1_d;
wire [7:0] chroma_filter1_out;

chroma_filter chroma_filter1
(
	.dx(ref_x[2:0]),
	.dy(ref_y[2:0]),
	.a(chroma_filter1_a),
	.b(chroma_filter1_b),
	.c(chroma_filter1_c),
	.d(chroma_filter1_d),
	.out(chroma_filter1_out)
);

reg  [7:0] chroma_filter2_a;
reg  [7:0] chroma_filter2_b;
reg  [7:0] chroma_filter2_c;
reg  [7:0] chroma_filter2_d;
wire [7:0] chroma_filter2_out;

chroma_filter chroma_filter2
(
	.dx(ref_x[2:0]),
	.dy(ref_y[2:0]),
	.a(chroma_filter2_a),
	.b(chroma_filter2_b),
	.c(chroma_filter2_c),
	.d(chroma_filter2_d),
	.out(chroma_filter2_out)
);

reg  [7:0] chroma_filter3_a;
reg  [7:0] chroma_filter3_b;
reg  [7:0] chroma_filter3_c;
reg  [7:0] chroma_filter3_d;
wire [7:0] chroma_filter3_out;

chroma_filter chroma_filter3
(
	.dx(ref_x[2:0]),
	.dy(ref_y[2:0]),
	.a(chroma_filter3_a),
	.b(chroma_filter3_b),
	.c(chroma_filter3_c),
	.d(chroma_filter3_d),
	.out(chroma_filter3_out)
);

always @(*)
if (calc && !chroma_cb_sel && !chroma_cr_sel) begin
	if (ref_x[1:0] == 0) begin
		case(counter)
		3:begin
			luma_filter0_a <= ref_00;
			luma_filter0_b <= ref_10;
			luma_filter0_c <= ref_20;
			luma_filter0_d <= ref_30;
			luma_filter0_e <= ref_40;
			luma_filter0_f <= ref_50;
		end
		2:begin
			luma_filter0_a <= ref_10;
			luma_filter0_b <= ref_20;
			luma_filter0_c <= ref_30;
			luma_filter0_d <= ref_40;
			luma_filter0_e <= ref_50;
			luma_filter0_f <= ref_60;
		end
		1:begin
			luma_filter0_a <= ref_20;
			luma_filter0_b <= ref_30;
			luma_filter0_c <= ref_40;
			luma_filter0_d <= ref_50;
			luma_filter0_e <= ref_60;
			luma_filter0_f <= ref_70;
		end
		0:begin
			luma_filter0_a <= ref_30;
			luma_filter0_b <= ref_40;
			luma_filter0_c <= ref_50;
			luma_filter0_d <= ref_60;
			luma_filter0_e <= ref_70;
			luma_filter0_f <= ref_80;
		end
		endcase
	end
	else if (ref_y[1:0] == 0) begin
		case(counter)
		3:begin
			luma_filter0_a <= ref_00;
			luma_filter0_b <= ref_01;
			luma_filter0_c <= ref_02;
			luma_filter0_d <= ref_03;
			luma_filter0_e <= ref_04;
			luma_filter0_f <= ref_05;
		end
		2:begin
			luma_filter0_a <= ref_10;
			luma_filter0_b <= ref_11;
			luma_filter0_c <= ref_12;
			luma_filter0_d <= ref_13;
			luma_filter0_e <= ref_14;
			luma_filter0_f <= ref_15;
		end
		1:begin
			luma_filter0_a <= ref_20;
			luma_filter0_b <= ref_21;
			luma_filter0_c <= ref_22;
			luma_filter0_d <= ref_23;
			luma_filter0_e <= ref_24;
			luma_filter0_f <= ref_25;
		end
		0:begin
			luma_filter0_a <= ref_30;
			luma_filter0_b <= ref_31;
			luma_filter0_c <= ref_32;
			luma_filter0_d <= ref_33;
			luma_filter0_e <= ref_34;
			luma_filter0_f <= ref_35;
		end
		endcase
	end
	else if (ref_x[1:0] == 2) begin
		case(counter)
		3:begin
			luma_filter0_a <= ref_00;
			luma_filter0_b <= ref_01;
			luma_filter0_c <= ref_02;
			luma_filter0_d <= ref_03;
			luma_filter0_e <= ref_04;
			luma_filter0_f <= ref_05;
		end
		2:begin
			luma_filter0_a <= ref_01;
			luma_filter0_b <= ref_02;
			luma_filter0_c <= ref_03;
			luma_filter0_d <= ref_04;
			luma_filter0_e <= ref_05;
			luma_filter0_f <= ref_06;
		end
		1:begin
			luma_filter0_a <= ref_02;
			luma_filter0_b <= ref_03;
			luma_filter0_c <= ref_04;
			luma_filter0_d <= ref_05;
			luma_filter0_e <= ref_06;
			luma_filter0_f <= ref_07;
		end
		0:begin
			luma_filter0_a <= ref_03;
			luma_filter0_b <= ref_04;
			luma_filter0_c <= ref_05;
			luma_filter0_d <= ref_06;
			luma_filter0_e <= ref_07;
			luma_filter0_f <= ref_08;
		end
		endcase
	end
	else if (ref_y[1:0] == 2) begin
		case(counter)
		3:begin
			luma_filter0_a <= ref_00;
			luma_filter0_b <= ref_10;
			luma_filter0_c <= ref_20;
			luma_filter0_d <= ref_30;
			luma_filter0_e <= ref_40;
			luma_filter0_f <= ref_50;
		end                        
		2:begin                    
			luma_filter0_a <= ref_10;
			luma_filter0_b <= ref_20;
			luma_filter0_c <= ref_30;
			luma_filter0_d <= ref_40;
			luma_filter0_e <= ref_50;
			luma_filter0_f <= ref_60;
		end                        
		1:begin                    
			luma_filter0_a <= ref_20;
			luma_filter0_b <= ref_30;
			luma_filter0_c <= ref_40;
			luma_filter0_d <= ref_50;
			luma_filter0_e <= ref_60;
			luma_filter0_f <= ref_70;
		end                        
		0:begin                    
			luma_filter0_a <= ref_30;
			luma_filter0_b <= ref_40;
			luma_filter0_c <= ref_50;
			luma_filter0_d <= ref_60;
			luma_filter0_e <= ref_70;
			luma_filter0_f <= ref_80;
		end                        
		endcase                    
	end                            
	else if (ref_x[1:0] == 1 && ref_y[1:0] == 1  ||
	         ref_x[1:0] == 1 && ref_y[1:0] == 3 ) begin
		case(counter)              
		3:begin
			luma_filter0_a <= ref_02;
			luma_filter0_b <= ref_12;
			luma_filter0_c <= ref_22;
			luma_filter0_d <= ref_32;
			luma_filter0_e <= ref_42;
			luma_filter0_f <= ref_52;
		end
		2:begin
			luma_filter0_a <= ref_12;
			luma_filter0_b <= ref_22;
			luma_filter0_c <= ref_32;
			luma_filter0_d <= ref_42;
			luma_filter0_e <= ref_52;
			luma_filter0_f <= ref_62;
		end
		1:begin
			luma_filter0_a <= ref_22;
			luma_filter0_b <= ref_32;
			luma_filter0_c <= ref_42;
			luma_filter0_d <= ref_52;
			luma_filter0_e <= ref_62;
			luma_filter0_f <= ref_72;
		end
		0:begin
			luma_filter0_a <= ref_32;
			luma_filter0_b <= ref_42;
			luma_filter0_c <= ref_52;
			luma_filter0_d <= ref_62;
			luma_filter0_e <= ref_72;
			luma_filter0_f <= ref_82;
		end
		endcase
	end
	else if (ref_x[1:0] == 3 && ref_y[1:0] == 1 ||
	         ref_x[1:0] == 3 && ref_y[1:0] == 3) begin
		case(counter)
		3:begin
			luma_filter0_a <= ref_03;
			luma_filter0_b <= ref_13;
			luma_filter0_c <= ref_23;
			luma_filter0_d <= ref_33;
			luma_filter0_e <= ref_43;
			luma_filter0_f <= ref_53;
		end
		2:begin
			luma_filter0_a <= ref_13;
			luma_filter0_b <= ref_23;
			luma_filter0_c <= ref_33;
			luma_filter0_d <= ref_43;
			luma_filter0_e <= ref_53;
			luma_filter0_f <= ref_63;
		end
		1:begin
			luma_filter0_a <= ref_23;
			luma_filter0_b <= ref_33;
			luma_filter0_c <= ref_43;
			luma_filter0_d <= ref_53;
			luma_filter0_e <= ref_63;
			luma_filter0_f <= ref_73;
		end
		0:begin
			luma_filter0_a <= ref_33;
			luma_filter0_b <= ref_43;
			luma_filter0_c <= ref_53;
			luma_filter0_d <= ref_63;
			luma_filter0_e <= ref_73;
			luma_filter0_f <= ref_83;
		end
		endcase
	end
	else begin
		luma_filter0_a <= 0;
		luma_filter0_b <= 0;
		luma_filter0_c <= 0;	
		luma_filter0_d <= 0;
		luma_filter0_e <= 0;
		luma_filter0_f <= 0;	
	end
end
else begin
	luma_filter0_a <= 0;
	luma_filter0_b <= 0;
	luma_filter0_c <= 0;	
	luma_filter0_d <= 0;
	luma_filter0_e <= 0;
	luma_filter0_f <= 0;
end

always @(*)
if (calc && !chroma_cb_sel && !chroma_cr_sel) begin
	if (ref_x[1:0] == 0) begin
		case(counter)
		3:begin
			luma_filter1_a <= ref_01;
			luma_filter1_b <= ref_11;
			luma_filter1_c <= ref_21;
			luma_filter1_d <= ref_31;
			luma_filter1_e <= ref_41;
			luma_filter1_f <= ref_51;
		end
		2:begin
			luma_filter1_a <= ref_11;
			luma_filter1_b <= ref_21;
			luma_filter1_c <= ref_31;
			luma_filter1_d <= ref_41;
			luma_filter1_e <= ref_51;
			luma_filter1_f <= ref_61;
		end
		1:begin
			luma_filter1_a <= ref_21;
			luma_filter1_b <= ref_31;
			luma_filter1_c <= ref_41;
			luma_filter1_d <= ref_51;
			luma_filter1_e <= ref_61;
			luma_filter1_f <= ref_71;
		end
		0:begin
			luma_filter1_a <= ref_31;
			luma_filter1_b <= ref_41;
			luma_filter1_c <= ref_51;
			luma_filter1_d <= ref_61;
			luma_filter1_e <= ref_71;
			luma_filter1_f <= ref_81;
		end
		endcase
	end
	else if (ref_y[1:0] == 0) begin
		case(counter)
		3:begin
			luma_filter1_a <= ref_01;
			luma_filter1_b <= ref_02;
			luma_filter1_c <= ref_03;
			luma_filter1_d <= ref_04;
			luma_filter1_e <= ref_05;
			luma_filter1_f <= ref_06;
		end
		2:begin
			luma_filter1_a <= ref_11;
			luma_filter1_b <= ref_12;
			luma_filter1_c <= ref_13;
			luma_filter1_d <= ref_14;
			luma_filter1_e <= ref_15;
			luma_filter1_f <= ref_16;
		end
		1:begin
			luma_filter1_a <= ref_21;
			luma_filter1_b <= ref_22;
			luma_filter1_c <= ref_23;
			luma_filter1_d <= ref_24;
			luma_filter1_e <= ref_25;
			luma_filter1_f <= ref_26;
		end
		0:begin
			luma_filter1_a <= ref_31;
			luma_filter1_b <= ref_32;
			luma_filter1_c <= ref_33;
			luma_filter1_d <= ref_34;
			luma_filter1_e <= ref_35;
			luma_filter1_f <= ref_36;
		end
		endcase
	end
	else if (ref_x[1:0] == 2) begin
		case(counter)
		3:begin
			luma_filter1_a <= ref_10;
			luma_filter1_b <= ref_11;
			luma_filter1_c <= ref_12;
			luma_filter1_d <= ref_13;
			luma_filter1_e <= ref_14;
			luma_filter1_f <= ref_15;
		end
		2:begin
			luma_filter1_a <= ref_11;
			luma_filter1_b <= ref_12;
			luma_filter1_c <= ref_13;
			luma_filter1_d <= ref_14;
			luma_filter1_e <= ref_15;
			luma_filter1_f <= ref_16;
		end
		1:begin
			luma_filter1_a <= ref_12;
			luma_filter1_b <= ref_13;
			luma_filter1_c <= ref_14;
			luma_filter1_d <= ref_15;
			luma_filter1_e <= ref_16;
			luma_filter1_f <= ref_17;
		end
		0:begin
			luma_filter1_a <= ref_13;
			luma_filter1_b <= ref_14;
			luma_filter1_c <= ref_15;
			luma_filter1_d <= ref_16;
			luma_filter1_e <= ref_17;
			luma_filter1_f <= ref_18;
		end
		endcase
	end
	else if (ref_y[1:0] == 2) begin
		case(counter)
		3:begin
			luma_filter1_a <= ref_01;
			luma_filter1_b <= ref_11;
			luma_filter1_c <= ref_21;
			luma_filter1_d <= ref_31;
			luma_filter1_e <= ref_41;
			luma_filter1_f <= ref_51;
		end
		2:begin
			luma_filter1_a <= ref_11;
			luma_filter1_b <= ref_21;
			luma_filter1_c <= ref_31;
			luma_filter1_d <= ref_41;
			luma_filter1_e <= ref_51;
			luma_filter1_f <= ref_61;
		end
		1:begin
			luma_filter1_a <= ref_21;
			luma_filter1_b <= ref_31;
			luma_filter1_c <= ref_41;
			luma_filter1_d <= ref_51;
			luma_filter1_e <= ref_61;
			luma_filter1_f <= ref_71;
		end
		0:begin
			luma_filter1_a <= ref_31;
			luma_filter1_b <= ref_41;
			luma_filter1_c <= ref_51;
			luma_filter1_d <= ref_61;
			luma_filter1_e <= ref_71;
			luma_filter1_f <= ref_81;
		end
		endcase
	end
	else if (ref_x[1:0] == 3 && ref_y[1:0] == 1 ||
	         ref_x[1:0] == 1 && ref_y[1:0] == 1) begin
		case(counter)
		3:begin
			luma_filter1_a <= ref_20;
			luma_filter1_b <= ref_21;
			luma_filter1_c <= ref_22;
			luma_filter1_d <= ref_23;
			luma_filter1_e <= ref_24;
			luma_filter1_f <= ref_25;
		end
		2:begin
			luma_filter1_a <= ref_30;
			luma_filter1_b <= ref_31;
			luma_filter1_c <= ref_32;
			luma_filter1_d <= ref_33;
			luma_filter1_e <= ref_34;
			luma_filter1_f <= ref_35;
		end
		1:begin
			luma_filter1_a <= ref_40;
			luma_filter1_b <= ref_41;
			luma_filter1_c <= ref_42;
			luma_filter1_d <= ref_43;
			luma_filter1_e <= ref_44;
			luma_filter1_f <= ref_45;
		end
		0:begin
			luma_filter1_a <= ref_50;
			luma_filter1_b <= ref_51;
			luma_filter1_c <= ref_52;
			luma_filter1_d <= ref_53;
			luma_filter1_e <= ref_54;
			luma_filter1_f <= ref_55;
		end
		endcase
	end
	else if (ref_x[1:0] == 1 && ref_y[1:0] == 3 ||
	         ref_x[1:0] == 3 && ref_y[1:0] == 3) begin
		case(counter)
		3:begin
			luma_filter1_a <= ref_30;
			luma_filter1_b <= ref_31;
			luma_filter1_c <= ref_32;
			luma_filter1_d <= ref_33;
			luma_filter1_e <= ref_34;
			luma_filter1_f <= ref_35;
		end
		2:begin
			luma_filter1_a <= ref_40;
			luma_filter1_b <= ref_41;
			luma_filter1_c <= ref_42;
			luma_filter1_d <= ref_43;
			luma_filter1_e <= ref_44;
			luma_filter1_f <= ref_45;
		end
		1:begin
			luma_filter1_a <= ref_50;
			luma_filter1_b <= ref_51;
			luma_filter1_c <= ref_52;
			luma_filter1_d <= ref_53;
			luma_filter1_e <= ref_54;
			luma_filter1_f <= ref_55;
		end
		0:begin
			luma_filter1_a <= ref_60;
			luma_filter1_b <= ref_61;
			luma_filter1_c <= ref_62;
			luma_filter1_d <= ref_63;
			luma_filter1_e <= ref_64;
			luma_filter1_f <= ref_65;
		end
		endcase
	end
	else begin
		luma_filter1_a <= 0;
		luma_filter1_b <= 0;
		luma_filter1_c <= 0;	
		luma_filter1_d <= 0;
		luma_filter1_e <= 0;
		luma_filter1_f <= 0;	
	end
end
else begin
	luma_filter1_a <= 0;
	luma_filter1_b <= 0;
	luma_filter1_c <= 0;	
	luma_filter1_d <= 0;
	luma_filter1_e <= 0;
	luma_filter1_f <= 0;
end

always @(*)
if (calc && !chroma_cb_sel && !chroma_cr_sel) begin
	if (ref_x[1:0] == 0) begin
		case(counter)
		3:begin
			luma_filter2_a <= ref_02;
			luma_filter2_b <= ref_12;
			luma_filter2_c <= ref_22;
			luma_filter2_d <= ref_32;
			luma_filter2_e <= ref_42;
			luma_filter2_f <= ref_52;
		end
		2:begin
			luma_filter2_a <= ref_12;
			luma_filter2_b <= ref_22;
			luma_filter2_c <= ref_32;
			luma_filter2_d <= ref_42;
			luma_filter2_e <= ref_52;
			luma_filter2_f <= ref_62;
		end
		1:begin
			luma_filter2_a <= ref_22;
			luma_filter2_b <= ref_32;
			luma_filter2_c <= ref_42;
			luma_filter2_d <= ref_52;
			luma_filter2_e <= ref_62;
			luma_filter2_f <= ref_72;
		end
		0:begin
			luma_filter2_a <= ref_32;
			luma_filter2_b <= ref_42;
			luma_filter2_c <= ref_52;
			luma_filter2_d <= ref_62;
			luma_filter2_e <= ref_72;
			luma_filter2_f <= ref_82;
		end
		endcase
	end
	else if (ref_y[1:0] == 0) begin
		case(counter)
		3:begin
			luma_filter2_a <= ref_02;
			luma_filter2_b <= ref_03;
			luma_filter2_c <= ref_04;
			luma_filter2_d <= ref_05;
			luma_filter2_e <= ref_06;
			luma_filter2_f <= ref_07;
		end
		2:begin
			luma_filter2_a <= ref_12;
			luma_filter2_b <= ref_13;
			luma_filter2_c <= ref_14;
			luma_filter2_d <= ref_15;
			luma_filter2_e <= ref_16;
			luma_filter2_f <= ref_17;
		end
		1:begin
			luma_filter2_a <= ref_22;
			luma_filter2_b <= ref_23;
			luma_filter2_c <= ref_24;
			luma_filter2_d <= ref_25;
			luma_filter2_e <= ref_26;
			luma_filter2_f <= ref_27;
		end
		0:begin
			luma_filter2_a <= ref_32;
			luma_filter2_b <= ref_33;
			luma_filter2_c <= ref_34;
			luma_filter2_d <= ref_35;
			luma_filter2_e <= ref_36;
			luma_filter2_f <= ref_37;
		end
		endcase
	end
	else if (ref_x[1:0] == 2) begin
		case(counter)
		3:begin
			luma_filter2_a <= ref_20;
			luma_filter2_b <= ref_21;
			luma_filter2_c <= ref_22;
			luma_filter2_d <= ref_23;
			luma_filter2_e <= ref_24;
			luma_filter2_f <= ref_25;
		end
		2:begin
			luma_filter2_a <= ref_21;
			luma_filter2_b <= ref_22;
			luma_filter2_c <= ref_23;
			luma_filter2_d <= ref_24;
			luma_filter2_e <= ref_25;
			luma_filter2_f <= ref_26;
		end
		1:begin
			luma_filter2_a <= ref_22;
			luma_filter2_b <= ref_23;
			luma_filter2_c <= ref_24;
			luma_filter2_d <= ref_25;
			luma_filter2_e <= ref_26;
			luma_filter2_f <= ref_27;
		end
		0:begin
			luma_filter2_a <= ref_23;
			luma_filter2_b <= ref_24;
			luma_filter2_c <= ref_25;
			luma_filter2_d <= ref_26;
			luma_filter2_e <= ref_27;
			luma_filter2_f <= ref_28;
		end
		endcase
	end
	else if (ref_y[1:0] == 2) begin
		case(counter)
		3:begin
			luma_filter2_a <= ref_02;
			luma_filter2_b <= ref_12;
			luma_filter2_c <= ref_22;
			luma_filter2_d <= ref_32;
			luma_filter2_e <= ref_42;
			luma_filter2_f <= ref_52;
		end
		2:begin
			luma_filter2_a <= ref_12;
			luma_filter2_b <= ref_22;
			luma_filter2_c <= ref_32;
			luma_filter2_d <= ref_42;
			luma_filter2_e <= ref_52;
			luma_filter2_f <= ref_62;
		end
		1:begin
			luma_filter2_a <= ref_22;
			luma_filter2_b <= ref_32;
			luma_filter2_c <= ref_42;
			luma_filter2_d <= ref_52;
			luma_filter2_e <= ref_62;
			luma_filter2_f <= ref_72;
		end
		0:begin
			luma_filter2_a <= ref_32;
			luma_filter2_b <= ref_42;
			luma_filter2_c <= ref_52;
			luma_filter2_d <= ref_62;
			luma_filter2_e <= ref_72;
			luma_filter2_f <= ref_82;
		end
		endcase
	end
	else if (ref_x[1:0] == 1 && ref_y[1:0] == 1 ||
	         ref_x[1:0] == 1 && ref_y[1:0] == 3) begin
		case(counter)
		3:begin
			luma_filter2_a <= ref_03;
			luma_filter2_b <= ref_13;
			luma_filter2_c <= ref_23;
			luma_filter2_d <= ref_33;
			luma_filter2_e <= ref_43;
			luma_filter2_f <= ref_53;
		end
		2:begin
			luma_filter2_a <= ref_13;
			luma_filter2_b <= ref_23;
			luma_filter2_c <= ref_33;
			luma_filter2_d <= ref_43;
			luma_filter2_e <= ref_53;
			luma_filter2_f <= ref_63;
		end
		1:begin
			luma_filter2_a <= ref_23;
			luma_filter2_b <= ref_33;
			luma_filter2_c <= ref_43;
			luma_filter2_d <= ref_53;
			luma_filter2_e <= ref_63;
			luma_filter2_f <= ref_73;
		end
		0:begin
			luma_filter2_a <= ref_33;
			luma_filter2_b <= ref_43;
			luma_filter2_c <= ref_53;
			luma_filter2_d <= ref_63;
			luma_filter2_e <= ref_73;
			luma_filter2_f <= ref_83;
		end
		endcase
	end
	else if (ref_x[1:0] == 3 && ref_y[1:0] == 1 ||
	         ref_x[1:0] == 3 && ref_y[1:0] == 3) begin
		case(counter)
		3:begin
			luma_filter2_a <= ref_04;
			luma_filter2_b <= ref_14;
			luma_filter2_c <= ref_24;
			luma_filter2_d <= ref_34;
			luma_filter2_e <= ref_44;
			luma_filter2_f <= ref_54;
		end
		2:begin
			luma_filter2_a <= ref_14;
			luma_filter2_b <= ref_24;
			luma_filter2_c <= ref_34;
			luma_filter2_d <= ref_44;
			luma_filter2_e <= ref_54;
			luma_filter2_f <= ref_64;
		end
		1:begin
			luma_filter2_a <= ref_24;
			luma_filter2_b <= ref_34;
			luma_filter2_c <= ref_44;
			luma_filter2_d <= ref_54;
			luma_filter2_e <= ref_64;
			luma_filter2_f <= ref_74;
		end
		0:begin
			luma_filter2_a <= ref_34;
			luma_filter2_b <= ref_44;
			luma_filter2_c <= ref_54;
			luma_filter2_d <= ref_64;
			luma_filter2_e <= ref_74;
			luma_filter2_f <= ref_84;
		end
		endcase
	end
	else begin
		luma_filter2_a <= 0;
		luma_filter2_b <= 0;
		luma_filter2_c <= 0;	
		luma_filter2_d <= 0;
		luma_filter2_e <= 0;
		luma_filter2_f <= 0;	
	end
end
else begin
	luma_filter2_a <= 0;
	luma_filter2_b <= 0;
	luma_filter2_c <= 0;	
	luma_filter2_d <= 0;
	luma_filter2_e <= 0;
	luma_filter2_f <= 0;
end

always @(*)
if (calc && !chroma_cb_sel && !chroma_cr_sel) begin
	if (ref_x[1:0] == 0) begin
		case(counter)
		3:begin
			luma_filter3_a <= ref_03;
			luma_filter3_b <= ref_13;
			luma_filter3_c <= ref_23;
			luma_filter3_d <= ref_33;
			luma_filter3_e <= ref_43;
			luma_filter3_f <= ref_53;
		end
		2:begin
			luma_filter3_a <= ref_13;
			luma_filter3_b <= ref_23;
			luma_filter3_c <= ref_33;
			luma_filter3_d <= ref_43;
			luma_filter3_e <= ref_53;
			luma_filter3_f <= ref_63;
		end
		1:begin
			luma_filter3_a <= ref_23;
			luma_filter3_b <= ref_33;
			luma_filter3_c <= ref_43;
			luma_filter3_d <= ref_53;
			luma_filter3_e <= ref_63;
			luma_filter3_f <= ref_73;
		end
		0:begin
			luma_filter3_a <= ref_33;
			luma_filter3_b <= ref_43;
			luma_filter3_c <= ref_53;
			luma_filter3_d <= ref_63;
			luma_filter3_e <= ref_73;
			luma_filter3_f <= ref_83;
		end
		endcase
	end
	else if (ref_y[1:0] == 0) begin
		case(counter)
		3:begin
			luma_filter3_a <= ref_03;
			luma_filter3_b <= ref_04;
			luma_filter3_c <= ref_05;
			luma_filter3_d <= ref_06;
			luma_filter3_e <= ref_07;
			luma_filter3_f <= ref_08;
		end
		2:begin
			luma_filter3_a <= ref_13;
			luma_filter3_b <= ref_14;
			luma_filter3_c <= ref_15;
			luma_filter3_d <= ref_16;
			luma_filter3_e <= ref_17;
			luma_filter3_f <= ref_18;
		end
		1:begin
			luma_filter3_a <= ref_23;
			luma_filter3_b <= ref_24;
			luma_filter3_c <= ref_25;
			luma_filter3_d <= ref_26;
			luma_filter3_e <= ref_27;
			luma_filter3_f <= ref_28;
		end
		0:begin
			luma_filter3_a <= ref_33;
			luma_filter3_b <= ref_34;
			luma_filter3_c <= ref_35;
			luma_filter3_d <= ref_36;
			luma_filter3_e <= ref_37;
			luma_filter3_f <= ref_38;
		end
		endcase
	end
	else if (ref_x[1:0] == 2) begin
		case(counter)
		3:begin
			luma_filter3_a <= ref_30;
			luma_filter3_b <= ref_31;
			luma_filter3_c <= ref_32;
			luma_filter3_d <= ref_33;
			luma_filter3_e <= ref_34;
			luma_filter3_f <= ref_35;
		end
		2:begin
			luma_filter3_a <= ref_31;
			luma_filter3_b <= ref_32;
			luma_filter3_c <= ref_33;
			luma_filter3_d <= ref_34;
			luma_filter3_e <= ref_35;
			luma_filter3_f <= ref_36;
		end
		1:begin
			luma_filter3_a <= ref_32;
			luma_filter3_b <= ref_33;
			luma_filter3_c <= ref_34;
			luma_filter3_d <= ref_35;
			luma_filter3_e <= ref_36;
			luma_filter3_f <= ref_37;
		end
		0:begin
			luma_filter3_a <= ref_33;
			luma_filter3_b <= ref_34;
			luma_filter3_c <= ref_35;
			luma_filter3_d <= ref_36;
			luma_filter3_e <= ref_37;
			luma_filter3_f <= ref_38;
		end
		endcase
	end
	else if (ref_y[1:0] == 2) begin
		case(counter)
		3:begin
			luma_filter3_a <= ref_03;
			luma_filter3_b <= ref_13;
			luma_filter3_c <= ref_23;
			luma_filter3_d <= ref_33;
			luma_filter3_e <= ref_43;
			luma_filter3_f <= ref_53;
		end
		2:begin
			luma_filter3_a <= ref_13;
			luma_filter3_b <= ref_23;
			luma_filter3_c <= ref_33;
			luma_filter3_d <= ref_43;
			luma_filter3_e <= ref_53;
			luma_filter3_f <= ref_63;
		end
		1:begin
			luma_filter3_a <= ref_23;
			luma_filter3_b <= ref_33;
			luma_filter3_c <= ref_43;
			luma_filter3_d <= ref_53;
			luma_filter3_e <= ref_63;
			luma_filter3_f <= ref_73;
		end
		0:begin
			luma_filter3_a <= ref_33;
			luma_filter3_b <= ref_43;
			luma_filter3_c <= ref_53;
			luma_filter3_d <= ref_63;
			luma_filter3_e <= ref_73;
			luma_filter3_f <= ref_83;
		end
		endcase
	end
	else if (ref_x[1:0] == 3 && ref_y[1:0] == 1 ||
	         ref_x[1:0] == 1 && ref_y[1:0] == 1) begin
		case(counter)
		3:begin
			luma_filter3_a <= ref_21;
			luma_filter3_b <= ref_22;
			luma_filter3_c <= ref_23;
			luma_filter3_d <= ref_24;
			luma_filter3_e <= ref_25;
			luma_filter3_f <= ref_26;
		end
		2:begin
			luma_filter3_a <= ref_31;
			luma_filter3_b <= ref_32;
			luma_filter3_c <= ref_33;
			luma_filter3_d <= ref_34;
			luma_filter3_e <= ref_35;
			luma_filter3_f <= ref_36;
		end
		1:begin
			luma_filter3_a <= ref_41;
			luma_filter3_b <= ref_42;
			luma_filter3_c <= ref_43;
			luma_filter3_d <= ref_44;
			luma_filter3_e <= ref_45;
			luma_filter3_f <= ref_46;
		end
		0:begin
			luma_filter3_a <= ref_51;
			luma_filter3_b <= ref_52;
			luma_filter3_c <= ref_53;
			luma_filter3_d <= ref_54;
			luma_filter3_e <= ref_55;
			luma_filter3_f <= ref_56;
		end
		endcase
	end
	else if (ref_x[1:0] == 1 && ref_y[1:0] == 3 ||
	         ref_x[1:0] == 3 && ref_y[1:0] == 3) begin
		case(counter)
		3:begin
			luma_filter3_a <= ref_31;
			luma_filter3_b <= ref_32;
			luma_filter3_c <= ref_33;
			luma_filter3_d <= ref_34;
			luma_filter3_e <= ref_35;
			luma_filter3_f <= ref_36;
		end
		2:begin
			luma_filter3_a <= ref_41;
			luma_filter3_b <= ref_42;
			luma_filter3_c <= ref_43;
			luma_filter3_d <= ref_44;
			luma_filter3_e <= ref_45;
			luma_filter3_f <= ref_46;
		end
		1:begin
			luma_filter3_a <= ref_51;
			luma_filter3_b <= ref_52;
			luma_filter3_c <= ref_53;
			luma_filter3_d <= ref_54;
			luma_filter3_e <= ref_55;
			luma_filter3_f <= ref_56;
		end
		0:begin
			luma_filter3_a <= ref_61;
			luma_filter3_b <= ref_62;
			luma_filter3_c <= ref_63;
			luma_filter3_d <= ref_64;
			luma_filter3_e <= ref_65;
			luma_filter3_f <= ref_66;
		end
		endcase
	end
	else begin
		luma_filter3_a <= 0;
		luma_filter3_b <= 0;
		luma_filter3_c <= 0;	
		luma_filter3_d <= 0;
		luma_filter3_e <= 0;
		luma_filter3_f <= 0;	
	end
end
else begin
	luma_filter3_a <= 0;
	luma_filter3_b <= 0;
	luma_filter3_c <= 0;
	luma_filter3_d <= 0;
	luma_filter3_e <= 0;
	luma_filter3_f <= 0;
end

always @(*)
if (calc && !chroma_cb_sel && !chroma_cr_sel) begin
	if (ref_x[1:0] == 2) begin
		case(counter)
		3:begin
			luma_filter4_a <= ref_40;
			luma_filter4_b <= ref_41;
			luma_filter4_c <= ref_42;
			luma_filter4_d <= ref_43;
			luma_filter4_e <= ref_44;
			luma_filter4_f <= ref_45;
		end
		2:begin
			luma_filter4_a <= ref_41;
			luma_filter4_b <= ref_42;
			luma_filter4_c <= ref_43;
			luma_filter4_d <= ref_44;
			luma_filter4_e <= ref_45;
			luma_filter4_f <= ref_46;
		end
		1:begin
			luma_filter4_a <= ref_42;
			luma_filter4_b <= ref_43;
			luma_filter4_c <= ref_44;
			luma_filter4_d <= ref_45;
			luma_filter4_e <= ref_46;
			luma_filter4_f <= ref_47;
		end
		0:begin
			luma_filter4_a <= ref_43;
			luma_filter4_b <= ref_44;
			luma_filter4_c <= ref_45;
			luma_filter4_d <= ref_46;
			luma_filter4_e <= ref_47;
			luma_filter4_f <= ref_48;
		end
		endcase
	end
	else if (ref_y[1:0] == 2) begin
		case(counter)
		3:begin
			luma_filter4_a <= ref_04;
			luma_filter4_b <= ref_14;
			luma_filter4_c <= ref_24;
			luma_filter4_d <= ref_34;
			luma_filter4_e <= ref_44;
			luma_filter4_f <= ref_54;
		end
		2:begin
			luma_filter4_a <= ref_14;
			luma_filter4_b <= ref_24;
			luma_filter4_c <= ref_34;
			luma_filter4_d <= ref_44;
			luma_filter4_e <= ref_54;
			luma_filter4_f <= ref_64;
		end
		1:begin
			luma_filter4_a <= ref_24;
			luma_filter4_b <= ref_34;
			luma_filter4_c <= ref_44;
			luma_filter4_d <= ref_54;
			luma_filter4_e <= ref_64;
			luma_filter4_f <= ref_74;
		end
		0:begin
			luma_filter4_a <= ref_34;
			luma_filter4_b <= ref_44;
			luma_filter4_c <= ref_54;
			luma_filter4_d <= ref_64;
			luma_filter4_e <= ref_74;
			luma_filter4_f <= ref_84;
		end
		endcase
	end
	else if (ref_x[1:0] == 1 && ref_y[1:0] == 1 ||
	         ref_x[1:0] == 1 && ref_y[1:0] == 3) begin
		case(counter)
		3:begin
			luma_filter4_a <= ref_04;
			luma_filter4_b <= ref_14;
			luma_filter4_c <= ref_24;
			luma_filter4_d <= ref_34;
			luma_filter4_e <= ref_44;
			luma_filter4_f <= ref_54;
		end
		2:begin
			luma_filter4_a <= ref_14;
			luma_filter4_b <= ref_24;
			luma_filter4_c <= ref_34;
			luma_filter4_d <= ref_44;
			luma_filter4_e <= ref_54;
			luma_filter4_f <= ref_64;
		end
		1:begin
			luma_filter4_a <= ref_24;
			luma_filter4_b <= ref_34;
			luma_filter4_c <= ref_44;
			luma_filter4_d <= ref_54;
			luma_filter4_e <= ref_64;
			luma_filter4_f <= ref_74;
		end
		0:begin
			luma_filter4_a <= ref_34;
			luma_filter4_b <= ref_44;
			luma_filter4_c <= ref_54;
			luma_filter4_d <= ref_64;
			luma_filter4_e <= ref_74;
			luma_filter4_f <= ref_84;
		end
		endcase
	end
	else if (ref_x[1:0] == 3 && ref_y[1:0] == 1 ||
	         ref_x[1:0] == 3 && ref_y[1:0] == 3) begin
		case(counter)
		3:begin
			luma_filter4_a <= ref_05;
			luma_filter4_b <= ref_15;
			luma_filter4_c <= ref_25;
			luma_filter4_d <= ref_35;
			luma_filter4_e <= ref_45;
			luma_filter4_f <= ref_55;
		end
		2:begin
			luma_filter4_a <= ref_15;
			luma_filter4_b <= ref_25;
			luma_filter4_c <= ref_35;
			luma_filter4_d <= ref_45;
			luma_filter4_e <= ref_55;
			luma_filter4_f <= ref_65;
		end
		1:begin
			luma_filter4_a <= ref_25;
			luma_filter4_b <= ref_35;
			luma_filter4_c <= ref_45;
			luma_filter4_d <= ref_55;
			luma_filter4_e <= ref_65;
			luma_filter4_f <= ref_75;
		end
		0:begin
			luma_filter4_a <= ref_35;
			luma_filter4_b <= ref_45;
			luma_filter4_c <= ref_55;
			luma_filter4_d <= ref_65;
			luma_filter4_e <= ref_75;
			luma_filter4_f <= ref_85;
		end
		endcase
	end
	else begin
		luma_filter4_a <= 0;
		luma_filter4_b <= 0;
		luma_filter4_c <= 0;	
		luma_filter4_d <= 0;
		luma_filter4_e <= 0;
		luma_filter4_f <= 0;	
	end
end
else begin
	luma_filter4_a <= 0;
	luma_filter4_b <= 0;
	luma_filter4_c <= 0;	
	luma_filter4_d <= 0;
	luma_filter4_e <= 0;
	luma_filter4_f <= 0;
end

always @(*)
if (calc && !chroma_cb_sel && !chroma_cr_sel) begin
	if (ref_x[1:0] == 2) begin
		case(counter)
		3:begin
			luma_filter5_a <= ref_50;
			luma_filter5_b <= ref_51;
			luma_filter5_c <= ref_52;
			luma_filter5_d <= ref_53;
			luma_filter5_e <= ref_54;
			luma_filter5_f <= ref_55;
		end
		2:begin
			luma_filter5_a <= ref_51;
			luma_filter5_b <= ref_52;
			luma_filter5_c <= ref_53;
			luma_filter5_d <= ref_54;
			luma_filter5_e <= ref_55;
			luma_filter5_f <= ref_56;
		end
		1:begin
			luma_filter5_a <= ref_52;
			luma_filter5_b <= ref_53;
			luma_filter5_c <= ref_54;
			luma_filter5_d <= ref_55;
			luma_filter5_e <= ref_56;
			luma_filter5_f <= ref_57;
		end
		0:begin
			luma_filter5_a <= ref_53;
			luma_filter5_b <= ref_54;
			luma_filter5_c <= ref_55;
			luma_filter5_d <= ref_56;
			luma_filter5_e <= ref_57;
			luma_filter5_f <= ref_58;
		end
		endcase
	end
	else if (ref_y[1:0] == 2) begin
		case(counter)
		3:begin
			luma_filter5_a <= ref_05;
			luma_filter5_b <= ref_15;
			luma_filter5_c <= ref_25;
			luma_filter5_d <= ref_35;
			luma_filter5_e <= ref_45;
			luma_filter5_f <= ref_55;
		end
		2:begin
			luma_filter5_a <= ref_15;
			luma_filter5_b <= ref_25;
			luma_filter5_c <= ref_35;
			luma_filter5_d <= ref_45;
			luma_filter5_e <= ref_55;
			luma_filter5_f <= ref_65;
		end
		1:begin
			luma_filter5_a <= ref_25;
			luma_filter5_b <= ref_35;
			luma_filter5_c <= ref_45;
			luma_filter5_d <= ref_55;
			luma_filter5_e <= ref_65;
			luma_filter5_f <= ref_75;
		end
		0:begin
			luma_filter5_a <= ref_35;
			luma_filter5_b <= ref_45;
			luma_filter5_c <= ref_55;
			luma_filter5_d <= ref_65;
			luma_filter5_e <= ref_75;
			luma_filter5_f <= ref_85;
		end
		endcase
	end
	else if (ref_x[1:0] == 3 && ref_y[1:0] == 1 ||
	    ref_x[1:0] == 1 && ref_y[1:0] == 1) begin
		case(counter)
		3:begin
			luma_filter5_a <= ref_22;
			luma_filter5_b <= ref_23;
			luma_filter5_c <= ref_24;
			luma_filter5_d <= ref_25;
			luma_filter5_e <= ref_26;
			luma_filter5_f <= ref_27;
		end
		2:begin
			luma_filter5_a <= ref_32;
			luma_filter5_b <= ref_33;
			luma_filter5_c <= ref_34;
			luma_filter5_d <= ref_35;
			luma_filter5_e <= ref_36;
			luma_filter5_f <= ref_37;
		end
		1:begin
			luma_filter5_a <= ref_42;
			luma_filter5_b <= ref_43;
			luma_filter5_c <= ref_44;
			luma_filter5_d <= ref_45;
			luma_filter5_e <= ref_46;
			luma_filter5_f <= ref_47;
		end
		0:begin
			luma_filter5_a <= ref_52;
			luma_filter5_b <= ref_53;
			luma_filter5_c <= ref_54;
			luma_filter5_d <= ref_55;
			luma_filter5_e <= ref_56;
			luma_filter5_f <= ref_57;
		end
		endcase
	end
	else if (ref_x[1:0] == 1 && ref_y[1:0] == 3 ||
	         ref_x[1:0] == 3 && ref_y[1:0] == 3) begin
		case(counter)
		3:begin
			luma_filter5_a <= ref_32;
			luma_filter5_b <= ref_33;
			luma_filter5_c <= ref_34;
			luma_filter5_d <= ref_35;
			luma_filter5_e <= ref_36;
			luma_filter5_f <= ref_37;
		end
		2:begin
			luma_filter5_a <= ref_42;
			luma_filter5_b <= ref_43;
			luma_filter5_c <= ref_44;
			luma_filter5_d <= ref_45;
			luma_filter5_e <= ref_46;
			luma_filter5_f <= ref_47;
		end
		1:begin
			luma_filter5_a <= ref_52;
			luma_filter5_b <= ref_53;
			luma_filter5_c <= ref_54;
			luma_filter5_d <= ref_55;
			luma_filter5_e <= ref_56;
			luma_filter5_f <= ref_57;
		end
		0:begin
			luma_filter5_a <= ref_62;
			luma_filter5_b <= ref_63;
			luma_filter5_c <= ref_64;
			luma_filter5_d <= ref_65;
			luma_filter5_e <= ref_66;
			luma_filter5_f <= ref_67;
		end
		endcase
	end
	else begin
		luma_filter5_a <= 0;
		luma_filter5_b <= 0;
		luma_filter5_c <= 0;	
		luma_filter5_d <= 0;
		luma_filter5_e <= 0;
		luma_filter5_f <= 0;	
	end
end
else begin
	luma_filter5_a <= 0;
	luma_filter5_b <= 0;
	luma_filter5_c <= 0;
	luma_filter5_d <= 0;
	luma_filter5_e <= 0;
	luma_filter5_f <= 0;
end

always @(*)
if (calc && !chroma_cb_sel && !chroma_cr_sel) begin
	if (ref_x[1:0] == 2) begin
		case(counter)
		3:begin
			luma_filter6_a <= ref_60;
			luma_filter6_b <= ref_61;
			luma_filter6_c <= ref_62;
			luma_filter6_d <= ref_63;
			luma_filter6_e <= ref_64;
			luma_filter6_f <= ref_65;
		end
		2:begin
			luma_filter6_a <= ref_61;
			luma_filter6_b <= ref_62;
			luma_filter6_c <= ref_63;
			luma_filter6_d <= ref_64;
			luma_filter6_e <= ref_65;
			luma_filter6_f <= ref_66;
		end
		1:begin
			luma_filter6_a <= ref_62;
			luma_filter6_b <= ref_63;
			luma_filter6_c <= ref_64;
			luma_filter6_d <= ref_65;
			luma_filter6_e <= ref_66;
			luma_filter6_f <= ref_67;
		end
		0:begin
			luma_filter6_a <= ref_63;
			luma_filter6_b <= ref_64;
			luma_filter6_c <= ref_65;
			luma_filter6_d <= ref_66;
			luma_filter6_e <= ref_67;
			luma_filter6_f <= ref_68;
		end
		endcase
	end
	else if (ref_y[1:0] == 2) begin
		case(counter)
		3:begin
			luma_filter6_a <= ref_06;
			luma_filter6_b <= ref_16;
			luma_filter6_c <= ref_26;
			luma_filter6_d <= ref_36;
			luma_filter6_e <= ref_46;
			luma_filter6_f <= ref_56;
		end
		2:begin
			luma_filter6_a <= ref_16;
			luma_filter6_b <= ref_26;
			luma_filter6_c <= ref_36;
			luma_filter6_d <= ref_46;
			luma_filter6_e <= ref_56;
			luma_filter6_f <= ref_66;
		end
		1:begin
			luma_filter6_a <= ref_26;
			luma_filter6_b <= ref_36;
			luma_filter6_c <= ref_46;
			luma_filter6_d <= ref_56;
			luma_filter6_e <= ref_66;
			luma_filter6_f <= ref_76;
		end
		0:begin
			luma_filter6_a <= ref_36;
			luma_filter6_b <= ref_46;
			luma_filter6_c <= ref_56;
			luma_filter6_d <= ref_66;
			luma_filter6_e <= ref_76;
			luma_filter6_f <= ref_86;
		end
		endcase
	end
	else if (ref_x[1:0] == 1 && ref_y[1:0] == 1 ||
	         ref_x[1:0] == 1 && ref_y[1:0] == 3) begin
		case(counter)
		3:begin
			luma_filter6_a <= ref_05;
			luma_filter6_b <= ref_15;
			luma_filter6_c <= ref_25;
			luma_filter6_d <= ref_35;
			luma_filter6_e <= ref_45;
			luma_filter6_f <= ref_55;
		end
		2:begin
			luma_filter6_a <= ref_15;
			luma_filter6_b <= ref_25;
			luma_filter6_c <= ref_35;
			luma_filter6_d <= ref_45;
			luma_filter6_e <= ref_55;
			luma_filter6_f <= ref_65;
		end
		1:begin
			luma_filter6_a <= ref_25;
			luma_filter6_b <= ref_35;
			luma_filter6_c <= ref_45;
			luma_filter6_d <= ref_55;
			luma_filter6_e <= ref_65;
			luma_filter6_f <= ref_75;
		end
		0:begin
			luma_filter6_a <= ref_35;
			luma_filter6_b <= ref_45;
			luma_filter6_c <= ref_55;
			luma_filter6_d <= ref_65;
			luma_filter6_e <= ref_75;
			luma_filter6_f <= ref_85;
		end
		endcase
	end
	else if (ref_x[1:0] == 3 && ref_y[1:0] == 1 ||
	         ref_x[1:0] == 3 && ref_y[1:0] == 3) begin
		case(counter)
		3:begin
			luma_filter6_a <= ref_06;
			luma_filter6_b <= ref_16;
			luma_filter6_c <= ref_26;
			luma_filter6_d <= ref_36;
			luma_filter6_e <= ref_46;
			luma_filter6_f <= ref_56;
		end
		2:begin
			luma_filter6_a <= ref_16;
			luma_filter6_b <= ref_26;
			luma_filter6_c <= ref_36;
			luma_filter6_d <= ref_46;
			luma_filter6_e <= ref_56;
			luma_filter6_f <= ref_66;
		end
		1:begin
			luma_filter6_a <= ref_26;
			luma_filter6_b <= ref_36;
			luma_filter6_c <= ref_46;
			luma_filter6_d <= ref_56;
			luma_filter6_e <= ref_66;
			luma_filter6_f <= ref_76;
		end
		0:begin
			luma_filter6_a <= ref_36;
			luma_filter6_b <= ref_46;
			luma_filter6_c <= ref_56;
			luma_filter6_d <= ref_66;
			luma_filter6_e <= ref_76;
			luma_filter6_f <= ref_86;
		end
		endcase
	end
	else begin
		luma_filter6_a <= 0;
		luma_filter6_b <= 0;
		luma_filter6_c <= 0;	
		luma_filter6_d <= 0;
		luma_filter6_e <= 0;
		luma_filter6_f <= 0;	
	end
end
else begin
	luma_filter6_a <= 0;
	luma_filter6_b <= 0;
	luma_filter6_c <= 0;	
	luma_filter6_d <= 0;
	luma_filter6_e <= 0;
	luma_filter6_f <= 0;
end

always @(*)
if (calc && !chroma_cb_sel && !chroma_cr_sel) begin
	if (ref_x[1:0] == 2) begin
		case(counter)
		3:begin
			luma_filter7_a <= ref_70;
			luma_filter7_b <= ref_71;
			luma_filter7_c <= ref_72;
			luma_filter7_d <= ref_73;
			luma_filter7_e <= ref_74;
			luma_filter7_f <= ref_75;
		end
		2:begin
			luma_filter7_a <= ref_71;
			luma_filter7_b <= ref_72;
			luma_filter7_c <= ref_73;
			luma_filter7_d <= ref_74;
			luma_filter7_e <= ref_75;
			luma_filter7_f <= ref_76;
		end
		1:begin
			luma_filter7_a <= ref_72;
			luma_filter7_b <= ref_73;
			luma_filter7_c <= ref_74;
			luma_filter7_d <= ref_75;
			luma_filter7_e <= ref_76;
			luma_filter7_f <= ref_77;
		end
		0:begin
			luma_filter7_a <= ref_73;
			luma_filter7_b <= ref_74;
			luma_filter7_c <= ref_75;
			luma_filter7_d <= ref_76;
			luma_filter7_e <= ref_77;
			luma_filter7_f <= ref_78;
		end
		endcase
	end
	else if (ref_y[1:0] == 2) begin
		case(counter)
		3:begin
			luma_filter7_a <= ref_07;
			luma_filter7_b <= ref_17;
			luma_filter7_c <= ref_27;
			luma_filter7_d <= ref_37;
			luma_filter7_e <= ref_47;
			luma_filter7_f <= ref_57;
		end
		2:begin
			luma_filter7_a <= ref_17;
			luma_filter7_b <= ref_27;
			luma_filter7_c <= ref_37;
			luma_filter7_d <= ref_47;
			luma_filter7_e <= ref_57;
			luma_filter7_f <= ref_67;
		end
		1:begin
			luma_filter7_a <= ref_27;
			luma_filter7_b <= ref_37;
			luma_filter7_c <= ref_47;
			luma_filter7_d <= ref_57;
			luma_filter7_e <= ref_67;
			luma_filter7_f <= ref_77;
		end
		0:begin
			luma_filter7_a <= ref_37;
			luma_filter7_b <= ref_47;
			luma_filter7_c <= ref_57;
			luma_filter7_d <= ref_67;
			luma_filter7_e <= ref_77;
			luma_filter7_f <= ref_87;
		end
		endcase
	end
	else if (ref_x[1:0] == 3 && ref_y[1:0] == 1 ||
	    ref_x[1:0] == 1 && ref_y[1:0] == 1) begin
		case(counter)
		3:begin
			luma_filter7_a <= ref_23;
			luma_filter7_b <= ref_24;
			luma_filter7_c <= ref_25;
			luma_filter7_d <= ref_26;
			luma_filter7_e <= ref_27;
			luma_filter7_f <= ref_28;
		end
		2:begin
			luma_filter7_a <= ref_33;
			luma_filter7_b <= ref_34;
			luma_filter7_c <= ref_35;
			luma_filter7_d <= ref_36;
			luma_filter7_e <= ref_37;
			luma_filter7_f <= ref_38;
		end
		1:begin
			luma_filter7_a <= ref_43;
			luma_filter7_b <= ref_44;
			luma_filter7_c <= ref_45;
			luma_filter7_d <= ref_46;
			luma_filter7_e <= ref_47;
			luma_filter7_f <= ref_48;
		end
		0:begin
			luma_filter7_a <= ref_53;
			luma_filter7_b <= ref_54;
			luma_filter7_c <= ref_55;
			luma_filter7_d <= ref_56;
			luma_filter7_e <= ref_57;
			luma_filter7_f <= ref_58;
		end
		endcase
	end
	else if (ref_x[1:0] == 1 && ref_y[1:0] == 3 ||
	         ref_x[1:0] == 3 && ref_y[1:0] == 3) begin
		case(counter)
		3:begin
			luma_filter7_a <= ref_33;
			luma_filter7_b <= ref_34;
			luma_filter7_c <= ref_35;
			luma_filter7_d <= ref_36;
			luma_filter7_e <= ref_37;
			luma_filter7_f <= ref_38;
		end
		2:begin
			luma_filter7_a <= ref_43;
			luma_filter7_b <= ref_44;
			luma_filter7_c <= ref_45;
			luma_filter7_d <= ref_46;
			luma_filter7_e <= ref_47;
			luma_filter7_f <= ref_48;
		end
		1:begin
			luma_filter7_a <= ref_53;
			luma_filter7_b <= ref_54;
			luma_filter7_c <= ref_55;
			luma_filter7_d <= ref_56;
			luma_filter7_e <= ref_57;
			luma_filter7_f <= ref_58;
		end
		0:begin
			luma_filter7_a <= ref_63;
			luma_filter7_b <= ref_64;
			luma_filter7_c <= ref_65;
			luma_filter7_d <= ref_66;
			luma_filter7_e <= ref_67;
			luma_filter7_f <= ref_68;
		end
		endcase
	end
	else begin
		luma_filter7_a <= 0;
		luma_filter7_b <= 0;
		luma_filter7_c <= 0;	
		luma_filter7_d <= 0;
		luma_filter7_e <= 0;
		luma_filter7_f <= 0;	
	end
end
else begin
	luma_filter7_a <= 0;
	luma_filter7_b <= 0;
	luma_filter7_c <= 0;
	luma_filter7_d <= 0;
	luma_filter7_e <= 0;
	luma_filter7_f <= 0;
end

always @(*)
if (calc && !chroma_cb_sel && !chroma_cr_sel) begin
	if (ref_x[1:0] == 2) begin
		case(counter)
		3:begin
			luma_filter8_a <= ref_80;
			luma_filter8_b <= ref_81;
			luma_filter8_c <= ref_82;
			luma_filter8_d <= ref_83;
			luma_filter8_e <= ref_84;
			luma_filter8_f <= ref_85;
		end
		2:begin
			luma_filter8_a <= ref_81;
			luma_filter8_b <= ref_82;
			luma_filter8_c <= ref_83;
			luma_filter8_d <= ref_84;
			luma_filter8_e <= ref_85;
			luma_filter8_f <= ref_86;
		end
		1:begin
			luma_filter8_a <= ref_82;
			luma_filter8_b <= ref_83;
			luma_filter8_c <= ref_84;
			luma_filter8_d <= ref_85;
			luma_filter8_e <= ref_86;
			luma_filter8_f <= ref_87;
		end
		0:begin
			luma_filter8_a <= ref_83;
			luma_filter8_b <= ref_84;
			luma_filter8_c <= ref_85;
			luma_filter8_d <= ref_86;
			luma_filter8_e <= ref_87;
			luma_filter8_f <= ref_88;
		end
		endcase
	end
	else if (ref_y[1:0] == 2) begin
		case(counter)
		3:begin
			luma_filter8_a <= ref_08;
			luma_filter8_b <= ref_18;
			luma_filter8_c <= ref_28;
			luma_filter8_d <= ref_38;
			luma_filter8_e <= ref_48;
			luma_filter8_f <= ref_58;
		end
		2:begin
			luma_filter8_a <= ref_18;
			luma_filter8_b <= ref_28;
			luma_filter8_c <= ref_38;
			luma_filter8_d <= ref_48;
			luma_filter8_e <= ref_58;
			luma_filter8_f <= ref_68;
		end
		1:begin
			luma_filter8_a <= ref_28;
			luma_filter8_b <= ref_38;
			luma_filter8_c <= ref_48;
			luma_filter8_d <= ref_58;
			luma_filter8_e <= ref_68;
			luma_filter8_f <= ref_78;
		end
		0:begin
			luma_filter8_a <= ref_38;
			luma_filter8_b <= ref_48;
			luma_filter8_c <= ref_58;
			luma_filter8_d <= ref_68;
			luma_filter8_e <= ref_78;
			luma_filter8_f <= ref_88;
		end
		endcase
	end
	else begin
		luma_filter8_a <= 0;
		luma_filter8_b <= 0;
		luma_filter8_c <= 0;	
		luma_filter8_d <= 0;
		luma_filter8_e <= 0;
		luma_filter8_f <= 0;	
	end
end
else begin
	luma_filter8_a <= 0;
	luma_filter8_b <= 0;
	luma_filter8_c <= 0;
	luma_filter8_d <= 0;
	luma_filter8_e <= 0;
	luma_filter8_f <= 0;
end

always @(*)
begin
	luma_filter9_a <= luma_filter0_out;
	luma_filter9_b <= luma_filter1_out;
	luma_filter9_c <= luma_filter2_out;
	luma_filter9_d <= luma_filter3_out;
	luma_filter9_e <= luma_filter4_out;
	luma_filter9_f <= luma_filter5_out;
end

always @(*)
begin
	luma_filter10_a <= luma_filter1_out;
	luma_filter10_b <= luma_filter2_out;
	luma_filter10_c <= luma_filter3_out;
	luma_filter10_d <= luma_filter4_out;
	luma_filter10_e <= luma_filter5_out;
	luma_filter10_f <= luma_filter6_out;
end

always @(*)
begin
	luma_filter11_a <= luma_filter2_out;
	luma_filter11_b <= luma_filter3_out;
	luma_filter11_c <= luma_filter4_out;
	luma_filter11_d <= luma_filter5_out;
	luma_filter11_e <= luma_filter6_out;
	luma_filter11_f <= luma_filter7_out;
end

always @(*)
begin
	luma_filter12_a <= luma_filter3_out;
	luma_filter12_b <= luma_filter4_out;
	luma_filter12_c <= luma_filter5_out;
	luma_filter12_d <= luma_filter6_out;
	luma_filter12_e <= luma_filter7_out;
	luma_filter12_f <= luma_filter8_out;
end

always @(*)
if (calc && (chroma_cb_sel || chroma_cr_sel) && 
	(ref_x[2:0] != 0 || ref_y[2:0] != 0)) begin
	case (counter)
	3:begin
		chroma_filter0_a <= ref_00;
		chroma_filter0_b <= ref_01;
		chroma_filter0_c <= ref_10;
		chroma_filter0_d <= ref_11;
	end
	2:begin
		chroma_filter0_a <= ref_10;
		chroma_filter0_b <= ref_11;
		chroma_filter0_c <= ref_20;
		chroma_filter0_d <= ref_21;
	end
	1:begin
		chroma_filter0_a <= ref_20;
		chroma_filter0_b <= ref_21;
		chroma_filter0_c <= ref_30;
		chroma_filter0_d <= ref_31;
	end
	0:begin
		chroma_filter0_a <= ref_30;
		chroma_filter0_b <= ref_31;
		chroma_filter0_c <= ref_40;
		chroma_filter0_d <= ref_41;
	end
	endcase
end
else begin
	chroma_filter0_a <= 0;
	chroma_filter0_b <= 0;
	chroma_filter0_c <= 0;
	chroma_filter0_d <= 0;
end

always @(*)
if (calc && (chroma_cb_sel || chroma_cr_sel) && 
	(ref_x[2:0] != 0 || ref_y[2:0] != 0)) begin
	case (counter)
	3:begin
		chroma_filter1_a <= ref_01;
		chroma_filter1_b <= ref_02;
		chroma_filter1_c <= ref_11;
		chroma_filter1_d <= ref_12;
	end
	2:begin
		chroma_filter1_a <= ref_11;
		chroma_filter1_b <= ref_12;
		chroma_filter1_c <= ref_21;
		chroma_filter1_d <= ref_22;
	end
	1:begin
		chroma_filter1_a <= ref_21;
		chroma_filter1_b <= ref_22;
		chroma_filter1_c <= ref_31;
		chroma_filter1_d <= ref_32;
	end
	0:begin
		chroma_filter1_a <= ref_31;
		chroma_filter1_b <= ref_32;
		chroma_filter1_c <= ref_41;
		chroma_filter1_d <= ref_42;
	end
	endcase
end
else begin
	chroma_filter1_a <= 0;
	chroma_filter1_b <= 0;
	chroma_filter1_c <= 0;
	chroma_filter1_d <= 0;
end

always @(*)
if (calc && (chroma_cb_sel || chroma_cr_sel) && 
	(ref_x[2:0] != 0 || ref_y[2:0] != 0)) begin
	case (counter)
	3:begin
		chroma_filter2_a <= ref_02;
		chroma_filter2_b <= ref_03;
		chroma_filter2_c <= ref_12;
		chroma_filter2_d <= ref_13;
	end
	2:begin
		chroma_filter2_a <= ref_12;
		chroma_filter2_b <= ref_13;
		chroma_filter2_c <= ref_22;
		chroma_filter2_d <= ref_23;
	end
	1:begin
		chroma_filter2_a <= ref_22;
		chroma_filter2_b <= ref_23;
		chroma_filter2_c <= ref_32;
		chroma_filter2_d <= ref_33;
	end
	0:begin
		chroma_filter2_a <= ref_32;
		chroma_filter2_b <= ref_33;
		chroma_filter2_c <= ref_42;
		chroma_filter2_d <= ref_43;
	end
	endcase
end
else begin
	chroma_filter2_a <= 0;
	chroma_filter2_b <= 0;
	chroma_filter2_c <= 0;
	chroma_filter2_d <= 0;
end

always @(*)
if (calc && (chroma_cb_sel || chroma_cr_sel) && 
	(ref_x[2:0] != 0 || ref_y[2:0] != 0)) begin
	case (counter)
	3:begin
		chroma_filter3_a <= ref_03;
		chroma_filter3_b <= ref_04;
		chroma_filter3_c <= ref_13;
		chroma_filter3_d <= ref_14;
	end
	2:begin
		chroma_filter3_a <= ref_13;
		chroma_filter3_b <= ref_14;
		chroma_filter3_c <= ref_23;
		chroma_filter3_d <= ref_24;
	end
	1:begin
		chroma_filter3_a <= ref_23;
		chroma_filter3_b <= ref_24;
		chroma_filter3_c <= ref_33;
		chroma_filter3_d <= ref_34;
	end
	0:begin
		chroma_filter3_a <= ref_33;
		chroma_filter3_b <= ref_34;
		chroma_filter3_c <= ref_43;
		chroma_filter3_d <= ref_44;
	end
	endcase
end
else begin
	chroma_filter3_a <= 0;
	chroma_filter3_b <= 0;
	chroma_filter3_c <= 0;
	chroma_filter3_d <= 0;
end

reg [7:0] a0, a1, a2, a3;
reg [7:0] b0, b1, b2, b3;
wire [7:0] out0, out1, out2, out3;

assign out0 = (a0 + b0 + 1) >> 1;
assign out1 = (a1 + b1 + 1) >> 1;
assign out2 = (a2 + b2 + 1) >> 1;
assign out3 = (a3 + b3 + 1) >> 1;

always @(*)
if (ena && calc) begin
	if (ref_x[1:0] == 0 && ref_y[1:0] == 1) begin
		case(counter)
		3: begin
			a0 <= luma_filter0_round_out; b0 <= ref_20;
			a1 <= luma_filter1_round_out; b1 <= ref_21;
			a2 <= luma_filter2_round_out; b2 <= ref_22;
			a3 <= luma_filter3_round_out; b3 <= ref_23;
		end
		2:begin
			a0 <= luma_filter0_round_out; b0 <= ref_30;
			a1 <= luma_filter1_round_out; b1 <= ref_31;
			a2 <= luma_filter2_round_out; b2 <= ref_32;
			a3 <= luma_filter3_round_out; b3 <= ref_33;
		end
		1:begin
			a0 <= luma_filter0_round_out; b0 <= ref_40;
			a1 <= luma_filter1_round_out; b1 <= ref_41;
			a2 <= luma_filter2_round_out; b2 <= ref_42;
			a3 <= luma_filter3_round_out; b3 <= ref_43;
		end
		0:begin
			a0 <= luma_filter0_round_out; b0 <= ref_50;
			a1 <= luma_filter1_round_out; b1 <= ref_51;
			a2 <= luma_filter2_round_out; b2 <= ref_52;
			a3 <= luma_filter3_round_out; b3 <= ref_53;
		end
		endcase
	end
	else if (ref_x[1:0] == 0 && ref_y[1:0] == 2) begin
		a0 <= luma_filter0_round_out; b0 <= luma_filter0_round_out;
		a1 <= luma_filter1_round_out; b1 <= luma_filter1_round_out;
		a2 <= luma_filter2_round_out; b2 <= luma_filter2_round_out;
		a3 <= luma_filter3_round_out; b3 <= luma_filter3_round_out;
	end
	else if (ref_x[1:0] == 0 && ref_y[1:0] == 3) begin
		case(counter)
		3: begin
			a0 <= luma_filter0_round_out; b0 <= ref_30;
			a1 <= luma_filter1_round_out; b1 <= ref_31;
			a2 <= luma_filter2_round_out; b2 <= ref_32;
			a3 <= luma_filter3_round_out; b3 <= ref_33;
		end
		2:begin
			a0 <= luma_filter0_round_out; b0 <= ref_40;
			a1 <= luma_filter1_round_out; b1 <= ref_41;
			a2 <= luma_filter2_round_out; b2 <= ref_42;
			a3 <= luma_filter3_round_out; b3 <= ref_43;
		end
		1:begin
			a0 <= luma_filter0_round_out; b0 <= ref_50;
			a1 <= luma_filter1_round_out; b1 <= ref_51;
			a2 <= luma_filter2_round_out; b2 <= ref_52;
			a3 <= luma_filter3_round_out; b3 <= ref_53;
		end
		0:begin
			a0 <= luma_filter0_round_out; b0 <= ref_60;
			a1 <= luma_filter1_round_out; b1 <= ref_61;
			a2 <= luma_filter2_round_out; b2 <= ref_62;
			a3 <= luma_filter3_round_out; b3 <= ref_63;
		end
		endcase
	end
	else if (ref_x[1:0] == 1 && ref_y[1:0] == 0) begin
		case(counter)
		3: begin
			a0 <= luma_filter0_round_out; b0 <= ref_02;
			a1 <= luma_filter1_round_out; b1 <= ref_03;
			a2 <= luma_filter2_round_out; b2 <= ref_04;
			a3 <= luma_filter3_round_out; b3 <= ref_05;
		end
		2:begin
			a0 <= luma_filter0_round_out; b0 <= ref_12;
			a1 <= luma_filter1_round_out; b1 <= ref_13;
			a2 <= luma_filter2_round_out; b2 <= ref_14;
			a3 <= luma_filter3_round_out; b3 <= ref_15;
		end
		1:begin
			a0 <= luma_filter0_round_out; b0 <= ref_22;
			a1 <= luma_filter1_round_out; b1 <= ref_23;
			a2 <= luma_filter2_round_out; b2 <= ref_24;
			a3 <= luma_filter3_round_out; b3 <= ref_25;
		end
		0:begin
			a0 <= luma_filter0_round_out; b0 <= ref_32;
			a1 <= luma_filter1_round_out; b1 <= ref_33;
			a2 <= luma_filter2_round_out; b2 <= ref_34;
			a3 <= luma_filter3_round_out; b3 <= ref_35;
		end
		endcase
	end
	else if (ref_x[1:0] == 2 && ref_y[1:0] == 0) begin
		a0 <= luma_filter0_round_out; b0 <= luma_filter0_round_out;
		a1 <= luma_filter1_round_out; b1 <= luma_filter1_round_out;
		a2 <= luma_filter2_round_out; b2 <= luma_filter2_round_out;
		a3 <= luma_filter3_round_out; b3 <= luma_filter3_round_out;
	end
	else if (ref_x[1:0] == 3 && ref_y[1:0] == 0) begin
		case(counter)
		3: begin
			a0 <= luma_filter0_round_out; b0 <= ref_03;
			a1 <= luma_filter1_round_out; b1 <= ref_04;
			a2 <= luma_filter2_round_out; b2 <= ref_05;
			a3 <= luma_filter3_round_out; b3 <= ref_06;
		end
		2:begin
			a0 <= luma_filter0_round_out; b0 <= ref_13;
			a1 <= luma_filter1_round_out; b1 <= ref_14;
			a2 <= luma_filter2_round_out; b2 <= ref_15;
			a3 <= luma_filter3_round_out; b3 <= ref_16;
		end
		1:begin
			a0 <= luma_filter0_round_out; b0 <= ref_23;
			a1 <= luma_filter1_round_out; b1 <= ref_24;
			a2 <= luma_filter2_round_out; b2 <= ref_25;
			a3 <= luma_filter3_round_out; b3 <= ref_26;
		end
		0:begin
			a0 <= luma_filter0_round_out; b0 <= ref_33;
			a1 <= luma_filter1_round_out; b1 <= ref_34;
			a2 <= luma_filter2_round_out; b2 <= ref_35;
			a3 <= luma_filter3_round_out; b3 <= ref_36;
		end
		endcase
	end
	else if (ref_x[1:0] == 2 && ref_y[1:0] == 1 || ref_x[1:0] == 1 && ref_y[1:0] == 2) begin
		a0 <= luma_filter9_round_out; b0 <= ((luma_filter2_out + 16) >> 5) > 255 ? 255 :(luma_filter2_out + 16) >> 5; 
		a1 <= luma_filter10_round_out; b1 <= ((luma_filter3_out + 16) >> 5) > 255 ? 255 :(luma_filter3_out + 16) >> 5; 
		a2 <= luma_filter11_round_out; b2 <= ((luma_filter4_out + 16) >> 5) > 255 ? 255 :(luma_filter4_out + 16) >> 5; 
		a3 <= luma_filter12_round_out; b3 <= ((luma_filter5_out + 16) >> 5) > 255 ? 255 :(luma_filter5_out + 16) >> 5; 
	end
	else if (ref_x[1:0] == 2 && ref_y[1:0] == 2) begin
		a0 <= luma_filter9_round_out; b0 <= luma_filter9_round_out;
		a1 <= luma_filter10_round_out; b1 <= luma_filter10_round_out;
		a2 <= luma_filter11_round_out; b2 <= luma_filter11_round_out;
		a3 <= luma_filter12_round_out; b3 <= luma_filter12_round_out;
	end
	else if (ref_x[1:0] == 2 && ref_y[1:0] == 3 || ref_x[1:0] == 3 && ref_y[1:0] == 2) begin
		a0 <= luma_filter9_round_out; b0 <= ((luma_filter3_out + 16) >> 5) > 255 ? 255 :(luma_filter3_out + 16) >> 5;  
		a1 <= luma_filter10_round_out; b1 <= ((luma_filter4_out + 16) >> 5) > 255 ? 255 :(luma_filter4_out + 16) >> 5; 
		a2 <= luma_filter11_round_out; b2 <= ((luma_filter5_out + 16) >> 5) > 255 ? 255 :(luma_filter5_out + 16) >> 5; 
		a3 <= luma_filter12_round_out; b3 <= ((luma_filter6_out + 16) >> 5) > 255 ? 255 :(luma_filter6_out + 16) >> 5; 
	end
	else begin //ref_x[1:0] == 1 && ref_y[1:0] == 1 ||
	           //ref_x[1:0] == 3 && ref_y[1:0] == 1 ||
	           //ref_x[1:0] == 1 && ref_y[1:0] == 3 ||
	           //ref_x[1:0] == 3 && ref_y[1:0] == 3 
		a0 <= luma_filter0_round_out; b0 <= luma_filter1_round_out;
		a1 <= luma_filter2_round_out; b1 <= luma_filter3_round_out;
		a2 <= luma_filter4_round_out; b2 <= luma_filter5_round_out;
		a3 <= luma_filter6_round_out; b3 <= luma_filter7_round_out;
	end
end
else begin
	a0 <= 0; b0 <= 0;
	a1 <= 0; b1 <= 0;
	a2 <= 0; b2 <= 0;
	a3 <= 0; b3 <= 0;
end

always @(posedge clk or negedge rst_n)
if (!rst_n) begin
	inter_pred_0  <= 0;
	inter_pred_1  <= 0;
	inter_pred_2  <= 0;
	inter_pred_3  <= 0;
	inter_pred_4  <= 0;
	inter_pred_5  <= 0;
	inter_pred_6  <= 0;
	inter_pred_7  <= 0;
	inter_pred_8  <= 0;
	inter_pred_9  <= 0;
	inter_pred_10 <= 0;
	inter_pred_11 <= 0;
	inter_pred_12 <= 0;
	inter_pred_13 <= 0;
	inter_pred_14 <= 0;
	inter_pred_15 <= 0;
end
else if (ena && calc) begin
	if(!chroma_cb_sel && !chroma_cr_sel) begin
		if ( ref_x[1:0] == 0 && ref_y[1:0] == 0) begin
			inter_pred_0  <= ref_00;
			inter_pred_1  <= ref_01;
			inter_pred_2  <= ref_02;
			inter_pred_3  <= ref_03;
			inter_pred_4  <= ref_10;
			inter_pred_5  <= ref_11;
			inter_pred_6  <= ref_12;
			inter_pred_7  <= ref_13;
			inter_pred_8  <= ref_20;
			inter_pred_9  <= ref_21;
			inter_pred_10 <= ref_22;
			inter_pred_11 <= ref_23;
			inter_pred_12 <= ref_30;
			inter_pred_13 <= ref_31;
			inter_pred_14 <= ref_32;
			inter_pred_15 <= ref_33;
		end
		else if (ref_x[1:0] == 2 && ref_y[1:0] != 0) begin
			case(counter)
			3: begin
				inter_pred_0 <= out0;
				inter_pred_4 <= out1;
				inter_pred_8 <= out2;
				inter_pred_12<= out3;
			end
			2:begin
				inter_pred_1 <= out0;
				inter_pred_5 <= out1;
				inter_pred_9 <= out2;
				inter_pred_13<= out3;
			end
			1:begin
				inter_pred_2 <= out0;
				inter_pred_6 <= out1;
				inter_pred_10<= out2;
				inter_pred_14<= out3;
			end
			0:begin
				inter_pred_3 <= out0;
				inter_pred_7 <= out1;
				inter_pred_11<= out2;
				inter_pred_15<= out3;
			end
			endcase
		end
		else begin
			case(counter)
			3: begin
				inter_pred_0 <= out0;
				inter_pred_1 <= out1;
				inter_pred_2 <= out2;
				inter_pred_3 <= out3;
			end
			2:begin
				inter_pred_4 <= out0;
				inter_pred_5 <= out1;
				inter_pred_6 <= out2;
				inter_pred_7 <= out3;
			end
			1:begin
				inter_pred_8 <= out0;
				inter_pred_9 <= out1;
				inter_pred_10<= out2;
				inter_pred_11<= out3;
			end
			0:begin
				inter_pred_12<= out0;
				inter_pred_13<= out1;
				inter_pred_14<= out2;
				inter_pred_15<= out3;
			end
			endcase
		end
	end
	else if (chroma_cb_sel || chroma_cr_sel) begin
		if (ref_x[2:0] == 0 && ref_y[2:0] == 0) begin
			inter_pred_0  <= ref_00;
			inter_pred_1  <= ref_01;
			inter_pred_2  <= ref_02;
			inter_pred_3  <= ref_03;
			inter_pred_4  <= ref_10;
			inter_pred_5  <= ref_11;
			inter_pred_6  <= ref_12;
			inter_pred_7  <= ref_13;
			inter_pred_8  <= ref_20;
			inter_pred_9  <= ref_21;
			inter_pred_10 <= ref_22;
			inter_pred_11 <= ref_23;
			inter_pred_12 <= ref_30;
			inter_pred_13 <= ref_31;
			inter_pred_14 <= ref_32;
			inter_pred_15 <= ref_33;
		end
		else begin
			case(counter)
			3: begin
				inter_pred_0 <= chroma_filter0_out;
				inter_pred_1 <= chroma_filter1_out;
				inter_pred_2 <= chroma_filter2_out;
				inter_pred_3 <= chroma_filter3_out;
			end
			2:begin
				inter_pred_4 <= chroma_filter0_out;
				inter_pred_5 <= chroma_filter1_out;
				inter_pred_6 <= chroma_filter2_out;
				inter_pred_7 <= chroma_filter3_out;
			end
			1:begin
				inter_pred_8 <= chroma_filter0_out;
				inter_pred_9 <= chroma_filter1_out;
				inter_pred_10<= chroma_filter2_out;
				inter_pred_11<= chroma_filter3_out;
			end
			0:begin
				inter_pred_12<= chroma_filter0_out;
				inter_pred_13<= chroma_filter1_out;
				inter_pred_14<= chroma_filter2_out;
				inter_pred_15<= chroma_filter3_out;
			end
			endcase
		end
	end
end

endmodule


module luma_filter
(
	a,
	b,
	c,
	d,
	e,
	f,
	out,
	round_out
);
input [7:0] a;
input [7:0] b;
input [7:0] c;
input [7:0] d;
input [7:0] e;
input [7:0] f;
output[14:0] out;
wire signed [14:0] out;
output[7:0]  round_out;
reg [7:0] round_out;
wire [8:0] aa;
wire [8:0] bb;
wire [8:0] cc;
wire signed [9:0] aaa;
wire signed [9:0] bbb;
wire signed [9:0] ccc;
assign aa =  a + f;
assign bb =  b + e;
assign cc =  c + d;
assign aaa = {1'b0, aa};
assign bbb = {1'b0, bb};
assign ccc = {1'b0, cc};

assign out = ( ((ccc) <<< 4 ) + (aaa) - (bbb) - (( (bbb)-(ccc) ) <<< 2 ) );

wire signed [13:0] round_tmp;
assign round_tmp = (out + 16) >>> 5;
always @(*)
if (round_tmp < 0)																											
	round_out <= 0;																											
else if (round_tmp > 255)																											
	round_out <= 255;																											
else																											
	round_out <= round_tmp[7:0];
																												
endmodule

module luma_filter2
(
	a,
	b,
	c,
	d,
	e,
	f,
	round_out
);
input [14:0] a;
input [14:0] b;
input [14:0] c;
input [14:0] d;
input [14:0] e;
input [14:0] f;
output[7:0]  round_out;

wire signed [19:0] out;
reg [7:0] round_out;
wire [14:0] aa;
wire [14:0] bb;
wire [14:0] cc;
wire signed [15:0] aaa;
wire signed [15:0] bbb;
wire signed [15:0] ccc;
assign aa =  a + f;
assign bb =  b + e;
assign cc =  c + d;
assign aaa = {1'b0, aa};
assign bbb = {1'b0, bb};
assign ccc = {1'b0, cc};

assign out = ( ((ccc) <<< 4 ) + (aaa) - (bbb) - (( (bbb)-(ccc) ) <<< 2 ) );

wire signed [19:0] round_tmp;
assign round_tmp = (out + 512) >>> 10;
always @(*)
if (round_tmp < 0)																											
	round_out <= 0;																											
else if (round_tmp > 255)																											
	round_out <= 255;																											
else																											
	round_out <= round_tmp[7:0];
																												
endmodule


module chroma_filter
(
	dx,
	dy,
	a,
	b,
	c,
	d,
	out
);
input [2:0] dx;
input [2:0] dy;
input [7:0] a;
input [7:0] b;
input [7:0] c;
input [7:0] d;
output[7:0] out;

assign out = ((8 - dx) * (8 - dy) * a +
			   dx      * (8 - dy) * b +
			  (8 - dx) *  dy      * c +
			   dx      *  dy      * d + 32)>>6;
endmodule
