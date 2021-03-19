//--------------------------------------------------------------------------------------------------
// Design    : bitstream_p
// Author(s) : qiu bin, shi tian qi
// Email     : chat1@126.com, tishi1@126.com
// Copyright (C) 2013 qiu bin 
// All rights reserved                
//-------------------------------------------------------------------------------------------------


module yuv2rgb (
  clk,
  rst_n,
  y,
  u,
  v,
  r,
  g,
  b
);
input			clk;
input			rst_n;
input 	[7:0]	y;
input	[7:0]	u;
input 	[7:0]	v;
output	[7:0]	r;
output	[7:0]	g;
output	[7:0]	b;

//
//regs
//
reg  [7:0]  r,g,b;
reg  [9:0] r_tmp;
reg  [9:0] g_tmp;
reg  [9:0] b_tmp;

always@(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    r   		<= 0;
    g	  		<= 0;
    b   		<= 0;
  end
  else begin
    if (r_tmp[9])
      r <= 0;
    else if (r_tmp[8:0] > 255)
      r <= 255;
    else
      r <= r_tmp[7:0];

    if (g_tmp[9])
      g <= 0;
    else if (g_tmp[8:0] > 255)
      g <= 255;
    else
      g <= g_tmp[7:0];
      
    if (b_tmp[9])
      b <= 0;
    else if (b_tmp[8:0] > 255)
      b <= 255;
    else
      b <= b_tmp[7:0];
  end
end

/*
R = 1.164(Y-16) + 1.596(Cr-128)
G = 1.164(Y-16) - 0.391(Cb-128) - 0.813(Cr-128)
B = 1.164(Y-16) + 2.018(Cb-128)

R << 9 = 596Y  + 817Cr          - 114131
G << 9 = 596Y  - 416Cr - 200Cb  + 69370
B << 9 = 596Y          + 1033Cb - 141787
*/

always@(*) begin
    r_tmp <= ( y*596 + v*817 - 114131 ) >>9;
    g_tmp <= ( y*596 - u*200 - v*416 + 69370) >>9;
    b_tmp <= ( y*596 + u*1033 - 141787 ) >>9;
end

endmodule