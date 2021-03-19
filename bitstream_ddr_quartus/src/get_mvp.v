//--------------------------------------------------------------------------------------------------
// Design    : bitstream_p
// Author(s) : qiu bin, shi tian qi
// Email     : chat1@126.com, tishi1@126.com
// Copyright (C) 2013 qiu bin 
// All rights reserved                
//-------------------------------------------------------------------------------------------------


`include "defines.v"

module get_mvp
(
 mb_index_in,
 luma4x4BlkIdx_in,
 pixel_y_in,
 pixel_x_in,
 MbPartWidth_in,
 MbPartHeight_in,
 ref_idx_l0_in,
 pic_width_in_mbs,
 ref_idx_l0_left_mb_in,
 ref_idx_l0_curr_mb_in,
 ref_idx_l0_up_left_mb_in,
 ref_idx_l0_up_mb_in,
 ref_idx_l0_up_right_mb_in,
 mvx_l0_left_mb_in,
 mvx_l0_curr_mb_in,
 mvx_l0_up_left_mb_in,
 mvx_l0_up_mb_in,
 mvx_l0_up_right_mb_in,
 mvy_l0_left_mb_in,
 mvy_l0_curr_mb_in,
 mvy_l0_up_left_mb_in,
 mvy_l0_up_mb_in,
 mvy_l0_up_right_mb_in,
 mvpx_l0_out,
 mvpy_l0_out
);

input[`mb_x_bits + `mb_y_bits - 1:0]  mb_index_in;
input[3:0]   luma4x4BlkIdx_in;
input[`mb_y_bits + 3:0]  pixel_y_in;
input[`mb_x_bits + 3:0]  pixel_x_in;
input[4:0]   MbPartWidth_in;
input[4:0]   MbPartHeight_in;
input[2:0]   ref_idx_l0_in;
input[`mb_x_bits - 1:0]   pic_width_in_mbs;

input[5:0] ref_idx_l0_left_mb_in;
input[11:0] ref_idx_l0_curr_mb_in;
input[5:0]  ref_idx_l0_up_left_mb_in;
input[5:0]  ref_idx_l0_up_mb_in;
input[5:0]  ref_idx_l0_up_right_mb_in;

input[63:0] mvx_l0_left_mb_in;
input[255:0] mvx_l0_curr_mb_in;
input[15:0] mvx_l0_up_left_mb_in; // only right most 4x4 blk is used
input[63:0] mvx_l0_up_mb_in;
input[15:0] mvx_l0_up_right_mb_in; // only left most 4x4 blk is used

input[63:0] mvy_l0_left_mb_in;
input[255:0] mvy_l0_curr_mb_in;
input[15:0] mvy_l0_up_left_mb_in;
input[63:0] mvy_l0_up_mb_in;
input[15:0] mvy_l0_up_right_mb_in;

output[15:0] mvpx_l0_out;
output[15:0] mvpy_l0_out;

reg up_right_avail;
reg up_avail;
reg left_avail;
reg up_left_avail;

reg[`mb_x_bits + `mb_y_bits - 1:0] mb_index_up_right;
reg[3:0] luma4x4BlkIdx_up_right;
reg[3:0] luma4x4BlkIdx_scan_up_right;

reg[3:0] luma4x4BlkIdx_uprightmost;

reg signed[2:0] ref_idx_l0_up_left;
reg signed[2:0] ref_idx_l0_up;
reg signed[2:0] ref_idx_l0_left;
reg signed[2:0] ref_idx_l0_up_right_mid;
reg signed[2:0] ref_idx_l0_up_right;

reg signed[15:0] mvx_l0_up_left;
reg signed[15:0] mvx_l0_up;
reg signed[15:0] mvx_l0_up_right;
reg signed[15:0] mvx_l0_left;

reg signed[15:0] mvy_l0_up_left;
reg signed[15:0] mvy_l0_up;
reg signed[15:0] mvy_l0_up_right;
reg signed[15:0] mvy_l0_left;

reg signed[15:0] mvpx_l0_out;
reg signed[15:0] mvpy_l0_out;

reg[2:0] ref_idx_l0; // ref_idx_l0_in, depricated

always @(luma4x4BlkIdx_in or ref_idx_l0_curr_mb_in)
    case (luma4x4BlkIdx_in)
        0,1,2,3:     ref_idx_l0 <= ref_idx_l0_curr_mb_in[2:0];
        4,5,6,7:     ref_idx_l0 <= ref_idx_l0_curr_mb_in[5:3];
        8,9,10,11:   ref_idx_l0 <= ref_idx_l0_curr_mb_in[8:6];
        12,13,14,15: ref_idx_l0 <= ref_idx_l0_curr_mb_in[11:9];        
    endcase

always @(pixel_y_in or pixel_x_in or pic_width_in_mbs or MbPartWidth_in)
    begin
        mb_index_up_right <= ((pixel_y_in - 4) >> 4) * (pic_width_in_mbs) + ((pixel_x_in + MbPartWidth_in) >> 4);
        luma4x4BlkIdx_scan_up_right <= ((((pixel_y_in - 4) % 16) >>2 )<<2) + (((pixel_x_in + MbPartWidth_in) % 16) >> 2); // fix: + has high priority than >>
    end
    
always @(luma4x4BlkIdx_scan_up_right)
    case(luma4x4BlkIdx_scan_up_right)
        2:luma4x4BlkIdx_up_right <= 4;
        3:luma4x4BlkIdx_up_right <= 5;
        4:luma4x4BlkIdx_up_right <= 2;
        5:luma4x4BlkIdx_up_right <= 3;
        10:luma4x4BlkIdx_up_right <= 12;
        11:luma4x4BlkIdx_up_right <= 13;
        12:luma4x4BlkIdx_up_right <= 10;
        13:luma4x4BlkIdx_up_right <= 11;
        default:luma4x4BlkIdx_up_right <= luma4x4BlkIdx_scan_up_right;
    endcase

always @(pixel_x_in or pixel_y_in or MbPartWidth_in or MbPartHeight_in 
             or ref_idx_l0 or ref_idx_l0_up_mb_in or ref_idx_l0_curr_mb_in or ref_idx_l0_up_left_mb_in 
                 or luma4x4BlkIdx_in or ref_idx_l0_left_mb_in)
    begin   
        if( pixel_y_in > 0 )
            begin
                up_avail <= 1;
                case(luma4x4BlkIdx_in)
                    0,1:                 ref_idx_l0_up <= ref_idx_l0_up_mb_in[2:0];
                    4,5:                 ref_idx_l0_up <= ref_idx_l0_up_mb_in[5:3];
                    2,3,6,7,10,11,14,15: ref_idx_l0_up <= ref_idx_l0;
                    8,9:                 ref_idx_l0_up <= ref_idx_l0_curr_mb_in[2:0];
                    12,13:               ref_idx_l0_up <= ref_idx_l0_curr_mb_in[5:3];
                endcase
            end
        else
            begin
                up_avail <= 0;
                ref_idx_l0_up <= -1;                
            end
            
        if (pixel_x_in > 0 && pixel_y_in > 0)
            begin
                up_left_avail <= 1;
                case(luma4x4BlkIdx_in)
                    0:         ref_idx_l0_up_left <= ref_idx_l0_up_left_mb_in[5:3];
                    1,4:       ref_idx_l0_up_left <= ref_idx_l0_up_mb_in[2:0];
                    5:         ref_idx_l0_up_left <= ref_idx_l0_up_mb_in[5:3];
                    2,8:       ref_idx_l0_up_left <= ref_idx_l0_left_mb_in[2:0];
                    10:        ref_idx_l0_up_left <= ref_idx_l0_left_mb_in[5:3];
                    3,7,11,15: ref_idx_l0_up_left <= ref_idx_l0;
                    6,9,12:    ref_idx_l0_up_left <= ref_idx_l0_curr_mb_in[2:0];
                    13:        ref_idx_l0_up_left <= ref_idx_l0_curr_mb_in[5:3];
                    14:        ref_idx_l0_up_left <= ref_idx_l0_curr_mb_in[8:6];
                endcase                
            end
        else
            begin
                up_left_avail <= 0;
                ref_idx_l0_up_left <= -1;
            end
            
        if (pixel_x_in > 0 )
            begin
                left_avail <= 1;
                case(luma4x4BlkIdx_in)
                    0,2:                ref_idx_l0_left <= ref_idx_l0_left_mb_in[2:0];
                    8,10:               ref_idx_l0_left <= ref_idx_l0_left_mb_in[5:3];
                    1,3,9,11,5,7,13,15: ref_idx_l0_left <= ref_idx_l0;
                    4,6:                ref_idx_l0_left <= ref_idx_l0_curr_mb_in[2:0];
                    12,14:              ref_idx_l0_left <= ref_idx_l0_curr_mb_in[8:6];
                endcase
            end
        else
            begin
                left_avail <= 0;
                ref_idx_l0_left <= -1;
            end
    end

always @(pixel_x_in or pixel_y_in or MbPartWidth_in or MbPartHeight_in or ref_idx_l0_up_right_mid or mb_index_in
            or mb_index_up_right or luma4x4BlkIdx_up_right or ref_idx_l0_up_left or luma4x4BlkIdx_in 
            or pic_width_in_mbs)
    if((pixel_y_in - 4 ) < 0 || (pixel_x_in + MbPartWidth_in) >= ((pic_width_in_mbs)<<4) || 
        (mb_index_up_right > mb_index_in) || 
         (mb_index_up_right == mb_index_in && luma4x4BlkIdx_up_right > luma4x4BlkIdx_in) )
        begin
            up_right_avail <= 0;
            ref_idx_l0_up_right <= ref_idx_l0_up_left;
        end
    else
        begin
            up_right_avail <= 1;
            ref_idx_l0_up_right <= ref_idx_l0_up_right_mid;
        end

	//0  1  4   5 
    //2  3  6   7
    //8  9  12  13
    //10 11  14  15
   //           --------         ------------------
	//          |        |       |                  |
	//          |  up    |       |    up_right      |
	//          |        |       |                  |
	//  -------- ---------------- ------------------
	// |        |                |
	// |   left |                |
	// |        |                |
	//  --------|                |
	//          |                |
	//           ----------------
	// 6's up right is not 5?
	// RefIdx[(y - 1) / 2][(x + MbPartWidth) / 2] 

always @(pixel_x_in or pixel_y_in or MbPartWidth_in or ref_idx_l0_up_left
            or pic_width_in_mbs or ref_idx_l0_curr_mb_in 
            or ref_idx_l0_up_mb_in or ref_idx_l0_up_right_mb_in or luma4x4BlkIdx_uprightmost)
    if(pixel_y_in > 0 && (pixel_x_in + MbPartWidth_in) < (pic_width_in_mbs)<<4  )
        case(luma4x4BlkIdx_uprightmost)
            0:  ref_idx_l0_up_right_mid <= ref_idx_l0_up_mb_in[2:0];
            1,4:  ref_idx_l0_up_right_mid <= ref_idx_l0_up_mb_in[5:3];
            2,8:  ref_idx_l0_up_right_mid <= ref_idx_l0_curr_mb_in[2:0];
            3,6,9,12:  ref_idx_l0_up_right_mid <= ref_idx_l0_curr_mb_in[5:3];
            5:  ref_idx_l0_up_right_mid <= ref_idx_l0_up_right_mb_in[2:0];
            10: ref_idx_l0_up_right_mid <= ref_idx_l0_curr_mb_in[8:6];
            11,14: ref_idx_l0_up_right_mid <= ref_idx_l0_curr_mb_in[11:9];
            default : ref_idx_l0_up_right_mid <= -1;
        endcase
    else
        begin
            ref_idx_l0_up_right_mid <= -1; 
        end

always @ (ref_idx_l0_up_left or mvx_l0_up_left_mb_in or mvx_l0_up_mb_in or mvx_l0_curr_mb_in 
            or mvy_l0_left_mb_in or mvy_l0_up_mb_in or mvy_l0_curr_mb_in or mvy_l0_up_left_mb_in
            or luma4x4BlkIdx_in or mvx_l0_left_mb_in)  
   if (ref_idx_l0_up_left == -1)
       begin
           mvx_l0_up_left <= 0;
           mvy_l0_up_left <= 0;
       end 
   else
       case(luma4x4BlkIdx_in)
           0:  begin mvx_l0_up_left <= mvx_l0_up_left_mb_in; mvy_l0_up_left <= mvy_l0_up_left_mb_in; end
           1:  begin mvx_l0_up_left <= mvx_l0_up_mb_in[15:0];        mvy_l0_up_left <= mvy_l0_up_mb_in[15:0];        end
           2:  begin mvx_l0_up_left <= mvx_l0_left_mb_in[15:0];      mvy_l0_up_left <= mvy_l0_left_mb_in[15:0];      end
           3:  begin mvx_l0_up_left <= mvx_l0_curr_mb_in[15:0];      mvy_l0_up_left <= mvy_l0_curr_mb_in[15:0];      end
           4:  begin mvx_l0_up_left <= mvx_l0_up_mb_in[31:16];       mvy_l0_up_left <= mvy_l0_up_mb_in[31:16];      end
           5:  begin mvx_l0_up_left <= mvx_l0_up_mb_in[47:32];      mvy_l0_up_left <= mvy_l0_up_mb_in[47:32];      end
           6:  begin mvx_l0_up_left <= mvx_l0_curr_mb_in[31:16];     mvy_l0_up_left <= mvy_l0_curr_mb_in[31:16];    end
           7:  begin mvx_l0_up_left <= mvx_l0_curr_mb_in[79:64];    mvy_l0_up_left <= mvy_l0_curr_mb_in[79:64];    end
           8:  begin mvx_l0_up_left <= mvx_l0_left_mb_in[31:16];     mvy_l0_up_left <= mvy_l0_left_mb_in[31:16];    end
           9:  begin mvx_l0_up_left <= mvx_l0_curr_mb_in[47:32];     mvy_l0_up_left <= mvy_l0_curr_mb_in[47:32];    end
           10: begin mvx_l0_up_left <= mvx_l0_left_mb_in[47:32];    mvy_l0_up_left <= mvy_l0_left_mb_in[47:32];    end
           11: begin mvx_l0_up_left <= mvx_l0_curr_mb_in[143:128];    mvy_l0_up_left <= mvy_l0_curr_mb_in[143:128];    end
           12: begin mvx_l0_up_left <= mvx_l0_curr_mb_in[63:48];    mvy_l0_up_left <= mvy_l0_curr_mb_in[63:48];    end
           13: begin mvx_l0_up_left <= mvx_l0_curr_mb_in[111:96];    mvy_l0_up_left <= mvy_l0_curr_mb_in[111:96];    end
           14: begin mvx_l0_up_left <= mvx_l0_curr_mb_in[159:144];    mvy_l0_up_left <= mvy_l0_curr_mb_in[159:144];    end
           15: begin mvx_l0_up_left <= mvx_l0_curr_mb_in[207:192];    mvy_l0_up_left <= mvy_l0_curr_mb_in[207:192];  end
       endcase

always @ (ref_idx_l0_up or mvx_l0_up_mb_in or mvx_l0_curr_mb_in
            or mvy_l0_up_mb_in or mvy_l0_curr_mb_in or luma4x4BlkIdx_in)
    if (ref_idx_l0_up == -1)
        begin
            mvx_l0_up <= 0;
            mvy_l0_up <= 0;
        end
    else
        case(luma4x4BlkIdx_in)
           0:  begin mvx_l0_up <= mvx_l0_up_mb_in[15:0];        mvy_l0_up <= mvy_l0_up_mb_in[15:0];          end
           1:  begin mvx_l0_up <= mvx_l0_up_mb_in[31:16];       mvy_l0_up <= mvy_l0_up_mb_in[31:16];        end
           2:  begin mvx_l0_up <= mvx_l0_curr_mb_in[15:0];      mvy_l0_up <= mvy_l0_curr_mb_in[15:0];        end
           3:  begin mvx_l0_up <= mvx_l0_curr_mb_in[31:16];     mvy_l0_up <= mvy_l0_curr_mb_in[31:16];      end
           4:  begin mvx_l0_up <= mvx_l0_up_mb_in[47:32];      mvy_l0_up <= mvy_l0_up_mb_in[47:32];        end
           5:  begin mvx_l0_up <= mvx_l0_up_mb_in[63:48];      mvy_l0_up <= mvy_l0_up_mb_in[63:48];        end
           6:  begin mvx_l0_up <= mvx_l0_curr_mb_in[79:64];    mvy_l0_up <= mvy_l0_curr_mb_in[79:64];      end
           7:  begin mvx_l0_up <= mvx_l0_curr_mb_in[95:80];    mvy_l0_up <= mvy_l0_curr_mb_in[95:80];      end
           8:  begin mvx_l0_up <= mvx_l0_curr_mb_in[47:32];     mvy_l0_up <= mvy_l0_curr_mb_in[47:32];      end
           9:  begin mvx_l0_up <= mvx_l0_curr_mb_in[63:48];    mvy_l0_up <= mvy_l0_curr_mb_in[63:48];      end
           10: begin mvx_l0_up <= mvx_l0_curr_mb_in[143:128];    mvy_l0_up <= mvy_l0_curr_mb_in[143:128];      end
           11: begin mvx_l0_up <= mvx_l0_curr_mb_in[159:144];    mvy_l0_up <= mvy_l0_curr_mb_in[159:144];      end
           12: begin mvx_l0_up <= mvx_l0_curr_mb_in[111:96];    mvy_l0_up <= mvy_l0_curr_mb_in[111:96];      end
           13: begin mvx_l0_up <= mvx_l0_curr_mb_in[127:112];    mvy_l0_up <= mvy_l0_curr_mb_in[127:112];      end
           14: begin mvx_l0_up <= mvx_l0_curr_mb_in[207:192];    mvy_l0_up <= mvy_l0_curr_mb_in[207:192];    end
           15: begin mvx_l0_up <= mvx_l0_curr_mb_in[223:208];   mvy_l0_up <= mvy_l0_curr_mb_in[223:208];    end            
        endcase

always @ (ref_idx_l0_left or mvx_l0_left_mb_in or mvx_l0_curr_mb_in
            or mvy_l0_left_mb_in or mvy_l0_curr_mb_in or luma4x4BlkIdx_in) 
    if (ref_idx_l0_left == -1) // fix: ref_idx_l0_left should be declared as signed, otherwise it never equals -1
        begin
            mvx_l0_left <= 0;
            mvy_l0_left <= 0;
        end
    else
        case(luma4x4BlkIdx_in)
            0:  begin mvx_l0_left <= mvx_l0_left_mb_in[15:0];      mvy_l0_left <= mvy_l0_left_mb_in[15:0];      end
            1:  begin mvx_l0_left <= mvx_l0_curr_mb_in[15:0];      mvy_l0_left <= mvy_l0_curr_mb_in[15:0];      end
            2:  begin mvx_l0_left <= mvx_l0_left_mb_in[31:16];    mvy_l0_left <= mvy_l0_left_mb_in[31:16];    end
            3:  begin mvx_l0_left <= mvx_l0_curr_mb_in[47:32];    mvy_l0_left <= mvy_l0_curr_mb_in[47:32];    end
            4:  begin mvx_l0_left <= mvx_l0_curr_mb_in[31:16];    mvy_l0_left <= mvy_l0_curr_mb_in[31:16];    end
            5:  begin mvx_l0_left <= mvx_l0_curr_mb_in[79:64];    mvy_l0_left <= mvy_l0_curr_mb_in[79:64];    end
            6:  begin mvx_l0_left <= mvx_l0_curr_mb_in[63:48];    mvy_l0_left <= mvy_l0_curr_mb_in[63:48];    end
            7:  begin mvx_l0_left <= mvx_l0_curr_mb_in[111:96];    mvy_l0_left <= mvy_l0_curr_mb_in[111:96];    end
            8:  begin mvx_l0_left <= mvx_l0_left_mb_in[47:32];    mvy_l0_left <= mvy_l0_left_mb_in[47:32];    end
            9:  begin mvx_l0_left <= mvx_l0_curr_mb_in[143:128];    mvy_l0_left <= mvy_l0_curr_mb_in[143:128];    end
            10: begin mvx_l0_left <= mvx_l0_left_mb_in[63:48];    mvy_l0_left <= mvy_l0_left_mb_in[63:48];    end
            11: begin mvx_l0_left <= mvx_l0_curr_mb_in[175:160];    mvy_l0_left <= mvy_l0_curr_mb_in[175:160];    end
            12: begin mvx_l0_left <= mvx_l0_curr_mb_in[159:144];    mvy_l0_left <= mvy_l0_curr_mb_in[159:144];    end
            13: begin mvx_l0_left <= mvx_l0_curr_mb_in[207:192];  mvy_l0_left <= mvy_l0_curr_mb_in[207:192];  end
            14: begin mvx_l0_left <= mvx_l0_curr_mb_in[191:176];  mvy_l0_left <= mvy_l0_curr_mb_in[191:176];  end
            15: begin mvx_l0_left <= mvx_l0_curr_mb_in[239:224];  mvy_l0_left <= mvy_l0_curr_mb_in[239:224];  end     
        endcase      

always @(luma4x4BlkIdx_in or MbPartWidth_in)
    case(luma4x4BlkIdx_in)
        0:
            if(MbPartWidth_in == 4)
                luma4x4BlkIdx_uprightmost <= 0;
            else if(MbPartWidth_in == 8)
                luma4x4BlkIdx_uprightmost <= 1;
            else // MbPartWidth = 16
                luma4x4BlkIdx_uprightmost <= 5;
        2:
            if(MbPartWidth_in == 4)
                luma4x4BlkIdx_uprightmost <= 2;
            else if(MbPartWidth_in == 8)
                luma4x4BlkIdx_uprightmost <= 3;
            else // MbPartWidth = 16
                luma4x4BlkIdx_uprightmost <= 7;        

        4:
            if(MbPartWidth_in == 4)
                luma4x4BlkIdx_uprightmost <= 4;
            else // MbPartWidth = 8
                luma4x4BlkIdx_uprightmost <= 5;
        6:
            if(MbPartWidth_in == 4)
                luma4x4BlkIdx_uprightmost <= 6;
            else // MbPartWidth = 8
                luma4x4BlkIdx_uprightmost <= 7;        
        8:
            if(MbPartWidth_in == 4)
                luma4x4BlkIdx_uprightmost <= 8;
            else if(MbPartWidth_in == 8)
                luma4x4BlkIdx_uprightmost <= 9;
            else // MbPartWidth = 16
                luma4x4BlkIdx_uprightmost <= 13;        

        10:
            if(MbPartWidth_in == 4)
                luma4x4BlkIdx_uprightmost <= 10;
            else if(MbPartWidth_in == 8)
                luma4x4BlkIdx_uprightmost <= 11;
            else // MbPartWidth = 16
                luma4x4BlkIdx_uprightmost <= 15;        

        12:
            if(MbPartWidth_in == 4)
                luma4x4BlkIdx_uprightmost <= 12;
            else // MbPartWidth = 8
                luma4x4BlkIdx_uprightmost <= 13;        
        14:
            if(MbPartWidth_in == 4)
                luma4x4BlkIdx_uprightmost <= 14;
            else // MbPartWidth = 8
                luma4x4BlkIdx_uprightmost <= 15;        
        default:
            luma4x4BlkIdx_uprightmost <= luma4x4BlkIdx_in;
    endcase    
        


always @ (up_right_avail or mvx_l0_up_left
             or mvy_l0_up_left or mvx_l0_up_mb_in or mvx_l0_curr_mb_in or mvx_l0_up_right_mb_in
             or mvy_l0_up_mb_in or mvy_l0_curr_mb_in or mvy_l0_up_right_mb_in or luma4x4BlkIdx_uprightmost)
    if ( up_right_avail )
        case(luma4x4BlkIdx_uprightmost)
            0:  
                begin
                mvx_l0_up_right <= mvx_l0_up_mb_in[31:16];
                mvy_l0_up_right <= mvy_l0_up_mb_in[31:16];
                end
            1:  
                begin 
                mvx_l0_up_right <= mvx_l0_up_mb_in[47:32];      
                mvy_l0_up_right <= mvy_l0_up_mb_in[47:32];      
                end
            2:  
                begin 
                mvx_l0_up_right <= mvx_l0_curr_mb_in[31:16];    
                mvy_l0_up_right <= mvy_l0_curr_mb_in[31:16];    
                end
            4:  
                begin
                mvx_l0_up_right <= mvx_l0_up_mb_in[63:48];      
                mvy_l0_up_right <= mvy_l0_up_mb_in[63:48];                      
                end
            5:  
                begin 
                mvx_l0_up_right <= mvx_l0_up_right_mb_in[15:0];      
                mvy_l0_up_right <= mvy_l0_up_right_mb_in[15:0];
                end
            6:  
                begin 
                mvx_l0_up_right <= mvx_l0_curr_mb_in[95:80];    
                mvy_l0_up_right <= mvy_l0_curr_mb_in[95:80];    
                end
            8:  
                begin 
                mvx_l0_up_right <= mvx_l0_curr_mb_in[63:48];    
                mvy_l0_up_right <= mvy_l0_curr_mb_in[63:48];    
                end
            9:  
                begin 
                mvx_l0_up_right <= mvx_l0_curr_mb_in[111:96];    
                mvy_l0_up_right <= mvy_l0_curr_mb_in[111:96];    
                end
            10: 
                begin 
                mvx_l0_up_right <= mvx_l0_curr_mb_in[159:144];    
                mvy_l0_up_right <= mvy_l0_curr_mb_in[159:144];    
                end
            12: 
                begin 
                mvx_l0_up_right <= mvx_l0_curr_mb_in[127:112];    
                mvy_l0_up_right <= mvy_l0_curr_mb_in[127:112];    
                end
            14: 
                begin 
                mvx_l0_up_right <= mvx_l0_curr_mb_in[223:208];  
                mvy_l0_up_right <= mvy_l0_curr_mb_in[223:208];  
                end 
            //default : begin mvx_l0_up_right <= -1; mvy_l0_up_right <= -1; end
            default : begin mvx_l0_up_right <= mvx_l0_up_left; mvy_l0_up_right <= mvy_l0_up_left; end        
        endcase
    else
        begin
            mvx_l0_up_right <= mvx_l0_up_left;
            mvy_l0_up_right <= mvy_l0_up_left;
        end

always @(ref_idx_l0_up_left or ref_idx_l0_up or ref_idx_l0_left or ref_idx_l0_up_right
            or mvx_l0_left or mvx_l0_up or mvx_l0_up_right or MbPartWidth_in or MbPartHeight_in
            or mvy_l0_left or mvy_l0_up or mvy_l0_up_right or up_right_avail or up_avail
            or pixel_y_in or pixel_x_in or ref_idx_l0)
    if ( ref_idx_l0_left == ref_idx_l0 && 
         ref_idx_l0_up != ref_idx_l0 &&
         ref_idx_l0_up_right != ref_idx_l0 )
        begin
            mvpx_l0_out <= mvx_l0_left;
            mvpy_l0_out <= mvy_l0_left;
        end
    else if (ref_idx_l0_left != ref_idx_l0 && 
         ref_idx_l0_up == ref_idx_l0 &&
         ref_idx_l0_up_right != ref_idx_l0 )
        begin
            mvpx_l0_out <= mvx_l0_up;
            mvpy_l0_out <= mvy_l0_up;        
        end
    else if (ref_idx_l0_left != ref_idx_l0 && 
         ref_idx_l0_up != ref_idx_l0 &&
         ref_idx_l0_up_right == ref_idx_l0) 
        begin
            mvpx_l0_out <= mvx_l0_up_right;
            mvpy_l0_out <= mvy_l0_up_right;        
        end
    else if (MbPartWidth_in == 16 && MbPartHeight_in == 8 && pixel_y_in % 16 < 8 && ref_idx_l0 == ref_idx_l0_up )
        begin // 16x8's up
            mvpx_l0_out <= mvx_l0_up;
            mvpy_l0_out <= mvy_l0_up;
        end 
    else if (MbPartWidth_in == 16 && MbPartHeight_in == 8 && pixel_y_in % 16 > 7 && ref_idx_l0 == ref_idx_l0_left )
        begin // 16x8's down
            mvpx_l0_out <= mvx_l0_left;
            mvpy_l0_out <= mvy_l0_left;
        end
    else if (MbPartWidth_in == 8 && MbPartHeight_in == 16 && pixel_x_in % 16 < 8 && ref_idx_l0 == ref_idx_l0_left)
        begin // 8x16's left
            mvpx_l0_out <= mvx_l0_left;
            mvpy_l0_out <= mvy_l0_left;
        end
    else if (MbPartWidth_in == 8 && MbPartHeight_in == 16 && pixel_x_in % 16 > 7 && ref_idx_l0 == ref_idx_l0_up_right)
        begin
            mvpx_l0_out <= mvx_l0_up_right;
            mvpy_l0_out <= mvy_l0_up_right;
        end    
    else if (up_avail == 0 && up_right_avail == 0)
        begin
            mvpx_l0_out <= mvx_l0_left;
            mvpy_l0_out <= mvy_l0_left;
        end
    else
        begin // Median(a,b,c)
            mvpx_l0_out <= mvx_l0_left > mvx_l0_up ? 
                          (mvx_l0_left > mvx_l0_up_right ? 
                              (mvx_l0_up > mvx_l0_up_right ? mvx_l0_up : mvx_l0_up_right): mvx_l0_left)
                          :(mvx_l0_left > mvx_l0_up_right ?
                              mvx_l0_left : (mvx_l0_up < mvx_l0_up_right ?mvx_l0_up:mvx_l0_up_right));
            mvpy_l0_out <= mvy_l0_left > mvy_l0_up ? 
                          (mvy_l0_left > mvy_l0_up_right ? 
                              (mvy_l0_up > mvy_l0_up_right ? mvy_l0_up : mvy_l0_up_right): mvy_l0_left)
                          :(mvy_l0_left > mvy_l0_up_right ?
                              mvy_l0_left : (mvy_l0_up < mvy_l0_up_right ? mvy_l0_up : mvy_l0_up_right));
        end                   

    
endmodule