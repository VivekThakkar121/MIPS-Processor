`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Designer: Vivek Thakkar
// 
// Create Date: 30th August 2025 
// Module Name: Top_Module
// Project Name: 5Stage_Pipeline_Processor
// Target Devices: Generic FPGA
// Tool Versions: Vivado 2023.1
//
// Description: This module checks the opecode and decides the execution_type if non halted condition. This also fetch the register value by looking the source register address from the instruction code available in IF_ID_IR_i.
// 
//
//////////////////////////////////////////////////////////////////////////////////

`include "definitions_pkg.sv"    

module Top_Module (
	input logic clk,
	input logic rst
);
	// connections between Instruction_Fetch and Instruction_Decode_Operand_Fetching
	logic [31:0] IF_ID_IR, 
					 IF_ID_NPC;

	// connections between Instruction_Fetch and Execution
	logic [31:0] EX_MEM_IR, 
					 EX_MEM_ALUOut;
	logic        EX_MEM_cond;
	
	// Connection between Instruction_Decode_Operand_Fetching and Execution
	logic [31:0] ID_EX_IR, 
					 ID_EX_NPC,
					 ID_EX_A,
					 ID_EX_B,
					 ID_EX_Imm32bit;
	logic [2:0]  ID_EX_Type;
	
	// connections between Execution and MEM_Access
	logic [31:0] EX_MEM_B;
	logic [2:0]  EX_MEM_Type;
	
	// connections between MEM_Access and Write_Back
	logic [31:0] MEM_WB_IR,
					 MEM_WB_ALUOut,
					 MEM_WB_LMD;
	logic [2:0]  MEM_WB_Type;
	
	// connections between Write_Back and Register_Bank
	logic [31:0] Wr_Data;
	logic [4:0]  Wr_Address;
	logic        Wr_Enable;
	
	logic        halted_flag;
	logic        taken_branch;
	logic [31:0] data_A, data_B;
	
	Register_Bank Register_Bank_Inst0 (
		.Wr_Data_i(Wr_Data), 
		.Sr1_i(IF_ID_IR[25:21]), 
		.Sr2_i(IF_ID_IR[20:16]), 
		.Dr_i(Wr_Address), 
		.clk(clk), 
		.rst(rst), 
		.Wr_Enable_i(Wr_Enable), 
		.Rd_Data1_o(data_A), 
		.Rd_Data2_o(data_B)
	);	
	
	Instruction_Fetch Instruction_Fetch_Inst1 (
		.EX_MEM_IR_i(EX_MEM_IR),
		.EX_MEM_cond_i(EX_MEM_cond),
		.EX_MEM_ALUOut_i(EX_MEM_ALUOut),
		.clk(clk),
		.rst(rst),
		.halted_flag_i(halted_flag),
		.IF_ID_IR_o(IF_ID_IR),
		.IF_ID_NPC_o(IF_ID_NPC),
		.taken_branch_o(taken_branch)
	);
	
	Instruction_Decode_Operand_Fetching Instruction_Decode_Operand_Fetching_Inst1 (
		.clk(clk),
		.rst(rst),
		.halted_flag_i(halted_flag),
		.IF_ID_IR_i(IF_ID_IR),
		.IF_ID_NPC_i(IF_ID_NPC),
		.data_A_i(data_A),
		.data_B_i(data_B),
		.ID_EX_IR_o(ID_EX_IR),
		.ID_EX_NPC_o(ID_EX_NPC),
		.ID_EX_A_o(ID_EX_A),
		.ID_EX_B_o(ID_EX_B),
		.ID_EX_Imm32bit_o(ID_EX_Imm32bit),
		.ID_EX_Type_o(ID_EX_Type)
	);

   Execution Execution_Inst1 (
		.clk(clk),
		.halted_flag_i(halted_flag),
		.rst(rst),
		.ID_EX_Type_i(ID_EX_Type),
		.ID_EX_IR_i(ID_EX_IR),
		.ID_EX_A_i(ID_EX_A),
		.ID_EX_B_i(ID_EX_B),
		.ID_EX_Imm32bit_i(ID_EX_Imm32bit),
		.ID_EX_NPC_i(ID_EX_NPC),
		.EX_MEM_IR_o(EX_MEM_IR),
		.EX_MEM_Type_o(EX_MEM_Type),
		.EX_MEM_B_o(EX_MEM_B),
		.EX_MEM_cond_o(EX_MEM_cond),
		.EX_MEM_ALUOut_o(EX_MEM_ALUOut)
	);

   MEM_Access MEM_Access_Inst1 (
		.clk(clk),
		.rst(rst),
		.EX_MEM_Type_i(EX_MEM_Type),
		.EX_MEM_IR_i(EX_MEM_IR),
		.EX_MEM_ALUOut_i(EX_MEM_ALUOut),
		.EX_MEM_B_i(EX_MEM_B),
		.halted_flag_i(halted_flag),
		.MEM_WB_Type_o(MEM_WB_Type),
		.MEM_WB_IR_o(MEM_WB_IR),
		.MEM_WB_ALUOut_o(MEM_WB_ALUOut),
		.MEM_WB_LMD_o(MEM_WB_LMD)
	);

	Write_Back Write_Back_Inst1 (
		.clk(clk),
		.rst(rst),
		.taken_branch_i(taken_branch),
		.MEM_WB_IR_i(MEM_WB_IR),
		.MEM_WB_Type_i(MEM_WB_Type),
		.MEM_WB_ALUOut_i(MEM_WB_ALUOut),
		.MEM_WB_LMD_i(MEM_WB_LMD),
		.halted_flag_o(halted_flag),
		.Wr_Enable_o(Wr_Enable),
		.Wr_Data_o(Wr_Data),
		.Wr_Address_o(Wr_Address)
	);
   


endmodule: Top_Module