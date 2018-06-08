analyze -define $DEFINES -f verilog [list \
~/20172718_riscv/core/riscv_core.v \
~/20172718_riscv/provided/REG_FILE.v \
~/20172718_riscv/provided/Mem_Model.v \
~/20172718_riscv/provided/RISCV_CLKRST.v \
~/20172718_riscv/provided/TB_RISCV.v \
~/20172718_riscv/units/alu.v \
~/20172718_riscv/units/control_unit.v]
