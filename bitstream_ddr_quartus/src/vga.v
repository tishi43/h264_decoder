//--------------------------------------------------------------------------------------------------
// Design    : bitstream_p
// Author(s) : qiu bin, shi tian qi
// Email     : chat1@126.com, tishi1@126.com
// Copyright (C) 2013 qiu bin 
// All rights reserved                
//-------------------------------------------------------------------------------------------------


module vga
(
	rst_n,
	clk,
	hsync,
	vsync,
	x,
	y,
	valid,
	y_valid
);
//Horizontal timing constants
parameter H_FRONT		= 'd8;
parameter H_SYNC        = 'd96;
parameter H_BACK        = 'd40;
parameter H_ACT         = 'd656;
parameter H_BLANK_END   =  H_FRONT+H_SYNC+H_BACK-1;
parameter H_PERIOD      =  H_FRONT+H_SYNC+H_BACK+H_ACT;
//Vertical timing constants
parameter V_FRONT       = 'd2;
parameter V_SYNC        = 'd2;
parameter V_BACK        = 'd25;
parameter V_ACT         = 'd496;
parameter V_BLANK_END   =  V_FRONT+V_SYNC+V_BACK-1;
parameter V_PERIOD      =  V_FRONT+V_SYNC+V_BACK+V_ACT;

input        rst_n;
input        clk;
output       hsync;
output       vsync;
output       valid;
output       y_valid;
output [10:0] x;
output [10:0] y;

reg          hsync;
reg          vsync;
reg          valid;
reg          y_valid;
reg [10:0]   x;
reg [10:0]   y;
reg [10:0]   hcnt;
reg [10:0]   vcnt;


//hsync
always @ (posedge clk or negedge rst_n)
begin
	if(!rst_n)
	begin
		hcnt <= 0;
		hsync <= 1;
	end
	else
	begin
		if(hcnt<H_PERIOD)
			hcnt <= hcnt + 1;  
		else 
			hcnt <= 0;
		if (hcnt == H_FRONT-1)
			hsync <= 1'b0;
		else if (hcnt == H_FRONT+H_SYNC-1)
			hsync <= 1'b1;
	end
end
  
 
//vsync
always @ (posedge clk or negedge rst_n)
begin
	if(!rst_n)
	begin
		vcnt <=  0;
		vsync <= 1;
	end
	else
	begin 
		if (hcnt == H_FRONT+H_SYNC-1)
		begin
			if(vcnt<V_PERIOD)
				vcnt <= vcnt + 1;  
			else 
				vcnt <= 0;
			if (vcnt == V_FRONT-1)
				vsync <= 1'b0;
			else if (vcnt == V_FRONT+V_SYNC-1)
				vsync <= 1'b1;
		end
	end
end
    
//valid 
always @ (posedge clk or negedge rst_n)
begin
	if (!rst_n)
	begin
		valid <= 0;
		y_valid <= 0;
	end
	else
	begin
		valid <= hcnt >= H_BLANK_END && vcnt >= V_BLANK_END;
		y_valid <= vcnt >= V_BLANK_END;
	end
end

//x & y
always @ (posedge clk or negedge rst_n)
begin
	if (!rst_n)
	begin
		x <= 0;
		y <= 0;
	end
	else
	begin
		x <= hcnt >= H_BLANK_END ? hcnt-H_BLANK_END : 0;
		y <= vcnt >= V_BLANK_END ? vcnt-V_BLANK_END : 0;
	end
end

endmodule
   
     
    

