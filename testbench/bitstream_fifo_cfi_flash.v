//--------------------------------------------------------------------------------------------------
// Design    : bitstream_p
// Author(s) :qiu bin, shi tian qi
// Email	   : chat1@126.com, tishi1@126.com
// Copyright (C) 2013 qiu bin                
//-------------------------------------------------------------------------------------------------
module bitstream_fifo_cfi_flash
(
	clk,
	rst_n,
	read,
	q,
	ready,
	flash_addr,
	flash_data,
	flash_ce_n,
	flash_oe_n,  
	flash_we_n,
	flash_rst_n
);
input			clk;
input 			rst_n;
input			read;
output	[7:0]	q;
output			ready;
output	[21:0]	flash_addr;
input	[7:0]	flash_data;
output			flash_ce_n;
output			flash_oe_n;
output			flash_we_n;
output			flash_rst_n;

parameter ReadPeriod = 3;

assign flash_rst_n = rst_n;

reg [2:0] counter;
reg state;
reg first_fill;
reg ready;

wire [6:0] usedw;
wire full;
parameter
Idle = 1'b0,
Fill = 1'b1;
always @(posedge clk or negedge rst_n)
if (!rst_n) begin
	state <= Idle;
	counter <= 0;
end
else 
case(state)
	Idle: begin
		if(usedw[6] == 0 && !full)
			state <= Fill;
	end
	Fill:begin
		if (full)
			state <= Idle;
		else if (counter < ReadPeriod)
			counter <= counter + 1;
		else
			counter <= 0;
	end
endcase

always @(posedge clk or negedge rst_n)
if (!rst_n)
begin
	ready <= 0;
	first_fill <= 1;
end
else 
begin
	if (first_fill && full)
	begin
		ready <= 1;
		first_fill <= 0;
	end
	else if (first_fill)
		ready <= 0;
	else
		ready <= usedw > 1 || full;
end

reg flash_ce_n;
reg flash_oe_n;
reg flash_we_n;
reg [21:0]flash_addr;


always @(*)
if (state == Fill)begin
	flash_ce_n <= 0;
	flash_oe_n <= 0;
	flash_we_n <= 1;
end
else begin
	flash_ce_n <= 1;
	flash_oe_n <= 1;
	flash_we_n <= 1;
end

always @(posedge clk or negedge rst_n)
if (!rst_n) begin
	flash_addr <= 0;
end
else if (state == Fill && counter == ReadPeriod)
	flash_addr <= flash_addr + 1;

stream_fifo stream_fifo (
	.aclr(!rst_n),
	.clock(clk),
	.data(flash_data),
	.rdreq(read),
	.wrreq(state==Fill && counter == ReadPeriod),
	.empty(empty),
	.full(full),
	.q(q),
	.usedw(usedw)
);


endmodule
