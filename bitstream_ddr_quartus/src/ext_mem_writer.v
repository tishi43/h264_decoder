//--------------------------------------------------------------------------------------------------
// Design    : bitstream_p
// Author(s) : qiu bin, shi tian qi
// Email     : chat1@126.com, tishi1@126.com
// Copyright (C) 2013 qiu bin 
// All rights reserved                
//-------------------------------------------------------------------------------------------------

`include "defines.v"

module ext_mem_writer
(
    clk,
    rst_n,
    ena,
    start,
    start_of_frame,
    blk4x4_counter,
    pic_num_2to0,
    mb_x_in,
    mb_y_in,
    pic_width_in_mbs,
    pic_height_in_map_units,
    luma4x4BlkIdx_x,
    luma4x4BlkIdx_y,
    chroma4x4BlkIdx,
    
    sum_0,
    sum_1,
    sum_2,
    sum_3,
    sum_4,
    sum_5,
    sum_6,
    sum_7,
    sum_8,
    sum_9,
    sum_10,
    sum_11,
    sum_12,
    sum_13,
    sum_14,
    sum_15,
    valid,  

	ext_mem_writer_burst,
	ext_mem_writer_burst_len_minus1,
    ext_mem_writer_ready,
    ext_mem_writer_addr,
    ext_mem_writer_data,
    ext_mem_writer_wr,
    
    ext_mem_writer_display_buf_addr
);
//global signals
input clk;
input rst_n;
input ena;

//misc control and data signals
input start;
input start_of_frame;
input [4:0] blk4x4_counter;
input [2:0] pic_num_2to0;
input [`mb_x_bits - 1:0] mb_x_in;
input [`mb_y_bits - 1:0] mb_y_in;
input [`mb_x_bits - 1:0] pic_width_in_mbs;
input [`mb_y_bits - 1:0] pic_height_in_map_units;
input [1:0] luma4x4BlkIdx_x;
input [1:0] luma4x4BlkIdx_y;
input [1:0] chroma4x4BlkIdx;

//interface to sum
input [7:0] sum_0;
input [7:0] sum_1;
input [7:0] sum_2;
input [7:0] sum_3;
input [7:0] sum_4;
input [7:0] sum_5;
input [7:0] sum_6;
input [7:0] sum_7;
input [7:0] sum_8;
input [7:0] sum_9;
input [7:0] sum_10;
input [7:0] sum_11;
input [7:0] sum_12;
input [7:0] sum_13;
input [7:0] sum_14;
input [7:0] sum_15;           
output      valid;

//interface to ext_mem_hub
output 									ext_mem_writer_burst;
output [4:0] 							ext_mem_writer_burst_len_minus1;
input  									ext_mem_writer_ready;
output [`ext_buf_mem_addr_width-1:0]	ext_mem_writer_addr;
output [`ext_buf_mem_addr_width-1:0]	ext_mem_writer_display_buf_addr;
output [`ext_buf_mem_data_width-1:0]	ext_mem_writer_data;
output									ext_mem_writer_wr;

////////////////////////////////
reg       state;
reg       valid;
reg       ext_mem_writer_burst;

reg [`ext_buf_mem_addr_width-1:0] ext_mem_writer_addr;
reg [`ext_buf_mem_addr_width-1:0] ext_mem_writer_display_buf_addr;

`ifdef ext_buf_mem_data_width_16
reg [15:0] ext_mem_writer_data;
`endif
`ifdef ext_buf_mem_data_width_32
reg [31:0] ext_mem_writer_data;
`endif
reg ext_mem_writer_wr;

reg [5:0] counter;

reg [`ext_buf_mem_addr_width-1:0] luma_addr_base;
reg [`ext_buf_mem_addr_width-1:0] cb_addr_base;
reg [`ext_buf_mem_addr_width-1:0] cr_addr_base;
reg [`ext_buf_mem_addr_width-1:0] display_buf_luma_addr_base;
reg [`ext_buf_mem_addr_width-1:0] display_buf_cb_addr_base;
reg [`ext_buf_mem_addr_width-1:0] display_buf_cr_addr_base;
reg [`ext_buf_mem_addr_width-1:0] luma_addr_offset;
reg [`ext_buf_mem_addr_width-1:0] chroma_addr_offset;

reg [7:0] sum_0_reg;
reg [7:0] sum_1_reg;
reg [7:0] sum_2_reg;
reg [7:0] sum_3_reg;
reg [7:0] sum_4_reg;
reg [7:0] sum_5_reg;
reg [7:0] sum_6_reg;
reg [7:0] sum_7_reg;
reg [7:0] sum_8_reg;
reg [7:0] sum_9_reg;
reg [7:0] sum_10_reg;
reg [7:0] sum_11_reg;
reg [7:0] sum_12_reg;
reg [7:0] sum_13_reg;
reg [7:0] sum_14_reg;
reg [7:0] sum_15_reg;

//cb_addr_base & cr_addr_base
always @(posedge clk or negedge rst_n)
if (!rst_n) begin
	luma_addr_base <= 0;
    cb_addr_base <= 0;
    cr_addr_base <= 0;
end
else if (start_of_frame) begin
	luma_addr_base <= pic_num_2to0 * (pic_width_in_mbs * pic_height_in_map_units*256 +
									  pic_width_in_mbs * pic_height_in_map_units*128);
    cb_addr_base <= pic_num_2to0 * (pic_width_in_mbs * pic_height_in_map_units*256 +
								    pic_width_in_mbs * pic_height_in_map_units*128) +
    				pic_width_in_mbs * pic_height_in_map_units*256;
    cr_addr_base <= pic_num_2to0 * (pic_width_in_mbs * pic_height_in_map_units*256 +
									pic_width_in_mbs * pic_height_in_map_units*128)+
    				pic_width_in_mbs * pic_height_in_map_units*256 +
    				pic_width_in_mbs * pic_height_in_map_units*64;
end

always @(posedge clk or negedge rst_n)
if (!rst_n) begin
	display_buf_luma_addr_base <= 0;
    display_buf_cb_addr_base <= 0;
    display_buf_cr_addr_base <= 0;
end
else if (start_of_frame) begin
	if (pic_num_2to0[0]) begin
		display_buf_luma_addr_base <= pic_width_in_mbs * pic_height_in_map_units*256 +
									  pic_width_in_mbs * pic_height_in_map_units*128;
	    display_buf_cb_addr_base <= pic_width_in_mbs * pic_height_in_map_units*512 +
									pic_width_in_mbs * pic_height_in_map_units*128;
	    display_buf_cr_addr_base <= pic_width_in_mbs * pic_height_in_map_units*512 +
								    pic_width_in_mbs * pic_height_in_map_units*128 +
	    							pic_width_in_mbs * pic_height_in_map_units*64;
	end
	else begin
		display_buf_luma_addr_base <= 0;
	    display_buf_cb_addr_base <= pic_width_in_mbs * pic_height_in_map_units*256;
	    display_buf_cr_addr_base <= pic_width_in_mbs * pic_height_in_map_units*256 +
	    							pic_width_in_mbs * pic_height_in_map_units*64;	
	end
end

//luma_addr_offset
always @(posedge clk or negedge rst_n)
if (!rst_n)
    luma_addr_offset <= 0;
else if (start)
    luma_addr_offset <= ((mb_y_in*16+luma4x4BlkIdx_y*4)*(pic_width_in_mbs)*4+mb_x_in*4+{luma4x4BlkIdx_x[1],1'b0})*4;

//chroma_addr_offset
always @(posedge clk or negedge rst_n)
if (!rst_n)
    chroma_addr_offset <= 0;
else if (start)
    chroma_addr_offset <= ((mb_y_in*8+chroma4x4BlkIdx[1]*4)*(pic_width_in_mbs)*2+mb_x_in*2)*4;

`ifdef ext_buf_mem_data_width_32

always @(posedge clk or negedge rst_n)
if (!rst_n) begin
    sum_0_reg <= 0;
    sum_1_reg <= 0;
    sum_2_reg <= 0;
    sum_3_reg <= 0;
    sum_4_reg <= 0;
    sum_5_reg <= 0;
    sum_6_reg <= 0;
    sum_7_reg <= 0;
    sum_8_reg <= 0;
    sum_9_reg <= 0;
    sum_10_reg <= 0;
    sum_11_reg <= 0;
    sum_12_reg <= 0;
    sum_13_reg <= 0;
    sum_14_reg <= 0;
    sum_15_reg <= 0;
end
else if (ena && blk4x4_counter[0] == 0 && start) begin
    sum_0_reg <= sum_0;
    sum_1_reg <= sum_1;
    sum_2_reg <= sum_2;
    sum_3_reg <= sum_3;
    sum_4_reg <= sum_4;
    sum_5_reg <= sum_5;
    sum_6_reg <= sum_6;
    sum_7_reg <= sum_7;
    sum_8_reg <= sum_8;
    sum_9_reg <= sum_9;
    sum_10_reg <= sum_10;
    sum_11_reg <= sum_11;
    sum_12_reg <= sum_12;
    sum_13_reg <= sum_13;
    sum_14_reg <= sum_14;
    sum_15_reg <= sum_15;
end

    
always @(posedge clk or negedge rst_n)
if (!rst_n)
    counter <= 0;
else if (ena && state == 0 && blk4x4_counter[0] && start)
    counter <= 10;
else if (ena && counter > 0 && ext_mem_writer_ready)
    counter <= counter - 1;
    
always @(posedge clk or negedge rst_n)
if (!rst_n) begin
    state <= 0;
	valid <= 0;
end
else if (ena && state == 0 && blk4x4_counter[0] && start) begin
    state <= 1;
    valid <= 0;
end
else if (ena && state == 1 && counter == 0 || ena && blk4x4_counter[0] == 0) begin
    state <= 0;
    valid <= 1;
end 

assign busy = state;
    

always @(*)
if (counter != 0 && counter < 9)
    ext_mem_writer_wr <= 1;
else
    ext_mem_writer_wr <= 0;
    
always @(*)
begin
    if (blk4x4_counter < 16)
        case(counter)
        9:ext_mem_writer_addr <= luma_addr_base + luma_addr_offset;
        7:ext_mem_writer_addr <=luma_addr_base + luma_addr_offset+pic_width_in_mbs*16;
        5:ext_mem_writer_addr <=luma_addr_base + luma_addr_offset+pic_width_in_mbs*32;
        3:ext_mem_writer_addr <=luma_addr_base + luma_addr_offset+pic_width_in_mbs*48;
        default:ext_mem_writer_addr <= 0;
        endcase
//  else
//  ext_mem_writer_addr <= 0;
    else if (blk4x4_counter >= 16 && blk4x4_counter < 20)
        case(counter)
        9:ext_mem_writer_addr <=cb_addr_base+chroma_addr_offset;
        7:ext_mem_writer_addr <=cb_addr_base+chroma_addr_offset+pic_width_in_mbs*8;
        5:ext_mem_writer_addr <=cb_addr_base+chroma_addr_offset+pic_width_in_mbs*16;
        3:ext_mem_writer_addr <=cb_addr_base+chroma_addr_offset+pic_width_in_mbs*24;
        default:ext_mem_writer_addr <= 0;
        endcase          
    else 
        case(counter)
        9:ext_mem_writer_addr <=cr_addr_base+chroma_addr_offset;
        7:ext_mem_writer_addr <=cr_addr_base+chroma_addr_offset+pic_width_in_mbs*8;
        5:ext_mem_writer_addr <=cr_addr_base+chroma_addr_offset+pic_width_in_mbs*16;
        3:ext_mem_writer_addr <=cr_addr_base+chroma_addr_offset+pic_width_in_mbs*24;
        default:ext_mem_writer_addr <= 0;
        endcase 
end

always @(*)
begin
    if (blk4x4_counter < 16)
        case(counter)
        9:ext_mem_writer_display_buf_addr <=display_buf_luma_addr_base + luma_addr_offset;
        7:ext_mem_writer_display_buf_addr <=display_buf_luma_addr_base + luma_addr_offset+pic_width_in_mbs*16;
        5:ext_mem_writer_display_buf_addr <=display_buf_luma_addr_base + luma_addr_offset+pic_width_in_mbs*32;
        3:ext_mem_writer_display_buf_addr <=display_buf_luma_addr_base + luma_addr_offset+pic_width_in_mbs*48;
        default:ext_mem_writer_display_buf_addr <= 0;
        endcase
    else if (blk4x4_counter >= 16 && blk4x4_counter < 20)
        case(counter)
        9:ext_mem_writer_display_buf_addr <=display_buf_cb_addr_base+chroma_addr_offset;
        7:ext_mem_writer_display_buf_addr <=display_buf_cb_addr_base+chroma_addr_offset+pic_width_in_mbs*8;
        5:ext_mem_writer_display_buf_addr <=display_buf_cb_addr_base+chroma_addr_offset+pic_width_in_mbs*16;
        3:ext_mem_writer_display_buf_addr <=display_buf_cb_addr_base+chroma_addr_offset+pic_width_in_mbs*24;
        default:ext_mem_writer_display_buf_addr <= 0;
        endcase          
    else 
        case(counter)
        9:ext_mem_writer_display_buf_addr <=display_buf_cr_addr_base+chroma_addr_offset;
        7:ext_mem_writer_display_buf_addr <=display_buf_cr_addr_base+chroma_addr_offset+pic_width_in_mbs*8;
        5:ext_mem_writer_display_buf_addr <=display_buf_cr_addr_base+chroma_addr_offset+pic_width_in_mbs*16;
        3:ext_mem_writer_display_buf_addr <=display_buf_cr_addr_base+chroma_addr_offset+pic_width_in_mbs*24;
        default:ext_mem_writer_display_buf_addr <= 0;
        endcase 
end


always @(*)          
begin
    case(counter)
    8:ext_mem_writer_data <= {sum_3_reg[7:0],sum_2_reg[7:0],sum_1_reg[7:0],sum_0_reg[7:0]};
    7:ext_mem_writer_data <= {sum_3[7:0],sum_2[7:0],sum_1[7:0],sum_0[7:0]};
    6:ext_mem_writer_data <= {sum_7_reg[7:0],sum_6_reg[7:0],sum_5_reg[7:0],sum_4_reg[7:0]};
    5:ext_mem_writer_data <= {sum_7[7:0],sum_6[7:0],sum_5[7:0],sum_4[7:0]};
    4:ext_mem_writer_data <= {sum_11_reg[7:0],sum_10_reg[7:0],sum_9_reg[7:0],sum_8_reg[7:0]};
    3:ext_mem_writer_data <= {sum_11[7:0],sum_10[7:0],sum_9[7:0],sum_8[7:0]};
    2:ext_mem_writer_data <= {sum_15_reg[7:0],sum_14_reg[7:0],sum_13_reg[7:0],sum_12_reg[7:0]};   
    1:ext_mem_writer_data <= {sum_15[7:0],sum_14[7:0],sum_13[7:0],sum_12[7:0]}; 
    default:ext_mem_writer_data <= 0;
    endcase
end

always @(*)          
begin
    case(counter)
    9,7,5,3: ext_mem_writer_burst <= 1;
    default: ext_mem_writer_burst <= 0;
    endcase
end
assign ext_mem_writer_burst_len_minus1 = 1;
`endif

endmodule
