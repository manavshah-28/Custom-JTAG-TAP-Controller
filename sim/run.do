# ----------------------------------
# Clean and create library
# ----------------------------------
if {[file exists work]} {
    vdel -lib work -all
}
vlib work

# ----------------------------------
# Compile
# ----------------------------------
vlog -sv -work work -f ../sim/dut.f


# ----------------------------------
# Simulate
# ----------------------------------
vsim work.tap_tb

run -all
quit