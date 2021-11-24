transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/Jorra/Documents/Coding\ Practice/School/EECS3201/ModelSim\ Practice {C:/Users/Jorra/Documents/Coding Practice/School/EECS3201/ModelSim Practice/half_adderV.v}
vlog -vlog01compat -work work +incdir+C:/Users/Jorra/Documents/Coding\ Practice/School/EECS3201/ModelSim\ Practice {C:/Users/Jorra/Documents/Coding Practice/School/EECS3201/ModelSim Practice/full_adderV.v}

