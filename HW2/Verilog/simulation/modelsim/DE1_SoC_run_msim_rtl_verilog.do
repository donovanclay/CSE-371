transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/donov/OneDrive\ -\ donovan.clay/OneDrive/1)\ School/2023-24\ UW/1)\ Fall/CSE\ 371/Setup {C:/Users/donov/OneDrive - donovan.clay/OneDrive/1) School/2023-24 UW/1) Fall/CSE 371/Setup/fullAdder.sv}
vlog -sv -work work +incdir+C:/Users/donov/OneDrive\ -\ donovan.clay/OneDrive/1)\ School/2023-24\ UW/1)\ Fall/CSE\ 371/Setup {C:/Users/donov/OneDrive - donovan.clay/OneDrive/1) School/2023-24 UW/1) Fall/CSE 371/Setup/DE1_SoC.sv}

