//--------------------------------------------------------------------------------------------------
// Design    : bitstream_p
// Author(s) : qiu bin, shi tian qi
// Email     : chat1@126.com, tishi1@126.com
// Copyright (C) 2013 qiu bin 
// All rights researved                
//-------------------------------------------------------------------------------------------------

module fat32_read_file
(
	clk,
	rst,
	
	init_done,
	sector_rd_start,
	sector_rd_addr,
	addr_i,
	data_i,
	wr_i,
	reading,
	read_done,
	
	file_read_req,
	file_data,
	file_data_valid,
	file_reach_end,
	
	//for debug
	state,
	file_state,
	step,
	sector_buf_data,
	sector_buf_rd_addr
);
input clk;
input rst;

input init_done;
output sector_rd_start;
output [22:0] sector_rd_addr;
input [8:0] addr_i;
input [7:0] data_i;
input wr_i;
input reading;
input read_done;

input        file_read_req; //read 512 bytes
output [7:0] file_data;
output       file_data_valid;
output       file_reach_end;

//for debug
output [3:0] step;
output [3:0] state;
output [3:0] file_state;
output [7:0] sector_buf_data;
output [8:0] sector_buf_rd_addr;

reg sector_rd_start;
reg [22:0] sector_rd_addr;
reg all_done;
reg [8:0] sector_buf_rd_addr;

//fat parameters
reg [22:0] dbr_sector_addr;
reg [7:0]  sectors_per_cluster;
reg [15:0] reserved_sector_num;
reg [21:0] sectors_per_fat;
reg [22:0] fat1_sector_addr;
reg [22:0] rootdir_sector_addr;

reg [3:0] step;
reg [3:0] state;

parameter    
Idle = 0,    
ReadDPT = 1, 
ReadDBR = 2, 
ReadFile = 3;


//file
wire [7:0] file_name[0:10];
assign file_name[0] = "T";
assign file_name[1] = "E";
assign file_name[2] = "S";
assign file_name[3] = "T";
assign file_name[4] = " ";
assign file_name[5] = " ";
assign file_name[6] = " ";
assign file_name[7] = " ";
assign file_name[8] = "2";
assign file_name[9] = "6";
assign file_name[10] = "4";

reg [3:0] file_state;
parameter
FileIdle = 0,
FileReadRootDir = 1,
FileSelect = 2,
FileGetParams = 3,
FileRead  = 4;

parameter MaxFileNumInDir = 511;
reg [8:0] file_name_compare_offset;

reg [3:0] file_select_index;
reg [19:0] file_cluster_index;
reg [6:0] file_cluster_index_old;
reg [31:0] file_size;
reg [31:0] file_read_size;
reg [12:0] current_fat_sector;
reg [4:0]  file_sector_index;
reg file_reading;
reg file_reach_end;
reg file_output;

assign file_data = data_i;
assign file_data_valid = file_reading && wr_i && file_output;

//sector buf
wire [8:0] sector_buf_addr;
assign sector_buf_addr = reading ? addr_i: sector_buf_rd_addr;
wire [7:0] sector_buf_data;
ram #(9,8) ram
(
	.clk(clk),
	.wr_n(!(wr_i && !file_reading)), 
	.addr(sector_buf_addr), 
	.data_in(data_i), 
	.data_out(sector_buf_data)
);

always @(*)
case (state)
Idle :  sector_buf_rd_addr <= 0;
ReadDPT : begin
	case (step)
	3:sector_buf_rd_addr <= 'h000;
	4:sector_buf_rd_addr <= 'h001;
	5:sector_buf_rd_addr <= 'h002;
	7:sector_buf_rd_addr <= 'h1c6;
	8:sector_buf_rd_addr <= 'h1c7;
	9:sector_buf_rd_addr <= 'h1c8;
	default:sector_buf_rd_addr <= 0;
	endcase
end
ReadDBR : begin
	case (step)
	2:sector_buf_rd_addr <= 'hd;
	3:sector_buf_rd_addr <= 'he;
	4:sector_buf_rd_addr <= 'hf;
	5:sector_buf_rd_addr <= 'h24;
	6:sector_buf_rd_addr <= 'h25;
	7:sector_buf_rd_addr <= 'h26;
	default : sector_buf_rd_addr <= 0;
	endcase
end
ReadFile : begin
	case (file_state)
	FileSelect : begin
		case (step)
		1:sector_buf_rd_addr <= (file_select_index << 5) + file_name_compare_offset;
		8:sector_buf_rd_addr <= (file_cluster_index_old[6:0] << 2) + 0;
		9:sector_buf_rd_addr <= (file_cluster_index_old[6:0] << 2) + 1;
		10:sector_buf_rd_addr <= (file_cluster_index_old[6:0] << 2) + 2;
		default : sector_buf_rd_addr <= 0;
		endcase
	end
	FileGetParams : begin
		case (step)
		0:sector_buf_rd_addr <= (file_select_index << 5) + 'h1a;
		1:sector_buf_rd_addr <= (file_select_index << 5) + 'h1b;
		2:sector_buf_rd_addr <= (file_select_index << 5) + 'h14;
		3:sector_buf_rd_addr <= (file_select_index << 5) + 'h1c;
		4:sector_buf_rd_addr <= (file_select_index << 5) + 'h1d;
		5:sector_buf_rd_addr <= (file_select_index << 5) + 'h1e;
		6:sector_buf_rd_addr <= (file_select_index << 5) + 'h1f;
		default : sector_buf_rd_addr <= 0;
		endcase
	end
	FileRead:begin
		case (step)
		8:sector_buf_rd_addr <= (file_cluster_index_old[6:0] << 2) + 0;
		9:sector_buf_rd_addr <= (file_cluster_index_old[6:0] << 2) + 1;
		10:sector_buf_rd_addr <= (file_cluster_index_old[6:0] << 2) + 2;
		default : sector_buf_rd_addr <= 0;
		endcase
	end 
	default : sector_buf_rd_addr <= 0;
	endcase
end
default : sector_buf_rd_addr <= 0;
endcase

always @(posedge clk or posedge rst)
if (rst) begin
	state <= Idle;
	step <= 0;
	sector_rd_start <= 0;
	sector_rd_addr <= 0;
	all_done <= 0;
	dbr_sector_addr <= 0;
	sectors_per_cluster <= 0;
	reserved_sector_num <= 0;
	sectors_per_fat <= 0;
	fat1_sector_addr <= 0;
	rootdir_sector_addr <= 0;
	file_state <= FileIdle;
	file_name_compare_offset <= 0;
	file_select_index <= 0;
	current_fat_sector <= 0;
	file_sector_index <= 0;
	file_cluster_index <= 0;
	file_cluster_index_old <= 0;
	file_size <= 0;
	file_read_size <= 0;
	file_reading <= 0;
	file_reach_end <= 0;
end
else begin
	case (state)
	Idle : begin
		if (init_done && !all_done) begin
			state <= ReadDPT;
			step <= 0;
		end
		else
			state <= Idle;
	end
	ReadDPT : begin
		if (step == 0) begin
			step <=1;
			sector_rd_start <= 1;
			sector_rd_addr <= 0;
		end
		else if (step == 1) begin
			sector_rd_start <= 0;
			step <= 2;
		end
		else if (step == 2) begin
			if (read_done) begin
				step <= 3;		
			end
		end
		else if (step == 3) begin
			step <= 4;
		end
		else if (step == 4) begin
			if (sector_buf_data == 'heb)
				step <= 5;
			else
				step <= 7;
		end
		else if (step == 5) begin
			if (sector_buf_data == 'h58)
				step <= 6;
			else
				step <= 7;
		end
		else if (step == 6) begin
			if (sector_buf_data == 'h90) begin //current sector is DBR
				dbr_sector_addr <= 0;
				state <= ReadDBR;
				step <= 0;
			end
			else
				step <= 7;
		end
		else if (step == 7) begin
			step <= 8;
		end
		else if (step == 8) begin
			dbr_sector_addr[7:0] <= sector_buf_data;
			step <= 9;
		end
		else if (step == 9) begin
			dbr_sector_addr[15:8] <= sector_buf_data;
			step <= 10;
		end
		else if (step == 10) begin
			dbr_sector_addr[22:16] <= sector_buf_data[6:0];
			state <= ReadDBR;
			step <= 0;
		end
	end
	ReadDBR : begin
		if (step == 0) begin
			step <=1;
			sector_rd_start <= 1;
			sector_rd_addr <= dbr_sector_addr;
		end
		else if (step == 1) begin
			sector_rd_start <= 0;
			step <= 2;
		end
		else if (step == 2) begin
			if (read_done) begin
				step <= 3;		
			end
		end
		else if (step == 3) begin
			sectors_per_cluster <= sector_buf_data;
			step <= 4;
		end
		else if (step == 4) begin
			reserved_sector_num[7:0] <= sector_buf_data;
			step <= 5;
		end
		else if (step == 5) begin
			reserved_sector_num[15:8] <= sector_buf_data;
			step <= 6;
		end
		else if (step == 6) begin
			sectors_per_fat[7:0] <= sector_buf_data;
			step <= 7;
		end
		else if (step == 7) begin
			sectors_per_fat[15:8] <= sector_buf_data;
			step <= 8;
		end
		else if (step == 8) begin
			sectors_per_fat[21:16] <= sector_buf_data[5:0];
			step <= 9;
		end
		else if (step == 9) begin
			fat1_sector_addr    <= dbr_sector_addr + reserved_sector_num; 
			step <= 10;
		end
		else if (step == 10) begin
			rootdir_sector_addr <= fat1_sector_addr + (sectors_per_fat << 1);
			step <= 0;
			state <= ReadFile;
			file_state <= FileIdle;	
		end
	end
	ReadFile : begin
		case (file_state)
		FileIdle : begin
			if (!all_done)begin
				file_state <= FileReadRootDir;
				file_cluster_index <= 2;
				file_sector_index  <= 0;
				step <= 0;
			end
		end
		FileReadRootDir:begin
			if (step == 0) begin
				if (file_cluster_index < 20'hffff8) begin
					step <=1;
					sector_rd_start <= 1;
					if (sectors_per_cluster == 8)
						sector_rd_addr <= rootdir_sector_addr + ((file_cluster_index - 2) << 3) + file_sector_index;
					else if(sectors_per_cluster == 16)
						sector_rd_addr <= rootdir_sector_addr + ((file_cluster_index - 2) << 4) + file_sector_index;
					else if(sectors_per_cluster == 32)
						sector_rd_addr <= rootdir_sector_addr + ((file_cluster_index - 2) << 5) + file_sector_index;
					else //(sectors_per_cluster == 64)
						sector_rd_addr <= rootdir_sector_addr + ((file_cluster_index - 2) << 6) + file_sector_index;
				end
				else begin
					state <= Idle;
					file_state <= FileIdle;
					all_done <= 1;
				end 
			end
			else if (step == 1) begin
				sector_rd_start <= 0;
				step <= 2;
			end
			else if (step == 2) begin
				if (read_done) begin
					step <= 0;
					file_state <= FileSelect;
					file_select_index <= 0;
				end
			end
		end
		FileSelect : begin
			if (step == 0) begin
				 file_name_compare_offset <= 0;
				 step <= 1;
			end
			else if (step == 1) begin
				step <= 2;
			end
			else if (step == 2) begin
				if (sector_buf_data == file_name[file_name_compare_offset]) begin
					if (file_name_compare_offset == 10) begin		//file found
						file_state <= FileGetParams;
						step <= 0;
					end
					else begin
						file_name_compare_offset <= file_name_compare_offset + 1;
						step <= 1;
					end
				end
				else if (file_select_index < 15) begin
					step <= 0;
					file_select_index <= file_select_index + 1;
				end
				else begin //file_select_index == 15
					file_select_index <= 0;
					step <= 3;
				end
			end
			else if (step == 3) begin
				file_sector_index <= file_sector_index + 1;
				step <=4;
			end
			if (step == 4) begin
				if (file_sector_index < sectors_per_cluster) begin
					file_state <= FileReadRootDir;
					step <= 0;
				end
				else begin	//load fat table to ram
					file_sector_index <= 0;
					step <= 5;
				end
			end
			else if (step == 5) begin
				step <= 6;
				sector_rd_start <= 1;
				sector_rd_addr <= fat1_sector_addr + (file_cluster_index >> 7);
			end
			else if (step == 6) begin
				sector_rd_start <= 0;
				step <= 7;
			end	
			else if (step == 7) begin
				if (read_done) begin
					step <= 8;
					file_cluster_index_old <= file_cluster_index[6:0];
				end
			end
			else if (step == 8) begin
				step <= 9;
			end
			else if (step == 9) begin
				file_cluster_index[7:0] <= sector_buf_data;
				step <= 10;
			end
			else if (step == 10) begin
				file_cluster_index[15:8] <= sector_buf_data;
				step <= 11;
			end
			else if (step == 11) begin
				file_cluster_index[19:16] <= sector_buf_data[3:0];
				file_state <= FileReadRootDir;
				step <= 0;
			end
		end
		FileGetParams : begin
			if (step == 0) begin
				step <= 1;
			end
			else if (step == 1) begin
				step <= 2;
				file_cluster_index[7:0] <= sector_buf_data;
			end
			else if (step == 2) begin
				step <= 3;
				file_cluster_index[15:8] <= sector_buf_data;
			end
			else if (step == 3) begin
				step <= 4;
				file_cluster_index[19:16] <= sector_buf_data[3:0];
			end
			else if (step == 4) begin
				step <= 5;
				file_size[7:0] <= sector_buf_data;
			end
			else if (step == 5) begin
				step <= 6;
				file_size[15:8] <= sector_buf_data;
			end
			else if (step == 6) begin
				step <= 7;
				file_size[23:16] <= sector_buf_data;
			end
			else if (step == 7) begin
				step <= 8;
				file_size[31:24] <= sector_buf_data;
				step <= 0;
				file_state <= FileRead;
				file_sector_index <= 0;
				file_read_size <= 0;
				file_reach_end <= 0;
				current_fat_sector <= 'hffff;
			end
		end
		FileRead : begin
			if (step == 0 && file_read_req) begin
				step <=1;
				sector_rd_start <= 1;
				file_reading <= 1;
				if (sectors_per_cluster == 8)
					sector_rd_addr <= rootdir_sector_addr + ((file_cluster_index - 2) << 3) + file_sector_index;
				else if(sectors_per_cluster == 16)
					sector_rd_addr <= rootdir_sector_addr + ((file_cluster_index - 2) << 4) + file_sector_index;
				else if(sectors_per_cluster == 32)
					sector_rd_addr <= rootdir_sector_addr + ((file_cluster_index - 2) << 5) + file_sector_index;
				else //(sectors_per_cluster == 64)
					sector_rd_addr <= rootdir_sector_addr + ((file_cluster_index - 2) << 6) + file_sector_index;
			end
			else if (step == 1) begin
				sector_rd_start <= 0;
				step <= 2;
			end	
			else if (step == 2) begin
				if (wr_i) 
					file_read_size <= file_read_size + 1;
				if (file_read_size >= file_size) begin
					file_reach_end <= 1;
				end
				if (read_done) begin
					step <= 3;
					file_reading <= 0;
				end
			end
			else if (step == 3) begin
				file_sector_index <= file_sector_index + 1;
				step <=4;
			end
			else if (step == 4) begin
				if (file_read_size >= file_size) begin
					state <= Idle;
					file_state <= Idle;
					all_done <= 1;
				end
				else if (file_sector_index < sectors_per_cluster) begin
					step <= 0;
				end
				else if (file_cluster_index >> 7 == current_fat_sector)begin//fat table is in ram
					file_sector_index <= 0;
					file_cluster_index_old <= file_cluster_index[6:0];
					step <= 8;
				end
				else begin	//fat table is not in ram, load it
					file_sector_index <= 0;
					step <= 5;
				end
			end
			else if (step == 5) begin
				step <= 6;
				sector_rd_start <= 1;
				sector_rd_addr <= fat1_sector_addr + (file_cluster_index >> 7);
			end
			else if (step == 6) begin
				sector_rd_start <= 0;
				step <= 7;
			end	
			else if (step == 7) begin
				if (read_done) begin
					step <= 8;
					current_fat_sector <= file_cluster_index >> 7;
					file_cluster_index_old <= file_cluster_index[6:0];
				end
			end
			else if (step == 8) begin
				step <= 9;
			end
			else if (step == 9) begin
				file_cluster_index[7:0] <= sector_buf_data;
				step <= 10;
			end
			else if (step == 10) begin
				file_cluster_index[15:8] <= sector_buf_data;
				step <= 11;
			end
			else if (step == 11) begin
				file_cluster_index[19:16] <= sector_buf_data[3:0];
				step <= 0;
			end
		end
		endcase
	end
	endcase
end

always @(posedge clk)
	file_output <= file_read_size < file_size + 8'h10;

endmodule
