onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_byte_SR/DUT/clk
add wave -noupdate /tb_byte_SR/DUT/n_rst
add wave -noupdate -divider param
add wave -noupdate /tb_byte_SR/DUT/MSB_FIRST
add wave -noupdate /tb_byte_SR/DUT/SIZE
add wave -noupdate -divider inputs
add wave -noupdate /tb_byte_SR/DUT/load_enable
add wave -noupdate /tb_byte_SR/DUT/shift_enable
add wave -noupdate /tb_byte_SR/DUT/byte_in
add wave -noupdate /tb_byte_SR/DUT/parallel_in
add wave -noupdate -divider outputs
add wave -noupdate -color {Dark Orchid} /tb_byte_SR/DUT/byte_out
add wave -noupdate -divider internals
add wave -noupdate /tb_byte_SR/DUT/q
add wave -noupdate /tb_byte_SR/DUT/q_n
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {35090 ps} 0}
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
WaveRestoreZoom {500 ps} {210500 ps}
