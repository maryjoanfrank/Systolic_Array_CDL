onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_fullInference/clk
add wave -noupdate /tb_fullInference/n_rst
add wave -noupdate -divider inputs
add wave -noupdate /tb_fullInference/systolic_data
add wave -noupdate -divider control
add wave -noupdate /tb_fullInference/enable
add wave -noupdate /tb_fullInference/start_weights
add wave -noupdate /tb_fullInference/start_array
add wave -noupdate /tb_fullInference/DUT/load
add wave -noupdate -divider outputs
add wave -noupdate /tb_fullInference/DUT/neuron_activation/activation_out
add wave -noupdate /tb_fullInference/activated
add wave -noupdate -divider array_internal
add wave -noupdate /tb_fullInference/DUT/systolicArray/load
add wave -noupdate /tb_fullInference/DUT/systolicArray/operand
add wave -noupdate /tb_fullInference/DUT/systolicArray/partials
add wave -noupdate -divider {load timing}
add wave -noupdate /tb_fullInference/DUT/load_timing/clear
add wave -noupdate /tb_fullInference/DUT/load_timing/count
add wave -noupdate /tb_fullInference/DUT/load_timing/load
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[0]/horizontal_loop[0]/PE_00/pe00/weight}
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[0]/horizontal_loop[1]/upper_row/pex0/weight}
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[0]/horizontal_loop[2]/upper_row/pex0/weight}
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[0]/horizontal_loop[3]/upper_row/pex0/weight}
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[0]/horizontal_loop[4]/upper_row/pex0/weight}
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[0]/horizontal_loop[5]/upper_row/pex0/weight}
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[0]/horizontal_loop[6]/upper_row/pex0/weight}
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[0]/horizontal_loop[7]/upper_row/pex0/weight}
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[1]/horizontal_loop[0]/left_column/pe0y/weight}
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[1]/horizontal_loop[1]/PE_XY/pex0/weight}
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[1]/horizontal_loop[2]/PE_XY/pex0/weight}
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[1]/horizontal_loop[3]/PE_XY/pex0/weight}
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[1]/horizontal_loop[4]/PE_XY/pex0/weight}
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[1]/horizontal_loop[5]/PE_XY/pex0/weight}
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[1]/horizontal_loop[6]/PE_XY/pex0/weight}
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[1]/horizontal_loop[7]/PE_XY/pex0/weight}
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[2]/horizontal_loop[0]/left_column/pe0y/weight}
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[2]/horizontal_loop[1]/PE_XY/pex0/weight}
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[2]/horizontal_loop[2]/PE_XY/pex0/weight}
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[2]/horizontal_loop[3]/PE_XY/pex0/weight}
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[2]/horizontal_loop[4]/PE_XY/pex0/weight}
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[2]/horizontal_loop[5]/PE_XY/pex0/weight}
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[2]/horizontal_loop[6]/PE_XY/pex0/weight}
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[2]/horizontal_loop[7]/PE_XY/pex0/weight}
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[3]/horizontal_loop[0]/left_column/pe0y/weight}
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[3]/horizontal_loop[1]/PE_XY/pex0/weight}
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[3]/horizontal_loop[2]/PE_XY/pex0/weight}
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[3]/horizontal_loop[3]/PE_XY/pex0/weight}
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[3]/horizontal_loop[4]/PE_XY/pex0/weight}
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[3]/horizontal_loop[5]/PE_XY/pex0/weight}
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[3]/horizontal_loop[6]/PE_XY/pex0/weight}
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[3]/horizontal_loop[7]/PE_XY/pex0/weight}
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[4]/horizontal_loop[0]/left_column/pe0y/weight}
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[4]/horizontal_loop[1]/PE_XY/pex0/weight}
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[4]/horizontal_loop[2]/PE_XY/pex0/weight}
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[4]/horizontal_loop[3]/PE_XY/pex0/weight}
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[4]/horizontal_loop[4]/PE_XY/pex0/weight}
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[4]/horizontal_loop[5]/PE_XY/pex0/weight}
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[4]/horizontal_loop[6]/PE_XY/pex0/weight}
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[4]/horizontal_loop[7]/PE_XY/pex0/weight}
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[5]/horizontal_loop[0]/left_column/pe0y/weight}
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[5]/horizontal_loop[1]/PE_XY/pex0/weight}
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[5]/horizontal_loop[2]/PE_XY/pex0/weight}
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[5]/horizontal_loop[3]/PE_XY/pex0/weight}
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[5]/horizontal_loop[4]/PE_XY/pex0/weight}
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[5]/horizontal_loop[5]/PE_XY/pex0/weight}
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[5]/horizontal_loop[6]/PE_XY/pex0/weight}
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[5]/horizontal_loop[7]/PE_XY/pex0/weight}
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[6]/horizontal_loop[0]/left_column/pe0y/weight}
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[6]/horizontal_loop[1]/PE_XY/pex0/weight}
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[6]/horizontal_loop[2]/PE_XY/pex0/weight}
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[6]/horizontal_loop[3]/PE_XY/pex0/weight}
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[6]/horizontal_loop[4]/PE_XY/pex0/weight}
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[6]/horizontal_loop[5]/PE_XY/pex0/weight}
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[6]/horizontal_loop[6]/PE_XY/pex0/weight}
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[6]/horizontal_loop[7]/PE_XY/pex0/weight}
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[7]/horizontal_loop[0]/left_column/pe0y/weight}
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[7]/horizontal_loop[1]/PE_XY/pex0/weight}
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[7]/horizontal_loop[2]/PE_XY/pex0/weight}
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[7]/horizontal_loop[3]/PE_XY/pex0/weight}
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[7]/horizontal_loop[4]/PE_XY/pex0/weight}
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[7]/horizontal_loop[5]/PE_XY/pex0/weight}
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[7]/horizontal_loop[6]/PE_XY/pex0/weight}
add wave -noupdate -group weights {/tb_fullInference/DUT/systolicArray/vertical_loop[7]/horizontal_loop[7]/PE_XY/pex0/weight}
add wave -noupdate -divider {activated timing}
add wave -noupdate /tb_fullInference/DUT/activation_timer/activated
add wave -noupdate /tb_fullInference/DUT/activation_timer/temp_activated
add wave -noupdate /tb_fullInference/DUT/activation_timer/stall
add wave -noupdate /tb_fullInference/DUT/activation_timer/computing
add wave -noupdate -radix decimal /tb_fullInference/DUT/activation_timer/count
add wave -noupdate /tb_fullInference/DUT/activation_timer/rollover_flag
add wave -noupdate /tb_fullInference/DUT/activation_timer/trigger_array
add wave -noupdate -divider staggering
add wave -noupdate /tb_fullInference/DUT/array_input
add wave -noupdate /tb_fullInference/DUT/temp_in
add wave -noupdate -group {input stagger} /tb_fullInference/DUT/row1/q
add wave -noupdate -group {input stagger} /tb_fullInference/DUT/row2/q
add wave -noupdate -group {input stagger} /tb_fullInference/DUT/row3/q
add wave -noupdate -group {input stagger} /tb_fullInference/DUT/row4/q
add wave -noupdate -group {input stagger} /tb_fullInference/DUT/row5/q
add wave -noupdate -group {input stagger} /tb_fullInference/DUT/row6/q
add wave -noupdate -group {input stagger} /tb_fullInference/DUT/row7/q
add wave -noupdate -group {input stagger} /tb_fullInference/DUT/row1/byte_out
add wave -noupdate -group {input stagger} /tb_fullInference/DUT/row2/byte_out
add wave -noupdate -group {input stagger} /tb_fullInference/DUT/row3/byte_out
add wave -noupdate -group {input stagger} /tb_fullInference/DUT/row4/byte_out
add wave -noupdate -group {input stagger} /tb_fullInference/DUT/row5/byte_out
add wave -noupdate -group {input stagger} /tb_fullInference/DUT/row6/byte_out
add wave -noupdate -group {input stagger} /tb_fullInference/DUT/row7/byte_out
add wave -noupdate /tb_fullInference/DUT/output_vector
add wave -noupdate -group {output stagger} /tb_fullInference/DUT/col0/q
add wave -noupdate -group {output stagger} /tb_fullInference/DUT/col1/q
add wave -noupdate -group {output stagger} /tb_fullInference/DUT/col2/q
add wave -noupdate -group {output stagger} /tb_fullInference/DUT/col3/q
add wave -noupdate -group {output stagger} /tb_fullInference/DUT/col4/q
add wave -noupdate -group {output stagger} /tb_fullInference/DUT/col5/q
add wave -noupdate -group {output stagger} /tb_fullInference/DUT/col6/q
add wave -noupdate -group {output stagger} /tb_fullInference/DUT/col0/byte_out
add wave -noupdate -group {output stagger} /tb_fullInference/DUT/col1/byte_out
add wave -noupdate -group {output stagger} /tb_fullInference/DUT/col2/byte_out
add wave -noupdate -group {output stagger} /tb_fullInference/DUT/col3/byte_out
add wave -noupdate -group {output stagger} /tb_fullInference/DUT/col4/byte_out
add wave -noupdate -group {output stagger} /tb_fullInference/DUT/col5/byte_out
add wave -noupdate -group {output stagger} /tb_fullInference/DUT/col6/byte_out
add wave -noupdate -divider bias
add wave -noupdate /tb_fullInference/DUT/bias_adder/array_output
add wave -noupdate /tb_fullInference/bias_vec
add wave -noupdate /tb_fullInference/DUT/bias_adder/bias_output
add wave -noupdate /tb_fullInference/DUT/bias_adder/enable
add wave -noupdate {/tb_fullInference/DUT/bias_adder/adders[0]/biasAdd/a}
add wave -noupdate {/tb_fullInference/DUT/bias_adder/adders[0]/biasAdd/b}
add wave -noupdate {/tb_fullInference/DUT/bias_adder/adders[0]/biasAdd/carry}
add wave -noupdate {/tb_fullInference/DUT/bias_adder/adders[0]/biasAdd/carry_in}
add wave -noupdate {/tb_fullInference/DUT/bias_adder/adders[0]/biasAdd/carry_out}
add wave -noupdate {/tb_fullInference/DUT/bias_adder/adders[0]/biasAdd/SIZE}
add wave -noupdate {/tb_fullInference/DUT/bias_adder/adders[0]/biasAdd/sum}
add wave -noupdate -divider activate
add wave -noupdate /tb_fullInference/activation_mode
add wave -noupdate /tb_fullInference/activations
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {132271 ps} 0} {{Cursor 2} {340817 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 385
configure wave -valuecolwidth 205
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
WaveRestoreZoom {0 ps} {567 ns}
