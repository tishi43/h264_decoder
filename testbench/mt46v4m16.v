/**************************************************************************************** 
* 
*    File Name:  MT46V4M16.V   
*      Version:  1.0a 
*         Date:  June 7th, 2000 
*        Model:  BUS Functional 
*    Simulator:  Model Technology (PC version 5.3 PE) 
* 
* Dependencies:  None 
* 
*       Author:  Son P. Huynh 
*        Email:  sphuynh@micron.com 
*        Phone:  (208) 368-3825 
*      Company:  Micron Technology, Inc. 
*  Part Number:  MT46V4M16 (1Meg x 16 x 4 Banks) 
* 
*  Description:  Micron 64Mb SDRAM DDR (Double Data Rate) 
* 
*   Limitation:  - Doesn't check for 4096-cycle refresh 
* 
*         Note:  - Set simulator resolution to "ps" accuracy 
*                - Set Debug = 0 to disable $display messages 
*                - Model assume Clk and Clk# crossing at both edge 
* 
*   Disclaimer:  THESE DESIGNS ARE PROVIDED "AS IS" WITH NO WARRANTY  
*                WHATSOEVER AND MICRON SPECIFICALLY DISCLAIMS ANY  
*                IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR 
*                A PARTICULAR PURPOSE, OR AGAINST INFRINGEMENT. 
* 
*                Copyright ? 1998 Micron Semiconductor Products, Inc. 
*                All rights researved 
* 
* Rev   Author          Phone         Date        Changes 
* ----  ----------------------------  ----------  --------------------------------------- 
* 1.0a  Son Huynh       208-368-3825  03/17/2000  - Change some timing from tCK to time 
*       Micron Technology Inc.                    - Add %m to debug information 
* 
* 0.0g  Son Huynh       208-368-3824  11/03/1999  - Fix faulty BST error message 
*                                                 - Fix Read terminate Write immediately 
* 
* 0.0f  Son Huynh       208-368-3825  05/20/1999  - Fix DQS not properly HiZ after precharge 
*       Micron Technology Inc.                      or burst terminate. 
*                                                 - Fix DQS not properly go LOW if Read 
*                                                   immediate after precharge or burst term 
*                                                 - Add detection for interrupting Read 
*                                                   or Write with Auto Precharge.       
* 
* 0.0e  Son Huynh       208-368-3825  03/18/1999  - First Release (derived from 8M8 DDR) 
*       Micron Technology Inc.                    - Simple testbench included 
****************************************************************************************/ 
 
// DO NOT CHANGE THE TIMESCALE 
// MAKE SURE YOUR SIMULATOR USE "PS" RESOLUTION 
`timescale 1ns / 1ps 
 
module mt46v4m16 (Dq, Dqs, Addr, Ba, Clk, Clk_n, Cke, Cs_n, Ras_n, Cas_n, We_n, Dm); 
 	
    parameter addr_bits =      13; 
    parameter data_bits =      16; 
    parameter col_bits  =       10; 
    parameter mem_sizes =  8388607; 
    /*
    parameter addr_bits =      12; 
    parameter data_bits =      16; 
    parameter col_bits  =       8; 
    parameter mem_sizes =  1048575; 
    */ 
    inout     [data_bits - 1 : 0] Dq; 
    inout                 [1 : 0] Dqs; 
    input     [addr_bits - 1 : 0] Addr; 
    input                 [1 : 0] Ba; 
    input                         Clk; 
    input                         Clk_n; 
    input                         Cke; 
    input                         Cs_n; 
    input                         Ras_n; 
    input                         Cas_n; 
    input                         We_n; 
    input                 [1 : 0] Dm; 
 
    reg       [data_bits - 1 : 0] Bank0 [0 : mem_sizes]; 
    reg       [data_bits - 1 : 0] Bank1 [0 : mem_sizes]; 
    reg       [data_bits - 1 : 0] Bank2 [0 : mem_sizes]; 
    reg       [data_bits - 1 : 0] Bank3 [0 : mem_sizes]; 
 
    reg                   [1 : 0] Bank_addr [0 : 6]; 
    reg        [col_bits - 1 : 0] Col_addr [0 : 6]; 
    reg                   [3 : 0] Command [0 : 6]; 
    reg       [addr_bits - 1 : 0] B0_row_addr, B1_row_addr, B2_row_addr, B3_row_addr; 
 
    reg       [addr_bits - 1 : 0] Mode_reg; 
    reg       [data_bits - 1 : 0] Dq_dm, Dq_out; 
    reg        [col_bits - 1 : 0] Col_temp, Burst_counter; 
 
    reg                           Act_b0, Act_b1, Act_b2, Act_b3; 
    reg                           Pc_b0, Pc_b1, Pc_b2, Pc_b3; 
    reg                   [1 : 0] Dqs_int, Dqs_out; 
 
    reg                   [1 : 0] Bank_precharge  [0 : 6];      // Precharge Command Bank 
    reg                           A10_precharge   [0 : 6];      // Addr[10] = 1 (All Banks) 
    reg                           Auto_precharge  [0 : 3];      // RW AutoPrecharge Bank 
    reg                           Read_precharge  [0 : 3];      // R  AutoPrecharge Command 
    reg                           Write_precharge [0 : 3];      // W  AutoPrecharge Command 
    integer                       Count_precharge [0 : 3];      // RW AutoPrecharge Counter 
 
    reg                           Data_in_enable; 
    reg                           Data_out_enable; 
 
    reg                   [3 : 0] Rw_command; 
    reg                   [1 : 0] Bank, Bank_dqs, Previous_bank; 
    reg       [addr_bits - 1 : 0] Row, Row_dqs; 
    reg        [col_bits - 1 : 0] Col, Col_dqs; 
    reg        [col_bits - 1 : 0] Col_brst, Col_brst_dqs; 
 
    reg                           Dll_enable; 
    reg                           CkeZ, Sys_clk; 
 
    // Commands Decode 
    wire      Active_enable   = ~Cs_n & ~Ras_n &  Cas_n &  We_n; 
    wire      Aref_enable     = ~Cs_n & ~Ras_n & ~Cas_n &  We_n; 
    wire      Burst_term      = ~Cs_n &  Ras_n &  Cas_n & ~We_n; 
    wire      Ext_mode_enable = ~Cs_n & ~Ras_n & ~Cas_n & ~We_n &  Ba[0] & ~Ba[1]; 
    wire      Mode_reg_enable = ~Cs_n & ~Ras_n & ~Cas_n & ~We_n & ~Ba[0] & ~Ba[1]; 
    wire      Prech_enable    = ~Cs_n & ~Ras_n &  Cas_n & ~We_n; 
    wire      Read_enable     = ~Cs_n &  Ras_n & ~Cas_n &  We_n; 
    wire      Write_enable    = ~Cs_n &  Ras_n & ~Cas_n & ~We_n; 
 
    // Burst Length Decode 
    wire      Burst_length_2  = ~Mode_reg[2] & ~Mode_reg[1] &  Mode_reg[0]; 
    wire      Burst_length_4  = ~Mode_reg[2] &  Mode_reg[1] & ~Mode_reg[0]; 
    wire      Burst_length_8  = ~Mode_reg[2] &  Mode_reg[1] &  Mode_reg[0]; 
 
    // CAS Latency Decode 
    wire      Cas_latency_15  =  Mode_reg[6] & ~Mode_reg[5] &  Mode_reg[4]; 
    wire      Cas_latency_2   = ~Mode_reg[6] &  Mode_reg[5] & ~Mode_reg[4]; 
    wire      Cas_latency_25  =  Mode_reg[6] &  Mode_reg[5] & ~Mode_reg[4]; 
    wire      Cas_latency_3   = ~Mode_reg[6] &  Mode_reg[5] &  Mode_reg[4]; 
 
    wire      Debug = 0;//1;                                    // Turn on Debug messages 
    wire      Dq_in = Dqs & Data_in_enable;                 // For checking Data-in Setup/Hold time 
 
    assign    Dq  = Dq_out; 
 
    // DQS Buffer 
    assign    Dqs = Dqs_out; 
 
    // DQS Receiver 
    wire      Dqs_rec = Dqs[1] & Dqs[0]; 
 
    //Commands Operation 
    `define   ACT       0 
    `define   NOP       1 
    `define   READ      2 
    `define   READ_A    3 
    `define   WRITE     4 
    `define   WRITE_A   5 
    `define   PRECH     6 
    `define   A_REF     7 
    `define   BST       8 
    `define   LMR       9 
    `define   EMR      10 
 
    // Timing Parameters for -7 (CAS Latency = 2) 
    parameter tMRD =  15; 
    parameter tRC  =  60; 
    parameter tRAS =  45; 
    parameter tRCD =  15; 
    parameter tRRD =  15; 
    parameter tRP  =  15; 
    parameter tWR  =  15; 
    parameter tWTR =   2;       //   1 Clk (2 edges) 
 
    // Timing Check 
    integer   WTR_chk; 
    time      MRD_chk, WR_chk[0 : 3]; 
    time      RC_chk, RRD_chk; 
    time      RAS_chk0, RAS_chk1, RAS_chk2, RAS_chk3; 
    time      RCD_chk0, RCD_chk1, RCD_chk2, RCD_chk3; 
    time      RP_chk, RP_chk0, RP_chk1, RP_chk2, RP_chk3; 
 
    initial begin 
        CkeZ = 1'b0; 
        Sys_clk = 1'b0; 
        {Act_b0, Act_b1, Act_b2, Act_b3} = 4'b0000; 
        {Pc_b0, Pc_b1, Pc_b2, Pc_b3} = 4'b0000; 
        Dqs_out = 2'bzz; 
        Dq_out = {data_bits{1'bz}}; 
        {Data_in_enable, Data_out_enable} = 2'b0; 
        {MRD_chk, WTR_chk, RC_chk, RRD_chk} = 4'b0; 
        {RAS_chk0, RAS_chk1, RAS_chk2, RAS_chk3} = 4'b0; 
        {RCD_chk0, RCD_chk1, RCD_chk2, RCD_chk3} = 4'b0; 
        {RP_chk, RP_chk0, RP_chk1, RP_chk2, RP_chk3} = 4'b0; 
        {WR_chk[0], WR_chk[1], WR_chk[2], WR_chk[3]} = 4'b0; 
        {Auto_precharge[0], Auto_precharge[1], Auto_precharge[2], Auto_precharge[3]} = 4'b0; 
        {Read_precharge[0], Read_precharge[1], Read_precharge[2], Read_precharge[3]} = 4'b0; 
        {Write_precharge[0], Write_precharge[1], Write_precharge[2], Write_precharge[3]} = 4'b0; 
        //$readmemh("bank0.txt", Bank0); 
        //$readmemh("bank1.txt", Bank1); 
        //$readmemh("bank2.txt", Bank2); 
        //$readmemh("bank3.txt", Bank3); 
        $timeformat (-9, 1, " ns", 12); 
    end 
 
    // System Clock 
    always begin 
        @ (posedge Clk) begin 
            Sys_clk = CkeZ; 
            CkeZ = Cke; 
        end 
        @ (negedge Clk) begin 
            Sys_clk = 1'b0; 
        end 
    end 
 
    always @ (Sys_clk) begin 
        // Internal Commamd Pipelined 
        Command[0] = Command[1]; 
        Command[1] = Command[2]; 
        Command[2] = Command[3]; 
        Command[3] = Command[4]; 
        Command[4] = Command[5]; 
        Command[5] = Command[6]; 
        Command[6] = `NOP; 
 
        Col_addr[0] = Col_addr[1]; 
        Col_addr[1] = Col_addr[2]; 
        Col_addr[2] = Col_addr[3]; 
        Col_addr[3] = Col_addr[4]; 
        Col_addr[4] = Col_addr[5]; 
        Col_addr[5] = Col_addr[6]; 
        Col_addr[6] = 0; 
 
        Bank_addr[0] = Bank_addr[1]; 
        Bank_addr[1] = Bank_addr[2]; 
        Bank_addr[2] = Bank_addr[3]; 
        Bank_addr[3] = Bank_addr[4]; 
        Bank_addr[4] = Bank_addr[5]; 
        Bank_addr[5] = Bank_addr[6]; 
        Bank_addr[6] = 2'b0; 
 
        // Precharge Pipeline 
        Bank_precharge[0] = Bank_precharge[1]; 
        Bank_precharge[1] = Bank_precharge[2]; 
        Bank_precharge[2] = Bank_precharge[3]; 
        Bank_precharge[3] = Bank_precharge[4]; 
        Bank_precharge[4] = Bank_precharge[5]; 
        Bank_precharge[5] = Bank_precharge[6]; 
        Bank_precharge[6] = 2'b0; 
 
        A10_precharge[0] = A10_precharge[1]; 
        A10_precharge[1] = A10_precharge[2]; 
        A10_precharge[2] = A10_precharge[3]; 
        A10_precharge[3] = A10_precharge[4]; 
        A10_precharge[4] = A10_precharge[5]; 
        A10_precharge[5] = A10_precharge[6]; 
        A10_precharge[6] = 1'b0; 
 
        // tWTR counter 
        WTR_chk = WTR_chk + 1; 
 
        // Commands Operation decode 
        if (Sys_clk === 1'b1) begin 
            // Read or Write with Auto Precharge Counter 
            if (Auto_precharge[0] === 1'b1) begin 
                Count_precharge[0] = Count_precharge[0] + 1; 
            end 
            if (Auto_precharge[1] === 1'b1) begin 
                Count_precharge[1] = Count_precharge[1] + 1; 
            end 
            if (Auto_precharge[2] === 1'b1) begin 
                Count_precharge[2] = Count_precharge[2] + 1; 
            end 
            if (Auto_precharge[3] === 1'b1) begin 
                Count_precharge[3] = Count_precharge[3] + 1; 
            end 
 
            // Auto Refresh 
            if (Aref_enable === 1'b1) begin 
                if (Debug) $display ("%m : at time %t AREF : Auto Refresh", $time); 
                // Auto Refresh to Auto Refresh 
                if ($time - RC_chk < tRC) begin 
                    $display ("%m : at time %t ERROR: tRC violation during Auto Refresh", $time); 
                end 
                // Precharge to Auto Refresh 
                if ($time - RP_chk < tRP) begin 
                    $display ("%m : at time %t ERROR: tRP violation during Auto Refresh", $time); 
                end 
                // Precharge to Auto Refresh 
                if (Pc_b0 === 1'b0 || Pc_b1 === 1'b0 || Pc_b2 === 1'b0 || Pc_b3 === 1'b0) begin 
                    $display ("%m : at time %t ERROR: All banks must be Precharge before Auto Refresh", $time); 
                end 
                // Record Current tRC time 
                RC_chk = $time; 
            end 
         
            // Extended Mode Register 
            if (Ext_mode_enable === 1'b1) begin 
                if (Pc_b0 === 1'b1 && Pc_b1 === 1'b1 && Pc_b2 === 1'b1 && Pc_b3 === 1'b1) begin 
                    if (Addr[0] === 1'b0) begin 
                        Dll_enable = 1'b1; 
                        if (Debug) $display ("%m : at time %t EMR  : Enable DLL", $time); 
                    end else begin 
                        Dll_enable = 1'b0; 
                        if (Debug) $display ("%m : at time %t EMR  : Disable DLL", $time); 
                    end 
                    // LMR/EMR to LMR/EMR 
                    if ($time - MRD_chk < tMRD) begin 
                        $display ("%m : at time %t ERROR: tMRD violation during Extended Mode Register", $time); 
                    end 
                    // Record current tMRD time 
                    MRD_chk = $time; 
                end else begin 
                    $display ("%m : at time %t ERROR: all banks must be Precharge before Extended Mode Register", $time); 
                end 
            end 
         
            // Load Mode Register 
            if (Mode_reg_enable === 1'b1) begin 
                // Decode DLL, CAS Latency, Burst Type, and Burst Length 
                if (Pc_b0 === 1'b1 && Pc_b1 === 1'b1 && Pc_b2 === 1'b1 && Pc_b3 === 1'b1) begin 
                    Mode_reg = Addr; 
                    if (Debug) begin 
                        $display ("%m : at time %t LMR  : Load Mode Register", $time); 
                        // Operating mode 
                        if (Addr [11 : 7] === 5'b00000) 
                            $display ("                            Normal Operation"); 
                        else if (Addr [11 : 7] === 5'b00010) 
                            $display ("                            Normal Operation / Reset DLL"); 
                        else 
                            $display ("                            Invalid Operating Mode"); 
                        // CAS Latency 
                        if (Addr[6 : 4] === 3'b101) 
                            $display ("                            CAS Latency  = 1.5"); 
                        else if (Addr[6 : 4] === 3'b010) 
                            $display ("                            CAS Latency  = 2"); 
                        else if (Addr[6 : 4] === 3'b110) 
                            $display ("                            CAS Latency  = 2.5"); 
                        else if (Addr[6 : 4] === 3'b011) 
                            $display ("                            CAS Latency  = 3"); 
                        else 
                            $display ("                            CAS Latency not supported"); 
                        // Burst Length 
                        if (Addr[2 : 0] === 3'b001) 
                            $display ("                            Burst Length = 2"); 
                        else if (Addr[2 : 0] === 3'b010) 
                            $display ("                            Burst Length = 4"); 
                        else if (Addr[2 : 0] === 3'b011) 
                            $display ("                            Burst Length = 8"); 
                        else 
                            $display ("                            Burst Length not supported"); 
                        // Burst Type 
                        if (Addr[3] === 1'b0) 
                            $display ("                            Burst Type   = Sequential"); 
                        else 
                            $display ("                            Burst Type   = Interleaved"); 
                    end 
                end else begin 
                    $display ("%m : at time %t ERROR: all banks must be Precharge before Load Mode Register", $time); 
                end 
                // LMR/EMR to LMR/EMR 
                if ($time - MRD_chk < tMRD) begin 
                    $display ("%m : at time %t ERROR: tMRD violation during Load Mode Register", $time); 
                end 
                MRD_chk = $time; 
            end 
 
            // Active Block (Latch Bank Address and Row Address) 
            if (Active_enable === 1'b1) begin 
                if (Ba === 2'b00 && Pc_b0 === 1'b1) begin 
                    {Act_b0, Pc_b0} = 2'b10; 
                    B0_row_addr = Addr [addr_bits - 1 : 0]; 
                    RCD_chk0 = $time; 
                    RAS_chk0 = $time; 
                    if (Debug) $display ("%m : at time %t ACT  : Bank = 0 Row = %d",$time, Addr); 
                    // Precharge to Activate Bank 0 
                    if ($time - RP_chk0 < tRP) begin 
                        $display ("%m : at time %t ERROR: tRP violation during Activate bank 0", $time); 
                    end 
                end else if (Ba === 2'b01 && Pc_b1 === 1'b1) begin 
                    {Act_b1, Pc_b1} = 2'b10; 
                    B1_row_addr = Addr [addr_bits - 1 : 0]; 
                    RCD_chk1 = $time; 
                    RAS_chk1 = $time; 
                    if (Debug) $display ("%m : at time %t ACT  : Bank = 1 Row = %d",$time, Addr); 
                    // Precharge to Activate Bank 1 
                    if ($time - RP_chk1 < tRP) begin 
                        $display ("%m : at time %t ERROR: tRP violation during Activate bank 1", $time); 
                    end 
                end else if (Ba === 2'b10 && Pc_b2 === 1'b1) begin 
                    {Act_b2, Pc_b2} = 2'b10; 
                    B2_row_addr = Addr [addr_bits - 1 : 0]; 
                    RCD_chk2 = $time; 
                    RAS_chk2 = $time; 
                    if (Debug) $display ("%m : at time %t ACT  : Bank = 2 Row = %d",$time, Addr); 
                    // Precharge to Activate Bank 2 
                    if ($time - RP_chk2 < tRP) begin 
                        $display ("%m : at time $t ERROR: tRP violation during Activate bank 2", $time); 
                    end 
                end else if (Ba === 2'b11 && Pc_b3 === 1'b1) begin 
                    {Act_b3, Pc_b3} = 2'b10; 
                    B3_row_addr = Addr [addr_bits - 1 : 0]; 
                    RCD_chk3 = $time; 
                    RAS_chk3 = $time; 
                    if (Debug) $display ("%m : at time %t ACT  : Bank = 3 Row = %d",$time, Addr); 
                    // Precharge to Activate Bank 3 
                    if ($time - RP_chk3 < tRP) begin 
                        $display ("%m : at time $t ERROR: tRP violation during Activate bank 3", $time); 
                    end 
                end else if (Ba === 2'b00 && Pc_b0 === 1'b0) begin 
                    $display ("%m : at time %t ERROR: Bank 0 is not Precharged.", $time); 
                end else if (Ba === 2'b01 && Pc_b1 === 1'b0) begin 
                    $display ("%m : at time %t ERROR: Bank 1 is not Precharged.", $time); 
                end else if (Ba === 2'b10 && Pc_b2 === 1'b0) begin 
                    $display ("%m : at time %t ERROR: Bank 2 is not Precharged.", $time); 
                end else if (Ba === 2'b11 && Pc_b3 === 1'b0) begin 
                    $display ("%m : at time %t ERROR: Bank 3 is not Precharged.", $time); 
                end 
                // Activate Bank A to Activate Bank B 
                if ((Previous_bank != Ba) && ($time - RRD_chk < tRRD)) begin 
                    $display ("%m : at time %t ERROR: tRRD violation during Activate bank = %d", $time, Ba); 
                end 
                // AutoRefresh to Activate 
                if ($time - RC_chk < tRC) begin 
                    $display ("%m : at time %t ERROR: tRC violation during Activate bank %d", $time, Ba); 
                end 
                // Record variable for checking violation 
                RRD_chk = $time; 
                Previous_bank = Ba; 
            end 
         
            // Precharge Block 
            if (Prech_enable === 1'b1) begin 
                if (Addr[10] === 1'b1) begin 
                    {Pc_b0, Pc_b1, Pc_b2, Pc_b3} = 4'b1111; 
                    {Act_b0, Act_b1, Act_b2, Act_b3} = 4'b0000; 
                    RP_chk0 = $time; 
                    RP_chk1 = $time; 
                    RP_chk2 = $time; 
                    RP_chk3 = $time; 
                    if (Debug) $display ("%m : at time %t PRE  : Bank = ALL",$time); 
                    // Activate to Precharge all banks 
                    if (($time - RAS_chk0 < tRAS) || ($time - RAS_chk1 < tRAS) || 
                        ($time - RAS_chk2 < tRAS) || ($time - RAS_chk3 < tRAS)) begin 
                        $display ("%m : at time %t ERROR: tRAS violation during Precharge all bank", $time); 
                    end 
                    // tWR violation check for Write 
                    if (($time - WR_chk[0] < tWR) || ($time - WR_chk[1] < tWR) || 
                        ($time - WR_chk[2] < tWR) || ($time - WR_chk[3] < tWR)) begin 
                        $display ("%m : at time %t ERROR: tWR violation during Precharge all bank", $time); 
                    end 
                end else if (Addr[10] === 1'b0) begin 
                    if (Ba === 2'b00) begin 
                        {Pc_b0, Act_b0} = 2'b10; 
                        RP_chk0 = $time; 
                        if (Debug) $display ("%m : at time %t PRE  : Bank = 0",$time); 
                        // Activate to Precharge Bank 0 
                        if ($time - RAS_chk0 < tRAS) begin 
                            $display ("%m : at time %t ERROR: tRAS violation during Precharge bank 0", $time); 
                        end 
                    end else if (Ba === 2'b01) begin 
                        {Pc_b1, Act_b1} = 2'b10; 
                        RP_chk1 = $time; 
                        if (Debug) $display ("%m : at time %t PRE  : Bank = 1",$time); 
                        // Activate to Precharge Bank 1 
                        if ($time - RAS_chk1 < tRAS) begin 
                            $display ("%m : at time %t ERROR: tRAS violation during Precharge bank 1", $time); 
                        end 
                    end else if (Ba === 2'b10) begin 
                        {Pc_b2, Act_b2} = 2'b10; 
                        RP_chk2 = $time; 
                        if (Debug) $display ("%m : at time %t PRE  : Bank = 2",$time); 
                        // Activate to Precharge Bank 2 
                        if ($time - RAS_chk2 < tRAS) begin 
                            $display ("%m : at time %t ERROR: tRAS violation during Precharge bank 2", $time); 
                        end 
                    end else if (Ba === 2'b11) begin 
                        {Pc_b3, Act_b3} = 2'b10; 
                        RP_chk3 = $time; 
                        if (Debug) $display ("%m : at time %t PRE  : Bank = 3",$time); 
                        // Activate to Precharge Bank 3 
                        if ($time - RAS_chk3 < tRAS) begin 
                            $display ("%m : at time %t ERROR: tRAS violation during Precharge bank 3", $time); 
                        end 
                    end 
                    // tWR violation check for Write 
                    if ($time - WR_chk[Ba] < tWR) begin 
                        $display ("%m : at time %t ERROR: tWR violation during Precharge", $time); 
                    end 
                end 
 
                // Terminate a WRITE immediately (if same bank or all banks) 
                if (Data_in_enable === 1'b1 && (Bank === Ba || Addr[10] === 1'b1)) begin 
                    Data_in_enable = 1'b0; 
                end 
                 
                // Precharge Command Pipeline for READ 
                if (Cas_latency_15 === 1'b1) begin 
                    Command[3] = `PRECH; 
                    Bank_precharge[3] = Ba; 
                    A10_precharge[3] = Addr[10]; 
                end else if (Cas_latency_2 === 1'b1) begin 
                    Command[4] = `PRECH; 
                    Bank_precharge[4] = Ba; 
                    A10_precharge[4] = Addr[10]; 
                end else if (Cas_latency_25 === 1'b1) begin 
                    Command[5] = `PRECH; 
                    Bank_precharge[5] = Ba; 
                    A10_precharge[5] = Addr[10]; 
                end else if (Cas_latency_3 === 1'b1) begin 
                    Command[6] = `PRECH; 
                    Bank_precharge[6] = Ba; 
                    A10_precharge[6] = Addr[10]; 
                end 
                // Record Current tRP time 
                RP_chk = $time; 
            end 
         
            // Burst terminate 
            if (Burst_term === 1'b1) begin 
                if (Cas_latency_15 === 1'b1) begin 
                    Command[3] = `BST; 
                end else if (Cas_latency_2 === 1'b1) begin 
                    Command[4] = `BST; 
                end else if (Cas_latency_25 === 1'b1) begin 
                    Command[5] = `BST; 
                end else if (Cas_latency_3 === 1'b1) begin 
                    Command[6] = `BST; 
                end 
                if (Debug) $display ("%m : at time %t BST  : Burst Terminate",$time); 
                if ((Data_in_enable === 1'b1 && Write_precharge[Bank] === 1'b1) || (Data_out_enable === 1'b1 && Read_precharge[Bank] === 1'b1)) begin 
                    if (Debug) $display ("%m : at time %t ERROR: It's illegal to burst terminate a Write or Read with Auto Precharge", $time); 
                end 
            end 
             
            // Read, Write, Column Latch 
            if (Read_enable === 1'b1 || Write_enable === 1'b1) begin 
                // Check to see if bank is open (ACT) 
                if ((Ba === 2'b00 && Pc_b0 === 1'b1) || (Ba === 2'b01 && Pc_b1 === 1'b1) || 
                    (Ba === 2'b10 && Pc_b2 === 1'b1) || (Ba === 2'b11 && Pc_b3 === 1'b1)) begin 
                    $display("%m : at time %t ERROR: Cannot Read or Write - Bank %b is not Activated", $time, Ba); 
                end 
 
                // Activate to Read or Write 
                if ((Ba === 2'b00) && ($time - RCD_chk0 < tRCD)) 
                    $display("%m : at time %t ERROR: tRCD violation during Read or Write to Bank 0", $time); 
                if ((Ba === 2'b01) && ($time - RCD_chk1 < tRCD)) 
                    $display("%m : at time %t ERROR: tRCD violation during Read or Write to Bank 1", $time); 
                if ((Ba === 2'b10) && ($time - RCD_chk2 < tRCD)) 
                    $display("%m : at time %t ERROR: tRCD violation during Read or Write to Bank 2", $time); 
                if ((Ba === 2'b11) && ($time - RCD_chk3 < tRCD)) 
                    $display("%m : at time %t ERROR: tRCD violation during Read or Write to Bank 3", $time); 
 
                // Read Command 
                if (Read_enable === 1'b1) begin 
                    // Read interrupt a Read/Write with Auto Precharge 
                    if ((Auto_precharge[0] === 1'b1 && (Read_precharge[0] === 1'b1 || Write_precharge[0] === 1'b1) && Ba === 2'b00) || 
                        (Auto_precharge[1] === 1'b1 && (Read_precharge[1] === 1'b1 || Write_precharge[1] === 1'b1) && Ba === 2'b01) || 
                        (Auto_precharge[2] === 1'b1 && (Read_precharge[2] === 1'b1 || Write_precharge[2] === 1'b1) && Ba === 2'b10) || 
                        (Auto_precharge[3] === 1'b1 && (Read_precharge[3] === 1'b1 || Write_precharge[3] === 1'b1) && Ba === 2'b11)) begin 
                        $display ("%m : at time %t ERROR: It's illegal to interrupt a Read or Write with Auto Precharge", $time); 
                    end 
                    // CAS Latency pipeline 
                    if (Cas_latency_15 === 1'b1) begin 
                        if (Addr[10] === 1'b1) begin 
                            Command[3] = `READ_A; 
                        end else begin 
                            Command[3] = `READ; 
                        end 
                        Col_addr[3] = Addr; 
                        Bank_addr[3] = Ba; 
                    end else if (Cas_latency_2 === 1'b1) begin 
                        if (Addr[10] === 1'b1) begin 
                            Command[4] = `READ_A; 
                        end else begin 
                            Command[4] = `READ; 
                        end 
                        Col_addr[4] = Addr; 
                        Bank_addr[4] = Ba; 
                    end else if (Cas_latency_25 === 1'b1) begin 
                        if (Addr[10] === 1'b1) begin 
                            Command[5] = `READ_A; 
                        end else begin 
                            Command[5] = `READ; 
                        end 
                        Col_addr[5] = Addr; 
                        Bank_addr[5] = Ba; 
                    end else if (Cas_latency_3 === 1'b1) begin 
                        if (Addr[10] === 1'b1) begin 
                            Command[6] = `READ_A; 
                        end else begin 
                            Command[6] = `READ; 
                        end 
                        Col_addr[6] = Addr; 
                        Bank_addr[6] = Ba; 
                    end 
                    // tWTR check (Write to Read) 
                    if (WTR_chk < tWTR) begin 
                        $display ("%m : at time %t ERROR: tWTR violation during Read", $time); 
                    end 
                    // Terminate a Write 
                    if (Data_in_enable === 1'b1) begin 
                        Data_in_enable = 1'b0; 
                    end 
                // Write Command 
                end else if (Write_enable === 1'b1) begin 
                    // Write interrupt a Read/Write with Auto Precharge 
                    if ((Auto_precharge[0] === 1'b1 && (Read_precharge[0] === 1'b1 || Write_precharge[0] === 1'b1) && Ba === 2'b00) || 
                        (Auto_precharge[1] === 1'b1 && (Read_precharge[1] === 1'b1 || Write_precharge[1] === 1'b1) && Ba === 2'b01) || 
                        (Auto_precharge[2] === 1'b1 && (Read_precharge[2] === 1'b1 || Write_precharge[2] === 1'b1) && Ba === 2'b10) || 
                        (Auto_precharge[3] === 1'b1 && (Read_precharge[3] === 1'b1 || Write_precharge[3] === 1'b1) && Ba === 2'b11)) begin 
                        $display ("%m : at time %t ERROR: It's illegal to interrupt a Read or Write with Auto Precharge", $time); 
                    end 
                    // Write Latency pipeline 
                    if (Addr[10] === 1'b1) begin 
                        Command[2] = `WRITE_A; 
                    end else begin 
                        Command[2] = `WRITE; 
                    end 
                    Col_addr[2] = Addr; 
                    Bank_addr[2] = Ba; 
                end 
 
                // Read or Write with Auto Precharge 
                if (Addr[10] === 1'b1) begin 
                    Auto_precharge [Ba]= 1'b1; 
                    Count_precharge [Ba]= 0; 
                    if (Read_enable === 1'b1) begin 
                        Read_precharge[Ba] = 1'b1; 
                    end else if (Write_enable === 1'b1) begin 
                        Write_precharge[Ba] = 1'b1; 
                    end 
                end 
            end 
 
            //  Read with Auto Precharge Calculation 
            //      The device start internal precharge: 
            //          1.  BL/2 cycles after command 
            //          2.  Meet minimum tRAS requirement 
            if ((Auto_precharge[0] === 1'b1) && (Read_precharge[0] === 1'b1) && ($time - RAS_chk0 >= tRAS)) begin 
                if ((Burst_length_2 === 1'b1 && Count_precharge[0] >= 1) ||  
                    (Burst_length_4 === 1'b1 && Count_precharge[0] >= 2) || 
                    (Burst_length_8 === 1'b1 && Count_precharge[0] >= 4)) begin 
                    Pc_b0 = 1'b1; 
                    Act_b0 = 1'b0; 
                    RP_chk0 = $time; 
                    Auto_precharge[0] = 1'b0; 
                    Read_precharge[0] = 1'b0; 
                    if (Debug) $display ("%m : at time %t NOTE : Start Internal Auto Precharge for Bank 0", $time); 
                end 
            end 
            if ((Auto_precharge[1] === 1'b1) && (Read_precharge[1] === 1'b1) && ($time - RAS_chk1 >= tRAS)) begin 
                if ((Burst_length_2 === 1'b1 && Count_precharge[1] >= 1) ||  
                    (Burst_length_4 === 1'b1 && Count_precharge[1] >= 2) || 
                    (Burst_length_8 === 1'b1 && Count_precharge[1] >= 4)) begin 
                    Pc_b1 = 1'b1; 
                    Act_b1 = 1'b0; 
                    RP_chk1 = $time; 
                    Auto_precharge[1] = 1'b0; 
                    Read_precharge[1] = 1'b0; 
                    if (Debug) $display ("%m : at time %t NOTE : Start Internal Auto Precharge for Bank 1", $time); 
                end 
            end 
            if ((Auto_precharge[2] === 1'b1) && (Read_precharge[2] === 1'b1) && ($time - RAS_chk2 >= tRAS)) begin 
                if ((Burst_length_2 === 1'b1 && Count_precharge[2] >= 1) ||  
                    (Burst_length_4 === 1'b1 && Count_precharge[2] >= 2) || 
                    (Burst_length_8 === 1'b1 && Count_precharge[2] >= 4)) begin 
                    Pc_b2 = 1'b1; 
                    Act_b2 = 1'b0; 
                    RP_chk2 = $time; 
                    Auto_precharge[2] = 1'b0; 
                    Read_precharge[2] = 1'b0; 
                    if (Debug) $display ("%m : at time %t NOTE : Start Internal Auto Precharge for Bank 2", $time); 
                end 
            end 
            if ((Auto_precharge[3] === 1'b1) && (Read_precharge[3] === 1'b1) && ($time - RAS_chk3 >= tRAS)) begin 
                if ((Burst_length_2 === 1'b1 && Count_precharge[3] >= 1) ||  
                    (Burst_length_4 === 1'b1 && Count_precharge[3] >= 2) || 
                    (Burst_length_8 === 1'b1 && Count_precharge[3] >= 4)) begin 
                    Pc_b3 = 1'b1; 
                    Act_b3 = 1'b0; 
                    RP_chk3 = $time; 
                    Auto_precharge[3] = 1'b0; 
                    Read_precharge[3] = 1'b0; 
                    if (Debug) $display ("%m : at time %t NOTE : Start Internal Auto Precharge for Bank 3", $time); 
                end 
            end 
 
            //  Write with Auto Precharge Calculation 
            //      The device start internal precharge 
            //          1.  Two Clock after last burst 
            //          2.  Meet minimum tRAS requirement 
            if ((Auto_precharge[0] === 1'b1) && (Write_precharge[0] === 1'b1) && ($time - RAS_chk0 >= tRAS)) begin 
                if ((Burst_length_2 === 1'b1 && Count_precharge[0] >= 4) ||  
                    (Burst_length_4 === 1'b1 && Count_precharge[0] >= 5) || 
                    (Burst_length_8 === 1'b1 && Count_precharge[0] >= 7)) begin 
                    Pc_b0 = 1'b1; 
                    Act_b0 = 1'b0; 
                    RP_chk0 = $time; 
                    Auto_precharge[0] = 1'b0; 
                    Write_precharge[0] = 1'b0; 
                    if (Debug) $display ("%m : at time %t NOTE : Start Internal Auto Precharge for Bank 0", $time); 
                end 
            end 
            if ((Auto_precharge[1] === 1'b1) && (Write_precharge[1] === 1'b1) && ($time - RAS_chk1 >= tRAS)) begin 
                if ((Burst_length_2 === 1'b1 && Count_precharge[1] >= 4) ||  
                    (Burst_length_4 === 1'b1 && Count_precharge[1] >= 5) || 
                    (Burst_length_8 === 1'b1 && Count_precharge[1] >= 7)) begin 
                    Pc_b1 = 1'b1; 
                    Act_b1 = 1'b0; 
                    RP_chk1 = $time; 
                    Auto_precharge[1] = 1'b0; 
                    Write_precharge[1] = 1'b0; 
                    if (Debug) $display ("%m : at time %t NOTE : Start Internal Auto Precharge for Bank 1", $time); 
                end 
            end 
            if ((Auto_precharge[2] === 1'b1) && (Write_precharge[2] === 1'b1) && ($time - RAS_chk2 >= tRAS)) begin 
                if ((Burst_length_2 === 1'b1 && Count_precharge[2] >= 4) ||  
                    (Burst_length_4 === 1'b1 && Count_precharge[2] >= 5) || 
                    (Burst_length_8 === 1'b1 && Count_precharge[2] >= 7)) begin 
                    Pc_b2 = 1'b1; 
                    Act_b2 = 1'b0; 
                    RP_chk2 = $time; 
                    Auto_precharge[2] = 1'b0; 
                    Write_precharge[2] = 1'b0; 
                    if (Debug) $display ("%m : at time %t NOTE : Start Internal Auto Precharge for Bank 2", $time); 
                end 
            end 
            if ((Auto_precharge[3] === 1'b1) && (Write_precharge[3] === 1'b1) && ($time - RAS_chk3 >= tRAS)) begin 
                if ((Burst_length_2 === 1'b1 && Count_precharge[3] >= 4) ||  
                    (Burst_length_4 === 1'b1 && Count_precharge[3] >= 5) || 
                    (Burst_length_8 === 1'b1 && Count_precharge[3] >= 7)) begin 
                    Pc_b3 = 1'b1; 
                    Act_b3 = 1'b0; 
                    RP_chk3 = $time; 
                    Auto_precharge[3] = 1'b0; 
                    Write_precharge[3] = 1'b0; 
                    if (Debug) $display ("%m : at time %t NOTE : Start Internal Auto Precharge for Bank 3", $time); 
                end 
            end 
        end 
 
        // Internal Precharge or Bst 
        if (Command[0] === `PRECH) begin                            // Precharge terminate a read with same bank or all banks 
            if (Bank_precharge[0] === Bank || A10_precharge[0] === 1'b1) begin 
                if (Data_out_enable === 1'b1) begin 
                    Dqs_out = 2'bzz; 
                    Data_out_enable = 1'b0; 
                end 
            end 
        end else if (Command[0] === `BST) begin                     // BST terminate a read to current bank 
            if (Data_out_enable === 1'b1) begin 
                Dqs_out = 2'bzz; 
                Data_out_enable = 1'b0; 
            end 
        end 
 
        #0.001;                                                     // Delay for Dqs to go HiZ then accept new internal Dqs 
 
        // Dqs Generator 
        if (Data_out_enable === 1'b1) begin 
            Dqs_int = 2'b00; 
            if (Dqs_out === 2'b00) begin 
                Dqs_out = 2'b11; 
            end else if (Dqs_out === 2'b11) begin 
                Dqs_out = 2'b00; 
            end else begin 
                Dqs_out = 2'b00; 
            end 
        end else if (Data_out_enable === 1'b0 && Dqs_int === 2'b00) begin 
            Dqs_out = 2'bzz; 
            Dq_out = {data_bits{1'bz}}; 
        end 
 
        #0.001;                                                     // Delay for Dqs to go HiZ then accept new Read or Write 
 
        // Internal Dqs 
        if (Command[2] === `READ || Command[2] === `READ_A) begin 
            if ((Dqs_out !== 2'b00 || Dqs_out !== 2'b11) && (Data_out_enable === 1'b0)) begin 
                Dqs_out = 2'b00; 
                Dqs_int = 2'b11; 
            end 
        end else if (Command[2] === `WRITE || Command[2] === `WRITE_A) begin 
            Dqs_out = 2'bzz; 
        end 
 
        // Detect Read or Write command (work with any DSS) 
        Rw_command = Command[1]; 
    end 
 
    // Latch address for Read or Write 
    task Latch_address; 
        begin 
            Bank_dqs = Bank_addr[1]; 
            Col_dqs  = Col_addr[1]; 
            Col_brst_dqs = Col_addr[1]; 
            if (Bank_addr[1] === 2'b00) begin 
                Row_dqs = B0_row_addr; 
            end else if (Bank_addr[1] === 2'b01) begin 
                Row_dqs = B1_row_addr; 
            end else if (Bank_addr[1] === 2'b10) begin 
                Row_dqs = B2_row_addr; 
            end else if (Bank_addr[1] === 2'b11) begin 
                Row_dqs = B3_row_addr; 
            end 
        end 
    endtask 
 
    // Read or Write command waiting for posedge DQS 
    always @ (Rw_command) begin 
        if (Rw_command === `READ || Rw_command === `READ_A) begin 
            Latch_address; 
            @ (Sys_clk); 
            Bank = Bank_dqs; 
            Row = Row_dqs; 
            Col = Col_dqs; 
            Col_brst = Col_brst_dqs; 
            Burst_counter = 0; 
            Data_in_enable = 1'b0; 
            Data_out_enable = 1'b1; 
        end else if (Rw_command === `WRITE || Rw_command === `WRITE_A) begin 
            Latch_address; 
            @ (posedge Dqs); 
            Bank = Bank_dqs; 
            Row = Row_dqs; 
            Col = Col_dqs; 
            Col_brst = Col_brst_dqs; 
            Burst_counter = 0; 
            Data_in_enable = 1'b1; 
            Data_out_enable = 1'b0; 
        end 
    end 
 
    // DQS buffer (Driver/Receiver) 
    always @ (Dqs_rec) begin 
        #0.001;                                                     // Delay to avoid race condition with Rw_command 
        if (Data_in_enable === 1'b1) begin                          // Writing Data to Memory 
            // Array buffer 
            if (Bank == 2'b00) Dq_dm [data_bits - 1 : 0] = Bank0 [{Row, Col}]; 
            if (Bank == 2'b01) Dq_dm [data_bits - 1 : 0] = Bank1 [{Row, Col}]; 
            if (Bank == 2'b10) Dq_dm [data_bits - 1 : 0] = Bank2 [{Row, Col}]; 
            if (Bank == 2'b11) Dq_dm [data_bits - 1 : 0] = Bank3 [{Row, Col}]; 
            // Dqm operation 
            if (Dm[0] == 1'b0) Dq_dm [ 7 : 0] = Dq [ 7 : 0]; 
            if (Dm[1] == 1'b0) Dq_dm [15 : 8] = Dq [15 : 8]; 
            // Write to memory 
            if (Bank == 2'b00) Bank0 [{Row, Col}] = Dq_dm [data_bits - 1 : 0]; 
            if (Bank == 2'b01) Bank1 [{Row, Col}] = Dq_dm [data_bits - 1 : 0]; 
            if (Bank == 2'b10) Bank2 [{Row, Col}] = Dq_dm [data_bits - 1 : 0]; 
            if (Bank == 2'b11) Bank3 [{Row, Col}] = Dq_dm [data_bits - 1 : 0]; 
            // Output result 
            if (Dm == 2'b11) begin 
                if (Debug) $display("%m : at time %t WRITE: Bank = %d Row = %d, Col = %d, Data = Hi-Z due to DM", $time, Bank, Row, Col); 
            end else begin 
                if (Debug) $display("%m : at time %t WRITE: Bank = %d Row = %d, Col = %d, Data = %d, Dm = %b", $time, Bank, Row, Col, Dq_dm, Dm); 
                // Record tWR time 
                WTR_chk = 0; 
                WR_chk [Bank] = $time;                              // Reset tWR 
            end 
            // Advance burst counter subroutine 
            Burst; 
        end else if (Data_out_enable === 1'b1) begin                // Reading Data from Memory 
            if (Bank === 2'b00) begin 
                Dq_out [data_bits - 1 : 0] = Bank0[{Row, Col}]; 
            end else if (Bank === 2'b01) begin 
                Dq_out [data_bits - 1 : 0] = Bank1[{Row, Col}]; 
            end else if (Bank === 2'b10) begin 
                Dq_out [data_bits - 1 : 0] = Bank2[{Row, Col}]; 
            end else if (Bank === 2'b11) begin 
                Dq_out [data_bits - 1 : 0] = Bank3[{Row, Col}]; 
            end 
            if (Debug) $display("%m : at time %t READ : Bank = %d Row = %d, Col = %d, Data = %d", $time, Bank, Row, Col, Dq_out); 
            Burst; 
        end else begin 
            Dq_out [data_bits - 1 : 0] = {data_bits{1'bz}}; 
        end 
    end 
 
    task Burst; 
        begin 
            // Advance Burst Counter 
            Burst_counter = Burst_counter + 1; 
 
            // Burst Type 
            if (Mode_reg[3] === 1'b0) begin                         // Sequential Burst 
                Col_temp = Col + 1; 
            end else if (Mode_reg[3] === 1'b1) begin                // Interleaved Burst 
                Col_temp[2] =  Burst_counter[2] ^  Col_brst[2]; 
                Col_temp[1] =  Burst_counter[1] ^  Col_brst[1]; 
                Col_temp[0] =  Burst_counter[0] ^  Col_brst[0]; 
            end 
            // Burst Length 
            if (Burst_length_2) begin                               // Burst Length = 2 
                Col [0] = Col_temp [0]; 
            end else if (Burst_length_4) begin                      // Burst Length = 4 
                Col [1 : 0] = Col_temp [1 : 0]; 
            end else if (Burst_length_8) begin                      // Burst Length = 8 
                Col [2 : 0] = Col_temp [2 : 0]; 
            end else begin                                          // Burst Length = FULL 
                Col = Col_temp; 
            end 
            // Data Counter 
            if (Burst_length_2 === 1'b1) begin 
                if (Burst_counter >= 2) begin 
                    Data_in_enable = 1'b0; 
                    Data_out_enable = 1'b0; 
                end 
            end else if (Burst_length_4 === 1'b1) begin 
                if (Burst_counter >= 4) begin 
                    Data_in_enable = 1'b0; 
                    Data_out_enable = 1'b0; 
                end 
            end else if (Burst_length_8 === 1'b1) begin 
                if (Burst_counter >= 8) begin 
                    Data_in_enable = 1'b0; 
                    Data_out_enable = 1'b0; 
                end 
            end 
        end 
    endtask 
 
    // Timing Check for -7 (CAS Latency = 2) 
    specify 
        specparam 
                    tCK =  7.5,                                    // Clock Cycle Time 
                    tCH =  0.45*tCK,                                // Clock High-Level Width 
                    tCL =  0.45*tCK,                                // Clock Low-Level Width 
                    tDH =  0.50,                                    // Data-in Hold Time 
                    tDS =  0.50,                                    // Data-in Setup Time 
                    tIH =  0.90,                                    // Input Hold Time 
                    tIS =  0.90;                                    // Input Setup Time 
        $width    (posedge Clk,          tCH     ); 
        $width    (negedge Clk,          tCL     ); 
        $period   (negedge Clk,          tCK     ); 
        $period   (posedge Clk,          tCK     ); 
        $setuphold(posedge Clk,   Cke,   tIS, tIH); 
        $setuphold(posedge Clk,   Cs_n,  tIS, tIH); 
        $setuphold(posedge Clk,   Cas_n, tIS, tIH); 
        $setuphold(posedge Clk,   Ras_n, tIS, tIH); 
        $setuphold(posedge Clk,   We_n,  tIS, tIH); 
        $setuphold(posedge Clk,   Addr,  tIS, tIH); 
        $setuphold(posedge Clk,   Ba,    tIS, tIH); 
        $setuphold(posedge Dq_in, Dq,    tDS, tDH); 
        $setuphold(negedge Dq_in, Dq,    tDS, tDH); 
        $setuphold(posedge Dq_in, Dm,    tDS, tDH); 
        $setuphold(negedge Dq_in, Dm,    tDS, tDH); 
    endspecify 
 
endmodule 
