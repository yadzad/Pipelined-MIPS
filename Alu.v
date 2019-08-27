/*
Author: 张永康
Institution Affiliation: 武汉大学计算机学院
Description: EX级ALU
*/

`include "ctrl_encode_def.v"
`include "bus_def.v"

module Alu(	input [`Word_Bus] DataIn1,		//输入: ALU的第一个输入
						input [`Word_Bus] DataIn2,		//输入: ALU的第二个输入
						input [4:0]	AluCtrl,					//输入: ALU的控制信号
						output reg[`Word_Bus] AluResult,		//输出: ALU运算结果
						output reg Zero	//输出: Zero=1表明ALU运算结果全0
);
	
	initial								//Initialize
	begin
		Zero = 0;
		AluResult = 0;
	end	
	
	always@(DataIn1 or DataIn2 or AluCtrl)
	begin
	  case(AluCtrl)
	    `ALUOp_ADD: AluResult = DataIn1+DataIn2;
	    `ALUOp_ADDU: AluResult = DataIn1+DataIn2;
	    `ALUOp_SUB: AluResult = DataIn1-DataIn2;
	    `ALUOp_SUBU: AluResult = DataIn1-DataIn2;
	    `ALUOp_OR: AluResult = DataIn1|DataIn2;
	    `ALUOp_AND: AluResult = DataIn1&DataIn2;
	    `ALUOp_SLL: AluResult = DataIn2<<DataIn1;
	    `ALUOp_SRL: AluResult = DataIn2>>DataIn1;
	    `ALUOp_SLT:
	    begin
	     if(DataIn1[31]==1&&DataIn2[31]==0)
	       AluResult=1;
	     else if(DataIn1[31]==0&&DataIn2[31]==1)
	       AluResult=0;
	     else
	       AluResult = (DataIn1<DataIn2)?1:0;
	    end
	    `ALUOp_EQL: AluResult = DataIn1-DataIn2;
	    `ALUOp_BNE: AluResult = DataIn1-DataIn2;
	    `ALUOp_LUI: AluResult = DataIn2;
	    default: ;
	  endcase
	  
	  if(AluCtrl==`ALUOp_BNE)
	    begin
	      case(AluResult)
	       0: Zero=0;
	       default: Zero=1;
	      endcase
	    end
	  else
	    begin
	     case(AluResult)
	       0: Zero=1;
	       default: Zero=0;
	     endcase
	    end
	end

endmodule