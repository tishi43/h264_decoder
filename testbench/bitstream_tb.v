//--------------------------------------------------------------------------------------------------
// Design    : bitstream_p
// Author(s) :qiu bin, shi tian qi
// Email	   : chat1@126.com, tishi1@126.com
// Copyright (C) 2013 qiu bin                
//-------------------------------------------------------------------------------------------------
`include "defines.v"
`timescale 1ns / 1ps
//-cond "/u_decode_stream/slice_data_dut/mb_index_out==4 && "
//-cond "/u_decode_stream/bc_dut/pic_num==1"
module bitstream_tb;
reg rst_n;
reg clk;

reg		[7:0] stream_mem [0:800*1024];

wire [7:0]  stream_data;
wire [31:0]	stream_mem_addr;
wire 		stream_mem_rd;

wire  [`ext_buf_mem_addr_width-1:0] 	ext_mem_addr;
wire    								ext_mem_rd;
wire    								ext_mem_wr;
wire  [`ext_buf_mem_data_width-1:0]		ext_mem_d;
wire  [`ext_buf_mem_data_width-1:0]		ext_mem_q;
reg 									ext_mem_valid;

wire    [9:0] pic_num;

always @(posedge clk)
	ext_mem_valid <= ext_mem_rd;


decode_stream u_decode_stream
(
 .clk(clk),
 .rst_n(rst_n),
 .ena(1'b1),
 
 .num_cycles_1_frame(24'd1),
  
 //interface to stream memory or fifo
 .stream_mem_valid(1'b1),
 .stream_mem_data_in(stream_data),
 .stream_mem_addr_out(stream_mem_addr),
 .stream_mem_rd(stream_mem_rd),
 .stream_mem_end(1'b0),
 
 //interface to external buffer memory
 .ext_mem_init_done(1'b1),
 .ext_mem_burst(ext_mem_burst),
 .ext_mem_burst_len_minus1(),
 .ext_mem_addr(ext_mem_addr),
 .ext_mem_rd(ext_mem_rd),
 .ext_mem_wr(ext_mem_wr),
 .ext_mem_d(ext_mem_d),
 .ext_mem_q(ext_mem_q),
 .ext_mem_full(1'b0),
 .ext_mem_valid(ext_mem_valid),
 .ext_display_buf_mem_burst(),
 .ext_display_buf_addr(),
 
 //video information
 .pic_width_in_mbs(),
 .pic_height_in_map_units(),
 .start_of_frame(),
 .end_of_frame(end_of_frame),
 .pic_num(pic_num)
);

// clock and reset
always
begin
   #20 clk = 0;
   #20 clk = 1;
end

initial
begin
   clk = 1'b1;
   rst_n = 1'b0;
   repeat (5) @(posedge clk);
   rst_n = 1'b1;
end

assign stream_data = stream_mem[stream_mem_addr];	//async read

// read stream file
initial
begin
	$readmemh( "out.mem", stream_mem );
end

ext_ram_32 ext_ram_32
(
	.clk(clk),
	.wr(ext_mem_wr),
	.addr(ext_mem_addr), 
	.data_in(ext_mem_d), 
	.data_out(ext_mem_q),
	.end_of_frame(end_of_frame),
	.pic_num_2to0(pic_num[2:0])
);

integer blk_num, residual_blk_num, fp_w, fp_w_cavlc,fp_w_residual;

initial
begin
	fp_w_cavlc = $fopen("trace_cavlc.log", "w");
	blk_num = 0;
	while(1)
	begin
		@(posedge u_decode_stream.residual_dut.cavlc_valid);
		@(posedge clk);
		blk_num = blk_num + 1;
		
	    $fdisplay( fp_w_cavlc, "mb_index_out:%-d luma4x4BlkIdx: %-d  chroma4x4BlkIdx :%-d", u_decode_stream.slice_data_dut.mb_index_out,  u_decode_stream.slice_data_dut.luma4x4BlkIdx_out, u_decode_stream.slice_data_dut.chroma4x4BlkIdx_out);		
		$fdisplay( fp_w_cavlc,"mb_index:%-5dnC:%-5dTotalCoeff:%-5d", u_decode_stream.slice_data_dut.mb_index_out, u_decode_stream.residual_dut.nC, u_decode_stream.residual_dut.TotalCoeff);
		$fdisplay( fp_w_cavlc,"%5d%5d%5d%5d", u_decode_stream.residual_dut.coeff_0, u_decode_stream.residual_dut.coeff_1, u_decode_stream.residual_dut.coeff_2, u_decode_stream.residual_dut.coeff_3);
		$fdisplay( fp_w_cavlc,"%5d%5d%5d%5d", u_decode_stream.residual_dut.coeff_4, u_decode_stream.residual_dut.coeff_5, u_decode_stream.residual_dut.coeff_6, u_decode_stream.residual_dut.coeff_7);
		$fdisplay( fp_w_cavlc,"%5d%5d%5d%5d", u_decode_stream.residual_dut.coeff_8, u_decode_stream.residual_dut.coeff_9, u_decode_stream.residual_dut.coeff_10, u_decode_stream.residual_dut.coeff_11);
		$fdisplay( fp_w_cavlc,"%5d%5d%5d%5d\n",u_decode_stream.residual_dut.coeff_12, u_decode_stream.residual_dut.coeff_13, u_decode_stream.residual_dut.coeff_14, u_decode_stream.residual_dut.coeff_15);
	end
end


initial
begin
	residual_blk_num = 0;
	fp_w_residual = $fopen("trace_residual.log", "w");
	while(1)
	begin
		@(posedge u_decode_stream.residual_dut.transform_valid);
		if (u_decode_stream.residual_dut.transform_dut.block_type == 0
			||u_decode_stream.residual_dut.transform_dut.block_type == 2
			||u_decode_stream.residual_dut.transform_dut.block_type == 3
			||u_decode_stream.residual_dut.transform_dut.block_type == 6)begin
			@(posedge clk);
			residual_blk_num = residual_blk_num + 1;
		    $fdisplay( fp_w_residual, "pic_num:%5d mb_index_out:%5d blk:%5d", u_decode_stream.pic_num, u_decode_stream.slice_data_dut.mb_index_out,  u_decode_stream.blk4x4_counter);		
			$fdisplay( fp_w_residual,"%5d%5d%5d%5d", u_decode_stream.residual_dut.residual_0, u_decode_stream.residual_dut.residual_1, u_decode_stream.residual_dut.residual_2, u_decode_stream.residual_dut.residual_3);
			$fdisplay( fp_w_residual,"%5d%5d%5d%5d", u_decode_stream.residual_dut.residual_4, u_decode_stream.residual_dut.residual_5, u_decode_stream.residual_dut.residual_6, u_decode_stream.residual_dut.residual_7);
			$fdisplay( fp_w_residual,"%5d%5d%5d%5d", u_decode_stream.residual_dut.residual_8, u_decode_stream.residual_dut.residual_9, u_decode_stream.residual_dut.residual_10, u_decode_stream.residual_dut.residual_11);
			$fdisplay( fp_w_residual,"%5d%5d%5d%5d\n",u_decode_stream.residual_dut.residual_12, u_decode_stream.residual_dut.residual_13, u_decode_stream.residual_dut.residual_14, u_decode_stream.residual_dut.residual_15);
		end
	end
end

integer fp_w_intra4x4;
initial
begin
	fp_w_intra4x4 = $fopen("trace_intra4x4.log", "w");
	while(1)
	begin
		@(posedge (u_decode_stream.intra_pred_top.intra_pred_fsm.state == `intra_pred_calc_s && u_decode_stream.intra_pred_top.intra_pred_fsm.calc_counter == 0));
		begin
			$fdisplay( fp_w_intra4x4,"mb_index:%5d blk:%5d", u_decode_stream.slice_data_dut.mb_index_out, u_decode_stream.blk4x4_counter);
			$fdisplay( fp_w_intra4x4,"%02x   %02x   %02x   %02x   ", u_decode_stream.intra_pred_top.intra_pred_0, u_decode_stream.intra_pred_top.intra_pred_1,  u_decode_stream.intra_pred_top.intra_pred_2, u_decode_stream.intra_pred_top.intra_pred_3);
			$fdisplay( fp_w_intra4x4,"%02x   %02x   %02x   %02x   ", u_decode_stream.intra_pred_top.intra_pred_4, u_decode_stream.intra_pred_top.intra_pred_5,  u_decode_stream.intra_pred_top.intra_pred_6, u_decode_stream.intra_pred_top.intra_pred_7);
			$fdisplay( fp_w_intra4x4,"%02x   %02x   %02x   %02x   ", u_decode_stream.intra_pred_top.intra_pred_8, u_decode_stream.intra_pred_top.intra_pred_9,  u_decode_stream.intra_pred_top.intra_pred_10, u_decode_stream.intra_pred_top.intra_pred_11);
			$fdisplay( fp_w_intra4x4,"%02x   %02x   %02x   %02x   \n",u_decode_stream.intra_pred_top.intra_pred_12, u_decode_stream.intra_pred_top.intra_pred_13,  u_decode_stream.intra_pred_top.intra_pred_14, u_decode_stream.intra_pred_top.intra_pred_15);
		end
	end
end

integer fp_w_sum_hex;
initial
begin
	fp_w_sum_hex = $fopen("trace_sum_hex.log", "w");
	while(1)
	begin
		@(posedge u_decode_stream.sum.valid);
		begin
			$fdisplay( fp_w_sum_hex,"pic_num:%5d mb_index:%5d blk:%5d", u_decode_stream.pic_num, u_decode_stream.slice_data_dut.mb_index_out, u_decode_stream.blk4x4_counter);
			$fdisplay( fp_w_sum_hex,"%02x   %02x   %02x   %02x   ", u_decode_stream.sum.sum_0,  u_decode_stream.sum.sum_1,  u_decode_stream.sum.sum_2, u_decode_stream.sum.sum_3);
			$fdisplay( fp_w_sum_hex,"%02x   %02x   %02x   %02x   ", u_decode_stream.sum.sum_4,  u_decode_stream.sum.sum_5,  u_decode_stream.sum.sum_6, u_decode_stream.sum.sum_7);
			$fdisplay( fp_w_sum_hex,"%02x   %02x   %02x   %02x   ", u_decode_stream.sum.sum_8,  u_decode_stream.sum.sum_9,  u_decode_stream.sum.sum_10, u_decode_stream.sum.sum_11);
			$fdisplay( fp_w_sum_hex,"%02x   %02x   %02x   %02x   \n",u_decode_stream.sum.sum_12,  u_decode_stream.sum.sum_13,  u_decode_stream.sum.sum_14, u_decode_stream.sum.sum_15);
		end
	end
end

integer fp_w_sum;
initial
begin
	fp_w_sum = $fopen("trace_sum.log", "w");
	while(1)
	begin
		@(posedge u_decode_stream.sum.valid);
		begin
			$fdisplay( fp_w_sum,"pic_num:%5d mb_index:%5d blk:%5d", u_decode_stream.pic_num, u_decode_stream.slice_data_dut.mb_index_out, u_decode_stream.blk4x4_counter);
			$fdisplay( fp_w_sum,"%5d%5d%5d%5d", u_decode_stream.sum.sum_0,  u_decode_stream.sum.sum_1,  u_decode_stream.sum.sum_2, u_decode_stream.sum.sum_3);
			$fdisplay( fp_w_sum,"%5d%5d%5d%5d", u_decode_stream.sum.sum_4,  u_decode_stream.sum.sum_5,  u_decode_stream.sum.sum_6, u_decode_stream.sum.sum_7);
			$fdisplay( fp_w_sum,"%5d%5d%5d%5d", u_decode_stream.sum.sum_8,  u_decode_stream.sum.sum_9,  u_decode_stream.sum.sum_10, u_decode_stream.sum.sum_11);
			$fdisplay( fp_w_sum,"%5d%5d%5d%5d\n",u_decode_stream.sum.sum_12,  u_decode_stream.sum.sum_13,  u_decode_stream.sum.sum_14, u_decode_stream.sum.sum_15);
		end
	end
end

integer fp_w_mv;
initial
begin
	fp_w_mv = $fopen("trace_mv.log", "w");
    while(1)
	begin	    
		@(u_decode_stream.slice_data_dut.slice_data_state);
		if ( u_decode_stream.slice_data_dut.slice_type_mod5_in != `slice_type_I &&
             u_decode_stream.slice_data_dut.slice_type_mod5_in != `slice_type_SI && 
				u_decode_stream.slice_data_dut.slice_data_state == `mb_num_update)
        begin
            $fdisplay( fp_w_mv, "pic_num:%d mb_index_out:%d", u_decode_stream.bc_dut.pic_num, u_decode_stream.slice_data_dut.mb_index_out);	    	    		
    		$fdisplay( fp_w_mv, "mvx_l0_curr_mb_out:%5d%5d%5d%5d", u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[15:0],
    		                                                    u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[31:16],
    		                                                    u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[79:64],
    		                                                    u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[95:80]
    		                                                    );
    		                                                    
    		$fdisplay( fp_w_mv, "mvx_l0_curr_mb_out:%5d%5d%5d%5d", u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[47:32],
    		                                                    u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[63:48],
    		                                                    u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[111:96],
    		                                                    u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[127:112]
    		                                                    );
    		$fdisplay( fp_w_mv, "mvx_l0_curr_mb_out:%5d%5d%5d%5d", u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[143:128],
    		                                                    u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[159:144],
    		                                                    u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[207:192],
    		                                                    u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[223:208]
    		                                                    );
    		$fdisplay( fp_w_mv, "mvx_l0_curr_mb_out:%5d%5d%5d%5d", u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[175:160],
    		                                                    u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[191:176],
    		                                                    u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[239:224],
    		                                                    u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[255:240]
    		                                                    );
    		$fdisplay( fp_w_mv, "mvy_l0_curr_mb_out:%5d%5d%5d%5d", u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[15:0],
    		                                                    u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[31:16],
    		                                                    u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[79:64],
    		                                                    u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[95:80]
    		                                                    
    		                                                    );
    		$fdisplay( fp_w_mv, "mvy_l0_curr_mb_out:%5d%5d%5d%5d", u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[47:32],
    		                                                    u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[63:48]
    		                                                    ,
    		                                                    u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[111:96],
    		                                                    u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[127:112]
    		                                                    );
    		$fdisplay( fp_w_mv, "mvy_l0_curr_mb_out:%5d%5d%5d%5d", u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[143:128],
    		                                                    u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[159:144],
    		                                                    u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[207:192],
    		                                                    u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[223:208]
    		                                                    );
    		$fdisplay( fp_w_mv, "mvy_l0_curr_mb_out:%5d%5d%5d%5d", u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[175:160],
    		                                                    u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[191:176]
    		                                                    ,
    		                                                    u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[239:224],
    		                                                    u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[255:240]); 
    		$fdisplay( fp_w_mv,"");  
		end
	end
end

initial
begin
	fp_w = $fopen("trace.log", "w");
    while(1)
	begin	    
		@(u_decode_stream.slice_data_dut.slice_data_state);
		if (u_decode_stream.slice_data_dut.slice_data_state == `mb_num_update)
        begin
            $display( "pic_num:%d mb_index_out:%d", u_decode_stream.bc_dut.pic_num, u_decode_stream.slice_data_dut.mb_index_out);	    	
		    $fdisplay( fp_w, "pic_num:%d mb_index_out:%d", u_decode_stream.bc_dut.pic_num, u_decode_stream.slice_data_dut.mb_index_out);	    	
    		
    		$fdisplay( fp_w, "mb_type:%-50d", u_decode_stream.slice_data_dut.mb_type);
    		$fdisplay( fp_w, "ref_idx_l0_curr_mb_out:%5d%5d%5d%5d", 
    		           u_decode_stream.slice_data_dut.ref_idx_l0_curr_mb_out[2:0],
    		           u_decode_stream.slice_data_dut.ref_idx_l0_curr_mb_out[5:3],
    		           u_decode_stream.slice_data_dut.ref_idx_l0_curr_mb_out[8:6],
    		           u_decode_stream.slice_data_dut.ref_idx_l0_curr_mb_out[11:9]);
    		$fdisplay( fp_w, "intra4x4_pred_mode_curr_mb_out:%-50x", u_decode_stream.slice_data_dut.intra4x4_pred_mode_curr_mb_out);
    		$fdisplay( fp_w, "nC_curr_mb_out:%-50x", u_decode_stream.slice_data_dut.nC_curr_mb_out);
    		$fdisplay( fp_w, "nC_cb_curr_mb_out:%-032x", u_decode_stream.slice_data_dut.nC_cb_curr_mb_out);
    		$fdisplay( fp_w, "nC_cr_curr_mb_out:%-032x", u_decode_stream.slice_data_dut.nC_cr_curr_mb_out);
    		$fdisplay( fp_w, "qp:%-50d", u_decode_stream.slice_data_dut.qp);
    		$fdisplay( fp_w, "qp_c:%-50d", u_decode_stream.slice_data_dut.qp_c);
/*
    		$fdisplay( fp_w, "mvx_l0_curr_mb_out:%5d%5d%5d%5d", u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[15:0],
    		                                                    u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[31:16],
    		                                                    u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[79:64],
    		                                                    u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[95:80]
    		                                                    );
    		$fdisplay( fp_w, "mvx_l0_curr_mb_out:%5d%5d%5d%5d", u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[47:32],
    		                                                    u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[63:48]
    		                                                    ,
    		                                                    u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[111:96],
    		                                                    u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[127:112]);
    		$fdisplay( fp_w, "mvx_l0_curr_mb_out:%5d%5d%5d%5d", u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[143:128],
    		                                                    u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[159:144],
    		                                                    u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[207:192],
    		                                                    u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[223:208]
    		                                                    
    		                                                    );
    		$fdisplay( fp_w, "mvx_l0_curr_mb_out:%5d%5d%5d%5d", u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[175:160],
    		                                                    u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[191:176],
    		                                                    u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[239:224],
    		                                                    u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[255:240]
    		                                                    );
    		$fdisplay( fp_w, "mvy_l0_curr_mb_out:%5d%5d%5d%5d", u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[15:0],
    		                                                    u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[31:16],
    		                                                    u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[79:64],
    		                                                    u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[95:80]
    		                                                    
    		                                                    );
    		$fdisplay( fp_w, "mvy_l0_curr_mb_out:%5d%5d%5d%5d", u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[47:32],
    		                                                    u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[63:48]
    		                                                    ,
    		                                                    u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[111:96],
    		                                                    u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[127:112]
    		                                                    );
    		$fdisplay( fp_w, "mvy_l0_curr_mb_out:%5d%5d%5d%5d", u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[143:128],
    		                                                    u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[159:144],
    		                                                    u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[207:192],
    		                                                    u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[223:208]
    		                                                    );
    		$fdisplay( fp_w, "mvy_l0_curr_mb_out:%5d%5d%5d%5d", u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[175:160],
    		                                                    u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[191:176]
    		                                                    ,
    		                                                    u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[239:224],
    		                                                    u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[255:240]);
*/
/*     		$fdisplay( fp_w, "ref_idx_l0_curr_mb_out:%3d%3d%3d%3d", u_decode_stream.slice_data_dut.ref_idx_l0_curr_mb_out[2:0],
    		                                                    u_decode_stream.slice_data_dut.ref_idx_l0_curr_mb_out[5:3]
    		                                                    ,
    		                                                    u_decode_stream.slice_data_dut.ref_idx_l0_curr_mb_out[8:6],
    		                                                    u_decode_stream.slice_data_dut.ref_idx_l0_curr_mb_out[11:9]);    		                                                    
    		
   	    	$fdisplay( fp_w, "CBP_luma_reg:%-50d", u_decode_stream.slice_data_dut.CBP_luma_reg);
    		$fdisplay( fp_w, "CBP_chroma_reg:%-50d", u_decode_stream.slice_data_dut.CBP_chroma_reg);
    		$fdisplay( fp_w, "mb_qp_delta:%-50d", u_decode_stream.slice_data_dut.mb_qp_delta);
    		$fdisplay( fp_w, "mb_pred_mode_out:%-50d", u_decode_stream.slice_data_dut.mb_pred_mode_out);
    		$fdisplay( fp_w, "I16_pred_mode:%-50d", u_decode_stream.slice_data_dut.I16_pred_mode);
    		$fdisplay( fp_w, "intra_pred_mode_chroma:%-50d", u_decode_stream.slice_data_dut.intra_pred_mode_chroma);
    		$fdisplay( fp_w, "intra_mode:%-50d\n\n", u_decode_stream.slice_data_dut.intra_mode);
    
    		$fdisplay( fp_w,"------------------------------------------------------------");*/	 
    		$fdisplay( fp_w,"");  
    		$fflush(fp_w);
		end
	end
end

/*
always @(u_decode_stream.slice_data_dut.mb_pred_state or u_decode_stream.slice_data_dut.rbsp_buffer_valid_in) 
if(u_decode_stream.slice_data_dut.rbsp_buffer_valid_in)
begin
    if (u_decode_stream.slice_data_dut.mb_pred_state == `prev_intra4x4_pred_mode_flag_s && u_decode_stream.slice_data_dut.rbsp_in[23] == 1)
        $fdisplay(fp_w, "luma4x4BlkIdx_out:%d  prev_intra4x4_pred_mode_flag_out:1", u_decode_stream.slice_data_dut.luma4x4BlkIdx_out);
    else if (u_decode_stream.slice_data_dut.mb_pred_state == `rem_intra4x4_pred_mode_s)
        begin
            #1;
            $fdisplay(fp_w, "luma4x4BlkIdx_out:%d  prev_intra4x4_pred_mode_flag_out:0  rem_intra4x4_pred_mode_out:%b",
            u_decode_stream.slice_data_dut.luma4x4BlkIdx_out, u_decode_stream.slice_data_dut.rbsp_in[23:21]);
        end
    else if (u_decode_stream.slice_data_dut.mb_pred_state == `mvdx_l0_s)
        begin
            #1;
            $fdisplay(fp_w, "mvdx_l0:%d mvpx_l0_in:%d mbPartIdx:%d",
            u_decode_stream.slice_data_dut.exp_golomb_decoding_output_se_in, u_decode_stream.slice_data_dut.mvpx_l0_in,
            u_decode_stream.slice_data_dut.mbPartIdx);        
        end
    else if (u_decode_stream.slice_data_dut.mb_pred_state == `mvdy_l0_s)
        begin
            #1;
            $fdisplay(fp_w, "mvdy_l0:%d mvpx_l0_in:%d mbPartIdx:%d",
            u_decode_stream.slice_data_dut.exp_golomb_decoding_output_se_in, u_decode_stream.slice_data_dut.mvpy_l0_in,
            u_decode_stream.slice_data_dut.mbPartIdx);        
        end
end

always @(u_decode_stream.slice_data_dut.sub_mb_pred_state or u_decode_stream.slice_data_dut.rbsp_buffer_valid_in)
if(u_decode_stream.slice_data_dut.rbsp_buffer_valid_in)
    if (u_decode_stream.slice_data_dut.sub_mb_pred_state == `sub_mb_type_s)
        begin
            #1;
            $fdisplay(fp_w, "sub_mb_type:%d mbPartIdx:%d ", u_decode_stream.slice_data_dut.exp_golomb_decoding_output_in,
            u_decode_stream.slice_data_dut.mbPartIdx);        
        end
    else if (u_decode_stream.slice_data_dut.sub_mb_pred_state == `sub_mvdx_l0_s)
        begin
            #1;
            $fdisplay(fp_w, "mvdx_l0:%d mvpx_l0_in:%d mbPartIdx:%d subMbPartIdx:%d",
            u_decode_stream.slice_data_dut.exp_golomb_decoding_output_se_in, u_decode_stream.slice_data_dut.mvpx_l0_in,
            u_decode_stream.slice_data_dut.mbPartIdx,
            u_decode_stream.slice_data_dut.subMbPartIdx);        
        end
    else if (u_decode_stream.slice_data_dut.sub_mb_pred_state == `sub_mvdy_l0_s)
        begin
            #1;
            $fdisplay(fp_w, "mvdy_l0:%d mvpx_l0_in:%d mbPartIdx:%d subMbPartIdx:%d",
            u_decode_stream.slice_data_dut.exp_golomb_decoding_output_se_in, u_decode_stream.slice_data_dut.mvpy_l0_in,
            u_decode_stream.slice_data_dut.mbPartIdx,
            u_decode_stream.slice_data_dut.subMbPartIdx);        
        end   
*/
initial $fsdbDumpvars;
endmodule

