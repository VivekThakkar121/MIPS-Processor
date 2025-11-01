`include "definitions_pkg.sv"

module Execution (
   input   logic        clk,
   input   logic        rst,
	input   logic        flush,
	input   logic        stall_i,
   input   logic [31:0] IR_i,
   input   logic [31:0] Operand1_i,
   input   logic [31:0] Operand2_i,
	input   logic [31:0] PC_i,
   output  logic [31:0] IR_EXE_o,
   output  logic [31:0] ALUOut_EXE_o,
	output  logic [31:0] target_branch_addr_o,     
	output  logic        branch_taken_o
);

   import definitions_pkg::*;
	logic [31:0] alu_result;
	
	
	ALU ALU_Inst1 (.clk(clk),.rst(rst),.Instruction_code(IR_i),.Operand1_i(Operand1_i),.Operand2_i(Operand2_i),.Result_o(alu_result),.branch_taken_o(branch_taken_o),.Result_Prev_o(ALUOut_EXE_o));
	
	always_comb begin
      target_branch_addr_o = 32'b0;	
		if (branch_taken_o) begin 
			if ((IR_i[31:26] == OPCODE_BEQ) || (IR_i[31:26] == OPCODE_BNE)) begin 
				target_branch_addr_o = PC_i + alu_result;
			end else if (IR_i[31:26] == OPCODE_J) begin 
				target_branch_addr_o = {2'b0,PC_i[31:28],alu_result[25:0]};
			end else begin 
				target_branch_addr_o = 32'b0;
			end
		end
	end 
	
	
   always_ff @(posedge clk) begin
      if (rst | flush) begin
			IR_EXE_o     <= 32'b0;
      end else if(!stall_i) begin
			IR_EXE_o     <= IR_i;
	   end
	end	
	
 
endmodule : Execution


