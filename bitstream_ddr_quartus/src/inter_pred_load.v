//--------------------------------------------------------------------------------------------------
// Design    : bitstream_p
// Author(s) : qiu bin, shi tian qi
// Email     : chat1@126.com, tishi1@126.com
// Copyright (C) 2013 qiu bin 
// All rights reserved                
//-------------------------------------------------------------------------------------------------


`include "defines.v"

module inter_pred_load
(
    clk,
    rst_n,
    ena,
    
    start,
    
    chroma_cb_sel,
    chroma_cr_sel,
    
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
    
    ref_load_sel,
    counter,
    ref_nword_left,
    
    ref_00,
    ref_01,
    ref_02,
    ref_03,
    ref_04,
    ref_05,
    ref_06,
    ref_07,
    ref_08,
    ref_09,
    ref_10,
    ref_11,
    ref_12,
    ref_13,
    ref_14,
    ref_15,
    ref_16,
    ref_17,
    ref_18,
    ref_19,
    ref_20,
    ref_21,
    ref_22,
    ref_23,
    ref_24,
    ref_25,
    ref_26,
    ref_27,
    ref_28,
    ref_29,
    ref_30,
    ref_31,
    ref_32,
    ref_33,
    ref_34,
    ref_35,
    ref_36,
    ref_37,
    ref_38,
    ref_39,
    ref_40,
    ref_41,
    ref_42,
    ref_43,
    ref_44,
    ref_45,
    ref_46,
    ref_47,
    ref_48,
    ref_49,
    ref_50,
    ref_51,
    ref_52,
    ref_53,
    ref_54,
    ref_55,
    ref_56,
    ref_57,
    ref_58,
    ref_59,
    ref_60,
    ref_61,
    ref_62,
    ref_63,
    ref_64,
    ref_65,
    ref_66,
    ref_67,
    ref_68,
    ref_69,
    ref_70,
    ref_71,
    ref_72,
    ref_73,
    ref_74,
    ref_75,
    ref_76,
    ref_77,
    ref_78,
    ref_79,
    ref_80,
    ref_81,
    ref_82,
    ref_83,
    ref_84,
    ref_85,
    ref_86,
    ref_87,
    ref_88,
    ref_89,
    ref_90,
    ref_91,
    ref_92,
    ref_93,
    ref_94,
    ref_95,
    ref_96,
    ref_97,
    ref_98,
    ref_99
);  
input  clk;
input  rst_n;
input  ena;
    
input start;
    
input  chroma_cb_sel;
input  chroma_cr_sel;
    
input  [2:0]    pic_num_2to0;
input  [`mb_x_bits - 1:0] pic_width_in_mbs; 
input  [`mb_y_bits - 1:0] pic_height_in_map_units;
    
input  [`mb_x_bits + 5:0] ref_x;
input  [`mb_y_bits + 5:0] ref_y;
input  [2:0] ref_idx;

output                                  ref_mem_burst;
output [4:0]                            ref_mem_burst_len_minus1;
input                                   ref_mem_ready;
input                                   ref_mem_valid;
output [`ext_buf_mem_addr_width-1:0]    ref_mem_addr;
input  [`ext_buf_mem_data_width-1:0]    ref_mem_data;
output                                  ref_mem_rd;

input  ref_load_sel;
input  [7:0] counter;
output [7:0] ref_nword_left;


output [7:0] ref_00;
output [7:0] ref_01;
output [7:0] ref_02;
output [7:0] ref_03;
output [7:0] ref_04;
output [7:0] ref_05;
output [7:0] ref_06;
output [7:0] ref_07;
output [7:0] ref_08;
output [7:0] ref_09;
output [7:0] ref_10;
output [7:0] ref_11;
output [7:0] ref_12;
output [7:0] ref_13;
output [7:0] ref_14;
output [7:0] ref_15;
output [7:0] ref_16;
output [7:0] ref_17;
output [7:0] ref_18;
output [7:0] ref_19;
output [7:0] ref_20;
output [7:0] ref_21;
output [7:0] ref_22;
output [7:0] ref_23;
output [7:0] ref_24;
output [7:0] ref_25;
output [7:0] ref_26;
output [7:0] ref_27;
output [7:0] ref_28;
output [7:0] ref_29;
output [7:0] ref_30;
output [7:0] ref_31;
output [7:0] ref_32;
output [7:0] ref_33;
output [7:0] ref_34;
output [7:0] ref_35;
output [7:0] ref_36;
output [7:0] ref_37;
output [7:0] ref_38;
output [7:0] ref_39;
output [7:0] ref_40;
output [7:0] ref_41;
output [7:0] ref_42;
output [7:0] ref_43;
output [7:0] ref_44;
output [7:0] ref_45;
output [7:0] ref_46;
output [7:0] ref_47;
output [7:0] ref_48;
output [7:0] ref_49;
output [7:0] ref_50;
output [7:0] ref_51;
output [7:0] ref_52;
output [7:0] ref_53;
output [7:0] ref_54;
output [7:0] ref_55;
output [7:0] ref_56;
output [7:0] ref_57;
output [7:0] ref_58;
output [7:0] ref_59;
output [7:0] ref_60;
output [7:0] ref_61;
output [7:0] ref_62;
output [7:0] ref_63;
output [7:0] ref_64;
output [7:0] ref_65;
output [7:0] ref_66;
output [7:0] ref_67;
output [7:0] ref_68;
output [7:0] ref_69;
output [7:0] ref_70;
output [7:0] ref_71;
output [7:0] ref_72;
output [7:0] ref_73;
output [7:0] ref_74;
output [7:0] ref_75;
output [7:0] ref_76;
output [7:0] ref_77;
output [7:0] ref_78;
output [7:0] ref_79;
output [7:0] ref_80;
output [7:0] ref_81;
output [7:0] ref_82;
output [7:0] ref_83;
output [7:0] ref_84;
output [7:0] ref_85;
output [7:0] ref_86;
output [7:0] ref_87;
output [7:0] ref_88;
output [7:0] ref_89;
output [7:0] ref_90;
output [7:0] ref_91;
output [7:0] ref_92;
output [7:0] ref_93;
output [7:0] ref_94;
output [7:0] ref_95;
output [7:0] ref_96;
output [7:0] ref_97;
output [7:0] ref_98;
output [7:0] ref_99;

//FFs
reg  [`ext_buf_mem_addr_width-1:0]  luma_addr_base;
reg  [`ext_buf_mem_addr_width-1:0]  cb_addr_base;
reg  [`ext_buf_mem_addr_width-1:0]  cr_addr_base;
reg  [7:0]                          ref_p[0:99];
reg  [7:0]                          ref_nword_left;    
reg                                 ref_mem_rd;
reg [`ext_buf_mem_addr_width-1:0]   ref_mem_addr;
reg start_s;

integer k;
    
//comb
reg  [`ext_buf_mem_data_width-1:0]  ref_mem_data_tmp;

reg         ref_mem_burst;
reg [4:0]   ref_mem_burst_len_minus1;

reg signed [3:0] i;
reg signed [3:0] j;

reg signed [`mb_x_bits + 4:0] pixel_ref_x_unclip; 
reg signed [`mb_y_bits + 4:0] pixel_ref_y_unclip;
reg [`mb_x_bits + 3:0] pixel_ref_x_clip;
reg [`mb_y_bits + 3:0] pixel_ref_y_clip;

wire signed [`mb_x_bits + 3:0] ref_x_int = ref_x[`mb_x_bits + 5:2];
wire signed [`mb_y_bits + 3:0] ref_y_int = ref_y[`mb_y_bits + 5:2];
wire signed [`mb_x_bits + 2:0] chroma_ref_x_int = ref_x[`mb_x_bits + 5:3];
wire signed [`mb_y_bits + 2:0] chroma_ref_y_int = ref_y[`mb_y_bits + 5:3];

always @(posedge clk or negedge rst_n)
if (!rst_n)
	start_s <= 0;
else if (ena)
	start_s <= start;
	
wire start_trigger;

assign start_trigger = start && !start_s;

always @(*) //integer pixel positions
if (!chroma_cb_sel && !chroma_cr_sel) begin //luma
    pixel_ref_x_unclip <= ref_x_int + j;
    pixel_ref_y_unclip <= ref_y_int + i;
end
else begin  //chroma
    pixel_ref_x_unclip <= chroma_ref_x_int + j;
    pixel_ref_y_unclip <= chroma_ref_y_int + i;
end

always @(*)
if (pixel_ref_x_unclip[`mb_x_bits + 4]) begin   //out of left bound
    pixel_ref_x_clip <= 0;
end
else if ((!chroma_cb_sel && !chroma_cr_sel) &&
        pixel_ref_x_unclip[`mb_x_bits + 3:0] >= pic_width_in_mbs << 4) begin //luma out of right bound
    pixel_ref_x_clip <= (pic_width_in_mbs << 4) - 1;
end
else if ((chroma_cb_sel || chroma_cr_sel) &&
        pixel_ref_x_unclip[`mb_x_bits + 3:0] >= pic_width_in_mbs << 3) begin //chroma out of right bound
    pixel_ref_x_clip <= (pic_width_in_mbs << 3) - 1;
end
else begin
    pixel_ref_x_clip <= pixel_ref_x_unclip[`mb_x_bits + 3:0];
end

always @(*)
if (pixel_ref_y_unclip[`mb_y_bits + 4])//out of up bound
    pixel_ref_y_clip <= 0;
else if ((!chroma_cb_sel && !chroma_cr_sel) && 
        pixel_ref_y_unclip[`mb_y_bits + 3:0] >= pic_height_in_map_units << 4)//luma out of bottom bound
    pixel_ref_y_clip <= (pic_height_in_map_units << 4) - 1;
else if ((chroma_cb_sel || chroma_cr_sel) && 
        pixel_ref_y_unclip[`mb_y_bits + 3:0] >= pic_height_in_map_units << 3)//chroma out of bottom bound
    pixel_ref_y_clip <= (pic_height_in_map_units << 3) - 1;
else
    pixel_ref_y_clip <= pixel_ref_y_unclip[`mb_y_bits + 3:0];

always @(*)
if (!chroma_cb_sel && !chroma_cr_sel) //luma
    if (ref_x[1:0] == 0 && ref_y[1:0] == 0) begin
        case (counter)
        5:begin i <= 0; j <= 0; end
        4:begin i <= 1; j <= 0; end
        3:begin i <= 2; j <= 0; end
        2:begin i <= 3; j <= 0; end
        default:begin i <= 0; j <= 0; end
        endcase
    end
    else if (ref_x[1:0] == 0) begin
        case (counter)
        10:begin i <= -2; j <= 0; end
        09:begin i <= -1; j <= 0; end
        08:begin i <=  0; j <= 0; end
        07:begin i <=  1; j <= 0; end
        06:begin i <=  2; j <= 0; end
        05:begin i <=  3; j <= 0; end
        04:begin i <=  4; j <= 0; end
        03:begin i <=  5; j <= 0; end
        02:begin i <=  6; j <= 0; end
        default:begin i <= 0; j <= 0; end
        endcase
    end
    else if (ref_y[1:0] == 0)
        case (counter)
        13:begin i <=  0; j <= -2; end
        10:begin i <=  1; j <= -2; end
        07:begin i <=  2; j <= -2; end
        04:begin i <=  3; j <= -2; end
        default:begin i <= 0; j <= -2; end
        endcase
    else 
        case (counter)
        28:begin i <= -2; j <= -2; end
        25:begin i <= -1; j <= -2; end
        22:begin i <=  0; j <= -2; end
        19:begin i <=  1; j <= -2; end
        16:begin i <=  2; j <= -2; end
        13:begin i <=  3; j <= -2; end
        10:begin i <=  4; j <= -2; end
        07:begin i <=  5; j <= -2; end
        04:begin i <=  6; j <= -2; end
        default:begin i <= 0; j <= -2; end
        endcase
else if (chroma_cb_sel || chroma_cr_sel) begin
    if(ref_x[2:0] == 0 && ref_y[2:0] == 0) begin //chroma int
        case (counter)
        5:begin i <= 0; j <= 0; end
        4:begin i <= 1; j <= 0; end
        3:begin i <= 2; j <= 0; end
        2:begin i <= 3; j <= 0; end
        default:begin i <= 0; j <= 0; end
        endcase
    end
    else begin //chroma frac
        case (counter)
        11:begin i <= 0; j <= 0; end
        9:begin i <= 1; j <= 0; end
        7:begin i <= 2; j <= 0; end
        5:begin i <= 3; j <= 0; end
        3:begin i <= 4; j <= 0; end
        default:begin i <= 0; j <= 0; end
        endcase
    end
end
else begin
    i <= 0; j <= 0;
end

always @(*)
if (!chroma_cb_sel && !chroma_cr_sel) begin //luma
    if (ref_x[1:0] == 0) 
        ref_mem_burst_len_minus1 <= 0;
    else
        ref_mem_burst_len_minus1 <= 2;
end
else begin // if (chroma_cb_sel || chroma_cr_sel) 
    if (ref_x[2:0] == 0 && ref_y[2:0] == 0) //chroma int
        ref_mem_burst_len_minus1 <= 0;
    else
        ref_mem_burst_len_minus1 <= 1;
end

always @(*)
if (!chroma_cb_sel && !chroma_cr_sel && ref_load_sel) begin //luma
    if (ref_x[1:0] == 0 && ref_y[1:0] == 0) begin
        case (counter)
        5,4,3,2 :   ref_mem_burst <= 1;
        default:    ref_mem_burst <= 0;
        endcase
    end
    else if (ref_x[1:0] == 0) begin
        case (counter)
        10,9,8,7,6,
        5,4,3,2 : ref_mem_burst <= 1;
        default:    ref_mem_burst <= 0;
        endcase
    end
    else if (ref_y[1:0] == 0)begin
        case (counter)
        13,10,7,4  : ref_mem_burst <= 1;
        default:    ref_mem_burst <= 0;
        endcase
    end
    else begin
        case (counter)
        28,25,22,19,16,
        13,10,7,4 : ref_mem_burst <= 1;
        default:    ref_mem_burst <= 0;
        endcase
    end
end
else if (ref_load_sel)begin // if (chroma_cb_sel || chroma_cr_sel) 
    if (ref_x[2:0] == 0 && ref_y[2:0] == 0)begin //chroma int
        case (counter)
        5,4,3,2 : ref_mem_burst <= 1;
        default:  ref_mem_burst <= 0;
        endcase
    end
    else begin
        case (counter)
        11,9,7,5,3  : ref_mem_burst <= 1;
        default:      ref_mem_burst <= 0;
        endcase
    end
end
else begin
	ref_mem_burst <= 0;
end

always @(posedge clk or negedge rst_n)
if (!rst_n)
    ref_nword_left <= 0;
else if (ena && start_trigger) begin
    if (!chroma_cb_sel && !chroma_cr_sel) begin
        if (ref_x[1:0] == 0 && ref_y[1:0] == 0)
            ref_nword_left <= 4;
        else if (ref_x[1:0] == 0)
            ref_nword_left <= 9;
        else if (ref_y[1:0] == 0)
            ref_nword_left <= 12;
        else begin
            ref_nword_left <= 27;
        end
    end
    else if ((chroma_cb_sel || chroma_cr_sel) &&
         (ref_x[2:0] == 0 && ref_y[2:0] == 0)) //chroma int
            ref_nword_left <= 4;
    else //chroma frac
        ref_nword_left <= 10;
end
else if (ena && ref_mem_valid && ref_nword_left > 0) begin
    ref_nword_left <= ref_nword_left  - 1;
end


//cb_addr_base & cr_addr_base
wire [2:0] ref_pic_num;
assign ref_pic_num = pic_num_2to0 - 1 - ref_idx;

wire [`mb_x_bits + `mb_y_bits - 1:0] mbs_in_1_frame;
assign mbs_in_1_frame = pic_width_in_mbs * pic_height_in_map_units;

always @(posedge clk or negedge rst_n)
if (!rst_n) begin
    luma_addr_base <= 0;
    cb_addr_base <= 0;
    cr_addr_base <= 0;
end
else if (ena && start_trigger) begin
    luma_addr_base <= ref_pic_num * (mbs_in_1_frame *256 + mbs_in_1_frame * 128);
    cb_addr_base <= ref_pic_num * (mbs_in_1_frame * 256 + mbs_in_1_frame * 128) +
                    mbs_in_1_frame * 256;
    cr_addr_base <= ref_pic_num * (mbs_in_1_frame * 256 + mbs_in_1_frame * 128) +
                    mbs_in_1_frame * 256 + mbs_in_1_frame * 64;
end

always @(*)
if ( ena && ref_load_sel) begin
    if (!chroma_cb_sel && !chroma_cr_sel)
        ref_mem_addr <= luma_addr_base + pixel_ref_y_clip * pic_width_in_mbs * 16 + pixel_ref_x_clip;
    else if (chroma_cb_sel)
        ref_mem_addr <= cb_addr_base + pixel_ref_y_clip * pic_width_in_mbs * 8 + pixel_ref_x_clip;
    else if (chroma_cr_sel)
        ref_mem_addr <= cr_addr_base + pixel_ref_y_clip * pic_width_in_mbs * 8 + pixel_ref_x_clip;
    else
        ref_mem_addr <= 0;
end
else
    ref_mem_addr <= 0;
        
always @(posedge clk or negedge rst_n)
if (!rst_n)
    ref_mem_rd  <= 0;
else if (ena) begin
	if (ref_nword_left > 1)
	    ref_mem_rd <= 1;  
	else if (ref_mem_valid)
	    ref_mem_rd <= 0;
end 

//-----------------------------------------
// out of bund control
//-----------------------------------------
reg                                 ref_mem_burst_reg;
reg [`mb_x_bits + 3:0]              pixel_ref_x_clip_reg;
reg [7:0]                           right_most_pixel;

reg [4:0] ref_mem_burst_len_minus1_reg;
reg signed [`mb_x_bits + 4:0] pixel_ref_x_unclip_reg; 

reg [31:0] ref_mem_data_reg0;
reg [31:0] ref_mem_data_reg1;
reg [31:0] ref_mem_data_reg2;
reg [31:0] ref_mem_data_reg0_tmp;
reg [31:0] ref_mem_data_reg1_tmp;
reg [31:0] ref_mem_data_reg2_tmp;

reg        use_ref_mem_data;
reg        first_ref_mem_data;
reg [1:0]  ref_mem_data_reg_wr_ptr;


always @(posedge clk or negedge rst_n)
if (!rst_n)
	ref_mem_burst_len_minus1_reg <= 0;
else if (ena) begin
    if (start_trigger || ref_mem_burst_len_minus1_reg == 0 && ref_mem_valid)
        ref_mem_burst_len_minus1_reg <= ref_mem_burst_len_minus1;
    else if (ref_mem_valid)
        ref_mem_burst_len_minus1_reg <= ref_mem_burst_len_minus1_reg - 1'b1;
end

//out of right bound
always @(posedge clk or negedge rst_n)
if (!rst_n) begin
    pixel_ref_x_clip_reg <= 0;
    ref_mem_burst_reg <= 0;
end
else if (ena) begin
    ref_mem_burst_reg <= ref_mem_burst;
    if (start_trigger || ref_mem_burst_len_minus1_reg == 0 && ref_mem_valid)
        pixel_ref_x_clip_reg <= pixel_ref_x_clip;
    else if (ref_mem_valid)
        pixel_ref_x_clip_reg <= pixel_ref_x_clip_reg + 4;
end

always @(posedge clk or negedge rst_n)
if (!rst_n)
    right_most_pixel <= 0;
else if (ena && ref_load_sel) begin
    if ((!chroma_cb_sel && !chroma_cr_sel) && pixel_ref_x_clip_reg ==  (pic_width_in_mbs << 4) - 4 ||
        (chroma_cb_sel || chroma_cr_sel) && pixel_ref_x_clip_reg ==  (pic_width_in_mbs << 3) - 4)
        right_most_pixel <= ref_mem_data[31:24];
    else if ((!chroma_cb_sel && !chroma_cr_sel) && pixel_ref_x_clip_reg ==  (pic_width_in_mbs << 4) - 3 ||
        (chroma_cb_sel || chroma_cr_sel) && pixel_ref_x_clip_reg ==  (pic_width_in_mbs << 3) - 3)
        right_most_pixel <= ref_mem_data[23:16];
    else if ((!chroma_cb_sel && !chroma_cr_sel) && pixel_ref_x_clip_reg ==  (pic_width_in_mbs << 4) - 2 ||
        (chroma_cb_sel || chroma_cr_sel) && pixel_ref_x_clip_reg ==  (pic_width_in_mbs << 3) - 2)
        right_most_pixel <= ref_mem_data[15:8];
    else if ((!chroma_cb_sel && !chroma_cr_sel) && pixel_ref_x_clip_reg ==  (pic_width_in_mbs << 4) - 1 ||
        (chroma_cb_sel || chroma_cr_sel) && pixel_ref_x_clip_reg ==  (pic_width_in_mbs << 3) - 1)
        right_most_pixel <= ref_mem_data[7:0];
end

//out of left bound

always @(posedge clk or negedge rst_n)
if (!rst_n) begin
	pixel_ref_x_unclip_reg <= 0;
	use_ref_mem_data <= 0;
end
else if (ena) begin
    if (start_trigger || ref_mem_burst_len_minus1_reg == 0 && ref_mem_valid) begin
        pixel_ref_x_unclip_reg <= pixel_ref_x_unclip;
        use_ref_mem_data <= pixel_ref_x_unclip > -4;
    end
    else if (ref_mem_valid && pixel_ref_x_unclip < 0)
        pixel_ref_x_unclip_reg <= pixel_ref_x_unclip_reg + 3'd4;
end
    

always @(posedge clk or negedge rst_n)
if (!rst_n) begin
    ref_mem_data_reg_wr_ptr <= 0;
    first_ref_mem_data  <= 0;
    ref_mem_data_reg0 <= 0;
    ref_mem_data_reg1 <= 0;
    ref_mem_data_reg2 <= 0;
end
else if (ena && pixel_ref_x_unclip < 0) begin
    if (start_trigger || ref_mem_burst_len_minus1_reg == 0)begin
        ref_mem_data_reg_wr_ptr <= 0;
        first_ref_mem_data  <= 1;
    end
    else if (ref_mem_valid) begin
        if (ref_mem_data_reg_wr_ptr == 0) 
            ref_mem_data_reg0 <= ref_mem_data;
        else if (ref_mem_data_reg_wr_ptr == 1) 
            ref_mem_data_reg1 <= ref_mem_data;
        else if (ref_mem_data_reg_wr_ptr == 2) 
            ref_mem_data_reg2 <= ref_mem_data;
        ref_mem_data_reg_wr_ptr <= ref_mem_data_reg_wr_ptr + 1'b1;
        first_ref_mem_data  <= 0;
    end
end


always @(*)
if (first_ref_mem_data || use_ref_mem_data)
    ref_mem_data_reg0_tmp <= ref_mem_data;
else
    ref_mem_data_reg0_tmp <= ref_mem_data_reg0;

always @(*)
if (use_ref_mem_data)
    ref_mem_data_reg1_tmp <= ref_mem_data;
else
    ref_mem_data_reg1_tmp <= ref_mem_data_reg1;

always @(*)
if (use_ref_mem_data)
    ref_mem_data_reg2_tmp <= ref_mem_data;
else
    ref_mem_data_reg2_tmp <= ref_mem_data_reg2;
    
//out of bound muxer
always @(*)
if (pixel_ref_x_unclip_reg <= -3)
    ref_mem_data_tmp <= {4{ref_mem_data_reg0_tmp[7:0]}};
else if (pixel_ref_x_unclip_reg == -2)
    ref_mem_data_tmp <= {ref_mem_data_reg0_tmp[15:8],
                       {3{ref_mem_data_reg0_tmp[7:0]}}};
else if(pixel_ref_x_unclip_reg == -1)
    ref_mem_data_tmp <= {ref_mem_data_reg0_tmp[23:8],
                        {2{ref_mem_data_reg0_tmp[7:0]}}};
else if (pixel_ref_x_unclip < 0 && pixel_ref_x_unclip_reg == 0)
    ref_mem_data_tmp <= ref_mem_data_reg0;
else if (pixel_ref_x_unclip < 0 && pixel_ref_x_unclip_reg == 1)
    ref_mem_data_tmp <= {ref_mem_data_reg1_tmp[7:0],ref_mem_data_reg0[31:8]};
else if (pixel_ref_x_unclip < 0 && pixel_ref_x_unclip_reg == 2)
    ref_mem_data_tmp <= {ref_mem_data_reg1_tmp[15:0],ref_mem_data_reg0[31:16]};
else if (pixel_ref_x_unclip < 0 && pixel_ref_x_unclip_reg == 3)
    ref_mem_data_tmp <= {ref_mem_data_reg1_tmp[23:0],ref_mem_data_reg0[31:24]};
else if (pixel_ref_x_unclip < 0 && pixel_ref_x_unclip_reg == 4)
    ref_mem_data_tmp <= ref_mem_data_reg1_tmp;
else if (pixel_ref_x_unclip < 0 && pixel_ref_x_unclip_reg == 5)
    ref_mem_data_tmp <= {ref_mem_data_reg2_tmp[7:0],ref_mem_data_reg1[31:8]};
else if (pixel_ref_x_unclip < 0 && pixel_ref_x_unclip_reg == 6)
    ref_mem_data_tmp <= {ref_mem_data_reg2_tmp[15:0],ref_mem_data_reg1[31:16]};
else if (pixel_ref_x_unclip < 0 && pixel_ref_x_unclip_reg == 7)
    ref_mem_data_tmp <= {ref_mem_data_reg2_tmp[23:0],ref_mem_data_reg1[31:24]};
else if ((!chroma_cb_sel && !chroma_cr_sel) && pixel_ref_x_clip_reg <= (pic_width_in_mbs << 4) - 4 ||
    (chroma_cb_sel || chroma_cr_sel) && pixel_ref_x_clip_reg <= (pic_width_in_mbs << 3) - 4)
    ref_mem_data_tmp <= ref_mem_data;
else if ((!chroma_cb_sel && !chroma_cr_sel) && pixel_ref_x_clip_reg == (pic_width_in_mbs << 4) - 3 ||
    (chroma_cb_sel || chroma_cr_sel) && pixel_ref_x_clip_reg == (pic_width_in_mbs << 3) - 3)
    ref_mem_data_tmp <= {ref_mem_data[23:16], ref_mem_data[23:0]};
else if ((!chroma_cb_sel && !chroma_cr_sel) && pixel_ref_x_clip_reg == (pic_width_in_mbs << 4) - 2 ||
    (chroma_cb_sel || chroma_cr_sel) && pixel_ref_x_clip_reg == (pic_width_in_mbs << 3) - 2)
    ref_mem_data_tmp <= {ref_mem_data[15:8], ref_mem_data[15:8], ref_mem_data[15:0]};
else if ((!chroma_cb_sel && !chroma_cr_sel) && pixel_ref_x_clip_reg == (pic_width_in_mbs << 4) - 1 ||
    (chroma_cb_sel || chroma_cr_sel) && pixel_ref_x_clip_reg == (pic_width_in_mbs << 3) - 1)
    ref_mem_data_tmp <= {ref_mem_data[7:0], ref_mem_data[7:0], ref_mem_data[7:0], ref_mem_data[7:0]};
else 
    ref_mem_data_tmp <= {right_most_pixel, right_most_pixel, right_most_pixel, right_most_pixel};

always @(posedge clk or negedge rst_n)
if (!rst_n) begin : clear
    ref_p[00] <= 0;
    ref_p[01] <= 0;
    ref_p[02] <= 0;
    ref_p[03] <= 0;
    ref_p[04] <= 0;
    ref_p[05] <= 0;
    ref_p[06] <= 0;
    ref_p[07] <= 0;
    ref_p[08] <= 0;
    ref_p[10] <= 0;
    ref_p[11] <= 0;
    ref_p[12] <= 0;
    ref_p[13] <= 0;
    ref_p[14] <= 0;
    ref_p[15] <= 0;
    ref_p[16] <= 0;
    ref_p[17] <= 0;
    ref_p[18] <= 0;
    ref_p[20] <= 0;
    ref_p[21] <= 0;
    ref_p[22] <= 0;
    ref_p[23] <= 0;
    ref_p[24] <= 0;
    ref_p[25] <= 0;
    ref_p[26] <= 0;
    ref_p[27] <= 0;
    ref_p[28] <= 0;
    ref_p[30] <= 0;
    ref_p[31] <= 0;
    ref_p[32] <= 0;
    ref_p[33] <= 0;
    ref_p[34] <= 0;
    ref_p[35] <= 0;
    ref_p[36] <= 0;
    ref_p[37] <= 0;
    ref_p[38] <= 0;
    ref_p[40] <= 0;
    ref_p[41] <= 0;
    ref_p[42] <= 0;
    ref_p[43] <= 0;
    ref_p[44] <= 0;
    ref_p[45] <= 0;
    ref_p[46] <= 0;
    ref_p[47] <= 0;
    ref_p[48] <= 0;
    ref_p[50] <= 0;
    ref_p[51] <= 0;
    ref_p[52] <= 0;
    ref_p[53] <= 0;
    ref_p[54] <= 0;
    ref_p[55] <= 0;
    ref_p[56] <= 0;
    ref_p[57] <= 0;
    ref_p[58] <= 0;
    ref_p[60] <= 0;
    ref_p[61] <= 0;
    ref_p[62] <= 0;
    ref_p[63] <= 0;
    ref_p[64] <= 0;
    ref_p[65] <= 0;
    ref_p[66] <= 0;
    ref_p[67] <= 0;
    ref_p[68] <= 0;
    ref_p[70] <= 0;
    ref_p[71] <= 0;
    ref_p[72] <= 0;
    ref_p[73] <= 0;
    ref_p[74] <= 0;
    ref_p[75] <= 0;
    ref_p[76] <= 0;
    ref_p[77] <= 0;
    ref_p[78] <= 0;
    ref_p[80] <= 0;
    ref_p[81] <= 0;
    ref_p[82] <= 0;
    ref_p[83] <= 0;
    ref_p[84] <= 0;
    ref_p[85] <= 0;
    ref_p[86] <= 0;
    ref_p[87] <= 0;
    ref_p[88] <= 0;
    ref_p[99] <= 0;
end 
else if (ena && ref_load_sel && ref_mem_valid) begin
    if (!chroma_cb_sel && !chroma_cr_sel) begin
        if (ref_x[1:0] == 0 && ref_y[1:0] == 0) begin
            case(ref_nword_left)
            4:{ref_p[03], ref_p[02], ref_p[01], ref_p[00]} <= ref_mem_data_tmp;
            3:{ref_p[13], ref_p[12], ref_p[11], ref_p[10]} <= ref_mem_data_tmp;
            2:{ref_p[23], ref_p[22], ref_p[21], ref_p[20]} <= ref_mem_data_tmp;
            1:{ref_p[33], ref_p[32], ref_p[31], ref_p[30]} <= ref_mem_data_tmp;
            endcase
        end
        else if (ref_x[1:0] == 0) begin
            case (ref_nword_left)
            9:{ref_p[03], ref_p[02], ref_p[01], ref_p[00]} <= ref_mem_data_tmp;
            8:{ref_p[13], ref_p[12], ref_p[11], ref_p[10]} <= ref_mem_data_tmp;
            7:{ref_p[23], ref_p[22], ref_p[21], ref_p[20]} <= ref_mem_data_tmp;
            6:{ref_p[33], ref_p[32], ref_p[31], ref_p[30]} <= ref_mem_data_tmp;
            5:{ref_p[43], ref_p[42], ref_p[41], ref_p[40]} <= ref_mem_data_tmp;
            4:{ref_p[53], ref_p[52], ref_p[51], ref_p[50]} <= ref_mem_data_tmp;
            3:{ref_p[63], ref_p[62], ref_p[61], ref_p[60]} <= ref_mem_data_tmp;
            2:{ref_p[73], ref_p[72], ref_p[71], ref_p[70]} <= ref_mem_data_tmp;
            1:{ref_p[83], ref_p[82], ref_p[81], ref_p[80]} <= ref_mem_data_tmp;
            endcase
        end
        else if (ref_y[1:0] == 0) begin
            case (ref_nword_left)
            12:{ref_p[03], ref_p[02], ref_p[01], ref_p[00]} <= ref_mem_data_tmp;
            11:{ref_p[07], ref_p[06], ref_p[05], ref_p[04]} <= ref_mem_data_tmp;
            10:{ref_p[99], ref_p[98], ref_p[97], ref_p[08]} <= ref_mem_data_tmp;
            09:{ref_p[13], ref_p[12], ref_p[11], ref_p[10]} <= ref_mem_data_tmp;
            08:{ref_p[17], ref_p[16], ref_p[15], ref_p[14]} <= ref_mem_data_tmp;
            07:{ref_p[99], ref_p[98], ref_p[97], ref_p[18]} <= ref_mem_data_tmp;
            06:{ref_p[23], ref_p[22], ref_p[21], ref_p[20]} <= ref_mem_data_tmp;
            05:{ref_p[27], ref_p[26], ref_p[25], ref_p[24]} <= ref_mem_data_tmp;
            04:{ref_p[99], ref_p[98], ref_p[97], ref_p[28]} <= ref_mem_data_tmp;
            03:{ref_p[33], ref_p[32], ref_p[31], ref_p[30]} <= ref_mem_data_tmp;
            02:{ref_p[37], ref_p[36], ref_p[35], ref_p[34]} <= ref_mem_data_tmp;
            01:{ref_p[99], ref_p[98], ref_p[97], ref_p[38]} <= ref_mem_data_tmp;    
            endcase
        end
        else begin 
            case (ref_nword_left)
            27:{ref_p[03], ref_p[02], ref_p[01], ref_p[00]} <= ref_mem_data_tmp;
            26:{ref_p[07], ref_p[06], ref_p[05], ref_p[04]} <= ref_mem_data_tmp;
            25:{ref_p[99], ref_p[98], ref_p[97], ref_p[08]} <= ref_mem_data_tmp;
            24:{ref_p[13], ref_p[12], ref_p[11], ref_p[10]} <= ref_mem_data_tmp;
            23:{ref_p[17], ref_p[16], ref_p[15], ref_p[14]} <= ref_mem_data_tmp;
            22:{ref_p[99], ref_p[98], ref_p[97], ref_p[18]} <= ref_mem_data_tmp;
            21:{ref_p[23], ref_p[22], ref_p[21], ref_p[20]} <= ref_mem_data_tmp;
            20:{ref_p[27], ref_p[26], ref_p[25], ref_p[24]} <= ref_mem_data_tmp;
            19:{ref_p[99], ref_p[98], ref_p[97], ref_p[28]} <= ref_mem_data_tmp;
            18:{ref_p[33], ref_p[32], ref_p[31], ref_p[30]} <= ref_mem_data_tmp;
            17:{ref_p[37], ref_p[36], ref_p[35], ref_p[34]} <= ref_mem_data_tmp;
            16:{ref_p[99], ref_p[98], ref_p[97], ref_p[38]} <= ref_mem_data_tmp;    
            15:{ref_p[43], ref_p[42], ref_p[41], ref_p[40]} <= ref_mem_data_tmp;
            14:{ref_p[47], ref_p[46], ref_p[45], ref_p[44]} <= ref_mem_data_tmp;
            13:{ref_p[99], ref_p[98], ref_p[97], ref_p[48]} <= ref_mem_data_tmp;
            12:{ref_p[53], ref_p[52], ref_p[51], ref_p[50]} <= ref_mem_data_tmp;
            11:{ref_p[57], ref_p[56], ref_p[55], ref_p[54]} <= ref_mem_data_tmp;
            10:{ref_p[99], ref_p[98], ref_p[97], ref_p[58]} <= ref_mem_data_tmp;
            09:{ref_p[63], ref_p[62], ref_p[61], ref_p[60]} <= ref_mem_data_tmp;
            08:{ref_p[67], ref_p[66], ref_p[65], ref_p[64]} <= ref_mem_data_tmp;
            07:{ref_p[99], ref_p[98], ref_p[97], ref_p[68]} <= ref_mem_data_tmp;
            06:{ref_p[73], ref_p[72], ref_p[71], ref_p[70]} <= ref_mem_data_tmp;
            05:{ref_p[77], ref_p[76], ref_p[75], ref_p[74]} <= ref_mem_data_tmp;
            04:{ref_p[99], ref_p[98], ref_p[97], ref_p[78]} <= ref_mem_data_tmp;    
            03:{ref_p[83], ref_p[82], ref_p[81], ref_p[80]} <= ref_mem_data_tmp;
            02:{ref_p[87], ref_p[86], ref_p[85], ref_p[84]} <= ref_mem_data_tmp;
            01:{ref_p[99], ref_p[98], ref_p[97], ref_p[88]} <= ref_mem_data_tmp;
            endcase
        end
    end
    else begin //if (chroma_cb_sel || chroma_cr_sel) 
        if(ref_x[2:0] == 0 && ref_y[2:0] == 0) begin//chroma int 
            case(ref_nword_left)
            4:{ref_p[03], ref_p[02], ref_p[01], ref_p[00]} <= ref_mem_data_tmp;
            3:{ref_p[13], ref_p[12], ref_p[11], ref_p[10]} <= ref_mem_data_tmp;
            2:{ref_p[23], ref_p[22], ref_p[21], ref_p[20]} <= ref_mem_data_tmp;
            1:{ref_p[33], ref_p[32], ref_p[31], ref_p[30]} <= ref_mem_data_tmp;
            endcase
        end
        else begin  //chroma frac
            case(ref_nword_left)
            10:{ref_p[03], ref_p[02], ref_p[01], ref_p[00]} <= ref_mem_data_tmp;
            09:{ref_p[99], ref_p[98], ref_p[97], ref_p[04]} <= ref_mem_data_tmp;
            08:{ref_p[13], ref_p[12], ref_p[11], ref_p[10]} <= ref_mem_data_tmp;
            07:{ref_p[99], ref_p[98], ref_p[97], ref_p[14]} <= ref_mem_data_tmp;
            06:{ref_p[23], ref_p[22], ref_p[21], ref_p[20]} <= ref_mem_data_tmp;
            05:{ref_p[99], ref_p[98], ref_p[97], ref_p[24]} <= ref_mem_data_tmp;
            04:{ref_p[33], ref_p[32], ref_p[31], ref_p[30]} <= ref_mem_data_tmp;
            03:{ref_p[99], ref_p[98], ref_p[97], ref_p[34]} <= ref_mem_data_tmp;
            02:{ref_p[43], ref_p[42], ref_p[41], ref_p[40]} <= ref_mem_data_tmp;
            01:{ref_p[99], ref_p[98], ref_p[97], ref_p[44]} <= ref_mem_data_tmp;
            endcase
        end
    end
end

assign ref_00 = ref_p[00];
assign ref_01 = ref_p[01];
assign ref_02 = ref_p[02];
assign ref_03 = ref_p[03];
assign ref_04 = ref_p[04];
assign ref_05 = ref_p[05];
assign ref_06 = ref_p[06];
assign ref_07 = ref_p[07];
assign ref_08 = ref_p[08];
assign ref_09 = ref_p[09];
assign ref_10 = ref_p[10];
assign ref_11 = ref_p[11];
assign ref_12 = ref_p[12];
assign ref_13 = ref_p[13];
assign ref_14 = ref_p[14];
assign ref_15 = ref_p[15];
assign ref_16 = ref_p[16];
assign ref_17 = ref_p[17];
assign ref_18 = ref_p[18];
assign ref_19 = ref_p[19];
assign ref_20 = ref_p[20];
assign ref_21 = ref_p[21];
assign ref_22 = ref_p[22];
assign ref_23 = ref_p[23];
assign ref_24 = ref_p[24];
assign ref_25 = ref_p[25];
assign ref_26 = ref_p[26];
assign ref_27 = ref_p[27];
assign ref_28 = ref_p[28];
assign ref_29 = ref_p[29];
assign ref_30 = ref_p[30];
assign ref_31 = ref_p[31];
assign ref_32 = ref_p[32];
assign ref_33 = ref_p[33];
assign ref_34 = ref_p[34];
assign ref_35 = ref_p[35];
assign ref_36 = ref_p[36];
assign ref_37 = ref_p[37];
assign ref_38 = ref_p[38];
assign ref_39 = ref_p[39];
assign ref_40 = ref_p[40];
assign ref_41 = ref_p[41];
assign ref_42 = ref_p[42];
assign ref_43 = ref_p[43];
assign ref_44 = ref_p[44];
assign ref_45 = ref_p[45];
assign ref_46 = ref_p[46];
assign ref_47 = ref_p[47];
assign ref_48 = ref_p[48];
assign ref_49 = ref_p[49];
assign ref_50 = ref_p[50];
assign ref_51 = ref_p[51];
assign ref_52 = ref_p[52];
assign ref_53 = ref_p[53];
assign ref_54 = ref_p[54];
assign ref_55 = ref_p[55];
assign ref_56 = ref_p[56];
assign ref_57 = ref_p[57];
assign ref_58 = ref_p[58];
assign ref_59 = ref_p[59];
assign ref_60 = ref_p[60];
assign ref_61 = ref_p[61];
assign ref_62 = ref_p[62];
assign ref_63 = ref_p[63];
assign ref_64 = ref_p[64];
assign ref_65 = ref_p[65];
assign ref_66 = ref_p[66];
assign ref_67 = ref_p[67];
assign ref_68 = ref_p[68];
assign ref_69 = ref_p[69];
assign ref_70 = ref_p[70];
assign ref_71 = ref_p[71];
assign ref_72 = ref_p[72];
assign ref_73 = ref_p[73];
assign ref_74 = ref_p[74];
assign ref_75 = ref_p[75];
assign ref_76 = ref_p[76];
assign ref_77 = ref_p[77];
assign ref_78 = ref_p[78];
assign ref_79 = ref_p[79];
assign ref_80 = ref_p[80];
assign ref_81 = ref_p[81];
assign ref_82 = ref_p[82];
assign ref_83 = ref_p[83];
assign ref_84 = ref_p[84];
assign ref_85 = ref_p[85];
assign ref_86 = ref_p[86];
assign ref_87 = ref_p[87];
assign ref_88 = ref_p[88];
assign ref_89 = ref_p[89];
assign ref_90 = ref_p[90];
assign ref_91 = ref_p[91];
assign ref_92 = ref_p[92];
assign ref_93 = ref_p[93];
assign ref_94 = ref_p[94];
assign ref_95 = ref_p[95];
assign ref_96 = ref_p[96];
assign ref_97 = ref_p[97];
assign ref_98 = ref_p[98];
assign ref_99 = ref_p[99];


endmodule   
