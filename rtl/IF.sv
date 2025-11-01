`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Designer: Vivek Thakkar
// 
// Create Date: 27th August 2025 
// Module Name: Instruction_Fetch
// Project Name: 5Stage_Pipeline_Processor
// Target Devices: Generic FPGA
// Tool Versions: Vivado 2023.1
//
// Description: This module processes the next PC value by checking that after execution state is there any conditional branch is taking place or not,
//              If branch takes place then PC gets the effective address from the EX_MEM_ALUOut_i, if no branch then PC increases regularly and fetches instruction_code from the instruction Memory.
// 
//
//////////////////////////////////////////////////////////////////////////////////

`include "definitions_pkg.sv"    // Include once at compile time

module Instruction_Fetch (
	input  logic       clk            ,   
	input  logic       rst            ,
	input  logic       branch_taken_i ,
	input  logic [31:0]target_PC_i    ,
	output logic [31:0]IR        
);

	import definitions_pkg::*;
	
	logic [31:0] PC;
	logic [31:0] instruction_code;
	
	assign IR = instruction_code;
	
	always_ff @(posedge clk) begin 
		if (rst) begin 
			PC <= 32'b0;
		end else begin 
			if (branch_taken_i) begin 
				PC <= target_PC_i;
				PC <= PC+1'b1;
			end else begin 
				PC <= PC+1'b1;
			end
		end
	end
	
   Instruction_Mem Instruction_Mem_inst (
		.pc_address(PC), 	
		.instruction_code(instruction_code)
	);

endmodule: Instruction_Fetch

