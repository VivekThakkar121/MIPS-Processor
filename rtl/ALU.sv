`include "definitions_pkg.sv"

module ALU (
   input  logic        clk,
	input  logic        rst,
	input  logic [31:0] Instruction_code,
	input  logic [31:0] Operand1_i,
	input  logic [31:0] Operand2_i,
	input  logic [31:0] PC_i,              // from IF module 
	output logic [31:0] Result_o,
	output logic [31:0] Result_Prev_o,
	output logic        branch_taken_o
);

   import definitions_pkg::*;

	logic [4:0] Sa;
	logic [31:0]Result_prev;
	logic [31:0]PC;
	
   assign Sa            = Instruction_code[10:6];
	assign Result_Prev_o = Result_prev;
	assign PC            = PC_i - 1'b1;
	
	always_ff @(posedge clk) begin 
		if (rst) begin 
			Result_prev  <= 32'b0;
		end else begin 
			Result_prev  <= Result_o;
		end
	end

	always_comb begin
      branch_taken_o = 1'b0;	
		Result_o       = Result_prev;
		case (Instruction_code[31:26])
         OPCODE_RTYPE_SPECIAL1: begin
            case (Instruction_code[5:0])
               FUNCT_ADD: Result_o = Operand1_i + Operand2_i;
               FUNCT_AND: Result_o = Operand1_i & Operand2_i;
               FUNCT_NOR: Result_o = ~(Operand1_i | Operand2_i);
               FUNCT_OR : Result_o = Operand1_i | Operand2_i;
               FUNCT_DIV: Result_o = Operand1_i / Operand2_i;
               FUNCT_SUB: Result_o = Operand1_i - Operand2_i;
               FUNCT_SLL: Result_o = Operand2_i << Sa;
               FUNCT_SRA: Result_o = ($signed(Operand2_i)) >>> Sa;
               default:   Result_o = Result_prev;  // Hold
            endcase
         end
	
         OPCODE_RTYPE_SPECIAL2: begin
            case (Instruction_code[5:0])
               FUNCT_CLO: begin
                  // Count leading ones
                  Result_o = count_leading_ones(Operand1_i);
               end
               FUNCT_CLZ: begin
                  // Count leading zeros
                  Result_o = count_leading_zeros(Operand1_i);
               end
               default: Result_o = Result_prev;
            endcase
         end
	
         OPCODE_ADDI: Result_o = Operand1_i + {{16{Instruction_code[15]}}, Instruction_code[15:0]};
         OPCODE_ANDI: Result_o = Operand1_i & {16'b0, Instruction_code[15:0]};
         OPCODE_ORI : Result_o = Operand1_i | {16'b0, Instruction_code[15:0]};
         OPCODE_MUL : Result_o = Operand1_i * Operand2_i;
         OPCODE_SLTI: Result_o = (Operand1_i < {{16{Instruction_code[15]}}, Instruction_code[15:0]}) ? 32'd1 : 32'd0;
         OPCODE_LW  : Result_o = Operand1_i + {{16{Instruction_code[15]}}, Instruction_code[15:0]};
         OPCODE_SW  : Result_o = Operand1_i + {{16{Instruction_code[15]}}, Instruction_code[15:0]};
         OPCODE_BEQ : begin 
							    if (Operand1_i == Operand2_i) begin 
								    Result_o = {{16{Instruction_code[15]}}, Instruction_code[15:0]} + PC;  // branch offset	
									 branch_taken_o = 1'b1;
								 end else begin 
								    Result_o = Result_prev;
								 end	
			             end
         OPCODE_BNE : begin 
							    if (Operand1_i != Operand2_i) begin 
								    Result_o       = {{16{Instruction_code[15]}}, Instruction_code[15:0]} + PC;  // branch offset	
									 branch_taken_o = 1'b1;
								 end else begin 
								    Result_o = Result_prev;
								 end	
			             end
         OPCODE_J   : begin
			                Result_o       = {2'b0, PC[31:28],Instruction_code[25:0]}; // Branch target handled elsewhere
								 branch_taken_o = 1'b1;
                      end
			default    : Result_o = Result_prev; // Retain previous value
      endcase
	end


   // --------------------------
   // Helper functions
   // --------------------------
   function automatic [31:0] count_leading_zeros(input logic [31:0] val);
      int i;
      begin
         count_leading_zeros = 0;
         for (i = 31; i >= 0; i--) begin
            if (val[i] == 1'b0)
               count_leading_zeros++;
            else
               break;
         end
      end
   endfunction
	
   function automatic [31:0] count_leading_ones(input logic [31:0] val);
      int i;
      begin
         count_leading_ones = 0;
         for (i = 31; i >= 0; i--) begin
            if (val[i] == 1'b1)
               count_leading_ones++;
            else
               break;
         end
      end
   endfunction


endmodule: ALU