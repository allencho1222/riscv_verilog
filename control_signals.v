// memory operation type
`define     MT_X      3b'000    // no memory operation is required
`define     MT_B      3b'001
`define     MT_H      3b'010
`define     MT_W      3b'011
`define     MT_BU     3b'100
`define     MT_HU     3b'101

// ALU control signals
`define     ALU_X     4b'0000   // no ALU operation is required
`define     ALU_ADD   4b'0001
`define     ALU_SUB   4b'0010
`define     ALU_SLT   4b'0011
`define     ALU_SLTU  4b'0100
`define     ALU_SGE   4b'0101
`define     ALU_SGEU  4b'0110
`define     ALU_AND   4b'0110
`define     ALU_OR    4b'0110
`define     ALU_XOR   4b'0111
`define     ALU_SEQ   4b'1000
`define     ALU_SNE   4b'1001
`define     ALU_SL    4b'1010
`define     ALU_SR    4b'1011
`define     ALU_SRA   4b'1100

// immediate type signals
`define     IMM_X     3b'000    // no immeidate operation is required(R type)
`define     IMM_I     3b'001 
`define     IMM_S     3b'010
`define     IMM_SB    3b'011
`define     IMM_U     3b'100
`define     IMM_UJ    3b'101

// ALU source2 signals   
`define     ALU2_X    3b'000    // no source is required
`define     ALU2_RS2  3b'001     
`define     ALU2_IMM  3b'010     
`define     ALU2_RS2  3b'011     
`define     ALU2_ZERO 3b'100     

// ALU source1 signals
`define     ALU1_X    3b'000    // no source is required
`define     ALU1_RS1  3b'001
`define     ALU1_PC   3b'010
`define     ALU1_ZERO 3b'011

