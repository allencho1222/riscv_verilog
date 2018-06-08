`timescale 1ns/10ps
`include "RISCV_CLKRST.v"
`include "REG_FILE.v"
`include "Mem_Model.v"
`include "../core/riscv_core.v"

module TB_RISCV ( );
	//General Signals
	wire            CLK;
	wire            RSTn;
	//Memory Signals
	wire            I_MEM_CSN;
	wire    [31:0]  I_MEM_DOUT;
	wire    [31:0]  I_MEM_ADDR;
	wire            D_MEM_CSN;
	wire            D_MEM_WEN;
	wire    [4:0]   D_MEM_BE; // I use 5-bits for this signal
	wire    [31:0]  D_MEM_DOUT;
	wire    [31:0]  D_MEM_ADDR;
	wire    [31:0]  D_MEM_DI;
	wire            RF_WE;
	wire    [4:0]   RF_RA1;
	wire    [4:0]   RF_RA2;
	wire    [4:0]   RF_WA;
	wire    [31:0]  RF_RD1;
	wire    [31:0]  RF_RD2;
	wire    [31:0]  RF_WD; 
	//Clock Reset Generator
	RISCV_CLKRST riscv_clkrst1 (
		.CLK           (CLK),
		.RSTn          (RSTn)
	);

	//CPU Core top
	RISCV_TOP core (
		//General Signals
		.CLK          (CLK),
		.RSTn         (RSTn),
		//I-Memory Signals
		.I_MEM_CSN    (I_MEM_CSN),
		.I_MEM_DI     (I_MEM_DOUT),
		.I_MEM_ADDR   (I_MEM_ADDR),
		//D-Memory Signals
		.D_MEM_CSN    (D_MEM_CSN),
		.D_MEM_DI     (D_MEM_DOUT),
		.D_MEM_DOUT   (D_MEM_DI),
		.D_MEM_ADDR   (D_MEM_ADDR),
		.D_MEM_WEN    (D_MEM_WEN),
		.D_MEM_BE     (D_MEM_BE),
		//RegFile Signals
		.RF_WE        (RF_WE),
		.RF_RA1       (RF_RA1),
		.RF_RA2       (RF_RA2),
		.RF_WA        (RF_WA),
		.RF_RD1       (RF_RD1),
		.RF_RD2       (RF_RD2),
		.RF_WD        (RF_WD),
		//Control Singals
		.DE_OP_EN     (1'b0) //Delayed branch mode
	);

	//I-Memory
	SP_SRAM #(
		.ROMDATA ("./test1.bin"), //Initialize I-Memory
		.AWIDTH  (10),
		.SIZE    (1024)	// it was .SIZE (1024)
	) i_mem1 (
		.CLK    (CLK),
		.CSN    (I_MEM_CSN),
		.DOUT   (I_MEM_DOUT),
		.ADDR   (I_MEM_ADDR[11:2]),
		.WEN    (1'b1),
		.BE     (4'b0000)
	);

	//D-Memory
	SP_SRAM #(
		.AWIDTH  (12),
		.SIZE    (4096)
	) d_mem1 (
		.CLK    (CLK),
		.CSN    (D_MEM_CSN),
		.DI     (D_MEM_DI),
		.DOUT   (D_MEM_DOUT),
		.ADDR   (D_MEM_ADDR[11:0]),
		.WEN    (D_MEM_WEN),
		.BE     (D_MEM_BE[3:0])   // truncate bits into [3:0] since [4] does not need anymore in this module
	);

	//Reg File
	REG_FILE #(
		.DWIDTH (32),
		.MDEPTH (32),
		.AWIDTH (5)
	) reg_file1 (
		.CLK    (CLK),
		.WE     (RF_WE),
		.RA1    (RF_RA1),
		.RA2    (RF_RA2),
		.WA     (RF_WA),
		.RD1    (RF_RD1),
		.RD2    (RF_RD2),
		.WD     (RF_WD)
	);

	//Simulation
	initial
	begin
		#(10*100000);
		$finish();
	end
	always @(posedge CLK)
	begin
		// print debugging information
		$display("current pc: %b\n", core.pc);
		$display("----- IF / ID pipeline registers -----\t\t",
			 "----- ID / EX pipeline registers -----\t\t\t",
			 "----- EX / MEM pipeline registers -----\t\t\t",
			 "----- MEM / WB pipeline registers -----\n");
		$display("if_id_inst: %b\tdo_branch: %b\n", core.if_id_inst, core.id_do_branch);
		$display("\t\t\t\t\t\tid_bypassed_rs1_data: %b", core.id_bypassed_rs1_data);
		$display("\t\t\t\t\t\tid_bypassed_rs2_data: %b", core.id_bypassed_rs2_data);
		$display("if_id_pc:   %b\tbranch_pc: %b\n", core.if_id_pc, core.id_branch_pc);
		$display("\t\t\t\t\t\tid_ex_pc:  %b\n", core.id_ex_pc);
		$display("\t\t\t\t\t\tid_ex_rd_addr: %b\t\t\t\t\t", core.id_ex_rd_addr,
			 "ex_mem_rd_addr: %b\t\t\t\t\t", core.ex_mem_rd_addr,
			 "mem_wb_rd_addr: %b\n", core.mem_wb_rd_addr);
		$display("\t\t\t\t\t\tid_ex_rs1_addr: %b\n", core.id_ex_rs1_addr);
		$display("\t\t\t\t\t\tid_ex_rs2_addr: %b\t\t\t\t\t", core.id_ex_rs2_addr,
			 "ex_mem_rs2_addr: %b\n", core.ex_mem_rs2_addr);
		$display("\t\t\t\t\t\tid_ex_rs1_data: %b\t", core.id_ex_rs1_data,
			 "ex_mem_mem_data: %b\t", core.ex_mem_mem_data,
		 	 "mem_wb_mem_data_out: %b\n", core.mem_wb_mem_data_out);
		$display("\t\t\t\t\t\tid_ex_rs2_data: %b\t", core.id_ex_rs2_data,
			 "ex_mem_alu_out: %b\t", core.ex_mem_alu_out,
		 	 "mem_wb_alu_out: %b\n", core.mem_wb_alu_out);
		$display("\t\t\t\t\t\tid_ex_imm_data: %b\n", core.id_ex_imm_data);
		$display("\t\t\t\t\t\tid_ex_ctrl_sig_imm_type: %b\n", core.id_ex_ctrl_sig_imm_type);
		$display("\t\t\t\t\t\tid_ex_ctrl_sig_alu_fn: %b\n", core.id_ex_ctrl_sig_alu_fn);
		$display("\t\t\t\t\t\tid_ex_ctrl_sig_alu_src2: %b\n", core.id_ex_ctrl_sig_alu_src2);
		$display("\t\t\t\t\t\tid_ex_ctrl_sig_alu_src1: %b\n", core.id_ex_ctrl_sig_alu_src1);
		$display("\t\t\t\t\t\tid_ex_ctrl_sig_mem_type: %b\t\t\t\t", core.id_ex_ctrl_sig_mem_type,
			 "ex_mem_ctrl_sig_mem_type: %b\n", core.ex_mem_ctrl_sig_mem_type);
		$display("\t\t\t\t\t\tid_ex_ctrl_sig_mem_rw: %b\t\t\t\t", core.id_ex_ctrl_sig_mem_rw,
			 "ex_mem_ctrl_sig_mem_rw: %b\n", core.ex_mem_ctrl_sig_mem_rw);
		$display("\t\t\t\t\t\tid_ex_ctrl_sig_wb_from: %b\t\t\t\t", core.id_ex_ctrl_sig_wb_from,
			 "ex_mem_ctrl_sig_wb_from: %b\t\t\t\t", core.ex_mem_ctrl_sig_wb_from,
			 "mem_wb_ctrl_sig_wb_from: %b\n", core.mem_wb_ctrl_sig_wb_from);
		$display("\t\t\t\t\t\tid_ex_ctrl_sig_reg_write: %b\t\t\t\t", core.id_ex_ctrl_sig_reg_write,
			 "ex_mem_ctrl_sig_reg_write: %b\t\t\t\t", core.ex_mem_ctrl_sig_reg_write,
		 	 "mem_wb_ctrl_sig_reg_write: %b\n", core.mem_wb_ctrl_sig_reg_write);

	end


endmodule
