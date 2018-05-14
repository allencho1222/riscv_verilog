// R type
// 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0
//               funct7            rs2            rs1   funct3             rd               opcode
               
// I type
// 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0
//                           imm[11:0]            rs1   funct3             rd               opcode

// S type
// 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0
//            imm[11:5]            rs2            rs1   funct3       imm[4:0]               opcode
            
// SB type
// 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0
//        imm[12][10:5]            rs2            rs1   funct3   imm[4:1][11]               opcode

// U type
// 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0
//                                                  imm[31:12]             rd               opcode 

// UJ type
// 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0
//                                    imm[20][10:1][11][19:12]             rd               opcode


// load instructions    --- I-type
`define     LB      32b'xxxxxxxxxxx_xxxxx_000_xxxxx_0000011
`define     LH      32b'xxxxxxxxxxx_xxxxx_001_xxxxx_0000011
`define     LW      32b'xxxxxxxxxxx_xxxxx_010_xxxxx_0000011
`define     LBU     32b'xxxxxxxxxxx_xxxxx_100_xxxxx_0000011
`define     LHU     32b'xxxxxxxxxxx_xxxxx_101_xxxxx_0000011

// store instructions   --- S-type
`define     SB      32b'xxxxxxx_xxxxx_xxxxx_000_xxxxx_0100011
`define     SH      32b'xxxxxxx_xxxxx_xxxxx_001_xxxxx_0100011
`define     SW      32b'xxxxxxx_xxxxx_xxxxx_010_xxxxx_0100011

// shift instructions
// SLL, SRL, SRA     --- R-type
// SLLI, SRLI, SRAI  --- I-type
`define     SLL     32b'0000000_xxxxx_xxxxx_001_xxxxx_0110011
`define     SLLI    32b'0000000_xxxxx_xxxxx_001_xxxxx_0010011
`define     SRL     32b'0000000_xxxxx_xxxxx_101_xxxxx_0110011
`define     SRLI    32b'0000000_xxxxx_xxxxx_101_xxxxx_0010011
`define     SRA     32b'0100000_xxxxx_xxxxx_101_xxxxx_0110011
`define     SRAI    32b'0100000_xxxxx_xxxxx_101_xxxxx_0010011

// arithmetic instructions
// ADD, SUB          --- R-type
// ADDI              --- I-type
// LUI, AUPIC        --- U-type
`define     ADD     32b'0000000_xxxxx_xxxxx_000_xxxxx_0110011
`define     ADDI    32b'xxxxxxxxxxxx_xxxxx_000_xxxxx_0010011
`define     SUB     32b'0100000_xxxxx_xxxxx_000_xxxxx_0110011
`define     LUI     32b'xxxxxxxxxxxxxxxxxxxx_xxxxx_0110111
`define     AUIPC   32b'xxxxxxxxxxxxxxxxxxxx_xxxxx_0010111

// logical instructions
// XOR, OR, AND      --- R-type
// XORI, ORI, ANDI   --- I-type
`define     XOR     32b'0000000_xxxxx_xxxxx_100_xxxxx_0110011
`define     XORI    32b'xxxxxxxxxxxx_xxxxx_100_xxxxx_0010011
`define     OR      32b'0000000_xxxxx_xxxxx_110_xxxxx_0110011
`define     ORI     32b'xxxxxxxxxxxx_xxxxx_110_xxxxx_0010011
`define     AND     32b'0000000_xxxxx_xxxxx_111_xxxxx_0110011
`define     ANDI    32b'xxxxxxxxxxxx_xxxxx_111_xxxxx_0010011

// compare instructions
// SLT, SLTU         --- R-type
// SLTI, SLTIU       --- I-type
`define     SLT     32b'0000000_xxxxx_xxxxx_010_xxxxx_0110011
`define     SLTI    32b'xxxxxxxxxxxx_xxxxx_010_xxxxx_0010011
`define     SLTU    32b'0000000_xxxxx_xxxxx_011_xxxxx_0110011
`define     SLTIU   32b'xxxxxxxxxxxx_xxxxx_011_xxxxx_0010011

// branch instructions   --- SB-type
`define     BEQ     32b'x_xxxxxx_xxxxx_xxxxx_000_xxxx_x_1100011
`define     BNE     32b'x_xxxxxx_xxxxx_xxxxx_001_xxxx_x_1100011
`define     BLT     32b'x_xxxxxx_xxxxx_xxxxx_100_xxxx_x_1100011
`define     BGE     32b'x_xxxxxx_xxxxx_xxxxx_101_xxxx_x_1100011
`define     BLTU    32b'x_xxxxxx_xxxxx_xxxxx_110_xxxx_x_1100011
`define     BGEU    32b'x_xxxxxx_xxxxx_xxxxx_111_xxxx_x_1100011

// jump and link instructions
// JAL               --- UJ-type
// JALR              --- I-type
`define     JAL     32b'x_xxxxxxxxxx_x_xxxxxxxx_xxxxx_1101111
`define     JALR    32b'xxxxxxxxxxxx_xxxxx_000_xxxxx_1100111
