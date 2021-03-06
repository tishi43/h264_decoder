//--------------------------------------------------------------------------------------------------
// Design    : bitstream_p
// Author(s) : qiu bin, shi tian qi
// Email     : chat1@126.com, tishi1@126.com
// Copyright (C) 2013 qiu bin 
// All rights reserved                
//-------------------------------------------------------------------------------------------------


module play_pause
(
 clk,
 rst_n,
 key1,
 num_cycles_1_frame
);
input clk;
input rst_n;
input key1;
output [23:0] num_cycles_1_frame;

reg key1_internal;
reg key1_internal_s;
reg [17:0] high;
reg [17:0] low;
reg led1;
reg [23:0] num_cycles_1_frame;

always @ (posedge clk or negedge rst_n)
if (!rst_n) begin
	high <= 0;
	low  <= 0;
	key1_internal <= 0;
end
else if (key1) begin
	if (high == 17'h1ffff) begin
		key1_internal <= 1;
		high <= 0;
		low <= 0;
	end
	else begin
		high <= high + 1;
		low <= 0;
	end
end
else begin
	if (low == 17'h1ffff) begin
		key1_internal <= 0;
		high <= 0;
		low <= 0;
	end
	else begin
		low <= low + 1;
		high <= 0;
	end
end

always @(posedge clk)
	key1_internal_s <= key1_internal;
	
always @(posedge clk or negedge rst_n)
if (!rst_n) begin
	num_cycles_1_frame <= 0;
	//synopsys translate_off
	num_cycles_1_frame <= 1;
	//synopsys translate_on
end
else if(!key1_internal && key1_internal_s && num_cycles_1_frame == 0)
	num_cycles_1_frame <= 1000000;//25M @ 25fps
	//num_cycles_1_frame <= 1200000;//30M @ 25fps
	//num_cycles_1_frame <= 1120000;//28M @ 25fps
else if(!key1_internal && key1_internal_s && num_cycles_1_frame != 0)
	num_cycles_1_frame <= 0;
	
endmodule
