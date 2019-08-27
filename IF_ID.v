/*
Author: 张永康
Institution Affiliation: 武汉大学计算机学院
Description: IF/ID寄存器
*/

`include "bus_def.v"

module IF_ID(
    input clk, //输入: 时钟信号
    input rst, //输入: 重置信号
	input Stall, //输入: ID级流水线暂停信号

    input [`Word_Bus] IF_PC, //输入: IF级的PC值
    input [`Word_Bus] IF_Instruction, //输入: IF级从指令存储器取出的指令
	
    output reg [`Word_Bus] ID_PC, //输出: ID级的PC值
    output reg [`Word_Bus] ID_Instruction //输出: ID级的指令
);
    initial begin
        ID_PC<=0;
        ID_Instruction<=0;
    end

    always@(posedge clk) begin
        if(rst==1) begin
            ID_PC<=0;
            ID_Instruction<=0;
            $display("IF/ID Reset!");
        end
        else if(Stall==1) begin
            ID_PC<=ID_PC;
            ID_Instruction<=ID_Instruction;
		end
		else begin
            ID_PC<=IF_PC;
            ID_Instruction<=IF_Instruction;
            $display("IF/ID: %8X %8X",ID_PC,ID_Instruction);
        end
    end
endmodule
