onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -group TOP_TB /tb_top/clk
add wave -noupdate -group TOP_TB /tb_top/n_rst
add wave -noupdate -group TOP_TB /tb_top/hsel
add wave -noupdate -group TOP_TB /tb_top/haddr
add wave -noupdate -group TOP_TB /tb_top/hsize
add wave -noupdate -group TOP_TB /tb_top/hburst
add wave -noupdate -group TOP_TB /tb_top/htrans
add wave -noupdate -group TOP_TB /tb_top/hwrite
add wave -noupdate -group TOP_TB /tb_top/hwdata
add wave -noupdate -group TOP_TB /tb_top/hrdata
add wave -noupdate -group TOP_TB /tb_top/hresp
add wave -noupdate -group TOP_TB /tb_top/hready
add wave -noupdate -expand -group compute -color {Yellow Green} /tb_top/dut/accelerator/compute/clk
add wave -noupdate -expand -group compute -color {Yellow Green} /tb_top/dut/accelerator/compute/n_rst
add wave -noupdate -expand -group compute -color {Yellow Green} /tb_top/dut/accelerator/compute/start_weights
add wave -noupdate -expand -group compute -color {Yellow Green} /tb_top/dut/accelerator/compute/start_array
add wave -noupdate -expand -group compute -color {Yellow Green} /tb_top/dut/accelerator/compute/enable
add wave -noupdate -expand -group compute -color {Yellow Green} /tb_top/dut/accelerator/compute/systolic_data
add wave -noupdate -expand -group compute -color {Yellow Green} /tb_top/dut/accelerator/compute/bias_vec
add wave -noupdate -expand -group compute -color {Yellow Green} /tb_top/dut/accelerator/compute/activation_mode
add wave -noupdate -expand -group compute -color {Yellow Green} /tb_top/dut/accelerator/compute/activations
add wave -noupdate -expand -group compute -color {Yellow Green} /tb_top/dut/accelerator/compute/activated
add wave -noupdate -expand -group compute -color {Yellow Green} /tb_top/dut/accelerator/compute/systolic_done
add wave -noupdate -expand -group compute -color {Yellow Green} /tb_top/dut/accelerator/compute/load
add wave -noupdate -expand -group compute -color {Yellow Green} /tb_top/dut/accelerator/compute/array_input
add wave -noupdate -expand -group compute -color {Yellow Green} /tb_top/dut/accelerator/compute/array_output
add wave -noupdate -expand -group compute -color {Yellow Green} /tb_top/dut/accelerator/compute/temp_in
add wave -noupdate -expand -group compute -color {Yellow Green} /tb_top/dut/accelerator/compute/output_vector
add wave -noupdate -expand -group compute -color {Yellow Green} /tb_top/dut/accelerator/compute/bias_output
add wave -noupdate -expand -group control -color {Cornflower Blue} /tb_top/dut/accelerator/control/clk
add wave -noupdate -expand -group control -color {Cornflower Blue} /tb_top/dut/accelerator/control/n_rst
add wave -noupdate -expand -group control -color {Cornflower Blue} /tb_top/dut/accelerator/control/load_weights
add wave -noupdate -expand -group control -color {Cornflower Blue} /tb_top/dut/accelerator/control/start_inference
add wave -noupdate -expand -group control -color {Cornflower Blue} /tb_top/dut/accelerator/control/load_weights_en
add wave -noupdate -expand -group control -color {Cornflower Blue} /tb_top/dut/accelerator/control/load_inputs_en
add wave -noupdate -expand -group control -color {Cornflower Blue} /tb_top/dut/accelerator/control/activated
add wave -noupdate -expand -group control -color {Cornflower Blue} /tb_top/dut/accelerator/control/input_reg
add wave -noupdate -expand -group control -color {Cornflower Blue} /tb_top/dut/accelerator/control/weight_reg
add wave -noupdate -expand -group control -color {Cornflower Blue} /tb_top/dut/accelerator/control/activations
add wave -noupdate -expand -group control -color {Cornflower Blue} /tb_top/dut/accelerator/control/controller_busy
add wave -noupdate -expand -group control -color {Cornflower Blue} /tb_top/dut/accelerator/control/data_ready
add wave -noupdate -expand -group control -color Violet /tb_top/dut/accelerator/control/output_reg
add wave -noupdate -expand -group control -color {Cornflower Blue} /tb_top/dut/accelerator/control/weights_done
add wave -noupdate -expand -group control -color {Cornflower Blue} /tb_top/dut/accelerator/control/inputs_done
add wave -noupdate -expand -group control -color Violet /tb_top/dut/accelerator/control/occupancy_err
add wave -noupdate -expand -group control -color {Cornflower Blue} /tb_top/dut/accelerator/control/start_weights
add wave -noupdate -expand -group control -color {Cornflower Blue} /tb_top/dut/accelerator/control/start_array
add wave -noupdate -expand -group control -color {Cornflower Blue} /tb_top/dut/accelerator/control/systolic_data
add wave -noupdate -expand -group control -color {Cornflower Blue} /tb_top/dut/accelerator/control/enable
add wave -noupdate -expand -group control -color {Cornflower Blue} /tb_top/dut/accelerator/control/r_trigger
add wave -noupdate -expand -group control -color {Cornflower Blue} /tb_top/dut/accelerator/control/w_trigger
add wave -noupdate -expand -group control -color {Cornflower Blue} /tb_top/dut/accelerator/control/addr
add wave -noupdate -expand -group control /tb_top/dut/accelerator/control/inst_controller/state
add wave -noupdate -expand -group control -color {Cornflower Blue} /tb_top/dut/accelerator/control/write_data0
add wave -noupdate -expand -group control -color {Cornflower Blue} /tb_top/dut/accelerator/control/write_data1
add wave -noupdate -expand -group control -color {Cornflower Blue} /tb_top/dut/accelerator/control/write_data2
add wave -noupdate -expand -group control -color {Cornflower Blue} /tb_top/dut/accelerator/control/write_data3
add wave -noupdate -expand -group control -color {Cornflower Blue} /tb_top/dut/accelerator/control/write_data4
add wave -noupdate -expand -group control -color {Cornflower Blue} /tb_top/dut/accelerator/control/write_data5
add wave -noupdate -expand -group control -color {Cornflower Blue} /tb_top/dut/accelerator/control/write_data6
add wave -noupdate -expand -group control -color {Cornflower Blue} /tb_top/dut/accelerator/control/write_data7
add wave -noupdate -expand -group control -color {Cornflower Blue} /tb_top/dut/accelerator/control/read_data0
add wave -noupdate -expand -group control -color {Cornflower Blue} /tb_top/dut/accelerator/control/read_data1
add wave -noupdate -expand -group control -color {Cornflower Blue} /tb_top/dut/accelerator/control/read_data2
add wave -noupdate -expand -group control -color {Cornflower Blue} /tb_top/dut/accelerator/control/read_data3
add wave -noupdate -expand -group control -color {Cornflower Blue} /tb_top/dut/accelerator/control/read_data4
add wave -noupdate -expand -group control -color {Cornflower Blue} /tb_top/dut/accelerator/control/read_data5
add wave -noupdate -expand -group control -color {Cornflower Blue} /tb_top/dut/accelerator/control/read_data6
add wave -noupdate -expand -group control -color {Cornflower Blue} /tb_top/dut/accelerator/control/read_data7
add wave -noupdate -expand -group control -color {Cornflower Blue} /tb_top/dut/accelerator/control/cs0
add wave -noupdate -expand -group control -color {Cornflower Blue} /tb_top/dut/accelerator/control/cs1
add wave -noupdate -expand -group control -color {Cornflower Blue} /tb_top/dut/accelerator/control/cs2
add wave -noupdate -expand -group control -color {Cornflower Blue} /tb_top/dut/accelerator/control/cs3
add wave -noupdate -expand -group control -color {Cornflower Blue} /tb_top/dut/accelerator/control/cs4
add wave -noupdate -expand -group control -color {Cornflower Blue} /tb_top/dut/accelerator/control/cs5
add wave -noupdate -expand -group control -color {Cornflower Blue} /tb_top/dut/accelerator/control/cs6
add wave -noupdate -expand -group control -color {Cornflower Blue} /tb_top/dut/accelerator/control/cs7
add wave -noupdate -expand -group control -color {Cornflower Blue} /tb_top/dut/accelerator/control/chip_select
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {39913333 ps} 0}
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
WaveRestoreZoom {0 ps} {65373 ns}
bookmark add wave bookmark0 {{0 ps} {680683 ps}} 37
bookmark add wave bookmark1 {{0 ps} {23163 ns}} 20
bookmark add wave bookmark2 {{0 ps} {65373 ns}} 20
