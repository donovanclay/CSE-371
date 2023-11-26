# Create work library
vlib work

# Compile Verilog
#     All Verilog files that are part of this design should have
#     their own "vlog" line below.
vlog "./altera_up_avalon_video_vga_timing.v"
vlog "./CLOCK25_PLL/CLOCK25_PLL_0002.v"
vlog "./CLOCK25_PLL.v"
vlog "./video_driver.sv"
vlog "./DE1_SoC.sv"

# Call vsim to invoke simulator
#     Make sure the last item on the line is the name of the
#     testbench module you want to execute.
vsim -voptargs="+acc" -t 1ps -lib work DE1_SoC_testbench -Lf altera_lnsim_ver

# Source the wave do file
#     This should be the file that sets up the signal window for
#     the module you are testing.
do DE1_SoC_wave.do

# Set the window types
view wave
view structure
view signals

# Run the simulation
run -all

# End
