/*
Author: 张永康
Institution Affiliation: 武汉大学计算机学院
Description: 寄存器堆
*/

module RegFile(input clk, //时钟信号
        input rst, //复位信号
        input WriteEn, //写使能信号
        input [4:0] WriteAddr, //被写入寄存器的地址
        input [31:0] WriteData, //要写入寄存器的数据

        //读端口1的地址和输出数据
        input [4:0] ReadAddr1, //被读出的第1个寄存器地址
        output [31:0] DataOut1, //被读出的第1个寄存器数据
        
        //读端口2的地址和输出数据
        input [4:0] ReadAddr2, //被读出的第2个寄存器地址
        output [31:0] DataOut2); //被读出的第2个寄存器数据
	
	reg [31:0] Registers[31:0];
	integer i;

	always@(posedge clk or posedge rst)
	begin
                if(rst==1) begin
                        $display("Clear the reg file!");
                        for(i=0;i<32;i=i+1) begin
                                Registers[i]<=0;
                        end
                end

        //如果写使能信号为1，则进行写操作
		else if(WriteEn == 1)
			Registers[WriteAddr] = WriteData;
                $display("R[00-07]=%8X, %8X, %8X, %8X, %8X, %8X, %8X, %8X", 0, Registers[1], Registers[2], Registers[3], Registers[4], Registers[5], Registers[6], Registers[7]);
                $display("R[08-15]=%8X, %8X, %8X, %8X, %8X, %8X, %8X, %8X", Registers[8], Registers[9], Registers[10], Registers[11], Registers[12], Registers[13], Registers[14], Registers[15]);
                $display("R[16-23]=%8X, %8X, %8X, %8X, %8X, %8X, %8X, %8X", Registers[16], Registers[17], Registers[18], Registers[19], Registers[20], Registers[21], Registers[22], Registers[23]);
                $display("R[24-31]=%8X, %8X, %8X, %8X, %8X, %8X, %8X, %8X", Registers[24], Registers[25], Registers[26], Registers[27], Registers[28], Registers[29], Registers[30], Registers[31]);
        end
        //若某个读地址和写入地址相同，则直接将要写入的数据送到读出数据口(否则，本次写入的数据要到下个周期才生效，本次读出的数据是上个周期的老数据，是错的)
	assign DataOut1 = (ReadAddr1==0)?0:(WriteEn==1&&WriteAddr==ReadAddr1)?WriteData:Registers[ReadAddr1];
	assign DataOut2 = (ReadAddr2==0)?0:(WriteEn==1&&WriteAddr==ReadAddr2)?WriteData:Registers[ReadAddr2];
endmodule