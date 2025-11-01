`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Designer: Vivek Thakkar
// 
// Create Date: 28th August 2025 
// Module Name: Instruction_Decode_Operand_Fetching
// Project Name: 5Stage_Pipeline_Processor
// Target Devices: Generic FPGA
// Tool Versions: Vivado 2023.1
//
// Description: This module checks the opecode and decides the execution_type if non halted condition. This also fetch the register value by looking the source register address from the instruction code available in IF_ID_IR_i.
// 
//
//////////////////////////////////////////////////////////////////////////////////

`include "definitions_pkg.sv"    // Include once at compile time

module ID_OP(
	input  logic        clk              ,
   input  logic        rst              ,
	input  logic        flush            ,
	input  logic [31:0] IR               ,
	input  logic [31:0] RB_data1_i       ,        //Operand Fetched from the Register bank
	input  logic [31:0] RB_data2_i       ,        //Operand Fetched from the Register bank
	output logic [31:0] operand1_o       ,
	output logic [31:0] operand2_o       ,
	output logic [4:0]  Rs_addr_o        ,
	output logic [4:0]  Rt_addr_o 		 ,
	output logic [2:0]  OP_type_ID_o     ,        //Operation type of given instruction
   output logic [2:0]  OP_type_IF_o     ,
	output logic [31:0] IR_ID_o	 
);

	import definitions_pkg::*;	
	
	
	assign Rs_addr_o   = IR[25:21] ;
	assign Rt_addr_o   = IR[20:16] ;	
	assign operand1_o  = RB_data1_i;
	assign operand2_o  = RB_data2_i;
	
	always_comb begin 
		OP_type_IF_o = 3'b000; 															//	None of the instruction is valid
		case (IR[31:26]) 
			OPCODE_RTYPE_SPECIAL1, OPCODE_MUL                : OP_type_IF_o = OP_RRTYPE1;
			OPCODE_RTYPE_SPECIAL2                            : OP_type_IF_o = OP_RRTYPE2;
			OPCODE_ADDI, OPCODE_ANDI, OPCODE_ORI, OPCODE_SLTI: OP_type_IF_o = OP_IRTYPE;
			OPCODE_LW                                        : OP_type_IF_o = OP_LOAD;
			OPCODE_SW                                        : OP_type_IF_o = OP_STORE;
			OPCODE_BEQ, OPCODE_BNE, OPCODE_J                 : OP_type_IF_o = OP_BRANCH;
			default                                          : OP_type_IF_o = 3'b000;
		endcase :
	end
		
	always_ff @(posedge clk) begin 
	   if (rst | flush) begin 
			IR_ID_o       <= 32'b0;
			OP_type_ID_o  <= 3'b0;
		end else begin
			IR_ID_o       <= IR;
			OP_type_ID_o  <= OP_type_IF_o;
      end		
	end 


endmodule: ID_OP