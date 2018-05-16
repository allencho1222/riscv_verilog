// memory operation type
// fifth bit indicates whether it is U or not
`define     MT_X      3'b00000  // no memory operation is required
`define     MT_B      3'b00001
`define     MT_H      3'b00011
`define     MT_W      3'b01111
`define     MT_BU     3'b10001
`define     MT_HU     3'b10011

// memory write signal
`define     M_X       2'b00
`define     M_W       2'b01
`define     M_R       2'b10

// register write signal
`define     REG_X     1'b0
`define     REG_W     1'b1

// branch instruction type
`define     BR_X      4'b0000
`define     BR_J      4'b0001
`define     BR_JR     4'b0010
`define     BR_EQ     4'b0011
`define     BR_NE     4'b0100
`define     BR_LT     4'b0101
`define     BR_GE     4'b0110
`define     BR_LTU    4'b0111
`define     BR_GEU    4'b1000

// write back from signals
`define     FROM_X    2'b00     // no write back occurs
`define     FROM_ALU  2'b01
`define     FROM_MEM  2'b10
`define	    FROM_PC   2'b11

// ALU control signals
`define     ALU_X     4'b0000   // no ALU operation is required
`define     ALU_ADD   4'b0001
`define     ALU_SUB   4'b0010
`define     ALU_SLT   4'b0011
`define     ALU_SLTU  4'b0100
`define     ALU_AND   4'b0101
`define     ALU_OR    4'b0110
`define     ALU_XOR   4'b0111
`define     ALU_SL    4'b1000
`define     ALU_SR    4'b1001
`define     ALU_SRA   4'b1010

// immediate type signals
`define     IMM_X     3'b000    // no immeidate operation is required(R type)
`define     IMM_I     3'b001 
`define     IMM_S     3'b010
`define     IMM_SB    3'b011
`define     IMM_U     3'b100
`define     IMM_UJ    3'b101

// ALU source2 signals   
`define     ALU2_X    3'b00     // no source is required
`define     ALU2_RS2  3'b01     
`define     ALU2_IMM  3'b10     

// ALU source1 signals
`define     ALU1_X    3'b00     // no source is required
`define     ALU1_RS1  3'b01
`define     ALU1_PC   3'b10
`define     ALU1_ZERO 3'b11

