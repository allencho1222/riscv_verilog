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
	wire 						D_READY; // data ready sig , 1 : ready, 0 : wait
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
		.D_READY 	  (D_READY), // data memory latency mode
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
		.ROMDATA ("/Users/sungjun/riscv_verilog/testset/test6.txt"), //Initialize I-Memory
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
	SP_SRAM_LATENCY #(
		.AWIDTH  (12),
		.SIZE    (4096)
	) d_mem1 (
		.CLK    (CLK),
		.CSN    (D_MEM_CSN),
		.DI     (D_MEM_DI),
		.DOUT   (D_MEM_DOUT),
		.ADDR   (D_MEM_ADDR[13:2]),
		.WEN    (D_MEM_WEN),
		.BE     (D_MEM_BE[3:0]),   // truncate bits into [3:0] since [4] does not need anymore in this module
		.READY  (D_READY),
		.LATENCY (3'd1)				// Latency == 1 -> default latency.
	);

	//Reg File
	REG_FILE #(
		.DWIDTH (32),
		.MDEPTH (32),
		.AWIDTH (5)) reg_file1 (
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
/*
		// print debugging information
		$display("current pc: %b\n", core.pc);
		$display("----- IF / ID pipeline registers -----\t\t\t\t",
			 "----- ID / EX pipeline registers -----\t\t\t\t",
			 "----- EX / MEM pipeline registers -----\t\t\t\t",
			 "----- MEM / WB pipeline registers -----\n");
		$display("if_id_inst: %h\t\t\t\t\t\t\t\tdo_branch: %b\n", core.I_MEM_DI, core.id_do_branch);
		$display("\t\t\t\t\t\t\t\t\tid_bypassed_rs1_data: %b", core.id_bypassed_rs1_data);
		$display("\t\t\t\t\t\t\t\t\tid_bypassed_rs2_data: %b", core.id_bypassed_rs2_data);
		$display("if_id_pc:   %b\t\tbranch_pc: %b\n", core.if_id_pc, core.id_branch_pc);
		$display("\t\t\t\t\t\t\t\t\t\tid_ex_pc:  %b\n", core.id_ex_pc);
		$display("\t\t\t\t\t\t\t\t\t\tid_ex_rd_addr: %b\t\t\t\t\t", core.id_ex_rd_addr,
			 "ex_mem_rd_addr: %b\t\t\t\t\t", core.ex_mem_rd_addr,
			 "mem_wb_rd_addr: %b\n", core.mem_wb_rd_addr);
		$display("\t\t\t\t\t\tid_ex_rs1_addr: %b\n", core.id_ex_rs1_addr);
		$display("\t\t\t\t\t\tid_ex_rs2_addr: %b\t\t\t\t\t", core.id_ex_rs2_addr,
			 "ex_mem_rs2_addr: %b\n", core.ex_mem_rs2_addr);
		$display(
			 "ex_mem_mem_data: %b\t", core.ex_mem_mem_data,
		 	 "mem_wb_mem_data_out: %b\n", core.mem_wb_mem_data_out);
		$display(
			 "ex_mem_alu_out: %b\t", core.ex_mem_alu_out,
		 	 "mem_wb_alu_out: %b\n", core.mem_wb_alu_out);
		$display("\t\t\t\t\t\tid_ex_imm_data: %b\n", core.id_ex_imm_data);
    $display("\t\t\t\t\t\tex_alu_oper2: %b\n", core.ex_alu_oper2);
    $display("\t\t\t\t\t\tex_alu_oper1: %b\n", core.ex_alu_oper1);
    $display("\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\tex_bypassed_rs1_data: %b\n", core.ex_bypassed_rs1_data);
    $display("\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\tex_bypassed_rs2_data: %b\n", core.ex_bypassed_rs2_data);
	$display("\t\t\t\t\t\t\treg_write_data: %b", core.reg_write_data);
	$display("\t\t\t\t\t\t\tid_from_mem_wb_rs2: %b", core.id_from_mem_wb_rs2);
	$display("\t\t\t\t\t\t\tid_from_mem_wb_rs1: %b", core.id_from_mem_wb_rs1);
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
	$display("ex_from_exe_mem_rs2: %b", core.ex_from_exe_mem_rs2);
	$display("ex_from_exe_mem_rs1: %b", core.ex_from_exe_mem_rs1);
	$display("ex_from_mem_wb_rs2: %b", core.ex_from_mem_wb_rs2);
	$display("ex_from_mem_wb_rs1: %b", core.ex_from_mem_wb_rs1);
	$display("memory data in: %b ", core.D_MEM_DOUT, "memory data in addr: %b ", core.D_MEM_ADDR, "memory data write: %b ", core.D_MEM_WEN, "memory data ignore: %b", core.D_MEM_CSN);
	$display("mem_is_load_store: %b\n", core.mem_is_load_store);
	$display("mem_data_out_ext: %b\n", core.mem_data_out_ext);
	$display("data read: %b\n", d_mem1.outline);
	$display("stack: %b\n", d_mem1.ram[4096'hF00]);
	$display("mem_stall: %b\n", core.mem_stall);
	$display("d_mem1.count: %b\n", d_mem1.count);
	$display("mem_ready: %b\n", d_mem1.READY);
	$display("load_use_stall: %b\n", core.load_use_stall);
	$display("load_br_stall: %b\n", core.load_br_stall);
	$display("load_br_stall2: %b\n", core.load_br_stall2);

    $display("\n\nx0: %h\t\t\t\t", reg_file1.RF[0], "x1: %h\t\t\t\t", reg_file1.RF[1], "x2: %h\t\t\t\t", reg_file1.RF[2],
             "x3: %h\t\t\t\t", reg_file1.RF[3], "x4: %h\t\t\t\t", reg_file1.RF[4], "x5: %h\t\t\t\t", reg_file1.RF[5],
             "x6: %h\t\t\t\t", reg_file1.RF[6], "x7: %h\t\t\t\t", reg_file1.RF[7], "x8: %h\t\t\t\t", reg_file1.RF[8]);
    $display("x9: %h\t\t\t\t", reg_file1.RF[9], "x10: %h\t\t\t\t", reg_file1.RF[10], "x11: %h\t\t\t\t", reg_file1.RF[11],
             "x12: %h\t\t\t\t", reg_file1.RF[12], "x13: %h\t\t\t\t", reg_file1.RF[13], "x14: %h\t\t\t\t", reg_file1.RF[14],
             "x15: %h\t\t\t\t", reg_file1.RF[15], "x16: %h\t\t\t\t", reg_file1.RF[16], "x17: %h\t\t\t\t", reg_file1.RF[17],
             "x18: %h\t\t\t\t", reg_file1.RF[18], "x19: %h\t\t\t\t", reg_file1.RF[19], "x20: %h\t\t\t\t", reg_file1.RF[20]);
    $display("x21: %h\t\t\t\t", reg_file1.RF[21], "x22: %h\t\t\t\t", reg_file1.RF[22], "x23: %h\t\t\t\t", reg_file1.RF[23],
             "x24: %h\t\t\t\t", reg_file1.RF[24], "x25: %h\t\t\t\t", reg_file1.RF[25], "x26: %h\t\t\t\t", reg_file1.RF[26],
             "x27: %h\t\t\t\t", reg_file1.RF[27], "x28: %h\t\t\t\t", reg_file1.RF[28], "x29: %h\t\t\t\t", reg_file1.RF[29],
             "x30: %h\t\t\t\t", reg_file1.RF[30], "x31: %h\t\t\t\t", reg_file1.RF[31], "\n\n");
*/
	end
endmodule
