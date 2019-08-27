/*
Author: 张永康
Institution Affiliation: 武汉大学计算机学院
Description: ID级控制器
*/
`include "ctrl_encode_def.v"
`include "instruction_def.v"
`include "bus_def.v"

module Ctrl(        
        input [5:0]                OpCode,                                //输入: 指令的6位操作码
        input [5:0]                funct,                                //输入: 指令的6位功能码

        output reg jump,                                                //输出: 跳转使能信号
        output reg RegDst,                                    //输出: 写入寄存器选择(Rt或Rd)
        output reg Branch,                                        //输出: 分支使能信号
        output reg MemR,                                                //输出: 内存读信号,lw指令有效
        output reg Mem2R,                                                //输出: 选择将从内存读出的数据作为写回寄存器的数据,lw指令有效
        output reg MemW,                                                //输出: 内存写信号,sw指令有效
        output reg RegW,                                                //输出: 写回寄存器信号,所有需要向寄存器写回结果的指令均有效
        output reg [`AluSrc_Bus] AluSrc1,                                                //输出: ALU的第一个输入的选择信号
    output reg [`AluSrc_Bus] AluSrc2,                                                //输出: ALU的第二个输入的选择信号
        output reg[1:0]    ExtOp,                                                //输出: ID级的扩展器的控制信号
        output reg[4:0] Aluctrl                                                //输出: ALU的控制信号
);
    initial begin
        jump=0;
        RegDst=0;
        Branch=0;
        MemR=0;
        Mem2R=0;
        MemW=0;
        RegW=0;
        AluSrc1=0;
        AluSrc2=0;
        ExtOp=0;
        Aluctrl=0;
    end

    always @(OpCode or funct)
    begin
        case(OpCode)
            `INSTR_RTYPE_OP: //R Type Instruction
                begin
                    Branch=0;
                    jump=0;
                    Mem2R=0;
                    MemW=0;
                    MemR=0;
                    AluSrc2=`AluSrc2_Reg2;
                    ExtOp=`EXT_ZERO;
                    RegDst=0;
                    
                    case(funct)
                        `INSTR_ADD_FUNCT: //Add
                            begin
                                RegW=1;
                                AluSrc1=`AluSrc1_Reg1;
                                Aluctrl=`ALUOp_ADD;
                            end
                        `INSTR_ADDU_FUNCT: //Addu
                            begin
                                RegW=1;
                                AluSrc1=`AluSrc1_Reg1;
                                Aluctrl=`ALUOp_ADDU;
                            end
                            
                        `INSTR_SUB_FUNCT: //Sub
                            begin
                                RegW=1;
                                AluSrc1=`AluSrc1_Reg1;
                                Aluctrl=`ALUOp_SUB;
                            end
                            
                        `INSTR_SUBU_FUNCT: //Subu
                            begin
                                RegW=1;
                                AluSrc1=`AluSrc1_Reg1;
                                Aluctrl=`ALUOp_SUBU;
                            end
                            
                        `INSTR_SLL_FUNCT: //SLL Instruction
                        begin
                                RegW=1;
                            AluSrc1=`AluSrc1_Shamt;
                            Aluctrl=`ALUOp_SLL;
                        end
                
                        `INSTR_SRL_FUNCT: //SRL Instruction
                        begin
                                RegW=1;
                            AluSrc1=`AluSrc1_Shamt;
                            Aluctrl=`ALUOp_SRL;
                        end
                        
                        `INSTR_SLT_FUNCT: //SLT Instruction
                        begin
                            RegW=1;
                            AluSrc1=`AluSrc1_Reg1;
                            Aluctrl=`ALUOp_SLT;
                        end
                        
                        `INSTR_AND_FUNCT: //AND Instruction
                        begin
                            RegW=1;
                            AluSrc1=`AluSrc1_Reg1;
                            Aluctrl=`ALUOp_AND;
                        end
                        
                        `INSTR_OR_FUNCT: //OR Instruction
                        begin
                            RegW=1;
                            AluSrc1=`AluSrc1_Reg1;
                            Aluctrl=`ALUOp_OR;
                        end
                        
                        default:
                        begin
                            RegW=0;
                            AluSrc1=`AluSrc1_Reg1;
                            Aluctrl=0;
                        end
                    endcase
                end
            
            
            `INSTR_ORI_OP: //Ori
                begin
                    Branch=0;
                    jump=0;
                    Mem2R=0;
                    MemW=0;
                    MemR=0;
                    AluSrc1=`AluSrc1_Reg1;
                    AluSrc2=`AluSrc2_16BitInstant;
                    ExtOp=`EXT_SIGNED;
                    RegDst=1;
                    RegW=1;
                    Aluctrl=`ALUOp_OR;
                end
                
            `INSTR_LW_OP: //LW Instruction
                begin
                    Branch=0;
                    jump=0;
                    Mem2R=1;
                    MemW=0;
                    MemR=1;
                    AluSrc1=`AluSrc1_Reg1;
                    AluSrc2=`AluSrc2_16BitInstant;
                    ExtOp=`EXT_SIGNED;
                    RegDst=1;
                    RegW=1;
                    Aluctrl=`ALUOp_ADD;
                end
                
            `INSTR_SW_OP: //SW Instruction
                begin
                    Branch=0;
                    jump=0;
                    Mem2R=0;
                    MemW=1;
                    MemR=0;
                    AluSrc1=`AluSrc1_Reg1;
                    AluSrc2=`AluSrc2_16BitInstant;
                    ExtOp=`EXT_SIGNED;
                    RegDst=0;
                    RegW=0;
                    Aluctrl=`ALUOp_ADD;
                end
            
            `INSTR_BEQ_OP: //BEQ Instruction
                begin
                    Branch=1;
                    jump=0;
                    Mem2R=0;
                    MemW=0;
                    MemR=0;
                    AluSrc1=`AluSrc1_Reg1;
                    AluSrc2=`AluSrc2_Reg2;
                    ExtOp=`EXT_SIGNED;
                    RegDst=0;
                    RegW=0;
                    Aluctrl=`ALUOp_EQL;
                end
            
                
            `INSTR_LUI_OP: //LUI Instruction
                begin
                    Branch=0;
                    jump=0;
                    Mem2R=0;
                    MemW=0;
                    MemR=0;
                    AluSrc1=`AluSrc1_Reg1;
                    AluSrc2=`AluSrc2_16BitInstant;
                    ExtOp=`EXT_HIGHPOS;
                    RegDst=1;
                    RegW=1;
                    Aluctrl=`ALUOp_LUI;
                end
                
                
                
                `INSTR_BNE_OP: //BNE Instruction
                begin
                    Branch=1;
                    jump=0;
                    Mem2R=0;
                    MemW=0;
                    MemR=0;
                    AluSrc1=`AluSrc1_Reg1;
                    AluSrc2=`AluSrc2_Reg2;
                    ExtOp=`EXT_SIGNED;
                    RegDst=0;
                    RegW=0;
                    Aluctrl=`ALUOp_BNE;
                end
                
                `INSTR_J_OP: //Jump Instruction
                begin
                    Branch=0;
                    jump=1;
                    Mem2R=0;
                    MemW=0;
                    MemR=0;
                    AluSrc1=`AluSrc1_Reg1;
                    AluSrc2=`AluSrc2_Reg2;
                    ExtOp=`EXT_ZERO;
                    RegDst=0;
                    RegW=0;
                    Aluctrl=`ALUOp_BNE;
                end
                
                `INSTR_SLTI_OP: //SLTI Instruction
                begin
                    Branch=0;
                    jump=0;
                    Mem2R=0;
                    MemW=0;
                    MemR=0;
                    AluSrc1=`AluSrc1_Reg1;
                    AluSrc2=`AluSrc2_16BitInstant;
                    ExtOp=`EXT_SIGNED;
                    RegDst=1;
                    RegW=1;
                    Aluctrl=`ALUOp_SLT;
                end
                
                `INSTR_ADDI_OP: //ADDI Instruction
                begin
                    Branch=0;
                    jump=0;
                    Mem2R=0;
                    MemW=0;
                    MemR=0;
                    AluSrc1=`AluSrc1_Reg1;
                    AluSrc2=`AluSrc2_16BitInstant;
                    ExtOp=`EXT_SIGNED;
                    RegDst=1;
                    RegW=1;
                    Aluctrl=`ALUOp_ADD;
                end
                
            default:
            begin
                    Branch=0;
                    jump=0;
                    Mem2R=0;
                    MemW=0;
                    MemR=0;
                    AluSrc1=`AluSrc1_Reg1;
                    AluSrc2=`AluSrc2_Reg2;
                    ExtOp=`EXT_ZERO;
                    RegDst=0;
                    RegW=0;
                    Aluctrl=0;
            end
        endcase
    end
endmodule