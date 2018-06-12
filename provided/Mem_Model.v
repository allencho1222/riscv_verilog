module SP_SRAM #(parameter ROMDATA = "", AWIDTH = 12, SIZE = 4096) (
	input	wire						CLK, 
	input	wire						CSN, 
	input	wire	[AWIDTH-1:0]		ADDR, 
	input	wire						WEN, 
	input	wire	[3:0]				BE,
	input	wire	[31:0]				DI, 
	output	wire	[31:0]				DOUT
);
	
	reg		[31:0]	outline;
	reg		[31:0]	ram[0 : SIZE-1];
	reg		[31:0]	temp;

	initial	
	begin
		if (ROMDATA != "")
			$readmemh(ROMDATA, ram);
	end
	
	assign #1 DOUT = outline;

	always @ (posedge CLK)
	begin
		if (~CSN)
		begin
			if (WEN)	
				outline = ram[ADDR];
			else 
			begin
				temp = ram[ADDR];
				if (BE[0]) temp[7:0] = DI[7:0];
				if (BE[1]) temp[15:8] = DI[15:8];
				if (BE[2]) temp[23:16] = DI[23:16];
				if (BE[3]) temp[31:24] = DI[31:24];

				ram[ADDR] = temp;
			end
		end
	end

endmodule

module SP_SRAM_LATENCY #(parameter ROMDATA = "", AWIDTH = 12, SIZE = 4096) (
	input	wire						CLK, 
	input	wire						CSN, 
	input	wire	[AWIDTH-1:0]		ADDR, 
	input	wire						WEN, 
	input	wire	[3:0]				BE,
	input	wire	[31:0]				DI, 
	output	wire	[31:0]				DOUT,
	output wire 	READY,
	input wire [2:0] LATENCY
);
	
	reg		[31:0]	outline;
	reg		[31:0]	ram[0 : SIZE-1];
	reg		[31:0]	temp;

	reg ready_sig;
	reg [2:0] count;

	initial	
	begin
		count <= 0;
		if (ROMDATA != "")
			$readmemh(ROMDATA, ram);
	end
	
	assign #1 DOUT = outline;
	assign READY = (ready_sig == 1'b1) && (count == LATENCY-1);

	always @ (*)
	begin
		if (~CSN)
			ready_sig = 1;
		else
			ready_sig = 0;
	end

	always @ (posedge CLK)
	begin
		if (count == LATENCY-1 || CSN == 1'b1)
			count <= 0;
		else if (~CSN)
			count <= count + 1;
	end

	always @ (posedge CLK)
	begin
		if (~CSN)
		begin
			if (WEN)	
				outline = ram[ADDR];
			else 
			begin
				temp = ram[ADDR];
				if (BE[0]) temp[7:0] = DI[7:0];
				if (BE[1]) temp[15:8] = DI[15:8];
				if (BE[2]) temp[23:16] = DI[23:16];
				if (BE[3]) temp[31:24] = DI[31:24];

				ram[ADDR] = temp;
			end
		end
	end

endmodule
