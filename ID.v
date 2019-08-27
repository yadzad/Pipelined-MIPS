/*
Author: 张永康
Institution Affiliation: 武汉大学计算机学院
Description: ID级模块
*/

`include "ctrl_encode_def.v"
`include "instruction_def.v"
`include "bus_def.v"

module ID(
	input clk, //输入: 时钟信号
	input rst, //输入: 重置信号

    input [`Word_Bus] Instruction, //输入: 32位指令
	input [`Reg_Addr_Bus] Write_RegAddr_From_WB,  //输入: 来自WB级指令的写回寄存器的地址
	input [`Word_Bus] Write_RegData_From_WB, //输入: 来自WB级指令的要写回寄存器的数据
	input WriteEn_From_WB, //输入: 来自WB级指令的写回寄存器使能信号
    
    output [`Word_Bus] Reg1, //输出: ID级指令从寄存器堆读出的第一个寄存器的数据
    output [`Word_Bus] Reg2, //输出: ID级指令从寄存器堆读出的第二个寄存器的数据
	output [`Reg_Addr_Bus] Write_RegAddr, //输出: ID级指令要写回的寄存器的地址
    
	output [`Word_Bus] Instant, //输出: ID级指令的立即数
    output [`Word_Bus] Shamt, //输出: ID级指令的位移量(用于SLL,SRL指令)

    output jump,	//输出: 跳转使能信号
	output RegDst,	//输出: 写入寄存器选择(Rt或Rd)		
	output Branch,	//输出: 分支使能信号
	output MemR,	//输出: 内存读信号,lw指令有效
	output Mem2R,	//输出: 选择将从内存读出的数据作为写回寄存器的数据,lw指令有效
	output MemW,	//输出: 内存写信号,sw指令有效
	output RegW,	//输出: 写回寄存器信号,所有需要向寄存器写回结果的指令均有效
	output [`AluSrc_Bus] AluSrc1, //输出: ALU的第一个输入的选择信号
    output [`AluSrc_Bus] AluSrc2, //输出: ALU的第二个输入的选择信号
	
	output [4:0] Aluctrl, //输出: ALU的控制信号
	
	input [`Word_Bus] DataSrc_EX_MEM, //来自EX_MEM的旁路数据
	input [`Word_Bus] DataSrc_MEM_WB, //来自MEM_WB的旁路数据
    input [`Word_Bus] ID_PC, //ID级指令所处的PC值

	input MEM_Reg_WriteEn, //MEM级指令的寄存器写回使能信号
	input [`Reg_Addr_Bus] MEM_Reg_WriteAddr, //MEM级指令的寄存器写回地址
	input WB_Reg_WriteEn, //WB级指令的寄存器写回使能信号
	input [`Reg_Addr_Bus] WB_Reg_WriteAddr, //WB级指令的寄存器写回地址
	
	output [`Word_Bus] PC_New, //对beq,bne,j型指令有效,分支或跳转发生后的新的PC值
	output Change_PC_en, //对beq,bne,j型指令有效,用PC_New改变当前PC值的使能信号
	
	
	output Stall_IF_ID, //ID级流水线暂停信号
	input [`Reg_Addr_Bus] EX_Reg_WriteAddr, //EX级指令的寄存器写回地址
	input EX_Reg_WriteEn, //EX级指令的寄存器写回使能信号
	
	output [`Reg_Addr_Bus] Rs_num, //ID级指令的Rs寄存器编号
	output [`Reg_Addr_Bus] Rt_num, //ID级指令的Rt寄存器编号

	input EX_MemRead, //EX级指令的存储器读信号
	input MEM_MemRead //MEM级指令的存储器读信号
);

	wire [5:0] OpCode; //6位操作码
	wire [5:0] funct; //R型指令功能码
	wire [1:0] ExtOp; //扩展器控制信号
    wire [25:0] JumpAddr; //J型指令的26位常数
    wire [15:0] Instant_16bit; //I型指令的16位立即数

    assign OpCode = Instruction[31:26];
	assign funct[5:0] = Instruction[5:0];
	assign Shamt[31:0] = {27'd0,Instruction[10:6]};
	assign JumpAddr[25:0] = Instruction[25:0];
    assign Instant_16bit[15:0]=Instruction[15:0];

	assign Rs_num[`Reg_Addr_Bus] = Instruction[25:21];
	assign Rt_num[`Reg_Addr_Bus] = Instruction[20:16];

    assign Write_RegAddr = (RegDst==`RegDst_High)?
							Instruction[20:16]:Instruction[15:11];

    Ctrl U_Ctrl(
        .OpCode(OpCode),
	    .funct(funct),
	    .jump(jump),
	    .RegDst(RegDst),						
	    .Branch(Branch),
	    .MemR(MemR),	
	    .Mem2R(Mem2R),
	    .MemW(MemW),
	    .RegW(RegW),
	    .AluSrc1(AluSrc1),
        .AluSrc2(AluSrc2),
	    .ExtOp(ExtOp),	
	    .Aluctrl(Aluctrl));
	
	RegFile U_RegFile(.clk(clk), //时钟信号
        .rst(rst), //复位信号
        .WriteEn(WriteEn_From_WB), //写使能信号
        .WriteAddr(Write_RegAddr_From_WB), //被写入寄存器的编号
        .WriteData(Write_RegData_From_WB), //要写入寄存器的数据

        //读端口1
        .ReadAddr1(Rs_num), //第一个被读寄存器编号
        .DataOut1(Reg1), //第一个被读寄存器数据
		
        //读端口2
		.ReadAddr2(Rt_num), //第二个被读寄存器编号
        .DataOut2(Reg2) //第二个被读寄存器数据
	);

	/*
	ID级旁路控制逻辑
	由于beq,bne指令的判定分支是在ID级实现的，因此类似于EX级，ID级也需要加入旁路解决数据相关问题。
	当来自EX,MEM,WB级的旁路数据中有多个同时有效时，应优先使用最早的数据.
	换言之，三种旁路数据的优先级为: EX>MEM>WB。
	*/

    Extender U_Extender(
        .Imm16(Instant_16bit),
        .EXTOp(ExtOp),
        .Imm32(Instant));
 	wire [`AluSrc_Bus] Bypassed_AluSrc1/*synthesis noprune*/;
  	wire [`AluSrc_Bus] Bypassed_AluSrc2/*synthesis noprune*/;
	wire [`Word_Bus] Branch_Data1/*synthesis noprune*/;
	wire [`Word_Bus] Branch_Data2/*synthesis noprune*/;
	wire [`Word_Bus] ID_PC_plus4/*synthesis noprune*/;
	
	wire MEM_WB_Rs_Bypass_En,MEM_WB_Rt_Bypass_En,EX_MEM_Rs_Bypass_En,
		EX_MEM_Rt_Bypass_En,ID_EX_Rs_Bypass_En,ID_EX_Rt_Bypass_En;
	
	//=1表明MEM/WB级Rs旁路数据是有效的
	assign MEM_WB_Rs_Bypass_En=WB_Reg_WriteEn==1&&
								WB_Reg_WriteAddr!=0&&
								WB_Reg_WriteAddr==Rs_num;
	
	//=1表明EX/MEM级Rs旁路数据是有效的
	assign EX_MEM_Rs_Bypass_En=MEM_Reg_WriteEn==1&&
								MEM_Reg_WriteAddr!=0&&
								MEM_Reg_WriteAddr==Rs_num;
	
	//=1表明ID/EX级Rs旁路数据是有效的
	assign ID_EX_Rs_Bypass_En=EX_Reg_WriteEn==1&&
								EX_Reg_WriteAddr!=0&&
								EX_Reg_WriteAddr==Rs_num;

	//=1表明MEM/WB级Rt旁路数据是有效的
	assign MEM_WB_Rt_Bypass_En=WB_Reg_WriteEn==1&&
								WB_Reg_WriteAddr!=0&&
								WB_Reg_WriteAddr==Rt_num;
	
	//=1表明EX/MEM级Rt旁路数据是有效的
	assign EX_MEM_Rt_Bypass_En=MEM_Reg_WriteEn==1&&
								MEM_Reg_WriteAddr!=0&&
								MEM_Reg_WriteAddr==Rt_num;
	
	//=1表明ID/EX级Rt旁路数据是有效的
	assign ID_EX_Rt_Bypass_En=EX_Reg_WriteEn==1&&
								EX_Reg_WriteAddr!=0&&
								EX_Reg_WriteAddr==Rt_num;

	//经旁路得到的ALU的第1个源操作数的来源
	assign Bypassed_AluSrc1=
			(MEM_WB_Rs_Bypass_En==1&&EX_MEM_Rs_Bypass_En==0&&ID_EX_Rs_Bypass_En==0)?
			`AluSrc1_MEM_WB:
			(EX_MEM_Rs_Bypass_En==1&&ID_EX_Rs_Bypass_En==0)?
			`AluSrc1_EX_MEM:
			(ID_EX_Rs_Bypass_En==1)?
			`AluSrc1_ID_EX:
			`AluSrc1_Reg1;
	
	//经旁路得到的ALU的第2个源操作数的来源
	assign Bypassed_AluSrc2=
			(MEM_WB_Rt_Bypass_En==1&&EX_MEM_Rt_Bypass_En==0&&ID_EX_Rt_Bypass_En==0)?
			`AluSrc2_MEM_WB:
			(EX_MEM_Rt_Bypass_En==1&&ID_EX_Rt_Bypass_En==0)?
			`AluSrc2_EX_MEM:
			(ID_EX_Rt_Bypass_En==1)?
			`AluSrc2_ID_EX:
			`AluSrc2_Reg2;

	//经旁路得到的ALU的第1个源操作数
	assign Branch_Data1=(Bypassed_AluSrc1==`AluSrc1_Reg1)?Reg1:
					(Bypassed_AluSrc1==`AluSrc1_EX_MEM)?DataSrc_EX_MEM:
					DataSrc_MEM_WB;

	//经旁路得到的ALU的第2个源操作数
	assign Branch_Data2=(Bypassed_AluSrc2==`AluSrc2_Reg2)?Reg2:
			(Bypassed_AluSrc2==`AluSrc2_EX_MEM)?DataSrc_EX_MEM:
			DataSrc_MEM_WB;	
	
	//ID级指令所对应PC值+4
	assign ID_PC_plus4=ID_PC+4;

	//=1表示发生了跳转或分支，需要改变PC单元的PC值
	assign Change_PC_en=(Stall_IF_ID==0)&&((OpCode==`INSTR_J_OP)||
			(OpCode==`INSTR_BEQ_OP&&Branch_Data1==Branch_Data2)||
			(OpCode==`INSTR_BNE_OP&&Branch_Data1!=Branch_Data2));
	
	/*
	ID级阻塞控制逻辑
	由于beq,bne指令的判定分支是在ID级实现的，因此类似于EX级，ID级也需要加入因数据相关引发的阻塞。当前一条数据为lw/R类型且发生先写后读(Read after write)类型数据相关时，需要暂停ID及其之前的所有单元一个周期。
	阻塞发生条件：
	当EX级的寄存器写回信号为1，对应指令的写入寄存器号不为0，且等于ID级指令的Rs或Rt时。
	*/

	//=1表示需要暂停IF/ID寄存器，同时PC Unit,IF,ID级都暂停，而EX,MEM,WB级继续执行
	assign Stall_IF_ID=(OpCode==`INSTR_BEQ_OP||OpCode==`INSTR_BNE_OP)&&
						(Bypassed_AluSrc1==`AluSrc1_ID_EX||(Bypassed_AluSrc1==`AluSrc1_EX_MEM&&MEM_MemRead==1)||
						Bypassed_AluSrc2==`AluSrc2_ID_EX||(Bypassed_AluSrc2==`AluSrc2_EX_MEM&&MEM_MemRead==1));

	//跳转或分支改变PC单元的新PC值
	assign PC_New=(Stall_IF_ID==1)?ID_PC_plus4:
			(OpCode==`INSTR_J_OP)?{ID_PC_plus4[31:28],JumpAddr,2'd0}:
			(OpCode==`INSTR_BEQ_OP&&Branch_Data1==Branch_Data2)?(ID_PC_plus4+(Instant<<2)):
			(OpCode==`INSTR_BNE_OP&&Branch_Data1!=Branch_Data2)?(ID_PC_plus4+(Instant<<2)):
			ID_PC;
endmodule