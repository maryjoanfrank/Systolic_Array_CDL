onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_processingElement/clk
add wave -noupdate /tb_processingElement/n_rst
add wave -noupdate -divider Inputs
add wave -noupdate /tb_processingElement/load
add wave -noupdate -color {Medium Spring Green} -radix decimal /tb_processingElement/input_byte
add wave -noupdate -radix decimal /tb_processingElement/partial_in
add wave -noupdate -divider Outputs
add wave -noupdate -color {Dark Orchid} -radix decimal /tb_processingElement/partial_out
add wave -noupdate -radix decimal /tb_processingElement/operand_out
add wave -noupdate -divider Intermediates
add wave -noupdate -color {Medium Spring Green} -radix decimal /tb_processingElement/DUT/weight
add wave -noupdate -radix binary /tb_processingElement/DUT/sum_out
add wave -noupdate -radix decimal /tb_processingElement/DUT/clipped_partial
add wave -noupdate -radix decimal /tb_processingElement/DUT/mult_clipped
add wave -noupdate -radix decimal /tb_processingElement/DUT/mult_true
add wave -noupdate -radix decimal /tb_processingElement/DUT/tree_out
add wave -noupdate -divider Adder
add wave -noupdate /tb_processingElement/DUT/temp_add
add wave -noupdate -childformat {{{/tb_processingElement/DUT/temp_sum[0]} -radix decimal}} -subitemconfig {{/tb_processingElement/DUT/temp_sum[0]} {-height 16 -radix decimal}} /tb_processingElement/DUT/temp_sum
add wave -noupdate -radix binary /tb_processingElement/DUT/input_ext
add wave -noupdate -radix binary /tb_processingElement/DUT/weight_ext
add wave -noupdate -divider verify
add wave -noupdate -color {Medium Spring Green} -radix decimal /tb_processingElement/DUT/weight
add wave -noupdate -color {Medium Spring Green} -radix decimal /tb_processingElement/input_byte
add wave -noupdate -radix decimal /tb_processingElement/partial_in
add wave -noupdate -color {Dark Orchid} -radix decimal /tb_processingElement/partial_out
add wave -noupdate /tb_processingElement/load
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {91090 ps} 0} {{Cursor 2} {15022 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 270
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
