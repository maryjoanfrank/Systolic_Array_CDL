onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {ACTIVATION TIMER}
add wave -noupdate /tb_peripheral/DUT/compute/activation_timer/clk
add wave -noupdate /tb_peripheral/DUT/compute/activation_timer/n_rst
add wave -noupdate /tb_peripheral/DUT/compute/activation_timer/num_inputs
add wave -noupdate /tb_peripheral/DUT/compute/activation_timer/trigger_array
add wave -noupdate /tb_peripheral/DUT/compute/activation_timer/stall
add wave -noupdate /tb_peripheral/DUT/compute/activation_timer/activated
add wave -noupdate /tb_peripheral/DUT/compute/activation_timer/state
add wave -noupdate /tb_peripheral/DUT/compute/activation_timer/state_n
add wave -noupdate /tb_peripheral/DUT/compute/activation_timer/clear
add wave -noupdate /tb_peripheral/DUT/compute/activation_timer/computing
add wave -noupdate /tb_peripheral/DUT/compute/activation_timer/rollover_flag
add wave -noupdate /tb_peripheral/DUT/compute/activation_timer/count
add wave -noupdate /tb_peripheral/DUT/compute/activation_timer/temp_activated
add wave -noupdate -divider {BIAS ADDER}
add wave -noupdate -group Bias -color Orchid /tb_peripheral/DUT/compute/bias_adder/clk
add wave -noupdate -group Bias -color Orchid /tb_peripheral/DUT/compute/bias_adder/n_rst
add wave -noupdate -group Bias -color Orchid /tb_peripheral/DUT/compute/bias_adder/enable
add wave -noupdate -group Bias -color Orchid /tb_peripheral/DUT/compute/bias_adder/array_output
add wave -noupdate -group Bias -color Orchid /tb_peripheral/DUT/compute/bias_adder/bias_vec
add wave -noupdate -group Bias -color Orchid /tb_peripheral/DUT/compute/bias_adder/bias_output
add wave -noupdate -group Bias -color Orchid /tb_peripheral/DUT/compute/bias_adder/temp
add wave -noupdate -group Bias -color Orchid /tb_peripheral/DUT/compute/bias_adder/bias_output_n
add wave -noupdate -group Bias -color Orchid /tb_peripheral/DUT/compute/bias_adder/INT8_MAX
add wave -noupdate -group Bias -color Orchid /tb_peripheral/DUT/compute/bias_adder/INT8_MIN
add wave -noupdate -divider CONTROLLER
add wave -noupdate -color {Yellow Green} /tb_peripheral/DUT/control/inst_controller/clk
add wave -noupdate -color {Yellow Green} /tb_peripheral/DUT/control/inst_controller/n_rst
add wave -noupdate -color {Yellow Green} /tb_peripheral/DUT/control/inst_controller/load_weights
add wave -noupdate -color {Yellow Green} /tb_peripheral/DUT/control/inst_controller/start_inference
add wave -noupdate -color {Yellow Green} /tb_peripheral/DUT/control/inst_controller/load_weights_en
add wave -noupdate -color {Yellow Green} /tb_peripheral/DUT/control/inst_controller/load_inputs_en
add wave -noupdate -color {Yellow Green} /tb_peripheral/DUT/control/inst_controller/input_reg
add wave -noupdate -color {Yellow Green} /tb_peripheral/DUT/control/inst_controller/weight_reg
add wave -noupdate -color {Yellow Green} /tb_peripheral/DUT/control/inst_controller/read_data0
add wave -noupdate -color {Yellow Green} /tb_peripheral/DUT/control/inst_controller/read_data1
add wave -noupdate -color {Yellow Green} /tb_peripheral/DUT/control/inst_controller/read_data2
add wave -noupdate -color {Yellow Green} /tb_peripheral/DUT/control/inst_controller/read_data3
add wave -noupdate -color {Yellow Green} /tb_peripheral/DUT/control/inst_controller/activations
add wave -noupdate -color {Yellow Green} /tb_peripheral/DUT/control/inst_controller/activated
add wave -noupdate -color {Yellow Green} /tb_peripheral/DUT/control/inst_controller/controller_busy
add wave -noupdate -color {Yellow Green} /tb_peripheral/DUT/control/inst_controller/data_ready
add wave -noupdate -color {Yellow Green} /tb_peripheral/DUT/control/inst_controller/ren
add wave -noupdate -color {Yellow Green} /tb_peripheral/DUT/control/inst_controller/wen
add wave -noupdate -color {Yellow Green} /tb_peripheral/DUT/control/inst_controller/start_weights
add wave -noupdate -color {Yellow Green} /tb_peripheral/DUT/control/inst_controller/start_array
add wave -noupdate -color {Yellow Green} /tb_peripheral/DUT/control/inst_controller/output_reg
add wave -noupdate -color {Yellow Green} /tb_peripheral/DUT/control/inst_controller/weights_done
add wave -noupdate -color {Yellow Green} /tb_peripheral/DUT/control/inst_controller/invalid
add wave -noupdate -color {Yellow Green} /tb_peripheral/DUT/control/inst_controller/enable
add wave -noupdate -color {Yellow Green} /tb_peripheral/DUT/control/inst_controller/write_data0
add wave -noupdate -color {Yellow Green} /tb_peripheral/DUT/control/inst_controller/write_data1
add wave -noupdate -color {Yellow Green} /tb_peripheral/DUT/control/inst_controller/write_data2
add wave -noupdate -color {Yellow Green} /tb_peripheral/DUT/control/inst_controller/write_data3
add wave -noupdate -color {Yellow Green} /tb_peripheral/DUT/control/inst_controller/cs0
add wave -noupdate -color {Yellow Green} /tb_peripheral/DUT/control/inst_controller/cs1
add wave -noupdate -color {Yellow Green} /tb_peripheral/DUT/control/inst_controller/cs2
add wave -noupdate -color {Yellow Green} /tb_peripheral/DUT/control/inst_controller/cs3
add wave -noupdate -color {Yellow Green} /tb_peripheral/DUT/control/inst_controller/addr
add wave -noupdate -color {Yellow Green} /tb_peripheral/DUT/control/inst_controller/systolic_data
add wave -noupdate -color {Yellow Green} /tb_peripheral/DUT/control/inst_controller/inputs_done
add wave -noupdate -color {Yellow Green} /tb_peripheral/DUT/control/inst_controller/occupancy_err
add wave -noupdate -color {Yellow Green} /tb_peripheral/DUT/control/inst_controller/num_input
add wave -noupdate -color {Yellow Green} /tb_peripheral/DUT/control/inst_controller/enable_counter_num_input_chunks
add wave -noupdate -color {Yellow Green} /tb_peripheral/DUT/control/inst_controller/num_input_chunks
add wave -noupdate -color {Yellow Green} /tb_peripheral/DUT/control/inst_controller/input_chunks_rollover
add wave -noupdate -color {Yellow Green} /tb_peripheral/DUT/control/inst_controller/no_more_inputs
add wave -noupdate -color {Yellow Green} /tb_peripheral/DUT/control/inst_controller/counter_num_input_chunks_clr
add wave -noupdate -color {Yellow Green} /tb_peripheral/DUT/control/inst_controller/enable_counter_num_input
add wave -noupdate -color {Yellow Green} /tb_peripheral/DUT/control/inst_controller/counter_num_input_clr
add wave -noupdate -color {Yellow Green} /tb_peripheral/DUT/control/inst_controller/unused_num_input_rollover
add wave -noupdate -color {Yellow Green} /tb_peripheral/DUT/control/inst_controller/unused_compute_counter
add wave -noupdate -color {Yellow Green} /tb_peripheral/DUT/control/inst_controller/compute_counter_enable
add wave -noupdate -color {Yellow Green} /tb_peripheral/DUT/control/inst_controller/compute_rollover
add wave -noupdate -color {Yellow Green} /tb_peripheral/DUT/control/inst_controller/compute_counter_clr
add wave -noupdate -color {Yellow Green} /tb_peripheral/DUT/control/inst_controller/buffout_clr
add wave -noupdate -color {Yellow Green} /tb_peripheral/DUT/control/inst_controller/buffout_rollover
add wave -noupdate -color {Yellow Green} /tb_peripheral/DUT/control/inst_controller/unused_buffout_counter
add wave -noupdate -color {Yellow Green} /tb_peripheral/DUT/control/inst_controller/buffout_counter_enable
add wave -noupdate -color {Yellow Green} /tb_peripheral/DUT/control/inst_controller/capture_clr
add wave -noupdate -color {Yellow Green} /tb_peripheral/DUT/control/inst_controller/capture_rollover
add wave -noupdate -color {Yellow Green} /tb_peripheral/DUT/control/inst_controller/unused_capture_counter
add wave -noupdate -color {Yellow Green} /tb_peripheral/DUT/control/inst_controller/capture_counter_enable
add wave -noupdate -color {Yellow Green} /tb_peripheral/DUT/control/inst_controller/state
add wave -noupdate -divider {SRAM BUFFER}
add wave -noupdate -color {Cornflower Blue} /tb_peripheral/DUT/control/inst_sram_buffer/clk
add wave -noupdate -color {Cornflower Blue} /tb_peripheral/DUT/control/inst_sram_buffer/n_rst
add wave -noupdate -color {Cornflower Blue} /tb_peripheral/DUT/control/inst_sram_buffer/ren
add wave -noupdate -color {Cornflower Blue} /tb_peripheral/DUT/control/inst_sram_buffer/wen
add wave -noupdate -color {Cornflower Blue} /tb_peripheral/DUT/control/inst_sram_buffer/addr
add wave -noupdate -color {Cornflower Blue} /tb_peripheral/DUT/control/inst_sram_buffer/write_data0
add wave -noupdate -color {Cornflower Blue} /tb_peripheral/DUT/control/inst_sram_buffer/write_data1
add wave -noupdate -color {Cornflower Blue} /tb_peripheral/DUT/control/inst_sram_buffer/write_data2
add wave -noupdate -color {Cornflower Blue} /tb_peripheral/DUT/control/inst_sram_buffer/write_data3
add wave -noupdate -color {Cornflower Blue} /tb_peripheral/DUT/control/inst_sram_buffer/chip_select
add wave -noupdate -color {Cornflower Blue} /tb_peripheral/DUT/control/inst_sram_buffer/read_data0
add wave -noupdate -color {Cornflower Blue} /tb_peripheral/DUT/control/inst_sram_buffer/read_data1
add wave -noupdate -color {Cornflower Blue} /tb_peripheral/DUT/control/inst_sram_buffer/read_data2
add wave -noupdate -color {Cornflower Blue} /tb_peripheral/DUT/control/inst_sram_buffer/read_data3
add wave -noupdate -divider {SRAM0 HIGH}
add wave -noupdate {/tb_peripheral/DUT/control/inst_sram_buffer/genblk1[0]/SRAM_HI/addr}
add wave -noupdate {/tb_peripheral/DUT/control/inst_sram_buffer/genblk1[0]/SRAM_HI/clk}
add wave -noupdate {/tb_peripheral/DUT/control/inst_sram_buffer/genblk1[0]/SRAM_HI/memory}
add wave -noupdate {/tb_peripheral/DUT/control/inst_sram_buffer/genblk1[0]/SRAM_HI/n_rst}
add wave -noupdate {/tb_peripheral/DUT/control/inst_sram_buffer/genblk1[0]/SRAM_HI/q}
add wave -noupdate {/tb_peripheral/DUT/control/inst_sram_buffer/genblk1[0]/SRAM_HI/read_data}
add wave -noupdate {/tb_peripheral/DUT/control/inst_sram_buffer/genblk1[0]/SRAM_HI/read_enable}
add wave -noupdate {/tb_peripheral/DUT/control/inst_sram_buffer/genblk1[0]/SRAM_HI/sram_state}
add wave -noupdate {/tb_peripheral/DUT/control/inst_sram_buffer/genblk1[0]/SRAM_HI/state}
add wave -noupdate {/tb_peripheral/DUT/control/inst_sram_buffer/genblk1[0]/SRAM_HI/wren}
add wave -noupdate {/tb_peripheral/DUT/control/inst_sram_buffer/genblk1[0]/SRAM_HI/write_data}
add wave -noupdate {/tb_peripheral/DUT/control/inst_sram_buffer/genblk1[0]/SRAM_HI/write_enable}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {611350 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 159
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
WaveRestoreZoom {500642 ps} {971067 ps}
