transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/fabiancojman/Documents/EECS3201/Final {C:/Users/fabiancojman/Documents/EECS3201/Final/EECS3201Final.v}
vlog -vlog01compat -work work +incdir+C:/Users/fabiancojman/Documents/EECS3201/Final {C:/Users/fabiancojman/Documents/EECS3201/Final/pll.v}
vlog -vlog01compat -work work +incdir+C:/Users/fabiancojman/Documents/EECS3201/Final/db {C:/Users/fabiancojman/Documents/EECS3201/Final/db/pll_altpll.v}

