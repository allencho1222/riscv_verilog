`include "../define/consts.v"
`include "../define/control_signals.v"

module alu (
  // inputs are unsigned value
  input       [(`DWIDTH - 1):0] oper2,
  input       [(`DWIDTH - 1):0] oper1,
  input       [(`ALU_FN_LEN - 1):0]  alu_fn,
  output      [(`DWIDTH - 1):0] alu_out
);

// for signed operation of SLT and SGE
wire signed [(`DWIDTH - 1):0] signed_oper2, signed_oper1;
assign signed_oper2 = oper2;
assign signed_oper1 = oper1;

// for shift amount of shift left, shift right, arithmetic shift right
wire [4:0] shamt;
assign shamt = oper2[4:0];

//always @(*)
//begin
  assign alu_out = 
    (alu_fn == `ALU_ADD) ? oper1 + oper2 :
    (alu_fn == `ALU_SUB) ? oper1 - oper2 :
    (alu_fn == `ALU_SLT) ? signed_oper1 < signed_oper2 :
    (alu_fn == `ALU_SLTU) ? oper1 < oper2 :
    (alu_fn == `ALU_AND) ? oper1 < oper2 :
    (alu_fn == `ALU_OR)  ? oper1 | oper2 :
    (alu_fn == `ALU_XOR) ? oper1 ^ oper2 :
    (alu_fn == `ALU_SL)  ? oper1 << shamt :
    (alu_fn == `ALU_SR)  ? oper1 >> shamt :
    (alu_fn == `ALU_SRA) ? signed_oper1 >>> shamt : oper1 + oper2;
    /*
  case (alu_fn)
    `ALU_ADD:  alu_out = oper1 + oper2;
    `ALU_SUB:  alu_out = oper1 - oper2;
    `ALU_SLT:  alu_out = signed_oper1 < signed_oper2;
    `ALU_SLTU: alu_out = oper1 < oper2;
    `ALU_AND:  alu_out = oper1 & oper2;
    `ALU_OR:   alu_out = oper1 | oper2;
    `ALU_XOR:  alu_out = oper1 ^ oper2;
    `ALU_SL:   alu_out = oper1 << shamt;
    `ALU_SR:   alu_out = oper1 >> shamt;
    `ALU_SRA:  alu_out = oper1 >>> shamt;
    default:  alu_out = oper1 + oper2;
  endcase
  */
//end

endmodule
