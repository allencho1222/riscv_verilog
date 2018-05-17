analyze -define $DEFINES -f verilog [list \
${RTL_DIR}/20182750_riscv/TOP_RISCV.v \
${RTL_DIR}/20182750_riscv/IF_ID.v \
${RTL_DIR}/20182750_riscv/ID_EX.v \
${RTL_DIR}/20182750_riscv/EX_MEM.v \
${RTL_DIR}/20182750_riscv/MEM_WB.v \
${RTL_DIR}/20182750_riscv/REG_FILE.v \
]
