module spi_master_ctrl
(
	wb_clk_i,
	wb_rst_i,
	wb_adr_o,
	wb_dat_i,
	wb_dat_o,
	wb_we_o,
	wb_stb_o,
	wb_ack_i,
	
	init_done,
	sector_rd_start,
	sector_rd_addr,
	addr_o,
	data_o,
	wr_o,
	reading,
	read_done,
	state
);		
input        wb_clk_i;
input        wb_rst_i;     
output[7:0]  wb_adr_o;
input [7:0]  wb_dat_i;
output[7:0]  wb_dat_o;
output       wb_we_o;  
output       wb_stb_o;
input        wb_ack_i;

output      init_done;
input sector_rd_start;
input [22:0] sector_rd_addr;

output [8:0] addr_o;
output [7:0] data_o;
output wr_o;
    
output [3:0] state;
output  reading;
output  read_done;

reg[7:0]   wb_adr_o;
reg[7:0]   wb_dat_o;
reg        wb_we_o;  
reg        wb_stb_o;  

reg init_done;
reg [8:0]  addr_o;
reg [3:0]  state;
parameter
Idle 				= 0,
TransTypeInit 		= 1,
TransTypeInitStart 	= 2,
WaitInitDone        = 3,
TransAddr0to7       = 4,
TransAddr8to15      = 5,
TransAddr16to23      = 6,
TransAddr24to31     = 7,
TransTypeRead 		= 8,
TransTypeReadStart 	= 9,
WaitReadDone        = 10,
ReadRxFifoData      = 11;

reg  reading;
reg[1:0] step;
reg [3:0] init_delay;
reg read_done;

always @(posedge wb_clk_i or posedge wb_rst_i)
if (wb_rst_i)
  init_delay <= 'hf;
else if (init_delay > 0)
  init_delay <= init_delay - 1;


always @(posedge wb_clk_i or posedge wb_rst_i)
if(wb_rst_i) begin
	state <= Idle; 
	step  <= 0;
	wb_adr_o <= 0;
	wb_dat_o <= 0;  
	wb_stb_o <= 0; 
	wb_we_o  <= 0;
	init_done <= 0;
	addr_o    <= 0;
end
else begin
	case (state)
	Idle : begin
		if (!init_done && init_delay == 0) begin
			state <= TransTypeInit;
			step  <= 0;
		end
		else if (sector_rd_start) begin
			state <= TransAddr0to7;
			addr_o  <= 0;
			step    <= 0;
			read_done <= 0;
		end
		else
			state <= Idle;
	end
	TransTypeInit : begin
		if (step == 0) begin
			step <= 1;
			wb_adr_o <= 8'h02;
			wb_dat_o <= 8'h01;  
			wb_stb_o <= 1'b1; 
			wb_we_o  <= 1'b1;
		end
		else if (step == 1)begin
			if(wb_ack_i) begin
				wb_stb_o <= 1'b0;
				state <= TransTypeInitStart;
				step <= 0;
			end
		end
	end
	TransTypeInitStart : begin
		if (step == 0) begin
			step <= 1;
			wb_adr_o <= 8'h03;
			wb_dat_o <= 8'h01;  
			wb_stb_o <= 1'b1; 
			wb_we_o  <= 1'b1;
		end
		else if (step == 1)begin
			if(wb_ack_i) begin
				wb_stb_o <= 1'b0;
				state <= WaitInitDone;
				step <= 0;
			end
		end
	end
	WaitInitDone : begin
		if (step == 0) begin
			step <= 1;
			wb_adr_o <= 8'h04;
			wb_dat_o <= 8'h00;  
			wb_stb_o <= 1'b1; 
			wb_we_o  <= 1'b0;
		end
		else if (step == 1)begin
			if(wb_ack_i) begin
				wb_stb_o <= 1'b0;
				step <= 2;
			end
		end
		else if (step == 2) begin
			if (wb_dat_i != 8'h01) begin
				state <= Idle;
				init_done <= 1;				
			end
		end
	end
	TransAddr0to7 : begin
		if (step == 0) begin
			step <= 1;
			wb_adr_o <= 8'h07;
			wb_dat_o <= 8'h00;  
			wb_stb_o <= 1'b1; 
			wb_we_o  <= 1'b1;
		end
		else if (step == 1)begin
			if(wb_ack_i) begin
				wb_stb_o <= 1'b0;
				state <= TransAddr8to15;
				step <= 0;
			end
		end
	end
	TransAddr8to15 : begin
		if (step == 0) begin
			step <= 1;
			wb_adr_o <= 8'h08;
			wb_dat_o <= {sector_rd_addr[6:0],1'b0};  
			wb_stb_o <= 1'b1; 
			wb_we_o  <= 1'b1;
		end
		else if (step == 1)begin
			if(wb_ack_i) begin
				wb_stb_o <= 1'b0;
				state <= TransAddr16to23;
				step <= 0;
			end
		end
	end
	TransAddr16to23 : begin
		if (step == 0) begin
			step <= 1;
			wb_adr_o <= 8'h09;
			wb_dat_o <= sector_rd_addr[14:7]; 
			wb_stb_o <= 1'b1; 
			wb_we_o  <= 1'b1;
		end
		else if (step == 1)begin
			if(wb_ack_i) begin
				wb_stb_o <= 1'b0;
				state <= TransAddr24to31;
				step <= 0;
			end
		end
	end
	TransAddr24to31 : begin
		if (step == 0) begin
			step <= 1;
			wb_adr_o <= 8'h0a;
			wb_dat_o <= sector_rd_addr[22:15];
			wb_stb_o <= 1'b1; 
			wb_we_o  <= 1'b1;
		end
		else if (step == 1)begin
			if(wb_ack_i) begin
				wb_stb_o <= 1'b0;
				state <= TransTypeRead;
				step <= 0;
			end
		end
	end
	TransTypeRead : begin
		if (step == 0) begin
			step <= 1;
			wb_adr_o <= 8'h02;
			wb_dat_o <= 8'h02;  
			wb_stb_o <= 1'b1; 
			wb_we_o  <= 1'b1;
		end
		else if (step == 1)begin
			if(wb_ack_i) begin
				wb_stb_o <= 1'b0;
				state <= TransTypeReadStart;
				step <= 0;
			end
		end
	end
	TransTypeReadStart : begin
		if (step == 0) begin
			step <= 1;
			wb_adr_o <= 8'h03;
			wb_dat_o <= 8'h01;  
			wb_stb_o <= 1'b1; 
			wb_we_o  <= 1'b1;
		end
		else if (step == 1)begin
			if(wb_ack_i) begin
				wb_stb_o <= 1'b0;
				state <= WaitReadDone;
				step <= 0;
			end
		end
	end
	WaitReadDone : begin
		if (step == 0) begin
			step <= 1;
			wb_adr_o <= 8'h04;
			wb_dat_o <= 8'h00;  
			wb_stb_o <= 1'b1; 
			wb_we_o  <= 1'b0;
		end
		else if (step == 1)begin
			if(wb_ack_i) begin
				wb_stb_o <= 1'b0;
				step <= 2;
			end
		end
		else if (step == 2) begin
			if (wb_dat_i != 8'h01) begin
				step <= 0;
				state <= ReadRxFifoData;
				init_done <= 1;				
			end
		end
	end
	ReadRxFifoData : begin
		if (step == 0) begin
			step <= 1;
			wb_adr_o <= 8'h10;
			wb_dat_o <= 8'h00;  
			wb_stb_o <= 1'b1; 
			wb_we_o  <= 1'b0;
		end
		else if (step == 1)begin
			if (reading == 0)
				reading <= 1;
			if(wb_ack_i) begin
				wb_stb_o <= 1'b0;
				if (addr_o < 511) begin
					addr_o <= addr_o + 1;
					step <= 2;
				end
				else begin
					state <= Idle;
					reading <= 0;
					read_done <= 1;
				end
			end
		end
		else if (step == 2)begin			
			wb_stb_o <= 1'b1;
			step <= 1;
		end
	end
	endcase
end

assign data_o = wb_dat_i;
assign wr_o = reading && wb_ack_i;

endmodule					   


