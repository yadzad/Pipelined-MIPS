/*
Author: 张永康
Institution Affiliation: 武汉大学计算机学院
Description: EX级模块
*/

`include "ctrl_encode_def.v"
`include "bus_def.v"

module EX(  input [`Word_Bus] DataSrc_EX_MEM, // //来自EX_MEM的旁路数据
	        input [`Word_Bus] DataSrc_MEM_WB,  //来自MEM_WB的旁路数据
            
			input [`Word_Bus] DataSrc_ID_EX_Reg1,  //来自ID/EX第1个寄存器的数据
            input [`Word_Bus] DataSrc_ID_EX_Reg2, //来自ID/EX第2个寄存器的数据
            input [`Word_Bus] DataSrc_ID_EX_Instant, //来自ID/EX的立即数
			input [`Word_Bus] DataSrc_Shamt, //来自ID/EX的5位位移量Shamt

            input [`AluSrc_Bus] AluSrc1, //ID级判定的ALU第1个数据的来源
            input [`AluSrc_Bus] AluSrc2, //ID级判定的ALU第2个数据的来源
	        input [4:0]	AluCtrl, //ALU控制信号，决定ALU执行什么类型的运算
			
			input [`Reg_Addr_Bus] EX_Rs_num, //EX级的指令的Rs寄存器号
			input [`Reg_Addr_Bus] EX_Rt_num, //EX级的指令的Rt寄存器号

			input MEM_Reg_WriteEn, //MEM级的指令的寄存器写回信号
			input [`Reg_Addr_Bus] MEM_Reg_WriteAddr, //MEM级的指令的寄存器写回地址
			input WB_Reg_WriteEn, //WB级的指令的寄存器写回信号
			input [`Reg_Addr_Bus] WB_Reg_WriteAddr, //WB级的指令的寄存器写回地址

	        output [`Word_Bus] AluResult, //ALU运算结果
			//output reg[Reg_Addr_Bus] Reg_Addr,
	        output Zero, //Zero=1表示ALU的运算结果为全零
			input DMem_WriteEn, //EX级的指令的存储器写入信号
			output [`Word_Bus] Bypassed_DMem_WriteData, //将要送给MEM级的被旁路过的送入存储器的数据
			//Signal for lw stall
			input MEM_DMem_ReadEn, //MEM级存储器读信号
			output Stall_ID_EX);			//ID/EX寄存器暂停的信号
	
	wire [`AluSrc_Bus] Bypassed_AluSrc1/*synthesis noprune*/;
	wire [`AluSrc_Bus] Bypassed_AluSrc2/*synthesis noprune*/;

	//ALU源操作数
	wire [`Word_Bus] Alu_Data1/*synthesis noprune*/;
	wire [`Word_Bus] Alu_Data2/*synthesis noprune*/;
	/*
	EX级旁路控制逻辑
	当来自MEM,WB级的旁路数据同时有效时，应优先使用MEM级的数据。
	*/

	//旁路后的ALU第1个操作数来源
	assign Bypassed_AluSrc1=(AluSrc1==`AluSrc1_Reg1&&WB_Reg_WriteEn==1&&
			WB_Reg_WriteAddr!=0&&WB_Reg_WriteAddr==EX_Rs_num&&
			!(MEM_Reg_WriteEn==1&&MEM_Reg_WriteAddr!=0&&MEM_Reg_WriteAddr==EX_Rs_num))?
			`AluSrc1_MEM_WB:
			(AluSrc1==`AluSrc1_Reg1&&MEM_Reg_WriteEn==1&&MEM_Reg_WriteAddr!=0&&MEM_Reg_WriteAddr==EX_Rs_num)?
			`AluSrc1_EX_MEM:
			AluSrc1;
	
	//旁路后的ALU第2个操作数来源
	assign Bypassed_AluSrc2=(AluSrc2==`AluSrc2_Reg2&&WB_Reg_WriteEn==1&&
			WB_Reg_WriteAddr!=0&&WB_Reg_WriteAddr==EX_Rt_num&&
			!(MEM_Reg_WriteEn==1&&MEM_Reg_WriteAddr!=0&&MEM_Reg_WriteAddr==EX_Rt_num))?
			`AluSrc2_MEM_WB:
			(AluSrc2==`AluSrc2_Reg2&&MEM_Reg_WriteEn==1&&MEM_Reg_WriteAddr!=0&&MEM_Reg_WriteAddr==EX_Rt_num)?
			`AluSrc2_EX_MEM:
			AluSrc2;
	always@(Bypassed_AluSrc1 or Bypassed_AluSrc2) begin
		$display("Dbg Alu: SRC1=%8X / SRC2=%8X",Bypassed_AluSrc1,Bypassed_AluSrc2);
	end

	//旁路后的ALU第1个操作数
	assign Alu_Data1=(Bypassed_AluSrc1==`AluSrc1_Reg1)?DataSrc_ID_EX_Reg1:
					(Bypassed_AluSrc1==`AluSrc1_Shamt)?DataSrc_Shamt:
					(Bypassed_AluSrc1==`AluSrc1_EX_MEM)?DataSrc_EX_MEM:
					DataSrc_MEM_WB;

	//旁路后的ALU第2个操作数
	assign Alu_Data2=(Bypassed_AluSrc2==`AluSrc2_Reg2)?DataSrc_ID_EX_Reg2:
			(Bypassed_AluSrc2==`AluSrc2_16BitInstant)?DataSrc_ID_EX_Instant:
			(Bypassed_AluSrc2==`AluSrc2_EX_MEM)?DataSrc_EX_MEM:
			DataSrc_MEM_WB;		

	assign Bypassed_DMem_WriteData=(DMem_WriteEn==0)?0:
			(WB_Reg_WriteEn==1&&
			WB_Reg_WriteAddr!=0&&WB_Reg_WriteAddr==EX_Rt_num&&
			!(MEM_Reg_WriteEn==1&&MEM_Reg_WriteAddr!=0&&MEM_Reg_WriteAddr==EX_Rt_num))?
			DataSrc_MEM_WB:
			(MEM_Reg_WriteEn==1&&MEM_Reg_WriteAddr!=0&&MEM_Reg_WriteAddr==EX_Rt_num)?
			DataSrc_EX_MEM:
			DataSrc_ID_EX_Reg2;

	/*
	EX级阻塞控制逻辑
	当前一条数据为lw类型且发生先写后读(Read after write)类型数据相关时，需要暂停EX及其之前的所有单元一个周期。
	阻塞发生条件：当MEM级的存储器读信号为1，对应指令的写入寄存器号不为0，且等于EX级指令的Rs或Rt时，则暂停。
	*/
	
	assign Stall_ID_EX=(Bypassed_AluSrc1==`AluSrc1_EX_MEM||Bypassed_AluSrc2==`AluSrc2_EX_MEM)&&MEM_DMem_ReadEn==1;
	
	Alu U_Alu(	.DataIn1(Alu_Data1),		//1st input data of ALU
				.DataIn2(Alu_Data2),		//2nd input data of ALU
				.AluCtrl(AluCtrl),		//ALU control signal
				.AluResult(AluResult),		//The output of ALU
				.Zero(Zero));
endmodule
