transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/Jorra/Documents/Coding\ Practice/School/EECS3201/Lab\ 3 {C:/Users/Jorra/Documents/Coding Practice/School/EECS3201/Lab 3/Lab3.v}

vlog -vlog01compat -work work +incdir+C:/Users/Jorra/Documents/Coding\ Practice/School/EECS3201/Lab\ 3 {C:/Users/Jorra/Documents/Coding Practice/School/EECS3201/Lab 3/lab3_testbench.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L fiftyfivenm_ver -L rtl_work -L work -voptargs="+acc"  lab3_testbench

add wave *
view structure
view signals
run -all
