//--------------------------------------------------------------------------------------------------
// Design    :  bitstream_p
// Author(s) :  qiu bin, shi tian qi
// Email     :  chat1@126.com, tishi1@126.com
// Copyright (C) 2013 qiu bin   All rights researved               
//-------------------------------------------------------------------------------------------------

`include "defines.v"

module bitstream_test_tb;
reg						clk;
reg						rst_n;
//VGA
wire						vga_hsync;
wire						vga_vsync;
wire 		[7:0]		vga_r;
wire 		[7:0]		vga_g;
wire 		[7:0]		vga_b;
wire                    key1;
wire                    vga_blank;
wire                    vga_clk;

//DDR SDRAM

//Flash
wire		[21:0]	flash_addr;
wire		[7:0]		flash_data;
wire						flash_ce_n;
wire						flash_oe_n;
wire						flash_we_n;
wire						flash_rst_n;

wire [15:0] 	ddr1_data;
wire [1:0]  	ddr1_dqs; 
wire [1:0]  	ddr1_dqm;  
wire 			ddr1_we_n;
wire 			ddr1_ras_n;  
wire 			ddr1_cs_n; 
wire 			ddr1_cke;  
wire 			ddr1_cas_n;  
wire [1:0]		ddr1_ba;
wire [12:0]		ddr1_addr;
wire            ddr1_clk;
wire            ddr1_clk_n;                        

wire [15:0] 	ddr2_data;
wire [1:0]  	ddr2_dqs; 
wire [1:0]  	ddr2_dqm;  
wire 			ddr2_we_n;
wire 			ddr2_ras_n;  
wire 			ddr2_cs_n; 
wire 			ddr2_cke;  
wire 			ddr2_cas_n;  
wire [1:0]		ddr2_ba;
wire [12:0]		ddr2_addr;
wire            ddr2_clk;
wire            ddr2_clk_n; 
bitstream_test_cfi_flash bitstream_test_cfi_flash (
	.clk	         	(clk),         
	.rst_n	       	(rst_n),   

	.key1           (key1),
	
	.vga_hsync	   	(vga_hsync),   
	.vga_vsync	   	(vga_vsync),
	.vga_clk        (vga_clk),
	.vga_blank      (vga_blank),   
	.vga_r	       	(vga_r),       
	.vga_g	       	(vga_g),       
	.vga_b	       	(vga_b),       
	               
	.flash_addr	  	(flash_addr),  
	.flash_data	  	(flash_data),  
	.flash_ce_n	  	(flash_ce_n),  
	.flash_oe_n	  	(flash_oe_n),  
	.flash_we_n	  	(flash_we_n),  
	.flash_rst_n	 	(flash_rst_n), 
           
	.ddr1_data      (ddr1_data), 
	.ddr1_dqs       (ddr1_dqs),  
	.ddr1_dqm       (ddr1_dqm),  
	.ddr1_we_n      (ddr1_we_n), 
	.ddr1_ras_n     (ddr1_ras_n),
	.ddr1_cs_n      (ddr1_cs_n), 
	.ddr1_cke       (ddr1_cke),  
	.ddr1_cas_n     (ddr1_cas_n),
	.ddr1_ba        (ddr1_ba),   
	.ddr1_addr      (ddr1_addr),
	.ddr1_clk       (ddr1_clk),
	.ddr1_clk_n     (ddr1_clk_n),     
	
	.ddr2_data      (ddr2_data), 	
	.ddr2_dqs       (ddr2_dqs),  	
	.ddr2_dqm       (ddr2_dqm),  	
	.ddr2_we_n      (ddr2_we_n), 	
	.ddr2_ras_n     (ddr2_ras_n),	
	.ddr2_cs_n      (ddr2_cs_n), 	
	.ddr2_cke       (ddr2_cke),  	
	.ddr2_cas_n     (ddr2_cas_n),	
	.ddr2_ba        (ddr2_ba),   	
	.ddr2_addr      (ddr2_addr), 	
	.ddr2_clk       (ddr2_clk),  	
	.ddr2_clk_n     (ddr2_clk_n) 
);  

flash_model flash_model
(
		.A20      (flash_addr[21]),
    .A19      (flash_addr[20]),
    .A18      (flash_addr[19]),
    .A17      (flash_addr[18]),
    .A16      (flash_addr[17]),
    .A15      (flash_addr[16]),
    .A14      (flash_addr[15]),
    .A13      (flash_addr[14]),
    .A12      (flash_addr[13]),
    .A11      (flash_addr[12]),
    .A10      (flash_addr[11]),
    .A9       (flash_addr[10]),
    .A8       (flash_addr[9]),
    .A7       (flash_addr[8]),
    .A6       (flash_addr[7]),
    .A5       (flash_addr[6]),
    .A4       (flash_addr[5]),
    .A3       (flash_addr[4]),
    .A2       (flash_addr[3]),
    .A1       (flash_addr[2]),
    .A0       (flash_addr[1]),

    .DQ15     (flash_addr[0]),
    .DQ14     (),
    .DQ13     (),
    .DQ12     (),
    .DQ11     (),
    .DQ10     (),
    .DQ9      (),
    .DQ8      (),
    .DQ7      (flash_data[7]),
    .DQ6      (flash_data[6]),
    .DQ5      (flash_data[5]),
    .DQ4      (flash_data[4]),
    .DQ3      (flash_data[3]),
    .DQ2      (flash_data[2]),
    .DQ1      (flash_data[1]),
    .DQ0      (flash_data[0]),

   .CENeg    (flash_ce_n),
   .OENeg    (flash_oe_n),
   .WENeg    (flash_we_n),
   .RESETNeg (flash_rst_n),
   .BYTENeg  (1'b0),
   .WPNeg    (1'b1),
   .RY()
);

mt46v4m16 mt46v4m16_1
(
	.Dq(ddr1_data), 
	.Dqs(ddr1_dqs), 
	.Addr(ddr1_addr), 
	.Ba(ddr1_ba), 
	.Clk(ddr1_clk), 
	.Clk_n(ddr1_clk_n), 
	.Cke(ddr1_cke), 
	.Cs_n(ddr1_cs_n), 
	.Ras_n(ddr1_ras_n), 
	.Cas_n(ddr1_cas_n), 
	.We_n(ddr1_we_n), 
	.Dm(ddr1_dqm)
);     

mt46v4m16 mt46v4m16_2
(
	.Dq(ddr2_data), 
	.Dqs(ddr2_dqs), 
	.Addr(ddr2_addr), 
	.Ba(ddr2_ba), 
	.Clk(ddr2_clk), 
	.Clk_n(ddr2_clk_n), 
	.Cke(ddr2_cke), 
	.Cs_n(ddr2_cs_n), 
	.Ras_n(ddr2_ras_n), 
	.Cas_n(ddr2_cas_n), 
	.We_n(ddr2_we_n), 
	.Dm(ddr2_dqm)
);     

// clock and reset
always
begin
   #10 clk = 0;
   #10 clk = 1;
end

initial
begin
   clk = 1'b1;
   rst_n = 1'b1;
   repeat (5) @(posedge clk);
   rst_n = 1'b0;
   repeat (5) @(posedge clk);
   rst_n = 1'b1;
end

//initial
//$dumpvars;
//initial $fsdbDumpvars;

endmodule