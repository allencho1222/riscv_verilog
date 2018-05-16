module alu (
  // inputs are unsigned value
  input       [31:0] oper2,
  input       [31:0] oper1,
  input       [3:0]  alu_op,
  output reg  [31:0] alu_out
);

// for signed operation of SLT and SGE
wire signed [31:0] signed_oper2, signed_oper1;
assign signed_oper2 = oper2;
assign signed_oper1 = oper1;

// for shift amount of shift left, shift right, arithmetic shift right
wire [4:0] shamt;
assign shamt = oper2[4:0];

always @(*)
begin
  case (alu_op)
    ALU_ADD:  alu_out = oper1 + oper2;
    ALU_SUB:  alu_out = oper1 - oper2;
    ALU_SLT:  alu_out = signed_oper1 < signed_oper2;
    ALU_SLTU: alu_out = oper1 < oper2;
    ALU_SGE:  alu_out = signed_oper1 >= signed_oper2;
    ALU_SGEU: alu_out = oper1 >= oper2;
    ALU_AND:  alu_out = oper1 & oper2;
    ALU_OR:   alu_out = oper1 | oper2;
    ALU_XOR:  alu_out = oper1 ^ oper2;
    ALU_SEQ:  alu_out = oper1 == oper2;
    ALU_SNE:  alu_out = oper1 != oper2;
    ALU_SL:   alu_out = oper1 << shamt;
    ALU_SR:   alu_out = oper1 >> shamt;
    ALU_SRA:  alu_out = src_opt >>> shamt;
    default:  alu_out = oper1 + oper2;
end

endmodule
