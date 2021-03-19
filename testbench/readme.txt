1.把测试码流文件重命名为"in"，运行bin2hex.exe生成"out.mem"
2.有两种测试模式：
	1.bitstream_tb.v ext_ram_32.v是不带ddr的仿真文件
	2.其余的.v文件(bitstream_test_tb.v, bitstream_test_cfi_flash.v, bitstream_fifo_cfi_flash.v flash_model.v mt46v4m16.v)是带ddr的仿真文件,还要altera的仿真库文件，但是速度很慢。仿真库请自行添加, 有altera_primitives.v altera_mf.v cycloneiv_atoms.v cycloneiii_atoms.v
3."display.log"是第一种模式下生成的yuv数据文件，用hex2bin.exe转为yuv格式。
