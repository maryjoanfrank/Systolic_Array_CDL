onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_AHB_CDL/DUT/clk
add wave -noupdate /tb_AHB_CDL/DUT/n_rst
add wave -noupdate /tb_AHB_CDL/reset_done
add wave -noupdate /tb_AHB_CDL/testcase
add wave -noupdate /tb_AHB_CDL/DUT/hsel
add wave -noupdate -radix decimal /tb_AHB_CDL/DUT/haddr
add wave -noupdate /tb_AHB_CDL/DUT/htrans
add wave -noupdate /tb_AHB_CDL/DUT/hsize
add wave -noupdate /tb_AHB_CDL/DUT/hwrite
add wave -noupdate -radix decimal /tb_AHB_CDL/DUT/hrdata
add wave -noupdate -radix decimal /tb_AHB_CDL/DUT/hwdata
add wave -noupdate /tb_AHB_CDL/DUT/hburst
add wave -noupdate /tb_AHB_CDL/DUT/hready
add wave -noupdate /tb_AHB_CDL/DUT/hresp
add wave -noupdate /tb_AHB_CDL/DUT/controller_busy
add wave -noupdate /tb_AHB_CDL/DUT/data_ready
add wave -noupdate /tb_AHB_CDL/DUT/output_reg
add wave -noupdate /tb_AHB_CDL/DUT/buffer_error
add wave -noupdate /tb_AHB_CDL/DUT/weight_done
add wave -noupdate /tb_AHB_CDL/DUT/input_done
add wave -noupdate /tb_AHB_CDL/DUT/input_data
add wave -noupdate /tb_AHB_CDL/DUT/weight
add wave -noupdate /tb_AHB_CDL/DUT/weight_write_en
add wave -noupdate /tb_AHB_CDL/DUT/input_write_en
add wave -noupdate /tb_AHB_CDL/DUT/start_inference
add wave -noupdate /tb_AHB_CDL/DUT/load_weights
add wave -noupdate /tb_AHB_CDL/DUT/activation_mode
add wave -noupdate /tb_AHB_CDL/DUT/bias
add wave -noupdate /tb_AHB_CDL/DUT/current_state
add wave -noupdate /tb_AHB_CDL/DUT/next_state
add wave -noupdate /tb_AHB_CDL/DUT/hsel_reg
add wave -noupdate /tb_AHB_CDL/DUT/haddr_reg
add wave -noupdate /tb_AHB_CDL/DUT/htrans_reg
add wave -noupdate /tb_AHB_CDL/DUT/hsize_reg
add wave -noupdate /tb_AHB_CDL/DUT/hwrite_reg
add wave -noupdate /tb_AHB_CDL/DUT/hburst_reg
add wave -noupdate /tb_AHB_CDL/DUT/weight_reg
add wave -noupdate /tb_AHB_CDL/DUT/input_reg
add wave -noupdate /tb_AHB_CDL/DUT/bias_reg
add wave -noupdate /tb_AHB_CDL/DUT/control_reg
add wave -noupdate /tb_AHB_CDL/DUT/control
add wave -noupdate /tb_AHB_CDL/DUT/act_control_reg
add wave -noupdate /tb_AHB_CDL/DUT/act_control
add wave -noupdate /tb_AHB_CDL/DUT/controller_reg
add wave -noupdate /tb_AHB_CDL/DUT/store_hrdata
add wave -noupdate /tb_AHB_CDL/DUT/burst_active
add wave -noupdate /tb_AHB_CDL/DUT/burst_active_reg
add wave -noupdate /tb_AHB_CDL/DUT/burst_addr_reg
add wave -noupdate /tb_AHB_CDL/DUT/burst_addr_next
add wave -noupdate /tb_AHB_CDL/DUT/burst_base_addr_reg
add wave -noupdate /tb_AHB_CDL/DUT/burst_base_addr_next
add wave -noupdate /tb_AHB_CDL/DUT/burst_beats_reg
add wave -noupdate /tb_AHB_CDL/DUT/burst_beats_next
add wave -noupdate /tb_AHB_CDL/DUT/burst_type_reg
add wave -noupdate /tb_AHB_CDL/DUT/burst_type_next
add wave -noupdate /tb_AHB_CDL/DUT/burst_length
add wave -noupdate /tb_AHB_CDL/DUT/burst_increment
add wave -noupdate /tb_AHB_CDL/DUT/beat_shift
add wave -noupdate /tb_AHB_CDL/DUT/boundary
add wave -noupdate /tb_AHB_CDL/DUT/wrap_mask
add wave -noupdate /tb_AHB_CDL/DUT/align_mask
add wave -noupdate /tb_AHB_CDL/DUT/wrap_align_mask
add wave -noupdate /tb_AHB_CDL/DUT/error_flag_reg
add wave -noupdate /tb_AHB_CDL/DUT/error_detected_now
add wave -noupdate /tb_AHB_CDL/DUT/error_flag_next
add wave -noupdate /tb_AHB_CDL/DUT/stall_active
add wave -noupdate /tb_AHB_CDL/DUT/effective_addr
add wave -noupdate /tb_AHB_CDL/DUT/raw_hazard
add wave -noupdate /tb_AHB_CDL/DUT/clear_error
add wave -noupdate /tb_AHB_CDL/DUT/valid_transfer
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {113834 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
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
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {126 ns}
