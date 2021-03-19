//--------------------------------------------------------------------------------------------------
// Design    : bitstream_p
// Author(s) : qiu bin, shi tian qi
// Email     : chat1@126.com, tishi1@126.com
// Copyright (C) 2013 qiu bin 
// All rights reserved                
//-------------------------------------------------------------------------------------------------

`include "defines.v"

module decode_stream
(
	clk,
	rst_n,
	ena,
	
	num_cycles_1_frame,
	
	stream_mem_data_in,
	stream_mem_valid,
	stream_mem_addr_out,
	stream_mem_rd,
	stream_mem_end,

	ext_mem_init_done,
	ext_mem_burst,
	ext_mem_burst_len_minus1,
	ext_mem_addr,
	ext_mem_rd,
	ext_mem_wr,
	ext_mem_d,
	ext_mem_q,
	ext_mem_full,
	ext_mem_valid,
	ext_display_buf_mem_burst,
 	ext_display_buf_addr,
  
	pic_width_in_mbs,
	pic_height_in_map_units,
	start_of_frame,
	end_of_frame,
	pic_num
 
);
//global signals
input 									clk;
input 									rst_n;
input  									ena;

//num of clock cycles per frame
input [23:0]    						num_cycles_1_frame;

//interface to bitstream memory or fifo 
input  [7:0] 							stream_mem_data_in;
input           						stream_mem_valid;
output [31:0]							stream_mem_addr_out;
output 									stream_mem_rd; // request stream read by read_nalu
input 							        stream_mem_end; // end of stream reached

//interface to external buffer memory controller and display buffer
input									ext_mem_init_done;	
output									ext_mem_burst;
output [4:0]							ext_mem_burst_len_minus1;
output [`ext_buf_mem_addr_width-1:0]	ext_mem_addr;
output									ext_mem_rd;
output									ext_mem_wr;
output [`ext_buf_mem_data_width-1:0]	ext_mem_d;
input  [`ext_buf_mem_data_width-1:0]	ext_mem_q;
input									ext_mem_full;
input 									ext_mem_valid;
output                                  ext_display_buf_mem_burst;
output [`ext_buf_mem_addr_width-1:0]	ext_display_buf_addr;

//video parameters
output	[`mb_x_bits - 1:0]				pic_width_in_mbs;
output	[`mb_y_bits - 1:0]				pic_height_in_map_units;
output         							start_of_frame;
output									end_of_frame;
output	[9:0]							pic_num;

//for debug
/*
output  [4:0] sps_state;
output  [3:0] pps_state;
output  [4:0] slice_header_state;
output	[3:0] slice_data_state;
output  [4:0] forward_len;
output  rbsp_buffer_valid;
output	rd_req_by_rbsp_buffer;
output  [4:0]   nal_unit_type;
output  [1:0]   nal_ref_idc;
output       	forbidden_zero_bit;
output  [7:0]   rbsp_data;
output      	rbsp_valid;
*/
//
//read_nalu
//
wire            read_nalu_ena;
wire			rd_req_by_rbsp_buffer;
wire	[4:0]   nal_unit_type;
wire	[1:0]   nal_ref_idc;
wire        	forbidden_zero_bit;
wire	[7:0]   rbsp_data;
wire        	rbsp_valid;

read_nalu read_nalu_dut
(
    .clk(clk),
    .rst_n(rst_n),
    .ena(read_nalu_ena),
    .rd_req_by_rbsp_buffer_in(rd_req_by_rbsp_buffer), 
    .mem_data_in(stream_mem_data_in),
    .nal_unit_type(nal_unit_type),
    .nal_ref_idc(nal_ref_idc),
    .forbidden_zero_bit(forbidden_zero_bit),
    .stream_mem_addr(stream_mem_addr_out),
    .mem_rd_req_out(stream_mem_rd),
    .rbsp_data_out(rbsp_data),
    .rbsp_valid_out(rbsp_valid)
);


wire        rbsp_buffer_ena;
wire[4:0]   forward_len;
wire[23:0]  rbsp_out;
wire        rbsp_buffer_valid;

rbsp_buffer rbsp_buffer
(
    .clk(clk),
    .rst_n(rst_n),
    .ena(rbsp_buffer_ena),
    .rbsp_in(rbsp_data),
    .valid_data_of_nalu_in(rbsp_valid),
    .forward_len_in(forward_len),
    .rd_req_to_nalu_out(rd_req_by_rbsp_buffer),
    .rbsp_out(rbsp_out),
    .buffer_valid_out(rbsp_buffer_valid)
);



wire[11:0]  exp_golomb_decoding_output;
wire[11:0]  exp_golomb_decoding_output_se;
wire[9:0]   exp_golomb_decoding_output_te;
wire[4:0]   exp_golomb_decoding_len;
wire        exp_golomb_decoding_me_intra4x4; 
wire        exp_golomb_decoding_te_sel; 
wire[2:0]   num_ref_idx_l0_active_minus1;
wire[3:0]   CBP_luma;
wire[1:0]   CBP_chroma;

read_exp_golomb read_exp_golomb_dut
(
    .data_in(rbsp_out[23:1]),
    .max_in(num_ref_idx_l0_active_minus1),
    .read_te_sel(exp_golomb_decoding_te_sel),
    .intra4x4_in(exp_golomb_decoding_me_intra4x4), 
    .ue_out(exp_golomb_decoding_output),
    .se_out(exp_golomb_decoding_output_se),
    .te_out(exp_golomb_decoding_output_te),
    .CBP_luma_out(CBP_luma),
    .CBP_chroma_out(CBP_chroma),
    .length_out(exp_golomb_decoding_len)
);



wire[7:0]   read_bits_out;
wire[3:0]   read_bits_len;
wire        read_bits_enable;

read_bits read_bits_dut
(
    .en_in(1'b1),
    .data_in(rbsp_out[23:16]),
    .len_in(read_bits_len),
    .data_out(read_bits_out)
);     


wire pps_enable;
wire [7:0] pic_parameter_set_id;
wire [4:0] seq_parameter_set_id;
wire  entropy_coding_mode_flag;
wire  pic_order_present_flag;
wire [2:0] num_slice_groups_minus1;
wire [2:0] num_ref_idx_l0_active_minus1_pps;
wire [2:0] num_ref_idx_l1_active_minus1_pps;
wire  weighted_pred_flag;
wire [1:0] weighted_bipred_idc;
wire [5:0] pic_init_qp_minus26;
wire [5:0] pic_init_qs_minus26;
wire [4:0] chroma_qp_index_offset;
wire  deblocking_filter_control_present_flag;
wire  constrained_intra_pred_flag;
wire  redundant_pic_cnt_present_flag;
wire[3:0] pps_state;
wire[4:0] forward_len_pps;

pps pps_dut
(
.clk(clk),
.rst_n(rst_n),
.ena(pps_ena),
.rbsp_in(rbsp_out[23:21]),
 .exp_golomb_decoding_output_in(exp_golomb_decoding_output[7:0]),
 .exp_golomb_decoding_output_se_in(exp_golomb_decoding_output_se[7:0]),
 .exp_golomb_decoding_len_in(exp_golomb_decoding_len),
.pic_parameter_set_id(pic_parameter_set_id),
.seq_parameter_set_id(seq_parameter_set_id),
.entropy_coding_mode_flag(entropy_coding_mode_flag),
.pic_order_present_flag(pic_order_present_flag),
.num_slice_groups_minus1(num_slice_groups_minus1),
.num_ref_idx_l0_active_minus1(num_ref_idx_l0_active_minus1_pps),
.num_ref_idx_l1_active_minus1(num_ref_idx_l1_active_minus1_pps),
.weighted_pred_flag(weighted_pred_flag),
.weighted_bipred_idc(weighted_bipred_idc),
.pic_init_qp_minus26(pic_init_qp_minus26),
.pic_init_qs_minus26(pic_init_qs_minus26),
.chroma_qp_index_offset(chroma_qp_index_offset),
.deblocking_filter_control_present_flag(deblocking_filter_control_present_flag),
.constrained_intra_pred_flag(constrained_intra_pred_flag),
.redundant_pic_cnt_present_flag(redundant_pic_cnt_present_flag),
.pps_state(pps_state),
.forward_len_out(forward_len_pps)
);


wire sps_enable;
wire [7:0] profile_idc;
wire constraint_set0_flag;
wire constraint_set1_flag;
wire constraint_set2_flag;
wire constraint_set3_flag;
wire [3:0] reserved_zero_4bits;
wire [7:0] level_idc;
wire [4:0] seq_parameter_set_id_sps;
wire [4:0] chroma_format_idc;
wire [3:0] bit_depth_luma_minus8;
wire [3:0] bit_depth_chroma_minus8;
wire lossless_qpprime_y_zero_flag;
wire seq_scaling_matrix_present_flag;
wire [3:0] log2_max_frame_num_minus4;
wire [1:0] pic_order_cnt_type;
wire [3:0] log2_max_pic_order_cnt_lsb_minus4;
wire delta_pic_order_always_zero_flag;
wire[4:0] offset_for_non_ref_pic;
wire[4:0] offset_for_top_to_bottom_field;
wire[2:0] num_ref_frames_in_pic_order_cnt_cycle;
wire [2:0] num_ref_frames; 
wire gaps_in_frame_num_value_allowed_flag;
wire [`mb_x_bits - 1:0] pic_width_in_mbs_minus1; 
wire [`mb_y_bits - 1:0] pic_height_in_map_units_minus1;
wire [`mb_x_bits - 1:0] pic_width_in_mbs; 
wire [`mb_y_bits - 1:0] pic_height_in_map_units;
wire frame_mbs_only_flag;
wire direct_8x8_inference_flag;
wire frame_cropping_flag;
wire vui_parameters_present_flag;        
wire [4:0] sps_state;
wire[4:0] forward_len_sps;

sps sps_dut(
.clk(clk),
.rst_n(rst_n),
.ena(sps_ena),
.rbsp_in(rbsp_out[23:8]),
 .exp_golomb_decoding_output_in(exp_golomb_decoding_output[7:0]),
 .exp_golomb_decoding_len_in(exp_golomb_decoding_len),
 .exp_golomb_decoding_output_se_in(exp_golomb_decoding_output_se[7:0]),
 .profile_idc(profile_idc),
 .constraint_set0_flag(constraint_set0_flag),
 .constraint_set1_flag(constraint_set1_flag),
 .constraint_set2_flag(constraint_set2_flag),
 .constraint_set3_flag(constraint_set3_flag),
 .reserved_zero_4bits(reserved_zero_4bits),
 .level_idc(level_idc),
 .seq_parameter_set_id_sps(seq_parameter_set_id_sps),
 .chroma_format_idc(chroma_format_idc),
 .bit_depth_luma_minus8(bit_depth_luma_minus8),
 .bit_depth_chroma_minus8(bit_depth_chroma_minus8),
 .lossless_qpprime_y_zero_flag(lossless_qpprime_y_zero_flag),
 .seq_scaling_matrix_present_flag(seq_scaling_matrix_present_flag),
 .log2_max_frame_num_minus4(log2_max_frame_num_minus4),
 .pic_order_cnt_type(pic_order_cnt_type),
 .log2_max_pic_order_cnt_lsb_minus4(log2_max_pic_order_cnt_lsb_minus4),
 .delta_pic_order_always_zero_flag(delta_pic_order_always_zero_flag),
 .offset_for_non_ref_pic(offset_for_non_ref_pic),
 .offset_for_top_to_bottom_field(offset_for_top_to_bottom_field),
 .num_ref_frames_in_pic_order_cnt_cycle(num_ref_frames_in_pic_order_cnt_cycle),
 .num_ref_frames(num_ref_frames),
 .gaps_in_frame_num_value_allowed_flag(gaps_in_frame_num_value_allowed_flag),
 .pic_width_in_mbs_minus1(pic_width_in_mbs_minus1),
 .pic_height_in_map_units_minus1(pic_height_in_map_units_minus1),
 .pic_width_in_mbs(pic_width_in_mbs),
 .pic_height_in_map_units(pic_height_in_map_units),
 .frame_mbs_only_flag(frame_mbs_only_flag),
 .direct_8x8_inference_flag(direct_8x8_inference_flag),
 .frame_cropping_flag(frame_cropping_flag),
 .vui_parameters_present_flag(vui_parameters_present_flag), 
.sps_state(sps_state),
.forward_len_out(forward_len_sps)
);




wire first_mb_in_slice;
wire[2:0] slice_type_mod5;
wire[7:0] pic_parameter_set_id_slice_header;
wire[3:0] frame_num;
wire idr_pic_id;
wire[9:0] pic_order_cnt_lsb;
wire num_ref_idx_active_override_flag;
wire[2:0] num_ref_idx_l0_active_minus1_slice_header;
wire ref_pic_list_reordering_flag_l0;
wire no_output_of_prior_pics_flag;
wire long_term_reference_flag;
wire adaptive_ref_pic_marking_mode_flag;
wire[5:0] slice_qp_delta;
wire[1:0] disable_deblocking_filter_idc;
wire[3:0] slice_alpha_c0_offset_div2;
wire[3:0] slice_beta_offset_div2;
wire[4:0] slice_header_state;
wire[4:0] forward_len_slice_header;
wire slice_header_enable;

slice_header slice_header_dut(
.clk(clk),
.rst_n(rst_n),
.ena(slice_header_ena),
.rbsp_in(rbsp_out[23:22]),
 .deblocking_filter_control_present_flag_pps_in(deblocking_filter_control_present_flag),
 .exp_golomb_decoding_output_in(exp_golomb_decoding_output[7:0]),
 .exp_golomb_decoding_output_se_in(exp_golomb_decoding_output_se[7:0]),
 .exp_golomb_decoding_len_in(exp_golomb_decoding_len),
 .read_bits_in(read_bits_out),
 .read_bits_len_out(read_bits_len),
.nalu_unit_type(nal_unit_type),
.nal_ref_idc(nal_ref_idc),
.pic_order_cnt_type_sps_in(pic_order_cnt_type),
.log2_max_frame_num_minus4_sps_in(log2_max_frame_num_minus4),
.log2_max_pic_order_cnt_lsb_minus4_sps_in(log2_max_pic_order_cnt_lsb_minus4),
.first_mb_in_slice(first_mb_in_slice),
.slice_type_mod5(slice_type_mod5),
.pic_parameter_set_id(pic_parameter_set_id_slice_header),
.frame_num(frame_num),
.idr_pic_id(idr_pic_id),
.pic_order_cnt_lsb(pic_order_cnt_lsb),
.num_ref_idx_active_override_flag(num_ref_idx_active_override_flag),
.num_ref_idx_l0_active_minus1(num_ref_idx_l0_active_minus1_slice_header),
.ref_pic_list_reordering_flag_l0(ref_pic_list_reordering_flag_l0),
.no_output_of_prior_pics_flag(no_output_of_prior_pics_flag),
.long_term_reference_flag(long_term_reference_flag),
.adaptive_ref_pic_marking_mode_flag(adaptive_ref_pic_marking_mode_flag),
.slice_qp_delta(slice_qp_delta),
 .disable_deblocking_filter_idc(disable_deblocking_filter_idc),
 .slice_alpha_c0_offset_div2(slice_alpha_c0_offset_div2),
 .slice_beta_offset_div2(slice_beta_offset_div2),
.slice_header_state(slice_header_state),
.forward_len_out(forward_len_slice_header)
);

wire[`mb_x_bits + `mb_y_bits - 1:0] mb_index;


wire fpga_ram_intra4x4_pred_mode_wr_n;
wire [`mb_x_bits-1:0] fpga_ram_intra4x4_pred_mode_addr;     
wire [15:0]  fpga_ram_intra4x4_pred_mode_data_in;
wire [15:0]  fpga_ram_intra4x4_pred_mode_data_out;

wire fpga_ram_mvx_wr_n;
wire [`mb_x_bits-1:0] fpga_ram_mvx_addr;     
wire [63:0]  fpga_ram_mvx_data_in;
wire [63:0]  fpga_ram_mvx_data_out;  
     
wire fpga_ram_mvy_wr_n;
wire [`mb_x_bits-1:0] fpga_ram_mvy_addr;     
wire [63:0]  fpga_ram_mvy_data_in;
wire [63:0]  fpga_ram_mvy_data_out;  
 
wire fpga_ram_ref_idx_wr_n;
wire [`mb_x_bits-1:0] fpga_ram_ref_idx_addr;     
wire [7:0] fpga_ram_ref_idx_data_in;
wire [7:0] fpga_ram_ref_idx_data_out;  

wire fpga_ram_qp_wr_n;
wire [`mb_x_bits-1:0] fpga_ram_qp_addr;
wire [7:0] fpga_ram_qp_data_in;
wire [7:0] fpga_ram_qp_data_out; 

wire fpga_ram_qp_c_wr_n;
wire [`mb_x_bits-1:0] fpga_ram_qp_c_addr;     
wire [7:0] fpga_ram_qp_c_data_in;
wire [7:0] fpga_ram_qp_c_data_out;

wire fpga_ram_pixels_y_wr_n;
wire [7:0] fpga_ram_pixels_y_addr;     
wire [15:0] fpga_ram_pixels_y_data_in;
wire [15:0] fpga_ram_pixels_y_data_out;

wire fpga_ram_pixels_u_wr_n;
wire [5:0] fpga_ram_pixels_u_addr;     
wire [15:0] fpga_ram_pixels_u_data_in;
wire [15:0] fpga_ram_pixels_u_data_out;

wire fpga_ram_pixels_v_wr_n;
wire [5:0] fpga_ram_pixels_v_addr;     
wire [15:0] fpga_ram_pixels_v_data_in;
wire [15:0] fpga_ram_pixels_v_data_out;

wire fpga_ram_nnz_wr_n;
wire [`mb_x_bits-1:0] fpga_ram_nnz_addr;
wire [31:0] fpga_ram_nnz_data_in;
wire [31:0] fpga_ram_nnz_data_out;

wire fpga_ram_nnz_cb_wr_n;
wire [`mb_x_bits-1:0] fpga_ram_nnz_cb_addr;
wire [15:0] fpga_ram_nnz_cb_data_in;
wire [15:0] fpga_ram_nnz_cb_data_out;

wire fpga_ram_nnz_cr_wr_n;
wire [`mb_x_bits-1:0] fpga_ram_nnz_cr_addr;
wire [15:0] fpga_ram_nnz_cr_data_in;
wire [15:0] fpga_ram_nnz_cr_data_out;

ram #(`mb_x_bits, 16) fpga_ram_intra4x4_pred_mode // up to 1024p width for future use, 4 bits per 4x4 block
(
 .clk(clk),
 .wr_n(fpga_ram_intra4x4_pred_mode_wr_n), 
 .addr(fpga_ram_intra4x4_pred_mode_addr), 
 .data_in(fpga_ram_intra4x4_pred_mode_data_in), 
 .data_out(fpga_ram_intra4x4_pred_mode_data_out)
 );

ram #(`mb_x_bits, 8) fpga_ram_ref_idx //4 bits per 8x8 block, 3 bits used
(
 .clk(clk),
 .wr_n(fpga_ram_ref_idx_wr_n), 
 .addr(fpga_ram_ref_idx_addr), 
 .data_in(fpga_ram_ref_idx_data_in), 
 .data_out(fpga_ram_ref_idx_data_out)
 );
 
ram #(`mb_x_bits, 64) fpga_ram_mvx // 12 bits per 4x4 block, maximum mv 4096/4=1024 pixels
(
 .clk(clk),
 .wr_n(fpga_ram_mvx_wr_n), 
 .addr(fpga_ram_mvx_addr), 
 .data_in(fpga_ram_mvx_data_in), 
 .data_out(fpga_ram_mvx_data_out)
 );


ram #(`mb_x_bits, 64) fpga_ram_mvy
(
 .clk(clk),
 .wr_n(fpga_ram_mvy_wr_n), 
 .addr(fpga_ram_mvy_addr), 
 .data_in(fpga_ram_mvy_data_in), 
 .data_out(fpga_ram_mvy_data_out)
 ); 
 

ram #(`mb_x_bits, 8) fpga_ram_qp 
(
 .clk(clk),
 .wr_n(fpga_ram_qp_wr_n), 
 .addr(fpga_ram_qp_addr), 
 .data_in(fpga_ram_qp_data_in), 
 .data_out(fpga_ram_qp_data_out)
 );

ram #(`mb_x_bits, 8) fpga_ram_qp_c
( 
 .clk(clk),
 .wr_n(fpga_ram_qp_c_wr_n), 
 .addr(fpga_ram_qp_c_addr), 
 .data_in(fpga_ram_qp_c_data_in), 
 .data_out(fpga_ram_qp_c_data_out)
 );

ram #(8, 16) fpga_ram_pixels_y // pixels for one macroblock, 
(
 .clk(clk),
 .wr_n(fpga_ram_pixels_y_wr_n), 
 .addr(fpga_ram_pixels_y_addr), 
 .data_in(fpga_ram_pixels_y_data_in), 
 .data_out(fpga_ram_pixels_y_data_out)
 );

ram #(6, 16) fpga_ram_pixels_u 
(
 .clk(clk),
 .wr_n(fpga_ram_pixels_u_wr_n), 
 .addr(fpga_ram_pixels_u_addr), 
 .data_in(fpga_ram_pixels_u_data_in), 
 .data_out(fpga_ram_pixels_u_data_out)
 );

ram #(6, 16) fpga_ram_pixels_v 
(
 .clk(clk),
 .wr_n(fpga_ram_pixels_v_wr_n), 
 .addr(fpga_ram_pixels_v_addr), 
 .data_in(fpga_ram_pixels_v_data_in), 
 .data_out(fpga_ram_pixels_v_data_out)
 );

ram #(`mb_x_bits, 32) fpga_ram_nnz 
(
 .clk(clk),
 .wr_n(fpga_ram_nnz_wr_n), 
 .addr(fpga_ram_nnz_addr), 
 .data_in(fpga_ram_nnz_data_in), 
 .data_out(fpga_ram_nnz_data_out)
 );

ram #(`mb_x_bits, 16) fpga_ram_nnz_cb 
(
 .clk(clk),
 .wr_n(fpga_ram_nnz_cb_wr_n), 
 .addr(fpga_ram_nnz_cb_addr), 
 .data_in(fpga_ram_nnz_cb_data_in), 
 .data_out(fpga_ram_nnz_cb_data_out)
 );

ram #(`mb_x_bits, 16) fpga_ram_nnz_cr 
(
 .clk(clk),
 .wr_n(fpga_ram_nnz_cr_wr_n), 
 .addr(fpga_ram_nnz_cr_addr), 
 .data_in(fpga_ram_nnz_cr_data_in), 
 .data_out(fpga_ram_nnz_cr_data_out)
 );

//
//line rams, for storing the bottom line pixels of up mbs
//
wire [`mb_x_bits + 1:0] line_ram_luma_addr;
wire [`mb_x_bits :0]    line_ram_chroma_addr;
wire [31:0] sum_bottom_row;
wire [31:0] line_ram_luma_data;
wire [31:0] line_ram_cb_data;
wire [31:0] line_ram_cr_data;
wire line_ram_luma_wr_n;
wire line_ram_cb_wr_n;
wire line_ram_cr_wr_n;

ram #(`mb_x_bits+2,32) line_ram_luma
(
	.clk(clk),
	.wr_n(line_ram_luma_wr_n), 
	.addr(line_ram_luma_addr), 	
	.data_in(sum_bottom_row), 
	.data_out(line_ram_luma_data)
);

ram #(`mb_x_bits+1, 32) line_ram_cb
(
	.clk(clk),
	.wr_n(line_ram_cb_wr_n), 
	.addr(line_ram_chroma_addr), 	
	.data_in(sum_bottom_row), 
	.data_out(line_ram_cb_data)
);

ram #(`mb_x_bits+1, 32) line_ram_cr
(
	.clk(clk),
	.wr_n(line_ram_cr_wr_n), 
	.addr(line_ram_chroma_addr), 	
	.data_in(sum_bottom_row), 
	.data_out(line_ram_cr_data)
);

wire[`mb_x_bits - 1:0] mb_x;
wire[`mb_y_bits - 1:0] mb_y;

wire[3:0] luma4x4BlkIdx;
wire[1:0] luma4x4BlkIdx_y;
wire[1:0] luma4x4BlkIdx_x;

wire prev_intra4x4_pred_mode_flag;
wire[2 :0] rem_intra4x4_pred_mod;
wire[15:0] intra4x4_pred_mode_up_mb;
wire[15:0] intra4x4_pred_mode_left_mb;
wire[3 :0] mb_pred_mode;
wire[63:0] intra4x4_pred_mode_curr_mb;
wire[3 :0] decoded_I4_pred_mode;
wire[2:0] rem_intra4x4_pred_mode;

intra4x4_pred_mode_decoding I4_pred_dut
(
 .mb_x_in(mb_x),
 .mb_y_in(mb_y),
 .luma4x4BlkIdx_in(luma4x4BlkIdx),
 .luma4x4BlkIdx_y_in(luma4x4BlkIdx_y),
 .luma4x4BlkIdx_x_in(luma4x4BlkIdx_x),
 .prev_intra4x4_pred_mode_in(prev_intra4x4_pred_mode_flag),
 .rem_intra4x4_pred_mode_in(rem_intra4x4_pred_mode),
 .intra4x4_pred_mode_left_mb_in(intra4x4_pred_mode_left_mb),
 .intra4x4_pred_mode_up_mb_in(intra4x4_pred_mode_up_mb),
 .intra4x4_pred_mode_curr_mb_in(intra4x4_pred_mode_curr_mb),
 .I4_pred_mode_out(decoded_I4_pred_mode)
);

wire[`mb_y_bits + 3:0]  pixel_y;
wire[`mb_x_bits + 3:0]  pixel_x;
wire[4:0]  MbPartWidth;
wire[4:0]  MbPartHeight;
wire[2:0]  ref_idx_l0;

wire[5:0] ref_idx_l0_left_mb;
wire[11:0] ref_idx_l0_curr_mb;
wire[5:0]  ref_idx_l0_up_left_mb;
wire[5:0]  ref_idx_l0_up_mb;
wire[5:0]  ref_idx_l0_up_right_mb;

wire [63 :0] mvx_l0_left_mb;
wire [255:0] mvx_l0_curr_mb;
wire [15 :0] mvx_l0_up_left_mb;
wire [63 :0] mvx_l0_up_mb;
wire [63 :0] mvx_l0_up_right_mb;

wire [63 :0] mvy_l0_left_mb;
wire [255:0] mvy_l0_curr_mb;
wire [15 :0] mvy_l0_up_left_mb;
wire [63 :0] mvy_l0_up_mb;
wire [63 :0] mvy_l0_up_right_mb;

wire[15:0] mvpx_l0;
wire[15:0] mvpy_l0;


 
get_mvp get_mvp_dut
(
 .mb_index_in(mb_index),
 .luma4x4BlkIdx_in(luma4x4BlkIdx),
 .pixel_y_in(pixel_y),
 .pixel_x_in(pixel_x),
 .MbPartWidth_in(MbPartWidth),
 .MbPartHeight_in(MbPartHeight),
 .ref_idx_l0_in(ref_idx_l0),
 .pic_width_in_mbs(pic_width_in_mbs),
 .ref_idx_l0_left_mb_in(ref_idx_l0_left_mb),
 .ref_idx_l0_curr_mb_in(ref_idx_l0_curr_mb),
 .ref_idx_l0_up_left_mb_in(ref_idx_l0_up_left_mb),
 .ref_idx_l0_up_mb_in(ref_idx_l0_up_mb),
 .ref_idx_l0_up_right_mb_in(ref_idx_l0_up_right_mb),
 .mvx_l0_left_mb_in(mvx_l0_left_mb),
 .mvx_l0_curr_mb_in(mvx_l0_curr_mb),
 .mvx_l0_up_left_mb_in(mvx_l0_up_left_mb),
 .mvx_l0_up_mb_in(mvx_l0_up_mb),
 .mvx_l0_up_right_mb_in(mvx_l0_up_right_mb[15:0]),
 .mvy_l0_left_mb_in(mvy_l0_left_mb),
 .mvy_l0_curr_mb_in(mvy_l0_curr_mb),
 .mvy_l0_up_left_mb_in(mvy_l0_up_left_mb),
 .mvy_l0_up_mb_in(mvy_l0_up_mb),
 .mvy_l0_up_right_mb_in(mvy_l0_up_right_mb[15:0]),
 .mvpx_l0_out(mvpx_l0),
 .mvpy_l0_out(mvpy_l0)
);


wire		cavlc_ena;
wire		residual_start;
wire		signed	[5:0]	nC_cavlc; 
// output from nC_decoding, input to slice_data and cavlc -- not the case,
// output from nC_decoding, processed by slice_data(store it to m9k), then input to cavlc, so there should be two signal in slice_data, one input and one output

wire		[4:0]	max_coeff_num;


wire	[4:0]	TotalCoeff; 
wire	[4:0]	len_comb;
wire	cavlc_idle;

wire signed[7:0] qp;
wire signed[7:0] qp_c;

wire [3:0] residual_state;
wire [1:0] chroma4x4BlkIdx;

wire signed	[8:0]	residual_0;
wire signed	[8:0]	residual_1;
wire signed	[8:0]	residual_2;
wire signed	[8:0]	residual_3;
wire signed	[8:0]	residual_4;
wire signed	[8:0]	residual_5;
wire signed	[8:0]	residual_6;
wire signed	[8:0]	residual_7;
wire signed	[8:0]	residual_8;
wire signed	[8:0]	residual_9;
wire signed	[8:0]	residual_10;
wire signed	[8:0]	residual_11;
wire signed	[8:0]	residual_12;
wire signed	[8:0]	residual_13;
wire signed	[8:0]	residual_14;
wire signed	[8:0]	residual_15;
wire residual_valid;

residual_top residual_dut(
	.clk(clk),
	.rst_n(rst_n),
	.ena(residual_ena),
	.residual_start(residual_start),
	.rbsp(rbsp_out[23:8]),
	.nC(nC_cavlc),
	.max_coeff_num(max_coeff_num),
	.qp(qp[5:0]),
	.qp_c(qp_c[5:0]),
	.residual_state(residual_state),
	.luma4x4BlkIdx_residual(luma4x4BlkIdx),
	.chroma4x4BlkIdx_residual(chroma4x4BlkIdx),
	.start_of_MB(start_of_MB),
	.residual_0(residual_0),
	.residual_1(residual_1),
	.residual_2(residual_2),
	.residual_3(residual_3),
	.residual_4(residual_4),
	.residual_5(residual_5),
	.residual_6(residual_6),
	.residual_7(residual_7),
	.residual_8(residual_8),
	.residual_9(residual_9),
	.residual_10(residual_10),
	.residual_11(residual_11),
	.residual_12(residual_12),
	.residual_13(residual_13),
	.residual_14(residual_14),
	.residual_15(residual_15),
	.TotalCoeff(TotalCoeff),
	.len_comb(len_comb),
	.cavlc_idle(cavlc_idle),
	.residual_valid(residual_valid)
);

wire [1:0] I16_pred_mode;
wire [3:0] I4_pred_mode;
wire [1:0] intra_pred_mode_chroma;
wire [4:0] blk4x4_counter;
wire [7:0] intra_pred_0;
wire [7:0] intra_pred_1; 
wire [7:0] intra_pred_2; 
wire [7:0] intra_pred_3; 
wire [7:0] intra_pred_4; 
wire [7:0] intra_pred_5; 
wire [7:0] intra_pred_6; 
wire [7:0] intra_pred_7; 
wire [7:0] intra_pred_8; 
wire [7:0] intra_pred_9; 
wire [7:0] intra_pred_10;
wire [7:0] intra_pred_11;
wire [7:0] intra_pred_12;
wire [7:0] intra_pred_13;
wire [7:0] intra_pred_14;
wire [7:0] intra_pred_15;
wire sum_valid;
wire [31:0] sum_right_colum;
wire mb_pred_inter_sel;

intra_pred_top intra_pred_top
(
	.clk(clk),
	.rst_n(rst_n),
	.ena(intra_pred_ena),
	.start(intra_pred_start),
	.mb_pred_mode(mb_pred_mode),
	.mb_pred_inter_sel(mb_pred_inter_sel),
	.I4_pred_mode(I4_pred_mode),
	.I16_pred_mode(I16_pred_mode),
	.intra_pred_mode_chroma(intra_pred_mode_chroma),
	.mb_x(mb_x),
	.mb_y(mb_y),
	.blk4x4_counter(blk4x4_counter),
	.pic_width_in_mbs_minus1(pic_width_in_mbs_minus1),
	.sum_valid(sum_valid),
	.sum_right_colum(sum_right_colum),
	.sum_bottom_row(sum_bottom_row),
	
	.line_ram_luma_addr(line_ram_luma_addr),
	.line_ram_chroma_addr(line_ram_chroma_addr),
	.line_ram_luma_wr_n(line_ram_luma_wr_n),
	.line_ram_cb_wr_n(line_ram_cb_wr_n),
	.line_ram_cr_wr_n(line_ram_cr_wr_n),
	.line_ram_luma_data(line_ram_luma_data),
	.line_ram_cb_data(line_ram_cb_data),
	.line_ram_cr_data(line_ram_cr_data),
	
	.intra_pred_0(intra_pred_0),  
	.intra_pred_1(intra_pred_1),                 
	.intra_pred_2(intra_pred_2),                 
	.intra_pred_3(intra_pred_3),
	.intra_pred_4(intra_pred_4),
	.intra_pred_5(intra_pred_5),
	.intra_pred_6(intra_pred_6),
	.intra_pred_7(intra_pred_7),
	.intra_pred_8(intra_pred_8),
	.intra_pred_9(intra_pred_9),
	.intra_pred_10(intra_pred_10),
	.intra_pred_11(intra_pred_11),
	.intra_pred_12(intra_pred_12),
	.intra_pred_13(intra_pred_13),
	.intra_pred_14(intra_pred_14),
	.intra_pred_15(intra_pred_15),
	.valid(intra_pred_valid)
);

wire inter_pred_ena;

wire [`mb_x_bits + 5:0] ref_x;
wire [`mb_y_bits + 5:0] ref_y;
wire [2:0] ref_idx;

wire [7:0] inter_pred_0; 
wire [7:0] inter_pred_1; 
wire [7:0] inter_pred_2; 
wire [7:0] inter_pred_3; 
wire [7:0] inter_pred_4; 
wire [7:0] inter_pred_5; 
wire [7:0] inter_pred_6; 
wire [7:0] inter_pred_7; 
wire [7:0] inter_pred_8; 
wire [7:0] inter_pred_9; 
wire [7:0] inter_pred_10;
wire [7:0] inter_pred_11;
wire [7:0] inter_pred_12;
wire [7:0] inter_pred_13;
wire [7:0] inter_pred_14;
wire [7:0] inter_pred_15;

wire									ref_mem_burst;
wire [4:0]								ref_mem_burst_len_minus1;
wire									ref_mem_ready;
wire									ref_mem_valid;
wire [`ext_buf_mem_addr_width-1:0]		ref_mem_addr;
wire [`ext_buf_mem_data_width-1:0]		ref_mem_data;
wire									ref_mem_rd;

inter_pred_top inter_pred_top
(
	.clk(clk),
	.rst_n(rst_n),
	.ena(inter_pred_ena),
	
	.start(inter_pred_start),
	.valid(inter_pred_valid),
	
	.blk4x4_counter(blk4x4_counter),
	.pic_num_2to0(pic_num[2:0]),
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

wire [7:0] sum_0;
wire [7:0] sum_1;
wire [7:0] sum_2;
wire [7:0] sum_3;
wire [7:0] sum_4;
wire [7:0] sum_5;
wire [7:0] sum_6;
wire [7:0] sum_7;
wire [7:0] sum_8;
wire [7:0] sum_9;
wire [7:0] sum_10;
wire [7:0] sum_11;
wire [7:0] sum_12;
wire [7:0] sum_13;
wire [7:0] sum_14;
wire [7:0] sum_15;

sum sum
(
	.clk(clk),
	.rst_n(rst_n),
	.ena(sum_ena),
	.start(sum_start),
	.mb_pred_mode(mb_pred_mode),
  
    .residual_0(residual_0),
    .residual_1(residual_1), 
    .residual_2(residual_2), 
    .residual_3(residual_3), 
    .residual_4(residual_4), 
    .residual_5(residual_5),
    .residual_6(residual_6),
    .residual_7(residual_7),
    .residual_8(residual_8),
    .residual_9(residual_9),
    .residual_10(residual_10),
    .residual_11(residual_11),
    .residual_12(residual_12),
    .residual_13(residual_13),
    .residual_14(residual_14),	
    .residual_15(residual_15),
	
	.intra_pred_0(intra_pred_0),
	.intra_pred_1(intra_pred_1),
	.intra_pred_2(intra_pred_2),
	.intra_pred_3(intra_pred_3),
	.intra_pred_4(intra_pred_4),
	.intra_pred_5(intra_pred_5),
	.intra_pred_6(intra_pred_6),
	.intra_pred_7(intra_pred_7),
	.intra_pred_8(intra_pred_8),
	.intra_pred_9(intra_pred_9), 
	.intra_pred_10(intra_pred_10),
	.intra_pred_11(intra_pred_11),
	.intra_pred_12(intra_pred_12),
	.intra_pred_13(intra_pred_13),
	.intra_pred_14(intra_pred_14),
	.intra_pred_15(intra_pred_15),

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
	.inter_pred_15(inter_pred_15),
	
	.sum_0(sum_0),
	.sum_1(sum_1),
	.sum_2(sum_2),
	.sum_3(sum_3),
	.sum_4(sum_4),
	.sum_5(sum_5),
	.sum_6(sum_6),
	.sum_7(sum_7),
	.sum_8(sum_8),
	.sum_9(sum_9),
	.sum_10(sum_10),
	.sum_11(sum_11),
	.sum_12(sum_12),   
	.sum_13(sum_13),
	.sum_14(sum_14),
	.sum_15(sum_15),
	.sum_right_colum(sum_right_colum),
	.sum_bottom_row(sum_bottom_row),
	.write_to_ram_start(write_to_ram_start),
	.write_to_ram_valid(write_to_ram_valid),
	.valid(sum_valid)
);

wire									ext_mem_writer_burst; 
wire [4:0]								ext_mem_writer_burst_len_minus1;
wire									ext_mem_writer_ready;
wire [`ext_buf_mem_addr_width-1:0]		ext_mem_writer_addr;
wire [`ext_buf_mem_addr_width-1:0]		ext_mem_writer_display_buf_addr;
wire [`ext_buf_mem_data_width-1:0]		ext_mem_writer_data;
wire									ext_mem_writer_wr;
ext_mem_writer ext_mem_writer
(
	.clk(clk),
	.rst_n(rst_n),
	.ena(ext_mem_writer_ena),
	
	.start(write_to_ram_start),
	.blk4x4_counter(blk4x4_counter),
	.start_of_frame(start_of_frame),
	.pic_num_2to0(pic_num[2:0]),
	.mb_x_in(mb_x),
	.mb_y_in(mb_y),
	.pic_width_in_mbs(pic_width_in_mbs),
	.pic_height_in_map_units(pic_height_in_map_units),
    .luma4x4BlkIdx_x(luma4x4BlkIdx_x),
    .luma4x4BlkIdx_y(luma4x4BlkIdx_y),
    .chroma4x4BlkIdx(chroma4x4BlkIdx),
    
    .sum_0(sum_0),
    .sum_1(sum_1),
    .sum_2(sum_2),
    .sum_3(sum_3),
    .sum_4(sum_4),
    .sum_5(sum_5),
    .sum_6(sum_6),
    .sum_7(sum_7),
    .sum_8(sum_8),
    .sum_9(sum_9),
    .sum_10(sum_10),
    .sum_11(sum_11),
    .sum_12(sum_12),
    .sum_13(sum_13),
    .sum_14(sum_14),
    .sum_15(sum_15),
    .valid(write_to_ram_valid),

	.ext_mem_writer_burst(ext_mem_writer_burst),
	.ext_mem_writer_burst_len_minus1(ext_mem_writer_burst_len_minus1),
	.ext_mem_writer_ready(ext_mem_writer_ready),
	.ext_mem_writer_addr(ext_mem_writer_addr),
	.ext_mem_writer_display_buf_addr(ext_mem_writer_display_buf_addr),
    .ext_mem_writer_data(ext_mem_writer_data),
    .ext_mem_writer_wr(ext_mem_writer_wr)
);



wire signed[7:0] nC;
wire signed[7:0] nC_cb;
wire signed[7:0] nC_cr;
wire[31:0] nC_up_mb;
wire[31:0] nC_left_mb;
wire[127:0] nC_curr_mb;
wire[15:0] nC_cb_up_mb;
wire[15:0] nC_cb_left_mb;
wire[31:0] nC_cb_curr_mb;
wire[15:0] nC_cr_up_mb;
wire[15:0] nC_cr_left_mb;
wire[31:0] nC_cr_curr_mb;

nC_decoding nC_decoding_dut
(
 .mb_x_in(mb_x),
 .mb_y_in(mb_y),
 .luma4x4BlkIdx_in(luma4x4BlkIdx),
 .chroma4x4BlkIdx_in(chroma4x4BlkIdx),
 .nC_up_mb_in(nC_up_mb),
 .nC_left_mb_in(nC_left_mb),
 .nC_curr_mb_in(nC_curr_mb),
 .nC_cb_up_mb_in(nC_cb_up_mb),
 .nC_cb_left_mb_in(nC_cb_left_mb),
 .nC_cb_curr_mb_in(nC_cb_curr_mb),
 .nC_cr_up_mb_in(nC_cr_up_mb),
 .nC_cr_left_mb_in(nC_cr_left_mb),
 .nC_cr_curr_mb_in(nC_cr_curr_mb), 
 .nC_out(nC),
 .nC_cb_out(nC_cb),
 .nC_cr_out(nC_cr)
);


wire[3:0] slice_data_state;
wire[4:0] forward_len_slice_data;
slice_data slice_data_dut
(
 .clk(clk),
 .rst_n(rst_n),
 .ena(slice_data_ena),
 .rbsp_in(rbsp_out),
 .slice_type_mod5_in(slice_type_mod5),
 .pic_width_in_mbs_minus1_sps_in(pic_width_in_mbs_minus1),
 .pic_height_in_map_units_minus1_sps_in(pic_height_in_map_units_minus1),
 .num_ref_idx_l0_active_minus1_in(num_ref_idx_l0_active_minus1),
 .exp_golomb_decoding_output_in(exp_golomb_decoding_output),
 .exp_golomb_decoding_len_in(exp_golomb_decoding_len),
 .exp_golomb_decoding_output_se_in({{4{exp_golomb_decoding_output_se[11]}},exp_golomb_decoding_output_se[11:0]}),
 .exp_golomb_decoding_output_te_in(exp_golomb_decoding_output_te[7:0]),
 .exp_golomb_decoding_me_intra4x4_out(exp_golomb_decoding_me_intra4x4),
 .exp_golomb_decoding_te_sel_out(exp_golomb_decoding_te_sel),
 .CBP_luma_in(CBP_luma),
 .CBP_chroma_in(CBP_chroma),
 .pic_init_qp_minus26_pps_in(pic_init_qp_minus26),
 .slice_qp_delta_slice_header_in(slice_qp_delta),
 .chroma_qp_index_offset_pps_in(chroma_qp_index_offset),
 .nC_in(nC[4:0]),
 .nC_cb_in(nC_cb[4:0]),
 .nC_cr_in(nC_cr[4:0]),
 
 .qp(qp),
 .qp_c(qp_c),
 .residual_state(residual_state),
 .slice_data_state(slice_data_state),
 .mb_index_out(mb_index),
 .forward_len_out(forward_len_slice_data),
 .mb_x_out(mb_x), 
 .mb_y_out(mb_y),
 .pixel_x_out(pixel_x),
 .pixel_y_out(pixel_y),
 .luma4x4BlkIdx_out(luma4x4BlkIdx),
 .chroma4x4BlkIdx_out(chroma4x4BlkIdx),
 .luma4x4BlkIdx_x_out(luma4x4BlkIdx_x),
 .luma4x4BlkIdx_y_out(luma4x4BlkIdx_y),
 .blk4x4_counter(blk4x4_counter),
 
 .nC(nC_cavlc), // output to CAVLC
 .nC_curr_mb_out(nC_curr_mb),
 .nC_left_mb_out(nC_left_mb),
 .nC_up_mb_out(nC_up_mb),
 .nC_cb_curr_mb_out(nC_cb_curr_mb),
 .nC_cb_left_mb_out(nC_cb_left_mb),
 .nC_cb_up_mb_out(nC_cb_up_mb),
 .nC_cr_curr_mb_out(nC_cr_curr_mb),
 .nC_cr_left_mb_out(nC_cr_left_mb),
 .nC_cr_up_mb_out(nC_cr_up_mb),
 
 .I4_pred_mode_in(decoded_I4_pred_mode),
 .mvpx_l0_in(mvpx_l0),
 .mvpy_l0_in(mvpy_l0),
 .mb_pred_mode_out(mb_pred_mode),
 .I16_pred_mode_out(I16_pred_mode),
 .I4_pred_mode_out(I4_pred_mode),
 .intra_pred_mode_chroma(intra_pred_mode_chroma),
 
 .intra4x4_pred_mode_up_mb_out(intra4x4_pred_mode_up_mb),
 .intra4x4_pred_mode_left_mb_out(intra4x4_pred_mode_left_mb),
 .intra4x4_pred_mode_curr_mb_out(intra4x4_pred_mode_curr_mb),
 .prev_intra4x4_pred_mode_flag_out(prev_intra4x4_pred_mode_flag),
 .rem_intra4x4_pred_mode_out(rem_intra4x4_pred_mode),

 .MbPartWidth(MbPartWidth),
 .MbPartHeight(MbPartHeight),
 .ref_idx_l0_out(ref_idx_l0),
 
 .max_coeff_num(max_coeff_num),
 .start_of_MB(start_of_MB),
 .end_of_MB(end_of_MB),
 .TotalCoeff(TotalCoeff), 
 .len_comb(len_comb),
 .cavlc_idle(cavlc_idle),
 
 .residual_start(residual_start),
 .intra_pred_start(intra_pred_start),
 .sum_start(sum_start),
 .mb_pred_inter_sel(mb_pred_inter_sel),
 
 .residual_valid(residual_valid),
 .intra_pred_valid(intra_pred_valid),
 .sum_valid(sum_valid), 

 .ref_x(ref_x),
 .ref_y(ref_y),
 .ref_idx(ref_idx),
 .inter_pred_start(inter_pred_start),
 .inter_pred_valid(inter_pred_valid),
  
 .ref_idx_l0_left_mb_out(ref_idx_l0_left_mb),
 .ref_idx_l0_curr_mb_out(ref_idx_l0_curr_mb),
 .ref_idx_l0_up_left_mb_out(ref_idx_l0_up_left_mb),
 .ref_idx_l0_up_mb_out(ref_idx_l0_up_mb),
 .ref_idx_l0_up_right_mb_out(ref_idx_l0_up_right_mb),

 .mvx_l0_left_mb_out(mvx_l0_left_mb),
 .mvy_l0_left_mb_out(mvy_l0_left_mb),
 .mvx_l0_up_left_mb_out(mvx_l0_up_left_mb),
 .mvy_l0_up_left_mb_out(mvy_l0_up_left_mb),
 .mvx_l0_up_mb_out(mvx_l0_up_mb),
 .mvy_l0_up_mb_out(mvy_l0_up_mb),
 .mvx_l0_up_right_mb_out(mvx_l0_up_right_mb),
 .mvy_l0_up_right_mb_out(mvy_l0_up_right_mb),
 .mvx_l0_curr_mb_out(mvx_l0_curr_mb),
 .mvy_l0_curr_mb_out(mvy_l0_curr_mb),
 
 .fpga_ram_intra4x4_pred_mode_wr_n(fpga_ram_intra4x4_pred_mode_wr_n),
 .fpga_ram_intra4x4_pred_mode_addr(fpga_ram_intra4x4_pred_mode_addr),     
 .fpga_ram_intra4x4_pred_mode_data_in(fpga_ram_intra4x4_pred_mode_data_in),
 .fpga_ram_intra4x4_pred_mode_data_out(fpga_ram_intra4x4_pred_mode_data_out),
 .fpga_ram_mvx_wr_n(fpga_ram_mvx_wr_n),
 .fpga_ram_mvx_addr(fpga_ram_mvx_addr),
 .fpga_ram_mvx_data_in(fpga_ram_mvx_data_in),
 .fpga_ram_mvx_data_out(fpga_ram_mvx_data_out),  
 .fpga_ram_mvy_wr_n(fpga_ram_mvy_wr_n),
 .fpga_ram_mvy_addr(fpga_ram_mvy_addr),    
 .fpga_ram_mvy_data_in(fpga_ram_mvy_data_in),
 .fpga_ram_mvy_data_out(fpga_ram_mvy_data_out),
 .fpga_ram_ref_idx_wr_n(fpga_ram_ref_idx_wr_n),
 .fpga_ram_ref_idx_addr(fpga_ram_ref_idx_addr),
 .fpga_ram_ref_idx_data_in(fpga_ram_ref_idx_data_in),
 .fpga_ram_ref_idx_data_out(fpga_ram_ref_idx_data_out), 
 .fpga_ram_qp_wr_n(fpga_ram_qp_wr_n),
 .fpga_ram_qp_addr(fpga_ram_qp_addr),   
 .fpga_ram_qp_data_in(fpga_ram_qp_data_in),
 .fpga_ram_qp_data_out(fpga_ram_qp_data_out),
  .fpga_ram_qp_c_wr_n(fpga_ram_qp_c_wr_n),
  .fpga_ram_qp_c_addr(fpga_ram_qp_c_addr),
  .fpga_ram_qp_c_data_in(fpga_ram_qp_c_data_in),
  .fpga_ram_qp_c_data_out(fpga_ram_qp_c_data_out), 
  .fpga_ram_nnz_wr_n(fpga_ram_nnz_wr_n),
  .fpga_ram_nnz_addr(fpga_ram_nnz_addr),     
  .fpga_ram_nnz_data_in(fpga_ram_nnz_data_in),
  .fpga_ram_nnz_data_out(fpga_ram_nnz_data_out), 
 .fpga_ram_nnz_cb_wr_n(fpga_ram_nnz_cb_wr_n),
 .fpga_ram_nnz_cb_addr(fpga_ram_nnz_cb_addr),
 .fpga_ram_nnz_cb_data_in(fpga_ram_nnz_cb_data_in),
 .fpga_ram_nnz_cb_data_out(fpga_ram_nnz_cb_data_out),
 .fpga_ram_nnz_cr_wr_n(fpga_ram_nnz_cr_wr_n),
 .fpga_ram_nnz_cr_addr(fpga_ram_nnz_cr_addr),     
 .fpga_ram_nnz_cr_data_in(fpga_ram_nnz_cr_data_in),
 .fpga_ram_nnz_cr_data_out(fpga_ram_nnz_cr_data_out)
);


bitstream_controller bc_dut
(
 .clk(clk), 
 .rst_n(rst_n),
 .ena(bc_ena),
 .ext_mem_init_done(ext_mem_init_done),
 .cycle_counter_ena(ena),
 .num_cycles_1_frame(num_cycles_1_frame),
 .sps_state(sps_state),
 .pps_state(pps_state),
 .slice_header_state(slice_header_state),
 .slice_data_state(slice_data_state),
 .num_ref_idx_active_override_flag(num_ref_idx_active_override_flag),
 .num_ref_idx_l0_active_minus1_slice_header(num_ref_idx_l0_active_minus1_slice_header),
 .num_ref_idx_l0_active_minus1_pps(num_ref_idx_l0_active_minus1_pps),
 .forward_len_pps(forward_len_pps),
 .forward_len_sps(forward_len_sps),
 .forward_len_slice_header(forward_len_slice_header),
 .forward_len_slice_data(forward_len_slice_data),
 .end_of_stream(stream_mem_end),
 .nal_unit_type(nal_unit_type),
 
 .sps_enable(bc_sps_ena),
 .pps_enable(bc_pps_ena),
 .slice_header_enable(bc_slice_header_ena),
 .slice_data_enable(bc_slice_data_ena), 
 .num_ref_idx_l0_active_minus1(num_ref_idx_l0_active_minus1),
 .forward_len(forward_len),
 .end_of_frame(end_of_frame),
 .start_of_frame(start_of_frame),
 .pic_num(pic_num)
);

wire ext_mem_hub_ena;
ext_mem_hub ext_mem_hub
(
	.clk(clk),
	.rst_n(rst_n),
	.ena(ext_mem_hub_ena),
	
	.ext_mem_writer_burst(ext_mem_writer_burst),
	.ext_mem_writer_burst_len_minus1(ext_mem_writer_burst_len_minus1),
	.ext_mem_writer_ready(ext_mem_writer_ready),
	.ext_mem_writer_addr(ext_mem_writer_addr),
    .ext_mem_writer_display_buf_addr(ext_mem_writer_display_buf_addr),
    .ext_mem_writer_data(ext_mem_writer_data),
    .ext_mem_writer_wr(ext_mem_writer_wr),
    
	.ref_mem_burst(ref_mem_burst),
	.ref_mem_burst_len_minus1(ref_mem_burst_len_minus1),
	.ref_mem_ready(ref_mem_ready),
	.ref_mem_valid(ref_mem_valid),
	.ref_mem_addr(ref_mem_addr),
	.ref_mem_data(ref_mem_data),
	.ref_mem_rd(ref_mem_rd),

	.ext_mem_init_done(ext_mem_init_done),
	.ext_mem_burst(ext_mem_burst),
	.ext_mem_burst_len_minus1(ext_mem_burst_len_minus1),
	.ext_mem_addr(ext_mem_addr),
	.ext_mem_rd(ext_mem_rd),
	.ext_mem_wr(ext_mem_wr),
	.ext_mem_d(ext_mem_d),
	.ext_mem_q(ext_mem_q),
	.ext_mem_full(ext_mem_full),
	.ext_mem_valid(ext_mem_valid),
	.ext_display_buf_mem_burst(ext_display_buf_mem_burst),
	.ext_display_buf_addr(ext_display_buf_addr)
);

bitstream_ena_gen bitstream_ena_gen
(
	.ena						(ena),		
	.stream_mem_valid           (stream_mem_valid),			  	
	.rbsp_buffer_valid          (rbsp_buffer_valid),               
	.bc_pps_ena             	(bc_pps_ena),               
	.bc_sps_ena             	(bc_sps_ena),               
	.bc_slice_header_ena    	(bc_slice_header_ena),      
	.bc_slice_data_ena	    	(bc_slice_data_ena),
	.read_nalu_ena              (read_nalu_ena),
	.rbsp_buffer_ena            (rbsp_buffer_ena),
	.bc_ena						(bc_ena),	      
	.pps_ena                	(pps_ena),                    
	.sps_ena                	(sps_ena),                    
	.slice_header_ena       	(slice_header_ena),             
	.slice_data_ena          	(slice_data_ena ),
	.residual_ena               (residual_ena),  
	.intra_pred_ena            	(intra_pred_ena),
	.inter_pred_ena             (inter_pred_ena),
	.sum_ena                   	(sum_ena),
	.ext_mem_writer_ena     	(ext_mem_writer_ena),
	.ext_mem_hub_ena			(ext_mem_hub_ena)
);          
            
endmodule
