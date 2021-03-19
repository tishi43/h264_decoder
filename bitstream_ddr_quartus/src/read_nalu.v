//--------------------------------------------------------------------------------------------------
// Design    : bitstream_p
// Author(s) : qiu bin, shi tian qi
// Email     : chat1@126.com, tishi1@126.com
// Copyright (C) 2013 qiu bin 
// All rights reserved                
//-------------------------------------------------------------------------------------------------

module read_nalu
(
 clk,
 rst_n,
 ena,
 rd_req_by_rbsp_buffer_in,
 mem_data_in,

 nal_unit_type,
 nal_ref_idc,
 forbidden_zero_bit,

 stream_mem_addr, 
 mem_rd_req_out,
 rbsp_data_out,
 rbsp_valid_out
);
input clk,rst_n;	   //global clock and reset					   
input rd_req_by_rbsp_buffer_in;		   //enable this module
input ena;
input 	[7:0]	mem_data_in;	  //data from stream
output	[31:0]	stream_mem_addr;
output  		mem_rd_req_out;		  //read request from stream

output[4:0] nal_unit_type;	   //nalu head output
output[1:0] nal_ref_idc;
output      forbidden_zero_bit; 

output[7:0] rbsp_data_out;	  //data to rbsp buffer
output      rbsp_valid_out;	  	 //write to rbsp buffer

//nslu
parameter
NaluStartBytes = 24'h000001;

reg[7:0] nalu_head;
reg       nalu_valid;
wire[7:0] rbsp_data_out;

reg[7:0] last_byte3;
reg[7:0] last_byte2;
reg[7:0] last_byte1;
reg[7:0] current_byte;
reg[7:0] next_byte1;
reg[7:0] next_byte2;
reg[7:0] next_byte3;
reg[7:0] next_byte4;

reg  start_bytes_detect;//current nalu start bytes
wire next_start_bytes_detect; //next nalu start bytes

reg [31:0] stream_mem_addr;
always @(posedge clk or negedge rst_n)
if (!rst_n)
   stream_mem_addr  <=  0;
else if (ena && mem_rd_req_out == 1'b1)
   stream_mem_addr  <= stream_mem_addr + 1;


always @(posedge clk or negedge rst_n)
if (!rst_n)
begin
   last_byte1   <= 8'b0;
   last_byte2   <= 8'b0;
   last_byte3   <= 8'b0;
   current_byte <= 8'b0;
   next_byte1   <= 8'b0;
   next_byte2   <= 8'b0;
   next_byte3   <= 8'b0;
   next_byte4   <= 8'b0;
end
else if (ena && mem_rd_req_out)
begin
   next_byte4   <= mem_data_in;
   next_byte3   <= next_byte4;
   next_byte2   <= next_byte3;
   next_byte1   <= next_byte2;
   current_byte <= next_byte1;
   last_byte1   <= current_byte;
   last_byte2   <= last_byte1;
   last_byte3   <= last_byte2; 
end
    
//detect nalu start bytes     
always @(posedge clk or negedge rst_n)
if (~rst_n)
    start_bytes_detect <= 1'b0;
else if(ena) begin
	if (rd_req_by_rbsp_buffer_in && {last_byte2,last_byte1,current_byte} 
			 == NaluStartBytes)
		start_bytes_detect <= 1'b1;
	else if (rd_req_by_rbsp_buffer_in)
		start_bytes_detect <= 1'b0;    
end
//nalu head
always @(posedge clk or negedge rst_n)
if (~rst_n)
   nalu_head <= 'b0;
else if (ena && rd_req_by_rbsp_buffer_in && start_bytes_detect)
   nalu_head <= current_byte;


always @(posedge clk or negedge rst_n)
if (~rst_n)
   nalu_valid <= 1'b0;
else if (ena) begin
	if(rd_req_by_rbsp_buffer_in && next_start_bytes_detect)
	   nalu_valid <= 1'b0;
	else if (rd_req_by_rbsp_buffer_in && start_bytes_detect)
	   nalu_valid <= 1'b1;
end
//current nalu end , next nalu start       
assign next_start_bytes_detect =  {next_byte1,next_byte2,next_byte3} == NaluStartBytes ||
{next_byte1,next_byte2,next_byte3,next_byte4} == {8'h00,NaluStartBytes} ;

//nalu head struct
assign nal_unit_type = nalu_head[4:0];
assign nal_ref_idc = nalu_head[6:5];
assign forbidden_zero_bit = nalu_head[7]; 

//ebsp to rbsp
parameter
emulation_prevention_three_byte = 24'h000003;

reg competition_bytes_detect;

always @(posedge clk or negedge rst_n)
if (~rst_n)
    competition_bytes_detect <= 1'b0;
else if (ena)begin
	if (rd_req_by_rbsp_buffer_in && {last_byte1,current_byte,next_byte1}
			  == emulation_prevention_three_byte)
		competition_bytes_detect <= 1'b1;
	else if (rd_req_by_rbsp_buffer_in)
		competition_bytes_detect <= 1'b0;
end
     
assign rbsp_data_out = current_byte;
assign rbsp_valid_out = nalu_valid && !competition_bytes_detect &&  nal_ref_idc;

//mem read
assign mem_rd_req_out = rst_n?(rd_req_by_rbsp_buffer_in && ena):0;
        
endmodule
