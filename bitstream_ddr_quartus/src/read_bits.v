//--------------------------------------------------------------------------------------------------
// Design    : bitstream_p
// Author(s) : qiu bin, shi tian qi
// Email     : chat1@126.com, tishi1@126.com
// Copyright (C) 2013 qiu bin 
// All rights reserved                
//-------------------------------------------------------------------------------------------------


module read_bits(data_in, en_in, len_in, data_out);
input [23:16] data_in;
input [3:0] len_in;
input en_in;
output [7:0] data_out;

reg[7:0] data_out;

always @(data_in or len_in or en_in)
if(en_in)
case ( len_in )
1 : data_out <= data_in[23];
2 : data_out <= data_in[23:22];
3 : data_out <= data_in[23:21];
4 : data_out <= data_in[23:20];
5 : data_out <= data_in[23:19];
6 : data_out <= data_in[23:18];
7 : data_out <= data_in[23:17];
8 : data_out <= data_in[23:16];
default: data_out <= 0;
endcase
else
    data_out <= 0;
    
endmodule