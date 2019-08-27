/*
Author: 张永康
Institution Affiliation: 武汉大学计算机学院
Description: MEM/WB寄存器
*/

`include "bus_def.v"

module MEM_WB(
    input clk,
    input rst,

    //Information came from MEM stage
    //1. Reg in WB
    input [`Reg_Addr_Bus] MEM_Reg_WriteAddr, //MEM级指令写回寄存器的地址
    input MEM_Reg_WriteEn, //MEM级指令写回寄存器使能信号
    //input [`Word_Bus] MEM_AluResult, //The data that needs to be written into a register
    input [`Word_Bus] MEM_Reg_WriteData, //MEM级指令写回寄存器的数据
    //input MEM_Mem2R,

    //Information that sends into WB stage
    //1. Reg in WB
    output reg [`Reg_Addr_Bus] WB_Reg_WriteAddr, //WB级指令写回寄存器的地址
    output reg WB_Reg_WriteEn, //WB级指令写回寄存器使能信号
    output reg [`Word_Bus] WB_Reg_WriteData //WB级指令写回寄存器的数据
    //output reg [`Word_Bus] WB_DataOut, //The data that needs to be written into a register
    //output reg WB_Mem2R
);
    initial begin
        WB_Reg_WriteAddr<=0;
        WB_Reg_WriteEn<=0;
        WB_Reg_WriteData<=0;
    end

    always@(posedge clk) begin
        if(rst==1) begin
            WB_Reg_WriteAddr<=0;
            WB_Reg_WriteEn<=0;
            WB_Reg_WriteData<=0;
        end
        else begin
            WB_Reg_WriteAddr<=MEM_Reg_WriteAddr;
            WB_Reg_WriteEn<=MEM_Reg_WriteEn;
            WB_Reg_WriteData<=MEM_Reg_WriteData;
        end
    end
endmodule