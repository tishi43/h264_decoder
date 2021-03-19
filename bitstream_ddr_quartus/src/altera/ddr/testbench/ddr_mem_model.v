//Legal Notice: (C)2013 Altera Corporation. All rights reserved.  Your
//use of Altera Corporation's design tools, logic functions and other
//software and tools, and its AMPP partner logic functions, and any
//output files any of the foregoing (including device programming or
//simulation files), and any associated documentation or information are
//expressly subject to the terms and conditions of the Altera Program
//License Subscription Agreement or other applicable license agreement,
//including, without limitation, that your use is for the sole purpose
//of programming logic devices manufactured by Altera and sold by Altera
//or its authorized distributors.  Please refer to the applicable
//agreement for further details.

// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

//Default depth for this memory model is 2048, do these when
//changing the depth.
//1)Set ARRAY_DEPTH generic/parameter from 2048 to new depth.
//2)Change mem_array depth from 2047 to (new depth - 1).
//3)VHDL only, don't forget the generic in component declaration
module ddr_mem_model_ram_module (
                                  // inputs:
                                   data,
                                   rdaddress,
                                   wraddress,
                                   wrclock,
                                   wren,

                                  // outputs:
                                   q
                                )
;

  parameter ARRAY_DEPTH = 2048;


  output  [ 31: 0] q;
  input   [ 31: 0] data;
  input   [ 22: 0] rdaddress;
  input   [ 22: 0] wraddress;
  input            wrclock;
  input            wren;

  wire    [ 31: 0] aq;
  reg     [ 55: 0] mem_array [2047: 0];
  wire    [ 31: 0] q;
  assign aq = mem_array[0][31:0];

//synthesis translate_off
//////////////// SIMULATION-ONLY CONTENTS

  reg     [  32 - 1: 0] out;

    integer i;
    reg found_valid_data;
    reg data_written;

    initial
    begin
        for (i = 0; i < ARRAY_DEPTH; i = i + 1)
            mem_array[i][0] <= 1'b0;
        data_written <= 1'b0;
    end

    always @(rdaddress)
    begin
        found_valid_data <= 1'b0;
        for (i = 0; i < ARRAY_DEPTH; i = i + 1)
        begin
            if (rdaddress == mem_array[i][56 - 1:56 - 23] && mem_array[i][0])
            begin
                out = mem_array[i][56 - 23 - 1:56 - 23 - 32];
                found_valid_data = 1'b1;
            end
        end
        if (!found_valid_data)
            out = 32'dX;
    end

    always @(posedge wrclock)
    if (wren)
    begin
        data_written <= 1'b0;
        for (i = 0; i < ARRAY_DEPTH; i = i + 1)
        begin
            if (wraddress == mem_array[i][56 - 1:56 - 23] && !data_written)
            begin
                mem_array[i][56 - 23 - 1:56 - 23 - 32] <= data;
                mem_array[i][0] <= 1'b1;
                data_written = 1'b1;
            end
            else if (!mem_array[i][0] && !data_written)
            begin
                mem_array[i] <= {wraddress,data,1'b1};
                data_written = 1'b1;
            end
        end
        if (!data_written)
        begin
            $write($time);
            $write(" --- Data could not be written, increase array depth or use full memory model --- ");
            $stop;
        end
    end

    assign q = out;

//////////////// END SIMULATION-ONLY CONTENTS

//synthesis translate_on

endmodule



// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module ddr_mem_model (
                       // inputs:
                        mem_addr,
                        mem_ba,
                        mem_cas_n,
                        mem_cke,
                        mem_clk,
                        mem_clk_n,
                        mem_cs_n,
                        mem_dm,
                        mem_ras_n,
                        mem_we_n,

                       // outputs:
                        global_reset_n,
                        mem_dq,
                        mem_dqs
                     )
;

  output           global_reset_n;
  inout   [ 15: 0] mem_dq;
  inout   [  1: 0] mem_dqs;
  input   [ 12: 0] mem_addr;
  input   [  1: 0] mem_ba;
  input            mem_cas_n;
  input            mem_cke;
  input            mem_clk;
  input            mem_clk_n;
  input            mem_cs_n;
  input   [  1: 0] mem_dm;
  input            mem_ras_n;
  input            mem_we_n;

  wire    [ 23: 0] CODE;
  wire    [ 12: 0] a;
  wire    [  7: 0] addr_col;
  wire    [  1: 0] ba;
  reg     [  2: 0] burstlength;
  reg              burstmode;
  wire             cas_n;
  wire             cke;
  wire             clk;
  wire    [  2: 0] cmd_code;
  wire             cs_n;
  wire    [  1: 0] current_row;
  wire    [  1: 0] dm;
  reg     [  3: 0] dm_captured;
  reg     [ 31: 0] dq_captured;
  wire    [ 15: 0] dq_temp;
  wire             dq_valid;
  wire    [  1: 0] dqs_temp;
  wire             dqs_valid;
  reg              dqs_valid_temp;
  reg     [ 15: 0] first_half_dq;
  wire             global_reset_n;
  wire    [ 31: 0] mem_bytes;
  wire    [ 15: 0] mem_dq;
  wire    [  1: 0] mem_dqs;
  reg     [ 12: 0] open_rows [  3: 0];
  wire             ras_n;
  reg     [ 22: 0] rd_addr_pipe_0;
  reg     [ 22: 0] rd_addr_pipe_1;
  reg     [ 22: 0] rd_addr_pipe_10;
  reg     [ 22: 0] rd_addr_pipe_11;
  reg     [ 22: 0] rd_addr_pipe_12;
  reg     [ 22: 0] rd_addr_pipe_13;
  reg     [ 22: 0] rd_addr_pipe_14;
  reg     [ 22: 0] rd_addr_pipe_15;
  reg     [ 22: 0] rd_addr_pipe_16;
  reg     [ 22: 0] rd_addr_pipe_17;
  reg     [ 22: 0] rd_addr_pipe_18;
  reg     [ 22: 0] rd_addr_pipe_19;
  reg     [ 22: 0] rd_addr_pipe_2;
  reg     [ 22: 0] rd_addr_pipe_20;
  reg     [ 22: 0] rd_addr_pipe_21;
  reg     [ 22: 0] rd_addr_pipe_3;
  reg     [ 22: 0] rd_addr_pipe_4;
  reg     [ 22: 0] rd_addr_pipe_5;
  reg     [ 22: 0] rd_addr_pipe_6;
  reg     [ 22: 0] rd_addr_pipe_7;
  reg     [ 22: 0] rd_addr_pipe_8;
  reg     [ 22: 0] rd_addr_pipe_9;
  reg     [ 22: 0] rd_burst_counter;
  reg     [ 25: 0] rd_valid_pipe;
  wire    [ 22: 0] read_addr_delayed;
  reg              read_cmd;
  reg              read_cmd_echo;
  wire    [ 31: 0] read_data;
  wire    [ 15: 0] read_dq;
  reg     [  4: 0] read_latency;
  wire             read_valid;
  reg              read_valid_r;
  reg              read_valid_r2;
  reg              read_valid_r3;
  reg              read_valid_r4;
  reg              reset_n;
  wire    [ 22: 0] rmw_address;
  reg     [ 31: 0] rmw_temp;
  reg     [ 15: 0] second_half_dq;
  reg     [  3: 0] tcl;
  wire    [ 23: 0] txt_code;
  wire             we_n;
  wire    [ 22: 0] wr_addr_delayed;
  reg     [ 22: 0] wr_addr_delayed_r;
  reg     [ 22: 0] wr_addr_pipe_0;
  reg     [ 22: 0] wr_addr_pipe_1;
  reg     [ 22: 0] wr_addr_pipe_10;
  reg     [ 22: 0] wr_addr_pipe_11;
  reg     [ 22: 0] wr_addr_pipe_12;
  reg     [ 22: 0] wr_addr_pipe_13;
  reg     [ 22: 0] wr_addr_pipe_14;
  reg     [ 22: 0] wr_addr_pipe_15;
  reg     [ 22: 0] wr_addr_pipe_16;
  reg     [ 22: 0] wr_addr_pipe_17;
  reg     [ 22: 0] wr_addr_pipe_18;
  reg     [ 22: 0] wr_addr_pipe_2;
  reg     [ 22: 0] wr_addr_pipe_3;
  reg     [ 22: 0] wr_addr_pipe_4;
  reg     [ 22: 0] wr_addr_pipe_5;
  reg     [ 22: 0] wr_addr_pipe_6;
  reg     [ 22: 0] wr_addr_pipe_7;
  reg     [ 22: 0] wr_addr_pipe_8;
  reg     [ 22: 0] wr_addr_pipe_9;
  reg     [ 22: 0] wr_burst_counter;
  reg     [ 25: 0] wr_valid_pipe;
  reg     [ 25: 0] write_burst_length_pipe;
  reg              write_cmd;
  reg              write_cmd_echo;
  wire             write_to_ram;
  reg              write_to_ram_r;
  wire             write_valid;
  reg              write_valid_r;
  reg              write_valid_r2;
  reg              write_valid_r3;
initial
  begin
    $write("\n");
    $write("**********************************************************************\n");
    $write("This testbench includes a generated Altera memory model:\n");
    $write("'ddr_mem_model.v', to simulate accesses to the DDR SDRAM memory.\n");
    $write(" \n");
    $write("**********************************************************************\n");
  end
  //Synchronous write when (CODE == 24'h205752 (write))
  ddr_mem_model_ram_module ddr_mem_model_ram
    (
      .data      (rmw_temp),
      .q         (read_data),
      .rdaddress (rmw_address),
      .wraddress (wr_addr_delayed_r),
      .wrclock   (clk),
      .wren      (write_to_ram_r)
    );

  assign clk = mem_clk;
  assign dm = mem_dm;
  assign cke = mem_cke;
  assign cs_n = mem_cs_n;
  assign ras_n = mem_ras_n;
  assign cas_n = mem_cas_n;
  assign we_n = mem_we_n;
  assign ba = mem_ba;
  assign a = mem_addr;
  //generate a fake reset inside the memory model
  assign global_reset_n = reset_n;

  initial 
    begin
      reset_n <= 0;
      #100 reset_n <= 1;
    end
  assign cmd_code = (&cs_n) ? 3'b111 : {ras_n, cas_n, we_n};
  assign CODE = (&cs_n) ? 24'h494e48 : txt_code;
  assign addr_col = a[8 : 1];
  assign current_row = {ba};
  // Decode commands into their actions
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
        begin
          write_cmd_echo <= 0;
          read_cmd_echo <= 0;
        end
      else // No Activity if the clock is
      if (cke)
        begin
          // Checks whether to echo read cmd
          if (read_cmd_echo && !read_cmd)
            begin
              read_cmd <= 1'b1;
              read_cmd_echo <= 1'b0;
            end
          else // This is a read command
          if (cmd_code == 3'b101)
            begin
              read_cmd <= 1'b1;
              read_cmd_echo <= 1'b1;
            end
          else 
            read_cmd <= 1'b0;
          // Checks whether to echo write cmd
          if (write_cmd_echo && !write_cmd)
            begin
              write_cmd <= 1'b1;
              write_cmd_echo <= 1'b0;
            end
          else // This is a write command
          if (cmd_code == 3'b100)
            begin
              write_cmd <= 1'b1;
              write_cmd_echo <= 1'b1;
              write_burst_length_pipe[0] <= a[0];
            end
          else 
            write_cmd <= 1'b0;
          // This is an activate - store the chip/row/bank address in the same order as the DDR controller
          if (cmd_code == 3'b011)
              open_rows[current_row] <= a;
        end
    end


  // Pipes are flushed here
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
        begin
          wr_addr_pipe_1 <= 0;
          wr_addr_pipe_2 <= 0;
          wr_addr_pipe_3 <= 0;
          wr_addr_pipe_4 <= 0;
          wr_addr_pipe_5 <= 0;
          wr_addr_pipe_6 <= 0;
          wr_addr_pipe_7 <= 0;
          wr_addr_pipe_8 <= 0;
          wr_addr_pipe_9 <= 0;
          wr_addr_pipe_10 <= 0;
          wr_addr_pipe_11 <= 0;
          wr_addr_pipe_12 <= 0;
          wr_addr_pipe_13 <= 0;
          wr_addr_pipe_14 <= 0;
          wr_addr_pipe_15 <= 0;
          wr_addr_pipe_16 <= 0;
          wr_addr_pipe_17 <= 0;
          wr_addr_pipe_18 <= 0;
          rd_addr_pipe_1 <= 0;
          rd_addr_pipe_2 <= 0;
          rd_addr_pipe_3 <= 0;
          rd_addr_pipe_4 <= 0;
          rd_addr_pipe_5 <= 0;
          rd_addr_pipe_6 <= 0;
          rd_addr_pipe_7 <= 0;
          rd_addr_pipe_8 <= 0;
          rd_addr_pipe_9 <= 0;
          rd_addr_pipe_10 <= 0;
          rd_addr_pipe_11 <= 0;
          rd_addr_pipe_12 <= 0;
          rd_addr_pipe_13 <= 0;
          rd_addr_pipe_14 <= 0;
          rd_addr_pipe_15 <= 0;
          rd_addr_pipe_16 <= 0;
          rd_addr_pipe_17 <= 0;
          rd_addr_pipe_18 <= 0;
          rd_addr_pipe_19 <= 0;
          rd_addr_pipe_20 <= 0;
          rd_addr_pipe_21 <= 0;
        end
      else // No Activity if the clock is
      if (cke)
        begin
          rd_addr_pipe_21 <= rd_addr_pipe_20;
          rd_addr_pipe_20 <= rd_addr_pipe_19;
          rd_addr_pipe_19 <= rd_addr_pipe_18;
          rd_addr_pipe_18 <= rd_addr_pipe_17;
          rd_addr_pipe_17 <= rd_addr_pipe_16;
          rd_addr_pipe_16 <= rd_addr_pipe_15;
          rd_addr_pipe_15 <= rd_addr_pipe_14;
          rd_addr_pipe_14 <= rd_addr_pipe_13;
          rd_addr_pipe_13 <= rd_addr_pipe_12;
          rd_addr_pipe_12 <= rd_addr_pipe_11;
          rd_addr_pipe_11 <= rd_addr_pipe_10;
          rd_addr_pipe_10 <= rd_addr_pipe_9;
          rd_addr_pipe_9 <= rd_addr_pipe_8;
          rd_addr_pipe_8 <= rd_addr_pipe_7;
          rd_addr_pipe_7 <= rd_addr_pipe_6;
          rd_addr_pipe_6 <= rd_addr_pipe_5;
          rd_addr_pipe_5 <= rd_addr_pipe_4;
          rd_addr_pipe_4 <= rd_addr_pipe_3;
          rd_addr_pipe_3 <= rd_addr_pipe_2;
          rd_addr_pipe_2 <= rd_addr_pipe_1;
          rd_addr_pipe_1 <= rd_addr_pipe_0;
          rd_valid_pipe[25 : 1] <= rd_valid_pipe[24 : 0];
          rd_valid_pipe[0] <= cmd_code == 3'b101;
          wr_addr_pipe_18 <= wr_addr_pipe_17;
          wr_addr_pipe_17 <= wr_addr_pipe_16;
          wr_addr_pipe_16 <= wr_addr_pipe_15;
          wr_addr_pipe_15 <= wr_addr_pipe_14;
          wr_addr_pipe_14 <= wr_addr_pipe_13;
          wr_addr_pipe_13 <= wr_addr_pipe_12;
          wr_addr_pipe_12 <= wr_addr_pipe_11;
          wr_addr_pipe_11 <= wr_addr_pipe_10;
          wr_addr_pipe_10 <= wr_addr_pipe_9;
          wr_addr_pipe_9 <= wr_addr_pipe_8;
          wr_addr_pipe_8 <= wr_addr_pipe_7;
          wr_addr_pipe_7 <= wr_addr_pipe_6;
          wr_addr_pipe_6 <= wr_addr_pipe_5;
          wr_addr_pipe_5 <= wr_addr_pipe_4;
          wr_addr_pipe_4 <= wr_addr_pipe_3;
          wr_addr_pipe_3 <= wr_addr_pipe_2;
          wr_addr_pipe_2 <= wr_addr_pipe_1;
          wr_addr_pipe_1 <= wr_addr_pipe_0;
          wr_valid_pipe[25 : 1] <= wr_valid_pipe[24 : 0];
          wr_valid_pipe[0] <= cmd_code == 3'b100;
          wr_addr_delayed_r <= wr_addr_delayed;
          write_burst_length_pipe[25 : 1] <= write_burst_length_pipe[24 : 0];
        end
    end


  // Decode CAS Latency from bits a[6:4]
  always @(posedge clk)
    begin
      // No Activity if the clock is disabled
      if (cke)
          //Load mode register - set CAS latency, burst mode and length
          if (cmd_code == 3'b000 && ba == 2'b00)
            begin
              burstmode <= a[3];
              burstlength <= a[2 : 0] << 1;
              //CAS Latency = 2.0
              if (a[6 : 4] == 3'b010)
                  tcl <= 4'b0001;
              else //CAS Latency = 2.5
              if (a[6 : 4] == 3'b110)
                  tcl <= 4'b0001;
              else //CAS Latency = 3.0
              if (a[6 : 4] == 3'b011)
                  tcl <= 4'b0010;
              else //CAS Latency = 4.0
              if (a[6 : 4] == 3'b100)
                  tcl <= 4'b0011;
              else 
                tcl <= 4'b0100;
            end
    end


  //No additive latency in DDR
  always @(tcl)
    begin
      read_latency = tcl;
    end


  // Burst support - make the wr_addr & rd_addr keep counting
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
        begin
          wr_addr_pipe_0 <= 0;
          rd_addr_pipe_0 <= 0;
        end
      else 
        begin
          // Reset write address otherwise if the first write is partial it breaks!
          if (cmd_code == 3'b000 && ba == 2'b00)
            begin
              wr_addr_pipe_0 <= 0;
              wr_burst_counter <= 0;
            end
          else if (cmd_code == 3'b100)
            begin
              wr_addr_pipe_0 <= {ba,open_rows[current_row],addr_col};
              wr_burst_counter[22 : 2] <= {ba,open_rows[current_row],addr_col[7 : 2]};
              wr_burst_counter[1 : 0] <= addr_col[1 : 0] + 1;
            end
          else if (write_cmd || write_to_ram || write_cmd_echo)
            begin
              wr_addr_pipe_0 <= wr_burst_counter;
              wr_burst_counter[1 : 0] <= wr_burst_counter[1 : 0] + 1;
            end
          else 
            wr_addr_pipe_0 <= 0;
          // Reset read address otherwise if the first write is partial it breaks!
          if (cmd_code == 3'b000 && ba == 2'b00)
              rd_addr_pipe_0 <= 0;
          else if (cmd_code == 3'b101)
            begin
              rd_addr_pipe_0 <= {ba,open_rows[current_row],addr_col};
              rd_burst_counter[22 : 2] <= {ba,open_rows[current_row],addr_col[7 : 2]};
              rd_burst_counter[1 : 0] <= addr_col[1 : 0] + 1;
            end
          else if (read_cmd || dq_valid || read_valid || read_cmd_echo)
            begin
              rd_addr_pipe_0 <= rd_burst_counter;
              rd_burst_counter[1 : 0] <= rd_burst_counter[1 : 0] + 1;
            end
          else 
            rd_addr_pipe_0 <= 0;
        end
    end


  // read data transition from single to double clock rate
  always @(posedge clk)
    begin
      first_half_dq <= read_data[31 : 16];
      second_half_dq <= read_data[15 : 0];
    end


  assign read_dq = clk  ? second_half_dq : first_half_dq;
  assign dq_temp = dq_valid  ? read_dq : {16{1'bz}};
  assign dqs_temp = dqs_valid ? {2{clk}} : {2{1'bz}};
  assign mem_dqs = dqs_temp;
  assign mem_dq = dq_temp;
  //Pipelining registers for burst counting
  always @(posedge clk)
    begin
      write_valid_r <= write_valid;
      read_valid_r <= read_valid;
      write_valid_r2 <= write_valid_r;
      write_valid_r3 <= write_valid_r2;
      write_to_ram_r <= write_to_ram;
      read_valid_r2 <= read_valid_r;
      read_valid_r3 <= read_valid_r2;
      read_valid_r4 <= read_valid_r3;
    end


  assign write_to_ram = burstlength[1] ? write_valid || write_valid_r || write_valid_r2 || write_valid_r3 : write_valid || write_valid_r;
  assign dq_valid = burstlength[1] ? read_valid_r || read_valid_r2 || read_valid_r3 || read_valid_r4 : read_valid_r || read_valid_r2;
  assign dqs_valid = dq_valid || dqs_valid_temp;
  // 
  always @(negedge clk)
    begin
      dqs_valid_temp <= read_valid;
    end


  //capture first half of write data with rising edge of DQS, for simulation use only 1 DQS pin
  always @(posedge mem_dqs[0])
    begin
      #0.1 dq_captured[15 : 0] <= mem_dq[15 : 0];
      #0.1 dm_captured[1 : 0] <= mem_dm[1 : 0];
    end


  //capture second half of write data with falling edge of DQS, for simulation use only 1 DQS pin
  always @(negedge mem_dqs[0])
    begin
      #0.1 dq_captured[31 : 16] <= mem_dq[15 : 0];
      #0.1 dm_captured[3 : 2] <= mem_dm[1 : 0];
    end


  //Support for incomplete writes, do a read-modify-write with mem_bytes and the write data
  always @(posedge clk)
    begin
      if (write_to_ram)
          rmw_temp[7 : 0] <= dm_captured[0] ? mem_bytes[7 : 0] : dq_captured[7 : 0];
    end


  always @(posedge clk)
    begin
      if (write_to_ram)
          rmw_temp[15 : 8] <= dm_captured[1] ? mem_bytes[15 : 8] : dq_captured[15 : 8];
    end


  always @(posedge clk)
    begin
      if (write_to_ram)
          rmw_temp[23 : 16] <= dm_captured[2] ? mem_bytes[23 : 16] : dq_captured[23 : 16];
    end


  always @(posedge clk)
    begin
      if (write_to_ram)
          rmw_temp[31 : 24] <= dm_captured[3] ? mem_bytes[31 : 24] : dq_captured[31 : 24];
    end


  assign write_valid = wr_valid_pipe[1];
  assign wr_addr_delayed = wr_addr_pipe_1;
  assign mem_bytes = (rmw_address == wr_addr_delayed_r && write_to_ram_r) ? rmw_temp : read_data;
  assign rmw_address = (write_to_ram) ? wr_addr_delayed : read_addr_delayed;
  //use read_latency to select which pipeline stage drives addr
  assign read_addr_delayed = (read_latency == 0)? rd_addr_pipe_0 :
    (read_latency == 1)? rd_addr_pipe_1 :
    (read_latency == 2)? rd_addr_pipe_2 :
    (read_latency == 3)? rd_addr_pipe_3 :
    (read_latency == 4)? rd_addr_pipe_4 :
    (read_latency == 5)? rd_addr_pipe_5 :
    (read_latency == 6)? rd_addr_pipe_6 :
    (read_latency == 7)? rd_addr_pipe_7 :
    (read_latency == 8)? rd_addr_pipe_8 :
    (read_latency == 9)? rd_addr_pipe_9 :
    (read_latency == 10)? rd_addr_pipe_10 :
    (read_latency == 11)? rd_addr_pipe_11 :
    (read_latency == 12)? rd_addr_pipe_12 :
    (read_latency == 13)? rd_addr_pipe_13 :
    (read_latency == 14)? rd_addr_pipe_14 :
    (read_latency == 15)? rd_addr_pipe_15 :
    (read_latency == 16)? rd_addr_pipe_16 :
    (read_latency == 17)? rd_addr_pipe_17 :
    (read_latency == 18)? rd_addr_pipe_18 :
    (read_latency == 19)? rd_addr_pipe_19 :
    (read_latency == 20)? rd_addr_pipe_20 :
    rd_addr_pipe_21;

  //use read_latency to select which pipeline stage drives valid
  assign read_valid = (read_latency == 0)? rd_valid_pipe[0] :
    (read_latency == 1)? rd_valid_pipe[1] :
    (read_latency == 2)? rd_valid_pipe[2] :
    (read_latency == 3)? rd_valid_pipe[3] :
    (read_latency == 4)? rd_valid_pipe[4] :
    (read_latency == 5)? rd_valid_pipe[5] :
    (read_latency == 6)? rd_valid_pipe[6] :
    (read_latency == 7)? rd_valid_pipe[7] :
    (read_latency == 8)? rd_valid_pipe[8] :
    (read_latency == 9)? rd_valid_pipe[9] :
    (read_latency == 10)? rd_valid_pipe[10] :
    (read_latency == 11)? rd_valid_pipe[11] :
    (read_latency == 12)? rd_valid_pipe[12] :
    (read_latency == 13)? rd_valid_pipe[13] :
    (read_latency == 14)? rd_valid_pipe[14] :
    (read_latency == 15)? rd_valid_pipe[15] :
    (read_latency == 16)? rd_valid_pipe[16] :
    (read_latency == 17)? rd_valid_pipe[17] :
    (read_latency == 18)? rd_valid_pipe[18] :
    (read_latency == 19)? rd_valid_pipe[19] :
    (read_latency == 20)? rd_valid_pipe[20] :
    rd_valid_pipe[21];


//synthesis translate_off
//////////////// SIMULATION-ONLY CONTENTS
  assign txt_code = (cmd_code == 3'h0)? 24'h4c4d52 :
    (cmd_code == 3'h1)? 24'h415246 :
    (cmd_code == 3'h2)? 24'h505245 :
    (cmd_code == 3'h3)? 24'h414354 :
    (cmd_code == 3'h4)? 24'h205752 :
    (cmd_code == 3'h5)? 24'h205244 :
    (cmd_code == 3'h6)? 24'h425354 :
    (cmd_code == 3'h7)? 24'h4e4f50 :
    24'h424144;


//////////////// END SIMULATION-ONLY CONTENTS

//synthesis translate_on

endmodule

