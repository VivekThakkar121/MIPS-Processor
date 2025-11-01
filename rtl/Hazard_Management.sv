`include "definitions_pkg.sv"


module Hazard_Management(
	input  logic 		  branch_taken_i,
	input  logic [31:0] target_branch_address_i,
	input  logic [31:0] IR_IF_i,      // from the registers between IF/ID pipeline(N+1,th instruction)
	input  logic [2:0]  OP_type_IF_i, // It states the type of operation for N+1th instruction    
   input  logic [31:0] IR_ID_i     , // from the registers between ID/EXE pipeline(N,th instruction) 
	input  logic [2:0]  OP_type_ID_i, // It states the type of operation for Nth instruction
	output logic        LoadUse_DH_o, // This signal is high if Load use data hazard is detected(So that we can forward operand from MA stage)
	output logic        ALU_ALU_DH_o, // This signal is high if ALU ALU data hazard is detected(So that we can forward operand from EXE stage)
	output logic [1:0]  OperandForward_o, // It decides which operand that ALU have to use(Rs or Rt), 01: Use forwarded result instead of Rs, 11: Use forwarded result instead of Rs and Rt 
	output logic [31:0] target_branch_address_o,
	output logic 		  flush_o
);
	import definitions_pkg::*;

	assign flush_o 					 = branch_taken_i;
   assign target_branch_address_o = target_branch_address_i;
	
	// Logic for detecting a ALU_ALU RAW Data Hazard
	always_comb begin 
		ALU_ALU_DH_o      = 1'b0;
		OperandForward_o  = 2'b0;
		LoadUse_DH_o      = 1'b0;
		if ((OP_type_ID_i == OP_RRTYPE1) || (OP_type_ID_i == OP_RRTYPE2)) begin 
			if (((OP_type_IF_i == OP_RRTYPE1) && (IR_IF_i[5:0] != FUNCT_SLL) && (IR_IF_i[5:0] != FUNCT_SRA)) || (OP_type_IF_i == OP_IRTYPE) || (OP_type_IF_i == OP_LOAD) || (OP_type_IF_i == OP_STORE) || (OP_type_IF_i == OP_BRANCH)) begin 
				if ((IR_ID_i[15:11] == IR_IF_i[25:21]) && (IR_ID_i[15:11] == IR_IF_i[20:16])) begin 
					ALU_ALU_DH_o     = 1'b1;
					OperandForward_o = 2'b11;  //Address(Rd = Rs = Rt)
				end else if (IR_ID_i[15:11] == IR_IF_i[25:21]) begin 
					ALU_ALU_DH_o     = 1'b1;
					OperandForward_o = 2'b01;  //Address(Rd = Rs)
				end else if (IR_ID_i[15:11] == IR_IF_i[20:16]) begin 
					ALU_ALU_DH_o     = 1'b1;
					OperandForward_o = 2'b10;  //Address(Rd = Rs)
				end else begin 
					ALU_ALU_DH_o     = 1'b0;
					OperandForward_o = 2'b00;
				end
			end else if ((IR_IF_i[5:0] == FUNCT_SLL) || (IR_IF_i[5:0] == FUNCT_SRA)) begin   //Only check Rt
			   if (IR_ID_i[15:11] == IR_IF_i[20:16]) begin 
					ALU_ALU_DH_o     = 1'b1;
					OperandForward_o = 2'b10;  //Address(Rd = Rt)
				end else begin 
				   ALU_ALU_DH_o     = 1'b0;
					OperandForward_o = 2'b00;
				end
			end else if (OP_type_IF_i == OP_RRTYPE2) begin   //Only check Rs
				if (IR_ID_i[15:11] == IR_IF_i[25:21]) begin 
					ALU_ALU_DH_o     = 1'b1;
					OperandForward_o = 2'b01;  //Address(Rd = Rs)
				end else begin 
				   ALU_ALU_DH_o     = 1'b0;
					OperandForward_o = 2'b00;
				end
			end else begin 
				ALU_ALU_DH_o     = 1'b0;
				OperandForward_o = 2'b00;
			end
		end else if (OP_type_ID_i == OP_IRTYPE) begin 
			if (((OP_type_IF_i == OP_RRTYPE1) && (IR_IF_i[5:0] != FUNCT_SLL) && (IR_IF_i[5:0] != FUNCT_SRA)) || (OP_type_IF_i == OP_IRTYPE) || (OP_type_IF_i == OP_LOAD) || (OP_type_IF_i == OP_STORE) || (OP_type_IF_i == OP_BRANCH)) begin 
				if ((IR_ID_i[15:11] == IR_IF_i[25:21]) && (IR_ID_i[15:11] == IR_IF_i[20:16])) begin 
					ALU_ALU_DH_o     = 1'b1;
					OperandForward_o = 2'b11;  //Address(Rd = Rs = Rt)
				end else if (IR_ID_i[15:11] == IR_IF_i[25:21]) begin 
					ALU_ALU_DH_o     = 1'b1;
					OperandForward_o = 2'b01;  //Address(Rd = Rs)
				end else if (IR_ID_i[15:11] == IR_IF_i[20:16]) begin 
					ALU_ALU_DH_o     = 1'b1;
					OperandForward_o = 2'b10;  //Address(Rd = Rs)
				end else begin 
					ALU_ALU_DH_o     = 1'b0;
					OperandForward_o = 2'b00;
				end
			end else if ((IR_IF_i[5:0] == FUNCT_SLL) || (IR_IF_i[5:0] == FUNCT_SRA)) begin   //Only check Rt
			   if (IR_ID_i[15:11] == IR_IF_i[20:16]) begin 
					ALU_ALU_DH_o     = 1'b1;
					OperandForward_o = 2'b10;  //Address(Rd = Rt)
				end else begin 
				   ALU_ALU_DH_o     = 1'b0;
					OperandForward_o = 2'b00;
				end
			end else if (OP_type_IF_i == OP_RRTYPE2) begin   //Only check Rs
				if (IR_ID_i[15:11] == IR_IF_i[25:21]) begin 
					ALU_ALU_DH_o     = 1'b1;
					OperandForward_o = 2'b01;  //Address(Rd = Rs)
				end else begin 
				   ALU_ALU_DH_o     = 1'b0;
					OperandForward_o = 2'b00;
				end
			end else begin 
				ALU_ALU_DH_o     = 1'b0;
				OperandForward_o = 2'b00;
			end
		end else if (OP_type_ID_i == OP_LOAD) begin 
			if (((OP_type_IF_i == OP_RRTYPE1) && (IR_IF_i[5:0] != FUNCT_SLL) && (IR_IF_i[5:0] != FUNCT_SRA)) || (OP_type_IF_i == OP_IRTYPE) || (OP_type_IF_i == OP_LOAD) || (OP_type_IF_i == OP_STORE) || (OP_type_IF_i == OP_BRANCH)) begin 
				if ((IR_ID_i[15:11] == IR_IF_i[25:21]) && (IR_ID_i[15:11] == IR_IF_i[25:21])) begin 
					LoadUse_DH_o     = 1'b1;
					OperandForward_o = 2'b11;  //Address(Rd = Rs = Rt)
				end else if (IR_ID_i[15:11] == IR_IF_i[25:21]) begin 
					LoadUse_DH_o     = 1'b1;
					OperandForward_o = 2'b01;  //Address(Rd = Rs)
				end else if (IR_ID_i[15:11] == IR_IF_i[20:16]) begin 
					LoadUse_DH_o     = 1'b1;
					OperandForward_o = 2'b10;  //Address(Rd = Rs)
				end else begin 
					LoadUse_DH_o     = 1'b0;
					OperandForward_o = 2'b00;
				end
			end else if ((IR_IF_i[5:0] == FUNCT_SLL) || (IR_IF_i[5:0] == FUNCT_SRA)) begin   //Only check Rt
			   if (IR_ID_i[15:11] == IR_IF_i[20:16]) begin 
					LoadUse_DH_o     = 1'b1;
					OperandForward_o = 2'b10;  //Address(Rd = Rt)
				end else begin 
				   LoadUse_DH_o     = 1'b0;
					OperandForward_o = 2'b00;
				end
			end else if (OP_type_IF_i == OP_RRTYPE2) begin   //Only check Rs
				if (IR_ID_i[15:11] == IR_IF_i[25:21]) begin 
					LoadUse_DH_o     = 1'b1;
					OperandForward_o = 2'b01;  //Address(Rd = Rs)
				end else begin 
				   LoadUse_DH_o     = 1'b0;
					OperandForward_o = 2'b00;
				end
			end else begin 
				LoadUse_DH_o     = 1'b0;
				OperandForward_o = 2'b00;
			end
		end else if (OP_type_ID_i == OP_IRTYPE) begin 
			if (((OP_type_IF_i == OP_RRTYPE1) && (IR_IF_i[5:0] != FUNCT_SLL) && (IR_IF_i[5:0] != FUNCT_SRA)) || (OP_type_IF_i == OP_IRTYPE) || (OP_type_IF_i == OP_LOAD) || (OP_type_IF_i == OP_STORE) || (OP_type_IF_i == OP_BRANCH)) begin 
				if ((IR_ID_i[15:11] == IR_IF_i[25:21]) && (IR_ID_i[15:11] == IR_IF_i[25:21])) begin 
					LoadUse_DH_o     = 1'b1;
					OperandForward_o = 2'b11;  //Address(Rd = Rs = Rt)
				end else if (IR_ID_i[15:11] == IR_IF_i[25:21]) begin 
					LoadUse_DH_o     = 1'b1;
					OperandForward_o = 2'b01;  //Address(Rd = Rs)
				end else if (IR_ID_i[15:11] == IR_IF_i[20:16]) begin 
					LoadUse_DH_o     = 1'b1;
					OperandForward_o = 2'b10;  //Address(Rd = Rs)
				end else begin 
					LoadUse_DH_o     = 1'b0;
					OperandForward_o = 2'b00;
				end
			end else if ((IR_IF_i[5:0] == FUNCT_SLL) || (IR_IF_i[5:0] == FUNCT_SRA)) begin   //Only check Rt
			   if (IR_ID_i[15:11] == IR_IF_i[20:16]) begin 
					LoadUse_DH_o     = 1'b1;
					OperandForward_o = 2'b10;  //Address(Rd = Rt)
				end else begin 
				   LoadUse_DH_o     = 1'b0;
					OperandForward_o = 2'b00;
				end
			end else if (OP_type_IF_i == OP_RRTYPE2) begin   //Only check Rs
				if (IR_ID_i[15:11] == IR_IF_i[25:21]) begin 
					LoadUse_DH_o     = 1'b1;
					OperandForward_o = 2'b01;  //Address(Rd = Rs)
				end else begin 
				   LoadUse_DH_o     = 1'b0;
					OperandForward_o = 2'b00;
				end
			end else begin 
				LoadUse_DH_o     = 1'b0;
				OperandForward_o = 2'b00;
			end
		end else begin 
			LoadUse_DH_o        = 1'b0;
			ALU_ALU_DH_o        = 1'b0;
			OperandForward_o    = 2'b0;
		end
	end

endmodule: Hazard_Management

