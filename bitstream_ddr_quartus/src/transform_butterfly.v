//--------------------------------------------------------------------------------------------------
// Design    : bitstream_p
// Author(s) : qiu bin, shi tian qi
// Email     : chat1@126.com, tishi1@126.com
// Copyright (C) 2013 qiu bin 
// All rights reserved                
//-------------------------------------------------------------------------------------------------


module transform_butterfly
(
	DHT_sel,
	butterfly_in_0,
	butterfly_in_1,
	butterfly_in_2,
	butterfly_in_3,
	butterfly_out_0,
	butterfly_out_1,
	butterfly_out_2,
	butterfly_out_3
);
input DHT_sel;
input signed [15:0] butterfly_in_0;
input signed [15:0] butterfly_in_1;
input signed [15:0] butterfly_in_2;
input signed [15:0] butterfly_in_3;

output signed [15:0] butterfly_out_0;
output signed [15:0] butterfly_out_1;
output signed [15:0] butterfly_out_2;
output signed [15:0] butterfly_out_3;

wire signed [15:0] temp_0;
wire signed [15:0] temp_1;
wire signed [15:0] temp_2;
wire signed [15:0] temp_3;

wire signed [15:0] butterfly_tmp_1;
wire signed [15:0] butterfly_tmp_3;

assign butterfly_tmp_1 = DHT_sel?butterfly_in_1:butterfly_in_1>>>1;
assign butterfly_tmp_3 = DHT_sel?butterfly_in_3:butterfly_in_3>>>1;

assign	temp_0 = butterfly_in_0 + butterfly_in_2;																									
assign	temp_1 = butterfly_in_0 - butterfly_in_2;																									
assign	temp_2 = butterfly_tmp_1 - butterfly_in_3;																									
assign	temp_3 = butterfly_tmp_3 + butterfly_in_1;																									
assign	butterfly_out_0 = temp_0 + temp_3;																									
assign	butterfly_out_1 = temp_1 + temp_2;																									
assign	butterfly_out_2 = temp_1 - temp_2;																									
assign	butterfly_out_3 = temp_0 - temp_3;


endmodule