
module DMem(DataAdr,DataIn,DataOut,DMemW,DMemR,clk);
	input [4:0] DataAdr;
	input [31:0] DataIn;
	input 		 DMemR;
	input 		 DMemW;
	input 		 clk;
	
	output reg[31:0] DataOut;
	
	reg [31:0]  DMem[1023:0];
	
	always@(posedge clk) //上升沿到来时写存储器
	begin
		if(DMemW)
			 DMem[DataAdr] <= DataIn;
		$display("addr=%8X",DataAdr);//addr to DM
    	$display("din=%8X",DataIn);//data to DM
    	$display("Mem[00-07]=%8X, %8X, %8X, %8X, %8X, %8X, %8X, %8X",DMem[0],DMem[4],DMem[8],DMem[12],DMem[16],DMem[20],DMem[24],DMem[28]);
	end
	
	always@(negedge clk) //下降沿到来时读存储器
	begin
	   if(DMemR)
	    DataOut = DMem[DataAdr];
	end
endmodule