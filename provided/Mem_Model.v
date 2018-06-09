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
    $display ("im[0]: %b", ram[0]);
    $display ("im[1]: %b", ram[1]);
    $display ("im[2]: %b", ram[2]);
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
