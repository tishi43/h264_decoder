//--------------------------------------------------------------------------------------------------
// Design    : bitstream_p
// Author(s) : qiu bin, shi tian qi
// Email     : chat1@126.com, tishi1@126.com
// Copyright (C) 2013 qiu bin 
// All rights researved                
//-------------------------------------------------------------------------------------------------


`include "defines.v"

// used for storing intra4x4_pred_mode, ref_idx, mvp etc
// 
module ext_ram_32
(
	clk,
	wr, 
	addr, 
	data_in, 
	data_out,
	end_of_frame,
	pic_num_2to0
);

input clk;
input wr;
input[25:0] addr;
input[31:0] data_in;
output[31:0] data_out;
input end_of_frame;
input [2:0] pic_num_2to0;
reg[31:0] ram[0:8000000];
reg[31:0] data_out;

//read
always @ (posedge clk)
if (addr % 4 == 0)
  	data_out <= ram[addr/4];
else if (addr % 4 == 1) begin
	data_out[31:24] <= ram[addr/4+1][7:0];
	data_out[23:00] <= ram[addr/4][31:8];
end
else if (addr % 4 == 2) begin
	data_out[31:16] <= ram[addr/4+1][15:0];
	data_out[15:00] <= ram[addr/4][31:16];
end
else if (addr % 4 == 3) begin
	data_out[31:08] <= ram[addr/4+1][23:0];
	data_out[07:00] <= ram[addr/4][31:24];
end

//write
always @ (posedge clk)
    if (wr)
        ram[addr/4] <= data_in;

integer fp_display,j,idx;

initial
	begin
		fp_display = $fopen("display.log","w");
		while(1) begin
			@ (posedge end_of_frame);
			for (j= 0; j < (u_decode_stream.pic_width_in_mbs_minus1 + 1)*(u_decode_stream.pic_height_in_map_units_minus1+1)*96; j= j + 1) begin
	        	idx = (u_decode_stream.pic_width_in_mbs_minus1 + 1)*(u_decode_stream.pic_height_in_map_units_minus1+1)*96*pic_num_2to0 + j;
	        	$fdisplay(fp_display, "%h", ram[idx]);
	        end        
		end
	end
	
endmodule

