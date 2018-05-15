module control_unit (
  input [31:0] instruction,
  // generated control signals
  output reg [3:0] alu_op,
  output reg [3:0] memory_type,
  output reg [1:0] memory_write,
  output reg [1:0] writeback_from,
  output reg [2:0] imm_type,
  output reg [2:0] alu_src2,
  output reg [2:0] alu_src1
);

wire [31:0] instruction_in;
assign instruction_in = instruction;

always @(instruction_in)
begin
  casex (instruction)
    // load instructions
    LB: begin
      alu_op = ALU_ADD;
      memory_type = MT_B;
      memory_write = M_R;
      writeback_from = FROM_MEM;
      imm_type = IMM_I;
      alu_src2 = ALU2_IMM;
      alu_src1 = ALU1_RS1;
    end
    LH: begin
      alu_op = ALU_ADD;
      memory_type = MT_H
      memory_write = M_R;
      writeback_from = FROM_MEM;
      imm_type = IMM_I;
      alu_src2 = ALU2_IMM;
      alu_src1 = ALU1_RS1;
    end
    LW: begin
      alu_op = ALU_ADD;
      memory_type = MT_W;
      memory_write = M_R;
      writeback_from = FROM_MEM;
      imm_type = IMM_I;
      alu_src2 = ALU2_IMM;
      alu_src1 = ALU1_RS1;
    end
    LBU: begin
      alu_op = ALU_ADD;
      memory_type = MT_BU;
      memory_write = M_R;
      writeback_from = FROM_MEM;
      imm_type = IMM_I;
      alu_src2 = ALU2_IMM;
      alu_src1 = ALU1_RS1;
    end
    LHU: begin
      alu_op = ALU_ADD;
      memory_type = MT_HU;
      memory_write = M_R;
      writeback_from = FROM_MEM;
      imm_type = IMM_I;
      alu_src2 = ALU2_IMM;
      alu_src1 = ALU1_RS1;
    end
    // store instructions
    SB: begin
      alu_op = ALU_ADD;
      memory_type = MT_B;
      memory_write = M_W;
      writeback_from = FROM_X;
      imm_type = IMM_S;
      alu_src2 = ALU2_IMM;
      alu_src1 = ALU1_RS1;
    end
    SH: begin
      alu_op = ALU_ADD;
      memory_type = MT_H;
      memory_write = M_W;
      writeback_from = FROM_X;
      imm_type = IMM_S;
      alu_src2 = ALU2_IMM;
      alu_src1 = ALU1_RS1;
    end
    SW: begin
      alu_op = ALU_ADD;
      memory_type = MT_W;
      memory_write = M_W;
      writeback_from = FROM_X;
      imm_type = IMM_S;
      alu_src2 = ALU2_IMM;
      alu_src1 = ALU1_RS1;
    end
    // shift instructions
    SLL: begin
      alu_op = ALU_SL;
      memory_type = MT_X;
      memory_write = M_X;
      writeback_from = FROM_ALU;
      imm_type = IMM_X;
      alu_src2 = ALU2_RS2;
      alu_src1 = ALU1_RS1;
    end
    SLLI: begin
      alu_op = ALU_SL;
      memory_type = MT_X;
      memory_write = M_X;
      writeback_from = FROM_ALU;
      imm_type = IMM_I;
      alu_src2 = ALU2_IMM;
      alu_src1 = ALU1_RS1;
    end
    SRL: begin
      alu_op = ALU_SR;
      memory_type = MT_X;
      memory_write = M_X;
      writeback_from = FROM_ALU;
      imm_type = IMM_X;
      alu_src2 = ALU2_RS2;
      alu_src1 = ALU1_RS1;
    end
    SRLI: begin
      alu_op = ALU_SR;
      memory_type = MT_X;
      memory_write = M_X;
      writeback_from = FROM_ALU;
      imm_type = IMM_I;
      alu_src2 = ALU2_IMM;
      alu_src1 = ALU1_RS1;
    end
    SRA: begin
      alu_op = ALU_SRA;
      memory_type = MT_X;
      memory_write = M_X;
      writeback_from = FROM_ALU;
      imm_type = IMM_X;
      alu_src2 = ALU2_RS2;
      alu_src1 = ALU1_RS1;
    end
    SRAI: begin
      alu_op = ALU_SRA;
      memory_type = MT_X;
      memory_write = M_X;
      writeback_from = FROM_ALU;
      imm_type = IMM_I;
      alu_src2 = ALU2_IMM;
      alu_src1 = ALU1_RS1;
    end
    // arithmetic instructions
    ADD: begin
      alu_op = ALU_ADD;
      memory_type = MT_X;
      memory_write = M_X;
      writeback_from = FROM_ALU;
      imm_type = IMM_X;
      alu_src2 = ALU2_RS2;
      alu_src1 = ALU1_RS1;
    end
    ADDI: begin
      alu_op = ALU_ADD;
      memory_type = MT_X;
      memory_write = M_X;
      writeback_from = FROM_ALU;
      imm_type = IMM_I;
      alu_src2 = ALU2_IMM;
      alu_src1 = ALU1_RS1;
    end
    SUB: begin
      alu_op = ALU_SUB;
      memory_type = MT_X;
      memory_write = M_X;
      writeback_from = FROM_ALU;
      imm_type = IMM_X;
      alu_src2 = ALU2_RS2;
      alu_src1 = ALU1_RS1;
    end
    LUI: begin
      alu_op = ALU_ADD;
      memory_type = MT_X;
      memory_write = M_X;
      writeback_from = FROM_ALU;
      imm_type = IMM_U;
      alu_src2 = ALU2_IMM;
      alu_src1 = ALU1_ZERO;
    end
    AUIPC: begin
      alu_op = ALU_ADD;
      memory_type = MT_X;
      memory_write = M_X;
      writeback_from = FROM_ALU;
      imm_type = IMM_UJ;
      alu_src2 = ALU2_IMM;
      alu_src1 = ALU1_PC;
    end
    // logical instructions
    XOR: begin
      alu_op = ALU_XOR;
      memory_type = MT_X;
      memory_write = M_X;
      writeback_from = FROM_ALU;
      imm_type = IMM_X;
      alu_src2 = ALU2_RS2;
      alu_src1 = ALU1_RS1;
    end
    XORI: begin
      alu_op = ALU_XOR;
      memory_type = MT_X;
      memory_write = M_X
      writeback_from = FROM_ALU;
      imm_type = IMM_I;
      alu_src2 = ALU2_IMM;
      alu_src1 = ALU1_RS1;
    end
    OR: begin
      alu_op = ALU_OR;
      memory_type = MT_X;
      memory_write = M_X
      writeback_from = FROM_ALU;
      imm_type = IMM_X;
      alu_src2 = ALU2_RS2;
      alu_src1 = ALU1_RS1;
    end
    ORI: begin
      alu_op = ALU_OR;
      memory_type = MT_X;
      memory_write = M_X
      writeback_from = FROM_ALU;
      imm_type = IMM_I;
      alu_src2 = ALU2_IMM2;
      alu_src1 = ALU1_RS1;
    end
    AND: begin
      alu_op = ALU_AND;
      memory_type = MT_X;
      memory_write = M_X
      writeback_from = FROM_ALU;
      imm_type = IMM_X;
      alu_src2 = ALU2_RS2;
      alu_src1 = ALU1_RS1;
    end
    ANDI: begin
      alu_op = ALU_AND;
      memory_type = MT_X;
      memory_write = M_X
      writeback_from = FROM_ALU;
      imm_type = IMM_I;
      alu_src2 = ALU2_IMM;
      alu_src1 = ALU1_RS1;
    end
    // compare instructions
    SLT: begin
      alu_op = ALU_SLT;
      memory_type = MT_X;
      memory_write = M_X
      writeback_from = FROM_ALU;
      imm_type = IMM_X;
      alu_src2 = ALU2_RS2;
      alu_src1 = ALU1_RS1;
    end
    SLTI: begin
      alu_op = ALU_SLT;
      memory_type = MT_X;
      memory_write = M_X
      writeback_from = FROM_ALU;
      imm_type = IMM_I;
      alu_src2 = ALU2_IMM;
      alu_src1 = ALU1_RS1;
    end
    SLTU: begin
      alu_op = ALU_SLTU;
      memory_type = MT_X;
      memory_write = M_X
      writeback_from = FROM_ALU;
      imm_type = IMM_X;
      alu_src2 = ALU2_RS2;
      alu_src1 = ALU1_RS1;
    end
    SLTIU: begin
      alu_op = ALU_SLTU;
      memory_type = MT_X;
      memory_write = M_X
      writeback_from = FROM_ALU;
      imm_type = IMM_I;
      alu_src2 = ALU2_IMM;
      alu_src1 = ALU1_RS1;
    end
    // branch instructions
    BEQ: begin
      alu_op = ALU_SEQ;
      memory_type = MT_X;
      memory_write = M_X
      writeback_from = FROM_X;
      imm_type = IMM_SB;
      alu_src2 = ALU2_RS2;
      alu_src1 = ALU1_RS1;
    end
    BNE: begin
      alu_op = ALU_SNE;
      memory_type = MT_X;
      memory_write = M_X
      writeback_from = FROM_X;
      imm_type = IMM_SB;
      alu_src2 = ALU2_RS2;
      alu_src1 = ALU1_RS1;
    end
    BLT: begin
      alu_op = ALU_SLT;
      memory_type = MT_X;
      memory_write = M_X
      writeback_from = FROM_X;
      imm_type = IMM_SB;
      alu_src2 = ALU2_RS2;
      alu_src1 = ALU1_RS1;
    end
    BGE: begin
      alu_op = ALU_SGE;
      memory_type = MT_X;
      memory_write = M_X
      writeback_from = FROM_X;
      imm_type = IMM_SB;
      alu_src2 = ALU2_RS2;
      alu_src1 = ALU1_RS1;
    end
    BLTU: begin
      alu_op = ALU_SLTU;
      memory_type = MT_X;
      memory_write = M_X
      writeback_from = FROM_X;
      imm_type = IMM_SB;
      alu_src2 = ALU2_RS2;
      alu_src1 = ALU1_RS1;
    end
    BGEU: begin
      alu_op = ALU_SGEU;
      memory_type = MT_X;
      memory_write = M_X
      writeback_from = FROM_X;
      imm_type = IMM_SB;
      alu_src2 = ALU2_RS2;
      alu_src1 = ALU1_RS1;
    end
    JAL: begin
      alu_op = ALU_ADD;
      memory_type = MT_X;
      memory_write = M_X
      writeback_from = FROM_PC;
      imm_type = IMM_UJ;
      alu_src2 = ALU2_RS2;  // TODO : src2 type
      alu_src1 = ALU1_PC;
    end
    JALR: begin
      alu_op = ALU_ADD;
      memory_type = MT_X;
      memory_write = M_X
      writeback_from = FROM_PC;
      imm_type = IMM_I;
      alu_src2 = ALU2_IMM;
      alu_src1 = ALU1_RS1;
    end
    default: begin
      alu_op = ALU_X;
      memory_type = MT_X;
      memory_write = M_X
      writeback_from = FROM_X;
      imm_type = IMM_X;
      alu_src2 = ALU2_X;
      alu_src1 = ALU1_X;
    end
end



