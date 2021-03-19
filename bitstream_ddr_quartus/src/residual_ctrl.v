//--------------------------------------------------------------------------------------------------
// Design    : bitstream_p
// Author(s) : qiu bin, shi tian qi
// Email     : chat1@126.com, tishi1@126.com
// Copyright (C) 2013 qiu bin 
// All rights reserved                
//-------------------------------------------------------------------------------------------------


`include "defines.v"

module residual_ctrl
(
	clk,
	rst_n,
	ena,
	residual_state,
	residual_start,
	residual_valid,
	cavlc_start,
	cavlc_valid,
	transform_start,
	transform_valid
);
input  clk;
input  rst_n;
input  ena;
input  [3:0] residual_state;
input  residual_start;
output residual_valid;
output cavlc_start;
input  cavlc_valid;
output transform_start;
input  transform_valid;

//FFs
reg cavlc_valid_s;
reg transform_valid_s;
reg transform_finished;

always @(posedge clk or negedge rst_n)
begin
	if (!rst_n) begin
		cavlc_valid_s     <= 0;
		transform_valid_s <= 0;
	end
	else if (ena) begin
		cavlc_valid_s     <= cavlc_valid;
		transform_valid_s <= transform_valid;
	end
end


wire all0_blk;
wire cavlc_finish;
wire transform_finish;

assign all0_blk = (residual_state == `Intra16x16ACLevel_0_s ||
				   residual_state == `LumaLevel_0_s ||
				   residual_state == `ChromaACLevel_Cb_0_s ||
				   residual_state == `ChromaACLevel_Cr_0_s );
				   
assign cavlc_start = residual_start && !all0_blk;
assign cavlc_finish = cavlc_valid && !cavlc_valid_s;
assign transform_start = residual_start && all0_blk || cavlc_finish;
assign transform_finish = transform_valid && !transform_valid_s;

always @(posedge clk or negedge rst_n)
begin
	if (!rst_n) 
		transform_finished <= 0;
	else if (ena) begin
		if (residual_start)
			transform_finished <= 0;
		else if (transform_finish)
			transform_finished <= 1;
	end
end
assign residual_valid = transform_finish || transform_finished;


endmodule
