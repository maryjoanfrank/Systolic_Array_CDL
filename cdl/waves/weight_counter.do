onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_weight_counter/clk
add wave -noupdate /tb_weight_counter/n_rst
add wave -noupdate -divider {actual signals}
add wave -noupdate /tb_weight_counter/trigger_weight
add wave -noupdate /tb_weight_counter/DUT/counter/count_out
add wave -noupdate /tb_weight_counter/DUT/state
add wave -noupdate -divider {state outputs}
add wave -noupdate /tb_weight_counter/load
add wave -noupdate /tb_weight_counter/DUT/clear
add wave -noupdate /tb_weight_counter/DUT/count_enable
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {58300 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 108
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
WaveRestoreZoom {0 ps} {241500 ps}
