//--------------------------------------------------------------------------------------------------
// Design    : bitstream_p
// Author(s) : qiu bin, shi tian qi
// Email     : chat1@126.com, tishi1@126.com
// Copyright (C) 2013 qiu bin 
// All rights reserved                
//-------------------------------------------------------------------------------------------------

`include "defines.v"

//synchoronous enable signals generator
module bitstream_ena_gen
(
	ena,
	stream_mem_valid,
	rbsp_buffer_valid,
	bc_pps_ena,
	bc_sps_ena,
	bc_slice_header_ena,
	bc_slice_data_ena,
	bc_ena,
	read_nalu_ena,
	rbsp_buffer_ena,
	pps_ena,
	sps_ena,
	slice_header_ena,
	slice_data_ena,
	residual_ena,
	intra_pred_ena,
	inter_pred_ena,
	sum_ena,
	ext_mem_writer_ena,
	ext_mem_hub_ena
);
input		ena;
input       stream_mem_valid;
input		rbsp_buffer_valid;
input		bc_pps_ena;
input 		bc_sps_ena;
input		bc_slice_header_ena;
input		bc_slice_data_ena;
output      read_nalu_ena;
output      rbsp_buffer_ena;
output		bc_ena;
output		pps_ena;
output		sps_ena;
output		slice_header_ena;
output		slice_data_ena;
output		residual_ena;
output		intra_pred_ena;
output      inter_pred_ena;
output		sum_ena;
output      ext_mem_writer_ena;
output		ext_mem_hub_ena;

assign read_nalu_ena          = ena && stream_mem_valid;
assign rbsp_buffer_ena        = ena && stream_mem_valid;
assign bc_ena				  = ena && stream_mem_valid && rbsp_buffer_valid;
assign sps_ena 				  = ena && stream_mem_valid && rbsp_buffer_valid && bc_sps_ena;
assign pps_ena 				  = ena && stream_mem_valid && rbsp_buffer_valid && bc_pps_ena;
assign slice_header_ena 	  = ena && stream_mem_valid && rbsp_buffer_valid && bc_slice_header_ena;
assign slice_data_ena 		  = ena && stream_mem_valid && rbsp_buffer_valid && bc_slice_data_ena;
assign residual_ena			  = ena && stream_mem_valid && rbsp_buffer_valid;
assign intra_pred_ena		  = ena;
assign inter_pred_ena         = ena;
assign sum_ena				  = ena;
assign ext_mem_writer_ena     = ena;
assign ext_mem_hub_ena        = ena;

endmodule
