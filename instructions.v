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

// no operation
`define     BUBBLE  32'b00000000000000000000000000000000000

// load instructions    --- I-type
`define     LB      32'bxxxxxxxxxxx_xxxxx_000_xxxxx_0000011
`define     LH      32'bxxxxxxxxxxx_xxxxx_001_xxxxx_0000011
`define     LW      32'bxxxxxxxxxxx_xxxxx_010_xxxxx_0000011
`define     LBU     32'bxxxxxxxxxxx_xxxxx_100_xxxxx_0000011
`define     LHU     32'bxxxxxxxxxxx_xxxxx_101_xxxxx_0000011

// store instructions   --- S-type
`define     SB      32'bxxxxxxx_xxxxx_xxxxx_000_xxxxx_0100011
`define     SH      32'bxxxxxxx_xxxxx_xxxxx_001_xxxxx_0100011
`define     SW      32'bxxxxxxx_xxxxx_xxxxx_010_xxxxx_0100011

// shift instructions
// SLL, SRL, SRA     --- R-type
// SLLI, SRLI, SRAI  --- I-type
`define     SLL     32'b0000000_xxxxx_xxxxx_001_xxxxx_0110011
`define     SLLI    32'b0000000_xxxxx_xxxxx_001_xxxxx_0010011
`define     SRL     32'b0000000_xxxxx_xxxxx_101_xxxxx_0110011
`define     SRLI    32'b0000000_xxxxx_xxxxx_101_xxxxx_0010011
`define     SRA     32'b0100000_xxxxx_xxxxx_101_xxxxx_0110011
`define     SRAI    32'b0100000_xxxxx_xxxxx_101_xxxxx_0010011

// arithmetic instructions
// ADD, SUB          --- R-type
// ADDI              --- I-type
// LUI, AUPIC        --- U-type
`define     ADD     32'b0000000_xxxxx_xxxxx_000_xxxxx_0110011
`define     ADDI    32'bxxxxxxxxxxxx_xxxxx_000_xxxxx_0010011
`define     SUB     32'b0100000_xxxxx_xxxxx_000_xxxxx_0110011
`define     LUI     32'bxxxxxxxxxxxxxxxxxxxx_xxxxx_0110111
`define     AUIPC   32'bxxxxxxxxxxxxxxxxxxxx_xxxxx_0010111

// logical instructions
// XOR, OR, AND      --- R-type
// XORI, ORI, ANDI   --- I-type
`define     XOR     32'b0000000_xxxxx_xxxxx_100_xxxxx_0110011
`define     XORI    32'bxxxxxxxxxxxx_xxxxx_100_xxxxx_0010011
`define     OR      32'b0000000_xxxxx_xxxxx_110_xxxxx_0110011
`define     ORI     32'bxxxxxxxxxxxx_xxxxx_110_xxxxx_0010011
`define     AND     32'b0000000_xxxxx_xxxxx_111_xxxxx_0110011
`define     ANDI    32'bxxxxxxxxxxxx_xxxxx_111_xxxxx_0010011

// compare instructions
// SLT, SLTU         --- R-type
// SLTI, SLTIU       --- I-type
`define     SLT     32'b0000000_xxxxx_xxxxx_010_xxxxx_0110011
`define     SLTI    32'bxxxxxxxxxxxx_xxxxx_010_xxxxx_0010011
`define     SLTU    32'b0000000_xxxxx_xxxxx_011_xxxxx_0110011
`define     SLTIU   32'bxxxxxxxxxxxx_xxxxx_011_xxxxx_0010011

// branch instructions   --- SB-type
`define     BEQ     32'bx_xxxxxx_xxxxx_xxxxx_000_xxxx_x_1100011
`define     BNE     32'bx_xxxxxx_xxxxx_xxxxx_001_xxxx_x_1100011
`define     BLT     32'bx_xxxxxx_xxxxx_xxxxx_100_xxxx_x_1100011
`define     BGE     32'bx_xxxxxx_xxxxx_xxxxx_101_xxxx_x_1100011
`define     BLTU    32'bx_xxxxxx_xxxxx_xxxxx_110_xxxx_x_1100011
`define     BGEU    32'bx_xxxxxx_xxxxx_xxxxx_111_xxxx_x_1100011

// jump and link instructions
// JAL               --- UJ-type
// JALR              --- I-type
`define     JAL     32'bx_xxxxxxxxxx_x_xxxxxxxx_xxxxx_1101111
`define     JALR    32'bxxxxxxxxxxxx_xxxxx_000_xxxxx_1100111
