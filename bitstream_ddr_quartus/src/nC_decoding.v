//--------------------------------------------------------------------------------------------------
// Design    : bitstream_p
// Author(s) : qiu bin, shi tian qi
// Email     : chat1@126.com, tishi1@126.com
// Copyright (C) 2013 qiu bin 
// All rights reserved                
//-------------------------------------------------------------------------------------------------

`include "defines.v"

module nC_decoding
(
 mb_x_in,
 mb_y_in,
 luma4x4BlkIdx_in,
 chroma4x4BlkIdx_in,
 nC_up_mb_in,
 nC_left_mb_in,
 nC_curr_mb_in,
 nC_cb_up_mb_in,
 nC_cb_left_mb_in,
 nC_cb_curr_mb_in,
 nC_cr_up_mb_in,
 nC_cr_left_mb_in,
 nC_cr_curr_mb_in, 
 nC_out,
 nC_cb_out,
 nC_cr_out
);

input[`mb_x_bits - 1:0] mb_x_in;
input[`mb_y_bits - 1:0] mb_y_in;
input[3:0] luma4x4BlkIdx_in;
input[1:0] chroma4x4BlkIdx_in;
input[31:0] nC_up_mb_in;
input[31:0] nC_left_mb_in;
input[127:0] nC_curr_mb_in;
input[15:0] nC_cb_up_mb_in;
input[15:0] nC_cb_left_mb_in;
input[31:0] nC_cb_curr_mb_in;
input[15:0] nC_cr_up_mb_in;
input[15:0] nC_cr_left_mb_in;
input[31:0] nC_cr_curr_mb_in; 


output[7:0] nC_out;
output[7:0] nC_cb_out;
output[7:0] nC_cr_out;

reg[7:0] nA;
reg[7:0] nB;
reg[7:0] nA_cb;
reg[7:0] nB_cb;
reg[7:0] nA_cr;
reg[7:0] nB_cr;

reg[1:0] luma4x4BlkIdx_x;
reg[1:0] luma4x4BlkIdx_y;

reg chroma4x4BlkIdx_x;
reg chroma4x4BlkIdx_y;

reg[7:0] nC_out;
reg[7:0] nC_cb_out;
reg[7:0] nC_cr_out;

always @(luma4x4BlkIdx_in)
     case(luma4x4BlkIdx_in)
         0,2,8,10:     luma4x4BlkIdx_x <= 0;
         1,3,9,11:     luma4x4BlkIdx_x <= 1;
         4,6,12,14:    luma4x4BlkIdx_x <= 2;
         5,7,13,15:    luma4x4BlkIdx_x <= 3;
         default:      luma4x4BlkIdx_x <= 3;
     endcase
     
always @(luma4x4BlkIdx_in)
     case(luma4x4BlkIdx_in)
         0,1,4,5:     luma4x4BlkIdx_y <= 0;
         2,3,6,7:     luma4x4BlkIdx_y <= 1;
         8,9,12,13:   luma4x4BlkIdx_y <= 2;
         10,11,14,15: luma4x4BlkIdx_y <= 3;
         default:     luma4x4BlkIdx_y <= 3;
     endcase


always @(chroma4x4BlkIdx_in)
    case(chroma4x4BlkIdx_in)
      0,2: chroma4x4BlkIdx_x <= 0;
      1,3: chroma4x4BlkIdx_x <= 1;
    endcase

always @(chroma4x4BlkIdx_in)
    case(chroma4x4BlkIdx_in)
      0,1: chroma4x4BlkIdx_y <= 0;
      2,3: chroma4x4BlkIdx_y <= 1;
    endcase


always @ (luma4x4BlkIdx_in or nC_up_mb_in or nC_curr_mb_in or nC_left_mb_in)
    begin
        case(luma4x4BlkIdx_in)
            0: begin nA <= nC_left_mb_in[7:0]; nB <= nC_up_mb_in[7:0]; end
            1: begin nA <= nC_curr_mb_in[7:0]; nB <= nC_up_mb_in[15:8]; end
            2: begin nA <= nC_left_mb_in[15:8]; nB <= nC_curr_mb_in[7:0]; end
            3: begin nA <= nC_curr_mb_in[23:16]; nB <= nC_curr_mb_in[15:8]; end
            4: begin nA <= nC_curr_mb_in[15:8]; nB <= nC_up_mb_in[23:16]; end
            5: begin nA <= nC_curr_mb_in[39:32]; nB <= nC_up_mb_in[31:24]; end
            6: begin nA <= nC_curr_mb_in[31:24]; nB <= nC_curr_mb_in[39:32]; end
            7: begin nA <= nC_curr_mb_in[55:48]; nB <= nC_curr_mb_in[47:40]; end
            8: begin nA <= nC_left_mb_in[23:16]; nB <= nC_curr_mb_in[23:16]; end
            9: begin nA <= nC_curr_mb_in[71:64]; nB <= nC_curr_mb_in[31:24]; end
            10: begin nA <= nC_left_mb_in[31:24]; nB <= nC_curr_mb_in[71:64]; end
            11: begin nA <= nC_curr_mb_in[87:80]; nB <= nC_curr_mb_in[79:72]; end
            12: begin nA <= nC_curr_mb_in[79:72]; nB <= nC_curr_mb_in[55:48]; end
            13: begin nA <= nC_curr_mb_in[103:96]; nB <= nC_curr_mb_in[63:56]; end
            14: begin nA <= nC_curr_mb_in[95:88]; nB <= nC_curr_mb_in[103:96]; end
            15: begin nA <= nC_curr_mb_in[119:112]; nB <= nC_curr_mb_in[111:104]; end
        endcase
    end

always @(chroma4x4BlkIdx_in or nC_cb_left_mb_in or nC_cb_up_mb_in or nC_cb_curr_mb_in)
    case(chroma4x4BlkIdx_in) // spec 9.2.1
        0: 
            begin 
                nA_cb <= nC_cb_left_mb_in[7:0]; 
                nB_cb <= nC_cb_up_mb_in[7:0];
            end
        1:
            begin
                nA_cb <= nC_cb_curr_mb_in[7:0]; 
                nB_cb <= nC_cb_up_mb_in[15:8];
            end
        2:
            begin
                nA_cb <= nC_cb_left_mb_in[15:8]; 
                nB_cb <= nC_cb_curr_mb_in[7:0];
            end        
        3:
            begin
                nA_cb <= nC_cb_curr_mb_in[23:16]; 
                nB_cb <= nC_cb_curr_mb_in[15:8];
            end      
    endcase

always @(chroma4x4BlkIdx_in or nC_cr_left_mb_in or nC_cr_up_mb_in or nC_cr_curr_mb_in)
    case(chroma4x4BlkIdx_in)
        0: 
            begin 
                nA_cr <= nC_cr_left_mb_in[7:0];
                nB_cr <= nC_cr_up_mb_in[7:0];
            end
        1:
            begin
                nA_cr <= nC_cr_curr_mb_in[7:0];
                nB_cr <= nC_cr_up_mb_in[15:8];
            end
        2:
            begin
                nA_cr <= nC_cr_left_mb_in[15:8];
                nB_cr <= nC_cr_curr_mb_in[7:0];
            end        
        3:
            begin
                nA_cr <= nC_cr_curr_mb_in[23:16];
                nB_cr <= nC_cr_curr_mb_in[15:8];
            end      
    endcase



always @(nA or nB or mb_x_in or luma4x4BlkIdx_x or mb_y_in or luma4x4BlkIdx_y)
    begin
        if (mb_x_in == 0 && luma4x4BlkIdx_x == 0 && mb_y_in == 0 && luma4x4BlkIdx_y == 0)
            begin
                nC_out <= 0;
            end
        else if (mb_x_in == 0 && luma4x4BlkIdx_x == 0)
            begin
                nC_out <= nB;
            end
        else if (mb_y_in == 0 && luma4x4BlkIdx_y == 0)
            begin
                nC_out <= nA;
            end
        else
            begin
                nC_out <= (nA + nB + 1) >> 1;
            end
    end

always @(nA_cb or nB_cb or mb_x_in or mb_y_in or chroma4x4BlkIdx_x or chroma4x4BlkIdx_y)
    begin
        if (mb_x_in == 0 && chroma4x4BlkIdx_x == 0 && mb_y_in == 0 && chroma4x4BlkIdx_y == 0)
            begin
                nC_cb_out <= 0;
            end
        else if (mb_x_in == 0 && chroma4x4BlkIdx_x == 0)
            begin
                nC_cb_out <= nB_cb;
            end
        else if (mb_y_in == 0 && chroma4x4BlkIdx_y == 0)
            begin
                nC_cb_out <= nA_cb;
            end
        else
            begin
                nC_cb_out <= (nA_cb + nB_cb + 1) >> 1;
            end
    end

always @(nA_cr or nB_cr or mb_x_in or mb_y_in or chroma4x4BlkIdx_x or chroma4x4BlkIdx_y)
    begin
        if (mb_x_in == 0 && chroma4x4BlkIdx_x == 0 && mb_y_in == 0 && chroma4x4BlkIdx_y == 0)
            begin
                nC_cr_out <= 0;
            end
        else if (mb_x_in == 0 && chroma4x4BlkIdx_x == 0)
            begin
                nC_cr_out <= nB_cr;
            end
        else if (mb_y_in == 0 && chroma4x4BlkIdx_y == 0)
            begin
                nC_cr_out <= nA_cr;
            end
        else
            begin
                nC_cr_out <= (nA_cr + nB_cr + 1) >> 1;
            end
    end

endmodule