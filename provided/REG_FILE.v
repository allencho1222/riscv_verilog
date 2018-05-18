module REG_FILE #(
    parameter DWIDTH = 32,
    parameter MDEPTH = 32,
    parameter AWIDTH = 5 
)  (
    input wire CLK,
    input wire WE,
	input wire RST,
    input wire [AWIDTH-1:0] RA1, RA2, WA,
    input wire [DWIDTH-1:0] WD,
    output wire [DWIDTH-1:0] RD1, RD2
);

    //Declare the register that will store the data
    reg [DWIDTH -1:0] RF [MDEPTH-1:0];

    //Define asynchronous read
    assign RD1 = RF[RA1];
    assign RD2 = RF[RA2];

    initial
    begin
	    RF[0] = {32{1'b0}};;
    end

    //Define synchronous write
    always @(posedge CLK)
	begin
        if(WE && (WA != {AWIDTH{1'b0}}))
		begin
            RF[WA] <= WD;
    	end

		else if (RST)
    	begin
     	 RF[0] <= 32'b0;
     	 RF[2] <= 32'hF00;
     	 RF[3] <= 32'h100;
    	end

		else
		begin
            RF[WA] <= RF [WA];
        end
    end



endmodule
