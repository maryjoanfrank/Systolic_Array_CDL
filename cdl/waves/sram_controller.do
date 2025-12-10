onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group controller /tb_sram_controller/DUT/inst_controller/clk
add wave -noupdate -expand -group controller /tb_sram_controller/DUT/inst_controller/n_rst
add wave -noupdate -expand -group controller /tb_sram_controller/activated
add wave -noupdate -expand -group controller /tb_sram_controller/activations
add wave -noupdate -expand -group controller /tb_sram_controller/data_ready
add wave -noupdate -expand -group controller /tb_sram_controller/output_reg
add wave -noupdate -expand -group controller /tb_sram_controller/DUT/inst_controller/input_reg
add wave -noupdate -expand -group controller /tb_sram_controller/DUT/inst_controller/input_reg_delay
add wave -noupdate -expand -group controller /tb_sram_controller/DUT/inst_controller/load_inputs_en
add wave -noupdate -expand -group controller /tb_sram_controller/DUT/inst_controller/load_weights
add wave -noupdate -expand -group controller /tb_sram_controller/DUT/inst_controller/load_weights_en
add wave -noupdate -expand -group controller /tb_sram_controller/DUT/inst_controller/weight_reg
add wave -noupdate -expand -group controller /tb_sram_controller/DUT/inst_controller/weight_reg_delay
add wave -noupdate -expand -group controller /tb_sram_controller/DUT/inst_controller/read_data0
add wave -noupdate -expand -group controller /tb_sram_controller/DUT/inst_controller/read_data1
add wave -noupdate -expand -group controller /tb_sram_controller/DUT/inst_controller/read_data2
add wave -noupdate -expand -group controller /tb_sram_controller/DUT/inst_controller/read_data3
add wave -noupdate -expand -group controller /tb_sram_controller/DUT/inst_controller/read_data4
add wave -noupdate -expand -group controller /tb_sram_controller/DUT/inst_controller/read_data5
add wave -noupdate -expand -group controller /tb_sram_controller/DUT/inst_controller/read_data6
add wave -noupdate -expand -group controller /tb_sram_controller/DUT/inst_controller/read_data7
add wave -noupdate -expand -group controller /tb_sram_controller/DUT/inst_controller/controller_busy
add wave -noupdate -expand -group controller /tb_sram_controller/DUT/inst_controller/r_trigger
add wave -noupdate -expand -group controller /tb_sram_controller/DUT/inst_controller/w_trigger
add wave -noupdate -expand -group controller /tb_sram_controller/DUT/inst_controller/start_weights
add wave -noupdate -expand -group controller /tb_sram_controller/DUT/inst_controller/write_data0
add wave -noupdate -expand -group controller /tb_sram_controller/DUT/inst_controller/write_data1
add wave -noupdate -expand -group controller /tb_sram_controller/DUT/inst_controller/write_data2
add wave -noupdate -expand -group controller /tb_sram_controller/DUT/inst_controller/write_data3
add wave -noupdate -expand -group controller /tb_sram_controller/DUT/inst_controller/write_data4
add wave -noupdate -expand -group controller /tb_sram_controller/DUT/inst_controller/write_data5
add wave -noupdate -expand -group controller /tb_sram_controller/DUT/inst_controller/write_data6
add wave -noupdate -expand -group controller /tb_sram_controller/DUT/inst_controller/write_data7
add wave -noupdate -expand -group controller /tb_sram_controller/DUT/inst_controller/cs0
add wave -noupdate -expand -group controller /tb_sram_controller/DUT/inst_controller/cs1
add wave -noupdate -expand -group controller /tb_sram_controller/DUT/inst_controller/cs2
add wave -noupdate -expand -group controller /tb_sram_controller/DUT/inst_controller/cs3
add wave -noupdate -expand -group controller /tb_sram_controller/DUT/inst_controller/cs4
add wave -noupdate -expand -group controller /tb_sram_controller/DUT/inst_controller/cs5
add wave -noupdate -expand -group controller /tb_sram_controller/DUT/inst_controller/cs6
add wave -noupdate -expand -group controller /tb_sram_controller/DUT/inst_controller/cs7
add wave -noupdate -expand -group controller /tb_sram_controller/DUT/inst_controller/addr
add wave -noupdate -expand -group controller /tb_sram_controller/DUT/inst_controller/systolic_data
add wave -noupdate -expand -group controller /tb_sram_controller/DUT/inst_controller/state
add wave -noupdate -expand -group controller /tb_sram_controller/DUT/inst_controller/next_state
add wave -noupdate -group {sram bufffer} /tb_sram_controller/DUT/inst_sram_buffer/clk
add wave -noupdate -group {sram bufffer} /tb_sram_controller/DUT/inst_sram_buffer/n_rst
add wave -noupdate -group {sram bufffer} /tb_sram_controller/DUT/inst_sram_buffer/r_trigger
add wave -noupdate -group {sram bufffer} /tb_sram_controller/DUT/inst_sram_buffer/w_trigger
add wave -noupdate -group {sram bufffer} /tb_sram_controller/DUT/inst_sram_buffer/addr
add wave -noupdate -group {sram bufffer} /tb_sram_controller/DUT/inst_sram_buffer/write_data0
add wave -noupdate -group {sram bufffer} /tb_sram_controller/DUT/inst_sram_buffer/write_data1
add wave -noupdate -group {sram bufffer} /tb_sram_controller/DUT/inst_sram_buffer/write_data2
add wave -noupdate -group {sram bufffer} /tb_sram_controller/DUT/inst_sram_buffer/write_data3
add wave -noupdate -group {sram bufffer} /tb_sram_controller/DUT/inst_sram_buffer/write_data4
add wave -noupdate -group {sram bufffer} /tb_sram_controller/DUT/inst_sram_buffer/write_data5
add wave -noupdate -group {sram bufffer} /tb_sram_controller/DUT/inst_sram_buffer/write_data6
add wave -noupdate -group {sram bufffer} /tb_sram_controller/DUT/inst_sram_buffer/write_data7
add wave -noupdate -group {sram bufffer} /tb_sram_controller/DUT/inst_sram_buffer/chip_select
add wave -noupdate -group {sram bufffer} /tb_sram_controller/DUT/inst_sram_buffer/read_data0
add wave -noupdate -group {sram bufffer} /tb_sram_controller/DUT/inst_sram_buffer/read_data1
add wave -noupdate -group {sram bufffer} /tb_sram_controller/DUT/inst_sram_buffer/read_data2
add wave -noupdate -group {sram bufffer} /tb_sram_controller/DUT/inst_sram_buffer/read_data3
add wave -noupdate -group {sram bufffer} /tb_sram_controller/DUT/inst_sram_buffer/read_data4
add wave -noupdate -group {sram bufffer} /tb_sram_controller/DUT/inst_sram_buffer/read_data5
add wave -noupdate -group {sram bufffer} /tb_sram_controller/DUT/inst_sram_buffer/read_data6
add wave -noupdate -group {sram bufffer} /tb_sram_controller/DUT/inst_sram_buffer/read_data7
add wave -noupdate -group genblk0 /tb_sram_controller/DUT/inst_sram_buffer/addr
add wave -noupdate -group genblk0 /tb_sram_controller/DUT/inst_sram_buffer/bank_free
add wave -noupdate -group genblk0 /tb_sram_controller/DUT/inst_sram_buffer/bank_outhi
add wave -noupdate -group genblk0 /tb_sram_controller/DUT/inst_sram_buffer/bank_outlo
add wave -noupdate -group genblk0 /tb_sram_controller/DUT/inst_sram_buffer/busy
add wave -noupdate -group genblk0 /tb_sram_controller/DUT/inst_sram_buffer/chip_select
add wave -noupdate -group genblk0 /tb_sram_controller/DUT/inst_sram_buffer/clk
add wave -noupdate -group genblk0 /tb_sram_controller/DUT/inst_sram_buffer/countdown
add wave -noupdate -group genblk0 /tb_sram_controller/DUT/inst_sram_buffer/LAT
add wave -noupdate -group genblk0 /tb_sram_controller/DUT/inst_sram_buffer/latched_addr
add wave -noupdate -group genblk0 /tb_sram_controller/DUT/inst_sram_buffer/latched_ren
add wave -noupdate -group genblk0 /tb_sram_controller/DUT/inst_sram_buffer/latched_wdatahi
add wave -noupdate -group genblk0 /tb_sram_controller/DUT/inst_sram_buffer/latched_wdatalo
add wave -noupdate -group genblk0 /tb_sram_controller/DUT/inst_sram_buffer/latched_wen
add wave -noupdate -group genblk0 /tb_sram_controller/DUT/inst_sram_buffer/n_rst
add wave -noupdate -group genblk0 /tb_sram_controller/DUT/inst_sram_buffer/r_trigger
add wave -noupdate -group genblk0 /tb_sram_controller/DUT/inst_sram_buffer/read_data0
add wave -noupdate -group genblk0 /tb_sram_controller/DUT/inst_sram_buffer/read_data1
add wave -noupdate -group genblk0 /tb_sram_controller/DUT/inst_sram_buffer/read_data2
add wave -noupdate -group genblk0 /tb_sram_controller/DUT/inst_sram_buffer/read_data3
add wave -noupdate -group genblk0 /tb_sram_controller/DUT/inst_sram_buffer/read_data4
add wave -noupdate -group genblk0 /tb_sram_controller/DUT/inst_sram_buffer/read_data5
add wave -noupdate -group genblk0 /tb_sram_controller/DUT/inst_sram_buffer/read_data6
add wave -noupdate -group genblk0 /tb_sram_controller/DUT/inst_sram_buffer/read_data7
add wave -noupdate -group genblk0 /tb_sram_controller/DUT/inst_sram_buffer/w_trigger
add wave -noupdate -group genblk0 /tb_sram_controller/DUT/inst_sram_buffer/write_data0
add wave -noupdate -group genblk0 /tb_sram_controller/DUT/inst_sram_buffer/write_data1
add wave -noupdate -group genblk0 /tb_sram_controller/DUT/inst_sram_buffer/write_data2
add wave -noupdate -group genblk0 /tb_sram_controller/DUT/inst_sram_buffer/write_data3
add wave -noupdate -group genblk0 /tb_sram_controller/DUT/inst_sram_buffer/write_data4
add wave -noupdate -group genblk0 /tb_sram_controller/DUT/inst_sram_buffer/write_data5
add wave -noupdate -group genblk0 /tb_sram_controller/DUT/inst_sram_buffer/write_data6
add wave -noupdate -group genblk0 /tb_sram_controller/DUT/inst_sram_buffer/write_data7
add wave -noupdate -expand -group {sram low} {/tb_sram_controller/DUT/inst_sram_buffer/genblk1[0]/SRAM_LO/clk}
add wave -noupdate -expand -group {sram low} {/tb_sram_controller/DUT/inst_sram_buffer/genblk1[0]/SRAM_LO/n_rst}
add wave -noupdate -expand -group {sram low} {/tb_sram_controller/DUT/inst_sram_buffer/genblk1[0]/SRAM_LO/address}
add wave -noupdate -expand -group {sram low} {/tb_sram_controller/DUT/inst_sram_buffer/genblk1[0]/SRAM_LO/read_enable}
add wave -noupdate -expand -group {sram low} {/tb_sram_controller/DUT/inst_sram_buffer/genblk1[0]/SRAM_LO/write_enable}
add wave -noupdate -expand -group {sram low} {/tb_sram_controller/DUT/inst_sram_buffer/genblk1[0]/SRAM_LO/write_data}
add wave -noupdate -expand -group {sram low} {/tb_sram_controller/DUT/inst_sram_buffer/genblk1[0]/SRAM_LO/read_data}
add wave -noupdate -expand -group {sram low} {/tb_sram_controller/DUT/inst_sram_buffer/genblk1[0]/SRAM_LO/sram_state}
add wave -noupdate -expand -group {sram low} {/tb_sram_controller/DUT/inst_sram_buffer/genblk1[0]/SRAM_LO/old_write_data}
add wave -noupdate -expand -group {sram low} {/tb_sram_controller/DUT/inst_sram_buffer/genblk1[0]/SRAM_LO/old_address}
add wave -noupdate -expand -group {sram low} {/tb_sram_controller/DUT/inst_sram_buffer/genblk1[0]/SRAM_LO/q}
add wave -noupdate -expand -group {sram low} {/tb_sram_controller/DUT/inst_sram_buffer/genblk1[0]/SRAM_LO/addr}
add wave -noupdate -expand -group {sram low} {/tb_sram_controller/DUT/inst_sram_buffer/genblk1[0]/SRAM_LO/wren}
add wave -noupdate -expand -group {sram low} {/tb_sram_controller/DUT/inst_sram_buffer/genblk1[0]/SRAM_LO/ac}
add wave -noupdate -expand -group {sram low} {/tb_sram_controller/DUT/inst_sram_buffer/genblk1[0]/SRAM_LO/dc}
add wave -noupdate -expand -group {sram low} {/tb_sram_controller/DUT/inst_sram_buffer/genblk1[0]/SRAM_LO/ec}
add wave -noupdate -expand -group {sram low} {/tb_sram_controller/DUT/inst_sram_buffer/genblk1[0]/SRAM_LO/prev_wen}
add wave -noupdate -expand -group {sram low} {/tb_sram_controller/DUT/inst_sram_buffer/genblk1[0]/SRAM_LO/prev_ren}
add wave -noupdate -expand -group {sram low} {/tb_sram_controller/DUT/inst_sram_buffer/genblk1[0]/SRAM_LO/state}
add wave -noupdate -expand -group {sram low} {/tb_sram_controller/DUT/inst_sram_buffer/genblk1[0]/SRAM_LO/next_state}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1561171 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 163
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
WaveRestoreZoom {0 ps} {1706250 ps}
