onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top_tb/clk0
add wave -noupdate /top_tb/rst_n
add wave -noupdate /top_tb/data_in
add wave -noupdate /top_tb/u_dut/u_rcv/u_clock/data_sync_o
add wave -noupdate /top_tb/u_dut/u_rcv/u_reader/sr_en_i
add wave -noupdate /top_tb/done
add wave -noupdate /top_tb/err
add wave -noupdate /top_tb/data
add wave -noupdate /top_tb/u_dut/u_rcv/u_clock/state
TreeUpdate [SetDefaultTree]
quietly wave cursor active 1
configure wave -namecolwidth 225
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 20
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
