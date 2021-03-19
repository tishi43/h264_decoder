//--------------------------------------------------------------------------------------------------
// Design    : bitstream_p
// Author(s) : qiu bin, shi tian qi
// Email     : chat1@126.com, tishi1@126.com
// Copyright (C) 2013 qiu bin 
// All rights researved                
//-------------------------------------------------------------------------------------------------


// used for storing intra4x4_pred_mode, ref_idx, mvp etc
// 
module ram
(
clk,
wr_n, 
addr, 
data_in, 
data_out
);
parameter addr_bits = 9;
parameter data_bits = 8;
input     clk;
input     wr_n;
input     [addr_bits-1:0]  addr;
input     [data_bits-1:0]  data_in;
output    [data_bits-1:0]  data_out;

reg       [data_bits-1:0]  ram[0:(1 << addr_bits) -1];
reg       [data_bits-1:0]  data_out;

//read
always @ ( posedge clk )
begin
    data_out <= ram[addr];
end 

//write
always @ (posedge clk)
begin
    if (!wr_n)
        ram[addr] <= data_in;
end

endmodule
