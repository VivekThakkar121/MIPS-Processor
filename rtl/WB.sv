`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Designer: Vivek Thakkar
// 
// Create Date: 30th August 2025 
// Module Name: Write_Back
// Project Name: 5Stage_Pipeline_Processor
// Target Devices: Generic FPGA
// Tool Versions: Vivado 2023.1
//
// Description: This module checks the opecode and decides the execution_type if non halted condition. This also fetch the register value by looking the source register address from the instruction code available in IF_ID_IR_i.
// 
//
//////////////////////////////////////////////////////////////////////////////////

`include "definitions_pkg.sv"    // Include once at compile time

module Write_Back (
	input   logic        clk                     ,
	input   logic        rst                     ,
	input   logic        taken_branch_i          ,
	input   logic [31:0] MEM_WB_IR_i  				,
	input   logic [2:0]  MEM_WB_Type_i				,
   input   logic [31:0] MEM_WB_ALUOut_i         ,
	input   logic [31:0] MEM_WB_LMD_i            ,
	output  logic        halted_flag_o           ,
	output  logic        Wr_Enable_o             ,
	output  logic [31:0] Wr_Data_o               ,
	output  logic [4:0]  Wr_Address_o               
);
	
	import definitions_pkg::*;
	
	always_comb begin 
		Wr_Enable_o    =  1'b0;
		Wr_Data_o      =  32'hDEADBEEF;
		Wr_Address_o   =  5'b0;
		if (!taken_branch_i) begin 
			case (MEM_WB_Type_i) 
				RR_ALU: begin 
					Wr_Enable_o    =  1'b1;
					Wr_Address_o   =  MEM_WB_IR_i[15:11];
					Wr_Data_o      =  MEM_WB_ALUOut_i;
				end
				
				RM_ALU: begin 
					Wr_Enable_o    =  1'b1;
					Wr_Address_o   =  MEM_WB_IR_i[20:16];
					Wr_Data_o      =  MEM_WB_ALUOut_i;
				end
				
				LOAD: begin 
					Wr_Enable_o    =  1'b1;
					Wr_Address_o   =  MEM_WB_IR_i[20:16];
					Wr_Data_o      =  MEM_WB_LMD_i;
				end
				
				default: begin 
					Wr_Enable_o    =  1'b0;
					Wr_Address_o   =  5'b0;
					Wr_Data_o      =  32'hDEADBEEF;
				end
			endcase
		end else begin 
			Wr_Enable_o    =  1'b0;
		   Wr_Data_o      =  32'hDEADBEEF;
		   Wr_Address_o   =  5'b0;
		end	
	end
	
	always_ff @(posedge clk or posedge rst) begin
      if (rst) begin
         halted_flag_o <= 1'b0;
      end else if (!taken_branch_i && MEM_WB_Type_i == HALT_OP) begin
         halted_flag_o <= 1'b1;
      end
   end
	

endmodule: Write_Back