//--------------------------------------------------------------------------------------------------
// Design    : bitstream_p
// Author(s) : qiu bin, shi tian qi
// Email     : chat1@126.com, tishi1@126.com
// Copyright (C) 2013 qiu bin 
// All rights reserved                
//-------------------------------------------------------------------------------------------------


`include "defines.v"

module slice_header
(
 clk,
 rst_n,
 ena,
 rbsp_in,
 nalu_unit_type,
 nal_ref_idc,
 pic_order_cnt_type_sps_in,
 log2_max_frame_num_minus4_sps_in,
 log2_max_pic_order_cnt_lsb_minus4_sps_in,
 deblocking_filter_control_present_flag_pps_in,
 exp_golomb_decoding_output_in,
 exp_golomb_decoding_len_in,
 exp_golomb_decoding_output_se_in,
 read_bits_in,
 
 read_bits_len_out,
 
 first_mb_in_slice,
 slice_type_mod5,
 pic_parameter_set_id,
 frame_num,
 //field_pic_flag,
 //bottom_field_flag,
 idr_pic_id,
 pic_order_cnt_lsb,
 //delta_pic_order_cnt_bottom,
 //delta_pic_order_cnt_0,
 //delta_pic_order_cnt_1,
 //redundant_pic_cnt,
 
 //direct_spatial_mv_pred_flag,
 num_ref_idx_active_override_flag,
 num_ref_idx_l0_active_minus1,
 //num_ref_idx_l1_active_minus1, only used in B frame
 ref_pic_list_reordering_flag_l0,
 no_output_of_prior_pics_flag,
 long_term_reference_flag,
 adaptive_ref_pic_marking_mode_flag,
 slice_qp_delta,
 disable_deblocking_filter_idc,
 slice_alpha_c0_offset_div2,
 slice_beta_offset_div2,
 
 slice_header_state,
 forward_len_out
);
input clk;
input rst_n;
input ena; 
input[23:22] rbsp_in; // from rbsp_buffer output 
input[4:0] nalu_unit_type;
input[1:0] nal_ref_idc;
input[1:0] pic_order_cnt_type_sps_in;
input[3:0] log2_max_frame_num_minus4_sps_in;
input[3:0] log2_max_pic_order_cnt_lsb_minus4_sps_in;
input deblocking_filter_control_present_flag_pps_in;

input[7:0] exp_golomb_decoding_output_in;
input[4:0] exp_golomb_decoding_len_in;
input[7:0] exp_golomb_decoding_output_se_in;
wire signed[7:0] exp_golomb_decoding_output_se_in;

input [7:0] read_bits_in;
output [3:0] read_bits_len_out;

output first_mb_in_slice;
output[2:0] slice_type_mod5;
output[7:0] pic_parameter_set_id;
output[3:0] frame_num;
output idr_pic_id;
output[9:0] pic_order_cnt_lsb;
output num_ref_idx_active_override_flag;
output[2:0] num_ref_idx_l0_active_minus1;
output ref_pic_list_reordering_flag_l0;
output no_output_of_prior_pics_flag;
output long_term_reference_flag;
output adaptive_ref_pic_marking_mode_flag;
output[5:0] slice_qp_delta;

output[1:0] disable_deblocking_filter_idc;
output[3:0] slice_alpha_c0_offset_div2;
output[3:0] slice_beta_offset_div2;
  
output[4:0] slice_header_state;
output[4:0] forward_len_out; 

reg first_mb_in_slice;
reg[3:0] slice_type;
reg[7:0] pic_parameter_set_id;
reg[3:0] frame_num;
reg idr_pic_id;
reg[9:0] pic_order_cnt_lsb;
reg num_ref_idx_active_override_flag;
reg[2:0] num_ref_idx_l0_active_minus1;
reg ref_pic_list_reordering_flag_l0;
reg no_output_of_prior_pics_flag;
reg long_term_reference_flag;
reg adaptive_ref_pic_marking_mode_flag;
reg signed[5:0] slice_qp_delta;
reg signed[1:0] disable_deblocking_filter_idc;
reg signed[3:0] slice_alpha_c0_offset_div2;
reg signed[3:0] slice_beta_offset_div2;
  
reg[4:0] slice_header_state;
reg[4:0] forward_len_out;
reg [3:0] read_bits_len_out;

reg[2:0] slice_type_mod5;

always @ (slice_type)
	case (slice_type)
		0, 5 :slice_type_mod5 <= 3'b000;
		1, 6 :slice_type_mod5 <= 3'b001;
		2, 7 :slice_type_mod5 <= 3'b010;
		3, 8 :slice_type_mod5 <= 3'b011;
		4, 9 :slice_type_mod5 <= 3'b100;
		default:slice_type_mod5 <= 3'bx;
	endcase

always @(slice_header_state or exp_golomb_decoding_len_in or read_bits_len_out )
    case(slice_header_state)
        `rst_slice_header,
		`slice_header_end:					   forward_len_out <= 0;	
        `num_ref_idx_active_override_flag_s,
        `ref_pic_list_reordering_flag_l0_s,
        `adaptive_ref_pic_marking_mode_flag_s: forward_len_out <= 1;
        `no_output_long_term_reference:        forward_len_out <= 2;
		`frame_num_s,
        `pic_order_cnt_lsb_s:                  forward_len_out <= read_bits_len_out;
        default:                               forward_len_out <= exp_golomb_decoding_len_in;
    endcase
                        
always @ (posedge clk or negedge rst_n)
    if (rst_n == 0)
	    begin
            first_mb_in_slice                              <= 0;
            slice_type                                     <= 0;
            pic_parameter_set_id                           <= 0;
            frame_num                                      <= 0;
            idr_pic_id                                     <= 0;
            pic_order_cnt_lsb                              <= 0;
            num_ref_idx_active_override_flag               <= 0;
            num_ref_idx_l0_active_minus1                   <= 0;
            ref_pic_list_reordering_flag_l0                <= 0;
            no_output_of_prior_pics_flag                   <= 0;
            long_term_reference_flag                       <= 0;
            adaptive_ref_pic_marking_mode_flag             <= 0;
            slice_qp_delta                                 <= 0;
            disable_deblocking_filter_idc                  <= 0;
            slice_alpha_c0_offset_div2                     <= 0;
            slice_beta_offset_div2                         <= 0;
		    slice_header_state                             <= 0;
	    end
    else 
        begin 
              
            if(ena)
                case (slice_header_state)
                    `rst_slice_header:	
                        begin  
                            
                            slice_header_state <= `first_mb_in_slice_s;
                        end
                    `first_mb_in_slice_s:	
                        begin  
                            first_mb_in_slice  <= exp_golomb_decoding_output_in;
                            
                            slice_header_state <= `slice_type_s;
                        end            
                    `slice_type_s:	
                        begin  
                            slice_type  <= exp_golomb_decoding_output_in;
                            
                            slice_header_state <= `pic_parameter_set_id_s;
                        end
                    `pic_parameter_set_id_s:	
                        begin  
                            pic_parameter_set_id <= exp_golomb_decoding_output_in;
                            read_bits_len_out <= log2_max_frame_num_minus4_sps_in+4;
                            slice_header_state <= `frame_num_s;
                        end
                    `frame_num_s:	
                        begin
                            frame_num <= read_bits_in; 
                            if(nalu_unit_type == 5)
                                begin                                    
                                    slice_header_state <= `idr_pic_id_s;
                                end
                            else if (pic_order_cnt_type_sps_in == 0)
                                begin
                                    read_bits_len_out <= log2_max_pic_order_cnt_lsb_minus4_sps_in+4;                   
                                    slice_header_state <= `pic_order_cnt_lsb_s;
                                end
                            else if (slice_type_mod5 == `slice_type_B || slice_type_mod5 == `slice_type_P || slice_type_mod5 == `slice_type_SP)
                                begin                                    
                                    slice_header_state <= `num_ref_idx_active_override_flag_s;
                                end
                            else if (nal_ref_idc)
                                if(nalu_unit_type == 5)
                                    begin                                    
                                        slice_header_state <= `no_output_long_term_reference;
                                    end
                                else
                                    begin                                        
                                        slice_header_state <= `adaptive_ref_pic_marking_mode_flag_s;
                                    end
                            else
                                begin                                    
                                    slice_header_state <= `slice_qp_delta_s;
                                end
                        end
                    `idr_pic_id_s:
                        begin
                            idr_pic_id <= exp_golomb_decoding_output_in;
                            if (pic_order_cnt_type_sps_in == 0)
                                begin  
                                    read_bits_len_out <= log2_max_pic_order_cnt_lsb_minus4_sps_in+4;
                                    slice_header_state <= `pic_order_cnt_lsb_s;
                                end
                            else if (slice_type_mod5 == `slice_type_B || slice_type_mod5 == `slice_type_P || slice_type_mod5 == `slice_type_SP)
                                begin
                                    slice_header_state <= `num_ref_idx_active_override_flag_s;
                                end
                            else if (nal_ref_idc)
                                if(nalu_unit_type == 5)
                                    begin
                                        slice_header_state <= `no_output_long_term_reference;
                                    end
                                else
                                    begin
                                        slice_header_state <= `adaptive_ref_pic_marking_mode_flag_s;
                                    end
                            else
                                begin
                                    slice_header_state <= `slice_qp_delta_s;
                                end
                        end
                    `pic_order_cnt_lsb_s:	
                        begin
                            pic_order_cnt_lsb <= read_bits_in;
                            if (slice_type_mod5 == `slice_type_B || slice_type_mod5 == `slice_type_P || slice_type_mod5 == `slice_type_SP)
                                begin
                                    slice_header_state <= `num_ref_idx_active_override_flag_s;
                                end
                            else if (nal_ref_idc)
                                if(nalu_unit_type == 5)
                                    begin
                                        slice_header_state <= `no_output_long_term_reference;
                                    end
                                else
                                    begin
                                        slice_header_state <= `adaptive_ref_pic_marking_mode_flag_s;
                                    end
                            else
                                begin
                                    slice_header_state <= `slice_qp_delta_s;
                                end            
                        end
                    `num_ref_idx_active_override_flag_s:
                        begin
                            num_ref_idx_active_override_flag <= rbsp_in[23];
                            if(rbsp_in[23])
                                begin  
                                    
                                    slice_header_state <= `num_ref_idx_l0_active_minus1_s;
                                end
                            else
                                begin
                                    ref_pic_list_reordering_flag_l0 <= rbsp_in[23];
                                    slice_header_state <= `ref_pic_list_reordering_flag_l0_s;
                                end
                        end
                    `num_ref_idx_l0_active_minus1_s:
                        begin
                            num_ref_idx_l0_active_minus1 <= exp_golomb_decoding_output_in;
                            
                            slice_header_state <= `ref_pic_list_reordering_flag_l0_s;
                        end
                    `ref_pic_list_reordering_flag_l0_s:	
                        begin
                            ref_pic_list_reordering_flag_l0 <= rbsp_in[23];
                            if (nal_ref_idc)
                                if(nalu_unit_type == 5)
                                    begin
                                        slice_header_state <= `no_output_long_term_reference;
                                    end
                                else
                                    begin
                                        slice_header_state <= `adaptive_ref_pic_marking_mode_flag_s;
                                    end
                            else
                                begin
                                    slice_header_state <= `slice_qp_delta_s;
                                end
                        end
                    `no_output_long_term_reference:	
                        begin
                            no_output_of_prior_pics_flag <= rbsp_in[23];
                            long_term_reference_flag <= rbsp_in[22];
                            slice_header_state <= `slice_qp_delta_s;
                        end
                    `adaptive_ref_pic_marking_mode_flag_s:	
                        begin
                            adaptive_ref_pic_marking_mode_flag <= rbsp_in[23];
                            slice_header_state <= `slice_qp_delta_s;
                        end
                    `slice_qp_delta_s:	
                        begin  
                            slice_qp_delta <= exp_golomb_decoding_output_se_in;
                            if (deblocking_filter_control_present_flag_pps_in == 0)
                                begin
                                    disable_deblocking_filter_idc <= 0;
                                    slice_alpha_c0_offset_div2 <= 0;
                                    slice_beta_offset_div2 <= 0;                                
                                    slice_header_state <= `slice_header_end;
                                end
                            else
                                slice_header_state <= `disable_deblocking_filter_idc_s;
                        end

                    `disable_deblocking_filter_idc_s:
                         begin
                             disable_deblocking_filter_idc <= exp_golomb_decoding_output_se_in;
                             if(exp_golomb_decoding_output_se_in == 1)
                                 begin
                                     slice_alpha_c0_offset_div2 <= 0;
                                     slice_beta_offset_div2 <= 0;
                                     slice_header_state <= `slice_header_end;
                                 end
                             else
                                 slice_header_state <= `slice_alpha_c0_offset_div2_s;
                         end
                    `slice_alpha_c0_offset_div2_s:
                         begin
                             slice_alpha_c0_offset_div2 <= exp_golomb_decoding_output_se_in;                             
                             slice_header_state <= `slice_beta_offset_div2_s;
                         end                    
                    `slice_beta_offset_div2_s:
                         begin
                              slice_beta_offset_div2 <= exp_golomb_decoding_output_se_in;
                              slice_header_state <= `slice_header_end;
                         end                    
                    default: slice_header_state <= `rst_slice_header;            
                endcase
        end                     	

endmodule

