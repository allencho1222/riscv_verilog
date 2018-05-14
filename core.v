module riscv_core(
);


// pipeline registers

// IF / ID pipeline registers
reg [(`DWIDTH - 1):0] if_id_inst;
reg [(`DWIDTH - 1):0] if_id_pc;

// ID / EX pipeline registers
reg [(`DWIDTH - 1):0] id_ex_rs1_data;
reg [(`DWIDTH - 1):0] id_ex_rs2_data;
reg [(`DWIDTH - 1):0] id_ex_imm_data;
reg [(`IMM_CTRL_LEN - 1):0]     id_ex_ctrl_sig_imm_type;
reg [(`ALU_CTRL_LEN - 1):0]     id_ex_ctrl_sig_alu_op;
reg [(`ALU_SRC_CTRL_LEN - 1):0] id_ex_ctrl_sig_alu_src;
reg [(`MEM_CTRL_LEN - 1):0]     id_ex_ctrl_sig_mem_type;

// instruction fetch stage
//
reg [(`DWIDTH - 1):0] pc;



// ----- instruction decode stage -----

// register file access
wire [4:0] rs1, rs2;
assign rs1 = if_id_inst[RS1_START:RS1_END];
assign rs2 = if_id_inst[RS2_START:RS2_END];

wire [(`DWIDTH - 1):0] rs1_data, rs2_data;


// control unit
wire [(`ALU_CTRL_LEN - 1):0]      ctrl_sig_alu_op;
wire [(`ALU_SRC_CTRL_LEN - 1):0]  ctrl_sig_alu_src2, ctrl_sig_alu_src1;
wire [(`IMM_CTRL_LEN - 1):0]      ctrl_sig_imm_type;
wire [(`MEM_CTRL_LEN - 1):0]      ctrl_sig_mem_type;

// immediate generator
wire [(`IMM_I_WIDTH - 1):0]   imm_i;
wire [(`IMM_S_WIDTH - 1):0]   imm_s;
wire [(`IMM_SB_WIDTH - 1):0]  imm_sb;
wire [(`IMM_U_WIDTH - 1):0]   imm_u;
wire [(`IMM_UJ_WIDTH - 1):0]  imm_uj;
assign imm_i  = if_id_inst[31:20];
assign imm_s  = {if_id_inst[31:25], if_id_inst[11, 7]}
assign imm_sb = {if_id_inst[31], if_id_inst[7], if_id_inst[30:25], if_id_inst[11:8]}
assign imm_u  = if_id_inst[31:12];
assign imm_uj = {if_id_inst[31], if_id_inst[19:12], if_id_inst[20], if_id_inst[30:21]};

// TODO : check replication number implementation
wire [(`DWIDTH - 1):0] sign_ext_imm_i;
wire [(`DWIDTH - 1):0] sign_ext_imm_s;
wire [(`DWIDTH - 1):0] sign_ext_imm_sb;
wire [(`DWIDTH - 1):0] sign_ext_imm_u;
wire [(`DWIDTH - 1):0] sign_ext_imm_uj;
assign sign_ext_imm_i   = {(`DWIDTH - `IMM_I_WIDTH){imm_i[IMM_I_WIDTH - 1]}, imm_i};
assign sign_ext_imm_s   = {(`DWIDTH - `IMM_S_WIDTH){imm_s[IMM_S_WIDTH - 1]}, imm_s};
assign sign_ext_imm_sb  = {(`DWIDTH - `IMM_SB_WIDTH){imm_s[IMM_SB_WIDTH - 1]}, imm_sb};
assign sign_ext_imm_u   = {(`DWIDTH - `IMM_U_WIDTH){imm_s[IMM_U_WIDTH - 1]}, imm_u};
assign sign_ext_imm_uj  = {(`DWIDTH - `IMM_UJ_WIDTH){imm_s[IMM_UJ_WIDTH - 1]}, imm_uj};


always @(posedge clk)
begin
  id_ex_rs1_data <= rs1_data;
  id_ex_rs2_data <= rs2_data;
end

always @(posedge clk)
begin
  case (ctrl_sig_imm_type)
    IMM_X:  id_ex_imm_data <= {32{1b'0}};
    IMM_I:  id_ex_imm_data <= sign_ext_imm_i;
    IMM_S:  id_ex_imm_data <= sign_ext_imm_s;
    IMM_SB: id_ex_imm_data <= sign_ext_imm_sb;
    IMM_U:  id_ex_imm_data <= sign_ext_imm_u;
    IMM_UJ: id_ex_imm_data <= sign_ext_imm_uj;
    default: id_ex_imm_data <= {32{1b'0}};
end

always @(posedge clk)
begin
  id_ex_ctrl_sig_alu_op <= ctrl_sig_alu_op;
  id_ex_ctrl_sig_alu_src2 <= ctrl_sig_alu_src2;
  id_ex_ctrl_sig_alu_src1 <= ctrl_sig_alu_src1;
  id_ex_ctrl_sig_imm_type <= ctrl_sig_imm_type;
  id_ex_ctrl_sig_mem_type <= ctrl_sig_mem_type;
end







