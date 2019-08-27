`define Word_Bus 31:0 //The bus size of a word(32 bits)
`define Reg_Addr_Bus 4:0 //The bus size of register file
`define DMem_Addr_Bus 4:0 //The bus size of Data Memory
`define IMem_Addr_Bus 9:0 //The bus size of Instruction Memory

`define NOPRegAddr 5'b00000
`define NOPDMemAddr 5'b00000
`define ZeroWord 32'h00000000

`define AluSrc_Bus 2:0 //The bus size of the ALUScr control signal