//--------------------------------------------------------------------------------------------------
// Design    : bitstream_p
// Author(s) : qiu bin, shi tian qi
// Email     : chat1@126.com, tishi1@126.com
// Copyright (C) 2013 qiu bin 
// All rights reserved                
//-------------------------------------------------------------------------------------------------


`include "defines.v"

module transform_fsm
(
	clk,
	rst_n,
	ena,
	start,
	
	QP,
	QP_C,
	curr_QP,
	TotalCoeff,
	residual_state,
	luma4x4BlkIdx_residual,
	chroma4x4BlkIdx_residual,
	state,
	block_type,
	counter,
	DC_wr_comb,
	DC_rd_idx,
	IQ_wr_comb,
	DHT_wr_comb,
	IDCT_wr_comb,
	AC_all_0_wr_comb,
	rd_comb,
	valid
);
//---------------------
//ports
//---------------------
input clk;
input rst_n;
input ena;
input start;
input  [4:0] TotalCoeff;
input  [3:0] residual_state;
input  [3:0] luma4x4BlkIdx_residual;
input  [1:0] chroma4x4BlkIdx_residual;

output [3:0] state;
input  [5:0] QP;
input  [5:0] QP_C;
output [5:0] curr_QP;

output [2:0] block_type;
output [2:0] counter;

output [3:0] DC_rd_idx;

output DC_wr_comb;
output IQ_wr_comb; 
output DHT_wr_comb;
output IDCT_wr_comb;
output AC_all_0_wr_comb;

output rd_comb;
output valid;

//--------------------
// FFs
//--------------------
reg [3:0] state;
reg [2:0] counter;
reg [2:0] block_type;
reg [5:0] curr_QP;
reg valid;

//----------------------
//regs
//----------------------
reg  DC_wr_comb;
reg  [3:0] DC_rd_idx;
reg  IQ_wr_comb;
reg  DHT_wr_comb;
reg  IDCT_wr_comb;
reg  AC_all_0_wr_comb;
reg  rd_comb;
reg  [2:0] block_type_comb;
reg  [3:0]  next_state;
reg DC_sel;

//------------------
//transform_state
//------------------
always @(posedge clk or negedge rst_n)
if (!rst_n)
	state <= `transform_idle_s;
else if (ena)
	state <= next_state;

//---------------------
// block_type 
//---------------------
// block_type =	1:  Intra16x16LumaDC
//				2:	Intra16x16LumaAC
//				3:  Luma4x4
//				
//				5:  ChromaDC
//				6:  ChromaAC
//				0:  Others
wire AC_all_0_sel;
assign AC_all_0_sel = block_type_comb == 0 
			|| block_type_comb == 2 && TotalCoeff == 0 
			|| block_type_comb == 3 && TotalCoeff == 0
			|| block_type_comb == 6 && TotalCoeff == 0;

always @(*)
case (state)
`transform_idle_s:
	if (start) begin
		if (AC_all_0_sel) begin				//All 0 block
			next_state <= `transform_AC_all_0_s;
		end
		else
		case(block_type_comb)
		1:			next_state <= `transform_DHT_s;
		5:			next_state <= `transform_DHT2_s;
		default:	next_state <= `transform_IQ_s;
		endcase
	end
	else
		next_state <= state;
`transform_DHT_s:	begin
	if (counter == 0) 
		next_state <= `transform_IQ_s;	
	else
		next_state <= state;	
end
`transform_DHT2_s:begin
	if (counter == 0) 
		next_state <= `transform_IQ_s;	
	else
		next_state <= state;
end
`transform_IQ_s:begin
	if (counter == 0 && block_type != 1 && block_type != 5)
		next_state <= `transform_IDCT_s;
	else if (counter == 0)
		next_state <= `transform_idle_s;
	else
		next_state <= state;
end
`transform_IDCT_s:begin
	if (counter == 0) 
		next_state <= `transform_idle_s;
	else
		next_state <= state;
end
`transform_AC_all_0_s:begin
	next_state <= `transform_idle_s;
end
default: next_state <= state;
endcase


always @(*)
	case(residual_state)
	`Intra16x16DCLevel_s:	block_type_comb <= 1;
	`Intra16x16ACLevel_s:	block_type_comb <= 2;
	`LumaLevel_s:			block_type_comb <= 3;
	`ChromaDCLevel_Cb_s,`ChromaDCLevel_Cr_s:	block_type_comb <= 5;
	`ChromaACLevel_Cb_s,`ChromaACLevel_Cr_s:	block_type_comb <= 6;
	default:	block_type_comb <= 0;
	endcase 

always @(*)
	case(residual_state)
	`Intra16x16DCLevel_s,
	`ChromaDCLevel_Cb_s,
	`ChromaDCLevel_Cr_s:	DC_sel <= 1;
	default:				DC_sel <= 0;
	endcase 

always @(posedge clk or negedge rst_n)
if (!rst_n)
	block_type <= 0;
else if(ena && start)begin
	block_type <= block_type_comb;
end

//----------------------
// curr_QP
//----------------------
always @(posedge clk or negedge rst_n)
if (!rst_n)
	curr_QP <= 0;
else if(ena && start)begin
	if (block_type_comb == 1 || block_type_comb == 2 || block_type_comb == 3)
		curr_QP <= QP;
	else
		curr_QP <= QP_C;
end

//--------------------
// counter
//--------------------
always @(posedge clk or negedge rst_n)
if (!rst_n)
	counter <= 0;
else if (ena) begin
	case (state)
	`transform_idle_s :	begin
		if (start) begin
			if (next_state == `transform_AC_all_0_s)
			   counter <= 0;
			else if (next_state == `transform_DHT_s)
				counter <= 7;
			else if (next_state == `transform_DHT2_s)
				counter <= 0;
			else
				counter <= 3;
		end
	end
	`transform_DHT_s: begin
		if (next_state == `transform_IQ_s)
			counter <= 3;
		else 
			counter <= counter - 1;
	end	
	`transform_DHT2_s:begin
		if (next_state == `transform_IQ_s)
			counter <= 0;
		else
			counter <= counter - 1;
	end
	`transform_IQ_s:begin
		if(next_state == `transform_IDCT_s)
			counter <= 7;
		else
			counter <= counter - 1;
	end
	`transform_IDCT_s:begin
		counter <= counter - 1;
	end
	endcase
end

//------------------
// valid
//------------------
always @(posedge clk or negedge rst_n)
if(!rst_n)
	valid <= 0;
else if (ena) begin
	if (start && state == `transform_idle_s)
		valid <= 0;
	else if (state == `transform_AC_all_0_s ||
			 state == `transform_IDCT_s && counter == 0)
		valid <= 1;
	else if (state == `transform_IQ_s && counter == 0 &&
			 (block_type == 1 || block_type== 5))
		valid <= 1;
end

//-----------------
//DC_wr_comb
//-----------------
always @(*)
if(DC_sel && state == `transform_IQ_s)
	DC_wr_comb <= 1;
else
	DC_wr_comb <= 0;

	
//-----------------
//DC_rd_idx      
//-----------------  
always @(*)
if(residual_state == `Intra16x16ACLevel_s || residual_state == `Intra16x16ACLevel_0_s)
	DC_rd_idx <= luma4x4BlkIdx_residual;
else if (residual_state == `ChromaACLevel_Cb_s || residual_state == `ChromaACLevel_Cb_0_s )
	DC_rd_idx <= {2'b00,chroma4x4BlkIdx_residual};
else if (residual_state == `ChromaACLevel_Cr_s || residual_state == `ChromaACLevel_Cr_0_s)
	DC_rd_idx <= {2'b01,chroma4x4BlkIdx_residual};
else
	DC_rd_idx <= 0;

	
//-----------------
//IDCT_wr_comb                  
//-----------------           
always @(*)         
if(state == `transform_IDCT_s)
	IDCT_wr_comb <= 1;
else
	IDCT_wr_comb <= 0;

always @(*)         
if(state == `transform_DHT_s || state == `transform_DHT2_s)
	DHT_wr_comb <= 1;
else
	DHT_wr_comb <= 0;
	
//-----------------
//IQ_wr_comb                  
//-----------------           
always @(*)         
if(state == `transform_IQ_s)
	IQ_wr_comb <= 1;
else
	IQ_wr_comb <= 0;
	
//-----------------
//rounding_wr_comb                  
//-----------------           
always @(*)         
if(state == `transform_AC_all_0_s)
	AC_all_0_wr_comb <= 1;
else
	AC_all_0_wr_comb <= 0;

//--------------------------
//rd_comb                 
//--------------------------
always @(*)         
if((state == `transform_DHT_s && !counter[2])
	 || state == `transform_IDCT_s
	 || state == `transform_IQ_s ) begin
	rd_comb <= 1;
end
else begin
	rd_comb <= 0;	
end


endmodule
