# ACQBOARD.VHD generic .DO file
# Because modelsim was, well, sucking, I've made my own .DO 
vlib work

# actual hardware 
vcom -93 -explicit encode8b10b.vhd
vcom -93 -explicit decode8b10b.vhd
vcom -93 -explicit fibertx.vhd
vcom -93 -explicit decoder.vhd
vcom -93 -explicit fiberrx.vhd
vcom -93 -explicit databuffer.vhd
vcom -93 -explicit dspio.vhd
vcom -93 -explicit eventinputs.vhd
vcom -93 -explicit eventoutputs.vhd
vcom -93 -explicit events.vhd
vcom -93 -explicit datamux.vhd
vcom -93 -explicit eventmux.vhd
vcom -93 -explicit dspboard.vhd

-- simulation entities
vcom -93 -explicit test_mem.vhd
vcom -93 -explicit test_event.vhd

vcom -93 -explicit dspboard_testbench.vhd


vsim -t 1ps -L xilinxcorelib -lib work testbench
view wave
add wave *
view structure
