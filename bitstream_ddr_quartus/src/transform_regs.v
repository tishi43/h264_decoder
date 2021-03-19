//--------------------------------------------------------------------------------------------------
// Design    : bitstream_p
// Author(s) : qiu bin, shi tian qi
// Email     : chat1@126.com, tishi1@126.com
// Copyright (C) 2013 qiu bin 
// All rights reserved                
//-------------------------------------------------------------------------------------------------


`include "defines.v"

module transform_DC_regs
(
	clk,
	rst_n,
	ena,
	residual_state,
	wr_idx,
	wr,
	clr,
	rd_idx,
	rd,
	data_in_0,
	data_in_1,
	data_in_2,
	data_in_3,
	
	data_out
);
//------------
// ports
//-------------
input clk;
input rst_n;
input ena;
input [3:0] residual_state;
input [1:0] wr_idx;
input wr;
input clr;
input [3:0] rd_idx;
input rd;
input [15:0] data_in_0;
input [15:0] data_in_1;
input [15:0] data_in_2;
input [15:0] data_in_3;

output [15:0] data_out;

//------------------
// FFs
//-----------------
reg [15:0] data_out;

reg [15:0] reg_0;
reg [15:0] reg_1;  
reg [15:0] reg_2;  
reg [15:0] reg_3;  
reg [15:0] reg_4;  
reg [15:0] reg_5;  
reg [15:0] reg_6;  
reg [15:0] reg_7;  
reg [15:0] reg_8;  
reg [15:0] reg_9;  
reg [15:0] reg_10;
reg [15:0] reg_11;
reg [15:0] reg_12;
reg [15:0] reg_13;
reg [15:0] reg_14;
reg [15:0] reg_15;

reg [15:0] Cb_reg_0;
reg [15:0] Cb_reg_1;
reg [15:0] Cb_reg_2;  
reg [15:0] Cb_reg_3; 
 
reg [15:0] Cr_reg_0;  
reg [15:0] Cr_reg_1;  
reg [15:0] Cr_reg_2;  
reg [15:0] Cr_reg_3;  

always @(posedge clk or negedge rst_n)
if (!rst_n)
begin
	reg_0  <= 0;
	reg_1  <= 0;
	reg_2  <= 0;
	reg_3  <= 0;
	reg_4  <= 0;
	reg_5  <= 0;
	reg_6  <= 0;
	reg_7  <= 0;
	reg_8  <= 0;
	reg_9  <= 0;
	reg_10 <= 0;
	reg_11 <= 0;
	reg_12 <= 0;
	reg_13 <= 0;
	reg_14 <= 0;
	reg_15 <= 0;
	Cb_reg_0 <= 0;
	Cb_reg_1 <= 0;
	Cb_reg_2 <= 0;
	Cb_reg_3 <= 0;
	Cr_reg_0 <= 0;   
	Cr_reg_1 <= 0;   
	Cr_reg_2 <= 0;   
	Cr_reg_3 <= 0;	 
end
else if (ena && clr)
begin
	reg_0  <= 0;
	reg_1  <= 0;
	reg_2  <= 0;
	reg_3  <= 0;
	reg_4  <= 0;
	reg_5  <= 0;
	reg_6  <= 0;
	reg_7  <= 0;
	reg_8  <= 0;
	reg_9  <= 0;
	reg_10 <= 0;
	reg_11 <= 0;
	reg_12 <= 0;
	reg_13 <= 0;
	reg_14 <= 0;
	reg_15 <= 0;
	Cb_reg_0 <= 0;
	Cb_reg_1 <= 0;
	Cb_reg_2 <= 0;
	Cb_reg_3 <= 0;
	Cr_reg_0 <= 0;   
	Cr_reg_1 <= 0;   
	Cr_reg_2 <= 0;   
	Cr_reg_3 <= 0;	 
end
else  if(ena && wr && residual_state == `Intra16x16DCLevel_s)//luma16x16DC
	case (wr_idx)
	0:
		begin 
			reg_0 <= data_in_0; reg_1 <= data_in_1;
			reg_4 <= data_in_2; reg_5 <= data_in_3;			
		end
	1:		
		begin 
			reg_2 <= data_in_0; reg_3 <= data_in_1;
			reg_6 <= data_in_2; reg_7 <= data_in_3;			
		end
	2:		
		begin 
			reg_8 <= data_in_0; reg_9 <= data_in_1;
			reg_12 <= data_in_2; reg_13 <= data_in_3;			
		end
	default:
		begin 
			reg_10 <= data_in_0; reg_11 <= data_in_1;
			reg_14 <= data_in_2; reg_15 <= data_in_3;			
		end
	endcase
else  if(ena && wr && residual_state == `ChromaDCLevel_Cb_s)
	begin 
		Cb_reg_0 <= data_in_0; Cb_reg_2 <= data_in_1;
		Cb_reg_3 <= data_in_2; Cb_reg_1 <= data_in_3;			
	end
else if (ena && wr && residual_state == `ChromaDCLevel_Cr_s)
	begin 
		Cr_reg_0 <= data_in_0; Cr_reg_2 <= data_in_1;   
		Cr_reg_3 <= data_in_2; Cr_reg_1 <= data_in_3;		
	end
	
always @(posedge clk or negedge rst_n)
if (!rst_n)
	data_out <= 0;
else  if(ena && rd && (residual_state ==`Intra16x16ACLevel_s || residual_state == `Intra16x16ACLevel_0_s))//lumaAC
	case (rd_idx)
	0:data_out <= reg_0;
	1:data_out <= reg_1;
	2:data_out <= reg_2;
	3:data_out <= reg_3;
	4:data_out <= reg_4;
	5:data_out <= reg_5;
	6:data_out <= reg_6;
	7:data_out <= reg_7;
	8:data_out <= reg_8;
	9:data_out <= reg_9;
	10:data_out <= reg_10;
	11:data_out <= reg_11;
	12:data_out <= reg_12;
	13:data_out <= reg_13;
	14:data_out <= reg_14;
	default:data_out <= reg_15;
	endcase
else  if(ena && rd)
	case (rd_idx)
	0:data_out <= Cb_reg_0;
	1:data_out <= Cb_reg_1;
	2:data_out <= Cb_reg_2;
	3:data_out <= Cb_reg_3;
	4:data_out <= Cr_reg_0;
	5:data_out <= Cr_reg_1;
	6:data_out <= Cr_reg_2;
	default:data_out <= Cr_reg_3;
	endcase

endmodule


module transform_regs
(
	clk,
	rst_n,
	ena,
	
	curr_DC,
	
	AC_all_0_wr,
	IQ_wr,
	DHT_wr,
	IDCT_wr,
	wr_col,
	wr_idx,
	block_type,
	
	rd_idx,
	rd,
	rd_col,
	IQ_out_0,
	IQ_out_1,
	IQ_out_2,
	IQ_out_3,
	butterfly_out_0,
	butterfly_out_1,
	butterfly_out_2,
	butterfly_out_3,
	
	data_out_0,
	data_out_1,
	data_out_2,
	data_out_3,
	
	rounding_out_0,
	rounding_out_1,
	rounding_out_2,
	rounding_out_3,
	rounding_out_4,
	rounding_out_5,
	rounding_out_6,
	rounding_out_7,
	rounding_out_8,
	rounding_out_9,
	rounding_out_10,
	rounding_out_11,
	rounding_out_12,
	rounding_out_13,
	rounding_out_14,
	rounding_out_15
	
);  
//------------
// ports
//-------------
input clk;
input rst_n;
input ena;
    
input [15:0] curr_DC;
wire signed [15:0] curr_DC;  
input AC_all_0_wr;
input IQ_wr;
input DHT_wr;
input IDCT_wr;

input [1:0] wr_idx;
input wr_col;

input [1:0] rd_idx;
input rd;
input rd_col;
input [2:0] block_type;

input [15:0] IQ_out_0;
input [15:0] IQ_out_1;
input [15:0] IQ_out_2;
input [15:0] IQ_out_3;

input [15:0] butterfly_out_0;
input [15:0] butterfly_out_1;
input [15:0] butterfly_out_2;
input [15:0] butterfly_out_3;
    
output [15:0]	data_out_0;
output [15:0]	data_out_1;
output [15:0]	data_out_2;
output [15:0]	data_out_3;
output [8:0]	rounding_out_0;
output [8:0]	rounding_out_1;
output [8:0]	rounding_out_2;
output [8:0]	rounding_out_3;
output [8:0]	rounding_out_4;
output [8:0]	rounding_out_5;
output [8:0]	rounding_out_6;
output [8:0]	rounding_out_7;
output [8:0]	rounding_out_8;
output [8:0]	rounding_out_9;
output [8:0]	rounding_out_10;
output [8:0]	rounding_out_11;
output [8:0]	rounding_out_12;
output [8:0]	rounding_out_13;
output [8:0]	rounding_out_14;
output [8:0]	rounding_out_15;

reg signed [15:0]	data_out_0;
reg signed [15:0]	data_out_1;
reg signed [15:0]	data_out_2;
reg signed [15:0]	data_out_3;

//------------------
// FFs
//-----------------
reg signed [15:0] reg_0;
reg signed [15:0] reg_1;  
reg signed [15:0] reg_2;  
reg signed [15:0] reg_3;  
reg signed [15:0] reg_4;  
reg signed [15:0] reg_5;  
reg signed [15:0] reg_6;  
reg signed [15:0] reg_7;  
reg signed [15:0] reg_8;  
reg signed [15:0] reg_9;  
reg signed [15:0] reg_10;
reg signed [15:0] reg_11;
reg signed [15:0] reg_12;
reg signed [15:0] reg_13;
reg signed [15:0] reg_14;
reg signed [15:0] reg_15;

reg signed [8:0] rounding_0;
reg signed [8:0] rounding_1;
reg signed [8:0] rounding_2;
reg signed [8:0] rounding_3;


always @(*)
	begin
		rounding_0 = (butterfly_out_0+32) >>> 6;																																						
		rounding_1 = (butterfly_out_1+32) >>> 6;																																				
		rounding_2 = (butterfly_out_2+32) >>> 6;								
		rounding_3 = (butterfly_out_3+32) >>> 6;																																							
	end
	
assign rounding_out_0 = reg_0[8:0];
assign rounding_out_1 = reg_1[8:0];	
assign rounding_out_2 = reg_2[8:0];
assign rounding_out_3 = reg_3[8:0];
assign rounding_out_4 = reg_4[8:0];
assign rounding_out_5 = reg_5[8:0];
assign rounding_out_6 = reg_6[8:0];
assign rounding_out_7 = reg_7[8:0];
assign rounding_out_8 = reg_8[8:0];
assign rounding_out_9 = reg_9[8:0];
assign rounding_out_10 = reg_10[8:0];
assign rounding_out_11 = reg_11[8:0];
assign rounding_out_12 = reg_12[8:0];
assign rounding_out_13 = reg_13[8:0];
assign rounding_out_14 = reg_14[8:0];
assign rounding_out_15 = reg_15[8:0];
wire signed [8:0] curr_DC_rounded;
assign curr_DC_rounded = (curr_DC + 32) >>> 6;

always @(posedge clk or negedge rst_n)
if (!rst_n) begin
	reg_0  <= 0;
	reg_1  <= 0;
	reg_2  <= 0;
	reg_3  <= 0;
	reg_4  <= 0;
	reg_5  <= 0;
	reg_6  <= 0;
	reg_7  <= 0;
	reg_8  <= 0;
	reg_9  <= 0;
	reg_10 <= 0;
	reg_11 <= 0;
	reg_12 <= 0;
	reg_13 <= 0;
	reg_14 <= 0;
	reg_15 <= 0;
end
else  if(ena && AC_all_0_wr) begin
	reg_0  <= curr_DC_rounded;
	reg_1  <= curr_DC_rounded;
	reg_2  <= curr_DC_rounded;
	reg_3  <= curr_DC_rounded;
	reg_4  <= curr_DC_rounded;
	reg_5  <= curr_DC_rounded;
	reg_6  <= curr_DC_rounded;
	reg_7  <= curr_DC_rounded;
	reg_8  <= curr_DC_rounded;
	reg_9  <= curr_DC_rounded;
	reg_10 <= curr_DC_rounded;
	reg_11 <= curr_DC_rounded;
	reg_12 <= curr_DC_rounded;
	reg_13 <= curr_DC_rounded;
	reg_14 <= curr_DC_rounded;
	reg_15 <= curr_DC_rounded; 
end
else  if(ena && IQ_wr && (block_type == 1 || block_type == 5))
	case (wr_idx)
	0:
		begin 
			reg_0 <= IQ_out_0; reg_1 <= IQ_out_1;
			reg_2 <= IQ_out_2; reg_3 <= IQ_out_3;			
		end
	1:		
		begin 
			reg_4 <= IQ_out_0; reg_5 <= IQ_out_1;
			reg_6 <= IQ_out_2; reg_7 <= IQ_out_3;			
		end
	2:		
		begin 
			reg_8 <= IQ_out_0;  reg_9  <= IQ_out_1;
			reg_10 <= IQ_out_2; reg_11 <= IQ_out_3;			
		end
	default:
		begin 
			reg_12 <= IQ_out_0; reg_13 <= IQ_out_1;
			reg_14 <= IQ_out_2; reg_15 <= IQ_out_3;			
		end
	endcase
else if (ena && IQ_wr)
	case (wr_idx)
	0:
		begin 
			reg_0 <= IQ_out_0; reg_4  <= IQ_out_1;
			reg_8 <= IQ_out_2; reg_12 <= IQ_out_3;			
		end
	1:		
		begin 
			reg_1 <= IQ_out_0; reg_5  <= IQ_out_1;
			reg_9 <= IQ_out_2; reg_13 <= IQ_out_3;			
		end
	2:		
		begin 
			reg_2 <= IQ_out_0;  reg_6  <= IQ_out_1;
			reg_10 <= IQ_out_2; reg_14 <= IQ_out_3;			
		end
	default:
		begin 
			reg_3 <= IQ_out_0; reg_7 <= IQ_out_1;
			reg_11 <= IQ_out_2; reg_15 <= IQ_out_3;			
		end
	endcase
else  if(ena && wr_col && (DHT_wr || IDCT_wr))
	case (wr_idx)
	0:
		begin 
			reg_0 <= butterfly_out_0; reg_4 <= butterfly_out_1;
			reg_8 <= butterfly_out_2; reg_12 <= butterfly_out_3;			
		end
	1:		
		begin 
			reg_1 <= butterfly_out_0; reg_5 <= butterfly_out_1;
			reg_9 <= butterfly_out_2; reg_13 <= butterfly_out_3;			
		end
	2:		
		begin 
			reg_2 <= butterfly_out_0; reg_6 <= butterfly_out_1;
			reg_10 <= butterfly_out_2; reg_14 <= butterfly_out_3;			
		end
	default:
		begin 
			reg_3 <= butterfly_out_0; reg_7 <= butterfly_out_1;
			reg_11 <= butterfly_out_2; reg_15 <= butterfly_out_3;			
		end
	endcase
else  if ( ena && DHT_wr)
	case (wr_idx)
	0:
		begin 
			reg_0 <= butterfly_out_0; reg_1 <= butterfly_out_1;
			reg_2 <= butterfly_out_2; reg_3 <= butterfly_out_3;			
		end
	1:		
		begin 
			reg_4 <= butterfly_out_0; reg_5 <= butterfly_out_1;
			reg_6 <= butterfly_out_2; reg_7 <= butterfly_out_3;			
		end
	2:		
		begin 
			reg_8 <= butterfly_out_0; reg_9 <= butterfly_out_1;
			reg_10 <= butterfly_out_2; reg_11 <= butterfly_out_3;			
		end
	default:
		begin 
			reg_12 <= butterfly_out_0; reg_13 <= butterfly_out_1;
			reg_14 <= butterfly_out_2; reg_15 <= butterfly_out_3;			
		end
	endcase
else  if ( ena && IDCT_wr)
	case (wr_idx)
	0:
		begin 
			reg_0 <= rounding_0; reg_1  <= rounding_1;
			reg_2 <= rounding_2; reg_3  <= rounding_3;			
		end
	1:		
		begin 
			reg_4 <= rounding_0; reg_5  <= rounding_1;
			reg_6 <= rounding_2; reg_7  <= rounding_3;			
		end
	2:		
		begin 
			reg_8  <= rounding_0; reg_9  <= rounding_1;
			reg_10 <= rounding_2; reg_11 <= rounding_3;			
		end
	default:
		begin 
			reg_12 <= rounding_0; reg_13 <= rounding_1;
			reg_14 <= rounding_2; reg_15 <= rounding_3;			
		end
	endcase
	
always @(*)
if(rd && rd_col)
	case (rd_idx)
	0:
		begin 
			data_out_0 <= reg_0; data_out_1 <= reg_4;
			data_out_2 <= reg_8; data_out_3 <= reg_12;			
		end
	1:		
		begin 
			data_out_0 <= reg_1; data_out_1 <= reg_5;   
			data_out_2 <= reg_9; data_out_3 <= reg_13;		
		end
	2:		
		begin 
			data_out_0 <= reg_2; data_out_1 <= reg_6;   
			data_out_2 <= reg_10; data_out_3 <= reg_14;				
		end
	3:      
		begin    
			data_out_0 <= reg_3; data_out_1 <= reg_7;   
			data_out_2 <= reg_11; data_out_3 <= reg_15;			
		end      
	default:     
		begin    
			data_out_0 <= 'bx; data_out_1 <= 'bx;   
			data_out_2 <= 'bx; data_out_3 <= 'bx;			
		end      
	endcase      
else if(rd)
    case (rd_idx)
	0:
		begin 
			data_out_0 <= reg_0; data_out_1 <= reg_1;
			data_out_2 <= reg_2; data_out_3 <= reg_3;			
		end
	1:		
		begin 
			data_out_0 <= reg_4; data_out_1 <= reg_5;   
			data_out_2 <= reg_6; data_out_3 <= reg_7;		
		end
	2:		
		begin 
			data_out_0 <= reg_8; data_out_1 <= reg_9;   
			data_out_2 <= reg_10; data_out_3 <= reg_11;				
		end
	3:      
		begin    
			data_out_0 <= reg_12; data_out_1 <= reg_13;   
			data_out_2 <= reg_14; data_out_3 <= reg_15;			
		end      
	default:     
		begin    
			data_out_0 <= 'bx; data_out_1 <= 'bx;   
			data_out_2 <= 'bx; data_out_3 <= 'bx;			
		end      
	endcase 
else begin
	data_out_0  <= 0;
	data_out_1  <= 0;
	data_out_2  <= 0;
	data_out_3  <= 0;
end


endmodule
