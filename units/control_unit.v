`include "../define/consts.v"
`include "../define/control_signals.v"
`include "../define/instructions.v"

module control_unit (
  input [31:0]      instruction,
  // generated control signals
  output reg [(`ALU_FN_LEN - 1):0]  alu_fn,
  output reg [(`MEM_TYPE_LEN - 1):0]  memory_type,
  output reg [(`MEM_WRITE_LEN - 1):0]  memory_rw,
  output reg        			register_write,
  output reg [(`WB_FROM_LEN - 1):0]  writeback_from,
  output reg [(`IMM_TYPE_LEN - 1):0]  imm_type,
  output reg [(`ALU_SRC_LEN - 1):0]  alu_src2,
  output reg [(`ALU_SRC_LEN - 1):0]  alu_src1,
  output reg [(`BR_TYPE_LEN - 1):0]  branch_type
);

wire [31:0] instruction_in;
assign instruction_in = instruction;

always @(instruction_in)
begin
  casex (instruction)
    // load instructions
    `LB: begin
      alu_fn          = `ALU_ADD;
      memory_type     = `MT_B;
      memory_rw       = `M_R;
      register_write  = `REG_W;
      writeback_from  = `FROM_MEM;
      imm_type        = `IMM_I;
      alu_src2        = `ALU2_IMM;
      alu_src1        = `ALU1_RS1;
      branch_type     = `BR_X;
    end
    `LH: begin
      alu_fn          = `ALU_ADD;
      memory_type     = `MT_H;
      memory_rw       = `M_R;
      register_write  = `REG_W;
      writeback_from  = `FROM_MEM;
      imm_type        = `IMM_I;
      alu_src2        = `ALU2_IMM;
      alu_src1        = `ALU1_RS1;
      branch_type     = `BR_X;
    end
    `LW: begin
      alu_fn          = `ALU_ADD;
      memory_type     = `MT_W;
      memory_rw       = `M_R;
      register_write  = `REG_W;
      writeback_from  = `FROM_MEM;
      imm_type        = `IMM_I;
      alu_src2        = `ALU2_IMM;
      alu_src1        = `ALU1_RS1;
      branch_type     = `BR_X;
    end
    `LBU: begin
      alu_fn          = `ALU_ADD;
      memory_type     = `MT_BU;
      memory_rw       = `M_R;
      register_write  = `REG_W;
      writeback_from  = `FROM_MEM;
      imm_type        = `IMM_I;
      alu_src2        = `ALU2_IMM;
      alu_src1        = `ALU1_RS1;
      branch_type     = `BR_X;
    end
    `LHU: begin
      alu_fn          = `ALU_ADD;
      memory_type     = `MT_HU;
      memory_rw       = `M_R;
      register_write  = `REG_W;
      writeback_from  = `FROM_MEM;
      imm_type        = `IMM_I;
      alu_src2        = `ALU2_IMM;
      alu_src1        = `ALU1_RS1;
      branch_type     = `BR_X;
    end
    // store instructions
    `SB: begin
      alu_fn          = `ALU_ADD;
      memory_type     = `MT_B;
      memory_rw       = `M_W;
      register_write  = `REG_X;
      writeback_from  = `FROM_X;
      imm_type        = `IMM_S;
      alu_src2        = `ALU2_IMM;
      alu_src1        = `ALU1_RS1;
      branch_type     = `BR_X;
    end
    `SH: begin
      alu_fn          = `ALU_ADD;
      memory_type     = `MT_H;
      memory_rw       = `M_W;
      register_write  = `REG_X;
      writeback_from  = `FROM_X;
      imm_type        = `IMM_S;
      alu_src2        = `ALU2_IMM;
      alu_src1        = `ALU1_RS1;
      branch_type     = `BR_X;
    end
    `SW: begin
      alu_fn          = `ALU_ADD;
      memory_type     = `MT_W;
      memory_rw       = `M_W;
      register_write  = `REG_X;
      writeback_from  = `FROM_X;
      imm_type        = `IMM_S;
      alu_src2        = `ALU2_IMM;
      alu_src1        = `ALU1_RS1;
      branch_type     = `BR_X;
    end
    // shift instructions
    `SLL: begin
      alu_fn          = `ALU_SL;
      memory_type     = `MT_X;
      memory_rw       = `M_X;
      register_write  = `REG_W;
      writeback_from  = `FROM_ALU;
      imm_type        = `IMM_X;
      alu_src2        = `ALU2_RS2;
      alu_src1        = `ALU1_RS1;
      branch_type     = `BR_X;
    end
    `SLLI: begin
      alu_fn          = `ALU_SL;
      memory_type     = `MT_X;
      memory_rw       = `M_X;
      register_write  = `REG_W;
      writeback_from  = `FROM_ALU;
      imm_type        = `IMM_I;
      alu_src2        = `ALU2_IMM;
      alu_src1        = `ALU1_RS1;
      branch_type     = `BR_X;
    end
    `SRL: begin
      alu_fn          = `ALU_SR;
      memory_type     = `MT_X;
      memory_rw       = `M_X;
      register_write  = `REG_W;
      writeback_from  = `FROM_ALU;
      imm_type        = `IMM_X;
      alu_src2        = `ALU2_RS2;
      alu_src1        = `ALU1_RS1;
      branch_type     = `BR_X;
    end
    `SRLI: begin
      alu_fn          = `ALU_SR;
      memory_type     = `MT_X;
      memory_rw       = `M_X;
      register_write  = `REG_W;
      writeback_from  = `FROM_ALU;
      imm_type        = `IMM_I;
      alu_src2        = `ALU2_IMM;
      alu_src1        = `ALU1_RS1;
      branch_type     = `BR_X;
    end
    `SRA: begin
      alu_fn          = `ALU_SRA;
      memory_type     = `MT_X;
      memory_rw       = `M_X;
      register_write  = `REG_W;
      writeback_from  = `FROM_ALU;
      imm_type        = `IMM_X;
      alu_src2        = `ALU2_RS2;
      alu_src1        = `ALU1_RS1;
      branch_type     = `BR_X;
    end
    `SRAI: begin
      alu_fn          = `ALU_SRA;
      memory_type     = `MT_X;
      memory_rw       = `M_X;
      register_write  = `REG_W;
      writeback_from  = `FROM_ALU;
      imm_type        = `IMM_I;
      alu_src2        = `ALU2_IMM;
      alu_src1        = `ALU1_RS1;
      branch_type     = `BR_X;
    end
    // arithmetic instructions
    `ADD: begin
      alu_fn          = `ALU_ADD;
      memory_type     = `MT_X;
      memory_rw       = `M_X;
      register_write  = `REG_W;
      writeback_from  = `FROM_ALU;
      imm_type        = `IMM_X;
      alu_src2        = `ALU2_RS2;
      alu_src1        = `ALU1_RS1;
      branch_type     = `BR_X;
    end
    `ADDI: begin
      alu_fn          = `ALU_ADD;
      memory_type     = `MT_X;
      memory_rw       = `M_X;
      register_write  = `REG_W;
      writeback_from  = `FROM_ALU;
      imm_type        = `IMM_I;
      alu_src2        = `ALU2_IMM;
      alu_src1        = `ALU1_RS1;
      branch_type     = `BR_X;
    end
    `SUB: begin
      alu_fn          = `ALU_SUB;
      memory_type     = `MT_X;
      memory_rw       = `M_X;
      register_write  = `REG_W;
      writeback_from  = `FROM_ALU;
      imm_type        = `IMM_X;
      alu_src2        = `ALU2_RS2;
      alu_src1        = `ALU1_RS1;
      branch_type     = `BR_X;
    end
    `LUI: begin
      alu_fn          = `ALU_ADD;
      memory_type     = `MT_X;
      memory_rw       = `M_X;
      register_write  = `REG_W;
      writeback_from  = `FROM_ALU;
      imm_type        = `IMM_U;
      alu_src2        = `ALU2_IMM;
      alu_src1        = `ALU1_ZERO;
      branch_type     = `BR_X;
    end
    `AUIPC: begin
      alu_fn          = `ALU_ADD;
      memory_type     = `MT_X;
      memory_rw       = `M_X;
      register_write  = `REG_W;
      writeback_from  = `FROM_ALU;
      imm_type        = `IMM_U;
      alu_src2        = `ALU2_IMM;
      alu_src1        = `ALU1_PC;
      branch_type     = `BR_X;
    end
    // logical instructions
    `XOR: begin
      alu_fn          = `ALU_XOR;
      memory_type     = `MT_X;
      memory_rw       = `M_X;
      register_write  = `REG_W;
      writeback_from  = `FROM_ALU;
      imm_type        = `IMM_X;
      alu_src2        = `ALU2_RS2;
      alu_src1        = `ALU1_RS1;
      branch_type     = `BR_X;
    end
    `XORI: begin
      alu_fn          = `ALU_XOR;
      memory_type     = `MT_X;
      memory_rw       = `M_X;
      register_write  = `REG_W;
      writeback_from  = `FROM_ALU;
      imm_type        = `IMM_I;
      alu_src2        = `ALU2_IMM;
      alu_src1        = `ALU1_RS1;
      branch_type     = `BR_X;
    end
    `OR: begin
      alu_fn          = `ALU_OR;
      memory_type     = `MT_X;
      memory_rw       = `M_X;
      register_write  = `REG_W;
      writeback_from  = `FROM_ALU;
      imm_type        = `IMM_X;
      alu_src2        = `ALU2_RS2;
      alu_src1        = `ALU1_RS1;
      branch_type     = `BR_X;
    end
    `ORI: begin
      alu_fn          = `ALU_OR;
      memory_type     = `MT_X;
      memory_rw       = `M_X;
      register_write  = `REG_W;
      writeback_from  = `FROM_ALU;
      imm_type        = `IMM_I;
      alu_src2        = `ALU2_IMM;
      alu_src1        = `ALU1_RS1;
      branch_type     = `BR_X;
    end
    `AND: begin
      alu_fn          = `ALU_AND;
      memory_type     = `MT_X;
      memory_rw       = `M_X;
      register_write  = `REG_W;
      writeback_from  = `FROM_ALU;
      imm_type        = `IMM_X;
      alu_src2        = `ALU2_RS2;
      alu_src1        = `ALU1_RS1;
      branch_type     = `BR_X;
    end
    `ANDI: begin
      alu_fn          = `ALU_AND;
      memory_type     = `MT_X;
      memory_rw       = `M_X;
      register_write  = `REG_W;
      writeback_from  = `FROM_ALU;
      imm_type        = `IMM_I;
      alu_src2        = `ALU2_IMM;
      alu_src1        = `ALU1_RS1;
      branch_type     = `BR_X;
    end
    // compare instructions
    `SLT: begin
      alu_fn          = `ALU_SLT;
      memory_type     = `MT_X;
      memory_rw       = `M_X;
      register_write  = `REG_W;
      writeback_from  = `FROM_ALU;
      imm_type        = `IMM_X;
      alu_src2        = `ALU2_RS2;
      alu_src1        = `ALU1_RS1;
      branch_type     = `BR_X;
    end
    `SLTI: begin
      alu_fn          = `ALU_SLT;
      memory_type     = `MT_X;
      memory_rw       = `M_X;
      register_write  = `REG_W;
      writeback_from  = `FROM_ALU;
      imm_type        = `IMM_I;
      alu_src2        = `ALU2_IMM;
      alu_src1        = `ALU1_RS1;
      branch_type     = `BR_X;
    end
    `SLTU: begin
      alu_fn          = `ALU_SLTU;
      memory_type     = `MT_X;
      memory_rw       = `M_X;
      register_write  = `REG_W;
      writeback_from  = `FROM_ALU;
      imm_type        = `IMM_X;
      alu_src2        = `ALU2_RS2;
      alu_src1        = `ALU1_RS1;
      branch_type     = `BR_X;
    end
    `SLTIU: begin
      alu_fn          = `ALU_SLTU;
      memory_type     = `MT_X;
      memory_rw       = `M_X;
      register_write  = `REG_W;
      writeback_from  = `FROM_ALU;
      imm_type        = `IMM_I;
      alu_src2        = `ALU2_IMM;
      alu_src1        = `ALU1_RS1;
      branch_type     = `BR_X;
    end
    // branch instructions
    `BEQ: begin
      alu_fn          = `ALU_X;
      memory_type     = `MT_X;
      memory_rw       = `M_X;
      register_write  = `REG_X;
      writeback_from  = `FROM_X;
      imm_type        = `IMM_SB;
      alu_src2        = `ALU2_RS2;
      alu_src1        = `ALU1_RS1;
      branch_type     = `BR_EQ;
    end
    `BNE: begin
      alu_fn          = `ALU_X;
      memory_type     = `MT_X;
      memory_rw       = `M_X;
      register_write  = `REG_X;
      writeback_from  = `FROM_X;
      imm_type        = `IMM_SB;
      alu_src2        = `ALU2_RS2;
      alu_src1        = `ALU1_RS1;
      branch_type     = `BR_NE;
    end
    `BLT: begin
      alu_fn          = `ALU_X;
      memory_type     = `MT_X;
      memory_rw       = `M_X;
      register_write  = `REG_X;
      writeback_from  = `FROM_X;
      imm_type        = `IMM_SB;
      alu_src2        = `ALU2_RS2;
      alu_src1        = `ALU1_RS1;
      branch_type     = `BR_LT;
    end
    `BGE: begin
      alu_fn          = `ALU_X;
      memory_type     = `MT_X;
      memory_rw       = `M_X;
      register_write  = `REG_X;
      writeback_from  = `FROM_X;
      imm_type        = `IMM_SB;
      alu_src2        = `ALU2_RS2;
      alu_src1        = `ALU1_RS1;
      branch_type     = `BR_GE;
    end
    `BLTU: begin
      alu_fn          = `ALU_X;
      memory_type     = `MT_X;
      memory_rw       = `M_X;
      register_write  = `REG_X;
      writeback_from  = `FROM_X;
      imm_type        = `IMM_SB;
      alu_src2        = `ALU2_RS2;
      alu_src1        = `ALU1_RS1;
      branch_type     = `BR_LTU;
    end
    `BGEU: begin
      alu_fn          = `ALU_X;
      memory_type     = `MT_X;
      memory_rw       = `M_X;
      register_write  = `REG_X;
      writeback_from  = `FROM_X;
      imm_type        = `IMM_SB;
      alu_src2        = `ALU2_RS2;
      alu_src1        = `ALU1_RS1;
      branch_type     = `BR_GEU;
    end
    `JAL: begin
      alu_fn          = `ALU_X;
      memory_type     = `MT_X;
      memory_rw       = `M_X;
      register_write  = `REG_W;
      writeback_from  = `FROM_PC;
      imm_type        = `IMM_UJ;
      alu_src2        = `ALU2_IMM;
      alu_src1        = `ALU1_RS1;
      branch_type     = `BR_J;
    end
    `JALR: begin
      alu_fn          = `ALU_ADD;
      memory_type     = `MT_X;
      memory_rw       = `M_X;
      register_write  = `REG_W;
      writeback_from  = `FROM_PC;
      imm_type        = `IMM_I;
      alu_src2        = `ALU2_IMM;
      alu_src1        = `ALU1_RS1;
      branch_type     = `BR_JR;
    end
    `BUBBLE: begin
      alu_fn          = `ALU_X;
      memory_type     = `MT_X;
      memory_rw       = `M_X;
      register_write  = `REG_X;
      writeback_from  = `FROM_X;
      imm_type        = `IMM_X;
      alu_src2        = `ALU2_X;
      alu_src1        = `ALU1_X;
      branch_type     = `BR_X;
    end
    default: begin
      alu_fn          = `ALU_X;
      memory_type     = `MT_X;
      memory_rw       = `M_X;
      register_write  = `REG_X;
      writeback_from  = `FROM_X;
      imm_type        = `IMM_X;
      alu_src2        = `ALU2_X;
      alu_src1        = `ALU1_X;
      branch_type     = `BR_X;
    end
  endcase
end

endmodule
