//--------------------------------------------------------------------------------------------------
// Design    : bitstream_p
// Author(s) : qiu bin, shi tian qi
// Email     : chat1@126.com, tishi1@126.com
// Copyright (C) 2013 qiu bin 
// All rights reserved                
//-------------------------------------------------------------------------------------------------

`timescale 1ns / 10ps // timescale time_unit/time_presicion

//external buffer memory controller data width
//`define ext_buf_mem_data_width_16
`define ext_buf_mem_data_width_32

`ifdef ext_buf_mem_data_width_32
`define ext_buf_mem_data_width 32
`endif
`ifdef ext_buf_mem_data_width_16
`define ext_buf_mem_data_width 16
`endif

//external memory buffer controller addr width
`define ext_buf_mem_addr_width  26

//max mb_x width
`define mb_x_bits    7

//max mb_y width
`define mb_y_bits    6 

//nalu type
`define nalu_type_sps     5'b00111
`define nalu_type_pps     5'b01000
`define nalu_type_idr     5'b00101
`define nalu_type_other   5'b00001

//sps_state
`define rst_seq_parameter_set                     5'b00000
`define fixed_header                              5'b00001
`define level_idc_s                               5'b00010
`define seq_parameter_set_id_sps_s                5'b00011
`define chroma_format_idc_s                       5'b00100
`define bit_depth_luma_minus8_s                   5'b00101
`define bit_depth_chroma_minus8_s                 5'b00110
`define lossless_qpprime_seq_scaling              5'b00111
`define log2_max_frame_num_minus4_s               5'b01000
`define pic_order_cnt_type_s                      5'b01001
`define log2_max_pic_order_cnt_lsb_minus4_s       5'b01010
`define delta_pic_order_always_zero_flag_s        5'b01011
`define offset_for_non_ref_pic_s                  5'b01100
`define offset_for_top_to_bottom_field_s          5'b01101
`define num_ref_frames_in_pic_order_cnt_cycle_s   5'b01110
`define offset_for_ref_frame_4_s                  5'b01111
`define offset_for_ref_frame_3_s                  5'b10000
`define offset_for_ref_frame_2_s                  5'b10001
`define offset_for_ref_frame_1_s                  5'b10010
`define offset_for_ref_frame_0_s                  5'b10011
`define num_ref_frames_s                          5'b10100
`define gaps_in_frame_num_value_allowed_flag_s    5'b10101
`define pic_width_in_mbs_minus1_s                 5'b10110
`define pic_height_in_map_units_minus1_s          5'b10111
`define frame_mbs_direct_8x8_frame_cropping_vui   5'b11000
`define vui_parameters                            5'b11001
`define rbsp_trailing_bits_sps                    5'b11010
`define sps_end                                   5'b11011

//vui_state
`define rst_video_usability_information           6'h00
`define aspect_ratio_info_present_flag            6'h01
`define aspect_ratio_idc                          6'h02
`define sar_width                                 6'h03
`define sar_height                                6'h04
`define overscan_info_present_flag                6'h05
`define overscan_appropriate_flag                 6'h06
`define video_signal_type_present_flag            6'h07
`define video_format                              6'h08
`define video_full_range_flag                     6'h09
`define colour_description_present_flag           6'h0a
`define colour_primaries                          6'h0b
`define transfer_characteristics                  6'h0c
`define matrix_coefficients                       6'h0d
`define chroma_loc_info_present_flag              6'h0e
`define chroma_sample_loc_type_top_field          6'h0f
`define chroma_sample_loc_type_bottom_field       6'h10
`define timing_info_present_flag                  6'h11
`define num_units_in_tick1                        6'h12
`define num_units_in_tick2                        6'h13
`define time_scale1                               6'h14
`define time_scale2                               6'h15
`define fixed_frame_rate_flag                     6'h16
`define nal_hrd_parameters_present_flag           6'h17
`define vcl_hrd_parameters_present_flag           6'h18
`define low_delay_hrd_flag                        6'h19
`define pic_struct_present_flag                   6'h1a
`define bitstream_restriction_flag                6'h1b
`define motion_vectors_over_pic_boundaries_flag   6'h1c
`define max_bytes_per_pic_denom                   6'h1d
`define max_bits_per_mb_denom                     6'h1e
`define log2_max_mv_length_horizontal             6'h1f
`define log2_max_mv_length_vertical               6'h20
`define num_reorder_frames                        6'h21
`define max_dec_frame_buffering                   6'h22
`define vui_end                                   6'h23
`define nal_hrd_parameters                        6'h24
`define vcl_hrd_parameters                        6'h25

//pps_state
`define rst_pic_parameter_set                                        4'b0000
`define pic_parameter_set_id_pps_s                                   4'b0001
`define seq_parameter_set_id_pps_s                                   4'b0010
`define entropy_coding_mode_flag_2_pic_order_present_flag            4'b0011
`define num_slice_groups_minus1_s                                    4'b0100
`define num_ref_idx_l0_active_minus1_pps_s                           4'b0101
`define num_ref_idx_l1_active_minus1_pps_s                           4'b0110
`define weighted_pred_flag_2_weighted_bipred_idc                     4'b0111
`define pic_init_qp_minus26_s                                        4'b1000
`define pic_init_qs_minus26_s                                        4'b1001
`define chroma_qp_index_offset_s                                     4'b1010
`define deblocking_constrained_redundant                             4'b1011
`define second_chroma_qp_index_offset_s                              4'b1100
`define rbsp_trailing_bits_pps                                       4'b1101
`define pps_end                                                      4'b1110

//slice_header_state
`define rst_slice_header                          5'b00000
`define first_mb_in_slice_s                       5'b00001
`define slice_type_s                              5'b00010
`define pic_parameter_set_id_s                    5'b00011 // in pps, pic_parameter_set_id_pps_s
`define frame_num_s                               5'b00100
`define idr_pic_id_s                              5'b00101
`define pic_order_cnt_lsb_s                       5'b00110
`define num_ref_idx_active_override_flag_s        5'b00111
`define num_ref_idx_l0_active_minus1_s            5'b01000
`define ref_pic_list_reordering_flag_l0_s         5'b01001
`define no_output_long_term_reference             5'b01010
`define adaptive_ref_pic_marking_mode_flag_s      5'b01011
`define slice_qp_delta_s                          5'b01100
`define disable_deblocking_filter_idc_s           5'b01101
`define slice_alpha_c0_offset_div2_s              5'b01110
`define slice_beta_offset_div2_s                  5'b01111
`define slice_header_end                          5'b10000

`define slice_type_P        0
`define slice_type_B        1
`define slice_type_I        2
`define slice_type_SP       3
`define slice_type_SI       4

//slice_data_state
`define rst_slice_data                            4'b0000
`define mb_skip_run_s                             4'b0001
`define skip_run_duration                         4'b0010
`define mb_type_s                                 4'b0011
`define mb_pred                                   4'b0100
`define sub_mb_pred                               4'b0101
`define coded_block_pattern_s                     4'b0110
`define mb_qp_delta_s                             4'b0111
`define residual                                  4'b1000
`define mb_num_update                             4'b1001
`define store_to_fpga_ram                         4'b1010
`define prefetch_from_fpga_ram                    4'b1011
`define rbsp_trailing_bits_slice_data             4'b1100
`define slice_data_end                            4'b1101
`define p_skip_s                                  4'b1110

//mb_pred_state
`define rst_mb_pred                    4'b0000
`define prev_intra4x4_pred_mode_flag_s 4'b0001
`define rem_intra4x4_pred_mode_s       4'b0010
`define luma_blk4x4_index_update       4'b0100
`define intra_pred_mode_chroma_s       4'b0101
`define ref_idx_l0_s                   4'b0110
`define mvdx_l0_s                      4'b0111
`define mvdy_l0_s                      4'b1000

//sub_mb_pred_state
`define rst_sub_mb_pred        3'b000
`define sub_mb_type_s          3'b001
`define sub_ref_idx_l0_s       3'b010
`define sub_mvdx_l0_s          3'b011
`define sub_mvdy_l0_s          3'b100

//residual_state
`define rst_residual              4'b0000
`define Intra16x16DCLevel_s       4'b0001
`define Intra16x16ACLevel_s       4'b0011
`define Intra16x16ACLevel_0_s     4'b0010
`define LumaLevel_s               4'b0110
`define LumaLevel_0_s             4'b0111
`define ChromaDCLevel_Cb_s        4'b0101
`define ChromaDCLevel_Cr_s        4'b0100
`define ChromaACLevel_Cb_s        4'b1100
`define ChromaACLevel_Cr_s        4'b1101
`define ChromaACLevel_Cb_0_s      4'b1110
`define ChromaACLevel_Cr_0_s      4'b1111

//transform_state

`define transform_DHT_bit       0

`define transform_idle_s        4'b0000
`define transform_DHT_s         4'b0001
`define transform_DHT2_s        4'b0011
`define transform_IQ_s          4'b0100
`define transform_IDCT_s        4'b1000
`define transform_AC_all_0_s    4'b1100        

//bitstream_state
`define rst_bitstream           3'b000
`define bitstream_sps           3'b001
`define bitstream_pps           3'b010
`define bitstream_slice_header  3'b011
`define bitstream_slice_data    3'b100
`define wait_for_next_frame     3'b101

//mb_pred_mode
`define mb_pred_mode_I4MB     4'b0000
`define mb_pred_mode_I16MB    4'b0001
`define mb_pred_mode_IPCM     4'b0010
`define mb_pred_mode_PRED_L0  4'b0011
`define mb_pred_mode_PRED_L1  4'b0100
`define mb_pred_mode_BI_PRED  4'b0101
`define mb_pred_mode_B_DIRECT 4'b0110
`define mb_pred_mode_P_REF0   4'b0111
`define mb_pred_mode_P_SKIP   4'b1000
`define mb_pred_mode_B_SKIP   4'b1001

`define exp_golomb_sel_ue 2'b00
`define exp_golomb_sel_se 2'b01
`define exp_golomb_sel_te 2'b10
`define exp_golomb_sel_me 2'b11

`define cavlc_idle_bit                  0
`define cavlc_read_total_coeffs_bit     1
`define cavlc_read_t1s_flags_bit        2
`define cavlc_read_level_prefix_bit     3
`define cavlc_read_level_suffix_bit     4
`define cavlc_calc_level_bit            5
`define cavlc_read_total_zeros_bit      6
`define cavlc_read_run_befores_bit      7

`define cavlc_idle_s                    8'b00000001
`define cavlc_read_total_coeffs_s       8'b00000010
`define cavlc_read_t1s_flags_s          8'b00000100
`define cavlc_read_level_prefix_s       8'b00001000
`define cavlc_read_level_suffix_s       8'b00010000
`define cavlc_calc_level_s              8'b00100000
`define cavlc_read_total_zeros_s        8'b01000000
`define cavlc_read_run_befores_s        8'b10000000

//intra pred modes
`define Intra4x4_Vertical            4'b0000
`define Intra4x4_Horizontal          4'b0001
`define Intra4x4_DC                  4'b0010
`define Intra4x4_Diagonal_Down_Left  4'b0011
`define Intra4x4_Diagonal_Down_Right 4'b0100
`define Intra4x4_Vertical_Right      4'b0101
`define Intra4x4_Horizontal_Down     4'b0110
`define Intra4x4_Vertical_Left       4'b0111
`define Intra4x4_Horizontal_Up       4'b1000

`define Intra16x16_Vertical          2'b00
`define Intra16x16_Horizontal        2'b01
`define Intra16x16_DC                2'b10
`define Intra16x16_Plane             2'b11

`define Intra_chroma_DC              2'b00
`define Intra_chroma_Horizontal      2'b01
`define Intra_chroma_Vertical        2'b10
`define Intra_chroma_Plane           2'b11

//intra pred fsm states
`define intra_pred_idle_s           3'b001
`define intra_pred_preload_s        3'b010
`define intra_pred_precalc_s        3'b011
`define intra_pred_seedcalc_s       3'b100
`define intra_pred_calc_s           3'b101

//p_skip_state
`define rst_p_skip_s           2'b00
`define p_skip_luma_s          2'b01
`define p_skip_cb_s            2'b11
`define p_skip_cr_s            2'b10

//inter pred fsm states
`define inter_pred_idle_bit          0
`define inter_pred_load_bit          1
`define inter_pred_calc_bit          2

`define inter_pred_idle_s           3'b001
`define inter_pred_load_s           3'b010
`define inter_pred_calc_s           3'b100
