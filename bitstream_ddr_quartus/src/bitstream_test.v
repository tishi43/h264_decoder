//--------------------------------------------------------------------------------------------------
// Design    : bitstream_p
// Author(s) : qiu bin, shi tian qi
// Email     : chat1@126.com, tishi1@126.com
// Copyright (C) 2013 qiu bin 
// All rights reserved                
//-------------------------------------------------------------------------------------------------

`include "defines.v"

module bitstream_test (
	clk,
	rst_n,
	
	key1,
	
	vga_hsync,
	vga_vsync,
	vga_blank,
	vga_clk,
	vga_r,
	vga_g,
	vga_b,
	
	sck_o,
	mosi_o,
	miso_i,
	csn_o,
	
	ddr1_data,
	ddr1_dqs, 
	ddr1_dqm,  
	ddr1_we_n,  
	ddr1_ras_n,  
	ddr1_cs_n,  
	ddr1_cke,  
	ddr1_cas_n,  
	ddr1_ba,   
	ddr1_addr,
	ddr1_clk,
	ddr1_clk_n,
	
	ddr2_data,
	ddr2_dqs, 
	ddr2_dqm,  
	ddr2_we_n,  
	ddr2_ras_n,  
	ddr2_cs_n,  
	ddr2_cke,  
	ddr2_cas_n,  
	ddr2_ba,   
	ddr2_addr,
	ddr2_clk,
	ddr2_clk_n
);
input			clk;
input			rst_n;

//play\pause botton
input           key1;

//vga
output			vga_hsync;
output			vga_vsync;
output         vga_blank;
output         vga_clk;
output [7:0]	vga_r;
output [7:0]	vga_g;
output [7:0]	vga_b;

//Flash
output      sck_o;  
output      mosi_o; 
input       miso_i; 
output 	    csn_o; 

//SDRAM
inout  [15:0] 	ddr1_data;
inout  [1:0]  	ddr1_dqs; 
output [1:0]  	ddr1_dqm;  
output 			ddr1_we_n;
output 			ddr1_ras_n;  
output 			ddr1_cs_n; 
output 			ddr1_cke;  
output 			ddr1_cas_n;  
output [1:0]	ddr1_ba;
output [12:0]	ddr1_addr;
inout          ddr1_clk;
inout          ddr1_clk_n;

inout  [15:0] 	ddr2_data;
inout  [1:0]  	ddr2_dqs; 
output [1:0]  	ddr2_dqm;  
output 			ddr2_we_n;
output 			ddr2_ras_n;  
output 			ddr2_cs_n; 
output 			ddr2_cke;  
output 			ddr2_cas_n;  
output [1:0]	ddr2_ba;
output [12:0]	ddr2_addr;
inout          ddr2_clk;
inout          ddr2_clk_n;

wire dec_clk;
wire vga_clk;

pll pll
(
	.inclk0(clk),
	.c0(clk_25m),
	.c1(clk_30m)
);
assign dec_clk = clk_30m;
assign vga_clk = clk_25m;


wire [10:0] x;
wire [10:0] y;
wire vga_valid;
wire vga_y_valid;

vga vga
(
	.rst_n(rst_n),
	.clk(vga_clk),
	.hsync(vga_hsync),
	.vsync(vga_vsync),
	.valid(vga_valid),
	.y_valid(vga_y_valid),
	.x(x),
	.y(y)
);
assign vga_blank = 1;
wire	[31:0]	data_from_sdram_y/*synthesis keep*/;
wire	[31:0]	data_from_sdram_u/*synthesis keep*/;
wire	[31:0]	data_from_sdram_v/*synthesis keep*/;

reg	[7:0]   yuv2rgb_y;
reg	[7:0]   yuv2rgb_u;
reg	[7:0]   yuv2rgb_v;

wire [7:0] yuv2rgb_r;
wire [7:0] yuv2rgb_g;
wire [7:0] yuv2rgb_b;


always @(*)
begin
	if (x[1:0] == 1)
		yuv2rgb_y <= data_from_sdram_y[7:0];
	else if (x[1:0] == 2)
		yuv2rgb_y <= data_from_sdram_y[15:8];
	else if (x[1:0] == 3)
		yuv2rgb_y <= data_from_sdram_y[23:16];
	else
		yuv2rgb_y <= data_from_sdram_y[31:24];
	if (x[2:1] == 1)
	begin
		yuv2rgb_u <= data_from_sdram_u[7:0];
		yuv2rgb_v <= data_from_sdram_v[7:0];
	end
	else if (x[2:1] == 2)
	begin
		yuv2rgb_u <= data_from_sdram_u[15:8];
		yuv2rgb_v <= data_from_sdram_v[15:8];
	end
	else if (x[2:1] == 3)
	begin
		yuv2rgb_u <= data_from_sdram_u[23:16];
		yuv2rgb_v <= data_from_sdram_v[23:16];
	end
	else
	begin
		yuv2rgb_u <= data_from_sdram_u[31:24];
		yuv2rgb_v <= data_from_sdram_v[31:24];
	end
end

yuv2rgb yuv2rgb
(
  .clk(vga_clk),
  .rst_n(rst_n),
  .y(yuv2rgb_y),
  .u(yuv2rgb_u),
  .v(yuv2rgb_v),
  .r(yuv2rgb_r),
  .g(yuv2rgb_g),
  .b(yuv2rgb_b)
);


reg	[`ext_buf_mem_addr_width-1:0]	h_base_addr_y;
reg	[`ext_buf_mem_addr_width-1:0]	h_base_addr_u;
reg	[`ext_buf_mem_addr_width-1:0]	h_base_addr_v;
reg [`mb_x_bits+3:0]	pic_width;
reg [`mb_y_bits+3:0]	pic_height;
reg start_of_frame;
reg end_of_frame;
reg [9:0]	pic_num;

wire		[`mb_x_bits-1:0]	pic_width_in_mbs;
wire		[`mb_y_bits-1:0]	pic_height_in_map_units;
wire		start_of_frame_wire;
wire		end_of_frame_wire;
wire [9:0]	pic_num_wire;

always @(posedge vga_clk)
begin
	if (start_of_frame) begin
		pic_width <= {pic_width_in_mbs, 4'b0};
		pic_height <= {pic_height_in_map_units,4'b0};
	end
	start_of_frame <= start_of_frame_wire;
	end_of_frame <= end_of_frame_wire;
	pic_num <= pic_num_wire;
end

reg vga_hsync_d;
reg vga_vsync_d;
reg vga_hsync_end;
reg vga_vsync_end;
reg vga_hsync_end_d;
reg vga_vsync_end_d;

always @(posedge vga_clk)
begin
	vga_hsync_d <= vga_hsync;
	vga_vsync_d <= vga_vsync;
	vga_hsync_end_d <= vga_hsync_end;
	vga_vsync_end_d <= vga_vsync_end;
	if (vga_hsync == 1 && vga_hsync_d == 0)
		vga_hsync_end <= 1;
	else
		vga_hsync_end <= 0;
	if (vga_vsync == 1 && vga_vsync_d == 0)
		vga_vsync_end <= 1;
	else
		vga_vsync_end <= 0;
end

reg [21:0] pic_base_addr;
always @(posedge vga_clk)
if (vga_hsync_end && pic_num[0])
	pic_base_addr <= 0;
else if (vga_hsync_end)
	pic_base_addr <= (pic_width * pic_height) + (pic_width * pic_height) / 2;

always @(posedge vga_clk)
begin
	if (vga_hsync_end)
	begin
		h_base_addr_y <= pic_base_addr + y*pic_width;
		h_base_addr_u <= pic_base_addr + (pic_width * pic_height) + (y / 2) * (pic_width / 2);
		h_base_addr_v <= pic_base_addr + (pic_width * pic_height) + (pic_width * pic_height) / 4 + (y / 2) * (pic_width / 2);
	end
end

reg [7:0]	vga_r;
reg [7:0]	vga_g;
reg [7:0]	vga_b;

always @(posedge vga_clk or negedge rst_n)
begin
	if (!rst_n)
	begin
		vga_r <= 0;
		vga_g <= 0;
		vga_b <= 0;
	end
	else if (vga_valid == 0 ||  x >= pic_width || y >= pic_height)
	begin
		vga_r <= 0;
		vga_g <= 0;
		vga_b <= 0;
	end
	else
	begin
		vga_r <= yuv2rgb_r;
		vga_g <= yuv2rgb_g;
		vga_b <= yuv2rgb_b;
	end
end


wire [23:0] num_cycles_1_frame;

play_pause play_pause
(
 .clk(dec_clk),
 .rst_n(rst_n),
 .key1(key1),
 .num_cycles_1_frame(num_cycles_1_frame)
);

wire          sc_ready;
wire    [7:0] stream_data;
wire          stream_fifo_ready;
wire          stream_mem_rd;

reg                                     ext_mem_init_done;
wire                                    ext_mem_burst;
wire    [4:0]							ext_mem_burst_len_minus1;
wire	[`ext_buf_mem_addr_width-1:0] 	ext_mem_addr;
wire    								ext_mem_rd;
wire    								ext_mem_wr;
wire  [`ext_buf_mem_data_width-1:0]		ext_mem_d;
wire  [31:0]							ext_mem_q;
wire 									ext_mem_full;
wire 									ext_mem_valid;
wire                                    ext_display_buf_mem_burst;
wire	[`ext_buf_mem_addr_width-1:0] 	ext_display_buf_addr;
wire sdrc_buffer_full;
wire sdrc_display_full;
wire sdrc_buffer_init_done_wire;
wire sdrc_display_init_done_wire;
reg sdrc_buffer_init_done;
reg sdrc_display_init_done;

always @(posedge dec_clk or negedge rst_n)
if (!rst_n)
	ext_mem_init_done <= 0;
else begin
	sdrc_buffer_init_done <= sdrc_buffer_init_done_wire;
	sdrc_display_init_done <= sdrc_display_init_done_wire;
	ext_mem_init_done <= sdrc_buffer_init_done && sdrc_display_init_done;

end

decode_stream u_decode_stream
(
 .clk(dec_clk),
 .rst_n(rst_n),
 .ena(1'b1),
 
 .num_cycles_1_frame(num_cycles_1_frame),
  
 //interface to stream memory or fifo
 .stream_mem_valid(stream_fifo_ready),
 .stream_mem_data_in(stream_data),
 .stream_mem_addr_out(),
 .stream_mem_rd(stream_mem_rd),
 .stream_mem_end(stream_over),
 
 //interface to external buffer memory
 .ext_mem_init_done(ext_mem_init_done),
 .ext_mem_burst(ext_mem_burst),
 .ext_mem_burst_len_minus1(ext_mem_burst_len_minus1),
 .ext_mem_addr(ext_mem_addr),
 .ext_mem_rd(ext_mem_rd),
 .ext_mem_wr(ext_mem_wr),
 .ext_mem_d(ext_mem_d),
 .ext_mem_q(ext_mem_q),
 .ext_mem_full(sdrc_buffer_full),
 .ext_mem_valid(ext_mem_valid),
 .ext_display_buf_mem_burst(ext_display_buf_mem_burst),
 .ext_display_buf_addr(ext_display_buf_addr),
 
 //video information
 .pic_width_in_mbs(pic_width_in_mbs),
 .pic_height_in_map_units(pic_height_in_map_units),
 .start_of_frame(start_of_frame_wire),
 .end_of_frame(end_of_frame_wire),
 .pic_num(pic_num_wire)
);


bitstream_fifo bitstream_fifo 
(
	.clk(dec_clk),
	.rst_n(rst_n),
	.read(stream_mem_rd),
	.stream_out(stream_data),
	.stream_out_valid(stream_fifo_ready),
	.stream_over(stream_over),
	.sck_o(sck_o),
	.mosi_o(mosi_o),
	.miso_i(miso_i),
	.csn_o(csn_o)
);


sdrc_buffer sdrc_buffer (
	.clk(clk),
	.dec_clk(dec_clk),
	.rst_n(rst_n),
	
	.init_done(sdrc_buffer_init_done_wire),
	.burst(ext_mem_burst),
	.burst_len_minus1(ext_mem_burst_len_minus1),
	.addr(ext_mem_addr),
	.rd(ext_mem_rd),
	.wr(ext_mem_wr),
	.d(ext_mem_d),
	.q(ext_mem_q),
	.full(sdrc_buffer_full),
	.valid(ext_mem_valid),
  
	.ddr_data(ddr1_data),
	.ddr_dqs(ddr1_dqs),
	.ddr_dqm(ddr1_dqm),
	.ddr_ras_n(ddr1_ras_n),
	.ddr_cas_n(ddr1_cas_n),
	.ddr_we_n(ddr1_we_n),  
	.ddr_cs_n(ddr1_cs_n), 
	.ddr_cke(ddr1_cke),  
	.ddr_ba(ddr1_ba),
	.ddr_addr(ddr1_addr),
	.ddr_clk(ddr1_clk),
	.ddr_clk_n(ddr1_clk_n)
);

wire y_rd;
wire uv_rd;
sdrc_display sdrc_display (
	.clk(clk),
	.dec_clk(dec_clk),
	.vga_clk(vga_clk),
	.rst_n(rst_n),
	
	.init_done(sdrc_display_init_done_wire),
	.burst(ext_display_buf_mem_burst),
	.burst_len_minus1(ext_mem_burst_len_minus1),
	.addr(ext_display_buf_addr),
	.wr(ext_mem_wr),
	.d(ext_mem_d),
	.full(sdrc_display_full),
	
	.y_addr(h_base_addr_y),
	.u_addr(h_base_addr_u),
	.v_addr(h_base_addr_v),
	.display_addr_load(vga_hsync_end),
	.vga_valid(vga_valid),
	.y_rd(y_rd),
	.uv_rd(uv_rd),
	.y_data(data_from_sdram_y),
	.u_data(data_from_sdram_u),
	.v_data(data_from_sdram_v),
	  
  	.ddr_data(ddr2_data),
	.ddr_dqs(ddr2_dqs),
	.ddr_dqm(ddr2_dqm),
	.ddr_ras_n(ddr2_ras_n),
	.ddr_cas_n(ddr2_cas_n),
	.ddr_we_n(ddr2_we_n),  
	.ddr_cs_n(ddr2_cs_n), 
	.ddr_cke(ddr2_cke),  
	.ddr_ba(ddr2_ba),
	.ddr_addr(ddr2_addr),
	.ddr_clk(ddr2_clk),
	.ddr_clk_n(ddr2_clk_n)
);

assign y_rd  = vga_valid&& x[1:0] == 0 && x >= 0 && x < pic_width && y >= 0 && y < pic_height;
assign uv_rd = vga_valid&& x[2:0] == 0 && x >= 0 && x < pic_width && y >= 0 && y < pic_height;

// synthesis translate_off
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
		    $fdisplay( fp_w_residual, "mb_index_out:%-d luma4x4BlkIdx: %-d  chroma4x4BlkIdx :%-d", u_decode_stream.slice_data_dut.mb_index_out,  u_decode_stream.slice_data_dut.luma4x4BlkIdx_out, u_decode_stream.slice_data_dut.chroma4x4BlkIdx_out);		
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
    		$fdisplay( fp_w_mv, "mvx_l0_curr_mb_out:%5d%5d%5d%5d", u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[7:0],
    		                                                    u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[15:8],
    		                                                    u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[39:32],
    		                                                    u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[47:40]
    		                                                    );
    		                                                    
    		$fdisplay( fp_w_mv, "mvx_l0_curr_mb_out:%5d%5d%5d%5d", u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[23:16],
    		                                                    u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[31:24],
    		                                                    u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[55:48],
    		                                                    u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[63:56]
    		                                                    );
    		$fdisplay( fp_w_mv, "mvx_l0_curr_mb_out:%5d%5d%5d%5d", u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[71:64],
    		                                                    u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[79:72],
    		                                                    u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[103:96],
    		                                                    u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[111:104]
    		                                                    );
    		$fdisplay( fp_w_mv, "mvx_l0_curr_mb_out:%5d%5d%5d%5d", u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[87:80],
    		                                                    u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[95:88],
    		                                                    u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[119:112],
    		                                                    u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[127:120]
    		                                                    );
    		$fdisplay( fp_w_mv, "mvy_l0_curr_mb_out:%5d%5d%5d%5d", u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[7:0],
    		                                                    u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[15:8],
    		                                                    u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[39:32],
    		                                                    u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[47:40]
    		                                                    
    		                                                    );
    		$fdisplay( fp_w_mv, "mvy_l0_curr_mb_out:%5d%5d%5d%5d", u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[23:16],
    		                                                    u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[31:24]
    		                                                    ,
    		                                                    u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[55:48],
    		                                                    u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[63:56]
    		                                                    );
    		$fdisplay( fp_w_mv, "mvy_l0_curr_mb_out:%5d%5d%5d%5d", u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[71:64],
    		                                                    u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[79:72],
    		                                                    u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[103:96],
    		                                                    u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[111:104]
    		                                                    );
    		$fdisplay( fp_w_mv, "mvy_l0_curr_mb_out:%5d%5d%5d%5d", u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[87:80],
    		                                                    u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[95:88]
    		                                                    ,
    		                                                    u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[119:112],
    		                                                    u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[127:120]); 
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
    		$fdisplay( fp_w, "mvx_l0_curr_mb_out:%5d%5d%5d%5d", u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[7:0],
    		                                                    u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[15:8],
    		                                                    u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[39:32],
    		                                                    u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[47:40]
    		                                                    );
    		$fdisplay( fp_w, "mvx_l0_curr_mb_out:%5d%5d%5d%5d", u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[23:16],
    		                                                    u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[31:24]
    		                                                    ,
    		                                                    u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[55:48],
    		                                                    u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[63:56]);
    		$fdisplay( fp_w, "mvx_l0_curr_mb_out:%5d%5d%5d%5d", u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[71:64],
    		                                                    u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[79:72],
    		                                                    u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[103:96],
    		                                                    u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[111:104]
    		                                                    
    		                                                    );
    		$fdisplay( fp_w, "mvx_l0_curr_mb_out:%5d%5d%5d%5d", u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[87:80],
    		                                                    u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[95:88],
    		                                                    u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[119:112],
    		                                                    u_decode_stream.slice_data_dut.mvx_l0_curr_mb_out[127:120]
    		                                                    );
    		$fdisplay( fp_w, "mvy_l0_curr_mb_out:%5d%5d%5d%5d", u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[7:0],
    		                                                    u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[15:8],
    		                                                    u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[39:32],
    		                                                    u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[47:40]
    		                                                    
    		                                                    );
    		$fdisplay( fp_w, "mvy_l0_curr_mb_out:%5d%5d%5d%5d", u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[23:16],
    		                                                    u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[31:24]
    		                                                    ,
    		                                                    u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[55:48],
    		                                                    u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[63:56]
    		                                                    );
    		$fdisplay( fp_w, "mvy_l0_curr_mb_out:%5d%5d%5d%5d", u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[71:64],
    		                                                    u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[79:72],
    		                                                    u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[103:96],
    		                                                    u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[111:104]
    		                                                    );
    		$fdisplay( fp_w, "mvy_l0_curr_mb_out:%5d%5d%5d%5d", u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[87:80],
    		                                                    u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[95:88]
    		                                                    ,
    		                                                    u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[119:112],
    		                                                    u_decode_stream.slice_data_dut.mvy_l0_curr_mb_out[127:120]);
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

// synthesis translate_on
//initial $fsdbDumpvars;
endmodule
