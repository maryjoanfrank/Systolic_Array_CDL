onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_array/clk
add wave -noupdate /tb_array/n_rst
add wave -noupdate /tb_array/array_input
add wave -noupdate /tb_array/array_output
add wave -noupdate /tb_array/load
add wave -noupdate /tb_array/DUT/operand
add wave -noupdate /tb_array/DUT/partials
add wave -noupdate -divider {left col partials}
add wave -noupdate {/tb_array/DUT/partials[0]}
add wave -noupdate {/tb_array/DUT/partials[8]}
add wave -noupdate {/tb_array/DUT/partials[16]}
add wave -noupdate {/tb_array/DUT/partials[24]}
add wave -noupdate {/tb_array/DUT/partials[32]}
add wave -noupdate {/tb_array/DUT/partials[40]}
add wave -noupdate {/tb_array/DUT/partials[48]}
add wave -noupdate {/tb_array/DUT/partials[56]}
add wave -noupdate -divider {2nd col partials}
add wave -noupdate {/tb_array/DUT/partials[1]}
add wave -noupdate {/tb_array/DUT/partials[9]}
add wave -noupdate {/tb_array/DUT/partials[17]}
add wave -noupdate {/tb_array/DUT/partials[25]}
add wave -noupdate {/tb_array/DUT/partials[33]}
add wave -noupdate {/tb_array/DUT/partials[41]}
add wave -noupdate {/tb_array/DUT/partials[49]}
add wave -noupdate {/tb_array/DUT/partials[57]}
add wave -noupdate -divider {3rd Col partials}
add wave -noupdate {/tb_array/DUT/partials[2]}
add wave -noupdate {/tb_array/DUT/partials[10]}
add wave -noupdate {/tb_array/DUT/partials[18]}
add wave -noupdate {/tb_array/DUT/partials[26]}
add wave -noupdate {/tb_array/DUT/partials[34]}
add wave -noupdate {/tb_array/DUT/partials[42]}
add wave -noupdate {/tb_array/DUT/partials[50]}
add wave -noupdate {/tb_array/DUT/partials[58]}
add wave -noupdate -divider weights
add wave -noupdate {/tb_array/DUT/vertical_loop[0]/horizontal_loop[0]/PE_00/pe00/weight}
add wave -noupdate {/tb_array/DUT/vertical_loop[0]/horizontal_loop[1]/upper_row/pex0/weight}
add wave -noupdate {/tb_array/DUT/vertical_loop[0]/horizontal_loop[2]/upper_row/pex0/weight}
add wave -noupdate {/tb_array/DUT/vertical_loop[0]/horizontal_loop[3]/upper_row/pex0/weight}
add wave -noupdate {/tb_array/DUT/vertical_loop[0]/horizontal_loop[4]/upper_row/pex0/weight}
add wave -noupdate {/tb_array/DUT/vertical_loop[0]/horizontal_loop[5]/upper_row/pex0/weight}
add wave -noupdate {/tb_array/DUT/vertical_loop[0]/horizontal_loop[6]/upper_row/pex0/weight}
add wave -noupdate {/tb_array/DUT/vertical_loop[0]/horizontal_loop[7]/upper_row/pex0/weight}
add wave -noupdate {/tb_array/DUT/vertical_loop[1]/horizontal_loop[0]/left_column/pe0y/weight}
add wave -noupdate {/tb_array/DUT/vertical_loop[1]/horizontal_loop[1]/PE_XY/pex0/weight}
add wave -noupdate {/tb_array/DUT/vertical_loop[1]/horizontal_loop[2]/PE_XY/pex0/weight}
add wave -noupdate {/tb_array/DUT/vertical_loop[1]/horizontal_loop[3]/PE_XY/pex0/weight}
add wave -noupdate {/tb_array/DUT/vertical_loop[1]/horizontal_loop[4]/PE_XY/pex0/weight}
add wave -noupdate {/tb_array/DUT/vertical_loop[1]/horizontal_loop[5]/PE_XY/pex0/weight}
add wave -noupdate {/tb_array/DUT/vertical_loop[1]/horizontal_loop[6]/PE_XY/pex0/weight}
add wave -noupdate {/tb_array/DUT/vertical_loop[1]/horizontal_loop[7]/PE_XY/pex0/weight}
add wave -noupdate {/tb_array/DUT/vertical_loop[2]/horizontal_loop[0]/left_column/pe0y/weight}
add wave -noupdate {/tb_array/DUT/vertical_loop[2]/horizontal_loop[1]/PE_XY/pex0/weight}
add wave -noupdate {/tb_array/DUT/vertical_loop[2]/horizontal_loop[2]/PE_XY/pex0/weight}
add wave -noupdate {/tb_array/DUT/vertical_loop[2]/horizontal_loop[3]/PE_XY/pex0/weight}
add wave -noupdate {/tb_array/DUT/vertical_loop[2]/horizontal_loop[4]/PE_XY/pex0/weight}
add wave -noupdate {/tb_array/DUT/vertical_loop[2]/horizontal_loop[5]/PE_XY/pex0/weight}
add wave -noupdate {/tb_array/DUT/vertical_loop[2]/horizontal_loop[6]/PE_XY/pex0/weight}
add wave -noupdate {/tb_array/DUT/vertical_loop[2]/horizontal_loop[7]/PE_XY/pex0/weight}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {72614 ps} 0} {{Cursor 2} {265000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 291
configure wave -valuecolwidth 167
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
WaveRestoreZoom {0 ps} {304500 ps}
