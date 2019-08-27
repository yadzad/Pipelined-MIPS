`include "bus_def.v"

module PcUnit(output reg [`Word_Bus] PC,
			input PcReSet,
			input Change_PC_en,
			input Stall,
			input Clk,
			input [`Word_Bus] PC_New);
	
	integer i;
	reg [31:0] temp;
	always@(posedge Clk or posedge PcReSet)
	begin
		if(PcReSet == 1) begin //重置信号为1，则重置PC值为0
			PC <= 32'h0000_3000;
		end
	  	else if(Change_PC_en==1) begin //改变PC值使能信号为1，表明分支或跳转发生，则用新的PC值替换原有PC值
		  	PC<=PC_New;
		end
		 //若阻塞信号为1，则PC值不+4，这样在下一周期取指时还会取出本周期的指令
		else if(Stall==0) begin //否则PC值+4
			PC <= PC+4;
		end
	end
endmodule
	
	