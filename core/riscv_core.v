`include "../units/alu.v"
`include "../units/control_unit.v"
`include "../define/control_signals.v"
`include "../define/consts.v"

module RISCV_TOP (
  output [31:0] debug_if_id_inst,
  output [31:0] debug_if_id_pc,
  // general signals
  input CLK,
  input RSTn,
  // Instruction memory signals
  output I_MEM_CSN,                     // no instruction memory operation
  input [(`DWIDTH - 1):0] I_MEM_DI,     // core will receive instruction from this wire
  output [(`DWIDTH - 1):0] I_MEM_ADDR,  // core will send address of an instruction(pc)
  // Data memory signals
  output D_MEM_CSN,                     // no data memory operation
  input [(`DWIDTH - 1):0] D_MEM_DI,     // core will receive data from this wire
	input D_READY,
  output [(`DWIDTH - 1):0] D_MEM_DOUT,  // core will send data to be written
  output [(`DWIDTH - 1):0] D_MEM_ADDR,  // core will send address of data memory
  output D_MEM_WEN,                     // core will send the write enable signal
  output [(`MEM_TYPE_LEN - 1):0] D_MEM_BE,// core will send memory type (BYTE, HALF, or WORD)
  // Register file signals
  output RF_WE,                           // core will send write enable signal of register file
  output [(`REG_ADDR_LEN - 1):0] RF_RA1,  // core will send address of register1
  output [(`REG_ADDR_LEN - 1):0] RF_RA2,  // core will send address of register2
  output [(`REG_ADDR_LEN - 1):0] RF_WA,   // core will send address of destination register
  input [(`DWIDTH - 1):0] RF_RD1,       // core will receive rs1 data
  input [(`DWIDTH - 1):0] RF_RD2,       // core will receive rs2 data
  output [(`DWIDTH - 1):0] RF_WD,       // core will send data to be written
  input DE_OP_EN                        // enable delayed branch mode
);

// ---------- pipeline registers ----------

assign debug_if_id_inst = if_id_pc;
assign debug_if_id_inst = I_MEM_DI;
// pc register
reg [(`DWIDTH - 1):0] pc;


// IF / ID pipeline registers
reg [(`DWIDTH - 1):0] if_id_pc;

// ID / EX pipeline registers
reg [(`DWIDTH - 1):0] id_ex_pc;
reg [(`DWIDTH - 1):0] id_ex_inst;
reg [(`REG_ADDR_LEN - 1):0] id_ex_rd_addr;
reg [(`REG_ADDR_LEN - 1):0] id_ex_rs1_addr;
reg [(`REG_ADDR_LEN - 1):0] id_ex_rs2_addr;
reg [(`DWIDTH - 1):0] id_ex_alu_data1;
reg [(`DWIDTH - 1):0] id_ex_alu_data2;
reg [(`DWIDTH - 1):0] id_ex_imm_data;
reg [(`DWIDTH - 1):0] id_ex_mem_data;

reg [(`IMM_TYPE_LEN - 1):0] id_ex_ctrl_sig_imm_type;
reg [(`ALU_FN_LEN - 1):0]   id_ex_ctrl_sig_alu_fn;
reg [(`ALU_SRC_LEN - 1):0]  id_ex_ctrl_sig_alu_src2, id_ex_ctrl_sig_alu_src1;

reg [(`MEM_TYPE_LEN - 1):0]   id_ex_ctrl_sig_mem_type;
reg [(`MEM_WRITE_LEN - 1):0]  id_ex_ctrl_sig_mem_rw;
reg [(`WB_FROM_LEN - 1):0]    id_ex_ctrl_sig_wb_from;
reg [(`BR_TYPE_LEN - 1):0]    id_ex_ctrl_sig_br_type;
reg                           id_ex_ctrl_sig_reg_write;


// EX / MEM pipeline registers
reg [(`REG_ADDR_LEN - 1):0] ex_mem_rd_addr;
reg [(`REG_ADDR_LEN - 1):0] ex_mem_rs2_addr;
reg [(`DWIDTH - 1):0] ex_mem_mem_data;
reg [(`DWIDTH - 1):0] ex_mem_alu_out;
reg [(`DWIDTH - 1):0] ex_mem_inst;

reg [(`MEM_TYPE_LEN - 1):0]   ex_mem_ctrl_sig_mem_type;
reg [(`MEM_WRITE_LEN - 1):0]  ex_mem_ctrl_sig_mem_rw;
reg [(`WB_FROM_LEN - 1):0]    ex_mem_ctrl_sig_wb_from;
reg [(`BR_TYPE_LEN - 1):0]    ex_mem_ctrl_sig_br_type;
reg                           ex_mem_ctrl_sig_reg_write;

// MEM / WB pipeline registers
reg [(`REG_ADDR_LEN - 1):0] mem_wb_rd_addr;
reg [(`DWIDTH - 1):0] mem_wb_alu_out;
reg [(`DWIDTH - 1):0] mem_wb_mem_data_out;
reg [(`DWIDTH - 1):0] mem_wb_inst;
reg [(`MEM_TYPE_LEN - 1):0]	mem_wb_ctrl_sig_mem_type;
reg [(`WB_FROM_LEN - 1):0]  mem_wb_ctrl_sig_wb_from;
reg                         mem_wb_ctrl_sig_reg_write;
reg							mem_wb_ctrl_sig_mem_rw;
reg	[1:0]					mem_wb_mem_pos;


reg [(`DWIDTH - 1):0] finish_sim;


// ---------- instruction fetch stage ----------

initial begin
	pc = 32'b00000000_00000000_00000000_00000000;
/*
	if_id_pc = 0; 
	id_ex_pc = 0;
	id_ex_inst = 0;
	id_ex_rd_addr = 0;
	id_ex_rs1_addr = 0;
	id_ex_rs2_addr = 0;
	id_ex_alu_data1 = 0;
	id_ex_alu_data2 = 0;
	id_ex_imm_data = 0;
	id_ex_mem_data = 0;
	id_ex_ctrl_sig_imm_type = 0;
	id_ex_ctrl_sig_alu_fn = 0;
	id_ex_ctrl_sig_alu_src2 = 0;
	id_ex_ctrl_sig_alu_src1 = 0;
	id_ex_ctrl_sig_mem_type = 0;
	id_ex_ctrl_sig_wb_from = 0;
	id_ex_ctrl_sig_br_type = 0;
	id_ex_ctrl_reg_write = 0;
	ex_mem_rd_addr = 0;
	ex_mem_rs2_addr = 0;
	ex_mem_mem_data = 0;
	ex_mem_alu_out = 0;
	ex_mem_inst = 0;
	ex_mem_ctrl_sig_mem_tyep = 0;
	ex_mem_ctrl_sig_mem_rw = 0;
	ex_mem_ctrl_sig_wb_from = 0;
	ex_mem_ctrl_sig_br_type = 0;
	ex_mem_ctrl_sig_reg_write = 0;
	mem_wb_rd_addr = 0;
	mem_wb_alu_out = 0;
	mem_wb_mem_data_out = 0;
	mem_wb_inst = 0;
	mem_wb_ctrl_sig_mem_type = 0;
	mem_wb_ctrl_sig_wb_from = 0;
	mem_wb_ctrl_sig_reg_write = 0;
	mem_wb_ctrl_sig_mem_rw = 0;
	mem_wb_mem_pos = 0;
*/
always @(posedge CLK)
  if (finish_sim === 32'b00000000_00000000_10000000_01100111)
	$finish;

wire [(`DWIDTH - 1):0]  pc_plus_4;
assign pc_plus_4 = pc + 4;

always @(posedge CLK)
begin
  if (mem_stall === 1'b1 || load_br_stall === 1'b1 || load_br_stall === 1'b1 || load_br_stall2 === 1'b1) begin
	pc <= pc;
  end
  else begin
	if (id_do_branch)
		pc <= id_branch_pc;
	else
		pc <= pc_plus_4;
  end
/*
  if (mem_stall === 1'b1)
	pc <= pc;
  else if (load_br_stall === 1'b1)
    pc <= if_id_pc;
  else if (id_do_branch === 1'b1)
    pc <= id_branch_pc;
  else if (load_use_stall === 1'b1)
    pc <= pc;
  //else if (mem_stall === 1'b1)
	//pc <= pc;
  else
    pc <= pc_plus_4;
*/
end

// TODO: how to deal with 2 stall cycles?
always @(posedge CLK)
begin
  if (mem_stall === 1'b1 || load_use_stall === 1'b1 || load_br_stall === 1'b1 || load_br_stall2 === 1'b1)
	if_id_pc <= if_id_pc;
  //else if ((load_br_stall === 1'b1) || ((id_do_branch === 1'b1) && !DE_OP_EN)) begin
	//if_id_pc <= 32'b0;
    //TB_RISCV.i_mem1.outline <= `BUBBLE;
  else if (id_do_branch === 1'b1 && !DE_OP_EN) begin
	if_id_pc <= 32'b0;
    TB_RISCV.i_mem1.outline <= `BUBBLE;
  end
  else
  	if_id_pc <= pc;
  //else
	//if_id_pc <= pc;
  //else if (!load_use_stall)
    //if_id_inst <= I_MEM_DI;
  //else
    //if_id_inst <= I_MEM_DI;
end

// interface between core and instruction memory
assign I_MEM_ADDR = pc;
assign I_MEM_CSN = (load_use_stall === 1'b1 || mem_stall === 1'b1 || load_br_stall === 1'b1 || load_br_stall2 === 1'b1) ? 1'b1 : 1'b0;




// ---------- instruction decode stage ----------

// register file access
wire [(`REG_ADDR_LEN - 1):0] id_rs1_addr, id_rs2_addr, id_rd_addr, reg_write_addr;      // rd is from parsing instruction, reg_write_rd is from writeback stage
assign id_rs1_addr  = I_MEM_DI[`RS1_START:`RS1_END];
assign id_rs2_addr  = I_MEM_DI[`RS2_START:`RS2_END];
assign id_rd_addr   = I_MEM_DI[`RD_START:`RD_END];

//wire [(`DWIDTH - 1):0] id_rs1_data, id_rs2_data;
wire [(`DWIDTH - 1):0] reg_write_data;      // it will be assigned at write back stage


// interface bewteen core and register file
assign RF_WE  = mem_wb_ctrl_sig_reg_write;
assign RF_RA1 = id_rs1_addr;
assign RF_RA2 = id_rs2_addr;
assign RF_WA  = reg_write_addr;
assign RF_WD  = reg_write_data;


// control unit
wire [(`ALU_FN_LEN - 1):0]      ctrl_sig_alu_fn;
wire [(`ALU_SRC_LEN - 1):0]     ctrl_sig_alu_src2, ctrl_sig_alu_src1;
wire [(`IMM_TYPE_LEN - 1):0]    ctrl_sig_imm_type;
wire [(`MEM_TYPE_LEN - 1):0]    ctrl_sig_mem_type;
wire [(`MEM_WRITE_LEN - 1):0]   ctrl_sig_mem_rw;
wire [(`WB_FROM_LEN - 1):0]     ctrl_sig_wb_from;
wire [(`BR_TYPE_LEN - 1):0]     ctrl_sig_br_type;
wire                            ctrl_sig_reg_write;

control_unit control (
  .instruction (I_MEM_DI),
  .alu_fn(ctrl_sig_alu_fn),
  .memory_type(ctrl_sig_mem_type),
  .memory_rw(ctrl_sig_mem_rw),
  .writeback_from(ctrl_sig_wb_from),
  .imm_type(ctrl_sig_imm_type),
  .alu_src2(ctrl_sig_alu_src2),
  .alu_src1(ctrl_sig_alu_src1),
  .branch_type(ctrl_sig_br_type),
  .register_write(ctrl_sig_reg_write)
);


// immediate generator
wire [(`IMM_I_WIDTH - 1):0]   imm_i;
wire [(`IMM_S_WIDTH - 1):0]   imm_s;
wire [(`IMM_SB_WIDTH - 1):0]  imm_sb;
wire [(`IMM_U_WIDTH - 1):0]   imm_u;
wire [(`IMM_UJ_WIDTH - 1):0]  imm_uj;
assign imm_i  = I_MEM_DI[31:20];
assign imm_s  = {I_MEM_DI[31:25], I_MEM_DI[11:7]};
assign imm_sb = {I_MEM_DI[31], I_MEM_DI[7], I_MEM_DI[30:25], I_MEM_DI[11:8]};
assign imm_u  = I_MEM_DI[31:12];
assign imm_uj = {I_MEM_DI[31], I_MEM_DI[19:12], I_MEM_DI[20], I_MEM_DI[30:21]};

wire [(`DWIDTH - 1):0] sign_ext_imm_i;
wire [(`DWIDTH - 1):0] sign_ext_imm_s;
wire [(`DWIDTH - 1):0] sign_ext_imm_sb;
wire [(`DWIDTH - 1):0] sign_ext_imm_u;
wire [(`DWIDTH - 1):0] sign_ext_imm_uj;
assign sign_ext_imm_i   = {{(`DWIDTH - `IMM_I_WIDTH){imm_i[`IMM_I_WIDTH - 1]}}, imm_i};
assign sign_ext_imm_u   = {imm_u, {(`DWIDTH - `IMM_U_WIDTH){1'b0}}};
assign sign_ext_imm_s   = {{(`DWIDTH - `IMM_S_WIDTH){imm_s[`IMM_S_WIDTH - 1]}}, imm_s};
assign sign_ext_imm_uj  = {{(`DWIDTH - `IMM_UJ_WIDTH){imm_uj[`IMM_UJ_WIDTH - 1]}}, imm_uj};
assign sign_ext_imm_sb  = {{(`DWIDTH - `IMM_SB_WIDTH){imm_sb[`IMM_SB_WIDTH - 1]}}, imm_sb};


// branch logic
wire signed [(`DWIDTH - 1):0] id_signed_rs1_data;
wire signed [(`DWIDTH - 1):0] id_signed_rs2_data;
wire id_do_branch;
wire [(`DWIDTH - 1):0] id_branch_oper2;    // immediate data
wire [(`DWIDTH - 1):0] id_branch_oper1;    // pc or rs1(in case of jalr)
wire [(`DWIDTH - 1):0] id_branch_pc;
assign id_signed_rs1_data = id_bypassed_rs1_data;
assign id_signed_rs2_data = id_bypassed_rs2_data;
assign id_branch_oper2 =  (ctrl_sig_br_type === `BR_J) ?   (sign_ext_imm_uj << 1) :
                          (ctrl_sig_br_type === `BR_JR) ?  (sign_ext_imm_i << 1) : (sign_ext_imm_sb << 1);
assign id_branch_oper1 =  (ctrl_sig_br_type === `BR_JR) ?  id_bypassed_rs1_data : if_id_pc; 
assign id_branch_pc    =  id_branch_oper1 + id_branch_oper2;
assign id_do_branch    =  (ctrl_sig_br_type === `BR_EQ)   ? id_signed_rs1_data === id_signed_rs2_data :
                          (ctrl_sig_br_type === `BR_NE)   ? id_signed_rs1_data != id_signed_rs2_data :
                          (ctrl_sig_br_type === `BR_LT)   ? id_signed_rs1_data < id_signed_rs2_data  :
                          (ctrl_sig_br_type === `BR_GE)   ? id_signed_rs1_data >= id_signed_rs2_data :
                          (ctrl_sig_br_type === `BR_LTU)  ? id_bypassed_rs1_data < id_bypassed_rs2_data   :
                          (ctrl_sig_br_type === `BR_GEU)  ? id_bypassed_rs1_data >= id_bypassed_rs2_data  :
                          (ctrl_sig_br_type === `BR_J || ctrl_sig_br_type === `BR_JR) ? 1'b1 : 1'b0;    // 1'b0 is for BR_X


// hazard detection unit  --- needed for stall
wire load_use_stall;    // stall 1 cycle
wire load_br_stall;     // stall 2 cycles
wire mem_stall; // memory ready
assign load_use_stall = (id_ex_ctrl_sig_mem_rw === `M_R) &&   // check whether preceding is a load instruction
                        (id_ex_rd_addr === id_rs1_addr || ((id_ex_rd_addr === id_rs2_addr) && (ctrl_sig_mem_rw != `M_W)));   // ctrl_sig_mem_rw != M_W is for load-store 
assign load_br_stall  = (ctrl_sig_br_type != `BR_X && ctrl_sig_br_type != `BR_J) && 
                        (id_ex_ctrl_sig_mem_rw === `M_R) && 
                        (id_ex_rd_addr === id_rs1_addr || id_ex_rd_addr === id_rs2_addr);
assign load_br_stall2 = (ctrl_sig_br_type != `BR_X && ctrl_sig_br_type != `BR_J) &&
						(ex_mem_ctrl_sig_mem_rw === `M_R) &&
						(ex_mem_rd_addr === id_rs1_addr || ex_mem_rd_addr === id_rs2_addr);
assign mem_stall = (mem_ignore === 1'b0) && (mem_ready === 1'b0);

// bypassing logic for branch unit
wire id_from_exe_mem_rs2, id_from_mem_wb_rs2;
wire id_from_exe_mem_rs1, id_from_mem_wb_rs1;
wire id_from_exe_alu_out_rs1, id_from_exe_alu_out_rs2; // for arith-br bypassing
wire [(`DWIDTH - 1):0] id_bypassed_rs1_data, id_bypassed_rs2_data;
assign id_from_exe_mem_rs2 =  (ex_mem_ctrl_sig_reg_write === `REG_W) && 
                              (ex_mem_rd_addr != `REG_X0) && 
                              (ex_mem_rd_addr === id_rs2_addr);
assign id_from_mem_wb_rs2  =  (mem_wb_ctrl_sig_reg_write === `REG_W) && 
                              (mem_wb_rd_addr != `REG_X0) && 
                              (mem_wb_rd_addr === id_rs2_addr);
assign id_from_exe_mem_rs1 =  (ex_mem_ctrl_sig_reg_write === `REG_W) && 
                              (ex_mem_rd_addr != `REG_X0) && 
                              (ex_mem_rd_addr === id_rs1_addr);
assign id_from_mem_wb_rs1  =  (mem_wb_ctrl_sig_reg_write === `REG_W) && 
                              (mem_wb_rd_addr != `REG_X0) && 
                              (mem_wb_rd_addr === id_rs1_addr);
assign id_from_exe_alu_out_rs1 =  (id_ex_ctrl_sig_reg_write === `REG_W) &&
                                  (id_ex_rd_addr != `REG_X0) &&
                                  (id_ex_rd_addr === id_rs1_addr);
assign id_from_exe_alu_out_rs2 =  (id_ex_ctrl_sig_reg_write === `REG_W) &&
                                  (id_ex_rd_addr != `REG_X0) &&
                                  (id_ex_rd_addr === id_rs2_addr);
assign id_bypassed_rs2_data = (id_from_exe_alu_out_rs2 === 1'b1) ? ex_alu_out :
                              (id_from_exe_mem_rs2 === 1'b1) ?     ex_mem_alu_out :
                              (id_from_mem_wb_rs2 === 1'b1) ? reg_write_data : RF_RD2;
assign id_bypassed_rs1_data = (id_from_exe_alu_out_rs1 === 1'b1) ? ex_alu_out :
                              (id_from_exe_mem_rs1 === 1'b1) ?     ex_mem_alu_out :
                              (id_from_mem_wb_rs1 === 1'b1) ? reg_write_data : RF_RD1;

wire [(`DWIDTH - 1) : 0] id_alu_oper2, id_alu_oper1;
assign id_alu_oper2 = (id_from_mem_wb_rs2 === 1'b1) ? reg_write_data : RF_RD2;
assign id_alu_oper1 = (id_from_mem_wb_rs1 === 1'b1) ? reg_write_data : RF_RD1;

// pipeline register operation
always @(posedge CLK)
begin
  //id_ex_inst <= I_MEM_DI;
  //id_ex_pc <= if_id_pc;
  if (mem_stall === 1'b1) begin

  end
  else if (load_use_stall === 1'b1 || load_br_stall === 1'b1 || load_br_stall2 === 1'b1) begin	// this includes !load_br_stall
	id_ex_pc				  <= 32'b0;
	id_ex_inst				  <= 32'b0;
	id_ex_rd_addr			  <= 5'b0;
	id_ex_rs1_addr			  <= 5'b0;
	id_ex_rs2_addr			  <= 5'b0;
    id_ex_alu_data1 		  <= 32'b0;
    id_ex_alu_data2 		  <= 32'b0;
    id_ex_ctrl_sig_alu_fn     <= `ALU_X;
    id_ex_ctrl_sig_alu_src2   <= `ALU2_X;
    id_ex_ctrl_sig_alu_src1   <= `ALU1_X;
    id_ex_ctrl_sig_mem_type   <= `MT_X;
	id_ex_ctrl_sig_br_type	  <= `BR_X;
    id_ex_ctrl_sig_mem_rw     <= `M_X;
    id_ex_ctrl_sig_wb_from    <= `FROM_X;
    id_ex_ctrl_sig_reg_write  <= `REG_X;
  end
  else begin	// this includes load_br_stall
	id_ex_inst 		<= I_MEM_DI;
	id_ex_pc		<= if_id_pc;
    id_ex_rd_addr   <= id_rd_addr;
    id_ex_rs1_addr  <= id_rs1_addr;
    id_ex_rs2_addr  <= id_rs2_addr;
    //id_ex_alu_data1  <= id_alu_oper1;
    //id_ex_alu_data2  <= id_alu_oper2;
    id_ex_alu_data1 <= id_alu_oper1;
    id_ex_alu_data2 <= id_alu_oper2;
    
    case (ctrl_sig_imm_type)
      `IMM_I:    id_ex_imm_data <= sign_ext_imm_i;
      `IMM_U:    id_ex_imm_data <= sign_ext_imm_u;
      `IMM_S:    id_ex_imm_data <= sign_ext_imm_s;
      `IMM_UJ:   id_ex_imm_data <= sign_ext_imm_uj;
      `IMM_SB:   id_ex_imm_data <= sign_ext_imm_sb;
      default:  id_ex_imm_data <= {32{1'b0}};      // IMM_X
    endcase //id_ex_mem_data            <= id_bypassed_rs2_data;
    id_ex_ctrl_sig_imm_type   <= ctrl_sig_imm_type;
    id_ex_ctrl_sig_alu_fn     <= ctrl_sig_alu_fn;
    id_ex_ctrl_sig_alu_src2   <= ctrl_sig_alu_src2;
    id_ex_ctrl_sig_alu_src1   <= ctrl_sig_alu_src1;
    id_ex_ctrl_sig_mem_type   <= ctrl_sig_mem_type;
	id_ex_ctrl_sig_br_type	  <= ctrl_sig_br_type;
    id_ex_ctrl_sig_mem_rw     <= ctrl_sig_mem_rw;
    id_ex_ctrl_sig_wb_from    <= ctrl_sig_wb_from;
    id_ex_ctrl_sig_reg_write  <= ctrl_sig_reg_write;
  end
/*
  else if (mem_stall != 1'b1) begin	// this includes !load_br_stall
	id_ex_inst 		<= I_MEM_DI;
	id_ex_pc		<= if_id_pc;
    id_ex_rd_addr   <= id_rd_addr;
    id_ex_rs1_addr  <= id_rs1_addr;
    id_ex_rs2_addr  <= id_rs2_addr;
    //id_ex_alu_data1  <= id_alu_oper1;
    //id_ex_alu_data2  <= id_alu_oper2;
    id_ex_alu_data1 <= id_alu_oper1;
    id_ex_alu_data2 <= id_alu_oper2;
    
    case (ctrl_sig_imm_type)
      `IMM_I:    id_ex_imm_data <= sign_ext_imm_i;
      `IMM_U:    id_ex_imm_data <= sign_ext_imm_u;
      `IMM_S:    id_ex_imm_data <= sign_ext_imm_s;
      `IMM_UJ:   id_ex_imm_data <= sign_ext_imm_uj;
      `IMM_SB:   id_ex_imm_data <= sign_ext_imm_sb;
      default:  id_ex_imm_data <= {32{1'b0}};      // IMM_X
    endcase //id_ex_mem_data            <= id_bypassed_rs2_data;
    id_ex_ctrl_sig_imm_type   <= ctrl_sig_imm_type;
    id_ex_ctrl_sig_alu_fn     <= ctrl_sig_alu_fn;
    id_ex_ctrl_sig_alu_src2   <= ctrl_sig_alu_src2;
    id_ex_ctrl_sig_alu_src1   <= ctrl_sig_alu_src1;
    id_ex_ctrl_sig_mem_type   <= ctrl_sig_mem_type;
    id_ex_ctrl_sig_mem_rw     <= ctrl_sig_mem_rw;
    id_ex_ctrl_sig_wb_from    <= ctrl_sig_wb_from;
    id_ex_ctrl_sig_reg_write  <= ctrl_sig_reg_write;
  end
*/
end
  

// ---------- execution stage ----------
wire [(`DWIDTH - 1):0] ex_alu_out, ex_alu_oper2, ex_alu_oper1;
wire [(`DWIDTH - 1):0] ex_bypassed_rs2_data, ex_bypassed_rs1_data;    // bypassing will be considered

// bypassing logic wires
assign ex_alu_oper2 = (id_ex_ctrl_sig_alu_src2 === `ALU2_RS2)  ? ex_bypassed_rs2_data   : 
                      (id_ex_ctrl_sig_alu_src2 === `ALU2_IMM)  ? id_ex_imm_data : {32{1'b0}};

assign ex_alu_oper1 = (id_ex_ctrl_sig_alu_src1 === `ALU1_RS1)  ? ex_bypassed_rs1_data   :
					  (id_ex_ctrl_sig_alu_src1 === `ALU1_PC)   ? id_ex_pc			   :
                      (id_ex_ctrl_sig_alu_src1 === `ALU1_ZERO) ? {32{1'b0}}     : {32{1'b0}};

alu alu_operation (
  .oper2(ex_alu_oper2),
  .oper1(ex_alu_oper1),
  .alu_fn(id_ex_ctrl_sig_alu_fn),
  .alu_out(ex_alu_out)
);

assign ex_from_exe_mem_rs2 =  (ex_mem_ctrl_sig_reg_write === `REG_W) && 
                              (ex_mem_rd_addr != `REG_X0) && 
                              (ex_mem_rd_addr === id_ex_rs2_addr);
assign ex_from_mem_wb_rs2  =  (mem_wb_ctrl_sig_reg_write === `REG_W) && 
                              (mem_wb_rd_addr != `REG_X0) && 
                              (mem_wb_rd_addr === id_ex_rs2_addr);
assign ex_from_exe_mem_rs1 =  (ex_mem_ctrl_sig_reg_write === `REG_W) && 
                              (ex_mem_rd_addr != `REG_X0) && 
                              (ex_mem_rd_addr === id_ex_rs1_addr);
assign ex_from_mem_wb_rs1  =  (mem_wb_ctrl_sig_reg_write === `REG_W) && 
                              (mem_wb_rd_addr != `REG_X0) && 
                              (mem_wb_rd_addr === id_ex_rs1_addr);

// TODO : do we need !ex_from_exe_mem_rs? (because forward_from_exe_mem_rs2 is considered before it)
assign ex_bypassed_rs2_data = (ex_from_exe_mem_rs2 === 1'b1) ? ex_mem_alu_out :
                              (ex_from_mem_wb_rs2 === 1'b1) ? reg_write_data : id_ex_alu_data2;
assign ex_bypassed_rs1_data = (ex_from_exe_mem_rs1 === 1'b1) ? ex_mem_alu_out :
                              (ex_from_mem_wb_rs1 === 1'b1) ? reg_write_data : id_ex_alu_data1;


// pipeline register operation
always @(posedge CLK)
begin
	if (mem_stall != 1'b1) begin
	  ex_mem_inst	  <= id_ex_inst;
	  //ex_mem_rs1_addr <= id_ex_rs1_addr;
		ex_mem_rs2_addr <= id_ex_rs2_addr;          // for load-store
		ex_mem_rd_addr  <= id_ex_rd_addr;
	  ex_mem_mem_data <= ex_bypassed_rs2_data;    // only for the store instruction (has to pass bypassed data becaused of arith-store)
	  ex_mem_alu_out  <= ex_alu_out;              // load, store => memory address, arithmetic => datum that goes into rd     
	  ex_mem_ctrl_sig_mem_type  <= id_ex_ctrl_sig_mem_type;
	  ex_mem_ctrl_sig_mem_rw    <= id_ex_ctrl_sig_mem_rw;
	  ex_mem_ctrl_sig_wb_from   <= id_ex_ctrl_sig_wb_from;
	  ex_mem_ctrl_sig_reg_write <= id_ex_ctrl_sig_reg_write;
	  ex_mem_ctrl_sig_br_type	<= id_ex_ctrl_sig_br_type;
	end
end


// ---------- memory stage ----------
wire mem_is_load_store;
wire mem_write, mem_ignore, mem_ready;
wire [(`MEM_TYPE_LEN - 1):0]  store_mem_type, load_mem_type;
wire [(`DWIDTH - 1):0] mem_addr;
wire [(`DWIDTH - 1):0] mem_data_in;
//wire [(`DWIDTH - 1):0] mem_data_out;
wire [(`DWIDTH - 1):0] mem_data_out_ext;  // only for the load instruction
assign mem_addr           = ex_mem_alu_out;
assign mem_write          = (ex_mem_ctrl_sig_mem_rw === `M_W) ? 1'b0 : 1'b1; // 0: write, 1: read
assign mem_ignore         = (ex_mem_ctrl_sig_mem_rw === `M_R || ex_mem_ctrl_sig_mem_rw === `M_W) ? 1'b0 : 1'b1;    // 0: memory opeation occurs, 1: does not occur
assign store_mem_type     = ex_mem_ctrl_sig_mem_type;
assign load_mem_type      = mem_wb_ctrl_sig_mem_type;

// TODO: I'm not sure load-store dependence is correctly handled. (bypassing logic)
assign mem_is_load_store  = (mem_wb_ctrl_sig_mem_rw === `M_R && mem_write === 1'b0 && (mem_wb_rd_addr === ex_mem_rs2_addr));
assign mem_data_in        = (mem_is_load_store === 1'b1) ? mem_data_out_ext : ex_mem_mem_data;
// only for the load instruction
assign mem_data_out_ext	  = (load_mem_type === `MT_B && mem_wb_mem_pos[1:0] === 2'b00) ? {{24{D_MEM_DI[7]}}, D_MEM_DI[7:0]} :
							(load_mem_type === `MT_B && mem_wb_mem_pos[1:0] === 2'b01) ? {{24{D_MEM_DI[15]}}, D_MEM_DI[15:8]} :
							(load_mem_type === `MT_B && mem_wb_mem_pos[1:0] === 2'b10) ? {{24{D_MEM_DI[23]}}, D_MEM_DI[23:16]} :
							(load_mem_type === `MT_B && mem_wb_mem_pos[1:0] === 2'b11) ? {{24{D_MEM_DI[31]}}, D_MEM_DI[31:24]} :
							(load_mem_type === `MT_H && mem_wb_mem_pos[1:0] === 2'b00) ? {{16{D_MEM_DI[15]}}, D_MEM_DI[15:0]} :
							(load_mem_type === `MT_H && mem_wb_mem_pos[1:0] === 2'b10) ? {{16{D_MEM_DI[31]}}, D_MEM_DI[31:16]} :
							(load_mem_type === `MT_BU && mem_wb_mem_pos[1:0] === 2'b00) ? {{24{1'b0}}, D_MEM_DI[7:0]} :
							(load_mem_type === `MT_BU && mem_wb_mem_pos[1:0] === 2'b01) ? {{24{1'b0}}, D_MEM_DI[15:8]} :
							(load_mem_type === `MT_BU && mem_wb_mem_pos[1:0] === 2'b10) ? {{24{1'b0}}, D_MEM_DI[23:16]} :
							(load_mem_type === `MT_BU && mem_wb_mem_pos[1:0] === 2'b11) ? {{24{1'b0}}, D_MEM_DI[31:24]} :
							(load_mem_type === `MT_HU && mem_wb_mem_pos[1:0] === 2'b00) ? {{16{1'b0}}, D_MEM_DI[15:0]} :
							(load_mem_type === `MT_HU && mem_wb_mem_pos[1:0] === 2'b00) ? {{16{1'b0}}, D_MEM_DI[31:16]} :
							(load_mem_type === `MT_W) ? D_MEM_DI : {32{1'b0}};
							
						 
/*
assign mem_data_out_ext   = (load_mem_type ==== `MT_HU) ? {{(`DWIDTH - `HALF){1'b0}}, D_MEM_DI[(`HALF - 1):0]} :
                            (load_mem_type ==== `MT_BU) ? {{(`DWIDTH - `BYTE){1'b0}}, D_MEM_DI[(`BYTE - 1):0]} :
                            (load_mem_type ==== `MT_H)  ? {{(`DWIDTH - `HALF){D_MEM_DI[`HALF - 1]}}, D_MEM_DI[(`HALF - 1):0]} :
                            (load_mem_type ==== `MT_B)  ? {{(`DWIDTH - `BYTE){D_MEM_DI[`BYTE - 1]}}, D_MEM_DI[(`BYTE - 1):0]} :
							(load_mem_type ==== `MT_W)  ? D_MEM_DI : {32{1'b0}};
*/

// interface between core and data memory
assign D_MEM_CSN  = mem_ignore;
//assign D_MEM_DOUT = mem_data_in;
assign mem_ready = D_READY;
assign D_MEM_ADDR = mem_addr;
assign D_MEM_WEN  = mem_write;
//assign D_MEM_BE   	=	store_mem_type;
assign D_MEM_BE 	=	(store_mem_type === `MT_B && mem_addr[1:0] === 2'b00) ? 4'b0001 :
					 	(store_mem_type === `MT_B && mem_addr[1:0] === 2'b01) ? 4'b0010 :
					 	(store_mem_type === `MT_B && mem_addr[1:0] === 2'b10) ? 4'b0100 :
					 	(store_mem_type === `MT_B && mem_addr[1:0] === 2'b11) ? 4'b1000 :
					 	(store_mem_type === `MT_H && mem_addr[1:0] === 2'b00) ? 4'b0011 :
					 	(store_mem_type === `MT_H && mem_addr[1:0] === 2'b10) ? 4'b1100 :
						(store_mem_type === `MT_W) ? 4'b1111 : 4'b0000;
assign D_MEM_DOUT 	=	(store_mem_type === `MT_B && mem_addr[1:0] === 2'b00) ? mem_data_in :
					 	(store_mem_type === `MT_B && mem_addr[1:0] === 2'b01) ? {mem_data_in[23:0], {8{1'b0}}} :
					 	(store_mem_type === `MT_B && mem_addr[1:0] === 2'b10) ? {mem_data_in[15:0], {16{1'b0}}} :
					 	(store_mem_type === `MT_B && mem_addr[1:0] === 2'b11) ? {mem_data_in[7:0], {24{1'b0}}} :
					 	(store_mem_type === `MT_H && mem_addr[1:0] === 2'b00) ? mem_data_in :
					 	(store_mem_type === `MT_H && mem_addr[1:0] === 2'b10) ? {mem_data_in[15:0], {16{1'b0}}} :
						(store_mem_type === `MT_W) ? mem_data_in : {32{1'b0}};
						


// pipeline register operation
always @(posedge CLK)
begin
  if (mem_stall === 1'b1) begin
  end
  else begin
  mem_wb_inst    <= ex_mem_inst;
  mem_wb_mem_pos <= mem_addr[1:0];
  mem_wb_rd_addr <= ex_mem_rd_addr;
  mem_wb_alu_out <= ex_mem_alu_out;
  mem_wb_ctrl_sig_mem_rw <= ex_mem_ctrl_sig_mem_rw;
  mem_wb_ctrl_sig_mem_type <= ex_mem_ctrl_sig_mem_type;
  mem_wb_ctrl_sig_wb_from   <= ex_mem_ctrl_sig_wb_from;
  mem_wb_ctrl_sig_reg_write <= ex_mem_ctrl_sig_reg_write; // will be used in register access operation
  end
end



// ---------- write back stage ----------
assign reg_write_addr = mem_wb_rd_addr;
assign reg_write_data = (mem_wb_ctrl_sig_wb_from === `FROM_ALU) ? mem_wb_alu_out :
                        (mem_wb_ctrl_sig_wb_from === `FROM_MEM) ? mem_data_out_ext :
                        (mem_wb_ctrl_sig_wb_from === `FROM_PC)  ? pc_plus_4 : {32{1'b0}};

always @(posedge CLK)
  finish_sim <= mem_wb_inst;

endmodule
