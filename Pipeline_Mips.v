/*
Author: 张永康
Institution Affiliation: 武汉大学计算机学院
Description: 顶层代码
*/

`include "bus_def.v"
`include "ctrl_encode_def.v"

module Pipeline_Mips( );
	
   reg Clk, Reset;
  wire [`Word_Bus] IF_Instruction;
   initial begin
      $readmemh( "sort_test.txt", U_IMem.IMem ) ; 
      //$readmemh( "Test_Signal_Pipeline.txt", U_IMem.IMem ) ; 
      
      $monitor("PC = 0x%8X, IR = 0x%8X", U_PcUnit.PC, IF_Instruction );        
      Clk = 1 ;
      Reset = 0 ;
      #5 Reset = 1 ;
      #20 Reset = 0 ;
   end

	always
	   #(50) Clk = ~Clk;
	
	wire [`Word_Bus] PC_out;
	wire [`IMem_Addr_Bus] IMem_Addr;

	wire [`Word_Bus] EX_Instant,ID_Instant;
	wire Change_PC_en;
	wire [`Word_Bus] PC_New;
	wire Stall_IF_ID,Stall_ID_EX;

	PcUnit U_PcUnit(.PC(PC_out),
			.PcReSet(Reset),
			.Change_PC_en(Change_PC_en),
			.Stall(Stall_IF_ID|Stall_ID_EX), //ID级或EX级要求阻塞时，需要暂停PC计数器
			.Clk(Clk),
			.PC_New(PC_New));

	assign IMem_Addr[`IMem_Addr_Bus]=PC_out[11:2];
	IMem U_IMem(.OpCode(IF_Instruction),.ImAdress(IMem_Addr));

	wire [`Word_Bus] ID_Instruction,ID_PC;
	
	/*
	ID和EX级阻塞同时发生的解决办法
	当ID和EX级阻塞同时发生时，优先照顾EX级阻塞的请求，
	即对EX级及其之前的所有单元阻塞一个周期。
	该周期结束后，如果ID级所需的数据仍无法通过旁路得到，
	则会再次触发ID级的阻塞。
	*/

	IF_ID U_IF_ID(.clk(Clk), //时钟信号
    			.rst(Reset|Change_PC_en), //重置信号
			    .Stall(Stall_IF_ID|Stall_ID_EX), //ID级或EX级要求阻塞时，需要阻塞IF/ID寄存器
				.IF_PC(PC_out), //IF级的PC值
    			.IF_Instruction(IF_Instruction),
				.ID_PC(ID_PC),
				.ID_Instruction(ID_Instruction)); //IF级从指令存储器取出的指令

	wire [`Word_Bus] ID_Reg1,ID_Reg2,ID_Shamt;
	wire jump,RegDst,Branch,MemR,Mem2R,MemW,RegW;
	wire [`AluSrc_Bus] AluSrc1,AluSrc2;
	wire [4:0] Aluctrl;
	wire [`Reg_Addr_Bus] Write_RegAddr;

	wire [`Reg_Addr_Bus] WB_Reg_WriteAddr;
	wire WB_Reg_WriteEn,WB_Mem2R;
	wire [`Word_Bus] WB_Reg_WriteData;
	wire [`Reg_Addr_Bus] Rs_num,Rt_num,Rd_num;

	wire [`Word_Bus] MEM_AluResult;

	wire [`Reg_Addr_Bus] MEM_Reg_WriteAddr;
	wire MEM_Reg_WriteEn;

	wire EX_RegWrite;
    wire [`Reg_Addr_Bus] EX_RegAddr;
	wire EX_MemRead,MEM_DMem_ReadEn;
	ID U_ID(
		.clk(Clk),
		.rst(Reset),

		.Instruction(ID_Instruction),
		.Write_RegAddr_From_WB(WB_Reg_WriteAddr), //来自WB级的写寄存器的地址
		.Write_RegData_From_WB(WB_Reg_WriteData), //来自WB级的写寄存器的地址
		.WriteEn_From_WB(WB_Reg_WriteEn), //来自WB级的写寄存器的地址
		
		.Reg1(ID_Reg1),
		.Reg2(ID_Reg2),
		.Write_RegAddr(Write_RegAddr),

		//杈撳嚭鐨勭粡鎷撳睍鐨勭珛鍗虫暟鍊煎拰鍋忕Щ閲廠hamt鍊�
		.Instant(ID_Instant),
		.Shamt(ID_Shamt),

		//杈撳嚭鐨勬帶鍒朵俊鍙�
		.jump(jump),						//?鐎垫碍绂掗妶鍫㈠劜閺夛拷?
		.RegDst(RegDst),						
		.Branch(Branch),						//?閸拷?閿燂拷?
		.MemR(MemR),						//閻犲洩顕�?閿燂拷?閸嬪秹宕崇瘬
		.Mem2R(Mem2R),						//?閺嗙喖骞�?閻庢冻鎷�?閸嬪秹宕抽妸銉ョ厒閿燂拷?閸曨偆鎽�?濞呮帪鎷�?閿燂拷
		.MemW(MemW),						//?閸燂拷?閺嗙喖骞�?閻庢冻鎷�?閸嬪秹宕崇瘬
		.RegW(RegW),						//閻庨潧瀚悺锟�?濞呮帪鎷�?閿燂拷?閸燂拷?閸欏棝寮悧鍫嫹?
		.AluSrc1(AluSrc1),						//閺夆晜鍔楅悾锟�?濞呮帡骞欏鍕▕?閺嗙喖鏌呴敓锟�?閿燂拷?
		.AluSrc2(AluSrc2),						//閺夆晜鍔楅悾锟�?濞呮帡骞欏鍕▕?閺嗙喖鏌呴敓锟�?閿燂拷?
		.Aluctrl(Aluctrl),						//Alu閺夆晜鍔楅悾骞烩斁鍋撻敓锟�?閿燂拷?

		//为支持分支与跳转加入的信号
		.DataSrc_EX_MEM(MEM_AluResult), //EX_MEM閺冧浇鐭剧紒鎾寸亯
		.DataSrc_MEM_WB(WB_Reg_WriteData), //MEM_WB閺冧浇鐭剧紒鎾寸亯
		.ID_PC(ID_PC),

		.MEM_Reg_WriteEn(MEM_Reg_WriteEn),
		.MEM_Reg_WriteAddr(MEM_Reg_WriteAddr),
		.WB_Reg_WriteEn(WB_Reg_WriteEn),
		.WB_Reg_WriteAddr(WB_Reg_WriteAddr),
		
		.PC_New(PC_New),
		.Change_PC_en(Change_PC_en),
		//End
		
		//Signal for stall when R instruction & beq together
		.Stall_IF_ID(Stall_IF_ID),
		.EX_Reg_WriteAddr(EX_RegAddr),
		.EX_Reg_WriteEn(EX_RegWrite),

		.Rs_num(Rs_num),
		.Rt_num(Rt_num),
		//.Rd_num(Rd_num)
		.EX_MemRead(EX_MemRead), //EX级指令的存储器读信号
		.MEM_MemRead(MEM_DMem_ReadEn) //MEM级指令的存储器读信号
	);

	wire [`Word_Bus] EX_Reg1,EX_Reg2,EX_Shamt; //来自ID/EX的Shamt偏移量
    //2. Control signal
    //--2.1 EX级控制信号
    wire [`AluSrc_Bus] EX_AluSrc1,EX_AluSrc2; //ALU源操作数2控制信号
    wire [4:0] EX_AluCtrl; //来自ID/EX的ALU控制信号
    //--2.2 MEM级控制信号
    wire EX_MemWrite;
    //--2.3 WB级控制信号
	//3. Rs,rt,rd寄存器号
	wire [`Reg_Addr_Bus] EX_Rs_num,EX_Rt_num,EX_Rd_num;
	
	ID_EX U_ID_EX(
		.clk(Clk),
		.rst(Reset|(Stall_IF_ID&(~Stall_ID_EX))), //!!!!注意这里，当ID、EX同时发现要暂停流水线，优先照顾EX的请求，ID/EX不要清空
		.Stall(Stall_ID_EX),
		
		//Information came from ID stage
		//1. Reg1&2 , intant number, shamt value in ID
		.ID_Reg1(ID_Reg1), //ID级取出的寄存器1的值
		.ID_Reg2(ID_Reg2), //ID级取出的寄存器2的值
		.ID_Instant(ID_Instant), //ID级取出的经扩展得到的立即数的值
		.ID_Shamt(ID_Shamt), //来自ID/EX的Shamt偏移量
		//2. Control signal
		//--2.1 EX级控制信号
		.ID_AluSrc1(AluSrc1), //ALU源操作数1控制信号
		.ID_AluSrc2(AluSrc2), //ALU源操作数2控制信号
		.ID_AluCtrl(Aluctrl), //来自ID/EX的ALU控制信号
		//--2.2 MEM级控制信号
		.ID_MemWrite(MemW),
		.ID_MemRead(MemR),
		//.ID_MemAddr(),
		//--2.3 WB级控制信号
		.ID_RegWrite(RegW),
		.ID_Mem2R(Mem2R),
		.ID_RegAddr(Write_RegAddr),
		//3. RS,RT,RD寄存器号
		.ID_Rs_num(Rs_num),
		.ID_Rt_num(Rt_num),
		//.ID_Rd_num(Rd_num),

		//Information that sends into EX stage
		//1. Reg1&2 , intant number, shamt value in ID
		.EX_Reg1(EX_Reg1), //ID级取出的寄存器1的值
		.EX_Reg2(EX_Reg2), //ID级取出的寄存器2的值
		.EX_Instant(EX_Instant), //ID级取出的经扩展得到的立即数的值
		.EX_Shamt(EX_Shamt), //来自ID/EX的Shamt偏移量
		//2. Control signal
		//--2.1 EX级控制信号
		.EX_AluSrc1(EX_AluSrc1), //ALU源操作数1控制信号
		.EX_AluSrc2(EX_AluSrc2), //ALU源操作数2控制信号
		.EX_AluCtrl(EX_AluCtrl), //来自ID/EX的ALU控制信号
		//--2.2 MEM级控制信号
		.EX_MemWrite(EX_MemWrite),
		.EX_MemRead(EX_MemRead),
		//--2.3 WB级控制信号
		.EX_RegWrite(EX_RegWrite),
		.EX_Mem2R(EX_Mem2R),
		.EX_RegAddr(EX_RegAddr),
		//3.Rs,Rt,Rd寄存器号
		.EX_Rs_num(EX_Rs_num),
		.EX_Rt_num(EX_Rt_num)
		//.EX_Rd_num(EX_Rd_num)
	);

	wire [`Word_Bus] AluResult;
	wire Zero;
	wire [`Word_Bus] Bypassed_DMem_WriteData;
	//wire MEM_DMem_ReadEn;

	EX U_EX(.DataSrc_EX_MEM(MEM_AluResult), //EX_MEM鏃佽矾缁撴灉
	        .DataSrc_MEM_WB(WB_Reg_WriteData), //MEM_WB鏃佽矾缁撴灉
            
			.DataSrc_ID_EX_Reg1(EX_Reg1), //鏉ヨ嚜ID/EX鐨勫瘎瀛樺櫒1鍊�
            .DataSrc_ID_EX_Reg2(EX_Reg2), //鏉ヨ嚜ID/EX鐨勫瘎瀛樺櫒2鍊�
            .DataSrc_ID_EX_Instant(EX_Instant), //鏉ヨ嚜ID/EX鐨勭珛鍗虫暟鍊�
			.DataSrc_Shamt(EX_Shamt), //鏉ヨ嚜ID/EX鐨凷hamt鍋忕Щ閲�
			
            .AluSrc1(EX_AluSrc1), //ALU婧愭搷浣滄暟1鎺у埗淇″彿
            .AluSrc2(EX_AluSrc2), //ALU婧愭搷浣滄暟2鎺у埗淇″彿
	        .AluCtrl(EX_AluCtrl), //鏉ヨ嚜ID/EX鐨凙LU鎺у埗淇″彿
			
			//旁路功能所需输入
			.EX_Rs_num(EX_Rs_num),
			.EX_Rt_num(EX_Rt_num),

			.MEM_Reg_WriteEn(MEM_Reg_WriteEn),
			.MEM_Reg_WriteAddr(MEM_Reg_WriteAddr),
			.WB_Reg_WriteEn(WB_Reg_WriteEn),
			.WB_Reg_WriteAddr(WB_Reg_WriteAddr),

	        .AluResult(AluResult),		//閺夆晜鍔楅悾锟�?濞呮帪鎷�?閿燂拷?閸ゎ叏鎷�?閿燂拷?閻忥拷
			//.Reg_Addr,
	        .Zero(Zero),
			.DMem_WriteEn(EX_MemWrite),
			.Bypassed_DMem_WriteData(Bypassed_DMem_WriteData),
			//Signal for lw stall
			.MEM_DMem_ReadEn(MEM_DMem_ReadEn),
			.Stall_ID_EX(Stall_ID_EX));

	wire [`Word_Bus] EX_Reg_WriteData,MEM_Reg_WriteData;
	wire [`DMem_Addr_Bus] MEM_DMem_WriteAddr;
	wire MEM_DMem_WriteEn;
	wire [`Word_Bus] MEM_DMem_WriteData; //,MEM_AluResult;
	wire [`Reg_Addr_Bus] MEM_Rs_num,MEM_Rt_num;

	EX_MEM U_EX_MEM(
		.clk(Clk),
    	.rst(Reset|Stall_ID_EX),
    	.EX_Reg_WriteAddr(EX_RegAddr),
		.EX_Reg_WriteEn(EX_RegWrite),
		.EX_AluResult(AluResult),
		.EX_Mem2R(EX_Mem2R),
    	.EX_DMem_WriteAddr(AluResult[`DMem_Addr_Bus]),
		.EX_DMem_WriteEn(EX_MemWrite),
		.EX_DMem_ReadEn(EX_MemRead),
    	.EX_DMem_WriteData(Bypassed_DMem_WriteData),
		.MEM_Reg_WriteAddr(MEM_Reg_WriteAddr),
		.MEM_Reg_WriteEn(MEM_Reg_WriteEn),
		.MEM_AluResult(MEM_AluResult),
		.MEM_Mem2R(MEM_Mem2R),
		.MEM_DMem_WriteAddr(MEM_DMem_WriteAddr),
		.MEM_DMem_WriteEn(MEM_DMem_WriteEn),
		.MEM_DMem_ReadEn(MEM_DMem_ReadEn),
		.MEM_DMem_WriteData(MEM_DMem_WriteData)
	);

	wire [`Word_Bus] MEM_DataOut;
	assign MEM_Reg_WriteData=(MEM_Mem2R==`Mem2R_From_Alu)?MEM_AluResult:MEM_DataOut;

	MEM U_MEM(.MemWrite(MEM_DMem_WriteEn),
            .MemRead(MEM_DMem_ReadEn),
            .clk(Clk),
            .DataAddr(MEM_DMem_WriteAddr),
            .DataIn(MEM_DMem_WriteData),
			//Output
            .DataOut(MEM_DataOut));

	MEM_WB U_MEM_WB(
		.clk(Clk),
		.rst(Reset),
		.MEM_Reg_WriteAddr(MEM_Reg_WriteAddr),
		.MEM_Reg_WriteEn(MEM_Reg_WriteEn),
		.MEM_Reg_WriteData(MEM_Reg_WriteData),
		.WB_Reg_WriteAddr(WB_Reg_WriteAddr),
		.WB_Reg_WriteEn(WB_Reg_WriteEn),
		.WB_Reg_WriteData(WB_Reg_WriteData)
	);
endmodule











