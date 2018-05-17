`timescale 1ns/10ps

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
	wire            D_MEM_BE;
	wire    [31:0]  D_MEM_DOUT;
	wire    [11:0]  D_MEM_DOUT;
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
	RISCV_TOP riscv_top1 (
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
		.RF_WD        (RF_WD)
		//Control Singals
		//.DE_OP_EN     (DE_OP_EN) //Delayed branch mode
	);

	//I-Memory
	SP_SRAM #(
		.ROMDATA ("./test1.bin"), //Initialize I-Memory
		.AWIDTH  (10),
		.SIZE    (1024)
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
		.BE     (D_MEM_BE)
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


endmodule
