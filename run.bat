@echo off
REM Execute the graphical display first, the program will listen to port 2000
start ferndisp/ferndisp.exe 2000

rem compile FLI code
rem make sure MTI_HOME is pointing to the win64pe directory
gcc -g -Wall -c -I%MTI_HOME%/include src/fli_fern.c
gcc -g -shared fli_fern.o -L%MTI_HOME%/win64pe -lmtipli -lwsock32 -o fli_fern.dll  

vdel -all
vlib work

REM compile VHDL
vcom -quiet rtl/fernpack.vhd
vcom -quiet rtl/fernpack_body.vhd
vcom -quiet rtl/random_rtl.vhd
vcom -quiet rtl/rectifier_rtl.vhd
vcom -quiet rtl/irectifier_rtl.vhd
vcom -quiet rtl/multiplier_struct.vhd
vcom -quiet rtl/xchan_struct.vhd
vcom -quiet rtl/ychan_struct.vhd
vcom -quiet rtl/fern_struct.vhd
vcom -quiet rtl/fern_tester_rtl.vhd
vcom -quiet rtl/load_fern_rtl.vhd
vcom -quiet rtl/clockgen_rtl.vhd
vcom -quiet rtl/fern_tb_struct.vhd

vsim -c -do "vsim fern_tb;set StdArithNoWarnings 1;run 16 ms"
