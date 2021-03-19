//--------------------------------------------------------------------------------------------------
// Design    : bitstream_p
// Author(s) : qiu bin, shi tian qi
// Email     : chat1@126.com, tishi1@126.com
// Copyright (C) 2013 qiu bin 
// All rights reserved                
//-------------------------------------------------------------------------------------------------


`include "defines.v"

module intra_pred_fsm
(
    clk,
    rst_n,
    ena,
    start,
    mb_x,
    mb_y,
    pic_width_in_mbs_minus1,
    mb_pred_mode,
    mb_pred_inter_sel,
    I4_pred_mode,
    I16_pred_mode,
    intra_pred_mode_chroma,
    sum_valid,
    up_avail,
    left_avail,
    up_right_avail,
    calc_counter,
    addr,
    wr,
    DC_wr,
    up_mb_luma_addr,
    up_mb_luma_wr,
    preload_counter,
    up_left_addr,
    up_left_wr,
    up_left_7_wr,
    up_left_cb_wr,
    up_left_cr_wr,
    blk4x4_counter,
    precalc_counter,
    left_mb_luma_addr,
    left_mb_luma_wr,
    
    left_mb_cb_wr,
    left_mb_cr_wr,
    left_mb_cb_addr,
    left_mb_cr_addr,
    line_ram_luma_wr_n,
    line_ram_cb_wr_n,
    line_ram_cr_wr_n,
    line_ram_luma_addr,
    line_ram_chroma_addr,
    calc_ena,
    abc_latch,
    seed_latch,
    seed_wr,
    valid
);  
input clk;
input rst_n;
input ena;
input start;
input [`mb_x_bits - 1:0] mb_x;
input [`mb_y_bits - 1:0] mb_y;
input [`mb_x_bits - 1:0] pic_width_in_mbs_minus1;
input sum_valid;
input [3:0] mb_pred_mode;
input mb_pred_inter_sel;
input [3:0] I4_pred_mode;
input [1:0] I16_pred_mode;
input [1:0] intra_pred_mode_chroma;
output [1:0] addr;
output wr;
output DC_wr;
output [1:0] left_mb_luma_addr;
output left_mb_luma_wr;
output [1:0] up_mb_luma_addr;
output up_mb_luma_wr;
output [2:0] preload_counter;
output [2:0] up_left_addr;
output up_left_wr;
output up_left_7_wr;
output up_left_cb_wr;
output up_left_cr_wr;
output left_mb_cb_wr;
output left_mb_cr_wr;
output left_mb_cb_addr;
output left_mb_cr_addr;
output [3:0] precalc_counter;
input  [4:0] blk4x4_counter;
output [1:0] calc_counter;
output up_avail;
output left_avail;
output up_right_avail;
output line_ram_luma_wr_n;
output line_ram_cb_wr_n;
output line_ram_cr_wr_n;
output [`mb_x_bits+1:0] line_ram_luma_addr;
output [`mb_x_bits:0] line_ram_chroma_addr;

output calc_ena;
output abc_latch;
output seed_latch;
output seed_wr;
output valid;

reg [1:0] left_mb_luma_addr;
reg left_mb_luma_wr;
reg [1:0] up_mb_luma_addr;
reg up_mb_luma_wr;
reg [2:0] up_left_addr;
reg up_left_wr;
reg up_left_7_wr;
reg up_left_cb_wr;
reg up_left_cr_wr;

reg wr;

reg left_mb_cb_wr;
reg left_mb_cr_wr;
reg left_mb_cb_addr;
reg left_mb_cr_addr;
reg DC_wr;
reg [1:0] addr;
reg line_ram_luma_wr_n;
reg line_ram_cb_wr_n;
reg line_ram_cr_wr_n;
reg [`mb_x_bits+1:0] line_ram_luma_addr;
reg [`mb_x_bits:0]   line_ram_chroma_addr;
//FFs
reg sum_valid_s;
reg [1:0] calc_counter;
reg [2:0] preload_counter;
reg [3:0] precalc_counter;
reg [2:0] state;
reg valid;

assign calc_ena =(state == `intra_pred_calc_s && ena);

assign abc_latch = (state == `intra_pred_precalc_s && precalc_counter == 0);
assign seed_latch = (state == `intra_pred_seedcalc_s);
assign seed_wr = ((   mb_pred_mode == `mb_pred_mode_I16MB && I16_pred_mode == `Intra16x16_Plane && (                                                              

                       ((blk4x4_counter == 0 || blk4x4_counter == 2 || 
                        blk4x4_counter == 8) && calc_counter == 2)||                                                     

                       ((blk4x4_counter == 1 || blk4x4_counter == 3 ||
                          blk4x4_counter == 9 || blk4x4_counter == 11) 
                        && !sum_valid_s && sum_valid))) ||

                   (intra_pred_mode_chroma == `Intra_chroma_Plane && (
                        (blk4x4_counter == 16 || blk4x4_counter == 20) && calc_counter == 2)));

              
//avail
reg up_avail;
reg left_avail;
reg up_right_avail;

always @(posedge clk or negedge rst_n)
if (!rst_n) begin
	up_avail   		<= 0;
	left_avail 		<= 0;
	up_right_avail	<= 0;
end
else if (start) begin
	up_avail <= mb_y > 0 ||
    	mb_y == 0 && mb_pred_mode == `mb_pred_mode_I4MB && 
    	blk4x4_counter != 0 && blk4x4_counter != 1 &&
    	blk4x4_counter != 4 && blk4x4_counter != 5 && blk4x4_counter < 16;
	left_avail <= mb_x > 0 ||
    	mb_x == 0 && mb_pred_mode == `mb_pred_mode_I4MB && 
    	blk4x4_counter != 0 &&blk4x4_counter != 2 &&
    	blk4x4_counter != 8 && blk4x4_counter!= 10 && blk4x4_counter < 16;
	up_right_avail <= mb_y != 0 && mb_x != pic_width_in_mbs_minus1;
end
         

       

always @(posedge clk or negedge rst_n)
if (!rst_n) begin
    state <= `intra_pred_idle_s;
    valid <= 0;
    calc_counter <= 0;
    precalc_counter <= 0;
end
else if (ena) begin
    case (state)
    `intra_pred_idle_s: begin
        if (start)begin
            if (blk4x4_counter == 0)begin   //load all up mb information at blk 0
                state <= `intra_pred_preload_s;                 
                valid <= 0;
            end
            else if (intra_pred_mode_chroma == `Intra_chroma_Plane &&
                  (blk4x4_counter == 16 || blk4x4_counter == 20))begin
                state <= `intra_pred_precalc_s;                 
                precalc_counter <= 4;                                            
                valid <= 0;               
            end   
            else begin
                state <= `intra_pred_calc_s;
                calc_counter <= 3;  
                valid <= 0;     
            end
        end
    end
    `intra_pred_preload_s: begin
        if (preload_counter == 1)begin
            if (mb_pred_mode == `mb_pred_mode_I16MB && I16_pred_mode == `Intra16x16_Plane)begin
                state <= `intra_pred_precalc_s;
                precalc_counter <= 8;                                            
            end
            else begin
                state <= `intra_pred_calc_s;
                calc_counter <= 3;
            end
        end
    end
    `intra_pred_precalc_s:
        if (precalc_counter == 0) begin
            state <= `intra_pred_seedcalc_s;
        end
        else begin
            precalc_counter <= precalc_counter - 1;
        end
    `intra_pred_seedcalc_s:
        begin
            state <= `intra_pred_calc_s;
            calc_counter <= 3;
        end
    `intra_pred_calc_s:
        if (calc_counter == 0) begin
        	valid <= 1;
            state <= `intra_pred_idle_s;
        end
        else begin
            calc_counter <= calc_counter - 1;
        end
    endcase
end

always @(posedge clk or negedge rst_n)
if (!rst_n)
	sum_valid_s <= 0;
else if (ena)
	sum_valid_s <= sum_valid;

always @(posedge clk or negedge rst_n)
if (!rst_n)
    preload_counter <= 0;
else if (ena) begin
    if (start && state == `intra_pred_idle_s && blk4x4_counter == 0)
        preload_counter <= 6;                                            
    else if (preload_counter > 0)    
        preload_counter <= preload_counter - 1;
end
       
always @(*)   
    if (!sum_valid_s  &&  sum_valid &&(
         (mb_pred_mode == `mb_pred_mode_I4MB && blk4x4_counter < 16 ) || 
         (mb_pred_mode == `mb_pred_mode_I16MB || mb_pred_inter_sel) &&
         (blk4x4_counter == 5 || blk4x4_counter == 7||
         blk4x4_counter == 13 || blk4x4_counter == 15)))
                                       
        left_mb_luma_wr <= 1;
    else
        left_mb_luma_wr <= 0;
        
always @(*)
    case(blk4x4_counter)
        0, 1, 4, 5  :left_mb_luma_addr <= 0;
        2, 3, 6, 7  :left_mb_luma_addr <= 1;
        8, 9,12,13  :left_mb_luma_addr <= 2;
        10,11,14,15 :left_mb_luma_addr <= 3; 
        default:left_mb_luma_addr <= 0;
    endcase

always @(*)
    if (!sum_valid_s  &&  sum_valid &&(
         (mb_pred_mode == `mb_pred_mode_I4MB  && blk4x4_counter < 16) || 
         (mb_pred_mode == `mb_pred_mode_I16MB || mb_pred_inter_sel) &&
         (blk4x4_counter == 10 || blk4x4_counter == 11||
         blk4x4_counter == 14 || blk4x4_counter == 15)
         ))
        up_mb_luma_wr <= 1;
    else
        up_mb_luma_wr <= 0;
        
always @(*)
if (state == `intra_pred_preload_s) 
    up_mb_luma_addr <= calc_counter;
else
    case(blk4x4_counter)
        0, 2, 8, 10  :up_mb_luma_addr <= 0;
        1, 3, 9, 11  :up_mb_luma_addr <= 1;
        4, 6,12, 14  :up_mb_luma_addr <= 2;
        5, 7,13, 15  :up_mb_luma_addr <= 3; 
        default:up_mb_luma_addr <= 0;
    endcase 
        

always @(*)
    if (!sum_valid_s  &&  sum_valid && mb_pred_mode == `mb_pred_mode_I4MB
        && blk4x4_counter != 5 && blk4x4_counter != 7 && blk4x4_counter != 13
        && blk4x4_counter != 10 && blk4x4_counter != 11 && blk4x4_counter != 14 
        && blk4x4_counter != 15)
        up_left_wr <= 1;
    else
        up_left_wr <= 0;

always @(*)
    if (state == `intra_pred_calc_s  &&  calc_counter == 0 &&
        ( blk4x4_counter == 0 ||blk4x4_counter == 2 ||
          blk4x4_counter == 8 ||blk4x4_counter == 15)  ||
          mb_pred_inter_sel && blk4x4_counter == 15 && !sum_valid_s  &&  sum_valid)                
        up_left_7_wr <= 1;
    else
        up_left_7_wr <= 0;

always @(*)
    if (!sum_valid_s && sum_valid && blk4x4_counter == 19 )                
        up_left_cb_wr <= 1;
    else
        up_left_cb_wr <= 0;

always @(*)
    if (!sum_valid_s && sum_valid && blk4x4_counter == 23 )                
        up_left_cr_wr <= 1;
    else
        up_left_cr_wr <= 0;

        
always @(*)
    case(blk4x4_counter)
        0, 6    :up_left_addr <= 0;
        1, 8    :up_left_addr <= 1;
        2, 9    :up_left_addr <= 2;
        3, 12   :up_left_addr <= 3; 
        4       :up_left_addr <= 4;
        default:up_left_addr <= 0;
    endcase
    
//intra_pred_regs control
    
always @(*)
    addr <= calc_counter;
    
always @(*)
    if (state == `intra_pred_calc_s &&  (
        blk4x4_counter < 16 &&( 
        mb_pred_mode == `mb_pred_mode_I16MB && I16_pred_mode != `Intra16x16_DC ||
        mb_pred_mode == `mb_pred_mode_I4MB && I4_pred_mode != `Intra4x4_DC
        )||
        blk4x4_counter > 15 && intra_pred_mode_chroma != `Intra_chroma_DC))
        wr <= 1;
    else
        wr <= 0;
        
always @(*)
    if (state == `intra_pred_calc_s && calc_counter == 0 && mb_pred_mode == `mb_pred_mode_I16MB &&
        I16_pred_mode == `Intra16x16_DC && blk4x4_counter == 0 ||
        state == `intra_pred_calc_s && calc_counter == 1 && mb_pred_mode == `mb_pred_mode_I4MB &&
        I4_pred_mode == `Intra4x4_DC && blk4x4_counter <16 ||
        state == `intra_pred_calc_s && calc_counter == 2 && intra_pred_mode_chroma == `Intra_chroma_DC &&
        blk4x4_counter > 15)
        DC_wr <= 1;
    else
        DC_wr <= 0;
        
//chroma wr and addr        
always @(*)
    if  (!sum_valid_s  &&  sum_valid &&
         (blk4x4_counter == 17 || blk4x4_counter == 19))    
        left_mb_cb_wr <= 1;
    else
        left_mb_cb_wr <= 0;

always @(*)
    if (blk4x4_counter == 17)
        left_mb_cb_addr <= 0;
    else
        left_mb_cb_addr <= 1;
    
always @(*)
    if  (!sum_valid_s  &&  sum_valid &&
         (blk4x4_counter == 21 || blk4x4_counter == 23))    
        left_mb_cr_wr <= 1;
    else
        left_mb_cr_wr <= 0;

always @(*)
    if (blk4x4_counter == 21)
        left_mb_cr_addr <= 0;
    else
        left_mb_cr_addr <= 1;   
        
always @(*)
    if (!sum_valid_s  && sum_valid && 
        (blk4x4_counter == 10 || blk4x4_counter == 11 ||
        blk4x4_counter == 14 || blk4x4_counter == 15))
        line_ram_luma_wr_n <= 0;
    else
        line_ram_luma_wr_n <= 1;
        
always @(*)
    if (!sum_valid_s  && sum_valid &&
     (blk4x4_counter == 18 || blk4x4_counter == 19 ))
        line_ram_cb_wr_n <= 0;
    else
        line_ram_cb_wr_n <= 1;
    
always @(*)
    if (!sum_valid_s  && sum_valid && 
    (blk4x4_counter == 22 || blk4x4_counter == 23 ))
        line_ram_cr_wr_n <= 0;
    else
        line_ram_cr_wr_n <= 1;  


always @(*)
if(!sum_valid_s && sum_valid)
    case(blk4x4_counter)	//write
        10:line_ram_luma_addr <= (mb_x<<2) + 0;
        11:line_ram_luma_addr <= (mb_x<<2) + 1;
        14:line_ram_luma_addr <= (mb_x<<2) + 2;
        15:line_ram_luma_addr <= (mb_x<<2) + 3;
        default:line_ram_luma_addr <= (mb_x<<2) + 3;
    endcase
else begin  //there is 1 cycle latency to read, because it's sync read
    case(preload_counter)
    6:line_ram_luma_addr <= (mb_x<<2) + 4;
    5:line_ram_luma_addr <= (mb_x<<2) + 0;
    4:line_ram_luma_addr <= (mb_x<<2) + 1;
    3:line_ram_luma_addr <= (mb_x<<2) + 2;
    2:line_ram_luma_addr <= (mb_x<<2) + 3;
    default :line_ram_luma_addr <= (mb_x<<2) + 3;
    endcase
end

always @(*)
if(!sum_valid_s && sum_valid)
    case(blk4x4_counter)
        18,22:line_ram_chroma_addr <= (mb_x << 1) + 0;
        19,23:line_ram_chroma_addr <= (mb_x << 1) + 1;
        default : line_ram_chroma_addr <= (mb_x << 1) + 1;
    endcase
else begin
    case(preload_counter)
    3:line_ram_chroma_addr <= (mb_x<<1) + 0;
    2:line_ram_chroma_addr <= (mb_x<<1) + 1;
    default : line_ram_chroma_addr <= (mb_x<<1) + 1;
    endcase
end

endmodule
