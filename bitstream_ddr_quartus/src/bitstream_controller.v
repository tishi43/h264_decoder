//--------------------------------------------------------------------------------------------------
// Design    : bitstream_p
// Author(s) : qiu bin, shi tian qi
// Email     : chat1@126.com, tishi1@126.com
// Copyright (C) 2013 qiu bin 
// All rights reserved                
//-------------------------------------------------------------------------------------------------

`include "defines.v"

module bitstream_controller
(
 clk,
 rst_n,
 ena,
 ext_mem_init_done,
 cycle_counter_ena,
 num_cycles_1_frame,
 sps_state,
 pps_state,
 slice_header_state,
 slice_data_state,
 num_ref_idx_active_override_flag,
 num_ref_idx_l0_active_minus1_slice_header,
 num_ref_idx_l0_active_minus1_pps,
 forward_len_pps,
 forward_len_sps,
 forward_len_slice_header,
 forward_len_slice_data,
 end_of_stream,
 nal_unit_type,
 
 sps_enable,
 pps_enable,
 slice_header_enable,
 slice_data_enable, 
 num_ref_idx_l0_active_minus1,
 forward_len,
 end_of_frame,
 start_of_frame,
 pic_num
);

input clk;
input rst_n;
input ena;
input ext_mem_init_done;
input cycle_counter_ena;
input[23:0] num_cycles_1_frame;
input[4:0] sps_state;
input[3:0] pps_state;
input[4:0] slice_header_state; // fix, input[3:0], Port width mismatch, so slice_header_state = `slice_header_end  5'b10000 is impossible
input[3:0] slice_data_state;
input num_ref_idx_active_override_flag;
input[2:0] num_ref_idx_l0_active_minus1_slice_header;
input[2:0] num_ref_idx_l0_active_minus1_pps;
input[4:0] forward_len_pps;
input[4:0] forward_len_sps;
input[4:0] forward_len_slice_header;
input[4:0] forward_len_slice_data;
input end_of_stream;
input[4:0] nal_unit_type;

output sps_enable;
output pps_enable;
output slice_header_enable;
output slice_data_enable;
output[2:0] num_ref_idx_l0_active_minus1;
output[4:0] forward_len;
output start_of_frame;
output end_of_frame;
output [9:0] pic_num;
//wire[9:0] num_mb_in_slice;

wire end_of_stream;
reg[9:0] pic_num;
reg start_of_frame;
reg end_of_frame;
reg[23:0] frame_cycle_counter;

reg[2:0] bitstream_state;
reg sps_enable;
reg pps_enable;
reg slice_header_enable;
reg slice_data_enable;
//reg[2:0] num_ref_idx_l0_active_minus1;

always @(posedge clk)
	if (bitstream_state== `bitstream_slice_header && slice_header_state == `slice_header_end)
		start_of_frame <= 1;
	else
		start_of_frame <= 0;
		
always @(posedge clk)
	if (bitstream_state== `bitstream_slice_data && slice_data_state == `slice_data_end)
		end_of_frame <= 1;
	else
		end_of_frame <= 0;

always @(posedge clk or negedge rst_n)
if (!rst_n)
	frame_cycle_counter <= 0;
else if (cycle_counter_ena) begin	
	if (bitstream_state == `wait_for_next_frame && 
	    frame_cycle_counter >= num_cycles_1_frame && 
	    num_cycles_1_frame != 0)
		frame_cycle_counter <= 0;
	else 
		frame_cycle_counter <= frame_cycle_counter + 1;
end


always @(posedge clk or negedge rst_n)
    if (rst_n == 0)
        begin
            sps_enable <= 0;
            pps_enable <= 0;
            slice_header_enable <= 0;
            slice_data_enable <= 0;
            pic_num <= 0;
            bitstream_state <= `rst_bitstream;
        end
    else if (ena)
        case (bitstream_state )
            `rst_bitstream:
                if (nal_unit_type == `nalu_type_sps && ext_mem_init_done)
                    begin
                        sps_enable <= 1;
                        bitstream_state <= `bitstream_sps;
                    end
            `bitstream_sps:
                if (sps_state == `sps_end)
                    begin
                        sps_enable <= 0;
                        pps_enable <= 1;
                        bitstream_state <= `bitstream_pps;
                    end
            `bitstream_pps:
                if (pps_state == `pps_end)
                    begin
                        pps_enable <= 0;
                        slice_header_enable <= 1;
                        bitstream_state <= `bitstream_slice_header;
                    end            
            `bitstream_slice_header:
                if (slice_header_state == `slice_header_end )
                    begin
                        slice_header_enable <= 0;
                        slice_data_enable <= 1;
                        bitstream_state <= `bitstream_slice_data;
                    end

            `bitstream_slice_data:
                if (slice_data_state == `slice_data_end)
                    begin
                        slice_data_enable <= 0;
								pic_num <= pic_num + 1;
                        bitstream_state <= `wait_for_next_frame;
                    end
            `wait_for_next_frame:  
				if (end_of_stream)
                    begin
                        slice_header_enable <= 0;
                        slice_data_enable <= 0;
                        pps_enable <= 0;
                        sps_enable <= 0;
                    end
             	else if (frame_cycle_counter >= num_cycles_1_frame && num_cycles_1_frame != 0)
                    begin
                        if (nal_unit_type == `nalu_type_sps)
                            begin
                               sps_enable <= 1;
                               bitstream_state <= `bitstream_sps;
                            end
                        else if (nal_unit_type == `nalu_type_pps)
                            begin
                               pps_enable <= 1;
                               bitstream_state <= `bitstream_pps;
                            end                            
                         else 
                             begin
                                 bitstream_state <= `bitstream_slice_header;
                                 slice_header_enable <= 1;
                             end  
                    end
        endcase

/*assign num_mb_in_slice = (pic_width_in_mbs_minus1+1)*(pic_height_in_map_units_minus1+1);
always @(posedge clk or negedge rst_n)
    if (rst_n == 0)
        begin
            num_ref_idx_l0_active_minus1 <= 0;
        end
    else if (ena && (
    		slice_header_state == `slice_header_end || slice_header_state == `pps_end)
		begin
			num_ref_idx_l0_active_minus1 <= num_ref_idx_active_override_flag ? 
            num_ref_idx_l0_active_minus1_slice_header : num_ref_idx_l0_active_minus1_pps;
		end
*/

assign num_ref_idx_l0_active_minus1 = num_ref_idx_active_override_flag ? 
                                      num_ref_idx_l0_active_minus1_slice_header : num_ref_idx_l0_active_minus1_pps;
  
assign forward_len = pps_enable ? forward_len_pps : (
                     sps_enable ? forward_len_sps : (
                     slice_header_enable ? forward_len_slice_header : (
                     slice_data_enable ? forward_len_slice_data : 0)));
    
            
endmodule


