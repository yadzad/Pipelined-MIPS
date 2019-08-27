/*
Author: 张永康
Institution Affiliation: 武汉大学计算机学院
Description: ID级扩展器
*/

`include "ctrl_encode_def.v"

module Extender(
   input  [15:0] Imm16,     //输入: 来自指令低16位的立即数
   input  [1:0]  EXTOp,     //输入: 扩展器控制信号
   output reg [31:0] Imm32  //输出: 扩展得到的32位立即数
); 
   always @(*) begin
      case (EXTOp)
         `EXT_ZERO:    Imm32 = {16'd0, Imm16};
         `EXT_SIGNED:  Imm32 = {{16{Imm16[15]}}, Imm16};
         `EXT_HIGHPOS: Imm32 = {Imm16, 16'd0};
         default: ;
      endcase
   end
endmodule

