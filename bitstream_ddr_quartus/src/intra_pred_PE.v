//--------------------------------------------------------------------------------------------------
// Design    : bitstream_p
// Author(s) : qiu bin, shi tian qi
// Email     : chat1@126.com, tishi1@126.com
// Copyright (C) 2013 qiu bin 
// All rights reserved                
//-------------------------------------------------------------------------------------------------


`include "defines.v"

//proceed 1 colum at a time

module intra_pred_PE
(
    clk,
    rst_n,
    ena,
    calc_counter,
    blk4x4_counter,
    mb_pred_mode,
    I16_pred_mode,
    I4_pred_mode,
    intra_pred_mode_chroma,
    
    up_avail,
    left_avail,
	up_right_avail,
	
	b,
	c,
	seed,
	
    up_mb_0,
    up_mb_1,
    up_mb_2,
    up_mb_3,
    up_mb_4,
    up_mb_5,
    up_mb_6,
    up_mb_7,
    up_mb_8,
    up_mb_9,
    up_mb_10,
    up_mb_11,
    up_mb_12,
    up_mb_13,
    up_mb_14,
    up_mb_15,

    left_mb_0,
    left_mb_1,
    left_mb_2,
    left_mb_3,
    left_mb_4,
    left_mb_5,
    left_mb_6,
    left_mb_7,
    left_mb_8,
    left_mb_9,
    left_mb_10,
    left_mb_11,
    left_mb_12,
    left_mb_13,
    left_mb_14,
    left_mb_15,

   	up_left_0,
	up_left_1,
	up_left_2,
	up_left_3,
	up_left_4,
	up_left_5,
	up_left_6,
	up_left_7,
	
	up_right_0,
	up_right_1,	
	up_right_2,
	up_right_3,
    
    intra_pred_0,
    intra_pred_1,
    intra_pred_2,
    intra_pred_4,
    intra_pred_5,
    intra_pred_6,
    intra_pred_8,
    intra_pred_9,
    intra_pred_10,
    intra_pred_12,
    intra_pred_13,
    intra_pred_14,

    PE0_out,
    PE1_out,
    PE2_out,
    PE3_out,
    
    PE0_sum_reg,
    PE3_sum_reg
);
input clk;
input rst_n;
input ena;

input [1:0] calc_counter;
input [4:0] blk4x4_counter;
input [3:0] mb_pred_mode;
input [1:0] I16_pred_mode;
input [3:0] I4_pred_mode;
input [1:0] intra_pred_mode_chroma;

input up_avail;
input left_avail;
input up_right_avail;

input [11:0] b;
input [11:0] c;
input [14:0] seed;

input [7:0] up_mb_0;
input [7:0] up_mb_1;
input [7:0] up_mb_2;
input [7:0] up_mb_3;
input [7:0] up_mb_4;
input [7:0] up_mb_5;
input [7:0] up_mb_6;
input [7:0] up_mb_7;
input [7:0] up_mb_8;
input [7:0] up_mb_9;
input [7:0] up_mb_10;
input [7:0] up_mb_11;
input [7:0] up_mb_12;
input [7:0] up_mb_13;
input [7:0] up_mb_14;
input [7:0] up_mb_15;
input [7:0] left_mb_0;
input [7:0] left_mb_1;
input [7:0] left_mb_2;
input [7:0] left_mb_3;
input [7:0] left_mb_4;
input [7:0] left_mb_5;
input [7:0] left_mb_6;
input [7:0] left_mb_7;
input [7:0] left_mb_8;
input [7:0] left_mb_9;
input [7:0] left_mb_10;
input [7:0] left_mb_11;
input [7:0] left_mb_12;
input [7:0] left_mb_13;
input [7:0] left_mb_14;
input [7:0] left_mb_15;

input [7:0] up_left_0;
input [7:0] up_left_1;
input [7:0] up_left_2;
input [7:0] up_left_3;
input [7:0] up_left_4;
input [7:0] up_left_5;
input [7:0] up_left_6;
input [7:0] up_left_7;

input [7:0] up_right_0;
input [7:0] up_right_1;
input [7:0] up_right_2;
input [7:0] up_right_3;

input [7:0] intra_pred_0;
input [7:0] intra_pred_1;
input [7:0] intra_pred_2;
input [7:0] intra_pred_4;
input [7:0] intra_pred_5;
input [7:0] intra_pred_6;
input [7:0] intra_pred_8;
input [7:0] intra_pred_9;
input [7:0] intra_pred_10;
input [7:0] intra_pred_12;
input [7:0] intra_pred_13;
input [7:0] intra_pred_14;

output [7:0] PE0_out;
output [7:0] PE1_out;
output [7:0] PE2_out;
output [7:0] PE3_out;

output [14:0] PE0_sum_reg;
output [14:0] PE3_sum_reg;

reg  [14:0] PE0_in0;
reg  [14:0] PE0_in1;
reg  [14:0] PE0_in2;
reg  [14:0] PE0_in3;
reg  PE0_store_sum;
reg  [4 :0] PE0_round_value;
reg  [2 :0] PE0_shift_num;
reg  PE0_bypass;
wire [14:0] PE0_sum_reg;
wire [7 :0] PE0_out;

reg  [14:0] PE1_in0;
reg  [14:0] PE1_in1;
reg  [14:0] PE1_in2;
reg  [14:0] PE1_in3;
reg  PE1_store_sum;
reg  [4 :0] PE1_round_value;
reg  [2 :0] PE1_shift_num;
reg  PE1_bypass;
wire [14:0] PE1_sum_reg;
wire [7 :0] PE1_out;

reg  [14:0] PE2_in0;
reg  [14:0] PE2_in1;
reg  [14:0] PE2_in2;
reg  [14:0] PE2_in3;
reg  PE2_store_sum;
reg  [4 :0] PE2_round_value;
reg  [2 :0] PE2_shift_num;
reg  PE2_bypass;
wire [14:0] PE2_sum_reg;
wire [7 :0] PE2_out;

reg  [14:0] PE3_in0;
reg  [14:0] PE3_in1;
reg  [14:0] PE3_in2;
reg  [14:0] PE3_in3;
reg  PE3_store_sum;
reg  [4 :0] PE3_round_value;
reg  [2 :0] PE3_shift_num;
reg  PE3_bypass;
wire [14:0] PE3_sum_reg;
wire [7 :0] PE3_out;

PE PE0
(
    .clk            (clk            ),
    .rst_n          (rst_n          ),
    .ena            (ena            ),
    .in0            (PE0_in0        ),
    .in1            (PE0_in1        ),
    .in2            (PE0_in2        ),
    .in3            (PE0_in3        ),
    .store_sum      (PE0_store_sum  ),
    .round_value    (PE0_round_value),
    .shift_num      (PE0_shift_num  ),
    .bypass         (PE0_bypass     ),
    .sum_reg        (PE0_sum_reg    ),
    .out            (PE0_out        )
);

PE PE1
(
    .clk            (clk            ),
    .rst_n          (rst_n          ),
    .ena            (ena            ),
    .in0            (PE1_in0        ),
    .in1            (PE1_in1        ),
    .in2            (PE1_in2        ),
    .in3            (PE1_in3        ),
    .store_sum      (PE1_store_sum  ),
    .round_value    (PE1_round_value),
    .shift_num      (PE1_shift_num  ),
    .bypass         (PE1_bypass     ),
    .sum_reg        (PE1_sum_reg    ),
    .out            (PE1_out        )
);
PE PE2
(
    .clk            (clk            ),
    .rst_n          (rst_n          ),
    .ena            (ena            ),
    .in0            (PE2_in0        ),
    .in1            (PE2_in1        ),
    .in2            (PE2_in2        ),
    .in3            (PE2_in3        ),
    .store_sum      (PE2_store_sum  ),
    .round_value    (PE2_round_value),
    .shift_num      (PE2_shift_num  ),
    .bypass         (PE2_bypass     ),
    .sum_reg        (PE2_sum_reg    ),
    .out            (PE2_out        )
);

PE PE3
(
    .clk            (clk            ),
    .rst_n          (rst_n          ),
    .ena            (ena            ),
    .in0            (PE3_in0        ),
    .in1            (PE3_in1        ),
    .in2            (PE3_in2        ),
    .in3            (PE3_in3        ),
    .store_sum      (PE3_store_sum  ),
    .round_value    (PE3_round_value),
    .shift_num      (PE3_shift_num  ),
    .bypass         (PE3_bypass     ),
    .sum_reg        (PE3_sum_reg    ),
    .out            (PE3_out        )
);

reg [7:0] up_mb_muxout_0;
reg [7:0] up_mb_muxout_1;
reg [7:0] up_mb_muxout_2;
reg [7:0] up_mb_muxout_3;

reg [7:0] left_mb_muxout_0;
reg [7:0] left_mb_muxout_1;
reg [7:0] left_mb_muxout_2;
reg [7:0] left_mb_muxout_3;

reg [7:0] up_right_muxout_0;
reg [7:0] up_right_muxout_1;
reg [7:0] up_right_muxout_2;
reg [7:0] up_right_muxout_3;

reg	[7:0] up_left_muxout;

wire [14:0] b_ext;
wire [14:0] c_ext;

assign b_ext = {{3{b[11]}},b};
assign c_ext = {{3{c[11]}},c};
always @(*)
    case(blk4x4_counter)
        0,2,8,10,16,18,20,22:begin
            up_mb_muxout_0 <= up_mb_0;
            up_mb_muxout_1 <= up_mb_1;
            up_mb_muxout_2 <= up_mb_2;
            up_mb_muxout_3 <= up_mb_3;
        end
        1,3,9,11,17,19,21,23:begin
            up_mb_muxout_0 <= up_mb_4;
            up_mb_muxout_1 <= up_mb_5;
            up_mb_muxout_2 <= up_mb_6;
            up_mb_muxout_3 <= up_mb_7;
        end
        4,6,12,14:begin
            up_mb_muxout_0 <= up_mb_8;
            up_mb_muxout_1 <= up_mb_9;
            up_mb_muxout_2 <= up_mb_10;
            up_mb_muxout_3 <= up_mb_11;
        end
        default:begin
            up_mb_muxout_0 <= up_mb_12;
            up_mb_muxout_1 <= up_mb_13;
            up_mb_muxout_2 <= up_mb_14;
            up_mb_muxout_3 <= up_mb_15;
        end
    endcase

always @(*)
    case(blk4x4_counter)
        0,1,4,5,16,17,20,21:begin
            left_mb_muxout_0 <= left_mb_0;
            left_mb_muxout_1 <= left_mb_1;
            left_mb_muxout_2 <= left_mb_2;
            left_mb_muxout_3 <= left_mb_3;
        end
        2,3,6,7,18,19,22,23:begin
            left_mb_muxout_0 <= left_mb_4;
            left_mb_muxout_1 <= left_mb_5;
            left_mb_muxout_2 <= left_mb_6;
            left_mb_muxout_3 <= left_mb_7;
        end
        8,9,12,13:begin
            left_mb_muxout_0 <= left_mb_8;
            left_mb_muxout_1 <= left_mb_9;
            left_mb_muxout_2 <= left_mb_10;
            left_mb_muxout_3 <= left_mb_11;
        end
        default:begin
            left_mb_muxout_0 <= left_mb_12;
            left_mb_muxout_1 <= left_mb_13;
            left_mb_muxout_2 <= left_mb_14;
            left_mb_muxout_3 <= left_mb_15;
        end
    endcase


always @(*)
    case(blk4x4_counter)
    	0:begin
    		up_right_muxout_0 <= up_mb_4;
            up_right_muxout_1 <= up_mb_5;
            up_right_muxout_2 <= up_mb_6;
            up_right_muxout_3 <= up_mb_7;
    	end
    	1:begin
    		up_right_muxout_0 <= up_mb_8;
            up_right_muxout_1 <= up_mb_9;
            up_right_muxout_2 <= up_mb_10;
            up_right_muxout_3 <= up_mb_11;
    	end
    	4:begin
    		up_right_muxout_0 <= up_mb_12;
            up_right_muxout_1 <= up_mb_13;
            up_right_muxout_2 <= up_mb_14;
            up_right_muxout_3 <= up_mb_15;
    	end
    	5:begin
    		up_right_muxout_0 <= up_right_avail ? up_right_0:up_mb_15;
            up_right_muxout_1 <= up_right_avail ? up_right_1:up_mb_15;
            up_right_muxout_2 <= up_right_avail ? up_right_2:up_mb_15;
            up_right_muxout_3 <= up_right_avail ? up_right_3:up_mb_15;
    	end
        2,8,10:begin
            up_right_muxout_0 <= up_mb_4;
            up_right_muxout_1 <= up_mb_5;
            up_right_muxout_2 <= up_mb_6;
            up_right_muxout_3 <= up_mb_7;
        end
        9:begin
            up_right_muxout_0 <= up_mb_8;
            up_right_muxout_1 <= up_mb_9;
            up_right_muxout_2 <= up_mb_10;
            up_right_muxout_3 <= up_mb_11;
        end
        6,12,14:begin
            up_right_muxout_0 <= up_mb_12;
            up_right_muxout_1 <= up_mb_13;
            up_right_muxout_2 <= up_mb_14;
            up_right_muxout_3 <= up_mb_15;
        end
        3,11,7,13,15:begin
            up_right_muxout_0 <= up_mb_muxout_3;
            up_right_muxout_1 <= up_mb_muxout_3;
            up_right_muxout_2 <= up_mb_muxout_3;
            up_right_muxout_3 <= up_mb_muxout_3;
        end
        default:begin
            up_right_muxout_0 <= 0;
            up_right_muxout_1 <= 0;
            up_right_muxout_2 <= 0;
            up_right_muxout_3 <= 0;
        end
    endcase
    
always @(*)
    case(blk4x4_counter)
        3,13 : up_left_muxout <= up_left_0;
        6,11 : up_left_muxout <= up_left_1;
        9,14 : up_left_muxout <= up_left_2;
        12,15: up_left_muxout <= up_left_3;
        7: up_left_muxout <= up_left_4;
        1:up_left_muxout <= up_left_4;
        4:up_left_muxout <= up_left_5;
        5:up_left_muxout <= up_left_6;
		default:up_left_muxout <= up_left_7;
    endcase

always @(*)
if (mb_pred_mode == `mb_pred_mode_I16MB && blk4x4_counter < 16)
    case (I16_pred_mode)
        `Intra16x16_Vertical: begin
            case(calc_counter)
                3:PE0_in0 <= up_mb_muxout_0;
                2:PE0_in0 <= up_mb_muxout_1;
                1:PE0_in0 <= up_mb_muxout_2;
                0:PE0_in0 <= up_mb_muxout_3;
            endcase
            PE0_in1 <= 0; PE0_in2 <= 0; PE0_in3 <= 0;
            PE0_store_sum <= 0;
            PE0_bypass <= 1;
            PE0_round_value <= 0;
            PE0_shift_num <= 0;
        end
        `Intra16x16_Horizontal:begin
            PE0_in0 <= left_mb_muxout_0;
            PE0_in1 <= 0; PE0_in2 <= 0; PE0_in3 <= 0;
            PE0_store_sum <= 0; 
            PE0_bypass <= 1;
            PE0_round_value <= 0;
            PE0_shift_num <= 0;
        end
        `Intra16x16_DC:begin
            case(calc_counter)
                3:begin
                    PE0_in0 <= up_avail ? up_mb_0:0;
                    PE0_in1 <= up_avail ? up_mb_1:0;
                    PE0_in2 <= up_avail ? up_mb_2:0;
                    PE0_in3 <= up_avail ? up_mb_3:0;
                    PE0_store_sum <= 1;
                    PE0_bypass <= 0;
                    PE0_round_value <= 0;
                    PE0_shift_num <= 0;
                end
                2:begin
                    PE0_in0 <= PE0_sum_reg;
                    PE0_in1 <= left_avail ? left_mb_1:0;
                    PE0_in2 <= left_avail ? left_mb_2:0;
                    PE0_in3 <= left_avail ? left_mb_3:0;
                    PE0_store_sum <= 1;
                    PE0_bypass <= 0;
                    PE0_round_value <= 0;
                    PE0_shift_num <= 0;
                end
                1:begin
                    PE0_in0 <= PE0_sum_reg;
                    PE0_in1 <= PE1_sum_reg;
                    PE0_in2 <= PE2_sum_reg;
                    PE0_in3 <= PE3_sum_reg;
                    PE0_store_sum <= 1;
                    PE0_bypass <= 0;
                    PE0_round_value <= 0;
                    PE0_shift_num <= 0;
                end
                default:begin
                    PE0_in0 <= (up_avail || left_avail)?PE0_sum_reg:128;
                    PE0_in1 <= PE1_sum_reg;
                    PE0_in2 <= 0;
                    PE0_in3 <= 0;
                    PE0_store_sum <= 0;
                    PE0_bypass <= (up_avail || left_avail)?0:1;
                    PE0_round_value <=(up_avail && left_avail)?16:8;
                    PE0_shift_num <= (up_avail && left_avail)?5:4;
                end
            endcase
        end
		`Intra16x16_Plane: begin
			PE0_in0 <= (calc_counter == 3 && blk4x4_counter[0] == 1'b0)? 
			seed:PE0_sum_reg;
			if(calc_counter == 3 && blk4x4_counter[0] == 0)begin 
				PE0_in1 <= 0;
			end
			else begin
				PE0_in1 <= b_ext;		
			end
			PE0_in2	<= 0;		
			PE0_in3	<= 0;
			PE0_store_sum	<= 1;
			PE0_bypass		<= 0;
			PE0_round_value <= 16;
			PE0_shift_num	<= 5;
		end
        default:begin
            PE0_in0 <= 0;
            PE0_in1 <= 0;
            PE0_in2 <= 0;
            PE0_in3 <= 0;
            PE0_store_sum <= 0;
            PE0_bypass <= 0;
            PE0_round_value <= 0;
            PE0_shift_num <= 0;            
        end
    endcase
else if (mb_pred_mode == `mb_pred_mode_I4MB && blk4x4_counter < 16)
    case (I4_pred_mode)
		`Intra4x4_Vertical : begin
			case(calc_counter)
                3:PE0_in0 <= up_mb_muxout_0;
                2:PE0_in0 <= up_mb_muxout_1;
                1:PE0_in0 <= up_mb_muxout_2;
                0:PE0_in0 <= up_mb_muxout_3;
            endcase
            PE0_in1 <= 0; PE0_in2 <= 0; PE0_in3 <= 0;
            PE0_store_sum <= 0; 
            PE0_bypass <= 1; 
            PE0_round_value <= 0;
            PE0_shift_num <= 0;
		end
		`Intra4x4_Horizontal:begin
            PE0_in0 <= left_mb_muxout_0;
            PE0_in1 <= 0; PE0_in2 <= 0; PE0_in3 <= 0;
            PE0_store_sum <= 0; 
            PE0_bypass <= 1;
            PE0_round_value <= 0;
            PE0_shift_num <= 0;
        end
        `Intra4x4_DC:begin
            case(calc_counter)
                3:begin
                    PE0_in0 <= up_avail? up_mb_muxout_0:0;
                    PE0_in1 <= up_avail? up_mb_muxout_1:0;
                    PE0_in2 <= up_avail? up_mb_muxout_2:0;
                    PE0_in3 <= up_avail? up_mb_muxout_3:0;
                    PE0_store_sum <= 1;
                    PE0_bypass <= 0;
                    PE0_round_value <= 0;
                    PE0_shift_num <= 0;
                end
                2:begin
                    PE0_in0 <= PE0_sum_reg;
                    PE0_in1 <= PE1_sum_reg;
                    PE0_in2 <= 0;
                    PE0_in3 <= 0;
                    PE0_store_sum <= 1;
                    PE0_bypass <= 0;
                    PE0_round_value <= 0;
                    PE0_shift_num <= 0;
                end
                1:begin
                    PE0_in0 <= (up_avail || left_avail)?PE0_sum_reg:128;
                    PE0_in1 <= 0;
                    PE0_in2 <= 0;
                    PE0_in3 <= 0;
                    PE0_store_sum <= 0;
                    PE0_bypass <= (up_avail || left_avail)?0:1;
                    PE0_round_value <=(up_avail && left_avail)?4:2;
                    PE0_shift_num <= (up_avail && left_avail)?3:2;
                end
                default:begin
                    PE0_in0 <= 0;
                    PE0_in1 <= 0;
                    PE0_in2 <= 0;
                    PE0_in3 <= 0;
                    PE0_store_sum <= 0;
                    PE0_bypass <= 1;
                    PE0_round_value <= 0;
                    PE0_shift_num <= 0;
                end
            endcase
        end
      	`Intra4x4_Diagonal_Down_Left:begin
			case (calc_counter)
				3:PE0_in0 <= up_mb_muxout_0;
				2:PE0_in0 <= intra_pred_4;
				1:PE0_in0 <= intra_pred_8;
				0:PE0_in0 <= intra_pred_12;
				default:PE0_in0 <= 0;
			endcase
			PE0_in1 <= (calc_counter == 3)? up_mb_muxout_1<<1:0;
			PE0_in2 <= (calc_counter == 3)? up_mb_muxout_2:0;
			PE0_in3 <= 0;
			PE0_store_sum 	<= 1'b0;
			PE0_bypass		<= (calc_counter == 3)? 0:1;
			PE0_round_value <= (calc_counter == 3)? 2:0;
			PE0_shift_num	<= (calc_counter == 3)? 2:0;
		end	
		`Intra4x4_Diagonal_Down_Right:begin
			case (calc_counter)
				3:begin	
					PE0_in0 <= up_mb_muxout_0;	
					PE0_in1 <= up_left_muxout << 1;
					PE0_in2 <= left_mb_muxout_0;
				end
				2:begin	
					PE0_in0 <= up_left_muxout;	
					PE0_in1 <= up_mb_muxout_0 << 1;
					PE0_in2 <= up_mb_muxout_1;				
				end
				1:begin	
					PE0_in0 <= up_mb_muxout_0;	
					PE0_in1 <= up_mb_muxout_1 << 1;
					PE0_in2 <= up_mb_muxout_2;				
				end
				0:begin	
					PE0_in0 <= up_mb_muxout_1;	
					PE0_in1 <= up_mb_muxout_2 << 1;
					PE0_in2 <= up_mb_muxout_3;			
				end
			endcase
			PE0_in3 <= 0;
			PE0_store_sum 	<= 0;
			PE0_bypass		<= 0;
			PE0_round_value <= 2;
			PE0_shift_num	<= 2;
		end	
		`Intra4x4_Vertical_Right:begin
			case (calc_counter)
				3:begin
					PE0_in0 <= up_mb_muxout_0;
					PE0_in1 <= up_left_muxout;
				end
				2:begin	
					PE0_in0 <= up_mb_muxout_0;
					PE0_in1 <= up_mb_muxout_1;
				end
				1:begin
					PE0_in0 <= up_mb_muxout_2;
					PE0_in1 <= up_mb_muxout_1;
				end
				0:begin	
					PE0_in0 <= up_mb_muxout_2;
					PE0_in1 <= up_mb_muxout_3;
				end
			endcase
			PE0_in2 <= 0;	
			PE0_in3 <= 0;
			PE0_store_sum 	<= 0;
			PE0_bypass <= 0;
			PE0_round_value <= 1;
			PE0_shift_num	<= 1;
		end
		`Intra4x4_Horizontal_Down:begin
			case (calc_counter)
				3:begin	
					PE0_in0 <= left_mb_muxout_0;
					PE0_in1 <= up_left_muxout;
					PE0_in2 <= 0;
					PE0_round_value <= 1;
					PE0_shift_num <= 1;
				end
				2:begin	
					PE0_in0 <= left_mb_muxout_0;
					PE0_in1 <= up_left_muxout << 1;
					PE0_in2 <= up_mb_muxout_0;				
					PE0_round_value <= 2;
					PE0_shift_num <= 2;
				end
				1:begin	
					PE0_in0 <= up_left_muxout;	 
					PE0_in1 <= up_mb_muxout_0 << 1;
					PE0_in2 <= up_mb_muxout_1;
					PE0_round_value <= 2;
					PE0_shift_num <= 2;
				end
				0:begin	
					PE0_in0 <= up_mb_muxout_0;
					PE0_in1 <= up_mb_muxout_1 << 1;
					PE0_in2 <= up_mb_muxout_2;				
					PE0_round_value <= 2;
					PE0_shift_num <= 2;
				end
			endcase
			PE0_in3 <= 0;
			PE0_store_sum <= 0; 
			PE0_bypass <= 0;
		end
		`Intra4x4_Vertical_Left:begin
			case (calc_counter)
				3:PE0_in0 <= up_mb_muxout_0;
				2:PE0_in0 <= intra_pred_8;
				1:PE0_in0 <= intra_pred_9;
				0:PE0_in0 <= intra_pred_10;
			endcase
			PE0_in1 <= (calc_counter == 3)? up_mb_muxout_1:0;
			PE0_in2 <= 0;
			PE0_in3 <= 0;
			PE0_store_sum 	<= 0; 
			PE0_bypass 		<= (calc_counter == 3)? 0:1;
			PE0_round_value <= 1;
			PE0_shift_num	<= 1;
		end
		`Intra4x4_Horizontal_Up:begin
			case (calc_counter)
				3:begin	
					PE0_in0 <= left_mb_muxout_0;	
					PE0_in1 <= left_mb_muxout_1;
				end
				2:begin	
					PE0_in0 <= left_mb_muxout_0;
					PE0_in1 <= left_mb_muxout_2;
				end
				1:begin	
					PE0_in0 <= intra_pred_4;	
					PE0_in1 <= 0;	
				end
				0:begin
					PE0_in0 <= intra_pred_5;
					PE0_in1 <= 0;
				end
			endcase
			PE0_in2 <= (calc_counter == 2)? left_mb_muxout_1<<1:0;
			PE0_in3 <= 0;
			PE0_store_sum <= 0;
			PE0_bypass <= (calc_counter == 3 || calc_counter == 2)? 0:1;
			PE0_round_value <= (calc_counter == 3)? 1:
						       (calc_counter == 2)? 2:0;
		 	PE0_shift_num	<= (calc_counter == 3)? 1:
						       (calc_counter == 2)? 2:0;
		end
		default:begin
            PE0_in0 <= 0;
            PE0_in1 <= 0;
            PE0_in2 <= 0;
            PE0_in3 <= 0;
            PE0_store_sum <= 0;
            PE0_bypass <= 0;
            PE0_round_value <= 0;
            PE0_shift_num <= 0;            
        end
	endcase
else if (blk4x4_counter > 15)
	case(intra_pred_mode_chroma)
		`Intra_chroma_DC: begin
			case ({left_avail,up_avail})
				2'b00:PE0_in0 <= (calc_counter == 2)? 15'd128:15'd0;
				2'b01:PE0_in0 <= (calc_counter == 3)? up_mb_muxout_0:
								 (calc_counter == 2)? PE0_sum_reg:0;
				2'b10:PE0_in0 <= (calc_counter == 2)? PE1_sum_reg:0;
				2'b11:
				if (calc_counter == 3)
					PE0_in0 <= (blk4x4_counter == 18 || blk4x4_counter == 22)? 
								0:up_mb_muxout_0;
				else if (calc_counter == 2)
					PE0_in0 <= PE0_sum_reg;
				else
					PE0_in0 <= 0;
			endcase
			case ({left_avail,up_avail})
				2'b00:PE0_in1 <= 0;
				2'b01:PE0_in1 <= (calc_counter == 3)? up_mb_muxout_1:0;
				2'b10:PE0_in1 <= 0;
				2'b11:
				if (calc_counter == 3)
					PE0_in1 <= (blk4x4_counter == 18 || blk4x4_counter == 22)? 
								0:up_mb_muxout_1;
				else if (calc_counter == 2)
					PE0_in1 <= PE1_sum_reg;
				else
					PE0_in1 <= 0;
			endcase
			case (up_avail)
				1'b0:begin PE0_in2 <= 0; PE0_in3 <= 0; end
				1'b1:
				begin
					if (calc_counter == 3)
						begin
							PE0_in2 <= ((blk4x4_counter == 18 || blk4x4_counter == 22) && left_avail)?
										0:up_mb_muxout_2;
							PE0_in3 <= ((blk4x4_counter == 18 || blk4x4_counter == 22) && left_avail)?
										0:up_mb_muxout_3;
						end
					else
						begin PE0_in2 <= 0; PE0_in3 <= 0; end
				end
			endcase
			PE0_store_sum <= (up_avail && calc_counter == 3)? 1'b1:1'b0; 
			PE0_bypass <= (!left_avail && !up_avail && calc_counter == 2)? 1:0;
			case ({left_avail,up_avail})
				2'b00		:begin
					PE0_round_value <= 0; 
					PE0_shift_num <= 0; 
				end
				2'b01,2'b10	:begin 
					PE0_round_value <= (calc_counter == 2)? 2:0;
					PE0_shift_num   <= (calc_counter == 2)? 2:0; 
				end	
				2'b11:begin
					if (calc_counter == 2)
						begin 
							PE0_round_value <= (blk4x4_counter == 16 || blk4x4_counter == 19 || 
							blk4x4_counter == 20 || blk4x4_counter == 23)? 4:2;
							PE0_shift_num   <= (blk4x4_counter == 16 || blk4x4_counter == 19 || 
							blk4x4_counter == 20 || blk4x4_counter == 23)? 3:2;
						end
					else
						begin PE0_round_value <= 0; PE0_shift_num <= 0; end
				end		
			endcase
		end
		`Intra_chroma_Horizontal:begin
			PE0_in0 <= left_mb_muxout_0;
			PE0_in1 <= 0; 	
			PE0_in2 <= 0;	
			PE0_in3 <= 0; 		
			PE0_store_sum	<= 0;
			PE0_bypass <= 1;
			PE0_round_value <= 0;
			PE0_shift_num <= 0;
		end
		`Intra_chroma_Vertical:begin            
			case(calc_counter)          
			3:PE0_in0 <= up_mb_muxout_0;
			2:PE0_in0 <= up_mb_muxout_1;
			1:PE0_in0 <= up_mb_muxout_2;
			0:PE0_in0 <= up_mb_muxout_3;
			endcase                     
			PE0_in1 <= 0; 	            
			PE0_in2 <= 0;	            
			PE0_in3 <= 0; 		        
			PE0_store_sum	<= 0;       
			PE0_bypass <= 1;            
			PE0_round_value <= 0;       
			PE0_shift_num <= 0;         
		end 
		`Intra_chroma_Plane: begin
			PE0_in0 <= (calc_counter == 3 && blk4x4_counter[0] == 1'b0)? 
			seed:PE0_sum_reg;
			if(calc_counter == 3 && blk4x4_counter[0] == 0)begin 
				PE0_in1 <= 0;
			end
			else begin
				PE0_in1 <= b_ext;		
			end
			PE0_in2	<= 0;		
			PE0_in3	<= 0;
			PE0_store_sum	<= 1;
			PE0_bypass		<= 0;
			PE0_round_value <= 16;
			PE0_shift_num	<= 5;
		end
   	    default: begin
		    PE0_in0 <= 0;
		    PE0_in1 <= 0;
		    PE0_in2 <= 0;
		    PE0_in3 <= 0;
		    PE0_store_sum <= 0;
		    PE0_bypass <= 0;
		    PE0_round_value <= 0;
		    PE0_shift_num <= 0;            
		end
	endcase	
else  begin
    PE0_in0 <= 0;
    PE0_in1 <= 0;
    PE0_in2 <= 0;
    PE0_in3 <= 0;
    PE0_store_sum <= 0;
    PE0_bypass <= 0;
    PE0_round_value <= 0;
    PE0_shift_num <= 0;            
end


always @(*)
if (mb_pred_mode == `mb_pred_mode_I16MB && blk4x4_counter < 16)
    case (I16_pred_mode)
        `Intra16x16_Vertical: begin
            case(calc_counter)
                3:PE1_in0 <= up_mb_muxout_0;
                2:PE1_in0 <= up_mb_muxout_1;
                1:PE1_in0 <= up_mb_muxout_2;
                0:PE1_in0 <= up_mb_muxout_3;
            endcase
            PE1_in1 <= 0; PE1_in2 <= 0; PE1_in3 <= 0;
            PE1_store_sum <= 0; 
            PE1_bypass <= 1;
            PE1_round_value <= 0;
            PE1_shift_num <= 0;
        end
        `Intra16x16_Horizontal:begin
            PE1_in0 <= left_mb_muxout_1;
            PE1_in1 <= 0; PE1_in2 <= 0; PE1_in3 <= 0;
            PE1_store_sum <= 0; 
            PE1_bypass <= 1;
            PE1_round_value <= 0;
            PE1_shift_num <= 0;
        end
        `Intra16x16_DC:begin
            case(calc_counter)
                3:begin
                    PE1_in0 <= up_avail ? up_mb_4:0;
                    PE1_in1 <= up_avail ? up_mb_5:0;
                    PE1_in2 <= up_avail ? up_mb_6:0;
                    PE1_in3 <= up_avail ? up_mb_7:0;
                    PE1_store_sum <= 1;
                    PE1_bypass <= 0;
                    PE1_round_value <= 0;
                    PE1_shift_num <= 0;
                end
                2:begin
                    PE1_in0 <= PE1_sum_reg;
                    PE1_in1 <= left_avail ? left_mb_5:0;
                    PE1_in2 <= left_avail ? left_mb_6:0;
                    PE1_in3 <= left_avail ? left_mb_7:0;
                    PE1_store_sum <= 1;
                    PE1_bypass <= 0;
                    PE1_round_value <= 0;
                    PE1_shift_num <= 0;
                end
                1:begin
                    PE1_in0 <=left_avail ? left_mb_0:0;
                    PE1_in1 <=left_avail ? left_mb_4:0;
                    PE1_in2 <=left_avail ? left_mb_8:0;
                    PE1_in3 <=left_avail ? left_mb_12:0;
                    PE1_store_sum <= 1;
                    PE1_bypass <= 0;
                    PE1_round_value <= 0;
                    PE1_shift_num <= 0;
                end
                default:begin
                    PE1_in0 <= 0;
                    PE1_in1 <= 0;
                    PE1_in2 <= 0;
                    PE1_in3 <= 0;
                    PE1_store_sum <= 0;
                    PE1_bypass <= 1;
                    PE1_round_value <= 0;
                    PE1_shift_num <= 0;
                end
            endcase
        end
        `Intra16x16_Plane:	begin
			PE1_in0 <= (calc_counter == 3 && blk4x4_counter[0] == 1'b0)? 
			seed:PE1_sum_reg;
			if(calc_counter == 3 && blk4x4_counter[0] == 0)begin 
				PE1_in1 <= c_ext;
			end
			else begin
				PE1_in1 <= b_ext;			
			end
			PE1_in2	<= 0;
			PE1_in3	<= 0;
			PE1_store_sum	<= 1;
			PE1_bypass		<= 0;
			PE1_round_value <= 16;
			PE1_shift_num	<= 5;
		end
        default:begin
            PE1_in0 <= 0;
            PE1_in1 <= 0;
            PE1_in2 <= 0;
            PE1_in3 <= 0;
            PE1_store_sum <= 0;
            PE1_bypass <= 1;
            PE1_round_value <= 0;
            PE1_shift_num <= 0;
        end
    endcase
else if (mb_pred_mode == `mb_pred_mode_I4MB && blk4x4_counter < 16)
    case (I4_pred_mode)
		`Intra4x4_Vertical : begin
			case(calc_counter)
                3:PE1_in0 <= up_mb_muxout_0;
                2:PE1_in0 <= up_mb_muxout_1;
                1:PE1_in0 <= up_mb_muxout_2;
                0:PE1_in0 <= up_mb_muxout_3;
            endcase
            PE1_in1 <= 0; PE1_in2 <= 0; PE1_in3 <= 0;
            PE1_store_sum <= 0; 
            PE1_bypass <= 1; 
            PE1_round_value <= 0;
            PE1_shift_num <= 0;
		end
		`Intra4x4_Horizontal:begin
            PE1_in0 <= left_mb_muxout_1;
            PE1_in1 <= 0; PE1_in2 <= 0; PE1_in3 <= 0;
            PE1_store_sum <= 0; 
            PE1_bypass <= 1;
            PE1_round_value <= 0;
            PE1_shift_num <= 0;
        end
        `Intra4x4_DC:begin
            case(calc_counter)
                3:begin
                    PE1_in0 <= left_avail?left_mb_muxout_0:0;
                    PE1_in1 <= left_avail?left_mb_muxout_1:0;
                    PE1_in2 <= left_avail?left_mb_muxout_2:0;
                    PE1_in3 <= left_avail?left_mb_muxout_3:0;
                    PE1_store_sum <= 1;
                    PE1_bypass <= 0;
                    PE1_round_value <= 0;
                    PE1_shift_num <= 0;
                end
                default:begin
                    PE1_in0 <= (up_avail || left_avail)?PE1_sum_reg:128;
                    PE1_in1 <= 0;
                    PE1_in2 <= 0;
                    PE1_in3 <= 0;
                    PE1_store_sum <= 0;
                    PE1_bypass <= (up_avail || left_avail)?0:1;
                    PE1_round_value <=(up_avail && left_avail)?4:2;
                    PE1_shift_num <= (up_avail && left_avail)?3:2;
                end
            endcase
        end
      	`Intra4x4_Diagonal_Down_Left:begin
			case (calc_counter)
				3:PE1_in0 <= up_mb_muxout_1;
				2:PE1_in0 <= intra_pred_8;
				1:PE1_in0 <= intra_pred_12;
				0:PE1_in0 <= intra_pred_13;
				default:PE1_in0 <= 0;
			endcase
			PE1_in1 <= (calc_counter == 3)? up_mb_muxout_2<<1:0;
			PE1_in2 <= (calc_counter == 3)? up_mb_muxout_3:0;
			PE1_in3 <= 0;
			PE1_store_sum 	<= 1'b0;
			PE1_bypass		<= (calc_counter == 3)? 0:1;
			PE1_round_value <= (calc_counter == 3)? 2:0;
			PE1_shift_num	<= (calc_counter == 3)? 2:0;
		end	
		`Intra4x4_Diagonal_Down_Right:begin
			case (calc_counter)
				3:PE1_in0 <= up_left_muxout;
				2:PE1_in0 <= intra_pred_0;
				1:PE1_in0 <= intra_pred_1;
				0:PE1_in0 <= intra_pred_2;
			endcase
			PE1_in1 <= (calc_counter == 3)? left_mb_muxout_0 << 1:0;
			PE1_in2 <= (calc_counter == 3)? left_mb_muxout_1:0;
			PE1_in3 <= 0;
			PE1_store_sum 	<= 0;
			PE1_bypass		<= (calc_counter == 3)? 0:1;
			PE1_round_value <= 2;
			PE1_shift_num	<= 2;
		end	
		`Intra4x4_Vertical_Right:begin
			case (calc_counter)
				3:begin	
					PE1_in0 <= up_mb_muxout_0;
					PE1_in1 <= up_left_muxout << 1;
					PE1_in2 <= left_mb_muxout_0;
				end
				2:begin
					PE1_in0 <= up_left_muxout;	 	
					PE1_in1 <= up_mb_muxout_0 << 1;
					PE1_in2 <= up_mb_muxout_1;			
				end
				1:begin	
					PE1_in0 <= up_mb_muxout_0;	
					PE1_in1 <= up_mb_muxout_1 << 1;
					PE1_in2 <= up_mb_muxout_2;				
				end
				0:begin	
					PE1_in0 <= up_mb_muxout_1;	
					PE1_in1 <= up_mb_muxout_2 << 1;
					PE1_in2 <= up_mb_muxout_3;				
				end		
			endcase
			PE1_in3 <= 0;
			PE1_store_sum <= 0;
			PE1_bypass <= 0;
			PE1_round_value <= 2;
			PE1_shift_num	<= 2;
		end
		`Intra4x4_Horizontal_Down:begin
			case (calc_counter)
				3:PE1_in0 <= left_mb_muxout_0;
				2:PE1_in0 <= up_left_muxout;
				1:PE1_in0 <= intra_pred_0;
				0:PE1_in0 <= intra_pred_1;
				default:PE1_in0 <= 0;
			endcase
			PE1_in1 <= (calc_counter == 3 || calc_counter == 2)?left_mb_muxout_1:0;
			PE1_in2 <= (calc_counter == 2)? left_mb_muxout_0 << 1:0;
			PE1_in3 <= 0;
			PE1_store_sum <= 1'b0;
			PE1_bypass <= (calc_counter == 1 || calc_counter == 0)? 1'b1:1'b0;
			PE1_round_value <= (calc_counter == 3)? 1:
							   (calc_counter == 2)? 2:0; 
		 	PE1_shift_num	<= (calc_counter == 3)? 1:
							   (calc_counter == 2)? 2:0; 
		end
		`Intra4x4_Vertical_Left:begin
			case (calc_counter)
				3:PE1_in0 <= up_mb_muxout_0;
				2:PE1_in0 <= intra_pred_12;
				1:PE1_in0 <= intra_pred_13;
				0:PE1_in0 <= intra_pred_14;
				default:PE1_in0 <= 0;
			endcase
			PE1_in1 <= (calc_counter == 3)? up_mb_muxout_2:0;
			PE1_in2 <= (calc_counter == 3)? up_mb_muxout_1<<1:0;
			PE1_in3 <= 0;
			PE1_store_sum   <= 0;
			PE1_bypass 		<= (calc_counter == 3)? 0:1;
			PE1_round_value <= (calc_counter == 3)? 2:0;
			PE1_shift_num	<= (calc_counter == 3)? 2:0;
		end
		`Intra4x4_Horizontal_Up:begin
			case (calc_counter)
				3:PE1_in0 <= left_mb_muxout_1;
				2:PE1_in0 <= left_mb_muxout_1;
				1:PE1_in0 <= intra_pred_8;
				0:PE1_in0 <= intra_pred_9;
				default:PE1_in0 <= 0;
			endcase
			PE1_in1 <= (calc_counter == 3)? left_mb_muxout_2:
					   (calc_counter == 2)? left_mb_muxout_3:0;
			PE1_in2 <= (calc_counter == 2)? left_mb_muxout_2<<1:0;
			PE1_in3 <= 0;
			PE1_store_sum <= 0; 
			PE1_bypass 		<= (calc_counter == 3 || 
								calc_counter == 2)? 0:1;
			PE1_round_value <= (calc_counter == 3)? 1:
							   (calc_counter == 2)? 2:0; 
		 	PE1_shift_num	<= (calc_counter == 3)? 1:
							   (calc_counter == 2)? 2:0; 
		end
		default:begin
            PE1_in0 <= 0;
            PE1_in1 <= 0;
            PE1_in2 <= 0;
            PE1_in3 <= 0;
            PE1_store_sum <= 0;
            PE1_bypass <= 0;
            PE1_round_value <= 0;
            PE1_shift_num <= 0;            
        end
	endcase
else if(blk4x4_counter > 15)
	case (intra_pred_mode_chroma)
		`Intra_chroma_DC:begin	
			case ({left_avail,up_avail})
				2'b00,2'b01: begin
					PE1_in0 <= 0;	PE1_in1 <= 0;	PE1_in2 <= 0;	PE1_in3 <= 0;
				end
				2'b10: begin
					PE1_in0 <= left_mb_muxout_0;	PE1_in1 <= left_mb_muxout_1;
					PE1_in2 <= left_mb_muxout_2;	PE1_in3 <= left_mb_muxout_3;
				end
				2'b11:
				begin
					PE1_in0 <= (blk4x4_counter == 17 || blk4x4_counter == 21)?
								0:left_mb_muxout_0;	
					PE1_in1 <= (blk4x4_counter == 17 || blk4x4_counter == 21)?
								0:left_mb_muxout_1;
					PE1_in2 <= (blk4x4_counter == 17 || blk4x4_counter == 21)?
								0:left_mb_muxout_2;	
					PE1_in3 <= (blk4x4_counter == 17 || blk4x4_counter == 21)?
								0:left_mb_muxout_3;
				end
			endcase
			PE1_store_sum <= (left_avail)? 1:0;
			PE1_bypass <= 0;
			PE1_round_value <= 0;	
			PE1_shift_num <= 0;
		end
		`Intra_chroma_Horizontal:begin
			PE1_in0 <= left_mb_muxout_1;
			PE1_in1 <= 0; 	
			PE1_in2 <= 0;	
			PE1_in3 <= 0; 		
			PE1_store_sum	<= 0;
			PE1_bypass <= 1;
			PE1_round_value <= 0;
			PE1_shift_num <= 0;
		end
		`Intra_chroma_Vertical:begin            
			case(calc_counter)          
			3:PE1_in0 <= up_mb_muxout_0;
			2:PE1_in0 <= up_mb_muxout_1;
			1:PE1_in0 <= up_mb_muxout_2;
			0:PE1_in0 <= up_mb_muxout_3;
			endcase                     
			PE1_in1 <= 0; 	            
			PE1_in2 <= 0;	            
			PE1_in3 <= 0; 		        
			PE1_store_sum	<= 0;       
			PE1_bypass <= 1;            
			PE1_round_value <= 0;       
			PE1_shift_num <= 0;         
		end
		`Intra_chroma_Plane:	begin
			PE1_in0 <= (calc_counter == 3 && blk4x4_counter[0] == 1'b0)? 
			seed:PE1_sum_reg;
			if(calc_counter == 3 && blk4x4_counter[0] == 0)begin 
				PE1_in1 <= c_ext;
			end
			else begin
				PE1_in1 <= b_ext;			
			end
			PE1_in2	<= 0;
			PE1_in3	<= 0;
			PE1_store_sum	<= 1;
			PE1_bypass		<= 0;
			PE1_round_value <= 16;
			PE1_shift_num	<= 5;
		end     
        default: begin
		    PE1_in0 <= 0;
		    PE1_in1 <= 0;
		    PE1_in2 <= 0;
		    PE1_in3 <= 0;
		    PE1_store_sum <= 0;
		    PE1_bypass <= 0;
		    PE1_round_value <= 0;
		    PE1_shift_num <= 0;            
		end                   
	endcase
else begin
    PE1_in0 <= 0;
    PE1_in1 <= 0;
    PE1_in2 <= 0;
    PE1_in3 <= 0;
    PE1_store_sum <= 0;
    PE1_bypass <= 0;
    PE1_round_value <= 0;
    PE1_shift_num <= 0;            
end     
        
always @(*)
if (mb_pred_mode == `mb_pred_mode_I16MB && blk4x4_counter < 16)
    case (I16_pred_mode)
        `Intra16x16_Vertical: begin
            case(calc_counter)
                3:PE2_in0 <= up_mb_muxout_0;
                2:PE2_in0 <= up_mb_muxout_1;
                1:PE2_in0 <= up_mb_muxout_2;
                0:PE2_in0 <= up_mb_muxout_3;
            endcase
            PE2_in1 <= 0; PE2_in2 <= 0; PE2_in3 <= 0;
            PE2_store_sum <= 0; 
            PE2_bypass <= 1;
            PE2_round_value <= 0;
            PE2_shift_num <= 0;
        end
        `Intra16x16_Horizontal:begin
            PE2_in0 <= left_mb_muxout_2;
            PE2_in1 <= 0; PE2_in2 <= 0; PE2_in3 <= 0;
            PE2_store_sum <= 0; 
            PE2_bypass <= 1;
            PE2_round_value <= 0;
            PE2_shift_num <= 0;
        end
        `Intra16x16_DC:begin
            case(calc_counter)
                3:begin
                    PE2_in0 <= up_avail ? up_mb_8:0;
                    PE2_in1 <= up_avail ? up_mb_9:0;
                    PE2_in2 <= up_avail ? up_mb_10:0;
                    PE2_in3 <= up_avail ? up_mb_11:0;
                    PE2_store_sum <= 1;
                    PE2_bypass <= 0;
                    PE2_round_value <= 0;
                    PE2_shift_num <= 0;
                end
                2:begin
                    PE2_in0 <= PE2_sum_reg;
                    PE2_in1 <=  left_avail ? left_mb_9:0;
                    PE2_in2 <=  left_avail ? left_mb_10:0;
                    PE2_in3 <=  left_avail ? left_mb_11:0;
                    PE2_store_sum <= 1;
                    PE2_bypass <= 0;
                    PE2_round_value <= 0;
                    PE2_shift_num <= 0;
                end
                default:begin
                    PE2_in0 <= 0;
                    PE2_in1 <= 0;
                    PE2_in2 <= 0;
                    PE2_in3 <= 0;
                    PE2_store_sum <= 0;
                    PE2_bypass <= 0;
                    PE2_round_value <= 0;
                    PE2_shift_num <= 0;
                end
            endcase
        end
        `Intra16x16_Plane:begin 	
			PE2_in0 <= (calc_counter == 3 && blk4x4_counter[0] == 1'b0)? 
			seed:PE2_sum_reg;
			if(calc_counter == 3 && blk4x4_counter[0] == 0)begin 
				PE2_in1 <= c_ext <<< 1;
			end
			else begin
				PE2_in1 <= b_ext;			
			end
			PE2_in2 <= 0;
			PE2_in3 <= 0;
			PE2_store_sum	<= 1;
			PE2_bypass		<= 0;
			PE2_round_value <= 16;
			PE2_shift_num	<= 5;
		end
        default:begin
            PE2_in0 <= 0;
            PE2_in1 <= 0;
            PE2_in2 <= 0;
            PE2_in3 <= 0;
            PE2_store_sum <= 0;
            PE2_bypass <= 0;
            PE2_round_value <= 0;
            PE2_shift_num <= 0;
        end
    endcase
else if (mb_pred_mode == `mb_pred_mode_I4MB && blk4x4_counter < 16)
    case (I4_pred_mode)
		`Intra4x4_Vertical : begin
			case(calc_counter)
                3:PE2_in0 <= up_mb_muxout_0;
                2:PE2_in0 <= up_mb_muxout_1;
                1:PE2_in0 <= up_mb_muxout_2;
                0:PE2_in0 <= up_mb_muxout_3;
            endcase
            PE2_in1 <= 0; PE2_in2 <= 0; PE2_in3 <= 0;
            PE2_store_sum <= 0; 
            PE2_bypass <= 1;
            PE2_round_value <= 0;
            PE2_shift_num <= 0; 
		end
		`Intra4x4_Horizontal:begin
            PE2_in0 <= left_mb_muxout_2;
            PE2_in1 <= 0; PE2_in2 <= 0; PE2_in3 <= 0;
            PE2_store_sum <= 0;
            PE2_bypass <= 1;
            PE2_round_value <= 0;
            PE2_shift_num <= 0;
        end
        `Intra4x4_DC:begin
            PE2_in0 <= 0;
            PE2_in1 <= 0;
            PE2_in2 <= 0;
            PE2_in3 <= 0;
            PE2_store_sum <= 0;
            PE2_bypass <= 1;
            PE2_round_value <=0;
            PE2_shift_num <= 0;
    	end
      	`Intra4x4_Diagonal_Down_Left:begin
			case (calc_counter)
				3:PE2_in0 <= up_mb_muxout_2;
				2:PE2_in0 <= intra_pred_12;
				1:PE2_in0 <= intra_pred_13;
				0:PE2_in0 <= intra_pred_14;
				default:PE2_in0 <= 0;
			endcase
			PE2_in1 <= (calc_counter == 3)? up_mb_muxout_3<<1:0;
			PE2_in2 <= (calc_counter == 3)? up_right_muxout_0:0;
			PE2_in3 <= 0;
			PE2_store_sum 	<= 0;
			PE2_bypass		<= (calc_counter == 3)? 0:1;
			PE2_round_value <= (calc_counter == 3)? 2:0;
			PE2_shift_num	<= (calc_counter == 3)? 2:0;
		end	
		`Intra4x4_Diagonal_Down_Right:begin
			case (calc_counter)
				3:PE2_in0 <= left_mb_muxout_0;
				2:PE2_in0 <= intra_pred_4;
				1:PE2_in0 <= intra_pred_0;
				0:PE2_in0 <= intra_pred_1;
			endcase
			PE2_in1 <= (calc_counter == 3)? left_mb_muxout_1 << 1:0;
			PE2_in2 <= (calc_counter == 3)? left_mb_muxout_2:0;
			PE2_in3 <= 0;
			PE2_store_sum 	<= 0;
			PE2_bypass		<= (calc_counter == 3)? 0:1;
			PE2_round_value <= 2;
			PE2_shift_num	<= 2;
		end	
		`Intra4x4_Vertical_Right:begin
			case (calc_counter)
				3:PE2_in0 <= up_left_muxout;
				2:PE2_in0 <= intra_pred_0;
				1:PE2_in0 <= intra_pred_1;
				0:PE2_in0 <= intra_pred_2;
				default:PE2_in0 <= 0;
			endcase
			PE2_in1 <= (calc_counter == 3)? left_mb_muxout_0<<1:0;
			PE2_in2 <= (calc_counter == 3)? left_mb_muxout_1:0;
			PE2_in3 <= 0;
			PE2_store_sum   <= 0;
			PE2_bypass <= (calc_counter == 3)? 0:1;
			PE2_round_value <= 2;
			PE2_shift_num	<= 2;
		end
		`Intra4x4_Horizontal_Down:begin
			case (calc_counter)
				3:PE2_in0 <= left_mb_muxout_1;
				2:PE2_in0 <= left_mb_muxout_0;
				1:PE2_in0 <= intra_pred_4;
				0:PE2_in0 <= intra_pred_5;
			endcase
			PE2_in1 <= (calc_counter == 3 || calc_counter == 2)?
						left_mb_muxout_2:0;
			PE2_in2 <= (calc_counter == 2)? left_mb_muxout_1<<1:0;
			PE2_in3 <= 0;
			PE2_store_sum <= 1'b0;
			PE2_bypass <= (calc_counter == 1 || 
								calc_counter == 0)? 1:0;
			PE2_round_value <= (calc_counter == 3)? 1:
							   (calc_counter == 2)? 2:0; 
		 	PE2_shift_num	<= (calc_counter == 3)? 1:
							   (calc_counter == 2)? 2:0; 
		end
		`Intra4x4_Vertical_Left:begin
			case (calc_counter)
				3:PE2_in0 <= up_mb_muxout_1;
				2:PE2_in0 <= up_mb_muxout_3;
				1:PE2_in0 <= up_mb_muxout_3;
				0:PE2_in0 <= up_right_muxout_1;
			endcase
			case (calc_counter)
				3,2:PE2_in1 <= up_mb_muxout_2;
				1,0:PE2_in1 <= up_right_muxout_0;
			endcase
			PE2_in2 <= 0;		
			PE2_in3 <= 0;
			PE2_store_sum 	<= 0;
			PE2_bypass 		<= 0;
			PE2_round_value <= 1;
			PE2_shift_num	<= 1;
		end
		`Intra4x4_Horizontal_Up:begin
			case (calc_counter)
				3,2:PE2_in0 <= left_mb_muxout_2;
				1,0:PE2_in0 <= intra_pred_12;
			endcase
			PE2_in1 <= (calc_counter == 3 || calc_counter == 2)?
						left_mb_muxout_3:0;
			PE2_in2 <= (calc_counter == 2)? left_mb_muxout_3<<1:0;
			PE2_in3 <= 0;
			PE2_store_sum	<= 1'b0;
			PE2_bypass <= (calc_counter == 1 || calc_counter == 0)? 1:0;
			PE2_round_value <= (calc_counter == 3)? 1:
							   (calc_counter == 2)? 2:0;
		 	PE2_shift_num	<= (calc_counter == 3)? 1:
							   (calc_counter == 2)? 2:0; 
		end
		default:begin
            PE2_in0 <= 0;
            PE2_in1 <= 0;
            PE2_in2 <= 0;
            PE2_in3 <= 0;
            PE2_store_sum <= 0;
            PE2_bypass <= 0;
            PE2_round_value <= 0;
            PE2_shift_num <= 0;            
        end
    endcase
else if(blk4x4_counter > 15)
	case (intra_pred_mode_chroma)
		`Intra_chroma_Horizontal:begin
			PE2_in0 <= left_mb_muxout_2;
			PE2_in1 <= 0; 	
			PE2_in2 <= 0;	
			PE2_in3 <= 0; 		
			PE2_store_sum	<= 0;
			PE2_bypass <= 1;
			PE2_round_value <= 0;
			PE2_shift_num <= 0;
		end
		`Intra_chroma_Vertical:begin
			case(calc_counter)
			3:PE2_in0 <= up_mb_muxout_0;
			2:PE2_in0 <= up_mb_muxout_1;
			1:PE2_in0 <= up_mb_muxout_2;
			0:PE2_in0 <= up_mb_muxout_3;
			endcase
			PE2_in1 <= 0; 	
			PE2_in2 <= 0;	
			PE2_in3 <= 0; 		
			PE2_store_sum	<= 0;
			PE2_bypass <= 1;
			PE2_round_value <= 0;
			PE2_shift_num <= 0;
		end
		`Intra_chroma_Plane:begin 	
			PE2_in0 <= (calc_counter == 3 && blk4x4_counter[0] == 1'b0)? 
			seed:PE2_sum_reg;
			if(calc_counter == 3 && blk4x4_counter[0] == 0)begin 
				PE2_in1 <= c_ext <<< 1;
			end
			else begin
				PE2_in1 <= b_ext;			
			end
			PE2_in2 <= 0;
			PE2_in3 <= 0;
			PE2_store_sum	<= 1;
			PE2_bypass		<= 0;
			PE2_round_value <= 16;
			PE2_shift_num	<= 5;
		end
		default: begin
		    PE2_in0 <= 0;
		    PE2_in1 <= 0;
		    PE2_in2 <= 0;
		    PE2_in3 <= 0;
		    PE2_store_sum <= 0;
		    PE2_bypass <= 0;
		    PE2_round_value <= 0;
		    PE2_shift_num <= 0;
		end
    endcase
else  begin
    PE2_in0 <= 0;
    PE2_in1 <= 0;
    PE2_in2 <= 0;
    PE2_in3 <= 0;
    PE2_store_sum <= 0;
    PE2_bypass <= 0;
    PE2_round_value <= 0;
    PE2_shift_num <= 0;
end

always @(*)
if (mb_pred_mode == `mb_pred_mode_I16MB && blk4x4_counter < 16)
    case (I16_pred_mode)
        `Intra16x16_Vertical: begin
            case(calc_counter)
                3:PE3_in0 <= up_mb_muxout_0;
                2:PE3_in0 <= up_mb_muxout_1;
                1:PE3_in0 <= up_mb_muxout_2;
                0:PE3_in0 <= up_mb_muxout_3;
            endcase
            PE3_in1 <= 0; PE3_in2 <= 0; PE3_in3 <= 0;
            PE3_store_sum <= 0; 
			PE3_bypass <= 1;
            PE3_round_value <= 0;
            PE3_shift_num <= 0;
        end
        `Intra16x16_Horizontal:begin
            PE3_in0 <= left_mb_muxout_3;
            PE3_in1 <= 0; PE3_in2 <= 0; PE3_in3 <= 0;
            PE3_store_sum <= 0; PE3_bypass <= 1;
			PE3_round_value <= 0;
            PE3_shift_num <= 0;
        end
        `Intra16x16_DC:begin
            case(calc_counter)
                3:begin
                    PE3_in0 <= up_avail ? up_mb_12:0;
                    PE3_in1 <= up_avail ? up_mb_13:0;
                    PE3_in2 <= up_avail ? up_mb_14:0;
                    PE3_in3 <= up_avail ? up_mb_15:0;
                    PE3_store_sum <= 1;
                    PE3_bypass <= 0;
                    PE3_round_value <= 0;
                    PE3_shift_num <= 0;
                end
                2:begin
                    PE3_in0 <= PE3_sum_reg;
                    PE3_in1 <= left_avail ?  left_mb_13:0;
                    PE3_in2 <= left_avail ?  left_mb_14:0;
                    PE3_in3 <= left_avail ?  left_mb_15:0;
                    PE3_store_sum <= 1;
                    PE3_bypass <= 0;
                    PE3_round_value <= 0;
                    PE3_shift_num <= 0;
                end
                default:begin
                    PE3_in0 <= 0;
                    PE3_in1 <= 0;
                    PE3_in2 <= 0;
                    PE3_in3 <= 0;
                    PE3_store_sum <= 0;
                    PE3_bypass <= 1;
                    PE3_round_value <= 0;
                    PE3_shift_num <= 0;
                end
            endcase
        end
        `Intra16x16_Plane:begin 
			PE3_in0 <= (calc_counter == 3 && blk4x4_counter[0] == 0)? seed:PE3_sum_reg;
			if(calc_counter == 3 && blk4x4_counter[0] == 0)begin 
				PE3_in1 <= c_ext <<< 1;
				PE3_in2 <= c_ext;
			end
			else begin
				PE3_in1 <= b_ext;
				PE3_in2 <= 0;			
			end
			PE3_in3 <=0;
			PE3_store_sum	<= 1;
			PE3_bypass		<= 0;
			PE3_round_value <= 16;
			PE3_shift_num	<= 5;
		end
		default:begin
            PE3_in0 <= 0;
            PE3_in1 <= 0;
            PE3_in2 <= 0;
            PE3_in3 <= 0;
            PE3_store_sum <= 0;
            PE3_bypass <= 0;
            PE3_round_value <= 0;
            PE3_shift_num <= 0;
	   	end
    endcase
else if (mb_pred_mode == `mb_pred_mode_I4MB && blk4x4_counter < 16)
    case (I4_pred_mode)
		`Intra4x4_Vertical : begin
			case(calc_counter)
                3:PE3_in0 <= up_mb_muxout_0;
                2:PE3_in0 <= up_mb_muxout_1;
                1:PE3_in0 <= up_mb_muxout_2;
                0:PE3_in0 <= up_mb_muxout_3;
            endcase
            PE3_in1 <= 0; PE3_in2 <= 0; PE3_in3 <= 0;
            PE3_store_sum <= 0; 
            PE3_bypass <= 1;
            PE3_round_value <= 0;
            PE3_shift_num <= 0; 
		end
		`Intra4x4_Horizontal:begin
            PE3_in0 <= left_mb_muxout_3;
            PE3_in1 <= 0; PE3_in2 <= 0; PE3_in3 <= 0;
            PE3_store_sum <= 0;
            PE3_bypass <= 1;
            PE3_round_value <= 0;
            PE3_shift_num <= 0;
        end
        `Intra4x4_DC:begin
            PE3_in0 <= 0;
            PE3_in1 <= 0;
            PE3_in2 <= 0;
            PE3_in3 <= 0;
            PE3_store_sum <= 0;
            PE3_bypass <= 1;
            PE3_round_value <=0;
            PE3_shift_num <= 0;
    	end
      	`Intra4x4_Diagonal_Down_Left:begin
			case (calc_counter)
				3:begin	
					PE3_in0 <= up_mb_muxout_3;	
					PE3_in1 <= up_right_muxout_0 << 1;
					PE3_in2 <= up_right_muxout_1;
				end
				2:begin	
					PE3_in0 <= up_right_muxout_0;	
					PE3_in1 <= up_right_muxout_1 << 1;
					PE3_in2 <= up_right_muxout_2;				
				end
				1:begin	
					PE3_in0 <= up_right_muxout_1;	
					PE3_in1 <= up_right_muxout_2 << 1;
					PE3_in2 <= up_right_muxout_3;				
				end
				0:begin	
					PE3_in0 <= up_right_muxout_2;	
					PE3_in1 <= up_right_muxout_3 << 1;
					PE3_in2 <= up_right_muxout_3;			
				end
			endcase
			PE3_in3 <= 0;
			PE3_store_sum 	<= 0;
			PE3_bypass		<= 0;
			PE3_round_value <= 2;
			PE3_shift_num	<= 2;
		end
		`Intra4x4_Diagonal_Down_Right:begin
			case (calc_counter)
				3:PE3_in0 <= left_mb_muxout_1;
				2:PE3_in0 <= intra_pred_8;
				1:PE3_in0 <= intra_pred_4;
				0:PE3_in0 <= intra_pred_0;
			endcase
			PE3_in1 <= (calc_counter == 3)? left_mb_muxout_2 << 1:0;
			PE3_in2 <= (calc_counter == 3)? left_mb_muxout_3:0;
			PE3_in3 <= 0;
			PE3_store_sum 	<= 0;
			PE3_bypass		<= (calc_counter == 3)? 0:1;
			PE3_round_value <= 2;
			PE3_shift_num	<= 2;
		end	
		`Intra4x4_Vertical_Right:begin
			case (calc_counter)
				3:PE3_in0 <= left_mb_muxout_0;
				2:PE3_in0 <= intra_pred_4;
				1:PE3_in0 <= intra_pred_5;
				0:PE3_in0 <= intra_pred_6;
				default:PE3_in0 <= 0;
			endcase
			PE3_in1 <= (calc_counter == 3)? left_mb_muxout_1<<1:0;
			PE3_in2 <= (calc_counter == 3)? left_mb_muxout_2:0;
			PE3_in3 <= 0;
			PE3_in3 <= 0;
			PE3_store_sum 	<= 0;
			PE3_bypass		<= (calc_counter == 3)? 0:1;
			PE3_round_value <= 2;
			PE3_shift_num	<= 2;
		end
		`Intra4x4_Horizontal_Down:begin
			case (calc_counter)
				3:PE3_in0 <= left_mb_muxout_2;
				2:PE3_in0 <= left_mb_muxout_1;
				1:PE3_in0 <= intra_pred_8;
				0:PE3_in0 <= intra_pred_9;
			endcase
			PE3_in1 <= (calc_counter == 3 || calc_counter == 2)?
						left_mb_muxout_3:0;
			PE3_in2 <= (calc_counter == 2)? left_mb_muxout_2<<1:0;
			PE3_in3 <= 0;
			PE3_store_sum <= 0;
			PE3_bypass <= (calc_counter == 1 || 
								calc_counter == 0)? 1:0;
			PE3_round_value <= (calc_counter == 3)? 1:
							   (calc_counter == 2)? 2:0; 
		 	PE3_shift_num	<= (calc_counter == 3)? 1:
							   (calc_counter == 2)? 2:0; 
		end
		`Intra4x4_Vertical_Left:begin
			case (calc_counter)
				3:begin	
					PE3_in0 <= up_mb_muxout_1;
					PE3_in1 <= up_mb_muxout_2 << 1;
					PE3_in2 <= up_mb_muxout_3;				
				end
				2:begin	
					PE3_in0 <= up_mb_muxout_2;	
					PE3_in1 <= up_mb_muxout_3 << 1;
					PE3_in2 <= up_right_muxout_0;				
				end
				1:begin	
					PE3_in0 <= up_mb_muxout_3;	
					PE3_in1 <= up_right_muxout_0 << 1;
					PE3_in2 <= up_right_muxout_1;
				end
				0:begin	
					PE3_in0 <= up_right_muxout_0;
					PE3_in1 <= up_right_muxout_1 << 1;
					PE3_in2 <= up_right_muxout_2;				
				end		
			endcase
			PE3_in3 <= 0;
			PE3_store_sum 	<= 0; 
			PE3_bypass 		<= 0;
			PE3_round_value <= 2;
			PE3_shift_num	<= 2;
		end
		`Intra4x4_Horizontal_Up:begin
			PE3_in0 <= left_mb_muxout_3;
			PE3_in1 <= 0;
			PE3_in2 <= 0;
			PE3_in3 <= 0;
			PE3_store_sum 	<= 0;
			PE3_bypass <= 1;
			PE3_round_value <= 0;
			PE3_shift_num <= 0; 
		end
		default:begin
            PE3_in0 <= 0;
            PE3_in1 <= 0;
            PE3_in2 <= 0;
            PE3_in3 <= 0;
            PE3_store_sum <= 0;
            PE3_bypass <= 1;
            PE3_round_value <= 0;
            PE3_shift_num <= 0;            
        end
    endcase
else if(blk4x4_counter > 15)
	case (intra_pred_mode_chroma)
		`Intra_chroma_Horizontal:begin
			PE3_in0 <= left_mb_muxout_3;
			PE3_in1 <= 0; 	
			PE3_in2 <= 0;	
			PE3_in3 <= 0; 		
			PE3_store_sum	<= 0;
			PE3_bypass <= 1;
			PE3_round_value <= 0;
			PE3_shift_num <= 0;
		end
		`Intra_chroma_Vertical:begin
			case(calc_counter)
			3:PE3_in0 <= up_mb_muxout_0;
			2:PE3_in0 <= up_mb_muxout_1;
			1:PE3_in0 <= up_mb_muxout_2;
			0:PE3_in0 <= up_mb_muxout_3;
			endcase
			PE3_in1 <= 0; 	
			PE3_in2 <= 0;	
			PE3_in3 <= 0; 		
			PE3_store_sum	<= 0;
			PE3_bypass <= 1;
			PE3_round_value <= 0;
			PE3_shift_num <= 0;
		end
		`Intra_chroma_Plane:begin 	
			PE3_in0 <= (calc_counter == 3 && blk4x4_counter[0] == 1'b0)? seed:PE3_sum_reg;
			if(calc_counter == 3 && blk4x4_counter[0] == 0)begin 
				PE3_in1 <= c_ext <<< 1;
				PE3_in2 <= c_ext;
			end
			else begin
				PE3_in1 <= b_ext;
				PE3_in2 <= 0;			
			end
			PE3_in3 <= 0;
			PE3_store_sum	<= 1;
			PE3_bypass		<= 0;
			PE3_round_value <= 16;
			PE3_shift_num	<= 5;
		end
		default: begin
		    PE3_in0 <= 0;
		    PE3_in1 <= 0;
		    PE3_in2 <= 0;
		    PE3_in3 <= 0;
		    PE3_store_sum <= 0;
		    PE3_bypass <= 0;
		    PE3_round_value <= 0;
		    PE3_shift_num <= 0;
		end
	endcase
else begin
    PE3_in0 <= 0;
    PE3_in1 <= 0;
    PE3_in2 <= 0;
    PE3_in3 <= 0;
    PE3_store_sum <= 0;
    PE3_bypass <= 0;
    PE3_round_value <= 0;
    PE3_shift_num <= 0;
end

endmodule

module PE
(
    clk,
    rst_n,
    ena,
    in0,
    in1,
    in2,
    in3,
    store_sum,
    round_value,
    shift_num,
    bypass,
    sum_reg,
    out
);
input clk;
input rst_n;
input ena;
input [14:0] in0;
input [14:0] in1;
input [14:0] in2;
input [14:0] in3;
input store_sum;
input [4:0] round_value;
input [2:0] shift_num;
input bypass;
output [14:0] sum_reg;
output [7:0] out;

reg [14:0] sum1;
reg [14:0] sum2;
reg signed [14:0] sum;
reg signed [14:0] rounding_out;
reg [7:0]  out;

//FFs
reg [14:0] sum_reg;
always @(*)
    sum1 <= in0 + in1;

always @(*)
    sum2 <= in2 + in3;

always @(*)
    sum <= sum1 + sum2;

always @(posedge clk or negedge rst_n)
if(!rst_n)
    sum_reg <= 0;
else if (ena && store_sum)
    sum_reg <= sum;

wire signed [5:0] round_value_signed;
assign round_value_signed = {1'b0,round_value};
always @(*)
if (shift_num == 5)
   	rounding_out <= (sum + round_value_signed) >>> 5;
else if(shift_num == 4)
   	rounding_out <= (sum + round_value_signed) >>> 4;
else if (shift_num == 3)
   	rounding_out <= (sum + round_value_signed) >>> 3;
else if (shift_num == 2)
   	rounding_out <= (sum + round_value_signed) >>> 2;
else if (shift_num == 1)
   	rounding_out <= (sum + round_value_signed) >>> 1;
else
   	rounding_out <= (sum + round_value_signed);


always @(*)
    out = bypass ? in0 :
          ( rounding_out > 255 ? 255 :
          ( rounding_out < 0 ? 0 : 
          ( rounding_out[7:0])));

endmodule
