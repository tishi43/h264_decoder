//--------------------------------------------------------------------------------------------------
// Design    : bitstream_p
// Author(s) : qiu bin, shi tian qi
// Email     : chat1@126.com, tishi1@126.com
// Copyright (C) 2013 qiu bin 
// All rights reserved                
//-------------------------------------------------------------------------------------------------

module bitstream_fifo 
(
	clk,
	rst_n,
	read,
	stream_out,
	stream_out_valid,
	stream_over,
	
	sck_o,
	mosi_o,
	miso_i,
	csn_o
);
input			clk;
input 			rst_n;
input			read;
output	[7:0]	stream_out;
output			stream_out_valid;
output          stream_over;

output      sck_o;  
output      mosi_o; 
input       miso_i; 
output 	    csn_o; 

wire file_read_req;
wire [7:0] file_data;
wire file_data_valid;
sd_read_top sd_read_top(
    .clk0(clk),
    .rst_n(rst_n),

    .sck_o(sck_o),
    .mosi_o(mosi_o), 
    .miso_i(miso_i), 
    .csn_o(csn_o),
    
	.file_read_req(file_read_req),
	.file_data(file_data),
	.file_data_valid(file_data_valid),
	.file_reach_end(stream_over)
); 

reg [2:0] counter;
reg state;
reg first_fill;
reg stream_out_valid;

wire [10:0] usedw;
wire full;
parameter
Idle = 1'b0,
Fill = 1'b1;
always @(posedge clk or negedge rst_n)
if (!rst_n) begin
	state <= Idle;
	first_fill <= 1;
end
else 
case(state)
	Idle: begin
		if(usedw < 1024 && !full)
			state <= Fill;
	end
	Fill:begin
		if (usedw > 1024+511)
			state <= Idle;
		if (first_fill)
			first_fill <= 0;
	end
endcase

assign file_read_req = state == Fill;

always @(posedge clk or negedge rst_n)
if (!rst_n)
	stream_out_valid <= 0;
else begin
	if (first_fill && usedw > 1024+511)
		stream_out_valid <= 1;
	else if (first_fill)
		stream_out_valid <= 0;
	else
		stream_out_valid <= usedw > 1 || full;
end

stream_fifo stream_fifo (
	.aclr(!rst_n),
	.clock(clk),
	.data(file_data),
	.rdreq(read),
	.wrreq(file_data_valid),
	.empty(empty),
	.full(full),
	.q(stream_out),
	.usedw(usedw)
);


endmodule
