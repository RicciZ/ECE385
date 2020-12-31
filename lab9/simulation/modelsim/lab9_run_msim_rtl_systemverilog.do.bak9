transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlib lab9_soc
vmap lab9_soc lab9_soc
vlog -sv -work lab9_soc +incdir+D:/Quartus/ECE385/lab9/lab9_soc/synthesis/submodules {D:/Quartus/ECE385/lab9/lab9_soc/synthesis/submodules/avalon_aes_interface.sv}
vlog -sv -work work +incdir+D:/Quartus/ECE385/lab9 {D:/Quartus/ECE385/lab9/SubBytes.sv}
vlog -sv -work work +incdir+D:/Quartus/ECE385/lab9 {D:/Quartus/ECE385/lab9/InvShiftRows.sv}
vlog -sv -work work +incdir+D:/Quartus/ECE385/lab9 {D:/Quartus/ECE385/lab9/InvMixColumns.sv}
vlog -sv -work work +incdir+D:/Quartus/ECE385/lab9 {D:/Quartus/ECE385/lab9/AddRoundKey.sv}
vlog -sv -work work +incdir+D:/Quartus/ECE385/lab9 {D:/Quartus/ECE385/lab9/counters.sv}
vlog -sv -work work +incdir+D:/Quartus/ECE385/lab9 {D:/Quartus/ECE385/lab9/KeyExpansion.sv}
vlog -sv -work work +incdir+D:/Quartus/ECE385/lab9 {D:/Quartus/ECE385/lab9/AES.sv}

vlog -sv -work work +incdir+D:/Quartus/ECE385/lab9 {D:/Quartus/ECE385/lab9/testbench.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -L lab9_soc -voptargs="+acc"  testbench

add wave *
view structure
view signals
run 2000 ns
