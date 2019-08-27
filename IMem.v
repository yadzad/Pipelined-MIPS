/*
Author: 张永康
Institution Affiliation: 武汉大学计算机学院
Description: 指令存储器
*/

`include "bus_def.v"

module IMem(OpCode,ImAdress);
	input [`IMem_Addr_Bus] ImAdress; //当前指令的地址

	output [`Word_Bus]  OpCode; //输出的32位指令
	
	reg [`Word_Bus] Opcode;
	
	reg [`Word_Bus]  IMem[1023:0];
	
	always@(ImAdress)
	begin
		$display("IMem[00-07]=%8X, %8X, %8X, %8X, %8X, %8X, %8X, %8X",IMem[0],IMem[1],IMem[2],IMem[3],IMem[4],IMem[5],IMem[6],IMem[7]);
		Opcode = IMem[ImAdress];	
	end
	assign OpCode = Opcode;
endmodule