#!/bin/bash

# Abort if any command returns != 0
set -e

# Project home folder
homedir="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
homedir=$homedir/..

# The directories of the hw source files
srcdir_core=$homedir/rtl/core
srcdir_top_templates=$homedir/rtl/top_templates
srcdir_sim=$homedir/sim

# Show GHDL version
ghdl -v

# List files
echo ""
echo "Simulation source files:"
ls -al $srcdir_core
ls -al $srcdir_top_templates
ls -al $srcdir_sim

# Analyse sources; libs and images at first!
ghdl -a --work=neorv32 $srcdir_core/neorv32_package.vhd
ghdl -a --work=neorv32 $srcdir_core/neorv32_application_image.vhd
ghdl -a --work=neorv32 $srcdir_core/neorv32_bootloader_image.vhd
#
ghdl -a --work=neorv32 $srcdir_core/neorv32_boot_rom.vhd
ghdl -a --work=neorv32 $srcdir_core/neorv32_clic.vhd
ghdl -a --work=neorv32 $srcdir_core/neorv32_cpu.vhd
ghdl -a --work=neorv32 $srcdir_core/neorv32_cpu_alu.vhd
ghdl -a --work=neorv32 $srcdir_core/neorv32_cpu_bus.vhd
ghdl -a --work=neorv32 $srcdir_core/neorv32_cpu_control.vhd
ghdl -a --work=neorv32 $srcdir_core/neorv32_cpu_cp_muldiv.vhd
ghdl -a --work=neorv32 $srcdir_core/neorv32_cpu_decompressor.vhd
ghdl -a --work=neorv32 $srcdir_core/neorv32_cpu_regfile.vhd
ghdl -a --work=neorv32 $srcdir_core/neorv32_devnull.vhd
ghdl -a --work=neorv32 $srcdir_core/neorv32_dmem.vhd
ghdl -a --work=neorv32 $srcdir_core/neorv32_gpio.vhd
ghdl -a --work=neorv32 $srcdir_core/neorv32_imem.vhd
ghdl -a --work=neorv32 $srcdir_core/neorv32_mtime.vhd
ghdl -a --work=neorv32 $srcdir_core/neorv32_pwm.vhd
ghdl -a --work=neorv32 $srcdir_core/neorv32_spi.vhd
ghdl -a --work=neorv32 $srcdir_core/neorv32_top.vhd
ghdl -a --work=neorv32 $srcdir_core/neorv32_trng.vhd
ghdl -a --work=neorv32 $srcdir_core/neorv32_twi.vhd
ghdl -a --work=neorv32 $srcdir_core/neorv32_uart.vhd
ghdl -a --work=neorv32 $srcdir_core/neorv32_wdt.vhd
ghdl -a --work=neorv32 $srcdir_core/neorv32_wishbone.vhd
#
ghdl -a --work=neorv32 $srcdir_top_templates/*.vhd
#
ghdl -a --work=neorv32 $srcdir_sim/*.vhd

# Prepare simulation output files
touch neorv32.testbench_uart.out
chmod 777 neorv32.testbench_uart.out
touch neorv32.devnull.out
chmod 777 neorv32.devnull.out

# Run simulation
ghdl -e --work=neorv32 neorv32_tb
ghdl -r --work=neorv32 neorv32_tb --stop-time=5ms --ieee-asserts=disable --assert-level=error

# Check output
echo "Checking NEORV32.DEVNULL output. Should contain:"; cat $homedir/check_reference.out
echo ""
echo "Checking NEORV32.DEVNULL output. NEORV32.DEVNULL output is:"
cat neorv32.devnull.out

# Check if reference can be found in output
grep -qf $homedir/check_reference.out neorv32.devnull.out