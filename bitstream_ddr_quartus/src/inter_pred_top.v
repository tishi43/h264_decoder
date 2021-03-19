//--------------------------------------------------------------------------------------------------
// Design    : bitstream_p
// Author(s) : qiu bin, shi tian qi
// Email     : chat1@126.com, tishi1@126.com
// Copyright (C) 2013 qiu bin 
// All rights reserved                
//-------------------------------------------------------------------------------------------------


`include "defines.v"

module inter_pred_top
(
	clk,
	rst_n,
	ena,
	
	start,
	valid,

	blk4x4_counter,	
	pic_num_2to0,
    pic_width_in_mbs,
    pic_height_in_map_units,
    
	ref_x,
	ref_y,
	ref_idx,
	
	ref_mem_burst,
	ref_mem_burst_len_minus1,
	ref_mem_ready,
	ref_mem_valid,
	ref_mem_addr,
	ref_mem_data,
	ref_mem_rd,
	
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

input  start;
output valid;

input  [4:0]	blk4x4_counter;
input  [2:0]    pic_num_2to0;
input  [`mb_x_bits - 1:0] pic_width_in_mbs; 
input  [`mb_y_bits - 1:0] pic_height_in_map_units;

input  [`mb_x_bits + 5:0] ref_x;
input  [`mb_y_bits + 5:0] ref_y;
input  [2:0] ref_idx;

output          						ref_mem_burst;
output [4:0]    						ref_mem_burst_len_minus1;
input           						ref_mem_ready;
input          							ref_mem_valid;
output [`ext_buf_mem_addr_width-1:0]	ref_mem_addr;
input  [`ext_buf_mem_data_width-1:0] 	ref_mem_data;
output 									ref_mem_rd;

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

wire [2:0] state;
wire [7:0] counter;

wire [7:0] ref_00;
wire [7:0] ref_01;
wire [7:0] ref_02;
wire [7:0] ref_03;
wire [7:0] ref_04;
wire [7:0] ref_05;
wire [7:0] ref_06;
wire [7:0] ref_07;
wire [7:0] ref_08;
wire [7:0] ref_09;
wire [7:0] ref_10;
wire [7:0] ref_11;
wire [7:0] ref_12;
wire [7:0] ref_13;
wire [7:0] ref_14;
wire [7:0] ref_15;
wire [7:0] ref_16;
wire [7:0] ref_17;
wire [7:0] ref_18;
wire [7:0] ref_19;
wire [7:0] ref_20;
wire [7:0] ref_21;
wire [7:0] ref_22;
wire [7:0] ref_23;
wire [7:0] ref_24;
wire [7:0] ref_25;
wire [7:0] ref_26;
wire [7:0] ref_27;
wire [7:0] ref_28;
wire [7:0] ref_29;
wire [7:0] ref_30;
wire [7:0] ref_31;
wire [7:0] ref_32;
wire [7:0] ref_33;
wire [7:0] ref_34;
wire [7:0] ref_35;
wire [7:0] ref_36;
wire [7:0] ref_37;
wire [7:0] ref_38;
wire [7:0] ref_39;
wire [7:0] ref_40;
wire [7:0] ref_41;
wire [7:0] ref_42;
wire [7:0] ref_43;
wire [7:0] ref_44;
wire [7:0] ref_45;
wire [7:0] ref_46;
wire [7:0] ref_47;
wire [7:0] ref_48;
wire [7:0] ref_49;
wire [7:0] ref_50;
wire [7:0] ref_51;
wire [7:0] ref_52;
wire [7:0] ref_53;
wire [7:0] ref_54;
wire [7:0] ref_55;
wire [7:0] ref_56;
wire [7:0] ref_57;
wire [7:0] ref_58;
wire [7:0] ref_59;
wire [7:0] ref_60;
wire [7:0] ref_61;
wire [7:0] ref_62;
wire [7:0] ref_63;
wire [7:0] ref_64;
wire [7:0] ref_65;
wire [7:0] ref_66;
wire [7:0] ref_67;
wire [7:0] ref_68;
wire [7:0] ref_69;
wire [7:0] ref_70;
wire [7:0] ref_71;
wire [7:0] ref_72;
wire [7:0] ref_73;
wire [7:0] ref_74;
wire [7:0] ref_75;
wire [7:0] ref_76;
wire [7:0] ref_77;
wire [7:0] ref_78;
wire [7:0] ref_79;
wire [7:0] ref_80;
wire [7:0] ref_81;
wire [7:0] ref_82;
wire [7:0] ref_83;
wire [7:0] ref_84;
wire [7:0] ref_85;
wire [7:0] ref_86;
wire [7:0] ref_87;
wire [7:0] ref_88;
wire [7:0] ref_89;
wire [7:0] ref_90;
wire [7:0] ref_91;
wire [7:0] ref_92;
wire [7:0] ref_93;
wire [7:0] ref_94;
wire [7:0] ref_95;
wire [7:0] ref_96;
wire [7:0] ref_97;
wire [7:0] ref_98;
wire [7:0] ref_99;

inter_pred_calc inter_pred_calc
(
	.clk(clk),
	.rst_n(rst_n),
	.ena(ena),
	
	.calc(state[`inter_pred_calc_bit]),
  	.counter(counter[1:0]),
  	  
   	.chroma_cb_sel(chroma_cb_sel),
	.chroma_cr_sel(chroma_cr_sel),
	
	.ref_x(ref_x[2:0]),
	.ref_y(ref_y[2:0]),
	
	.ref_00(ref_00),
    .ref_01(ref_01),
    .ref_02(ref_02),
    .ref_03(ref_03),
    .ref_04(ref_04),
    .ref_05(ref_05),
    .ref_06(ref_06),
    .ref_07(ref_07),
    .ref_08(ref_08),
    .ref_10(ref_10),
    .ref_11(ref_11),
    .ref_12(ref_12),
    .ref_13(ref_13),
    .ref_14(ref_14),
    .ref_15(ref_15),
    .ref_16(ref_16),
    .ref_17(ref_17),
    .ref_18(ref_18),
    .ref_20(ref_20),
    .ref_21(ref_21),
    .ref_22(ref_22),
    .ref_23(ref_23),
    .ref_24(ref_24),
    .ref_25(ref_25),
    .ref_26(ref_26),
    .ref_27(ref_27),
    .ref_28(ref_28),
    .ref_30(ref_30),
    .ref_31(ref_31),
    .ref_32(ref_32),
    .ref_33(ref_33),
    .ref_34(ref_34),
    .ref_35(ref_35),
    .ref_36(ref_36),
    .ref_37(ref_37),
    .ref_38(ref_38),
    .ref_40(ref_40),
    .ref_41(ref_41),
    .ref_42(ref_42),
    .ref_43(ref_43),
    .ref_44(ref_44),
    .ref_45(ref_45),
    .ref_46(ref_46),
    .ref_47(ref_47),
    .ref_48(ref_48),
    .ref_50(ref_50),
    .ref_51(ref_51),
    .ref_52(ref_52),
    .ref_53(ref_53),
    .ref_54(ref_54),
    .ref_55(ref_55),
    .ref_56(ref_56),
    .ref_57(ref_57),
    .ref_58(ref_58),
    .ref_60(ref_60),
    .ref_61(ref_61),
    .ref_62(ref_62),
    .ref_63(ref_63),
    .ref_64(ref_64),
    .ref_65(ref_65),
    .ref_66(ref_66),
    .ref_67(ref_67),
    .ref_68(ref_68),
    .ref_70(ref_70),
    .ref_71(ref_71),
    .ref_72(ref_72),
    .ref_73(ref_73),
    .ref_74(ref_74),
    .ref_75(ref_75),
    .ref_76(ref_76),
    .ref_77(ref_77),
    .ref_78(ref_78),
    .ref_80(ref_80),
    .ref_81(ref_81),
    .ref_82(ref_82),
    .ref_83(ref_83),
    .ref_84(ref_84),
    .ref_85(ref_85),
    .ref_86(ref_86),
    .ref_87(ref_87),
    .ref_88(ref_88),
	
	.inter_pred_0(inter_pred_0),
	.inter_pred_1(inter_pred_1),
	.inter_pred_2(inter_pred_2),
	.inter_pred_3(inter_pred_3),
	.inter_pred_4(inter_pred_4),
	.inter_pred_5(inter_pred_5),
	.inter_pred_6(inter_pred_6),
	.inter_pred_7(inter_pred_7),
	.inter_pred_8(inter_pred_8),
	.inter_pred_9(inter_pred_9),
	.inter_pred_10(inter_pred_10),
	.inter_pred_11(inter_pred_11),
	.inter_pred_12(inter_pred_12),
	.inter_pred_13(inter_pred_13),
	.inter_pred_14(inter_pred_14),
	.inter_pred_15(inter_pred_15)
);

wire [7:0] ref_nword_left;
inter_pred_load inter_pred_load
(
	.clk(clk),
	.rst_n(rst_n),
	.ena(ena),
	
	.start(start),
	
	.chroma_cb_sel(chroma_cb_sel),
	.chroma_cr_sel(chroma_cr_sel),
	
	.pic_num_2to0(pic_num_2to0),
    .pic_width_in_mbs(pic_width_in_mbs),
    .pic_height_in_map_units(pic_height_in_map_units),
    
	.ref_x(ref_x),
	.ref_y(ref_y),
	.ref_idx(ref_idx),
	
	.ref_mem_burst(ref_mem_burst),
	.ref_mem_burst_len_minus1(ref_mem_burst_len_minus1),
	.ref_mem_ready(ref_mem_ready),
	.ref_mem_valid(ref_mem_valid),
	.ref_mem_addr(ref_mem_addr),
	.ref_mem_data(ref_mem_data),
	.ref_mem_rd(ref_mem_rd),

	.ref_load_sel(state[`inter_pred_load_bit]),
	.counter(counter),
	.ref_nword_left(ref_nword_left),
		
	.ref_00(ref_00),
    .ref_01(ref_01),
    .ref_02(ref_02),
    .ref_03(ref_03),
    .ref_04(ref_04),
    .ref_05(ref_05),
    .ref_06(ref_06),
    .ref_07(ref_07),
    .ref_08(ref_08),
    .ref_09(ref_09),
    .ref_10(ref_10),
    .ref_11(ref_11),
    .ref_12(ref_12),
    .ref_13(ref_13),
    .ref_14(ref_14),
    .ref_15(ref_15),
    .ref_16(ref_16),
    .ref_17(ref_17),
    .ref_18(ref_18),
    .ref_19(ref_19),
    .ref_20(ref_20),
    .ref_21(ref_21),
    .ref_22(ref_22),
    .ref_23(ref_23),
    .ref_24(ref_24),
    .ref_25(ref_25),
    .ref_26(ref_26),
    .ref_27(ref_27),
    .ref_28(ref_28),
    .ref_29(ref_29),
    .ref_30(ref_30),
    .ref_31(ref_31),
    .ref_32(ref_32),
    .ref_33(ref_33),
    .ref_34(ref_34),
    .ref_35(ref_35),
    .ref_36(ref_36),
    .ref_37(ref_37),
    .ref_38(ref_38),
    .ref_39(ref_39),
    .ref_40(ref_40),
    .ref_41(ref_41),
    .ref_42(ref_42),
    .ref_43(ref_43),
    .ref_44(ref_44),
    .ref_45(ref_45),
    .ref_46(ref_46),
    .ref_47(ref_47),
    .ref_48(ref_48),
    .ref_49(ref_49),
    .ref_50(ref_50),
    .ref_51(ref_51),
    .ref_52(ref_52),
    .ref_53(ref_53),
    .ref_54(ref_54),
    .ref_55(ref_55),
    .ref_56(ref_56),
    .ref_57(ref_57),
    .ref_58(ref_58),
    .ref_59(ref_59),
    .ref_60(ref_60),
    .ref_61(ref_61),
    .ref_62(ref_62),
    .ref_63(ref_63),
    .ref_64(ref_64),
    .ref_65(ref_65),
    .ref_66(ref_66),
    .ref_67(ref_67),
    .ref_68(ref_68),
    .ref_69(ref_69),
    .ref_70(ref_70),
    .ref_71(ref_71),
    .ref_72(ref_72),
    .ref_73(ref_73),
    .ref_74(ref_74),
    .ref_75(ref_75),
    .ref_76(ref_76),
    .ref_77(ref_77),
    .ref_78(ref_78),
    .ref_79(ref_79),
    .ref_80(ref_80),
    .ref_81(ref_81),
    .ref_82(ref_82),
    .ref_83(ref_83),
    .ref_84(ref_84),
    .ref_85(ref_85),
    .ref_86(ref_86),
    .ref_87(ref_87),
    .ref_88(ref_88),
    .ref_89(ref_89),
    .ref_90(ref_90),
    .ref_91(ref_91),
    .ref_92(ref_92),
    .ref_93(ref_93),
    .ref_94(ref_94),
    .ref_95(ref_95),
    .ref_96(ref_96),
    .ref_97(ref_97),
    .ref_98(ref_98),
    .ref_99(ref_99)
);


inter_pred_fsm inter_pred_fsm
(
	.clk(clk),
	.rst_n(rst_n),
	.ena(ena),
	
	.start(start),
	.valid(valid),
	
	.ref_x(ref_x),
	.ref_y(ref_y),
	
	.ref_mem_ready(ref_mem_ready),
	
	.blk4x4_counter(blk4x4_counter),
	.chroma_cb_sel(chroma_cb_sel),
	.chroma_cr_sel(chroma_cr_sel),
	.state(state),
	.counter(counter),
	.ref_nword_left(ref_nword_left)
);

endmodule
