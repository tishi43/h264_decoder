//--------------------------------------------------------------------------------------------------
// Design    : bitstream_p
// Author(s) : qiu bin, shi tian qi
// Email     : chat1@126.com, tishi1@126.com
// Copyright (C) 2013 qiu bin 
// All rights reserved                
//-------------------------------------------------------------------------------------------------


`include "defines.v"

module intra4x4_pred_mode_decoding
(
 mb_x_in,
 mb_y_in,
 luma4x4BlkIdx_in,
 luma4x4BlkIdx_y_in,
 luma4x4BlkIdx_x_in,
 prev_intra4x4_pred_mode_in,
 rem_intra4x4_pred_mode_in,
 intra4x4_pred_mode_left_mb_in,
 intra4x4_pred_mode_up_mb_in,
 intra4x4_pred_mode_curr_mb_in,
 I4_pred_mode_out
);

input[`mb_x_bits - 1:0] mb_x_in;
input[`mb_y_bits - 1:0] mb_y_in;
input[3:0] luma4x4BlkIdx_in;
input[1:0] luma4x4BlkIdx_y_in;
input[1:0] luma4x4BlkIdx_x_in;

input prev_intra4x4_pred_mode_in;
input[2:0] rem_intra4x4_pred_mode_in;
input[15:0] intra4x4_pred_mode_up_mb_in;
input[15:0] intra4x4_pred_mode_left_mb_in;
input[63:0] intra4x4_pred_mode_curr_mb_in;

output[3:0] I4_pred_mode_out;

reg[3:0] intra4x4_pred_mode_up;
reg[3:0] intra4x4_pred_mode_left;

reg[3:0] mostProbableIntra4x4PredMode;
reg[3:0] I4_pred_mode_out;

// get intra4x4_pred_mode of left and up   
always @(intra4x4_pred_mode_left_mb_in or intra4x4_pred_mode_curr_mb_in or luma4x4BlkIdx_in or intra4x4_pred_mode_up_mb_in)
    case(luma4x4BlkIdx_in)
        0:  intra4x4_pred_mode_up <= intra4x4_pred_mode_up_mb_in[3:0];
        1:  intra4x4_pred_mode_up <= intra4x4_pred_mode_up_mb_in[7:4];
        2:  intra4x4_pred_mode_up <= intra4x4_pred_mode_curr_mb_in[3:0];
        3:  intra4x4_pred_mode_up <= intra4x4_pred_mode_curr_mb_in[7:4];
        4:  intra4x4_pred_mode_up <= intra4x4_pred_mode_up_mb_in[11:8];
        5:  intra4x4_pred_mode_up <= intra4x4_pred_mode_up_mb_in[15:12];
        6:  intra4x4_pred_mode_up <= intra4x4_pred_mode_curr_mb_in[19:16];
        7:  intra4x4_pred_mode_up <= intra4x4_pred_mode_curr_mb_in[23:20];
        8:  intra4x4_pred_mode_up <= intra4x4_pred_mode_curr_mb_in[11:8];
        9:  intra4x4_pred_mode_up <= intra4x4_pred_mode_curr_mb_in[15:12];
        12: intra4x4_pred_mode_up <= intra4x4_pred_mode_curr_mb_in[27:24];
        13: intra4x4_pred_mode_up <= intra4x4_pred_mode_curr_mb_in[31:28];
        10: intra4x4_pred_mode_up <= intra4x4_pred_mode_curr_mb_in[35:32];
        11: intra4x4_pred_mode_up <= intra4x4_pred_mode_curr_mb_in[39:36];
        14: intra4x4_pred_mode_up <= intra4x4_pred_mode_curr_mb_in[51:48];
        15: intra4x4_pred_mode_up <= intra4x4_pred_mode_curr_mb_in[55:52];
    endcase
    
always @(intra4x4_pred_mode_left_mb_in or intra4x4_pred_mode_curr_mb_in or luma4x4BlkIdx_in)
    case(luma4x4BlkIdx_in)
        0:  intra4x4_pred_mode_left <= intra4x4_pred_mode_left_mb_in[3:0];
        1:  intra4x4_pred_mode_left <= intra4x4_pred_mode_curr_mb_in[3:0];
        2:  intra4x4_pred_mode_left <= intra4x4_pred_mode_left_mb_in[7:4];
        3:  intra4x4_pred_mode_left <= intra4x4_pred_mode_curr_mb_in[11:8];
        8:  intra4x4_pred_mode_left <= intra4x4_pred_mode_left_mb_in[11:8];
        9:  intra4x4_pred_mode_left <= intra4x4_pred_mode_curr_mb_in[35:32];
        10: intra4x4_pred_mode_left <= intra4x4_pred_mode_left_mb_in[15:12];
        11: intra4x4_pred_mode_left <= intra4x4_pred_mode_curr_mb_in[43:40];
        4:  intra4x4_pred_mode_left <= intra4x4_pred_mode_curr_mb_in[7:4];
        6:  intra4x4_pred_mode_left <= intra4x4_pred_mode_curr_mb_in[15:12];
        12: intra4x4_pred_mode_left <= intra4x4_pred_mode_curr_mb_in[39:36];
        14: intra4x4_pred_mode_left <= intra4x4_pred_mode_curr_mb_in[47:44];
        5:  intra4x4_pred_mode_left <= intra4x4_pred_mode_curr_mb_in[19:16];
        7:  intra4x4_pred_mode_left <= intra4x4_pred_mode_curr_mb_in[27:24];
        13: intra4x4_pred_mode_left <= intra4x4_pred_mode_curr_mb_in[51:48];
        15: intra4x4_pred_mode_left <= intra4x4_pred_mode_curr_mb_in[59:56];
    endcase

always @(intra4x4_pred_mode_up or intra4x4_pred_mode_left or mb_y_in or mb_x_in 
            or luma4x4BlkIdx_y_in or luma4x4BlkIdx_x_in)
    if ((mb_y_in == 0 && luma4x4BlkIdx_y_in == 0)||(mb_x_in == 0 && luma4x4BlkIdx_x_in == 0)) // if left or up is not available
        mostProbableIntra4x4PredMode <= 2;
    else
        mostProbableIntra4x4PredMode <= intra4x4_pred_mode_up > intra4x4_pred_mode_left 
                                                ? intra4x4_pred_mode_left : intra4x4_pred_mode_up;

always @(prev_intra4x4_pred_mode_in or rem_intra4x4_pred_mode_in or mostProbableIntra4x4PredMode)
    if(prev_intra4x4_pred_mode_in)
        I4_pred_mode_out <= mostProbableIntra4x4PredMode;
    else
        begin
            if(rem_intra4x4_pred_mode_in >= mostProbableIntra4x4PredMode)
                I4_pred_mode_out <= rem_intra4x4_pred_mode_in + 1;
            else
                I4_pred_mode_out <= rem_intra4x4_pred_mode_in;
        end
        
endmodule
