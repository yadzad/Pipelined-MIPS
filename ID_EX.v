`include "bus_def.v"

module ID_EX(
    input clk,
    input rst,
	//Signal for stall
	input Stall,
	
    //Information came from ID stage
    //1. Reg1&2 , intant number, shamt value in ID
    input [`Word_Bus] ID_Reg1, //ID级取出的寄存器1的值
    input [`Word_Bus] ID_Reg2, //ID级取出的寄存器2的值
    input [`Word_Bus] ID_Instant, //ID级取出的经扩展得到的立即数的值
    input [`Word_Bus]	ID_Shamt, //来自ID/EX的Shamt偏移量
    //2. Control signal
    //--2.1 EX级控制信号
    input [`AluSrc_Bus] ID_AluSrc1, //ALU源操作数1控制信号
    input [`AluSrc_Bus] ID_AluSrc2, //ALU源操作数2控制信号
    input [4:0]	ID_AluCtrl, //来自ID/EX的ALU控制信号
    //--2.2 MEM级控制信号
    input ID_MemWrite,
    input ID_MemRead,
    //input [`DMem_Addr_Bus] ID_MemAddr,
    //--2.3 WB级控制信号
    input ID_RegWrite,
    input ID_Mem2R,
    input [`Reg_Addr_Bus] ID_RegAddr,
    //3. rs,rt,rd寄存器号
    input [`Reg_Addr_Bus] ID_Rs_num,
	input [`Reg_Addr_Bus] ID_Rt_num,
	//input [`Reg_Addr_Bus] ID_Rd_num,
	
    //Information that sends into EX stage
    //1. Reg1&2 , intant number, shamt value in ID
    output reg [`Word_Bus] EX_Reg1, //ID级取出的寄存器1的值
    output reg [`Word_Bus] EX_Reg2, //ID级取出的寄存器2的值
    output reg [`Word_Bus] EX_Instant, //ID级取出的经扩展得到的立即数的值
    output reg [`Word_Bus] EX_Shamt, //来自ID/EX的Shamt偏移量
    //2. Control signal
    //--2.1 EX级控制信号
    output reg [`AluSrc_Bus] EX_AluSrc1, //ALU源操作数1控制信号
    output reg [`AluSrc_Bus] EX_AluSrc2, //ALU源操作数2控制信号
    output reg [4:0] EX_AluCtrl, //来自ID/EX的ALU控制信号
    //--2.2 MEM级控制信号
    output reg EX_MemWrite,
    output reg EX_MemRead,
    //output reg [`DMem_Addr_Bus] EX_MemAddr,
    //--2.3 WB级控制信号
    output reg EX_RegWrite,
    output reg EX_Mem2R,
    output reg [`Reg_Addr_Bus] EX_RegAddr,
    //3. rs,rt,rd寄存器号
    output reg [`Reg_Addr_Bus] EX_Rs_num,
	output reg [`Reg_Addr_Bus] EX_Rt_num
	//output reg [`Reg_Addr_Bus] EX_Rd_num,
);
    initial begin
        EX_Reg1<=0;
        EX_Reg2<=0;
        EX_Instant<=0;
        EX_Shamt<=0;

        EX_AluSrc1<=0;
        EX_AluSrc2<=0;
        EX_AluCtrl<=0;

        EX_MemWrite<=0;
        EX_MemRead<=0;
            //EX_MemAddr<=0;
            //--2.3 WB级控制信号
        EX_RegWrite<=0;
        EX_Mem2R<=0;
        EX_RegAddr<=0;
            
        EX_Rs_num<=0;
        EX_Rt_num<=0;
            //EX_Rd_num<=0;
    end
    
    always@(posedge clk) begin
        if(rst==1) begin
            EX_Reg1<=0;
            EX_Reg2<=0;
            EX_Instant<=0;
            EX_Shamt<=0;

            EX_AluSrc1<=0;
            EX_AluSrc2<=0;
            EX_AluCtrl<=0;

            EX_MemWrite<=0;
            EX_MemRead<=0;
            //EX_MemAddr<=0;
            //--2.3 WB级控制信号
            EX_RegWrite<=0;
            EX_Mem2R<=0;
            EX_RegAddr<=0;
            
            EX_Rs_num<=0;
            EX_Rt_num<=0;
            //EX_Rd_num<=0;
        end
		else if(Stall==1) begin
            EX_Reg1<=EX_Reg1;
            EX_Reg2<=EX_Reg2;
            EX_Instant<=EX_Instant;
            EX_Shamt<=EX_Shamt;
            
            EX_AluSrc1<=EX_AluSrc1;
            EX_AluSrc2<=EX_AluSrc2;
            EX_AluCtrl<=EX_AluCtrl;

            EX_MemWrite<=EX_MemWrite;
            EX_MemRead<=EX_MemRead;
            //EX_MemAddr<=ID_MemAddr;
            //--2.3 WB级控制信号
            EX_RegWrite<=EX_RegWrite;
            EX_Mem2R<=EX_Mem2R;
            EX_RegAddr<=EX_RegAddr;

            EX_Rs_num<=EX_Rs_num;
            EX_Rt_num<=EX_Rt_num;
            //EX_Rd_num<=ID_Rd_num;
		end
        else begin
            EX_Reg1<=ID_Reg1;
            EX_Reg2<=ID_Reg2;
            EX_Instant<=ID_Instant;
            EX_Shamt<=ID_Shamt;
            
            EX_AluSrc1<=ID_AluSrc1;
            EX_AluSrc2<=ID_AluSrc2;
            EX_AluCtrl<=ID_AluCtrl;

            EX_MemWrite<=ID_MemWrite;
            EX_MemRead<=ID_MemRead;
            //EX_MemAddr<=ID_MemAddr;
            //--2.3 WB级控制信号
            EX_RegWrite<=ID_RegWrite;
            EX_Mem2R<=ID_Mem2R;
            EX_RegAddr<=ID_RegAddr;

            EX_Rs_num<=ID_Rs_num;
            EX_Rt_num<=ID_Rt_num;
            //EX_Rd_num<=ID_Rd_num;
        end
    end
endmodule