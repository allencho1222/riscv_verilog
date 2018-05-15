module riscv_core();


// pipeline registers

// IF / ID pipeline registers
reg [(`DWIDTH - 1):0] if_id_inst;
reg [(`DWIDTH - 1):0] if_id_pc;

// ID / EX pipeline registers
reg [4:0]             id_ex_rd;
reg [4:0]             id_ex_rs1;
reg [4:0]             id_ex_rs2;
reg [31:0]            id_ex_pc;
reg [(`DWIDTH - 1):0] id_ex_rs1_data;
reg [(`DWIDTH - 1):0] id_ex_rs2_data;
reg [(`DWIDTH - 1):0] id_ex_imm_data;

reg [(`IMM_LEN - 1):0]        id_ex_ctrl_sig_imm_type;
reg [(`ALU_OP_LEN - 1):0]     id_ex_ctrl_sig_alu_op;
reg [(`ALU_SRC_LEN - 1):0]    id_ex_ctrl_sig_alu_src2, id_ex_ctrl_sig_alu_src1;

reg [(`MEM_TYPE_LEN - 1):0]   id_ex_ctrl_sig_mem_type;
reg [(`MEM_WRITE_LEN - 1):0]  id_ex_ctrl_sig_mem_write;
reg [(`WB_FROM_LEN - 1):0]    id_ex_ctrl_sig_wb_from;


// EX / MEM pipeline registers
reg [4:0]             ex_mem_rd;
reg [4:0]             ex_mem_rs1;
reg [4:0]             ex_mem_rs2;
reg [(`DWIDTH - 1):0] ex_mem_mem_data;
reg [(`DWIDTH - 1):0] ex_mem_alu_out;

reg [(`MEM_TYPE_LEN - 1):0]   ex_mem_ctrl_sig_mem_type;
reg [(`MEM_WRITE_LEN - 1):0]  ex_mem_ctrl_sig_mem_write;
reg [(`WB_FROM_LEN - 1):0]    ex_mem_ctrl_sig_wb_from;

// MEM / WB pipeline registers
reg [4:0]             mem_wb_rd;
reg [4:0]             mem_wb_rs1;
reg [4:0]             mem_wb_rs2;
reg [(`DWIDTH - 1):0] mem_wb_alu_out;
reg [(`DWIDTH - 1):0] mem_wb_mem_data_out;
reg [(`WB_FROM_LEN - 1):0]  mem_wb_ctrl_sig_wb_from;


// instruction fetch stage
reg [(`DWIDTH - 1):0] pc;


wire [(`DWIDTH - 1):0]  pc_plus_4;
assign pc_plus_4 = pc + 4;

always @(posedge clk)
// branch logic is described at the end of decode stage code
begin
  pc <= (do_branch) ? branch_pc : pc_plus_4;
end

always @(posedge clk)
begin
  if_id_pc <= pc;
  if_id_inst <= aa; // TODO : instruction is from where?
end
  



// ----- instruction decode stage -----

// register file access
wire [4:0] rs1, rs2, rd, reg_write_rd;      // rd is from parsing instruction, reg_write_rd is from writeback stage
assign rs1  = if_id_inst[RS1_START:RS1_END];
assign rs2  = if_id_inst[RS2_START:RS2_END];
assign rd   = if_id_inst[RD_START:RD_END];

wire [(`DWIDTH - 1):0] rs1_data, rs2_data;
wire [(`DWIDTH - 1):0] reg_write_data;      // it will be assigned at write back stage

REG_FILE register_file (
  .CLK(),
  .WE(),
  .RST(),
  .RA1(rs1),
  .RA2(rs2),
  .WA(reg_write_rd),
  .WD(reg_write_data),
  .RD1(rs1_data),
  .RD2(rs2_data)
);

always @(posedge clk)
begin
  id_ex_rd <= rd;
  id_ex_rs1_data <= rs1_data;
  id_ex_rs2_data <= rs2_data;
end

// control unit
wire [(`ALU_OP_LEN - 1):0]      ctrl_sig_alu_op;
wire [(`ALU_SRC_LEN - 1):0]     ctrl_sig_alu_src2, ctrl_sig_alu_src1;
wire [(`IMM_LEN - 1):0]         ctrl_sig_imm_type;
wire [(`MEM_TYPE_LEN - 1):0]    ctrl_sig_mem_type;
wire [(`MEM_WRITE_LEN - 1):0]   ctrl_sig_mem_write;
wire [(`WB_FROM_LEN - 1):0]     ctrl_sig_wb_from;
wire [3:0]                      ctrl_sig_br_type;

control_unit control (
  .instruction (if_id_inst),
  .alu_op(ctrl_sig_alu_op),
  .memory_type(ctrl_sig_mem_type),
  .memory_write(ctrl_sig_mem_write),
  .writeback_from(ctrl_sig_wb_from),
  .imm_type(ctrl_sig_imm_type),
  .alu_src2(ctrl_sig_alu_src2),
  .alu_src1(ctrl_sig_alu_src1),
  .branch_type(ctrl_sig_br_type)
);

always @(posedge clk)
begin
  id_ex_ctrl_sig_alu_op <= ctrl_sig_alu_op;
  id_ex_ctrl_sig_alu_src2 <= ctrl_sig_alu_src2;
  id_ex_ctrl_sig_alu_src1 <= ctrl_sig_alu_src1;
  id_ex_ctrl_sig_imm_type <= ctrl_sig_imm_type;
  id_ex_ctrl_sig_mem_type <= ctrl_sig_mem_type;
end

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

wire [(`DWIDTH - 1):0] sign_ext_imm_i;
wire [(`DWIDTH - 1):0] sign_ext_imm_s;
wire [(`DWIDTH - 1):0] sign_ext_imm_sb;
wire [(`DWIDTH - 1):0] sign_ext_imm_u;
wire [(`DWIDTH - 1):0] sign_ext_imm_uj;
assign sign_ext_imm_i   = {(`DWIDTH - `IMM_I_WIDTH){imm_i[IMM_I_WIDTH - 1]}, imm_i};
assign sign_ext_imm_s   = {(`DWIDTH - `IMM_S_WIDTH){imm_s[IMM_S_WIDTH - 1]}, imm_s};
assign sign_ext_imm_sb  = {(`DWIDTH - `IMM_SB_WIDTH){imm_s[IMM_SB_WIDTH - 1]}, imm_sb};
assign sign_ext_imm_u   = {imm_u, (`DWIDTH - `IMM_U_WIDTH){1'b0}};
assign sign_ext_imm_uj  = {(`DWIDTH - `IMM_UJ_WIDTH){imm_s[IMM_UJ_WIDTH - 1]}, imm_uj};

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


// branch logic
// TODO : data hazard has to be resolved for rs1 and rs2
wire signed [(`DWIDTH - 1):0] signed_rs1_data;
wire signed [(`DWIDTH - 1):0] signed_rs2_data;
wire do_branch;
wire [(`DWIDTH - 1):0] branch_oper2;    // immediate data
wire [(`DWIDTH - 1):0] branch_oper1;    // pc or rs1(in case of jalr)
wire [(`DWIDTH - 1):0] branch_pc;
assign signed_rs1_data = rs1_data;
assign signed_rs2_data = rs2_data;
assign branch_oper2 = (ctrl_sig_br_type == BR_J) ?   (sign_ext_imm_uj << 1) :
                      (ctrl_sig_br_type == BR_JR) ?  (sign_ext_imm_i << 1) : (sign_ext_imm_sb << 1);
assign branch_oper1 = (ctrl_sig_br_type == BR_JR) ?  rs1_data : if_id_pc;   // TODO : have to resolve data hazard of rs1_data
assign branch_pc    = branch_oper1 + branch_oper2;
// TODO : an instruction right after the branch has to be dealt with
assign do_branch    = (ctrl_sig_br_type == BR_EQ)   ? signed_rs1_data == signed_rs2_data :
                      (ctrl_sig_br_type == BR_NE)   ? signed_rs1_data != signed_rs2_data :
                      (ctrl_sig_br_type == BR_LT)   ? signed_rs1_data < signed_rs2_data  :
                      (ctrl_sig_br_type == BR_GE)   ? signed_rs1_data >= signed_rs2_data :
                      (ctrl_sig_br_type == BR_LTU)  ? rs1_data < rs2_data   :
                      (ctrl_sig_br_type == BR_GEU)  ? rs1_data >= rs2_data  :
                      (ctrl_sig_br_type == BR_J || ctrl_sig_br_type == BR_JR) ? 1'b1 : 1'b0;    // 1'b0 is for BR_X




// ----- execution stage -----
wire [(`DWIDTH - 1):0] alu_out, alu_op2, alu_op1;

assign alu_oper2 = (id_ex_ctrl_sig_alu_src2 == ALU2_RS2)  ? id_ex_rs2_data : 
                   (id_ex_ctrl_sig_alu_src2 == ALU2_IMM)  ? id_ex_imm_data : 32{1'b0};

assign alu_oper1 = (id_ex_ctrl_sig_alu_src1 == ALU1_RS1)  ? id_ex_rs1_data :
                   (id_ex_ctrl_sig_alu_src1 == ALU1_PC)   ? id_ex_pc       :            // TODO : do not use pc, just do pc + 4 at wb stage
                   (id_ex_ctrl_sig_alu_src1 == ALU1_ZERO) ? 32{1'b0}       : 32{1'b0};

alu alu_operation (
  .src_op2(alu_oper2),
  .src_op1(alu_oper1),
  .alu_op(id_ex_ctrl_alu_op),
  .alu_out(alu_out)
);

always @(posedge clk)
begin
  ex_mem_rd <= id_ex_rd;
  ex_mem_data <= id_ex_rs2_data;
  ex_mem_alu_out <= alu_out;
end

always @(posedge clk)
begin
  ex_mem_ctrl_sig_mem_type <= id_ex_ctrl_sig_mem_type;
  ex_mem_ctrl_sig_mem_write <= id_ex_ctrl_sig_mem_write;
  ex_mem_ctrl_sig_wb_from <= id_ex_ctrl_sig_wb_from;
end




// ----- memory stage -----
wire mem_write, mem_ignore;
wire [4:0]  mem_type;
wire [11:0] mem_addr;
wire
wire [(`DWIDTH - 1):0] mem_data_in;
wire [(`DWIDTH - 1):0] mem_data_out;
wire [(`DWIDTH - 1):0] mem_data_out_ext;  // only for the load instruction
assign mem_addr = ex_mem_alu_out;
assign mem_data_in = ex_mem_data;
// 0: write, 1: read
assign mem_write = (ex_mem_ctrl_sig_mem_write == M_W) ? 1'b0 : 1'b1;
// 0: memory opeation occurs, 1: does not occur
assign mem_ignore = (ex_mem_ctrl_sig_mem_write == M_X) ? 1'b1 : 1'b0;
assign mem_type = ex_mem_ctrl_mem_type;
// only for the load instruction
assign mem_data_out_ext = (mem_type == MT_HU) ? {(`DWIDTH - `HALF){1'b0}, mem_data_out[(`HALF - 1):0]} :
                          (mem_type == MT_BU) ? {(`DWIDTH - `BYTE){1'b0}, mem_data_out[(`BYTE - 1):0]} :
                          (mem_type == MT_H)  ? {(`DWIDTH - `HALF){mem_data_out[`HALF - 1]}, mem_data_out[(`HALF - 1):0]} :
                          (mem_type == MT_B)  ? {(`DWIDTH - `BYTE){mem_data_out[`BYTE - 1]}, mem_data_out[(`BYTE - 1):0]} :
                                                32{1'b0};
// TODO : where to put multiplexr which is used for data selection between memory out and alu out
// TODO : write back stage or memory stage?

// memory module do not have sign-extended operation
// negative triggered memory
SP_SRAM data_memory (
  .WEN(mem_write),
  .DI(mem_data_in),
  .ADDR(mem_addr),
  .BE(mem_type),
  .DOUT(mem_data_out),
  .CLK(),
  .CSN(mem_ignore)
);

always @(posedge clk)
begin
  mem_wb_rd <= ex_mem_rd;
  mem_wb_alu_out <= ex_mem_alu_out;
  mem_wb_mem_data_out <= mem_data_out_ext;
  mem_wb_ctrl_sig_wb_from <= ex_mem_ctrl_sig_wb_from;
end



// ----- write back stage -----
wire [1:0]              wb_from;
assign wb_from        = mem_wb_ctrl_sig_wb_from;
assign reg_write_rd   = mem_wb_rd;
assign reg_write_data = (wb_from == FROM_ALU) ? mem_wb_alu_out :
                        (wb_from == FROM_MEM) ? mem_wb_mem_data_out :
                        32{1'b0};

