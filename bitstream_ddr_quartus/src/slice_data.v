//--------------------------------------------------------------------------------------------------
// Design    : bitstream_p
// Author(s) : qiu bin, shi tian qi
// Email     : chat1@126.com, tishi1@126.com
// Copyright (C) 2013 qiu bin 
// All rights reserved                
//-------------------------------------------------------------------------------------------------


`include "defines.v"

module slice_data
(
 clk,
 rst_n,
 ena,
 rbsp_in,
 slice_type_mod5_in,
 pic_width_in_mbs_minus1_sps_in,
 pic_height_in_map_units_minus1_sps_in,
 num_ref_idx_l0_active_minus1_in,
 exp_golomb_decoding_output_in,
 exp_golomb_decoding_output_se_in,
 exp_golomb_decoding_output_te_in,
 exp_golomb_decoding_len_in,
 exp_golomb_decoding_me_intra4x4_out,
 exp_golomb_decoding_te_sel_out,
 
 CBP_luma_in,
 CBP_chroma_in,
 pic_init_qp_minus26_pps_in,
 slice_qp_delta_slice_header_in,
 chroma_qp_index_offset_pps_in,
 nC_in, // input from nC_decoding
 nC_cb_in,
 nC_cr_in,
 I4_pred_mode_in,
 mvpx_l0_in,
 mvpy_l0_in,
 
 qp,
 qp_c,
 residual_state,
 slice_data_state,
 mb_index_out,
 forward_len_out,
 mb_x_out, 
 mb_y_out,
 pixel_x_out,
 pixel_y_out,
 luma4x4BlkIdx_out,
 chroma4x4BlkIdx_out,
 luma4x4BlkIdx_x_out,
 luma4x4BlkIdx_y_out,
 blk4x4_counter,
 
 nC, // output to CAVLC
 nC_curr_mb_out,
 nC_left_mb_out,
 nC_up_mb_out,
 nC_cb_curr_mb_out,
 nC_cb_left_mb_out,
 nC_cb_up_mb_out,
 nC_cr_curr_mb_out,
 nC_cr_left_mb_out,
 nC_cr_up_mb_out,
 
 start_of_MB,
 end_of_MB,
 residual_start,
 intra_pred_start,
 sum_start,
 residual_valid,
 intra_pred_valid,
 sum_valid, 
 max_coeff_num,
 TotalCoeff, 
 len_comb,
 cavlc_idle,
 mb_pred_inter_sel,

 mb_pred_mode_out,
 I16_pred_mode_out,
 I4_pred_mode_out,
 intra_pred_mode_chroma,
 
 ref_x,
 ref_y,
 ref_idx,
 inter_pred_start,
 inter_pred_valid,
 
 intra4x4_pred_mode_up_mb_out,
 intra4x4_pred_mode_left_mb_out,
 intra4x4_pred_mode_curr_mb_out,
 prev_intra4x4_pred_mode_flag_out,
 rem_intra4x4_pred_mode_out,
 
 MbPartWidth,
 MbPartHeight,
 ref_idx_l0_out,
 ref_idx_l0_left_mb_out,
 ref_idx_l0_curr_mb_out,
 ref_idx_l0_up_left_mb_out,
 ref_idx_l0_up_mb_out,
 ref_idx_l0_up_right_mb_out,
 mvx_l0_left_mb_out,
 mvy_l0_left_mb_out,
 mvx_l0_up_left_mb_out,
 mvy_l0_up_left_mb_out,
 mvx_l0_up_mb_out,
 mvy_l0_up_mb_out,
 mvx_l0_up_right_mb_out,
 mvy_l0_up_right_mb_out,
 mvx_l0_curr_mb_out,
 mvy_l0_curr_mb_out,
 
 fpga_ram_intra4x4_pred_mode_wr_n,
 fpga_ram_intra4x4_pred_mode_addr,     
 fpga_ram_intra4x4_pred_mode_data_in,
 fpga_ram_intra4x4_pred_mode_data_out,
 fpga_ram_mvx_wr_n,
 fpga_ram_mvx_addr,
 fpga_ram_mvx_data_in,
 fpga_ram_mvx_data_out,  
 fpga_ram_mvy_wr_n,
 fpga_ram_mvy_addr,    
 fpga_ram_mvy_data_in,
 fpga_ram_mvy_data_out,
 fpga_ram_ref_idx_wr_n,
 fpga_ram_ref_idx_addr,
 fpga_ram_ref_idx_data_in,
 fpga_ram_ref_idx_data_out, 
 fpga_ram_qp_wr_n,
 fpga_ram_qp_addr,   
 fpga_ram_qp_data_in,
 fpga_ram_qp_data_out,
 fpga_ram_qp_c_wr_n,
 fpga_ram_qp_c_addr,
 fpga_ram_qp_c_data_in,
 fpga_ram_qp_c_data_out, 
 fpga_ram_nnz_wr_n,
 fpga_ram_nnz_addr,     
 fpga_ram_nnz_data_in,
 fpga_ram_nnz_data_out,
 fpga_ram_nnz_cb_wr_n,
 fpga_ram_nnz_cb_addr,
 fpga_ram_nnz_cb_data_in,
 fpga_ram_nnz_cb_data_out,
 fpga_ram_nnz_cr_wr_n,
 fpga_ram_nnz_cr_addr,     
 fpga_ram_nnz_cr_data_in,
 fpga_ram_nnz_cr_data_out
 );
 
input clk;
input rst_n;
input ena; 
input[23:0] rbsp_in; // from rbsp_buffer output 
input[2:0] slice_type_mod5_in;
input[`mb_x_bits - 1:0] pic_width_in_mbs_minus1_sps_in;
input[`mb_y_bits - 1:0] pic_height_in_map_units_minus1_sps_in;
input[2:0] num_ref_idx_l0_active_minus1_in;
input[3:0] CBP_luma_in;
input[1:0] CBP_chroma_in;
input[5:0] pic_init_qp_minus26_pps_in;
wire signed[5:0] pic_init_qp_minus26_pps_in;
input[5:0] slice_qp_delta_slice_header_in;
wire signed[5:0] slice_qp_delta_slice_header_in;

input[11:0] exp_golomb_decoding_output_in;
input[4:0] exp_golomb_decoding_len_in;
input[15:0] exp_golomb_decoding_output_se_in;
wire signed[15:0] exp_golomb_decoding_output_se_in;
input[7:0] exp_golomb_decoding_output_te_in;
output exp_golomb_decoding_me_intra4x4_out; //1=intra4x4, 0=inter
reg exp_golomb_decoding_me_intra4x4_out;
output exp_golomb_decoding_te_sel_out;
reg exp_golomb_decoding_te_sel_out;

input[3:0] I4_pred_mode_in;

input[15:0] mvpx_l0_in;
input[15:0] mvpy_l0_in;

input [4:0] chroma_qp_index_offset_pps_in;
wire signed[4:0] chroma_qp_index_offset_pps_in;
 
 
output fpga_ram_intra4x4_pred_mode_wr_n;
output [`mb_x_bits-1:0] fpga_ram_intra4x4_pred_mode_addr;     
output [15:0]  fpga_ram_intra4x4_pred_mode_data_in;
input [15:0]  fpga_ram_intra4x4_pred_mode_data_out;

output fpga_ram_mvx_wr_n;
output [`mb_x_bits-1:0] fpga_ram_mvx_addr;     
output [63:0]  fpga_ram_mvx_data_in;
input [63:0]  fpga_ram_mvx_data_out;  
 
output fpga_ram_mvy_wr_n;
output [`mb_x_bits-1:0] fpga_ram_mvy_addr;     
output [63:0]  fpga_ram_mvy_data_in;
input  [63:0]  fpga_ram_mvy_data_out;  
 
output fpga_ram_ref_idx_wr_n;
output [`mb_x_bits-1:0] fpga_ram_ref_idx_addr;
output [7:0] fpga_ram_ref_idx_data_in;
input  [7:0] fpga_ram_ref_idx_data_out;

output fpga_ram_qp_wr_n;
output [`mb_x_bits-1:0] fpga_ram_qp_addr;
output [7:0] fpga_ram_qp_data_in;
input  [7:0] fpga_ram_qp_data_out;

output fpga_ram_qp_c_wr_n;
output [`mb_x_bits-1:0] fpga_ram_qp_c_addr;
output [7:0] fpga_ram_qp_c_data_in;
input  [7:0] fpga_ram_qp_c_data_out; 

output fpga_ram_nnz_wr_n;
output [`mb_x_bits-1:0] fpga_ram_nnz_addr;     
output [31:0] fpga_ram_nnz_data_in;
input  [31:0] fpga_ram_nnz_data_out;

output fpga_ram_nnz_cb_wr_n;
output [`mb_x_bits-1:0] fpga_ram_nnz_cb_addr;     
output [15:0] fpga_ram_nnz_cb_data_in;
input  [15:0] fpga_ram_nnz_cb_data_out;

output fpga_ram_nnz_cr_wr_n;
output [`mb_x_bits-1:0] fpga_ram_nnz_cr_addr;     
output [15:0] fpga_ram_nnz_cr_data_in;
input  [15:0] fpga_ram_nnz_cr_data_out;

input  [4:0] nC_in;
input  [4:0] nC_cb_in;
input  [4:0] nC_cr_in;

output[7:0] qp;
output[7:0] qp_c;
output[3:0] slice_data_state;
output[3:0] residual_state;
output[`mb_x_bits + `mb_y_bits - 1:0] mb_index_out;
output[4:0] forward_len_out;

output[`mb_x_bits - 1:0]  mb_x_out; 
output[`mb_y_bits - 1:0]  mb_y_out;
output[`mb_x_bits + 3:0] pixel_x_out;
output[`mb_y_bits + 3:0] pixel_y_out;
output[3:0] luma4x4BlkIdx_out;
output[1:0] chroma4x4BlkIdx_out;
output[1:0] luma4x4BlkIdx_x_out;
output[1:0] luma4x4BlkIdx_y_out;
output[4:0] blk4x4_counter; 
output[127:0] nC_curr_mb_out; //output to nC_decoding
output[31:0] nC_left_mb_out;
output[31:0] nC_up_mb_out;
output[31:0] nC_cb_curr_mb_out;
output[15:0] nC_cb_left_mb_out;
output[15:0] nC_cb_up_mb_out;
output[31:0] nC_cr_curr_mb_out;
output[15:0] nC_cr_left_mb_out;
output[15:0] nC_cr_up_mb_out;

output[15:0] intra4x4_pred_mode_up_mb_out;
output[15:0] intra4x4_pred_mode_left_mb_out;
output[63:0] intra4x4_pred_mode_curr_mb_out;
output prev_intra4x4_pred_mode_flag_out;
output[2:0] rem_intra4x4_pred_mode_out;

output[5 :0] ref_idx_l0_left_mb_out;
output[11:0] ref_idx_l0_curr_mb_out;
output[5 :0] ref_idx_l0_up_left_mb_out;
output[5 :0] ref_idx_l0_up_mb_out;
output[5 :0] ref_idx_l0_up_right_mb_out;

output[63 :0] mvx_l0_left_mb_out;
output[63 :0] mvy_l0_left_mb_out;
output[15 :0] mvx_l0_up_left_mb_out;
output[15 :0] mvy_l0_up_left_mb_out;
output[63 :0] mvx_l0_up_mb_out;  // input from m9k, actually no, the input is fpga_ram_mvx_l0_in, output to get_mvp
output[63 :0] mvy_l0_up_mb_out;
output[63 :0] mvx_l0_up_right_mb_out;
output[63 :0] mvy_l0_up_right_mb_out;
output[255:0] mvx_l0_curr_mb_out; // 8x16=128
output[255:0] mvy_l0_curr_mb_out;

output[4:0] MbPartWidth;
output[4:0] MbPartHeight;
output[2:0] ref_idx_l0_out;

output  signed  [5:0]   nC; // input from nC_decoding, output to cavlc,  
                                // fix nC_decoding and cavlc only allowed to put inside slice_data?
                                // otherwise the signal nC will be inout, or nC use reg to store the output 
                                // of nC_decoding, then output to cavlc    
                                // put all code of nC_decoding inside slice_data
                                // or declare nC_in, nC_out, assgin nC_out = Nc_in
output  start_of_MB;
output  end_of_MB;

//residual
output residual_start;
input  residual_valid;
output [4:0]   max_coeff_num;
input  [4:0]   TotalCoeff; 
input  [4:0]   len_comb;
input  cavlc_idle;

//intra_pred
output  intra_pred_start;
input   intra_pred_valid;
output[3:0] mb_pred_mode_out;
output[1:0] I16_pred_mode_out;
output[3:0] I4_pred_mode_out;
output[1:0] intra_pred_mode_chroma;

//inter_pred
output[`mb_x_bits + 5:0] ref_x;
output[`mb_y_bits + 5:0] ref_y;
output[2:0] ref_idx;
output inter_pred_start;
input  inter_pred_valid;

//sum
output  sum_start;
input   sum_valid;
output  mb_pred_inter_sel;

//inter_pred
reg[`mb_x_bits + 5:0] ref_x;
reg[`mb_y_bits + 5:0] ref_y;
reg[2:0] ref_idx;
reg inter_pred_start;

reg     signed [5:0] nC;
reg     residual_start;
reg     intra_pred_start;
reg     sum_start;
reg     [4:0]   max_coeff_num;
reg     mb_pred_inter_sel;
reg     residual_started;
reg     [2:0]   step;

wire    [4:0]   TotalCoeff; 
wire    [4:0]   len_comb;
wire    cavlc_idle;

reg[4:0] forward_len_out;

reg[3:0] CBP_luma_reg;
reg[1:0] CBP_chroma_reg;

reg signed[7:0] qp;
reg signed[7:0] qp_c;
reg signed[7:0] qp_i;

reg[3:0] slice_data_state;
reg[3:0] mb_pred_state;
reg[2:0] sub_mb_pred_state;
reg[3:0] residual_state;
reg[1:0] p_skip_state;

reg signed[7:0] qp_up;
reg signed[7:0] qp_c_up;
reg signed[7:0] qp_left_mb;
reg signed[7:0] qp_c_left_mb;

reg[127:0] nC_curr_mb_out; //nC_curr_mb is not neccessary to be declared as signed, only nC_curr_mb[7:0] is handled as signed
reg[31:0] nC_left_mb_out;
reg[31:0] nC_up_mb_out;
reg[31:0] nC_cb_curr_mb_out;
reg[15:0] nC_cb_left_mb_out;
reg[15:0] nC_cb_up_mb_out;
reg[31:0] nC_cr_curr_mb_out;
reg[15:0] nC_cr_left_mb_out;
reg[15:0] nC_cr_up_mb_out;

reg[4:0]  mb_type;
reg[3:0]  mb_pred_mode_comb;
reg[3:0]  mb_pred_mode_out;
wire[1:0] I16_pred_mode;
wire[3:0] I4_pred_mode_in;

reg[15:0]  sub_mb_type;
reg[`mb_x_bits + `mb_y_bits - 1:0]  mb_index_out;
reg[`mb_x_bits - 1:0]   mb_x_out;
reg[`mb_y_bits - 1:0]   mb_y_out;
reg[`mb_x_bits + 3:0]  pixel_x_out;
reg[`mb_y_bits + 3:0]  pixel_y_out;

reg[1:0] chroma4x4BlkIdx_out;

reg [3:0] luma4x4BlkIdx_out;
reg[1:0] luma4x4BlkIdx_x_out;
reg[1:0] luma4x4BlkIdx_y_out;

reg prev_intra4x4_pred_mode_flag_out;
reg[2:0] rem_intra4x4_pred_mode_out;
reg[1:0] intra_pred_mode_chroma;
reg[2:0] ref_idx_l0_out;
reg signed[15:0] mvdx_l0;
reg signed[15:0] mvdy_l0;

reg[15:0] intra4x4_pred_mode_up_mb_out;
reg[15:0] intra4x4_pred_mode_left_mb_out;
reg[63:0] intra4x4_pred_mode_curr_mb_out;

reg[5 :0] ref_idx_l0_left_mb_out;
reg[11:0] ref_idx_l0_curr_mb_out;
reg[5 :0] ref_idx_l0_up_left_mb_out;
reg[5 :0] ref_idx_l0_up_mb_out;
reg[5 :0] ref_idx_l0_up_right_mb_out;

reg[2:0] ref_idx_l0_curr_blk4x4;

reg[63 :0] mvx_l0_left_mb_out;
reg[63 :0] mvy_l0_left_mb_out;
reg[15 :0] mvx_l0_up_left_mb_out;
reg[15 :0] mvy_l0_up_left_mb_out;
reg[63 :0] mvx_l0_up_mb_out;
reg[63 :0] mvy_l0_up_mb_out;
reg[63  :0] mvx_l0_up_right_mb_out;
reg[63  :0] mvy_l0_up_right_mb_out;
reg[255:0] mvx_l0_curr_mb_out; // 8x16=128
reg[255:0] mvy_l0_curr_mb_out;

reg signed[15 :0] mvx_l0;
reg signed[15 :0] mvy_l0;
wire signed[15 :0] mvpx_l0_in;
wire signed[15 :0] mvpy_l0_in;

reg signed [15:0] mvx_l0_curr_4x4blk;
reg signed [15:0] mvy_l0_curr_4x4blk;
reg signed [`mb_x_bits + 6:0] ref_x_comb;
reg signed [`mb_y_bits + 6:0] ref_y_comb;

reg[21:0] intra_mode;

reg[`mb_x_bits+`mb_y_bits-1:0] mb_skip_run;
reg      P_skip_mode;

reg[1:0] prefetch_counter;

reg[1:0] mbPartIdx; // 8x8,16x8,8x16 index in 16x16 block
reg[1:0] MbPartNum; // 4x4,8x4,4x8 index in 8x8 block
reg[1:0] subMbPartIdx; // sub mb index 4x4,8x4,4x8, used in inter pred
reg[2:0] SubMbPartNum;
reg[4:0] MbPartWidth;
reg[4:0] MbPartHeight;

reg fpga_ram_intra4x4_pred_mode_wr_n;
reg [`mb_x_bits-1:0] fpga_ram_intra4x4_pred_mode_addr;     
reg [15:0]  fpga_ram_intra4x4_pred_mode_data_in; 
wire[15:0]  fpga_ram_intra4x4_pred_mode_data_out; // output from fpga_ram

reg fpga_ram_mvx_wr_n;
reg [`mb_x_bits-1:0] fpga_ram_mvx_addr;     
reg [63:0]  fpga_ram_mvx_data_in;
wire[63:0]  fpga_ram_mvx_data_out;
     
reg fpga_ram_mvy_wr_n;
reg [`mb_x_bits-1:0] fpga_ram_mvy_addr;     
reg [63:0]  fpga_ram_mvy_data_in;
wire[63:0]  fpga_ram_mvy_data_out;  

reg fpga_ram_ref_idx_wr_n;
reg [`mb_x_bits-1:0] fpga_ram_ref_idx_addr;     
reg [7:0] fpga_ram_ref_idx_data_in;
wire[7:0] fpga_ram_ref_idx_data_out;  

reg fpga_ram_qp_wr_n;
reg [`mb_x_bits-1:0] fpga_ram_qp_addr;
reg [7:0] fpga_ram_qp_data_in;
wire[7:0] fpga_ram_qp_data_out; 

reg fpga_ram_qp_c_wr_n;
reg [`mb_x_bits-1:0] fpga_ram_qp_c_addr;
reg [7:0] fpga_ram_qp_c_data_in;
wire[7:0] fpga_ram_qp_c_data_out;

reg fpga_ram_nnz_wr_n;
reg [`mb_x_bits-1:0] fpga_ram_nnz_addr;     
reg [31:0] fpga_ram_nnz_data_in;
wire[31:0] fpga_ram_nnz_data_out;

reg fpga_ram_nnz_cb_wr_n;
reg [`mb_x_bits-1:0] fpga_ram_nnz_cb_addr;     
reg [15:0] fpga_ram_nnz_cb_data_in;
wire[15:0] fpga_ram_nnz_cb_data_out;

reg fpga_ram_nnz_cr_wr_n;
reg [`mb_x_bits-1:0] fpga_ram_nnz_cr_addr;     
reg [15:0] fpga_ram_nnz_cr_data_in;
wire[15:0] fpga_ram_nnz_cr_data_out;

always @(slice_data_state or mb_pred_state or sub_mb_pred_state or ena
            or len_comb or cavlc_idle 
            or exp_golomb_decoding_len_in)
        case (slice_data_state)
            `rst_slice_data      : forward_len_out <= 0;
            `mb_skip_run_s       : forward_len_out <= exp_golomb_decoding_len_in;
            `mb_type_s           : forward_len_out <= exp_golomb_decoding_len_in;
            `mb_pred:
                case(mb_pred_state)
                    `rst_mb_pred                    : forward_len_out <= 0;
                    `prev_intra4x4_pred_mode_flag_s : forward_len_out <= 1;
                    `ref_idx_l0_s                   : forward_len_out <= exp_golomb_decoding_len_in;
                    `rem_intra4x4_pred_mode_s       : forward_len_out <= 3;
                    `intra_pred_mode_chroma_s       : forward_len_out <= exp_golomb_decoding_len_in;
                    `mvdx_l0_s                      : forward_len_out <= exp_golomb_decoding_len_in;
                    `mvdy_l0_s                      : forward_len_out <= exp_golomb_decoding_len_in;
                    default : forward_len_out <= 0;
                endcase
            `coded_block_pattern_s: forward_len_out <= exp_golomb_decoding_len_in;
            `mb_qp_delta_s        : forward_len_out <= exp_golomb_decoding_len_in;
            `sub_mb_pred:
                case(sub_mb_pred_state)
                    `rst_sub_mb_pred  : forward_len_out <= 0;
                    `sub_mb_type_s    : forward_len_out <= exp_golomb_decoding_len_in;
                    `sub_ref_idx_l0_s : forward_len_out <= exp_golomb_decoding_len_in;
                    `sub_mvdx_l0_s    : forward_len_out <= exp_golomb_decoding_len_in;
                    `sub_mvdy_l0_s    : forward_len_out <= exp_golomb_decoding_len_in;
                    default : forward_len_out <= 0;
                endcase
            `residual:
                if (!cavlc_idle)
                    forward_len_out <= len_comb;
                else
                    forward_len_out <= 0;
            `mb_num_update, `store_to_fpga_ram, `prefetch_from_fpga_ram : forward_len_out <= 0;
            `rbsp_trailing_bits_slice_data: forward_len_out <= 5'b11111;
            default : forward_len_out <= 0;
        endcase
                                        
always @(luma4x4BlkIdx_out)
     case(luma4x4BlkIdx_out)
         0,1,4,5:     luma4x4BlkIdx_y_out <= 0;
         2,3,6,7:     luma4x4BlkIdx_y_out <= 1;
         8,9,12,13:   luma4x4BlkIdx_y_out <= 2;
         10,11,14,15: luma4x4BlkIdx_y_out <= 3;
         default:     luma4x4BlkIdx_y_out <= 3;
     endcase

always @(luma4x4BlkIdx_out)
     case(luma4x4BlkIdx_out)
         0,2,8,10:     luma4x4BlkIdx_x_out <= 0;
         1,3,9,11:     luma4x4BlkIdx_x_out <= 1;
         4,6,12,14:    luma4x4BlkIdx_x_out <= 2;
         5,7,13,15:    luma4x4BlkIdx_x_out <= 3;
         default:      luma4x4BlkIdx_x_out <= 3;
     endcase


always @(luma4x4BlkIdx_x_out or luma4x4BlkIdx_y_out or mb_x_out or mb_y_out )
    begin
        pixel_x_out <= (mb_x_out << 4) + (luma4x4BlkIdx_x_out << 2);
        pixel_y_out <= (mb_y_out << 4) + (luma4x4BlkIdx_y_out << 2);
    end


always @(slice_type_mod5_in or mb_type or mb_skip_run)
    begin
        if ( slice_type_mod5_in == `slice_type_I )
            begin
                if (mb_type == 0)
                    mb_pred_mode_comb <= `mb_pred_mode_I4MB;
                else if (mb_type == 25 )
                    mb_pred_mode_comb <= `mb_pred_mode_IPCM;
                else
                    mb_pred_mode_comb <= `mb_pred_mode_I16MB;
            end
        else if ( slice_type_mod5_in == `slice_type_P && mb_skip_run > 0 )
            begin
                mb_pred_mode_comb <= `mb_pred_mode_P_SKIP;
            end
        else if (slice_type_mod5_in == `slice_type_P)
            begin
                case ( mb_type )
                0,1,2,3:    mb_pred_mode_comb <= `mb_pred_mode_PRED_L0;
                4:          mb_pred_mode_comb <= `mb_pred_mode_P_REF0;
                5:          mb_pred_mode_comb <= `mb_pred_mode_I4MB;
                default:    mb_pred_mode_comb <= `mb_pred_mode_I16MB;
                endcase
            end
        else
            begin
                mb_pred_mode_comb <= 4'b1111;
            end
    end      

always @(*)
	mb_pred_mode_out <= mb_pred_mode_comb;

always @(mb_pred_mode_comb)           
if (mb_pred_mode_comb == `mb_pred_mode_PRED_L0 ||
    mb_pred_mode_comb == `mb_pred_mode_P_REF0 ||
    mb_pred_mode_comb == `mb_pred_mode_P_SKIP)
    mb_pred_inter_sel <= 1;
else
	mb_pred_inter_sel <= 0;
        
     
assign I16_pred_mode_out = (slice_type_mod5_in == `slice_type_P && 
							mb_pred_mode_comb <= `mb_pred_mode_I16MB) ? (mb_type-6)%4 : (mb_type-1)%4; // mb_type[4:3]?

reg [3:0] I4_pred_mode_out;
always @(intra4x4_pred_mode_curr_mb_out or luma4x4BlkIdx_out)
    case(luma4x4BlkIdx_out)
        0 : I4_pred_mode_out <= intra4x4_pred_mode_curr_mb_out[3 : 0]; 
        1 : I4_pred_mode_out <= intra4x4_pred_mode_curr_mb_out[7 : 4]; 
        2 : I4_pred_mode_out <= intra4x4_pred_mode_curr_mb_out[11: 8]; 
        3 : I4_pred_mode_out <= intra4x4_pred_mode_curr_mb_out[15:12]; 
        4 : I4_pred_mode_out <= intra4x4_pred_mode_curr_mb_out[19:16]; 
        5 : I4_pred_mode_out <= intra4x4_pred_mode_curr_mb_out[23:20]; 
        6 : I4_pred_mode_out <= intra4x4_pred_mode_curr_mb_out[27:24]; 
        7 : I4_pred_mode_out <= intra4x4_pred_mode_curr_mb_out[31:28]; 
        8 : I4_pred_mode_out <= intra4x4_pred_mode_curr_mb_out[35:32]; 
        9 : I4_pred_mode_out <= intra4x4_pred_mode_curr_mb_out[39:36]; 
        10: I4_pred_mode_out <= intra4x4_pred_mode_curr_mb_out[43:40]; 
        11: I4_pred_mode_out <= intra4x4_pred_mode_curr_mb_out[47:44]; 
        12: I4_pred_mode_out <= intra4x4_pred_mode_curr_mb_out[51:48]; 
        13: I4_pred_mode_out <= intra4x4_pred_mode_curr_mb_out[55:52]; 
        14: I4_pred_mode_out <= intra4x4_pred_mode_curr_mb_out[59:56]; 
        15: I4_pred_mode_out <= intra4x4_pred_mode_curr_mb_out[63:60]; 
    endcase
    
always @ (qp or chroma_qp_index_offset_pps_in)
    begin
        if (qp + chroma_qp_index_offset_pps_in < 0)
            qp_i <= 0;
        else if (qp + chroma_qp_index_offset_pps_in > 51)
            qp_i <= 51;
        else
            qp_i <= qp + chroma_qp_index_offset_pps_in;
    end

always @ (qp_i)
    begin
        if(qp_i < 30)
            qp_c <= qp_i;
        else 
            case(qp_i)
                30      :qp_c <= 29;
                31      :qp_c <= 30;
                32      :qp_c <= 31;
                33,34   :qp_c <= 32;
                35      :qp_c <= 33;
                36,37   :qp_c <= 34;
                38,39   :qp_c <= 35;
                40,41   :qp_c <= 36;
                42,43,44:qp_c <= 37;
                45,46,47:qp_c <= 38;
                default :qp_c <= 39;
            endcase
    end

    
reg start_of_MB;
reg end_of_MB;
reg sum_valid_s;
reg [4:0] blk4x4_counter;

always @(posedge clk or negedge rst_n)
if (!rst_n)
    start_of_MB <= 0;
else if (slice_data_state == `rst_slice_data && ena)
    start_of_MB <= 1;
else if (ena)
    start_of_MB <= 0;   

always @(posedge clk or negedge rst_n)
if (!rst_n)
    end_of_MB <= 0;
else if (slice_data_state == `mb_num_update && ena)
    end_of_MB <= 1;
else if (ena)
    end_of_MB <= 0; 


always @(posedge clk or negedge rst_n)
if (!rst_n)
	sum_valid_s <= 0;
else if (ena)
	sum_valid_s <= sum_valid;
		
//blk4x4_counter
always @(posedge clk or negedge rst_n)
if (!rst_n)
    blk4x4_counter <= 0;
else if (ena) begin
    if(start_of_MB)
        blk4x4_counter <= 0;
    else if (!sum_valid_s && sum_valid)
        blk4x4_counter <= blk4x4_counter + 1;
end

always @(posedge clk or negedge rst_n)
    if (!rst_n)
        residual_started <= 0;
    else if (ena)
        begin
            if (residual_start)
                residual_started <= 1;
            else if (residual_valid)
                residual_started <= 0;
        end

always @ (posedge clk or negedge rst_n)
    if (rst_n == 0)
        begin
            prev_intra4x4_pred_mode_flag_out    <= 0;
            rem_intra4x4_pred_mode_out          <= 0;
            intra_pred_mode_chroma              <= 0;
            slice_data_state                    <= 0;
            mb_pred_state                       <= 0;
            sub_mb_pred_state                   <= 0;
            residual_state                      <= 0;
            mb_index_out                        <= 0;
            mbPartIdx                           <= 0;
            mb_x_out                            <= 0;
            mb_y_out                            <= 0;
            luma4x4BlkIdx_out                   <= 0;
            chroma4x4BlkIdx_out                 <= 0;
            step                                <= 0;
            residual_start                      <= 0;
            intra_pred_start                    <= 0;
            inter_pred_start                    <= 0;
            sum_start                           <= 0;
            ref_x                                <= 0;
            ref_y                                <= 0;
            ref_idx                             <= 0;
            max_coeff_num                       <= 0;
            mb_skip_run                         <= 0;   
            P_skip_mode                         <= 0;
            exp_golomb_decoding_me_intra4x4_out <= 0;
            exp_golomb_decoding_te_sel_out      <= 0;
            intra_mode                          <= 0;
            intra4x4_pred_mode_curr_mb_out      <= 0;
            end
    else 
        begin
            if (ena)
                case (slice_data_state)
                    `rst_slice_data: // more appropriately rst_macroblock
                        begin
	                        intra4x4_pred_mode_curr_mb_out   <=  64'h2222222222222222;
	                        if (mb_index_out == 0)
                            	qp <= pic_init_qp_minus26_pps_in + 26 + slice_qp_delta_slice_header_in;
                            if (mb_x_out != 0)
                                begin
                                    ref_idx_l0_left_mb_out <= {ref_idx_l0_curr_mb_out[11:9], ref_idx_l0_curr_mb_out[5:3]};
                                    mvx_l0_left_mb_out <= {mvx_l0_curr_mb_out[255:240],
                                                           mvx_l0_curr_mb_out[223:208],
                                                           mvx_l0_curr_mb_out[127:112], 
                                                           mvx_l0_curr_mb_out[95:80]
                                                           };
                                    mvy_l0_left_mb_out <= {mvy_l0_curr_mb_out[255:240],
                                                           mvy_l0_curr_mb_out[223:208],
                                                           mvy_l0_curr_mb_out[127:112], 
                                                           mvy_l0_curr_mb_out[95:80]
                                                            };
                                    intra4x4_pred_mode_left_mb_out <= {intra4x4_pred_mode_curr_mb_out[63:60],
                                                                       intra4x4_pred_mode_curr_mb_out[55:52],
                                                                       intra4x4_pred_mode_curr_mb_out[31:28],
                                                                       intra4x4_pred_mode_curr_mb_out[23:20] // 5,7,13,15
                                                                       };
                                    qp_left_mb <= qp;
                                    qp_c_left_mb <= qp_c;
                                    nC_left_mb_out <= {nC_curr_mb_out[127:120], nC_curr_mb_out[111:104],
                                                           nC_curr_mb_out[63:56],nC_curr_mb_out[47:40] };
                                    nC_cb_left_mb_out <= {nC_cb_curr_mb_out[31:24], nC_cb_curr_mb_out[15:8]};
                                    nC_cr_left_mb_out <= {nC_cr_curr_mb_out[31:24], nC_cr_curr_mb_out[15:8]};
                                end
                                
                            if (mb_y_out != 0)
                                begin
                                    slice_data_state <= `prefetch_from_fpga_ram;
                                    prefetch_counter <= 0;
                                    
                                    fpga_ram_intra4x4_pred_mode_wr_n <= 1;  
                                    fpga_ram_intra4x4_pred_mode_addr <= mb_x_out;
                                    fpga_ram_qp_wr_n      <= 1;
                                    fpga_ram_qp_c_wr_n    <= 1;
                                    fpga_ram_nnz_wr_n     <= 1;
                                    fpga_ram_nnz_cb_wr_n   <= 1;
                                    fpga_ram_nnz_cr_wr_n   <= 1;
                                    fpga_ram_qp_addr      <= mb_x_out; 
                                    fpga_ram_qp_c_addr    <= mb_x_out; 
                                    fpga_ram_nnz_addr     <= mb_x_out;
                                    fpga_ram_nnz_cb_addr   <= mb_x_out;
                                    fpga_ram_nnz_cr_addr   <= mb_x_out;
                                    
                                    fpga_ram_ref_idx_wr_n <= 1;
                                    fpga_ram_mvx_wr_n     <= 1;
                                    fpga_ram_mvy_wr_n     <= 1;
                                    // mb is in first column, retrieve ref_idx_l0_up_mb and ref_idx_l0_up_right_mb, otherwise retrieve ref_idx_l0_up_right_mb       
                                    if ( mb_x_out == 0 )
                                        begin
                                            fpga_ram_ref_idx_addr <= mb_x_out;
                                            fpga_ram_mvx_addr <= mb_x_out; 
                                            fpga_ram_mvy_addr <= mb_x_out;
                                        end
                                    else
                                        begin
                                            fpga_ram_ref_idx_addr <= mb_x_out + 1;
                                            fpga_ram_mvx_addr <= mb_x_out + 1; 
                                            fpga_ram_mvy_addr <= mb_x_out + 1;
                                        end
                                end
                            else if ( mb_skip_run != 0 ) 
                                slice_data_state <= `skip_run_duration;
                                 
                            else if(slice_type_mod5_in != `slice_type_I &&
                                    slice_type_mod5_in != `slice_type_SI && 
                                    !P_skip_mode)
                                begin                                                
                                    slice_data_state <= `mb_skip_run_s;
                                end    
                            else
                                begin                                                
                                    slice_data_state <= `mb_type_s;
                                end 
                        end

                    `prefetch_from_fpga_ram: 
                        if ( prefetch_counter == 0)
                        // fix: since it's not async read, it takes 2 clocks to read one data from fpga ram
                            begin
                                prefetch_counter <= 1;
                            end
                        else if (prefetch_counter == 1)
                            begin
                                intra4x4_pred_mode_up_mb_out <= fpga_ram_intra4x4_pred_mode_data_out;
                                qp_up <= fpga_ram_qp_data_out;
                                qp_c_up <= fpga_ram_qp_c_data_out;
                                nC_up_mb_out <= fpga_ram_nnz_data_out;
                                nC_cb_up_mb_out <= fpga_ram_nnz_cb_data_out;
                                nC_cr_up_mb_out <= fpga_ram_nnz_cr_data_out;

                                if (mb_x_out == 0)
                                    begin
                                        ref_idx_l0_up_mb_out[5:0] <= fpga_ram_ref_idx_data_out[5:0];
                                        mvx_l0_up_mb_out <= fpga_ram_mvx_data_out;
                                        mvy_l0_up_mb_out <= fpga_ram_mvy_data_out;
                                        prefetch_counter <= 2;
                                        fpga_ram_ref_idx_wr_n <= 1;
                                        fpga_ram_mvx_wr_n <= 1;
                                        fpga_ram_mvy_wr_n <= 1;
                                        fpga_ram_ref_idx_addr <= mb_x_out + 1 ;
                                        fpga_ram_mvx_addr <= mb_x_out + 1;
                                        fpga_ram_mvy_addr <= mb_x_out + 1;
                                    end
                                else
                                    begin

                                        mvx_l0_up_right_mb_out <= fpga_ram_mvx_data_out;
                                        mvy_l0_up_right_mb_out <= fpga_ram_mvy_data_out;

                                        ref_idx_l0_up_left_mb_out <= ref_idx_l0_up_mb_out;
                                        
                                        ref_idx_l0_up_mb_out <= ref_idx_l0_up_right_mb_out;
                                        ref_idx_l0_up_right_mb_out[5:0] <= fpga_ram_ref_idx_data_out[5:0];
                                                                                
                                        mvx_l0_up_left_mb_out <= mvx_l0_up_mb_out[63:48];
                                        mvx_l0_up_mb_out <= mvx_l0_up_right_mb_out;
                                        
                                        mvy_l0_up_left_mb_out <= mvy_l0_up_mb_out[63:48];
                                        mvy_l0_up_mb_out <= mvy_l0_up_right_mb_out;
                                        if ( mb_skip_run != 0 )
                                            slice_data_state <= `skip_run_duration; 
                                        else if(slice_type_mod5_in != `slice_type_I &&
                                         slice_type_mod5_in != `slice_type_SI && !P_skip_mode)
                                            begin                                                
                                                slice_data_state <= `mb_skip_run_s;
                                            end    
                                        else
                                            begin                                                
                                                slice_data_state <= `mb_type_s;
                                            end
                                    end
                            end
                        else if (prefetch_counter == 2)
                            begin
                                prefetch_counter <= 3;
                            end
                        else //prefetch_counter = 3
                            begin
                                ref_idx_l0_up_right_mb_out[5:0] <= fpga_ram_ref_idx_data_out[5:0];
                                mvx_l0_up_right_mb_out <= fpga_ram_mvx_data_out;
                                mvy_l0_up_right_mb_out <= fpga_ram_mvy_data_out;
                                
                                // not necessary?
                                intra4x4_pred_mode_left_mb_out <= 0;
                                ref_idx_l0_left_mb_out <= 0;
                                ref_idx_l0_up_left_mb_out <= 0;
                                
                                mvx_l0_left_mb_out <= 0;
                                mvx_l0_up_left_mb_out <= 0;
                                
                                mvy_l0_left_mb_out <= 0;
                                mvy_l0_up_left_mb_out <= 0;   
                                
                                if ( mb_skip_run != 0 )
                                    slice_data_state <= `skip_run_duration; 
                                else if(slice_type_mod5_in != `slice_type_I &&
                                 slice_type_mod5_in != `slice_type_SI && !P_skip_mode)
                                    begin                                                
                                        slice_data_state <= `mb_skip_run_s;
                                    end    
                                else
                                    begin                                                
                                        slice_data_state <= `mb_type_s;
                                    end                            
                            end
                            
                    `mb_skip_run_s:
                        begin
                            if (exp_golomb_decoding_output_in > 0)
                                begin
                                    slice_data_state <= `skip_run_duration;
                                    MbPartWidth <= 16;
                                    MbPartHeight <= 16;
                                    luma4x4BlkIdx_out <= 0;
                                    mb_skip_run <= exp_golomb_decoding_output_in;
                                    ref_idx_l0_curr_mb_out <= 0;
                                    ref_idx_l0_out <= 0;                                    
                                end
                            else
                                begin
                                    slice_data_state <= `mb_type_s;
                                end
                        end
                    `skip_run_duration:
                        begin
                            P_skip_mode <= 1;
                            // P_skip 's mv, 
                            if ( pixel_x_out == 0 || pixel_y_out == 0 )
                                begin
                                    mvx_l0 <= 0;
                                    mvy_l0 <= 0;
                                end
                            else if (ref_idx_l0_left_mb_out[2:0] == 0 &&
                                     mvx_l0_left_mb_out[15:0] == 0 &&
                                     mvy_l0_left_mb_out[15:0] == 0)
                                begin
                                    mvx_l0 <= 0;
                                    mvy_l0 <= 0;
                                end
                            else if (ref_idx_l0_up_mb_out[2:0] == 0 &&
                                     mvx_l0_up_mb_out[15:0] == 0 &&
                                     mvy_l0_up_mb_out[15:0] == 0)
                                begin
                                    mvx_l0 <= 0;
                                    mvy_l0 <= 0;
                                end
                            else
                                begin
                                    mvx_l0 <= mvpx_l0_in;
                                    mvy_l0 <= mvpy_l0_in;
                                end
                            slice_data_state <= `p_skip_s;
                            p_skip_state <= `rst_p_skip_s;
                        end 
                    `mb_type_s:
                        begin
                            mb_type <= exp_golomb_decoding_output_in;
                            slice_data_state <= `mb_pred;
                            mb_pred_state <= `rst_mb_pred;
                        end
                    `mb_pred:
                        case(mb_pred_state)
                            `rst_mb_pred:begin
                                if(mb_pred_mode_comb == `mb_pred_mode_I4MB)
                                    begin
                                        mb_pred_state <= `prev_intra4x4_pred_mode_flag_s;
                                        luma4x4BlkIdx_out <= 0;
                                        ref_idx_l0_curr_mb_out <= -1;
                                    end
                                else if(mb_pred_mode_comb == `mb_pred_mode_I16MB &&
                                         slice_type_mod5_in != `slice_type_I &&
                                         slice_type_mod5_in != `slice_type_SI)
                                    begin
                                        CBP_luma_reg <= (mb_type >= 18 ? 15 : 0);
                                        //CBP_chroma_reg <= ((mb_type - 1) % 12) >> 2; divisor must be a positive constant power of 2
                                        if (mb_type >= 18)
                                            CBP_chroma_reg <= (mb_type - 18) >> 2;
                                        else
                                            CBP_chroma_reg <= (mb_type - 6) >> 2;
                                        mb_pred_state <= `intra_pred_mode_chroma_s;
                                        luma4x4BlkIdx_out <= 0; 
                                        ref_idx_l0_curr_mb_out <= -1;                                       
                                    end
                                else if (mb_pred_mode_comb == `mb_pred_mode_I16MB)
                                    begin
                                        CBP_luma_reg <= (mb_type >= 13 ? 15 : 0);
                                        //CBP_chroma_reg <= ((mb_type - 1) % 12) >> 2; divisor must be a positive constant power of 2
                                        if (mb_type >= 13)
                                            CBP_chroma_reg <= (mb_type - 13) >> 2;
                                        else
                                            CBP_chroma_reg <= (mb_type - 1) >> 2;
                                        mb_pred_state <= `intra_pred_mode_chroma_s;
                                        luma4x4BlkIdx_out <= 0;
                                        ref_idx_l0_curr_mb_out <= -1;                                    
                                    end
                                else if (mb_pred_mode_comb == `mb_pred_mode_PRED_L0 || 
                                         mb_pred_mode_comb == `mb_pred_mode_P_REF0)
                                    begin
                                        luma4x4BlkIdx_out <= 0; 
                                        mbPartIdx <= 0;
                                        subMbPartIdx <= 0;
                                        if ( mb_type == 3 || mb_type == 4 ) // P_8x8, P_8x8ref0
                                            begin
                                                MbPartNum <= 4;
                                            end
                                        else if (mb_type == 1) // 16x8
                                            begin
                                                MbPartNum <= 2;
                                                MbPartWidth <= 16;
                                                MbPartHeight <= 8;
                                            end
                                        else if( mb_type == 2 ) // 8x16
                                            begin
                                                MbPartNum <= 2;
                                                MbPartWidth <= 8;
                                                MbPartHeight <= 16;
                                            end
                                        else
                                            begin
                                                MbPartNum <= 1;
                                                MbPartWidth <= 16;
                                                MbPartHeight <= 16;
                                            end
                                            
                                        if ( mb_type == 3 || mb_type == 4 ) // P_8x8, P_8x8ref0
                                            begin
                                                slice_data_state    <= `sub_mb_pred;
                                                sub_mb_pred_state   <= `rst_sub_mb_pred;
                                            end
                                        else
                                            begin
                                                if ( num_ref_idx_l0_active_minus1_in > 0 )
                                                    begin
                                                        mb_pred_state <= `ref_idx_l0_s;
                                                        exp_golomb_decoding_te_sel_out  <= 1;
                                                    end
                                                else
                                                    begin
                                                        ref_idx_l0_out <= 0;
                                                        ref_idx_l0_curr_mb_out <= 0;
                                                        mb_pred_state <= `mvdx_l0_s;
                                                    end
                                            end
                                    end 
                            end    
                            `prev_intra4x4_pred_mode_flag_s:
                                begin
                                    prev_intra4x4_pred_mode_flag_out <= rbsp_in[23];
                                    if (rbsp_in[23] == 0)
                                        mb_pred_state <= `rem_intra4x4_pred_mode_s;
                                    else
                                        mb_pred_state <= `luma_blk4x4_index_update;
                                end
                            `rem_intra4x4_pred_mode_s:
                                begin
                                    rem_intra4x4_pred_mode_out <= rbsp_in[23:21];
                                    mb_pred_state <= `luma_blk4x4_index_update;
                                end

                            `intra_pred_mode_chroma_s:
                                begin
                                    intra_pred_mode_chroma <= exp_golomb_decoding_output_in;
                                    if ( mb_pred_mode_comb != `mb_pred_mode_I16MB )
                                        begin
                                            slice_data_state <= `coded_block_pattern_s;
                                            if ( mb_pred_mode_comb == `mb_pred_mode_I4MB )
                                                exp_golomb_decoding_me_intra4x4_out <= 1;
                                            else // inter
                                                exp_golomb_decoding_me_intra4x4_out <= 0;
                                        end
                                    else if (CBP_luma_in || CBP_chroma_in || mb_pred_mode_comb == `mb_pred_mode_I16MB)
                                        slice_data_state <= `mb_qp_delta_s;
                                    else
                                        begin
                                            slice_data_state <= `residual; 
                                            residual_state <= `rst_residual;
                                        end
                                end
                                
                            `luma_blk4x4_index_update:
                                begin
                                    case(luma4x4BlkIdx_out)
                                        0 : intra4x4_pred_mode_curr_mb_out[3 : 0] <= I4_pred_mode_in; 
                                        1 : intra4x4_pred_mode_curr_mb_out[7 : 4] <= I4_pred_mode_in; 
                                        2 : intra4x4_pred_mode_curr_mb_out[11: 8] <= I4_pred_mode_in; 
                                        3 : intra4x4_pred_mode_curr_mb_out[15:12] <= I4_pred_mode_in; 
                                        4 : intra4x4_pred_mode_curr_mb_out[19:16] <= I4_pred_mode_in; 
                                        5 : intra4x4_pred_mode_curr_mb_out[23:20] <= I4_pred_mode_in; 
                                        6 : intra4x4_pred_mode_curr_mb_out[27:24] <= I4_pred_mode_in; 
                                        7 : intra4x4_pred_mode_curr_mb_out[31:28] <= I4_pred_mode_in; 
                                        8 : intra4x4_pred_mode_curr_mb_out[35:32] <= I4_pred_mode_in; 
                                        9 : intra4x4_pred_mode_curr_mb_out[39:36] <= I4_pred_mode_in; 
                                        10: intra4x4_pred_mode_curr_mb_out[43:40] <= I4_pred_mode_in; 
                                        11: intra4x4_pred_mode_curr_mb_out[47:44] <= I4_pred_mode_in; 
                                        12: intra4x4_pred_mode_curr_mb_out[51:48] <= I4_pred_mode_in; 
                                        13: intra4x4_pred_mode_curr_mb_out[55:52] <= I4_pred_mode_in; 
                                        14: intra4x4_pred_mode_curr_mb_out[59:56] <= I4_pred_mode_in; 
                                        15: intra4x4_pred_mode_curr_mb_out[63:60] <= I4_pred_mode_in; 
                                    endcase
                                    if (luma4x4BlkIdx_out == 15)
                                        begin
                                            luma4x4BlkIdx_out <= 0;
                                            mb_pred_state <= `intra_pred_mode_chroma_s;
                                        end
                                    else
                                        begin
                                            luma4x4BlkIdx_out <= luma4x4BlkIdx_out + 1;
                                            mb_pred_state <= `prev_intra4x4_pred_mode_flag_s;
                                        end
                                end 
                            `ref_idx_l0_s:
                                begin
                                    ref_idx_l0_out <= exp_golomb_decoding_output_te_in;
                                    if ( mb_type == 0) // P_L0_16x16
                                        begin
                                            MbPartNum <= 1;
                                            MbPartWidth <= 16;
                                            MbPartHeight <= 16;
                                            ref_idx_l0_curr_mb_out[2:0] <= exp_golomb_decoding_output_te_in;
                                            ref_idx_l0_curr_mb_out[5:3] <= exp_golomb_decoding_output_te_in;
                                            ref_idx_l0_curr_mb_out[8:6] <= exp_golomb_decoding_output_te_in;
                                            ref_idx_l0_curr_mb_out[11:9] <= exp_golomb_decoding_output_te_in;
                                            exp_golomb_decoding_te_sel_out  <= 0;
                                            mb_pred_state <= `mvdx_l0_s;
                                        end
                                    else if ( mb_type == 1 ) // P_L0_L0_16x8
                                        begin
                                            MbPartNum <= 2;
                                            MbPartWidth <= 16;
                                            MbPartHeight <= 8;
                                            if (mbPartIdx == 0)
                                                begin
                                                    ref_idx_l0_curr_mb_out[2:0] <= exp_golomb_decoding_output_te_in;
                                                    ref_idx_l0_curr_mb_out[5:3] <= exp_golomb_decoding_output_te_in;
                                                    mbPartIdx <= 1;
                                                end
                                            else if (mbPartIdx == 1)
                                                begin
                                                    ref_idx_l0_curr_mb_out[8:6] <= exp_golomb_decoding_output_te_in;
                                                    ref_idx_l0_curr_mb_out[11:9] <= exp_golomb_decoding_output_te_in;
                                                    mbPartIdx <= 0;
                                                    mb_pred_state <= `mvdx_l0_s;
                                                    exp_golomb_decoding_te_sel_out  <= 0;
                                                end
                                        end
                                    else // mb_type = 2  P_L0_L0_8x16
                                        begin
                                            MbPartNum <= 2;
                                            MbPartWidth <= 8;
                                            MbPartHeight <= 16;
                                            if (mbPartIdx == 0)
                                                begin
                                                    ref_idx_l0_curr_mb_out[2:0] <= exp_golomb_decoding_output_te_in;
                                                    ref_idx_l0_curr_mb_out[8:6] <= exp_golomb_decoding_output_te_in;
                                                    mbPartIdx <= 1;
                                                end
                                            else if (mbPartIdx == 1)
                                                begin
                                                    ref_idx_l0_curr_mb_out[5:3] <= exp_golomb_decoding_output_te_in;
                                                    ref_idx_l0_curr_mb_out[11:9] <= exp_golomb_decoding_output_te_in;
                                                    mbPartIdx <= 0;
                                                    mb_pred_state <= `mvdx_l0_s;
                                                    exp_golomb_decoding_te_sel_out  <= 0;
                                                end
                                        end
                                end
                            `mvdx_l0_s:
                                begin
                                    mvdx_l0 <= exp_golomb_decoding_output_se_in;
                                    mb_pred_state <= `mvdy_l0_s; 
                                end
                            `mvdy_l0_s:
                                begin
                                    mvdy_l0 <= exp_golomb_decoding_output_se_in;
                                    if (mbPartIdx + 1 < MbPartNum)
                                        begin
                                            mbPartIdx <= mbPartIdx + 1;
                                            mb_pred_state <= `mvdx_l0_s;
                                            if ( mb_type == 1) // P_L0_L0_16x8
                                                luma4x4BlkIdx_out <= 8; // In order to update pixel_y, pixel_x and for get_mvp
                                            else if ( mb_type == 2 )// P_L0_L0_8x16
                                                luma4x4BlkIdx_out <= 4;
                                        end
                                    else
                                        begin
                                            mb_pred_state <= `rst_mb_pred;
                                            if ( mb_pred_mode_comb != `mb_pred_mode_I16MB )
                                                begin
                                                    slice_data_state <= `coded_block_pattern_s;
                                                    if ( mb_pred_mode_comb == `mb_pred_mode_I4MB )
                                                        exp_golomb_decoding_me_intra4x4_out <= 1;
                                                    else // inter
                                                        exp_golomb_decoding_me_intra4x4_out <= 0;
                                                end
                                            else if (CBP_luma_reg || CBP_chroma_reg || mb_pred_mode_comb == `mb_pred_mode_I16MB)
                                                slice_data_state <= `mb_qp_delta_s;
                                            else
                                                begin
                                                    slice_data_state <= `residual; 
                                                    residual_state <= `rst_residual;
                                                end
                                        end
                                end
                            default: mb_pred_state <= `rst_mb_pred;
                        endcase // case(mb_pred_state)
                        
                    `coded_block_pattern_s:
                        begin
                            CBP_luma_reg <= CBP_luma_in;
                            CBP_chroma_reg <= CBP_chroma_in;
                            if (CBP_luma_in || CBP_chroma_in || mb_pred_mode_comb == `mb_pred_mode_I16MB)
                                begin
                                    slice_data_state <= `mb_qp_delta_s;
                                end
                            else
                                begin
                                    slice_data_state <= `residual; 
                                    residual_state <= `rst_residual;
                                end
                        end
                    
                    `mb_qp_delta_s:
                        begin
                            qp <= qp  + exp_golomb_decoding_output_se_in;
                            slice_data_state <= `residual;
                            residual_state <= `rst_residual;                            
                        end
       
                    `residual:
                        case(residual_state)
                            `rst_residual :
                                 begin
                                    step <= 0;
                                    luma4x4BlkIdx_out <= 0;
                                    chroma4x4BlkIdx_out <= 0;
                                    if (mb_pred_mode_comb == `mb_pred_mode_I16MB) 
                                        residual_state <= `Intra16x16DCLevel_s;
                                    else if (CBP_luma_reg & 1)                                        
                                        residual_state <= `LumaLevel_s;
                                    else
                                        residual_state <= `LumaLevel_0_s;
                                end
                            `Intra16x16DCLevel_s:
                                begin
                                    if(step == 0)
                                    begin
                                        residual_start <= 1;
                                        nC <= nC_in;
                                        max_coeff_num <= 16;                                                    
                                        step <= 1;
                                    end
                                    else if (step == 1) begin
                                    	residual_start <= 0;
                                    	step <= 2;
                                    end
                                    else if (step == 2) begin                         
                                        if(residual_valid) begin
                                            step <= 0;
                                            if ( CBP_luma_reg & (1 << (luma4x4BlkIdx_out >> 2) ) )
                                                residual_state <= `Intra16x16ACLevel_s;
                                            else
                                                residual_state <= `Intra16x16ACLevel_0_s;
                                        end
                                    end
                                end
                                
                            `Intra16x16ACLevel_s:
                                begin
                                    if (step == 0) begin
                                        residual_start <= 1;
                                        nC <= nC_in;
                                        max_coeff_num <= 15;
                                        step <= 1;
                                        if (mb_pred_inter_sel) begin
                                            inter_pred_start <= 1;
                                        	ref_x <= ref_x_comb[`mb_x_bits + 5:0];
 			                       			ref_y <= ref_y_comb[`mb_y_bits + 5:0];
                        					ref_idx <= ref_idx_l0_curr_blk4x4; 
                        				end
                                        else begin
                                        	intra_pred_start <= 1;
                        				end
                                    end
                                    else if (step == 1) begin
                                        residual_start <= 0;
                                        if (mb_pred_inter_sel)
                                        	inter_pred_start <= 0;
                                        else
                                        	intra_pred_start <= 0;
                                        step <= 2;
                                    end
                                    else if (step == 2) begin
                                    	if (mb_pred_inter_sel)begin
                                            if (residual_valid && inter_pred_valid) begin
                                    			sum_start <= 1;
                                    			step <= 3;
                                    		end
                                        end
                                        else begin
                                        	if (residual_valid && intra_pred_valid) begin
                                    			sum_start <= 1;
                                    			step <= 3;
                                    		end
                                    	end
                                    end
                                    else if (step == 3) begin
                                    	sum_start <= 0;
                                    	step <= 4;
                                    end
                                    else if (step == 4) begin
                                        if(sum_valid) begin
                                            step <= 0;
                                            if ( luma4x4BlkIdx_out == 15 )
                                                if ( CBP_chroma_reg )
                                                    residual_state <= `ChromaDCLevel_Cb_s;
                                                else begin
                                                    residual_state <= `ChromaACLevel_Cb_0_s;
                                                    chroma4x4BlkIdx_out <= 0;
                                                end
                                            else if (  CBP_luma_reg & (1 <<( (luma4x4BlkIdx_out +1) >> 2 ) ) )
                                                begin
                                                    luma4x4BlkIdx_out <= luma4x4BlkIdx_out + 1;
                                                    residual_state <= `Intra16x16ACLevel_s;
                                                end
                                            else
                                                begin
                                                    luma4x4BlkIdx_out <= luma4x4BlkIdx_out + 1;
                                                    residual_state <= `Intra16x16ACLevel_0_s;
                                                end
                                        end
                                    end                                   
                                end
                            
                            `Intra16x16ACLevel_0_s :
                                begin
                                    if (step == 0) begin
                                        residual_start <= 1;
                                        if (mb_pred_inter_sel) begin
                                            inter_pred_start <= 1;
                                        	ref_x <= ref_x_comb[`mb_x_bits + 5:0];
 			                       			ref_y <= ref_y_comb[`mb_y_bits + 5:0];
                        					ref_idx <= ref_idx_l0_curr_blk4x4; 
                        				end
                                        else begin
                                        	intra_pred_start <= 1;
                        				end
                                        step <= 1;
                                    end
                                    else if (step == 1) begin
                                        residual_start <= 0;
                                        if (mb_pred_inter_sel)
                                        	inter_pred_start <= 0;
                                        else
                                        	intra_pred_start <= 0;
                                        step <= 2;
                                    end
                                    else if (step == 2) begin
                                    	if (mb_pred_inter_sel)begin
                                            if (residual_valid && inter_pred_valid) begin
                                    			sum_start <= 1;
                                    			step <= 3;
                                    		end
                                        end
                                        else begin
                                        	if (residual_valid && intra_pred_valid) begin
                                    			sum_start <= 1;
                                    			step <= 3;
                                    		end
                                    	end
                                    end
                                    else if (step == 3) begin
                                    	sum_start <= 0;
                                    	step <= 4;
                                    end
                                    else if (step == 4) begin
                                        if(sum_valid) begin
                                            step <= 0;  
                                            if ( luma4x4BlkIdx_out == 15 )
                                                if ( CBP_chroma_reg )
                                                    residual_state <= `ChromaDCLevel_Cb_s;
                                                else begin
                                                    residual_state <= `ChromaACLevel_Cb_0_s;
                                                    chroma4x4BlkIdx_out <= 0;                                        
                                                end
                                            else if ( CBP_luma_reg & (1 <<( (luma4x4BlkIdx_out +1) >> 2 ) ) )
                                                begin
                                                    luma4x4BlkIdx_out <= luma4x4BlkIdx_out + 1;
                                                    residual_state <= `Intra16x16ACLevel_s;
                                                end
                                            else
                                                begin
                                                    luma4x4BlkIdx_out <= luma4x4BlkIdx_out + 1;
                                                    residual_state <= `Intra16x16ACLevel_0_s;
                                                end
                                        end
                                    end
                                end
                                
                            `LumaLevel_s:
                                begin
                                    if (step == 0) begin
                                        residual_start <= 1;
                                        nC <= nC_in;
                                        max_coeff_num <= 16;
                                        step <= 1;
                                        if (mb_pred_inter_sel) begin
                                            inter_pred_start <= 1;
                                        	ref_x <= ref_x_comb[`mb_x_bits + 5:0];
 			                       			ref_y <= ref_y_comb[`mb_y_bits + 5:0];
                        					ref_idx <= ref_idx_l0_curr_blk4x4; 
                        				end
                                        else begin
                                        	intra_pred_start <= 1;
                        				end
                                    end
                                    else if (step == 1) begin
                                    	residual_start <= 0;
                                    	if (mb_pred_inter_sel)
                                        	inter_pred_start <= 0;
                                        else
                                        	intra_pred_start <= 0;
                                    	step <= 2;
                                    end
                                    else if (step == 2) begin    
                                    	if (mb_pred_inter_sel)begin
                                            if (residual_valid && inter_pred_valid) begin
                                    			sum_start <= 1;
                                    			step <= 3;
                                    		end
                                        end
                                        else begin
                                        	if (residual_valid && intra_pred_valid) begin
                                    			sum_start <= 1;
                                    			step <= 3;
                                    		end
                                    	end
                                    end
                                    else if (step == 3) begin
                                    	sum_start <= 0;
                                    	step <= 4;
                                    end           
                                    else if (step == 4) begin 
                                        if(sum_valid) begin                                   
                                            step <= 0;
                                            if ( luma4x4BlkIdx_out == 15 )
                                                if ( CBP_chroma_reg )
                                                    residual_state <= `ChromaDCLevel_Cb_s;
                                                else begin
                                                    residual_state <= `ChromaACLevel_Cb_0_s;
                                                    chroma4x4BlkIdx_out <= 0;                                             
                                                end
                                            else if (  CBP_luma_reg & (1 <<( (luma4x4BlkIdx_out +1) >> 2 ) ))
                                                begin
                                                    luma4x4BlkIdx_out <= luma4x4BlkIdx_out + 1;
                                                    residual_state <= `LumaLevel_s;
                                                end
                                            else
                                                begin
                                                    luma4x4BlkIdx_out <= luma4x4BlkIdx_out + 1;
                                                    residual_state <= `LumaLevel_0_s;
                                                end
                                        end
                                    end
                                end
    
                            `LumaLevel_0_s:
                                begin
                                    if (step == 0) begin
                                        residual_start <= 1;
                                        if (mb_pred_inter_sel) begin
                                            inter_pred_start <= 1;
                                        	ref_x <= ref_x_comb[`mb_x_bits + 5:0];
 			                       			ref_y <= ref_y_comb[`mb_y_bits + 5:0];
                        					ref_idx <= ref_idx_l0_curr_blk4x4; 
                        				end
                                        else begin
                                        	intra_pred_start <= 1;
                        				end
                                        step <= 1;
                                    end
                                    else if (step == 1) begin
                                    	residual_start <= 0;
                                    	if (mb_pred_inter_sel)
                                        	inter_pred_start <= 0;
                                        else
                                        	intra_pred_start <= 0;
                                    	step <= 2;
                                    end
                                    else if (step == 2) begin    
                                    	if (mb_pred_inter_sel)begin
                                            if (residual_valid && inter_pred_valid) begin
                                    			sum_start <= 1;
                                    			step <= 3;
                                    		end
                                        end
                                        else begin
                                        	if (residual_valid && intra_pred_valid) begin
                                    			sum_start <= 1;
                                    			step <= 3;
                                    		end
                                    	end
                                    end
                                    else if (step == 3) begin
                                    	sum_start <= 0;
                                    	step <= 4;
                                    end           
                                    else if (step == 4) begin 
                                        if(sum_valid) begin                                   
                                            step <= 0;
                                            if ( luma4x4BlkIdx_out == 15 )
                                                if ( CBP_chroma_reg )
                                                    residual_state <= `ChromaDCLevel_Cb_s;
                                                else begin
                                                    residual_state <= `ChromaACLevel_Cb_0_s;
                                                    chroma4x4BlkIdx_out <= 0;                                            
                                                end
                                            else if (  CBP_luma_reg & (1 <<( (luma4x4BlkIdx_out +1) >> 2 ) ) )
                                                begin
                                                    luma4x4BlkIdx_out <= luma4x4BlkIdx_out + 1;
                                                    residual_state <= `LumaLevel_s;
                                               end
                                            else
                                                begin
                                                    luma4x4BlkIdx_out <= luma4x4BlkIdx_out + 1;
                                                    residual_state <= `LumaLevel_0_s;
                                                end
                                        end
                                    end
                                end
                                
                            `ChromaDCLevel_Cb_s:
                                begin
                                    if(step == 0)begin
                                        residual_start <= 1;
                                        nC <= -1;
                                        max_coeff_num <= 4;
                                        step <= 1;
                                    end
                                    else if (step == 1) begin
                                        residual_start <= 0;
                                        step <= 2;
                                    end
                                    else if (step == 2) begin
                                        if(residual_valid) begin
                                            step <= 0;
                                            residual_state <= `ChromaDCLevel_Cr_s;
                                        end
                                    end
                                end
    
                            `ChromaDCLevel_Cr_s:
                                begin
                                    if(step == 0)begin
                                        residual_start <= 1;
                                        nC <= -1;
                                        max_coeff_num <= 4;
                                        step <= 1;
                                    end
                                    else if (step == 1) begin
                                        residual_start <= 0;
                                        step <= 2;
                                    end
                                    else if (step == 2) begin
                                        if(residual_valid) begin
                                            step <= 0;
                                            if ( CBP_chroma_reg[1] )
                                                begin
                                                    residual_state <= `ChromaACLevel_Cb_s;
                                                end
                                            else
                                                begin
                                                    residual_state <= `ChromaACLevel_Cb_0_s;
                                                    chroma4x4BlkIdx_out <= 0;
                                                end
                                        end
                                    end
                                end
    
                            `ChromaACLevel_Cb_s:
                                begin
                                    if (step == 0) begin
                                        residual_start <= 1;
                                        nC <= nC_cb_in;
                                        max_coeff_num <= 15;
                                        step <= 1;
                                        if (mb_pred_inter_sel) begin
                                            inter_pred_start <= 1;
                                        	ref_x <= ref_x_comb[`mb_x_bits + 5:0];
 			                       			ref_y <= ref_y_comb[`mb_y_bits + 5:0];
                        					ref_idx <= ref_idx_l0_curr_blk4x4; 
                        				end
                                        else begin
                                        	intra_pred_start <= 1;
                        				end
                                    end
                                    else if (step == 1) begin
                                    	residual_start <= 0;
                                    	if (mb_pred_inter_sel)
                                        	inter_pred_start <= 0;
                                        else
                                        	intra_pred_start <= 0;
                                    	step <= 2;
                                    end
                                    else if (step == 2) begin    
                                    	if (mb_pred_inter_sel)begin
                                            if (residual_valid && inter_pred_valid) begin
                                    			sum_start <= 1;
                                    			step <= 3;
                                    		end
                                        end
                                        else begin
                                        	if (residual_valid && intra_pred_valid) begin
                                    			sum_start <= 1;
                                    			step <= 3;
                                    		end
                                    	end
                                    end
                                    else if (step == 3) begin
                                    	sum_start <= 0;
                                    	step <= 4;
                                    end
                                    else if (step == 4) begin 
                                        if(sum_valid) begin                                           
                                            step <= 0; 
                                            if ( chroma4x4BlkIdx_out == 3 )
                                                begin
                                                    residual_state <= `ChromaACLevel_Cr_s;
                                                    chroma4x4BlkIdx_out <= 0;
                                                end
                                            else
                                                begin
                                                    residual_state <= `ChromaACLevel_Cb_s;
                                                    chroma4x4BlkIdx_out <= chroma4x4BlkIdx_out + 1;
                                                end
                                        end
                                    end
                                end
                                
                            `ChromaACLevel_Cr_s:
                                begin
                                    if (step == 0) begin
                                        residual_start <= 1;
                                        nC <= nC_cr_in;
                                        max_coeff_num <= 15;
                                        step <= 1;
                                    	if (mb_pred_inter_sel) begin
                                            inter_pred_start <= 1;
                                        	ref_x <= ref_x_comb[`mb_x_bits + 5:0];
 			                       			ref_y <= ref_y_comb[`mb_y_bits + 5:0];
                        					ref_idx <= ref_idx_l0_curr_blk4x4; 
                        				end
                                        else begin
                                        	intra_pred_start <= 1;
                        				end
                                    end
                                    else if (step == 1) begin
                                    	residual_start <= 0;
                                    	if (mb_pred_inter_sel)
                                        	inter_pred_start <= 0;
                                        else
                                        	intra_pred_start <= 0;
                                    	step <= 2;
                                    end
                                    else if (step == 2) begin    
                                    	if (mb_pred_inter_sel)begin
                                            if (residual_valid && inter_pred_valid) begin
                                    			sum_start <= 1;
                                    			step <= 3;
                                    		end
                                        end
                                        else begin
                                        	if (residual_valid && intra_pred_valid) begin
                                    			sum_start <= 1;
                                    			step <= 3;
                                    		end
                                    	end
                                    end
                                    else if (step == 3) begin
                                    	sum_start <= 0;
                                    	step <= 4;
                                    end
                                    else if (step == 4) begin 
                                        if(sum_valid) begin                                           
                                            step <= 0;
                                            if ( chroma4x4BlkIdx_out == 3 )
                                                begin
                                                    residual_state <= `rst_residual;
                                                    slice_data_state <= `store_to_fpga_ram; // temporary, should be `intra-pred or inter-polate
                                                end
                                            else
                                                begin
                                                    chroma4x4BlkIdx_out <= chroma4x4BlkIdx_out + 1;
                                                    residual_state <= `ChromaACLevel_Cr_s;
                                                end
                                        end
                                    end
                                end
                                              
                            `ChromaACLevel_Cb_0_s:
                                begin
	                                if (step == 0) begin
                                        residual_start <= 1;
                                        step <= 1;
                                        if (mb_pred_inter_sel) begin
                                            inter_pred_start <= 1;
                                        	ref_x <= ref_x_comb[`mb_x_bits + 5:0];
 			                       			ref_y <= ref_y_comb[`mb_y_bits + 5:0];
 			                       			ref_idx <= ref_idx_l0_curr_blk4x4; 
                        				end
                                        else begin
                                        	intra_pred_start <= 1;
                        				end
                                    end
                                    else if (step == 1) begin
                                    	residual_start <= 0;
                                    	if (mb_pred_inter_sel)
                                        	inter_pred_start <= 0;
                                        else
                                        	intra_pred_start <= 0;
                                    	step <= 2;
                                    end
                                    else if (step == 2) begin    
                                    	if (mb_pred_inter_sel)begin
                                            if (residual_valid && inter_pred_valid) begin
                                    			sum_start <= 1;
                                    			step <= 3;
                                    		end
                                        end
                                        else begin
                                        	if (residual_valid && intra_pred_valid) begin
                                    			sum_start <= 1;
                                    			step <= 3;
                                    		end
                                    	end
                                    end
                                    else if (step == 3) begin
                                    	sum_start <= 0;
                                    	step <= 4;
                                    end
                                    else if (step == 4) begin 
                                        if(sum_valid) begin                                           
                                            step <= 0;                                
                                            if ( chroma4x4BlkIdx_out == 3) begin
                                                residual_state <= `ChromaACLevel_Cr_0_s;
                                                chroma4x4BlkIdx_out <= 0;
                                            end
                                            else begin
                                                 chroma4x4BlkIdx_out <= chroma4x4BlkIdx_out + 1;
                                            end
                                        end
                                    end
                                end
                            `ChromaACLevel_Cr_0_s:
                                begin
                                    if (step == 0) begin
                                        residual_start <= 1;
                                        step <= 1;
                                    	if (mb_pred_inter_sel) begin
                                            inter_pred_start <= 1;
                                        	ref_x <= ref_x_comb[`mb_x_bits + 5:0];
 			                       			ref_y <= ref_y_comb[`mb_y_bits + 5:0];
                        					ref_idx <= ref_idx_l0_curr_blk4x4; 
                        				end
                                        else begin
                                        	intra_pred_start <= 1;
                        				end
                                    end
                                    else if (step == 1) begin
                                    	residual_start <= 0;
                                    	if (mb_pred_inter_sel)
                                        	inter_pred_start <= 0;
                                        else
                                        	intra_pred_start <= 0;
                                    	step <= 2;
                                    end
                                    else if (step == 2) begin    
                                    	if (mb_pred_inter_sel)begin
                                            if (residual_valid && inter_pred_valid) begin
                                    			sum_start <= 1;
                                    			step <= 3;
                                    		end
                                        end
                                        else begin
                                        	if (residual_valid && intra_pred_valid) begin
                                    			sum_start <= 1;
                                    			step <= 3;
                                    		end
                                    	end
                                    end
                                    else if (step == 3) begin
                                    	sum_start <= 0;
                                    	step <= 4;
                                    end
                                    else if (step == 4) begin 
                                        if(sum_valid) begin                                           
                                            step <= 0; 
                                            if ( chroma4x4BlkIdx_out == 3) begin
                                                residual_state <= `rst_residual;
                                                slice_data_state <= `store_to_fpga_ram; // temporary, should be `intra-pred or inter-polate
                                            end
                                            else begin
                                                 chroma4x4BlkIdx_out <= chroma4x4BlkIdx_out + 1;
                                            end
                                        end
                                    end
                                end                                
                        endcase // case(residual_state)
                    `p_skip_s : begin
                    	case (p_skip_state)
                    	`rst_p_skip_s : begin
                    		step <= 0;
                            luma4x4BlkIdx_out <= 0;
                            chroma4x4BlkIdx_out <= 0;
                            p_skip_state <= `p_skip_luma_s;
                    	end
                    	`p_skip_luma_s : begin
                        	if (step == 0) begin
                        		ref_x <= ref_x_comb[`mb_x_bits + 5:0];
 			                    ref_y <= ref_y_comb[`mb_y_bits + 5:0];
                        		ref_idx <= 0;
                        		inter_pred_start <= 1;
                        		step <= 1;
                        	end
                        	else if (step == 1) begin
                        		inter_pred_start <= 0;
                        		step <= 2;
                        	end
                        	else if (step == 2) begin
                        		if (inter_pred_valid) begin
                        			sum_start <= 1;
                        			step <= 3;
                        		end
                        	end
                        	else if (step == 3) begin
                        		sum_start <= 0;
                        		step <= 4;
                        	end
                        	else if (step == 4) begin
                        		if (sum_valid) begin
                        			step <= 0;
	                        		if ( luma4x4BlkIdx_out == 15 ) begin
                                		p_skip_state <= `p_skip_cb_s;
                                		chroma4x4BlkIdx_out <= 0;
                                	end
                                	else
                                    	luma4x4BlkIdx_out <= luma4x4BlkIdx_out + 1;
                            	end
                        	end
                        end
                        `p_skip_cb_s : begin
	                        if (step == 0) begin
                        		ref_x <= ref_x_comb[`mb_x_bits + 5:0];
 			                    ref_y <= ref_y_comb[`mb_y_bits + 5:0];
                        		ref_idx <= 0;
                        		inter_pred_start <= 1;
                        		step <= 1;
                        	end
                        	else if (step == 1) begin
                        		inter_pred_start <= 0;
                        		step <= 2;
                        	end
                        	else if (step == 2) begin
                        		if (inter_pred_valid) begin
                        			sum_start <= 1;
                        			step <= 3;
                        		end
                        	end
                        	else if (step == 3) begin
                        		sum_start <= 0;
                        		step <= 4;
                        	end
                        	else if (step == 4) begin
                        		if (sum_valid) begin
	                        		step <= 0;
		                        	if ( chroma4x4BlkIdx_out == 3 ) begin
            	                    	p_skip_state <= `p_skip_cr_s;
            	                    	chroma4x4BlkIdx_out <= 0;
            	                    end
                    	            else
                        	            chroma4x4BlkIdx_out <= chroma4x4BlkIdx_out + 1;
                        		end
                        	end
                        end
                        `p_skip_cr_s : begin
	                        if (step == 0) begin
                        		ref_x <= ref_x_comb[`mb_x_bits + 5:0];
 			                    ref_y <= ref_y_comb[`mb_y_bits + 5:0];
                        		ref_idx <= 0;
                        		inter_pred_start <= 1;
                        		step <= 1;
                        	end
                        	else if (step == 1) begin
                        		inter_pred_start <= 0;
                        		step <= 2;
                        	end
                        	else if (step == 2) begin
                        		if (inter_pred_valid) begin
                        			sum_start <= 1;
                        			step <= 3;
                        		end
                        	end
                        	else if (step == 3) begin
                        		sum_start <= 0;
                        		step <= 4;
                        	end
                        	else if (step == 4) begin
                        		if (sum_valid) begin
	                        		step <= 0;
		                        	if ( chroma4x4BlkIdx_out == 3 ) begin
        	                        	p_skip_state <= `rst_p_skip_s;
            	                    	slice_data_state <= `store_to_fpga_ram; //temporary, should be inter-polate
                	                end
                    	            else
                        	            chroma4x4BlkIdx_out <= chroma4x4BlkIdx_out + 1;
                        		end
                        	end
                        end
                    	endcase
                    end
                    `sub_mb_pred: 
                        case(sub_mb_pred_state)
                            `rst_sub_mb_pred:
                                begin
                                    sub_mb_pred_state <= `sub_mb_type_s;
                                    mbPartIdx <= 0; // 4 8x8 sub mb, no possible 1 16x8 and 2 8x8
                                    subMbPartIdx <= 0;
                                end
                            `sub_mb_type_s: // stream format: 4 sub_mb_type, 4 ref_idx(if exist), mvds
                                begin
                                    if (mbPartIdx == 0)
                                        begin
                                            sub_mb_type[3:0] <= exp_golomb_decoding_output_in;
                                            mbPartIdx <= 1;
                                        end
                                    else if (mbPartIdx == 1)
                                        begin
                                            sub_mb_type[7:4] <= exp_golomb_decoding_output_in;
                                            mbPartIdx <= 2;
                                        end
                                    else if (mbPartIdx == 2)
                                        begin
                                            sub_mb_type[11:8] <= exp_golomb_decoding_output_in;
                                            mbPartIdx <= 3;
                                        end
                                    else if (mbPartIdx == 3)
                                        begin
                                            sub_mb_type[15:12] <= exp_golomb_decoding_output_in;
                                            mbPartIdx <= 0;
                                            if ( num_ref_idx_l0_active_minus1_in > 0 && mb_pred_mode_comb != `mb_pred_mode_P_REF0 )
                                                begin
                                                    sub_mb_pred_state <= `sub_ref_idx_l0_s;
                                                    exp_golomb_decoding_te_sel_out  <= 1;
                                                end
                                            else
                                                begin
                                                    ref_idx_l0_out <= 0;
                                                    ref_idx_l0_curr_mb_out <= 0;
                                                    mbPartIdx <= 0;
                                                    subMbPartIdx <= 0;
                                                    luma4x4BlkIdx_out <= 0;                                                    
                                                    case(sub_mb_type[1:0])
                                                        0:begin MbPartWidth <= 8; MbPartHeight <= 8;SubMbPartNum <= 1;end
                                                        1:begin MbPartWidth <= 8; MbPartHeight <= 4;SubMbPartNum <= 2;end
                                                        2:begin MbPartWidth <= 4; MbPartHeight <= 8;SubMbPartNum <= 2;end
                                                        3:begin MbPartWidth <= 4; MbPartHeight <= 4;SubMbPartNum <= 4;end
                                                        default:begin MbPartWidth <= 0; MbPartHeight <= 0;end
                                                    endcase                                                    
                                                    sub_mb_pred_state <= `sub_mvdx_l0_s;
                                                end
                                        end
                                end
                                      
                            `sub_ref_idx_l0_s:
                                if (mbPartIdx == 0)
                                    begin
                                        ref_idx_l0_out <= exp_golomb_decoding_output_te_in;
                                        ref_idx_l0_curr_mb_out[2:0] <= exp_golomb_decoding_output_te_in;
                                        mbPartIdx <= 1;
                                    end
                                else if (mbPartIdx == 1)
                                    begin
                                        ref_idx_l0_out <= exp_golomb_decoding_output_te_in;
                                        ref_idx_l0_curr_mb_out[5:3] <= exp_golomb_decoding_output_te_in;
                                        mbPartIdx <= 2;
                                    end
                                else if (mbPartIdx == 2)
                                    begin
                                        ref_idx_l0_out <= exp_golomb_decoding_output_te_in;
                                        ref_idx_l0_curr_mb_out[8:6] <= exp_golomb_decoding_output_te_in;
                                        mbPartIdx <= 3;
                                    end
                                else //mbPartIdx = 3
                                    begin
                                        ref_idx_l0_out <= exp_golomb_decoding_output_te_in;
                                        ref_idx_l0_curr_mb_out[11:9] <= exp_golomb_decoding_output_te_in;
                                        sub_mb_pred_state <= `sub_mvdx_l0_s;
                                        exp_golomb_decoding_te_sel_out  <= 0;
                                        case(sub_mb_type[1:0])
                                            0:begin MbPartWidth <= 8; MbPartHeight <= 8;SubMbPartNum <= 1;end
                                            1:begin MbPartWidth <= 8; MbPartHeight <= 4;SubMbPartNum <= 2;end
                                            2:begin MbPartWidth <= 4; MbPartHeight <= 8;SubMbPartNum <= 2;end
                                            3:begin MbPartWidth <= 4; MbPartHeight <= 4;SubMbPartNum <= 4;end
                                            default:begin MbPartWidth <= 0; MbPartHeight <= 0;end
                                        endcase
                                        mbPartIdx <= 0;
                                        subMbPartIdx <= 0;
                                        luma4x4BlkIdx_out <= 0;
                                    end
                
                            `sub_mvdx_l0_s:
                                begin
                                    mvdx_l0 <= exp_golomb_decoding_output_se_in;
                                    sub_mb_pred_state <= `sub_mvdy_l0_s;
                                end
                                
                                
                            `sub_mvdy_l0_s:
                                begin
                                    mvdy_l0 <= exp_golomb_decoding_output_se_in;
                                    if (subMbPartIdx + 1 < SubMbPartNum)
                                        begin
                                            sub_mb_pred_state <= `sub_mvdx_l0_s;
                                            subMbPartIdx <= subMbPartIdx + 1;
                                            case (sub_mb_type[1:0]) // update luma4x4BlkIdx for get_mvp
                                                1:luma4x4BlkIdx_out <= (mbPartIdx << 2)+2;
                                                2:luma4x4BlkIdx_out <= (mbPartIdx << 2)+1;
                                                3:luma4x4BlkIdx_out <= (mbPartIdx << 2) + subMbPartIdx+1;
                                                default:luma4x4BlkIdx_out <= 0;
                                            endcase 
                                        end
                                    else
                                        begin
                                            if (mbPartIdx + 1 < 4)
                                                begin
                                                    sub_mb_pred_state <= `sub_mvdx_l0_s;
                                                    sub_mb_type <= sub_mb_type >> 4;    //last 2 bits -> curr_sub_mb_type
                                                    mbPartIdx <= mbPartIdx + 1;
                                                    subMbPartIdx <= 0;
                                                    luma4x4BlkIdx_out <= (mbPartIdx+1) << 2; // update luma4x4BlkIdx for get_mvp
                                                    case ((sub_mb_type>>4) & 4'hf)
                                                        0: 
                                                            begin
                                                                MbPartWidth <= 8;
                                                                MbPartHeight <= 8;
                                                                SubMbPartNum <= 1;
                                                            end
                                                        1:
                                                            begin
                                                                MbPartWidth <= 8;
                                                                MbPartHeight <= 4;
                                                                SubMbPartNum <= 2;
                                                            end
                                                        2:
                                                            begin
                                                                MbPartWidth <= 4;
                                                                MbPartHeight <= 8;
                                                                SubMbPartNum <= 2;
                                                            end
                                                        3:
                                                            begin
                                                                MbPartWidth <= 4;
                                                                MbPartHeight <= 4;
                                                                SubMbPartNum <= 4;
                                                            end
                                                        default:
                                                            begin 
                                                                MbPartWidth <= 0;
                                                                MbPartHeight <= 0;
                                                                SubMbPartNum <= 0;
                                                            end
                                                    endcase                                                    
                                                end
                                            else
                                                begin
                                                    sub_mb_pred_state <= `rst_sub_mb_pred;
                                                    mbPartIdx <= 0;
                                                    if ( mb_pred_mode_comb != `mb_pred_mode_I16MB )
                                                        begin
                                                            slice_data_state <= `coded_block_pattern_s;
                                                            if ( mb_pred_mode_comb == `mb_pred_mode_I4MB )
                                                                exp_golomb_decoding_me_intra4x4_out <= 1;
                                                            else // inter
                                                                exp_golomb_decoding_me_intra4x4_out <= 0;
                                                        end
                                                    else if (CBP_luma_reg || CBP_chroma_reg || mb_pred_mode_comb == `mb_pred_mode_I16MB)
                                                        slice_data_state <= `mb_qp_delta_s;
                                                    else
                                                        begin
                                                            slice_data_state <= `residual; 
                                                            residual_state <= `rst_residual;
                                                        end
                                                end
                                        end
                                end
                            default : sub_mb_pred_state <= `rst_sub_mb_pred;
                        endcase  //  case(sub_mb_pred_state)
                        
                    `store_to_fpga_ram: 
                        begin
                            fpga_ram_intra4x4_pred_mode_wr_n <= 0;
                            fpga_ram_ref_idx_wr_n <= 0;
                            fpga_ram_mvx_wr_n <= 0;
                            fpga_ram_mvy_wr_n <= 0;
                            fpga_ram_nnz_wr_n <= 0;
                            fpga_ram_nnz_cb_wr_n <= 0;
                            fpga_ram_nnz_cr_wr_n <= 0;
                            
                            
                            fpga_ram_intra4x4_pred_mode_addr <= mb_x_out;
                            fpga_ram_ref_idx_addr <= mb_x_out;
                            fpga_ram_mvx_addr <= mb_x_out;
                            fpga_ram_mvy_addr <= mb_x_out;
                            fpga_ram_nnz_addr <= mb_x_out;
                            fpga_ram_nnz_cb_addr <= mb_x_out;
                            fpga_ram_nnz_cr_addr <= mb_x_out;
                            
                            
                            fpga_ram_qp_addr <= mb_x_out;
                            fpga_ram_qp_c_addr <= mb_x_out;
                            fpga_ram_qp_data_in <= qp;
                            fpga_ram_qp_c_data_in <= qp_c;
                            
                            fpga_ram_intra4x4_pred_mode_data_in <= {intra4x4_pred_mode_curr_mb_out[63:60],
                                                                    intra4x4_pred_mode_curr_mb_out[59:56],
                                                                    intra4x4_pred_mode_curr_mb_out[47:44],
                                                                    intra4x4_pred_mode_curr_mb_out[43:40]
                                                                    }; // 10,11,14,15

                            fpga_ram_ref_idx_data_in[5:0] <= ref_idx_l0_curr_mb_out[11:6];
                            if( mb_skip_run > 0 ) //temporary
                                begin
                                    fpga_ram_mvx_data_in <= {mvx_l0, mvx_l0, 
                                                             mvx_l0, mvx_l0};     
                                    fpga_ram_mvy_data_in <= {mvy_l0,mvy_l0 , 
                                                             mvy_l0, mvy_l0};                                
                                end
                            else
                                begin
                                    fpga_ram_mvx_data_in <= {mvx_l0_curr_mb_out[255:240], 
                                                             mvx_l0_curr_mb_out[239:224], 
                                                             mvx_l0_curr_mb_out[191:176],
                                                             mvx_l0_curr_mb_out[175:160]
                                                             };     
                                    fpga_ram_mvy_data_in <= {mvy_l0_curr_mb_out[255:240], 
                                                             mvy_l0_curr_mb_out[239:224], 
                                                             mvy_l0_curr_mb_out[191:176],
                                                             mvy_l0_curr_mb_out[175:160]
                                                             };                                
                                end

                            
                            fpga_ram_nnz_data_in <= {nC_curr_mb_out[127:120], nC_curr_mb_out[119:112],
                                                     nC_curr_mb_out[95:88], nC_curr_mb_out[87:80]};
                            fpga_ram_nnz_cb_data_in <= {nC_cb_curr_mb_out[31:24], nC_cb_curr_mb_out[23:16]};
                            fpga_ram_nnz_cr_data_in <= {nC_cr_curr_mb_out[31:24], nC_cr_curr_mb_out[23:16]};
                            
                            intra_mode[mb_x_out] <= mb_pred_mode_comb == `mb_pred_mode_I4MB || mb_pred_mode_comb == `mb_pred_mode_I16MB ? 1 : 0;
                            
                            slice_data_state <= `mb_num_update;
                        end

                    `mb_num_update:
                       begin
                            mb_pred_state <= `rst_mb_pred;
                            mb_index_out <= mb_index_out + 1;
                            if ( mb_skip_run > 0) // the macroblock immediately follows the last P_skip macroblock is still in P_skip_mode
                                begin
                                    mb_skip_run <= mb_skip_run - 1;
                                    P_skip_mode <= 1;
                                    MbPartWidth <= 16;
                                    MbPartHeight <= 16;
                                    luma4x4BlkIdx_out <= 0;
                                end
                            else
                                begin
                                    P_skip_mode <= 0;
                                end                                          
                            if (mb_x_out == pic_width_in_mbs_minus1_sps_in)
                                begin
                                    mb_x_out <= 0;
                                    if (mb_y_out == pic_height_in_map_units_minus1_sps_in)
                                        begin
                                            mb_index_out <= 0;
                                            mb_y_out <= 0; // end of a slice parsing
                                            slice_data_state <= `rbsp_trailing_bits_slice_data;
                                            P_skip_mode <= 0;
                                        end
                                    /*
                                    //for test
                                    //synthesis translate_off
                                    if (mb_y_out == 0)//pic_height_in_map_units_minus1_sps_in)
                                        begin
                                            mb_index_out <= 0;
                                            mb_y_out <= 0; // end of a slice parsing
                                            slice_data_state <= `rbsp_trailing_bits_slice_data;
                                            P_skip_mode <= 0;
                                        end
                                    //synthesis translate_on
                                    */
                                    else
                                        begin
                                            mb_y_out <= mb_y_out + 1;
                                            slice_data_state <= `rst_slice_data;
                                        end
                                end
                            else
                                begin
                                    mb_x_out <= mb_x_out + 1;
                                    slice_data_state <= `rst_slice_data;
                                end 
                            //if(mb_x_out==pic_width_in_mbs_minus1_sps_in &&
                            //   mb_y_out==pic_height_in_map_units_minus1_sps_in)
                            //    slice_data_state <= `rbsp_trailing_bits_slice_data;
                            //else 
                            //    slice_data_state <= `rst_slice_data;
                        end
                    `rbsp_trailing_bits_slice_data:
                        slice_data_state <= `slice_data_end;
                        
                        
                    default: slice_data_state <= `rst_slice_data;
                endcase    
        end        



always @(posedge clk)
if(ena) 
	if (slice_data_state == `mb_type_s) begin
        mvx_l0_curr_mb_out <= 128'b0; 
    end
    else if ((slice_data_state == `mb_pred && mb_pred_state == `mvdx_l0_s) 
        || (slice_data_state == `sub_mb_pred && sub_mb_pred_state == `sub_mvdx_l0_s) 
        || (slice_data_state == `store_to_fpga_ram && mb_skip_run > 0) )
        if (MbPartWidth == 16 && MbPartHeight == 16)
            if ( slice_data_state == `store_to_fpga_ram && mb_skip_run > 0 ) //temporary
                begin
                    mvx_l0_curr_mb_out[255:0]    <= {16{mvx_l0}}; 
                end
            else
                begin
                    mvx_l0_curr_mb_out[15:0]    <= exp_golomb_decoding_output_se_in + mvpx_l0_in; 
                    mvx_l0_curr_mb_out[31:16]   <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                    mvx_l0_curr_mb_out[47:32]   <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                    mvx_l0_curr_mb_out[63:48]   <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                    mvx_l0_curr_mb_out[79:64]   <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                    mvx_l0_curr_mb_out[95:80]   <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                    mvx_l0_curr_mb_out[111:96]  <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                    mvx_l0_curr_mb_out[127:112] <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                    mvx_l0_curr_mb_out[143:128] <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                    mvx_l0_curr_mb_out[159:144] <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                    mvx_l0_curr_mb_out[175:160] <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                    mvx_l0_curr_mb_out[191:176] <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                    mvx_l0_curr_mb_out[207:192] <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                    mvx_l0_curr_mb_out[223:208] <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                    mvx_l0_curr_mb_out[239:224] <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                    mvx_l0_curr_mb_out[255:240] <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                end            
        else if (MbPartWidth == 16 && MbPartHeight == 8)
            if (mbPartIdx == 0)                
                begin
                    mvx_l0_curr_mb_out[15:0]     <= exp_golomb_decoding_output_se_in + mvpx_l0_in; 
                    mvx_l0_curr_mb_out[31:16]   <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                    mvx_l0_curr_mb_out[47:32]   <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                    mvx_l0_curr_mb_out[63:48]   <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                    mvx_l0_curr_mb_out[79:64]   <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                    mvx_l0_curr_mb_out[95:80]   <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                    mvx_l0_curr_mb_out[111:96]   <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                    mvx_l0_curr_mb_out[127:112]   <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                end                
            else //mbPartIdx = 1
                begin
                    mvx_l0_curr_mb_out[143:128]   <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                    mvx_l0_curr_mb_out[159:144]   <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                    mvx_l0_curr_mb_out[175:160] <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                    mvx_l0_curr_mb_out[191:176] <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                    mvx_l0_curr_mb_out[207:192]<= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                    mvx_l0_curr_mb_out[223:208] <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                    mvx_l0_curr_mb_out[239:224] <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                    mvx_l0_curr_mb_out[255:240] <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                end
        else if (MbPartWidth == 8 && MbPartHeight == 16)
            if (mbPartIdx == 0)
                begin
                    mvx_l0_curr_mb_out[15:0]     <= exp_golomb_decoding_output_se_in + mvpx_l0_in; 
                    mvx_l0_curr_mb_out[31:16]    <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                    mvx_l0_curr_mb_out[47:32]   <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                    mvx_l0_curr_mb_out[63:48]   <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                    mvx_l0_curr_mb_out[143:128]   <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                    mvx_l0_curr_mb_out[159:144]   <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                    mvx_l0_curr_mb_out[175:160]   <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                    mvx_l0_curr_mb_out[191:176]   <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                end          
            else //mbPartIdx = 1                
                begin
                    mvx_l0_curr_mb_out[79:64]   <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                    mvx_l0_curr_mb_out[95:80]   <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                    mvx_l0_curr_mb_out[111:96]   <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                    mvx_l0_curr_mb_out[127:112]   <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                    mvx_l0_curr_mb_out[207:192]<= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                    mvx_l0_curr_mb_out[223:208] <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                    mvx_l0_curr_mb_out[239:224] <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                    mvx_l0_curr_mb_out[255:240] <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                end
        else if( MbPartWidth == 8 && MbPartHeight == 8)
            case(mbPartIdx)
                0:
                    begin
                        mvx_l0_curr_mb_out[15:0]     <= exp_golomb_decoding_output_se_in + mvpx_l0_in; 
                        mvx_l0_curr_mb_out[31:16]    <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                        mvx_l0_curr_mb_out[47:32]   <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                        mvx_l0_curr_mb_out[63:48]   <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                    end
                1:
                    begin
                        mvx_l0_curr_mb_out[79:64]   <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                        mvx_l0_curr_mb_out[95:80]   <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                        mvx_l0_curr_mb_out[111:96]   <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                        mvx_l0_curr_mb_out[127:112]   <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                    end
                2:
                    begin
                        mvx_l0_curr_mb_out[143:128]   <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                        mvx_l0_curr_mb_out[159:144]   <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                        mvx_l0_curr_mb_out[175:160] <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                        mvx_l0_curr_mb_out[191:176] <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                    end
                3:                   
                    begin
                        mvx_l0_curr_mb_out[207:192] <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                        mvx_l0_curr_mb_out[223:208] <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                        mvx_l0_curr_mb_out[239:224] <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                        mvx_l0_curr_mb_out[255:240] <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                    end
                default: mvx_l0_curr_mb_out <= 0;
            endcase  
        else if (MbPartWidth == 8 && MbPartHeight == 4)
            case(mbPartIdx)
                0:
                    if (subMbPartIdx == 0)
                        begin
                            mvx_l0_curr_mb_out[15:0]     <= exp_golomb_decoding_output_se_in + mvpx_l0_in; 
                            mvx_l0_curr_mb_out[31:16]   <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                        end     
                    else // subMbPartIdx = 1
                        begin
                            mvx_l0_curr_mb_out[47:32]   <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                            mvx_l0_curr_mb_out[63:48]   <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                        end                   
                1:
                    if (subMbPartIdx == 0)
                        begin
                            mvx_l0_curr_mb_out[79:64]   <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                            mvx_l0_curr_mb_out[95:80]   <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                        end                        
                    else //subMbPartIdx = 1
                        begin
                            mvx_l0_curr_mb_out[111:96]   <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                            mvx_l0_curr_mb_out[127:112]   <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                        end
                        
                2:
                    if (subMbPartIdx == 0)
                        begin
                            mvx_l0_curr_mb_out[143:128]   <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                            mvx_l0_curr_mb_out[159:144]   <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                        end
                    else //subMbPartIdx = 1
                        begin
                            mvx_l0_curr_mb_out[175:160] <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                            mvx_l0_curr_mb_out[191:176] <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                        end

                3:
                    if (subMbPartIdx == 0)
                        begin
                            mvx_l0_curr_mb_out[207:192]<= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                            mvx_l0_curr_mb_out[223:208] <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                        end
                    else //subMbPartIdx = 1
                        begin
                            mvx_l0_curr_mb_out[239:224] <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                            mvx_l0_curr_mb_out[255:240] <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                        end
            endcase             
        else if (MbPartWidth == 4 && MbPartHeight == 8)
            case(mbPartIdx)
                0:
                    if (subMbPartIdx == 0)
                        begin
                            mvx_l0_curr_mb_out[15:0]     <= exp_golomb_decoding_output_se_in + mvpx_l0_in; 
                            mvx_l0_curr_mb_out[47:32]   <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                        end
                    else //subMbPartIdx = 1
                        begin
                            mvx_l0_curr_mb_out[31:16]   <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                            mvx_l0_curr_mb_out[63:48]   <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                        end
                1:
                    if (subMbPartIdx == 0)
                        begin
                            mvx_l0_curr_mb_out[79:64]   <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                            mvx_l0_curr_mb_out[111:96]   <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                        end
                    else //subMbPartIdx = 1
                        begin
                            mvx_l0_curr_mb_out[95:80]   <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                            mvx_l0_curr_mb_out[127:112]   <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                        end
                2:
                    if (subMbPartIdx == 0)
                        begin
                            mvx_l0_curr_mb_out[143:128]   <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                            mvx_l0_curr_mb_out[175:160] <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                        end    
                    else //subMbPartIdx = 1
                        begin
                            mvx_l0_curr_mb_out[159:144]   <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                            mvx_l0_curr_mb_out[191:176] <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                        end
                3:
                    if (subMbPartIdx == 0)
                        begin
                            mvx_l0_curr_mb_out[207:192]<= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                            mvx_l0_curr_mb_out[239:224] <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                        end    
                    else //subMbPartIdx = 1
                        begin
                            mvx_l0_curr_mb_out[223:208] <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                            mvx_l0_curr_mb_out[255:240] <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                        end
                
            endcase             
        else // MbPartWidth = 4, MbPartHeight = 4
            case(mbPartIdx)
                0:
                    if (subMbPartIdx == 0)
                        mvx_l0_curr_mb_out[15:0]     <= exp_golomb_decoding_output_se_in + mvpx_l0_in; 
                    else if (subMbPartIdx == 1)
                        mvx_l0_curr_mb_out[31:16]   <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                    else if (subMbPartIdx == 2)
                        mvx_l0_curr_mb_out[47:32]   <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                    else //subMbPartIdx = 3
                        mvx_l0_curr_mb_out[63:48]   <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                1:
                    if (subMbPartIdx == 0)
                        mvx_l0_curr_mb_out[79:64]   <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                    else if (subMbPartIdx == 1)
                        mvx_l0_curr_mb_out[95:80]   <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                    else if (subMbPartIdx == 2)
                        mvx_l0_curr_mb_out[111:96]   <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                    else //subMbPartIdx = 3
                        mvx_l0_curr_mb_out[127:112]   <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                2:
                    if (subMbPartIdx == 0)
                        mvx_l0_curr_mb_out[143:128]   <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                    else if (subMbPartIdx == 1)
                        mvx_l0_curr_mb_out[159:144]   <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                    else if (subMbPartIdx == 2)
                        mvx_l0_curr_mb_out[175:160] <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                    else //subMbPartIdx = 3
                        mvx_l0_curr_mb_out[191:176] <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                3:
                    if (subMbPartIdx == 0)
                        mvx_l0_curr_mb_out[207:192]<= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                    else if (subMbPartIdx == 1)
                        mvx_l0_curr_mb_out[223:208] <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                    else if (subMbPartIdx == 2)
                        mvx_l0_curr_mb_out[239:224] <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
                    else //subMbPartIdx = 3
                        mvx_l0_curr_mb_out[255:240] <= exp_golomb_decoding_output_se_in + mvpx_l0_in;
               
            endcase

always @(*)
if (slice_data_state == `p_skip_s)
	mvx_l0_curr_4x4blk <= mvx_l0;
else if (slice_data_state == `residual && (
		 residual_state == `LumaLevel_0_s ||
		 residual_state == `LumaLevel_s ||
		 residual_state == `Intra16x16ACLevel_s ||
		 residual_state == `Intra16x16ACLevel_0_s))
	case(luma4x4BlkIdx_out)
	0: mvx_l0_curr_4x4blk <= mvx_l0_curr_mb_out[15:0];
	1: mvx_l0_curr_4x4blk <= mvx_l0_curr_mb_out[31:16];
	2: mvx_l0_curr_4x4blk <= mvx_l0_curr_mb_out[47:32];
	3: mvx_l0_curr_4x4blk <= mvx_l0_curr_mb_out[63:48];
	4: mvx_l0_curr_4x4blk <= mvx_l0_curr_mb_out[79:64];
	5: mvx_l0_curr_4x4blk <= mvx_l0_curr_mb_out[95:80];
	6: mvx_l0_curr_4x4blk <= mvx_l0_curr_mb_out[111:96];
	7: mvx_l0_curr_4x4blk <= mvx_l0_curr_mb_out[127:112];
	8: mvx_l0_curr_4x4blk <= mvx_l0_curr_mb_out[143:128];
	9: mvx_l0_curr_4x4blk <= mvx_l0_curr_mb_out[159:144];
	10:mvx_l0_curr_4x4blk <= mvx_l0_curr_mb_out[175:160];
	11:mvx_l0_curr_4x4blk <= mvx_l0_curr_mb_out[191:176];
	12:mvx_l0_curr_4x4blk <= mvx_l0_curr_mb_out[207:192];
	13:mvx_l0_curr_4x4blk <= mvx_l0_curr_mb_out[223:208];
	14:mvx_l0_curr_4x4blk <= mvx_l0_curr_mb_out[239:224];
	15:mvx_l0_curr_4x4blk <= mvx_l0_curr_mb_out[255:240];
	default:mvx_l0_curr_4x4blk <= 'bx;
	endcase
else if (slice_data_state == `residual && (
		residual_state == `ChromaACLevel_Cb_s ||
		residual_state == `ChromaACLevel_Cb_0_s ||
		residual_state == `ChromaACLevel_Cr_s ||
		residual_state == `ChromaACLevel_Cr_0_s))
	case (chroma4x4BlkIdx_out)
	0:mvx_l0_curr_4x4blk <= mvx_l0_curr_mb_out[15:0];
	1:mvx_l0_curr_4x4blk <= mvx_l0_curr_mb_out[79:64];
	2:mvx_l0_curr_4x4blk <= mvx_l0_curr_mb_out[143:128];
	3:mvx_l0_curr_4x4blk <= mvx_l0_curr_mb_out[207:192];
	default:mvx_l0_curr_4x4blk <= 'bx;
	endcase
else
	mvx_l0_curr_4x4blk <= 'bx;
	
	
always @(posedge clk)
if(ena)
	if (slice_data_state == `mb_type_s) begin
        mvy_l0_curr_mb_out <= 128'b0; 
    end
    else if ((slice_data_state == `mb_pred && mb_pred_state == `mvdy_l0_s) 
        || (slice_data_state == `sub_mb_pred && sub_mb_pred_state == `sub_mvdy_l0_s)  
        || (slice_data_state == `store_to_fpga_ram && mb_skip_run > 0))
        if (MbPartWidth == 16 && MbPartHeight == 16)
            if(slice_data_state == `store_to_fpga_ram && mb_skip_run > 0)//temporary
                begin               
                    mvy_l0_curr_mb_out[15:0]     <= mvy_l0; 
                    mvy_l0_curr_mb_out[31:16]    <= mvy_l0;
                    mvy_l0_curr_mb_out[47:32]   <= mvy_l0;
                    mvy_l0_curr_mb_out[63:48]   <= mvy_l0;
                    mvy_l0_curr_mb_out[79:64]   <= mvy_l0;
                    mvy_l0_curr_mb_out[95:80]   <= mvy_l0;
                    mvy_l0_curr_mb_out[111:96]   <= mvy_l0;
                    mvy_l0_curr_mb_out[127:112]   <= mvy_l0;
                    mvy_l0_curr_mb_out[143:128]   <= mvy_l0;
                    mvy_l0_curr_mb_out[159:144]   <= mvy_l0;
                    mvy_l0_curr_mb_out[175:160]   <= mvy_l0;
                    mvy_l0_curr_mb_out[191:176]   <= mvy_l0;
                    mvy_l0_curr_mb_out[207:192] <= mvy_l0;
                    mvy_l0_curr_mb_out[223:208] <= mvy_l0;
                    mvy_l0_curr_mb_out[239:224] <= mvy_l0;
                    mvy_l0_curr_mb_out[255:240] <= mvy_l0;
                end
            else
                begin               
                    mvy_l0_curr_mb_out[15:0]     <= exp_golomb_decoding_output_se_in + mvpy_l0_in; 
                    mvy_l0_curr_mb_out[31:16]    <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                    mvy_l0_curr_mb_out[47:32]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                    mvy_l0_curr_mb_out[63:48]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                    mvy_l0_curr_mb_out[79:64]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                    mvy_l0_curr_mb_out[95:80]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                    mvy_l0_curr_mb_out[111:96]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                    mvy_l0_curr_mb_out[127:112]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                    mvy_l0_curr_mb_out[143:128]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                    mvy_l0_curr_mb_out[159:144]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                    mvy_l0_curr_mb_out[175:160]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                    mvy_l0_curr_mb_out[191:176]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                    mvy_l0_curr_mb_out[207:192] <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                    mvy_l0_curr_mb_out[223:208] <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                    mvy_l0_curr_mb_out[239:224] <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                    mvy_l0_curr_mb_out[255:240] <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                end                
        else if (MbPartWidth == 16 && MbPartHeight == 8)
            if (mbPartIdx == 0)                
                begin
                    mvy_l0_curr_mb_out[15:0]     <= exp_golomb_decoding_output_se_in + mvpy_l0_in; 
                    mvy_l0_curr_mb_out[31:16]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                    mvy_l0_curr_mb_out[47:32]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                    mvy_l0_curr_mb_out[63:48]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                    mvy_l0_curr_mb_out[79:64]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                    mvy_l0_curr_mb_out[95:80]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                    mvy_l0_curr_mb_out[111:96]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                    mvy_l0_curr_mb_out[127:112]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                end                
            else // mbPartIdx = 1
                begin
                    mvy_l0_curr_mb_out[143:128]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                    mvy_l0_curr_mb_out[159:144]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                    mvy_l0_curr_mb_out[175:160] <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                    mvy_l0_curr_mb_out[191:176] <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                    mvy_l0_curr_mb_out[207:192]<= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                    mvy_l0_curr_mb_out[223:208] <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                    mvy_l0_curr_mb_out[239:224] <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                    mvy_l0_curr_mb_out[255:240] <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                end
        else if (MbPartWidth == 8 && MbPartHeight == 16)
            if (mbPartIdx == 0)
                begin
                    mvy_l0_curr_mb_out[15:0]     <= exp_golomb_decoding_output_se_in + mvpy_l0_in; 
                    mvy_l0_curr_mb_out[31:16]    <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                    mvy_l0_curr_mb_out[47:32]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                    mvy_l0_curr_mb_out[63:48]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                    mvy_l0_curr_mb_out[143:128]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                    mvy_l0_curr_mb_out[159:144]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                    mvy_l0_curr_mb_out[175:160]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                    mvy_l0_curr_mb_out[191:176]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                end          
            else //mbPartIdx = 1                
                begin
                    mvy_l0_curr_mb_out[79:64]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                    mvy_l0_curr_mb_out[95:80]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                    mvy_l0_curr_mb_out[111:96]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                    mvy_l0_curr_mb_out[127:112]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                    mvy_l0_curr_mb_out[207:192]<= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                    mvy_l0_curr_mb_out[223:208] <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                    mvy_l0_curr_mb_out[239:224] <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                    mvy_l0_curr_mb_out[255:240] <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                end
        else if( MbPartWidth == 8 && MbPartHeight == 8)
            case(mbPartIdx)
                0:
                    begin
                        mvy_l0_curr_mb_out[15:0]     <= exp_golomb_decoding_output_se_in + mvpy_l0_in; 
                        mvy_l0_curr_mb_out[31:16]    <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                        mvy_l0_curr_mb_out[47:32]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                        mvy_l0_curr_mb_out[63:48]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                    end
                1:
                    begin
                        mvy_l0_curr_mb_out[79:64]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                        mvy_l0_curr_mb_out[95:80]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                        mvy_l0_curr_mb_out[111:96]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                        mvy_l0_curr_mb_out[127:112]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                    end
                2:
                    begin
                        mvy_l0_curr_mb_out[143:128]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                        mvy_l0_curr_mb_out[159:144]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                        mvy_l0_curr_mb_out[175:160] <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                        mvy_l0_curr_mb_out[191:176] <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                    end
                3:                   
                    begin
                        mvy_l0_curr_mb_out[207:192]<= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                        mvy_l0_curr_mb_out[223:208] <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                        mvy_l0_curr_mb_out[239:224] <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                        mvy_l0_curr_mb_out[255:240] <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                    end
            endcase  
        else if (MbPartWidth == 8 && MbPartHeight == 4)
            case(mbPartIdx)
                0:
                    if (subMbPartIdx == 0)
                        begin
                            mvy_l0_curr_mb_out[15:0]     <= exp_golomb_decoding_output_se_in + mvpy_l0_in; 
                            mvy_l0_curr_mb_out[31:16]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                        end     
                    else // subMbPartIdx = 1
                        begin
                            mvy_l0_curr_mb_out[47:32]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                            mvy_l0_curr_mb_out[63:48]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                        end                   
                1:
                    if (subMbPartIdx == 0)
                        begin
                            mvy_l0_curr_mb_out[79:64]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                            mvy_l0_curr_mb_out[95:80]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                        end                        
                    else //subMbPartIdx = 1
                        begin
                            mvy_l0_curr_mb_out[111:96]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                            mvy_l0_curr_mb_out[127:112]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                        end
                        
                2:
                    if (subMbPartIdx == 0)
                        begin
                            mvy_l0_curr_mb_out[143:128]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                            mvy_l0_curr_mb_out[159:144]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                        end
                    else //subMbPartIdx = 1
                        begin
                            mvy_l0_curr_mb_out[175:160] <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                            mvy_l0_curr_mb_out[191:176] <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                        end

                3:
                    if (subMbPartIdx == 0)
                        begin
                            mvy_l0_curr_mb_out[207:192]<= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                            mvy_l0_curr_mb_out[223:208] <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                        end
                    else //subMbPartIdx = 1
                        begin
                            mvy_l0_curr_mb_out[239:224] <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                            mvy_l0_curr_mb_out[255:240] <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                        end
            endcase
        else if (MbPartWidth == 4 && MbPartHeight == 8)
            case(mbPartIdx)
                0:
                    if (subMbPartIdx == 0)
                        begin
                            mvy_l0_curr_mb_out[15:0]     <= exp_golomb_decoding_output_se_in + mvpy_l0_in; 
                            mvy_l0_curr_mb_out[47:32]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                        end
                    else //subMbPartIdx = 1
                        begin
                            mvy_l0_curr_mb_out[31:16]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                            mvy_l0_curr_mb_out[63:48]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                        end
                1:
                    if (subMbPartIdx == 0)
                        begin
                            mvy_l0_curr_mb_out[79:64]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                            mvy_l0_curr_mb_out[111:96]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                        end
                    else //subMbPartIdx = 1
                        begin
                            mvy_l0_curr_mb_out[95:80]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                            mvy_l0_curr_mb_out[127:112]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                        end
                2:
                    if (subMbPartIdx == 0)
                        begin
                            mvy_l0_curr_mb_out[143:128]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                            mvy_l0_curr_mb_out[175:160] <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                        end    
                    else //subMbPartIdx = 1
                        begin
                            mvy_l0_curr_mb_out[159:144]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                            mvy_l0_curr_mb_out[191:176] <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                        end
                3:
                    if (subMbPartIdx == 0)
                        begin
                            mvy_l0_curr_mb_out[207:192]<= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                            mvy_l0_curr_mb_out[239:224] <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                        end    
                    else //subMbPartIdx = 1
                        begin
                            mvy_l0_curr_mb_out[223:208] <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                            mvy_l0_curr_mb_out[255:240] <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                        end
                
            endcase             
        else // MbPartWidth = 4, MbPartHeight = 4
            case(mbPartIdx)
                0:
                    if (subMbPartIdx == 0)
                        mvy_l0_curr_mb_out[15:0]     <= exp_golomb_decoding_output_se_in + mvpy_l0_in; 
                    else if (subMbPartIdx == 1)
                        mvy_l0_curr_mb_out[31:16]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                    else if (subMbPartIdx == 2)
                        mvy_l0_curr_mb_out[47:32]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                    else //subMbPartIdx = 3
                        mvy_l0_curr_mb_out[63:48]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                1:
                    if (subMbPartIdx == 0)
                        mvy_l0_curr_mb_out[79:64]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                    else if (subMbPartIdx == 1)
                        mvy_l0_curr_mb_out[95:80]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                    else if (subMbPartIdx == 2)
                        mvy_l0_curr_mb_out[111:96]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                    else //subMbPartIdx = 3
                        mvy_l0_curr_mb_out[127:112]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                2:
                    if (subMbPartIdx == 0)
                        mvy_l0_curr_mb_out[143:128]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                    else if (subMbPartIdx == 1)
                        mvy_l0_curr_mb_out[159:144]   <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                    else if (subMbPartIdx == 2)
                        mvy_l0_curr_mb_out[175:160] <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                    else //subMbPartIdx = 3
                        mvy_l0_curr_mb_out[191:176] <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                3:
                    if (subMbPartIdx == 0)
                        mvy_l0_curr_mb_out[207:192]<= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                    else if (subMbPartIdx == 1)
                        mvy_l0_curr_mb_out[223:208] <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                    else if (subMbPartIdx == 2)
                        mvy_l0_curr_mb_out[239:224] <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
                    else //subMbPartIdx = 3
                        mvy_l0_curr_mb_out[255:240] <= exp_golomb_decoding_output_se_in + mvpy_l0_in;
               
            endcase
            
always @(*)
if (slice_data_state == `p_skip_s)
	mvy_l0_curr_4x4blk <= mvy_l0;
else if (slice_data_state == `residual && (
		 residual_state == `LumaLevel_0_s ||
		 residual_state == `LumaLevel_s ||
		 residual_state == `Intra16x16ACLevel_s ||
		 residual_state == `Intra16x16ACLevel_0_s))
	case(luma4x4BlkIdx_out)
	0: mvy_l0_curr_4x4blk <= mvy_l0_curr_mb_out[15:0];
	1: mvy_l0_curr_4x4blk <= mvy_l0_curr_mb_out[31:16];
	2: mvy_l0_curr_4x4blk <= mvy_l0_curr_mb_out[47:32];
	3: mvy_l0_curr_4x4blk <= mvy_l0_curr_mb_out[63:48];
	4: mvy_l0_curr_4x4blk <= mvy_l0_curr_mb_out[79:64];
	5: mvy_l0_curr_4x4blk <= mvy_l0_curr_mb_out[95:80];
	6: mvy_l0_curr_4x4blk <= mvy_l0_curr_mb_out[111:96];
	7: mvy_l0_curr_4x4blk <= mvy_l0_curr_mb_out[127:112];
	8: mvy_l0_curr_4x4blk <= mvy_l0_curr_mb_out[143:128];
	9: mvy_l0_curr_4x4blk <= mvy_l0_curr_mb_out[159:144];
	10:mvy_l0_curr_4x4blk <= mvy_l0_curr_mb_out[175:160];
	11:mvy_l0_curr_4x4blk <= mvy_l0_curr_mb_out[191:176];
	12:mvy_l0_curr_4x4blk <= mvy_l0_curr_mb_out[207:192];
	13:mvy_l0_curr_4x4blk <= mvy_l0_curr_mb_out[223:208];
	14:mvy_l0_curr_4x4blk <= mvy_l0_curr_mb_out[239:224];
	15:mvy_l0_curr_4x4blk <= mvy_l0_curr_mb_out[255:240];
	default:mvy_l0_curr_4x4blk <= 'bx;
	endcase
else if (slice_data_state == `residual && (
		residual_state == `ChromaACLevel_Cb_s ||
		residual_state == `ChromaACLevel_Cb_0_s ||
		residual_state == `ChromaACLevel_Cr_s ||
		residual_state == `ChromaACLevel_Cr_0_s))
	case (chroma4x4BlkIdx_out)
	0:mvy_l0_curr_4x4blk <= mvy_l0_curr_mb_out[15:0];
	1:mvy_l0_curr_4x4blk <= mvy_l0_curr_mb_out[79:64];
	2:mvy_l0_curr_4x4blk <= mvy_l0_curr_mb_out[143:128];
	3:mvy_l0_curr_4x4blk <= mvy_l0_curr_mb_out[207:192];
	default:mvy_l0_curr_4x4blk <= 'bx;
	endcase
else
	mvy_l0_curr_4x4blk <= 'bx;
	
always @(*)
if (slice_data_state == `residual && (
		 residual_state == `LumaLevel_0_s ||
		 residual_state == `LumaLevel_s ||
		 residual_state == `Intra16x16ACLevel_s ||
		 residual_state == `Intra16x16ACLevel_0_s))
	case (luma4x4BlkIdx_out)
	0, 1, 2, 3  :ref_idx_l0_curr_blk4x4 <= ref_idx_l0_curr_mb_out[2:0];
	4, 5, 6, 7  :ref_idx_l0_curr_blk4x4 <= ref_idx_l0_curr_mb_out[5:3];
	8, 9,10,11  :ref_idx_l0_curr_blk4x4 <= ref_idx_l0_curr_mb_out[8:6];
	12,13,14,15 :ref_idx_l0_curr_blk4x4 <= ref_idx_l0_curr_mb_out[11:9];
	default:ref_idx_l0_curr_blk4x4 <= 'bx;
	endcase
else if (slice_data_state == `residual && (
		residual_state == `ChromaACLevel_Cb_s ||
		residual_state == `ChromaACLevel_Cb_0_s ||
		residual_state == `ChromaACLevel_Cr_s ||
		residual_state == `ChromaACLevel_Cr_0_s))
	case (chroma4x4BlkIdx_out)
	0:ref_idx_l0_curr_blk4x4 <= ref_idx_l0_curr_mb_out[2:0]; 
	1:ref_idx_l0_curr_blk4x4 <= ref_idx_l0_curr_mb_out[5:3]; 
	2:ref_idx_l0_curr_blk4x4 <= ref_idx_l0_curr_mb_out[8:6]; 
	3:ref_idx_l0_curr_blk4x4 <= ref_idx_l0_curr_mb_out[11:9];
	default:ref_idx_l0_curr_blk4x4 <= 'bx;
	endcase
else
	ref_idx_l0_curr_blk4x4 <= 'bx;
	
reg signed [`mb_x_bits + 6:0] ref_x_tmp;
reg signed [`mb_y_bits + 6:0] ref_y_tmp;

always @(*)
if (blk4x4_counter < 16) begin
	ref_x_tmp <= {1'b0, mb_x_out * 64 + luma4x4BlkIdx_x_out * 16};
	ref_y_tmp <= {1'b0, mb_y_out * 64 + luma4x4BlkIdx_y_out * 16};
end
else begin
	ref_x_tmp <= {1'b0, mb_x_out * 64 + chroma4x4BlkIdx_out[0] * 32};
	ref_y_tmp <= {1'b0, mb_y_out * 64 + chroma4x4BlkIdx_out[1] * 32}; 
end

always @(*)
begin
	  ref_x_comb <= ref_x_tmp + mvx_l0_curr_4x4blk;
	  ref_y_comb <= ref_y_tmp + mvy_l0_curr_4x4blk;
end	

always @(posedge clk)
    if (slice_data_state == `residual && (residual_state == `Intra16x16ACLevel_s ||
                                          residual_state == `LumaLevel_s)
        && residual_started == 1 && residual_valid == 1)        
        case(luma4x4BlkIdx_out)
            0:  nC_curr_mb_out[7:0] <= TotalCoeff;
            1:  nC_curr_mb_out[15:8] <= TotalCoeff;
            2:  nC_curr_mb_out[23:16] <= TotalCoeff;
            3:  nC_curr_mb_out[31:24] <= TotalCoeff;
            4:  nC_curr_mb_out[39:32] <= TotalCoeff;
            5:  nC_curr_mb_out[47:40] <= TotalCoeff;
            6:  nC_curr_mb_out[55:48] <= TotalCoeff;
            7:  nC_curr_mb_out[63:56] <= TotalCoeff;
            8:  nC_curr_mb_out[71:64] <= TotalCoeff;
            9:  nC_curr_mb_out[79:72] <= TotalCoeff;
            10: nC_curr_mb_out[87:80] <= TotalCoeff;
            11: nC_curr_mb_out[95:88] <= TotalCoeff;
            12: nC_curr_mb_out[103:96] <= TotalCoeff;
            13: nC_curr_mb_out[111:104] <= TotalCoeff;
            14: nC_curr_mb_out[119:112] <= TotalCoeff;
            15: nC_curr_mb_out[127:120] <= TotalCoeff;
        endcase
    else if (slice_data_state == `residual && (residual_state == `Intra16x16ACLevel_0_s || 
                                               residual_state == `LumaLevel_0_s))
        case(luma4x4BlkIdx_out)
            0:  nC_curr_mb_out[31:0] <= 0;
            4:  nC_curr_mb_out[63:32] <= 0;
            8:  nC_curr_mb_out[95:64] <= 0;
            12: nC_curr_mb_out[127:96] <= 0;
        endcase
    else if (slice_data_state == `residual &&  residual_state == `ChromaACLevel_Cb_s && 
        residual_started == 1 && residual_valid == 1)
        case(chroma4x4BlkIdx_out)
            0: nC_cb_curr_mb_out[7:0] <= TotalCoeff;
            1: nC_cb_curr_mb_out[15:8] <= TotalCoeff;
            2: nC_cb_curr_mb_out[23:16] <= TotalCoeff;
            3: nC_cb_curr_mb_out[31:24] <= TotalCoeff;      
        endcase
   else if (slice_data_state == `residual && residual_state == `ChromaACLevel_Cr_s &&
        residual_started == 1 && residual_valid == 1)
        case(chroma4x4BlkIdx_out)
            0: nC_cr_curr_mb_out[7:0] <= TotalCoeff;
            1: nC_cr_curr_mb_out[15:8] <= TotalCoeff;
            2: nC_cr_curr_mb_out[23:16] <= TotalCoeff;
            3: nC_cr_curr_mb_out[31:24] <= TotalCoeff;      
        endcase
    else if (slice_data_state == `residual && (residual_state == `ChromaACLevel_Cb_0_s || residual_state == `ChromaACLevel_Cr_0_s))
        begin nC_cb_curr_mb_out[31:0] <= 0;   nC_cr_curr_mb_out[31:0] <= 0; end
    else if (slice_data_state == `mb_qp_delta_s && CBP_luma_reg == 0 && CBP_chroma_reg == 0 && mb_pred_mode_comb != `mb_pred_mode_I16MB ||
    slice_data_state == `skip_run_duration)
        begin
            nC_curr_mb_out <= 0;
            nC_cb_curr_mb_out <= 0;
            nC_cr_curr_mb_out <= 0;
        end

endmodule