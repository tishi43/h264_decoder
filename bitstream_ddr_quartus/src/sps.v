//--------------------------------------------------------------------------------------------------
// Design    : bitstream_p
// Author(s) : qiu bin, shi tian qi
// Email     : chat1@126.com, tishi1@126.com
// Copyright (C) 2013 qiu bin 
// All rights reserved                
//-------------------------------------------------------------------------------------------------


`include "defines.v"

module sps
(
 clk,
 rst_n,
 ena,
 rbsp_in,
 exp_golomb_decoding_output_in,
 exp_golomb_decoding_len_in,
 exp_golomb_decoding_output_se_in,
 
 profile_idc,
 constraint_set0_flag,
 constraint_set1_flag,
 constraint_set2_flag,
 constraint_set3_flag,
 reserved_zero_4bits,
 level_idc,
 seq_parameter_set_id_sps,
 chroma_format_idc,
 bit_depth_luma_minus8,
 bit_depth_chroma_minus8,
 lossless_qpprime_y_zero_flag,
 seq_scaling_matrix_present_flag,
 log2_max_frame_num_minus4,
 pic_order_cnt_type,
 log2_max_pic_order_cnt_lsb_minus4,
 delta_pic_order_always_zero_flag,
 offset_for_non_ref_pic,
 offset_for_top_to_bottom_field,
 num_ref_frames_in_pic_order_cnt_cycle,
 num_ref_frames,
 gaps_in_frame_num_value_allowed_flag,
 pic_width_in_mbs_minus1,
 pic_height_in_map_units_minus1,
 pic_width_in_mbs,
 pic_height_in_map_units,
 frame_mbs_only_flag,
 direct_8x8_inference_flag,
 frame_cropping_flag,
 vui_parameters_present_flag, 
 
 sps_state,
 forward_len_out
);
input clk;
input rst_n;
input ena;
input[23:8] rbsp_in; // from rbsp_buffer output 
input[7:0] exp_golomb_decoding_output_in;
input[4:0] exp_golomb_decoding_len_in;
input[7:0] exp_golomb_decoding_output_se_in;
wire signed[7:0] exp_golomb_decoding_output_se_in;

output [7:0] profile_idc;
output constraint_set0_flag;
output constraint_set1_flag;
output constraint_set2_flag;
output constraint_set3_flag;
output [3:0] reserved_zero_4bits;
output [7:0] level_idc;
output [4:0] seq_parameter_set_id_sps;
output [4:0] chroma_format_idc;
output [3:0] bit_depth_luma_minus8;
output [3:0] bit_depth_chroma_minus8;
output lossless_qpprime_y_zero_flag;
output seq_scaling_matrix_present_flag;
 
output [3:0] log2_max_frame_num_minus4;
output [1:0] pic_order_cnt_type;
output [3:0] log2_max_pic_order_cnt_lsb_minus4;
output delta_pic_order_always_zero_flag;
output[4:0] offset_for_non_ref_pic;
output[4:0] offset_for_top_to_bottom_field;
output[2:0] num_ref_frames_in_pic_order_cnt_cycle;
 
output [2:0] num_ref_frames;
output gaps_in_frame_num_value_allowed_flag;
output [`mb_x_bits - 1:0] pic_width_in_mbs_minus1; 
output [`mb_y_bits - 1:0] pic_height_in_map_units_minus1;
output [`mb_x_bits - 1:0] pic_width_in_mbs; 
output [`mb_y_bits - 1:0] pic_height_in_map_units;
output frame_mbs_only_flag;
output direct_8x8_inference_flag;
output frame_cropping_flag;
output vui_parameters_present_flag;

output[4:0] sps_state;
output[4:0] forward_len_out; // indicate how many bits consumed, ask rbsp_buffer to read from read_nalu


reg [7:0] profile_idc;
reg constraint_set0_flag,constraint_set1_flag,constraint_set2_flag,constraint_set3_flag;
reg [3:0] reserved_zero_4bits;
reg [7:0] level_idc;
reg [4:0] seq_parameter_set_id_sps;
reg [4:0] chroma_format_idc;
reg [3:0] bit_depth_luma_minus8;
reg [3:0] bit_depth_chroma_minus8;
reg lossless_qpprime_y_zero_flag;
reg seq_scaling_matrix_present_flag;
 
reg [3:0] log2_max_frame_num_minus4;
reg [1:0] pic_order_cnt_type;
reg [3:0] log2_max_pic_order_cnt_lsb_minus4;
reg delta_pic_order_always_zero_flag;
reg signed[4:0] offset_for_non_ref_pic;
reg signed[4:0] offset_for_top_to_bottom_field;
reg[2:0] num_ref_frames_in_pic_order_cnt_cycle;
 
reg [2:0] num_ref_frames; //however,we only support 1 reference frame currently
reg gaps_in_frame_num_value_allowed_flag;
reg [`mb_x_bits - 1:0] pic_width_in_mbs_minus1; 
reg [`mb_y_bits - 1:0] pic_height_in_map_units_minus1;
reg [`mb_x_bits - 1:0] pic_width_in_mbs; 
reg [`mb_y_bits - 1:0] pic_height_in_map_units;
reg frame_mbs_only_flag;
reg direct_8x8_inference_flag;
reg frame_cropping_flag;
reg vui_parameters_present_flag;

reg[4:0] forward_len_out;
        
reg [4:0] sps_state;


reg [5:0] vui_state;
reg [4:0] vui_forward_len;
reg nal_hrd_parameters_present_flag;
reg vcl_hrd_parameters_present_flag;

always @(sps_state or exp_golomb_decoding_len_in or vui_forward_len)
    case(sps_state)
        `rst_seq_parameter_set                   : forward_len_out <= 0;        
        `fixed_header                            : forward_len_out <= 16;
        `level_idc_s                             : forward_len_out <= 8;
        `seq_parameter_set_id_sps_s              : forward_len_out <= exp_golomb_decoding_len_in;
        `chroma_format_idc_s                     : forward_len_out <= exp_golomb_decoding_len_in;
        `bit_depth_luma_minus8_s                 : forward_len_out <= exp_golomb_decoding_len_in;
        `bit_depth_chroma_minus8_s               : forward_len_out <= exp_golomb_decoding_len_in;
        `lossless_qpprime_seq_scaling            : forward_len_out <= 2;
        `log2_max_frame_num_minus4_s             : forward_len_out <= exp_golomb_decoding_len_in;
        `pic_order_cnt_type_s                    : forward_len_out <= exp_golomb_decoding_len_in;
        `log2_max_pic_order_cnt_lsb_minus4_s     : forward_len_out <= exp_golomb_decoding_len_in;
        `delta_pic_order_always_zero_flag_s      : forward_len_out <= 1;
        `offset_for_non_ref_pic_s                : forward_len_out <= exp_golomb_decoding_len_in;
        `offset_for_top_to_bottom_field_s        : forward_len_out <= exp_golomb_decoding_len_in;
        `num_ref_frames_in_pic_order_cnt_cycle_s : forward_len_out <= exp_golomb_decoding_len_in;
        `num_ref_frames_s                        : forward_len_out <= exp_golomb_decoding_len_in;
        `gaps_in_frame_num_value_allowed_flag_s  : forward_len_out <= 1;
        `pic_width_in_mbs_minus1_s               : forward_len_out <= exp_golomb_decoding_len_in;
        `pic_height_in_map_units_minus1_s        : forward_len_out <= exp_golomb_decoding_len_in;
        `frame_mbs_direct_8x8_frame_cropping_vui : forward_len_out <= 4;
        `vui_parameters                          : forward_len_out <= vui_forward_len;
        `rbsp_trailing_bits_sps                  : forward_len_out <= -1;
        default : forward_len_out <= 0; 
    endcase


always @ (posedge clk or negedge rst_n)
if (rst_n == 0)
        begin
				profile_idc                            <= 0;
				constraint_set0_flag                   <= 0;
				constraint_set1_flag                   <= 0;            
				constraint_set2_flag                   <= 0;
				constraint_set3_flag                   <= 0;
				reserved_zero_4bits                        <= 0;
				level_idc                              <= 0;
				seq_parameter_set_id_sps               <= 0;
				chroma_format_idc                      <= 0;
				bit_depth_luma_minus8                  <= 0;
				bit_depth_chroma_minus8                <= 0;
				lossless_qpprime_y_zero_flag           <= 0;
				seq_scaling_matrix_present_flag        <= 0;
				log2_max_frame_num_minus4              <= 0;
				pic_order_cnt_type                     <= 0;
				log2_max_pic_order_cnt_lsb_minus4      <= 0;
				delta_pic_order_always_zero_flag       <= 0;
				offset_for_non_ref_pic                 <= 0;
				offset_for_top_to_bottom_field         <= 0;
				num_ref_frames_in_pic_order_cnt_cycle  <= 0;

                num_ref_frames                         <= 0; 
                gaps_in_frame_num_value_allowed_flag   <= 0;
                pic_width_in_mbs_minus1                <= 0; 
                pic_width_in_mbs                       <= 0; 
                pic_height_in_map_units_minus1         <= 0;
                pic_height_in_map_units                <= 0;
                frame_mbs_only_flag                    <= 0;
                direct_8x8_inference_flag              <= 0;
                frame_cropping_flag                    <= 0;
                vui_parameters_present_flag             <= 0;
                sps_state                              <= 0;
        end
else 
    begin   
        if(ena)
            case (sps_state)
                `rst_seq_parameter_set: 
                    begin 
                        sps_state <= `fixed_header;
                    end
                `fixed_header:  
                    begin 
                        profile_idc           <= rbsp_in[23:16];
                        constraint_set0_flag  <= rbsp_in[15];
                        constraint_set1_flag  <= rbsp_in[14];
                        constraint_set2_flag  <= rbsp_in[13];
                        constraint_set3_flag  <= rbsp_in[12];
                        reserved_zero_4bits   <= rbsp_in[11:8]; 
                         
                        sps_state <= `level_idc_s;
                    end
                `level_idc_s :
                    begin 
                        level_idc <= rbsp_in[23:16];
                        
                        sps_state <= `seq_parameter_set_id_sps_s;
                    end
                `seq_parameter_set_id_sps_s:
                    begin 
                        seq_parameter_set_id_sps <= exp_golomb_decoding_output_in;
                    	if (profile_idc == 100 || profile_idc == 110 || 
                    	    profile_idc == 122 || profile_idc == 144)                        
                        	sps_state <= `chroma_format_idc_s;
                        else
                        	sps_state <= `log2_max_frame_num_minus4_s;                        
                    end
                    
	
                `chroma_format_idc_s:
                    begin 
                        chroma_format_idc <= exp_golomb_decoding_output_in; 
                    
                        
                        sps_state <= `bit_depth_luma_minus8_s;
                    end
                `bit_depth_luma_minus8_s:
                    begin 
                        bit_depth_luma_minus8 <= exp_golomb_decoding_output_in; 
                        
                        sps_state <= `bit_depth_chroma_minus8_s;
                    end
                `bit_depth_chroma_minus8_s:
                    begin 
                        bit_depth_chroma_minus8 <= exp_golomb_decoding_output_in; 
                        
                        sps_state <= `lossless_qpprime_seq_scaling;
                    end
                `lossless_qpprime_seq_scaling:
                    begin 
                        lossless_qpprime_y_zero_flag <= rbsp_in[23]; 
                        seq_scaling_matrix_present_flag <= rbsp_in[22];
                        
                        sps_state <= `log2_max_frame_num_minus4_s;
                    end
                `log2_max_frame_num_minus4_s:
                    begin 
                        log2_max_frame_num_minus4 <= exp_golomb_decoding_output_in; 
                        
                        sps_state <= `pic_order_cnt_type_s;
                    end
                `pic_order_cnt_type_s:
                    begin 
                        pic_order_cnt_type <= exp_golomb_decoding_output_in; 
                        if ( exp_golomb_decoding_output_in == 0 )
                            begin
                                
                                sps_state <= `log2_max_pic_order_cnt_lsb_minus4_s;
                            end
                        else if ( exp_golomb_decoding_output_in == 1 )
                            begin
                                
                                sps_state <= `delta_pic_order_always_zero_flag_s;
                            end
                        else begin
 	                       sps_state <= `num_ref_frames_s;
                     	end
                    end
                `log2_max_pic_order_cnt_lsb_minus4_s:
                    begin 
                        log2_max_pic_order_cnt_lsb_minus4 <= exp_golomb_decoding_output_in;
                        
                        sps_state <= `num_ref_frames_s;
                    end
                `delta_pic_order_always_zero_flag_s:
                    begin 
                        delta_pic_order_always_zero_flag <= rbsp_in[23];
                        
                        sps_state <= `offset_for_non_ref_pic_s;
                    end
                `offset_for_non_ref_pic_s: 
                    begin 
                        offset_for_non_ref_pic <= exp_golomb_decoding_output_se_in; 
                        
                        sps_state <= `offset_for_top_to_bottom_field_s;  
                    end
                `offset_for_top_to_bottom_field_s: 
                    begin 
                        offset_for_top_to_bottom_field <= exp_golomb_decoding_output_se_in;
                        
                        sps_state <= `num_ref_frames_in_pic_order_cnt_cycle_s;  
                    end
                `num_ref_frames_in_pic_order_cnt_cycle_s: 
                    begin 
                        num_ref_frames_in_pic_order_cnt_cycle <= exp_golomb_decoding_output_in;
                       
                        sps_state <= `num_ref_frames_s; // ignore next 4 state, assume num_ref_frames_in_pic_order_cnt_cycle    
                    end

                `num_ref_frames_s: 
                    begin 
                        num_ref_frames <= exp_golomb_decoding_output_in;
                        
                        sps_state <= `gaps_in_frame_num_value_allowed_flag_s;  
                    end
                `gaps_in_frame_num_value_allowed_flag_s: 
                    begin 
                        gaps_in_frame_num_value_allowed_flag <= rbsp_in[23];
                        
                        sps_state <= `pic_width_in_mbs_minus1_s;  
                    end
                `pic_width_in_mbs_minus1_s:
                    begin 
                        pic_width_in_mbs_minus1 <= exp_golomb_decoding_output_in;
                        pic_width_in_mbs <= exp_golomb_decoding_output_in+1;
                        sps_state <= `pic_height_in_map_units_minus1_s;  
                    end
                `pic_height_in_map_units_minus1_s: 
                    begin 
                        pic_height_in_map_units_minus1 <= exp_golomb_decoding_output_in;
                        pic_height_in_map_units <= exp_golomb_decoding_output_in+1;
                        sps_state <= `frame_mbs_direct_8x8_frame_cropping_vui;  
                    end
                `frame_mbs_direct_8x8_frame_cropping_vui: // end of state
                    begin 
                        frame_mbs_only_flag                    <= rbsp_in[23];
                        direct_8x8_inference_flag              <= rbsp_in[22];
                        frame_cropping_flag                    <= rbsp_in[21];
                        vui_parameters_present_flag            <= rbsp_in[20];
  	                    if (rbsp_in[20])
 	 	                    sps_state <= `vui_parameters;
 	 	                else
 	 	                	sps_state <= `rbsp_trailing_bits_sps;
                    end
                `vui_parameters:
                begin
                	if (vui_state == `vui_end)
                		sps_state <= `rbsp_trailing_bits_sps;
                end
                `rbsp_trailing_bits_sps:
                    sps_state <= `sps_end;
                default: sps_state <= `rst_seq_parameter_set;            
            endcase
    end                         

always @(*)
begin
	case(vui_state)
	`aspect_ratio_info_present_flag            : vui_forward_len <= 1; 
	`aspect_ratio_idc                          : vui_forward_len <= 8;
	`sar_width                                 : vui_forward_len <= 16;
	`sar_height                                : vui_forward_len <= 16;
	`overscan_info_present_flag                : vui_forward_len <= 1;
	`overscan_appropriate_flag                 : vui_forward_len <= 1;
	`video_signal_type_present_flag            : vui_forward_len <= 1;
	`video_format                              : vui_forward_len <= 3;
	`video_full_range_flag                     : vui_forward_len <= 1;
	`colour_description_present_flag           : vui_forward_len <= 1;
	`colour_primaries                          : vui_forward_len <= 8;
	`transfer_characteristics                  : vui_forward_len <= 8;
	`matrix_coefficients                       : vui_forward_len <= 8;
	`chroma_loc_info_present_flag              : vui_forward_len <= 1;
	`chroma_sample_loc_type_top_field          : vui_forward_len <= exp_golomb_decoding_len_in;
	`chroma_sample_loc_type_bottom_field       : vui_forward_len <= exp_golomb_decoding_len_in;
	`timing_info_present_flag                  : vui_forward_len <= 1;
	`num_units_in_tick1                        : vui_forward_len <= 16;
	`num_units_in_tick2                        : vui_forward_len <= 16;
	`time_scale1                               : vui_forward_len <= 16;
	`time_scale2                               : vui_forward_len <= 16;
	`fixed_frame_rate_flag                     : vui_forward_len <= 1;
	`nal_hrd_parameters_present_flag           : vui_forward_len <= 1;
	`vcl_hrd_parameters_present_flag           : vui_forward_len <= 1;
	`low_delay_hrd_flag                        : vui_forward_len <= 1;
	`pic_struct_present_flag                   : vui_forward_len <= 1;
	`bitstream_restriction_flag                : vui_forward_len <= 1;
	`motion_vectors_over_pic_boundaries_flag   : vui_forward_len <= 1;
	`max_bytes_per_pic_denom                   : vui_forward_len <= exp_golomb_decoding_len_in;
	`max_bits_per_mb_denom                     : vui_forward_len <= exp_golomb_decoding_len_in;
	`log2_max_mv_length_horizontal             : vui_forward_len <= exp_golomb_decoding_len_in;
	`log2_max_mv_length_vertical               : vui_forward_len <= exp_golomb_decoding_len_in;
	`num_reorder_frames                        : vui_forward_len <= exp_golomb_decoding_len_in;
	`max_dec_frame_buffering                   : vui_forward_len <= exp_golomb_decoding_len_in;
	default                                    : vui_forward_len <= 0;
	endcase
end

always @(posedge clk or negedge rst_n)
begin
	if (!rst_n)
	begin
		vui_state <=`rst_video_usability_information;
		nal_hrd_parameters_present_flag <= 0;
		vcl_hrd_parameters_present_flag <= 0;
	end
	else if(ena && sps_state == `vui_parameters)
	begin
		case(vui_state)
		`rst_video_usability_information           :
		begin
			vui_state <= `aspect_ratio_info_present_flag;
		end
		`aspect_ratio_info_present_flag            :
		begin
			if (rbsp_in[23])
				vui_state <= `aspect_ratio_idc;
			else
				vui_state <= `overscan_info_present_flag;
		end
		`aspect_ratio_idc                          :
		begin
			if(rbsp_in[23:16] == 8'hff)
				vui_state <= `sar_width;
			else
				vui_state <= `overscan_info_present_flag;
		end
		`sar_width                                 :
		begin
			vui_state <= `sar_height;
		end
		`sar_height                                :
		begin
			vui_state <= `overscan_info_present_flag;
		end
		`overscan_info_present_flag                :
		begin
			if (rbsp_in[23])
				vui_state <= `overscan_appropriate_flag;
			else
				vui_state <= `video_signal_type_present_flag;
		end
		`overscan_appropriate_flag                 :
		begin
			vui_state <= `video_signal_type_present_flag;
		end
		`video_signal_type_present_flag            :
		begin
			if (rbsp_in[23])
				vui_state <= `video_format;
			else
				vui_state <= `chroma_loc_info_present_flag;
		end
		`video_format                              :
		begin
			vui_state <= `video_full_range_flag;
		end
		`video_full_range_flag                     :
		begin
			vui_state <= `colour_description_present_flag;
		end
		`colour_description_present_flag           :
		begin
			if (rbsp_in[23])
				vui_state <= `colour_primaries;
			else
				vui_state <= `chroma_loc_info_present_flag;
		end
		`colour_primaries                          :
		begin
			vui_state <= `transfer_characteristics;
		end
		`transfer_characteristics                  :
		begin
			vui_state <= `matrix_coefficients;
		end
		`matrix_coefficients                       :
		begin
			vui_state <= `chroma_loc_info_present_flag;
		end
		`chroma_loc_info_present_flag              :
		begin
			if (rbsp_in[23])
				vui_state <= `chroma_sample_loc_type_top_field;
			else
				vui_state <= `timing_info_present_flag;
		end
		`chroma_sample_loc_type_top_field          :
		begin
			vui_state <= `chroma_sample_loc_type_bottom_field;
		end
		`chroma_sample_loc_type_bottom_field       :
		begin
			vui_state <= `timing_info_present_flag;
		end
		`timing_info_present_flag                  :
		begin
			if (rbsp_in[23])
				vui_state <= `num_units_in_tick1;
			else
				vui_state <= `nal_hrd_parameters_present_flag;
		end
		`num_units_in_tick1                        :
		begin
			vui_state <= `num_units_in_tick2;
		end
		`num_units_in_tick2                        :
		begin
			vui_state <= `time_scale1;
		end
		`time_scale1                               :
		begin
			vui_state <= `time_scale2;
		end
		`time_scale2                               :
		begin
			vui_state <= `fixed_frame_rate_flag;
		end
		`fixed_frame_rate_flag                     :
		begin
			vui_state <= `nal_hrd_parameters_present_flag;
		end
		`nal_hrd_parameters_present_flag           :
		begin
			if (rbsp_in[23])
			begin
				vui_state <= `nal_hrd_parameters;
				nal_hrd_parameters_present_flag <= 1;
			end
			else
			begin
				vui_state <= `vcl_hrd_parameters_present_flag;
				nal_hrd_parameters_present_flag <= 0;
			end
		end
		`nal_hrd_parameters                        :
		begin
			vui_state <= `vcl_hrd_parameters_present_flag;
		end
		`vcl_hrd_parameters_present_flag           :
		begin
			if (rbsp_in[23])
			begin
				vcl_hrd_parameters_present_flag <= 1;
				vui_state <= `vcl_hrd_parameters;
			end
			else if ( nal_hrd_parameters_present_flag)
			begin
				vcl_hrd_parameters_present_flag <= 0;
				vui_state <= `low_delay_hrd_flag;
			end
			else
			begin
				vcl_hrd_parameters_present_flag <= 0;
				vui_state <= `pic_struct_present_flag;				
			end 
		end
		`vcl_hrd_parameters                        :
		begin
			vui_state <= `low_delay_hrd_flag;
		end
		`low_delay_hrd_flag                        :
		begin
			vui_state <= `pic_struct_present_flag;
		end
		`pic_struct_present_flag                   :
		begin
			vui_state <= `bitstream_restriction_flag;
		end
		`bitstream_restriction_flag                :
		begin
			if ( rbsp_in[23] )
				vui_state <= `motion_vectors_over_pic_boundaries_flag;
			else
				vui_state <=  `vui_end;
		end
		`motion_vectors_over_pic_boundaries_flag   :
		begin
			vui_state <= `max_bytes_per_pic_denom;
		end
		`max_bytes_per_pic_denom                   :
		begin
			vui_state <= `max_bits_per_mb_denom;
		end
		`max_bits_per_mb_denom                     :
		begin
			vui_state <= `log2_max_mv_length_horizontal;
		end
		`log2_max_mv_length_horizontal             :
		begin
			vui_state <= `log2_max_mv_length_vertical;
		end
		`log2_max_mv_length_vertical               :
		begin
			vui_state <= `num_reorder_frames;
		end
		`num_reorder_frames                        :
		begin
			vui_state <= `max_dec_frame_buffering;
		end
		`max_dec_frame_buffering                   :
		begin
			vui_state <= `vui_end;
		end
		default                                    :
		begin
			vui_state <= `rst_video_usability_information;
		end
		endcase
	end
end

endmodule
