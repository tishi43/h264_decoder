//--------------------------------------------------------------------------------------------------
// Design    : bitstream_p
// Author(s) : qiu bin, shi tian qi
// Email     : chat1@126.com, tishi1@126.com
// Copyright (C) 2013 qiu bin 
// All rights reserved                
//-------------------------------------------------------------------------------------------------


`include "defines.v"

module rbsp_buffer
(
 clk,
 rst_n,
 ena,
 rbsp_in, 
 valid_data_of_nalu_in, 
 forward_len_in,
 rd_req_to_nalu_out,
 rbsp_out,
 buffer_valid_out
);
input clk,rst_n; //global clock and reset
input ena;
input valid_data_of_nalu_in; //enable this module, valid data of nalu 
                             //valid data is the data except for start_code, nalu_head, competition_prevent_code
input [7:0] rbsp_in; //data from read nalu
input [4:0] forward_len_in; //length of bits to forward 

output rd_req_to_nalu_out;		 //read one byte request to read nalu 
output [23:0] rbsp_out;	         //bits output		     
output buffer_valid_out;

reg [31:0] buffer; // store 4 bytes, if 
//next_bits_offset
reg [2:0] bits_offset;
reg [4:0] next_bits_offset;

integer rbsp_bit_counter;
always @(posedge clk or negedge rst_n)
begin
	if (!rst_n)
	begin
		rbsp_bit_counter <= 3'b0;
	end
	else if ( ena && buffer_valid_out && forward_len_in != 'h1f )
	begin
		rbsp_bit_counter <= rbsp_bit_counter + forward_len_in;
	end
end

always @(bits_offset or forward_len_in)
//    if ( forward_len_in == 5'b11111 && bits_offset == 7) // forward_len_in 5'b11111 used to clear rbsp_trailing_bits
//        next_bits_offset <= 8;
    if ( forward_len_in == 'h1f ) // forward_len_in 5'b11111 used to clear rbsp_trailing_bits
        next_bits_offset <= 8;       
    else
        next_bits_offset <= bits_offset + forward_len_in; 

//bits_offset	 
always @(posedge clk or negedge rst_n)
begin
	if (!rst_n)
	begin
		bits_offset <= 3'b0;
	end
	else if ( ena && buffer_valid_out )
	begin
		bits_offset <= next_bits_offset[2:0];
	end
end
		
reg [2:0] num_of_byte_to_fill;
reg buffer_valid_out_int;
//num_of_byte_to_fill
always @ (posedge clk or negedge rst_n) 
    if (!rst_n)
        begin
        	num_of_byte_to_fill <= 4;
            buffer_valid_out_int <= 0;
        end
    else if ( ena && num_of_byte_to_fill == 0 && buffer_valid_out )
        begin
    	    num_of_byte_to_fill <= next_bits_offset[4:3];
    	    buffer_valid_out_int <= (next_bits_offset[4:3] == 0);
    	end
    else if ( ena && valid_data_of_nalu_in  && rd_req_to_nalu_out)
        begin
    	    num_of_byte_to_fill <= num_of_byte_to_fill - 1'b1;
    	    buffer_valid_out_int <= (num_of_byte_to_fill == 1);
        end

assign buffer_valid_out = buffer_valid_out_int;
//equest data from nalu
assign rd_req_to_nalu_out = valid_data_of_nalu_in? (num_of_byte_to_fill > 0) : 1'b1; 
// if nalu output is invalid, request data from nalu again

//buffer
integer i;		
always @ (posedge clk or negedge rst_n) 
if (!rst_n)
	buffer <= 32'b0;
else if (ena && valid_data_of_nalu_in  && rd_req_to_nalu_out)
begin
	for (i = 0 ; i <  8; i = i + 1)
    begin
	   buffer[i+8]  <= buffer[i];
	   buffer[i+16] <= buffer[i+8];		   
	   buffer[i+24] <= buffer[i+16];		
	end
    for (i = 0 ; i < 8 ; i = i + 1)
 	   buffer[i] <= rbsp_in[i];	
end

reg [23:0] rbsp_out;
always@(buffer or bits_offset)
	case (bits_offset)
		0  :rbsp_out <= buffer[31:8];
		1  :rbsp_out <= buffer[30:7];
		2  :rbsp_out <= buffer[29:6];
		3  :rbsp_out <= buffer[28:5];
		4  :rbsp_out <= buffer[27:4];
		5  :rbsp_out <= buffer[26:3];
		6  :rbsp_out <= buffer[25:2];
		7  :rbsp_out <= buffer[24:1];
	endcase
	
endmodule
