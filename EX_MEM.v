/*
Author: 张永康
Institution Affiliation: 武汉大学计算机学院
Description: EX/MEM寄存器
*/

`include "bus_def.v"

module EX_MEM(
    input clk,
    input rst,

    //Information came from EX stage
    //1. Reg in WB
    input [`Reg_Addr_Bus] EX_Reg_WriteAddr, //EX级指令要写入的寄存器的地址
    input EX_Reg_WriteEn, //=1 表示EX级指令要写寄存器
    input [`Word_Bus] EX_AluResult, //EX级指令ALU的结果
    input EX_Mem2R, //=1表示EX级指令选择将存储器读出的数据送入寄存器
    //2. DMem in MEM
    input [`DMem_Addr_Bus] EX_DMem_WriteAddr, //EX级指令要写入的存储器单元的地址
    input EX_DMem_WriteEn, //EX级指令存储器写入使能信号
    input EX_DMem_ReadEn, //EX级指令存储器读出使能信号
    input [`Word_Bus] EX_DMem_WriteData, //EX级指令要写入存储器的数据
    //3. 为支持旁路加入的部分信息
	//input [`Reg_Addr_Bus] EX_Rs_num,
	//input [`Reg_Addr_Bus] EX_Rt_num,

    //Information that sends into MEM stage
    //1. Reg in WB
    output reg [`Reg_Addr_Bus] MEM_Reg_WriteAddr, //MEM级指令要写入寄存器的地址
    output reg MEM_Reg_WriteEn, //=1 表示MEM级指令要写寄存器
    output reg [`Word_Bus] MEM_AluResult, //MEM级指令ALU结果
    output reg MEM_Mem2R, //=1 表示MEM级指令选择将存储器读出的数据送入寄存器
    
    //2. DMem in MEM
    output reg [`DMem_Addr_Bus] MEM_DMem_WriteAddr, //MEM级指令写入存储器单元的地址
    output reg MEM_DMem_WriteEn, //MEM级指令存储器写入使能信号
    output reg MEM_DMem_ReadEn, //MEM级指令存储器读出使能信号
    output reg [`Word_Bus] MEM_DMem_WriteData //MEM级指令要写入存储器的数据
);
    initial begin
        MEM_Reg_WriteAddr<=`NOPRegAddr;
        MEM_Reg_WriteEn<=0;
        MEM_AluResult<=0; //The data that needs to be written into a register
        MEM_Mem2R<=0;
    
        MEM_DMem_WriteAddr<=`NOPDMemAddr;
        MEM_DMem_WriteEn<=0;
        MEM_DMem_ReadEn<=0;
        MEM_DMem_WriteData<=`ZeroWord;

        //MEM_Rs_num<=0;
        //MEM_Rt_num<=0;
    end
    always@(posedge clk) begin
        if(rst==1) begin
            MEM_Reg_WriteAddr<=`NOPRegAddr;
            MEM_Reg_WriteEn<=0;
            MEM_AluResult<=0; //The data that needs to be written into a register
            MEM_Mem2R<=0;
    
            MEM_DMem_WriteAddr<=`NOPDMemAddr;
            MEM_DMem_WriteEn<=0;
            MEM_DMem_ReadEn<=0;
            MEM_DMem_WriteData<=`ZeroWord;
        
            //MEM_Rs_num<=0;
            //MEM_Rt_num<=0;
        end
        else begin
            MEM_Reg_WriteAddr<=EX_Reg_WriteAddr;
            MEM_Reg_WriteEn<=EX_Reg_WriteEn;
            MEM_AluResult<=EX_AluResult; //The data that needs to be written into a register
            MEM_Mem2R<=EX_Mem2R;

            MEM_DMem_WriteAddr<=EX_DMem_WriteAddr;
            MEM_DMem_WriteEn<=EX_DMem_WriteEn;
            MEM_DMem_ReadEn<=EX_DMem_ReadEn;
            MEM_DMem_WriteData<=EX_DMem_WriteData;
            
            //MEM_Rs_num<=EX_Rs_num;
            //MEM_Rt_num<=EX_Rt_num;
        end
    end
endmodule