onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/clk
add wave -noupdate /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/rst_n
add wave -noupdate /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/ddr_data
add wave -noupdate /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/ddr_dqs
add wave -noupdate /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/ddr_dqm
add wave -noupdate /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/ddr_ras_n
add wave -noupdate /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/ddr_cas_n
add wave -noupdate /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/ddr_we_n
add wave -noupdate /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/ddr_cs_n
add wave -noupdate /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/ddr_cke
add wave -noupdate /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/ddr_ba
add wave -noupdate /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/ddr_addr
add wave -noupdate /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/ddr_clk
add wave -noupdate /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/ddr_clk_n
add wave -noupdate /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/dec_clk
add wave -noupdate /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/vga_clk
add wave -noupdate /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/burst_len_minus1
add wave -noupdate /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/addr
add wave -noupdate /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/d
add wave -noupdate /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/full
add wave -noupdate /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/y_addr
add wave -noupdate /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/u_addr
add wave -noupdate /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/v_addr
add wave -noupdate /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/sdrc_burst_idle
add wave -noupdate /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/y_rd
add wave -noupdate /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/uv_rd
add wave -noupdate -radix hexadecimal /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/y_data
add wave -noupdate -radix hexadecimal /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/u_data
add wave -noupdate -radix hexadecimal /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/v_data
add wave -noupdate /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/sdrc_act
add wave -noupdate -radix hexadecimal /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/sdrc_cmd
add wave -noupdate /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/sys_addr
add wave -noupdate /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/sdrc_data_in
add wave -noupdate /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/sdrc_burst_idle
add wave -noupdate -radix hexadecimal /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/rw_len
add wave -noupdate -radix hexadecimal -childformat {{{/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/addr_display[23]} -radix hexadecimal} {{/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/addr_display[22]} -radix hexadecimal} {{/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/addr_display[21]} -radix hexadecimal} {{/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/addr_display[20]} -radix hexadecimal} {{/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/addr_display[19]} -radix hexadecimal} {{/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/addr_display[18]} -radix hexadecimal} {{/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/addr_display[17]} -radix hexadecimal} {{/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/addr_display[16]} -radix hexadecimal} {{/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/addr_display[15]} -radix hexadecimal} {{/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/addr_display[14]} -radix hexadecimal} {{/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/addr_display[13]} -radix hexadecimal} {{/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/addr_display[12]} -radix hexadecimal} {{/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/addr_display[11]} -radix hexadecimal} {{/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/addr_display[10]} -radix hexadecimal} {{/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/addr_display[9]} -radix hexadecimal} {{/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/addr_display[8]} -radix hexadecimal} {{/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/addr_display[7]} -radix hexadecimal} {{/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/addr_display[6]} -radix hexadecimal} {{/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/addr_display[5]} -radix hexadecimal} {{/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/addr_display[4]} -radix hexadecimal} {{/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/addr_display[3]} -radix hexadecimal} {{/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/addr_display[2]} -radix hexadecimal} {{/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/addr_display[1]} -radix hexadecimal} {{/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/addr_display[0]} -radix hexadecimal}} -subitemconfig {{/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/addr_display[23]} {-height 15 -radix hexadecimal} {/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/addr_display[22]} {-height 15 -radix hexadecimal} {/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/addr_display[21]} {-height 15 -radix hexadecimal} {/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/addr_display[20]} {-height 15 -radix hexadecimal} {/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/addr_display[19]} {-height 15 -radix hexadecimal} {/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/addr_display[18]} {-height 15 -radix hexadecimal} {/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/addr_display[17]} {-height 15 -radix hexadecimal} {/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/addr_display[16]} {-height 15 -radix hexadecimal} {/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/addr_display[15]} {-height 15 -radix hexadecimal} {/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/addr_display[14]} {-height 15 -radix hexadecimal} {/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/addr_display[13]} {-height 15 -radix hexadecimal} {/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/addr_display[12]} {-height 15 -radix hexadecimal} {/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/addr_display[11]} {-height 15 -radix hexadecimal} {/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/addr_display[10]} {-height 15 -radix hexadecimal} {/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/addr_display[9]} {-height 15 -radix hexadecimal} {/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/addr_display[8]} {-height 15 -radix hexadecimal} {/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/addr_display[7]} {-height 15 -radix hexadecimal} {/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/addr_display[6]} {-height 15 -radix hexadecimal} {/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/addr_display[5]} {-height 15 -radix hexadecimal} {/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/addr_display[4]} {-height 15 -radix hexadecimal} {/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/addr_display[3]} {-height 15 -radix hexadecimal} {/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/addr_display[2]} {-height 15 -radix hexadecimal} {/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/addr_display[1]} {-height 15 -radix hexadecimal} {/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/addr_display[0]} {-height 15 -radix hexadecimal}} /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/addr_display
add wave -noupdate /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/burst_len_minus1_display
add wave -noupdate /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/sdrc_data_in_req
add wave -noupdate /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/local_burstbegin
add wave -noupdate /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/local_read_req
add wave -noupdate -radix hexadecimal /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/local_address
add wave -noupdate -radix hexadecimal /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/local_address_reg
add wave -noupdate /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/local_ready
add wave -noupdate /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/vga_clk
add wave -noupdate /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/local_write_req
add wave -noupdate /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/phy_clk
add wave -noupdate /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/rw_done
add wave -noupdate -radix hexadecimal -childformat {{{/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/y_addr_reg[23]} -radix hexadecimal} {{/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/y_addr_reg[22]} -radix hexadecimal} {{/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/y_addr_reg[21]} -radix hexadecimal} {{/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/y_addr_reg[20]} -radix hexadecimal} {{/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/y_addr_reg[19]} -radix hexadecimal} {{/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/y_addr_reg[18]} -radix hexadecimal} {{/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/y_addr_reg[17]} -radix hexadecimal} {{/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/y_addr_reg[16]} -radix hexadecimal} {{/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/y_addr_reg[15]} -radix hexadecimal} {{/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/y_addr_reg[14]} -radix hexadecimal} {{/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/y_addr_reg[13]} -radix hexadecimal} {{/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/y_addr_reg[12]} -radix hexadecimal} {{/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/y_addr_reg[11]} -radix hexadecimal} {{/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/y_addr_reg[10]} -radix hexadecimal} {{/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/y_addr_reg[9]} -radix hexadecimal} {{/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/y_addr_reg[8]} -radix hexadecimal} {{/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/y_addr_reg[7]} -radix hexadecimal} {{/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/y_addr_reg[6]} -radix hexadecimal} {{/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/y_addr_reg[5]} -radix hexadecimal} {{/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/y_addr_reg[4]} -radix hexadecimal} {{/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/y_addr_reg[3]} -radix hexadecimal} {{/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/y_addr_reg[2]} -radix hexadecimal} {{/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/y_addr_reg[1]} -radix hexadecimal} {{/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/y_addr_reg[0]} -radix hexadecimal}} -subitemconfig {{/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/y_addr_reg[23]} {-height 15 -radix hexadecimal} {/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/y_addr_reg[22]} {-height 15 -radix hexadecimal} {/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/y_addr_reg[21]} {-height 15 -radix hexadecimal} {/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/y_addr_reg[20]} {-height 15 -radix hexadecimal} {/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/y_addr_reg[19]} {-height 15 -radix hexadecimal} {/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/y_addr_reg[18]} {-height 15 -radix hexadecimal} {/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/y_addr_reg[17]} {-height 15 -radix hexadecimal} {/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/y_addr_reg[16]} {-height 15 -radix hexadecimal} {/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/y_addr_reg[15]} {-height 15 -radix hexadecimal} {/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/y_addr_reg[14]} {-height 15 -radix hexadecimal} {/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/y_addr_reg[13]} {-height 15 -radix hexadecimal} {/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/y_addr_reg[12]} {-height 15 -radix hexadecimal} {/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/y_addr_reg[11]} {-height 15 -radix hexadecimal} {/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/y_addr_reg[10]} {-height 15 -radix hexadecimal} {/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/y_addr_reg[9]} {-height 15 -radix hexadecimal} {/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/y_addr_reg[8]} {-height 15 -radix hexadecimal} {/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/y_addr_reg[7]} {-height 15 -radix hexadecimal} {/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/y_addr_reg[6]} {-height 15 -radix hexadecimal} {/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/y_addr_reg[5]} {-height 15 -radix hexadecimal} {/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/y_addr_reg[4]} {-height 15 -radix hexadecimal} {/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/y_addr_reg[3]} {-height 15 -radix hexadecimal} {/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/y_addr_reg[2]} {-height 15 -radix hexadecimal} {/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/y_addr_reg[1]} {-height 15 -radix hexadecimal} {/bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/y_addr_reg[0]} {-height 15 -radix hexadecimal}} /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/y_addr_reg
add wave -noupdate /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/u_addr_reg
add wave -noupdate /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/v_addr_reg
add wave -noupdate /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/y_rd
add wave -noupdate /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/uv_rd
add wave -noupdate -radix hexadecimal /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/local_rdata
add wave -noupdate /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/local_rdata_valid
add wave -noupdate /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/read_done
add wave -noupdate /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/rd_req_id
add wave -noupdate /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/rd_req_list
add wave -noupdate -radix unsigned /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/y_fifo_nword
add wave -noupdate -radix unsigned /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/u_fifo_nword
add wave -noupdate -radix unsigned /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/v_fifo_nword
add wave -noupdate /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/display_addr_load
add wave -noupdate /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/read_req
add wave -noupdate /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/burst
add wave -noupdate /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/init_done
add wave -noupdate /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/wr
add wave -noupdate /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/rd_req_id
add wave -noupdate /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/rd_mask
add wave -noupdate /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/rd_req_list
add wave -noupdate /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/y_fifo_rdempty
add wave -noupdate /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/u_fifo_rdempty
add wave -noupdate /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/v_fifo_rdempty
add wave -noupdate -radix hexadecimal /bitstream_test_tb/bitstream_test_cfi_flash/vga/x
add wave -noupdate -radix unsigned /bitstream_test_tb/bitstream_test_cfi_flash/vga/y
add wave -noupdate /bitstream_test_tb/bitstream_test_cfi_flash/sdrc_display/read_ena
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1221960000 ps} 0}
configure wave -namecolwidth 224
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {1256358546 ps} {1257429551 ps}
