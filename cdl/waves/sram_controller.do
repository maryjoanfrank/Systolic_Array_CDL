onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider sram+controller
add wave -noupdate /tb_sram_controller/clk
add wave -noupdate /tb_sram_controller/n_rst
add wave -noupdate /tb_sram_controller/load_weights
add wave -noupdate /tb_sram_controller/start_inference
add wave -noupdate /tb_sram_controller/load_weights_en
add wave -noupdate /tb_sram_controller/load_inputs_en
add wave -noupdate /tb_sram_controller/input_reg
add wave -noupdate /tb_sram_controller/weight_reg
add wave -noupdate /tb_sram_controller/activation_ready
add wave -noupdate /tb_sram_controller/activations
add wave -noupdate /tb_sram_controller/controller_busy
add wave -noupdate /tb_sram_controller/data_ready
add wave -noupdate /tb_sram_controller/output_reg
add wave -noupdate /tb_sram_controller/systolic_data
add wave -noupdate /tb_sram_controller/weights_done
add wave -noupdate /tb_sram_controller/inputs_done
add wave -noupdate -divider controller
add wave -noupdate -color {Cornflower Blue} /tb_sram_controller/DUT/inst_controller/clk
add wave -noupdate -color {Cornflower Blue} /tb_sram_controller/DUT/inst_controller/n_rst
add wave -noupdate -color {Cornflower Blue} /tb_sram_controller/DUT/inst_controller/load_weights
add wave -noupdate -color {Cornflower Blue} /tb_sram_controller/DUT/inst_controller/start_inference
add wave -noupdate -color {Cornflower Blue} /tb_sram_controller/DUT/inst_controller/load_weights_en
add wave -noupdate -color {Cornflower Blue} /tb_sram_controller/DUT/inst_controller/load_inputs_en
add wave -noupdate -color {Cornflower Blue} /tb_sram_controller/DUT/inst_controller/activation_ready
add wave -noupdate -color {Cornflower Blue} /tb_sram_controller/DUT/inst_controller/input_reg
add wave -noupdate -color {Cornflower Blue} /tb_sram_controller/DUT/inst_controller/weight_reg
add wave -noupdate -color {Cornflower Blue} /tb_sram_controller/DUT/inst_controller/read_data0
add wave -noupdate -color {Cornflower Blue} /tb_sram_controller/DUT/inst_controller/read_data1
add wave -noupdate -color {Cornflower Blue} /tb_sram_controller/DUT/inst_controller/read_data2
add wave -noupdate -color {Cornflower Blue} /tb_sram_controller/DUT/inst_controller/read_data3
add wave -noupdate -color {Cornflower Blue} /tb_sram_controller/DUT/inst_controller/activations
add wave -noupdate -color {Cornflower Blue} /tb_sram_controller/DUT/inst_controller/controller_busy
add wave -noupdate -color {Cornflower Blue} /tb_sram_controller/DUT/inst_controller/data_ready
add wave -noupdate -color {Cornflower Blue} /tb_sram_controller/DUT/inst_controller/ren
add wave -noupdate -color {Cornflower Blue} /tb_sram_controller/DUT/inst_controller/wen
add wave -noupdate -color {Cornflower Blue} /tb_sram_controller/DUT/inst_controller/start_weights
add wave -noupdate -color {Cornflower Blue} /tb_sram_controller/DUT/inst_controller/start_array
add wave -noupdate -color {Cornflower Blue} /tb_sram_controller/DUT/inst_controller/output_reg
add wave -noupdate -color {Cornflower Blue} /tb_sram_controller/DUT/inst_controller/weights_done
add wave -noupdate -color {Cornflower Blue} /tb_sram_controller/DUT/inst_controller/cs0
add wave -noupdate -color {Cornflower Blue} /tb_sram_controller/DUT/inst_controller/cs1
add wave -noupdate -color {Cornflower Blue} /tb_sram_controller/DUT/inst_controller/cs2
add wave -noupdate -color {Cornflower Blue} /tb_sram_controller/DUT/inst_controller/cs3
add wave -noupdate -color {Cornflower Blue} /tb_sram_controller/DUT/inst_controller/addr
add wave -noupdate -color {Cornflower Blue} /tb_sram_controller/DUT/inst_controller/systolic_data
add wave -noupdate -color {Cornflower Blue} /tb_sram_controller/DUT/inst_controller/inputs_done
add wave -noupdate -color {Cornflower Blue} /tb_sram_controller/DUT/inst_controller/occupancy_err
add wave -noupdate -color {Cornflower Blue} /tb_sram_controller/DUT/inst_controller/num_input
add wave -noupdate -color {Cornflower Blue} /tb_sram_controller/DUT/inst_controller/enable_counter_num_input_chunks
add wave -noupdate -color {Cornflower Blue} /tb_sram_controller/DUT/inst_controller/num_input_chunks
add wave -noupdate -color {Cornflower Blue} /tb_sram_controller/DUT/inst_controller/input_chunks_rollover
add wave -noupdate -color {Cornflower Blue} /tb_sram_controller/DUT/inst_controller/no_more_inputs
add wave -noupdate -color {Cornflower Blue} /tb_sram_controller/DUT/inst_controller/enable_counter_num_input
add wave -noupdate -color {Cornflower Blue} /tb_sram_controller/DUT/inst_controller/unused_num_input_rollover
add wave -noupdate -color {Cornflower Blue} /tb_sram_controller/DUT/inst_controller/unused_compute_counter
add wave -noupdate -color {Cornflower Blue} /tb_sram_controller/DUT/inst_controller/compute_counter_enable
add wave -noupdate -color {Cornflower Blue} /tb_sram_controller/DUT/inst_controller/compute_rollover
add wave -noupdate -color {Cornflower Blue} /tb_sram_controller/DUT/inst_controller/buffout_clr
add wave -noupdate -color {Cornflower Blue} /tb_sram_controller/DUT/inst_controller/buffout_rollover
add wave -noupdate -color {Cornflower Blue} /tb_sram_controller/DUT/inst_controller/unused_buffout_counter
add wave -noupdate -color {Cornflower Blue} /tb_sram_controller/DUT/inst_controller/buffout_counter_enable
add wave -noupdate -color {Cornflower Blue} /tb_sram_controller/DUT/inst_controller/capture_clr
add wave -noupdate -color {Cornflower Blue} /tb_sram_controller/DUT/inst_controller/capture_rollover
add wave -noupdate -color {Cornflower Blue} /tb_sram_controller/DUT/inst_controller/unused_capture_counter
add wave -noupdate -color {Cornflower Blue} /tb_sram_controller/DUT/inst_controller/capture_counter_enable
add wave -noupdate /tb_sram_controller/DUT/inst_controller/write_data3
add wave -noupdate /tb_sram_controller/DUT/inst_controller/write_data2
add wave -noupdate /tb_sram_controller/DUT/inst_controller/write_data1
add wave -noupdate /tb_sram_controller/DUT/inst_controller/write_data0
add wave -noupdate /tb_sram_controller/DUT/inst_controller/activated
add wave -noupdate -color {Cornflower Blue} /tb_sram_controller/DUT/inst_controller/state
add wave -noupdate -color {Cornflower Blue} /tb_sram_controller/DUT/inst_controller/next_state
add wave -noupdate -divider sram_buffer
add wave -noupdate /tb_sram_controller/DUT/inst_sram_buffer/clk
add wave -noupdate /tb_sram_controller/DUT/inst_sram_buffer/n_rst
add wave -noupdate /tb_sram_controller/DUT/inst_sram_buffer/ren
add wave -noupdate /tb_sram_controller/DUT/inst_sram_buffer/wen
add wave -noupdate /tb_sram_controller/DUT/inst_sram_buffer/addr
add wave -noupdate /tb_sram_controller/DUT/inst_sram_buffer/chip_select
add wave -noupdate /tb_sram_controller/DUT/write_data3
add wave -noupdate /tb_sram_controller/DUT/write_data2
add wave -noupdate /tb_sram_controller/DUT/write_data1
add wave -noupdate /tb_sram_controller/DUT/write_data0
add wave -noupdate /tb_sram_controller/DUT/inst_sram_buffer/read_data0
add wave -noupdate /tb_sram_controller/DUT/inst_sram_buffer/read_data1
add wave -noupdate /tb_sram_controller/DUT/inst_sram_buffer/read_data2
add wave -noupdate /tb_sram_controller/DUT/inst_sram_buffer/read_data3
add wave -noupdate -divider genblk0
add wave -noupdate /tb_sram_controller/DUT/inst_sram_buffer/wen
add wave -noupdate /tb_sram_controller/DUT/inst_sram_buffer/ren
add wave -noupdate /tb_sram_controller/DUT/inst_sram_buffer/read_data3
add wave -noupdate /tb_sram_controller/DUT/inst_sram_buffer/read_data2
add wave -noupdate /tb_sram_controller/DUT/inst_sram_buffer/read_data1
add wave -noupdate /tb_sram_controller/DUT/inst_sram_buffer/read_data0
add wave -noupdate /tb_sram_controller/DUT/inst_sram_buffer/n_rst
add wave -noupdate /tb_sram_controller/DUT/inst_sram_buffer/clk
add wave -noupdate /tb_sram_controller/DUT/inst_sram_buffer/chip_select
add wave -noupdate /tb_sram_controller/DUT/inst_sram_buffer/bank_outlo
add wave -noupdate /tb_sram_controller/DUT/inst_sram_buffer/bank_outhi
add wave -noupdate /tb_sram_controller/DUT/inst_sram_buffer/bank_free
add wave -noupdate /tb_sram_controller/DUT/inst_sram_buffer/addr
add wave -noupdate /tb_sram_controller/DUT/inst_sram_buffer/countdown
add wave -noupdate /tb_sram_controller/DUT/inst_sram_buffer/busy
add wave -noupdate /tb_sram_controller/DUT/inst_sram_buffer/latched_wen
add wave -noupdate /tb_sram_controller/DUT/inst_sram_buffer/latched_wdatalo
add wave -noupdate /tb_sram_controller/DUT/inst_sram_buffer/latched_wdatahi
add wave -noupdate /tb_sram_controller/DUT/inst_sram_buffer/latched_ren
add wave -noupdate /tb_sram_controller/DUT/inst_sram_buffer/latched_addr
add wave -noupdate /tb_sram_controller/DUT/inst_sram_buffer/latched_wen
add wave -noupdate /tb_sram_controller/DUT/inst_sram_buffer/latched_wdatalo
add wave -noupdate /tb_sram_controller/DUT/inst_sram_buffer/latched_wdatahi
add wave -noupdate /tb_sram_controller/DUT/inst_sram_buffer/latched_ren
add wave -noupdate /tb_sram_controller/DUT/inst_sram_buffer/latched_addr
add wave -noupdate -divider SRAM_LOW0
add wave -noupdate {/tb_sram_controller/DUT/inst_sram_buffer/genblk1[0]/SRAM_LO/clk}
add wave -noupdate {/tb_sram_controller/DUT/inst_sram_buffer/genblk1[0]/SRAM_LO/n_rst}
add wave -noupdate {/tb_sram_controller/DUT/inst_sram_buffer/genblk1[0]/SRAM_LO/address}
add wave -noupdate {/tb_sram_controller/DUT/inst_sram_buffer/genblk1[0]/SRAM_LO/read_enable}
add wave -noupdate {/tb_sram_controller/DUT/inst_sram_buffer/genblk1[0]/SRAM_LO/write_enable}
add wave -noupdate {/tb_sram_controller/DUT/inst_sram_buffer/genblk1[0]/SRAM_LO/write_data}
add wave -noupdate {/tb_sram_controller/DUT/inst_sram_buffer/genblk1[0]/SRAM_LO/read_data}
add wave -noupdate {/tb_sram_controller/DUT/inst_sram_buffer/genblk1[0]/SRAM_LO/sram_state}
add wave -noupdate {/tb_sram_controller/DUT/inst_sram_buffer/genblk1[0]/SRAM_LO/old_write_data}
add wave -noupdate {/tb_sram_controller/DUT/inst_sram_buffer/genblk1[0]/SRAM_LO/old_address}
add wave -noupdate {/tb_sram_controller/DUT/inst_sram_buffer/genblk1[0]/SRAM_LO/q}
add wave -noupdate {/tb_sram_controller/DUT/inst_sram_buffer/genblk1[0]/SRAM_LO/addr}
add wave -noupdate {/tb_sram_controller/DUT/inst_sram_buffer/genblk1[0]/SRAM_LO/wren}
add wave -noupdate {/tb_sram_controller/DUT/inst_sram_buffer/genblk1[0]/SRAM_LO/ac}
add wave -noupdate {/tb_sram_controller/DUT/inst_sram_buffer/genblk1[0]/SRAM_LO/dc}
add wave -noupdate {/tb_sram_controller/DUT/inst_sram_buffer/genblk1[0]/SRAM_LO/ec}
add wave -noupdate {/tb_sram_controller/DUT/inst_sram_buffer/genblk1[0]/SRAM_LO/prev_wen}
add wave -noupdate {/tb_sram_controller/DUT/inst_sram_buffer/genblk1[0]/SRAM_LO/prev_ren}
add wave -noupdate {/tb_sram_controller/DUT/inst_sram_buffer/genblk1[0]/SRAM_LO/state}
add wave -noupdate {/tb_sram_controller/DUT/inst_sram_buffer/genblk1[0]/SRAM_LO/next_state}
add wave -noupdate -expand {/tb_sram_controller/DUT/inst_sram_buffer/genblk1[0]/SRAM_LO/memory}
add wave -noupdate -divider SRAM_LOW3
add wave -noupdate {/tb_sram_controller/DUT/inst_sram_buffer/genblk1[3]/SRAM_LO/clk}
add wave -noupdate {/tb_sram_controller/DUT/inst_sram_buffer/genblk1[3]/SRAM_LO/n_rst}
add wave -noupdate {/tb_sram_controller/DUT/inst_sram_buffer/genblk1[3]/SRAM_LO/address}
add wave -noupdate {/tb_sram_controller/DUT/inst_sram_buffer/genblk1[3]/SRAM_LO/read_enable}
add wave -noupdate {/tb_sram_controller/DUT/inst_sram_buffer/genblk1[3]/SRAM_LO/write_enable}
add wave -noupdate {/tb_sram_controller/DUT/inst_sram_buffer/genblk1[3]/SRAM_LO/write_data}
add wave -noupdate {/tb_sram_controller/DUT/inst_sram_buffer/genblk1[3]/SRAM_LO/read_data}
add wave -noupdate {/tb_sram_controller/DUT/inst_sram_buffer/genblk1[3]/SRAM_LO/sram_state}
add wave -noupdate {/tb_sram_controller/DUT/inst_sram_buffer/genblk1[3]/SRAM_LO/old_write_data}
add wave -noupdate {/tb_sram_controller/DUT/inst_sram_buffer/genblk1[3]/SRAM_LO/old_address}
add wave -noupdate {/tb_sram_controller/DUT/inst_sram_buffer/genblk1[3]/SRAM_LO/q}
add wave -noupdate {/tb_sram_controller/DUT/inst_sram_buffer/genblk1[3]/SRAM_LO/addr}
add wave -noupdate {/tb_sram_controller/DUT/inst_sram_buffer/genblk1[3]/SRAM_LO/wren}
add wave -noupdate {/tb_sram_controller/DUT/inst_sram_buffer/genblk1[3]/SRAM_LO/ac}
add wave -noupdate {/tb_sram_controller/DUT/inst_sram_buffer/genblk1[3]/SRAM_LO/dc}
add wave -noupdate {/tb_sram_controller/DUT/inst_sram_buffer/genblk1[3]/SRAM_LO/ec}
add wave -noupdate {/tb_sram_controller/DUT/inst_sram_buffer/genblk1[3]/SRAM_LO/prev_wen}
add wave -noupdate {/tb_sram_controller/DUT/inst_sram_buffer/genblk1[3]/SRAM_LO/prev_ren}
add wave -noupdate {/tb_sram_controller/DUT/inst_sram_buffer/genblk1[3]/SRAM_LO/state}
add wave -noupdate /tb_sram_controller/DUT/inst_controller/write_data3
add wave -noupdate /tb_sram_controller/DUT/inst_controller/write_data2
add wave -noupdate /tb_sram_controller/DUT/inst_controller/write_data1
add wave -noupdate /tb_sram_controller/DUT/inst_controller/write_data0
add wave -noupdate /tb_sram_controller/DUT/inst_controller/activated
add wave -noupdate {/tb_sram_controller/DUT/inst_sram_buffer/genblk1[3]/SRAM_LO/next_state}
add wave -noupdate -divider {compute counter}
add wave -noupdate -color {Dark Orchid} /tb_sram_controller/DUT/inst_controller/flex_counter_compute/clk
add wave -noupdate -color {Dark Orchid} /tb_sram_controller/DUT/inst_controller/flex_counter_compute/n_rst
add wave -noupdate -color {Dark Orchid} /tb_sram_controller/DUT/inst_controller/flex_counter_compute/clear
add wave -noupdate -color {Dark Orchid} /tb_sram_controller/DUT/inst_controller/flex_counter_compute/count_enable
add wave -noupdate -color {Dark Orchid} /tb_sram_controller/DUT/inst_controller/flex_counter_compute/rollover_val
add wave -noupdate -color {Dark Orchid} /tb_sram_controller/DUT/inst_controller/flex_counter_compute/count_out
add wave -noupdate -color {Dark Orchid} /tb_sram_controller/DUT/inst_controller/flex_counter_compute/rollover_flag
add wave -noupdate -color {Dark Orchid} /tb_sram_controller/DUT/inst_controller/flex_counter_compute/next_count
add wave -noupdate -color {Dark Orchid} /tb_sram_controller/DUT/inst_controller/flex_counter_compute/next_flag
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {449532 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 151
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
configure wave -timelineunits ns
update
WaveRestoreZoom {329343 ps} {682614 ps}
