/*
Author: 张永康
Institution Affiliation: 武汉大学计算机学院
Description: MEM级(数据存储器)
*/

`include "bus_def.v"
module MEM( input MemWrite, //存储器写信号
            input MemRead, //存储器读信号
            input clk, //时钟信号
            input [4:0] DataAddr, //地址
            input [31:0] DataIn, //要写入存储器的数据
            
			output [31:0] DataOut //从存储器取出的数据
);
	reg [31:0]  DMem[1023:0];
	
	always@(posedge clk) //Write the mem when pos edge comes
	begin
		if(MemWrite)
			 DMem[DataAddr] = DataIn;
		//else if(MemRead)
	    //	DataOut = DMem[DataAddr];
		$display("addr=%8X",DataAddr);//addr to DM
    	$display("din=%8X",DataIn);//data to DM
    	$display("Mem[00-07]=%8X, %8X, %8X, %8X, %8X, %8X, %8X, %8X",DMem[0],DMem[4],DMem[8],DMem[12],DMem[16],DMem[20],DMem[24],DMem[28]);
	end
	assign DataOut = DMem[DataAddr];
endmodule
