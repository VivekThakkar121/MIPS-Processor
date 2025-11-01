`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Designer: Vivek Thakkar
// 
// Create Date: 29th August 2025 
// Module Name: Mem_Access
// Project Name: 5Stage_Pipeline_Processor
// Target Devices: Generic FPGA
// Tool Versions: Vivado 2023.1
//
// Description: This module checks the opecode and decides the execution_type if non halted condition. This also fetch the register value by looking the source register address from the instruction code available in IF_ID_IR_i.
// 
//
//////////////////////////////////////////////////////////////////////////////////

`include "definitions_pkg.sv"    // Include once at compile time

module MEM_Access (
   input  logic         clk,
   input  logic         rst,

   // Inputs from EX stage
   input  logic [2:0]   EX_MEM_Type_i,    // Instruction type (e.g., LOAD, STORE)
   input  logic [31:0]  EX_MEM_IR_i,      // Instruction register
   input  logic [31:0]  EX_MEM_ALUOut_i,  // ALU output (address)
   input  logic [31:0]  EX_MEM_B_i,       // Data to write
   input  logic         halted_flag_i,   // Branch control

   // Outputs to WB stage
   output logic [2:0]   MEM_WB_Type_o,
   output logic [31:0]  MEM_WB_IR_o,
   output logic [31:0]  MEM_WB_ALUOut_o,
   output logic [31:0]  MEM_WB_LMD_o      // Loaded memory data
);

	import definitions_pkg::*;
	
   // Internal signals
   logic         wr_en_comb;     // Combinational write enable
   logic [31:0]  wr_data_comb;   // Combinational write data
   logic [31:0]  rd_data;        // Data read from memory

   // ============================
   // Combinational Logic for Mem Control
   // ============================
   always_comb begin
      wr_en_comb   = 1'b0;
      wr_data_comb = '0;

      case (EX_MEM_Type_i)
         STORE: begin
            if (!halted_flag_i) begin
               wr_en_comb   = 1'b1;          // Enable write
               wr_data_comb = EX_MEM_B_i;    // Data to write
            end
         end
         default: begin
            wr_en_comb   = 1'b0;
            wr_data_comb = '0;
         end
      endcase
   end

   // ============================
   // Instantiate Data Memory
   // ============================
   Data_Memory data_mem_inst (
      .clk        (clk),
      .Wr_Enable  (wr_en_comb),
      .Address    (EX_MEM_ALUOut_i), // ALU output as address
      .Write_Data (wr_data_comb),
      .Read_Data  (rd_data)
   );

   // ============================
   // Sequential Logic for Pipeline Registers
   // ============================
   always_ff @(posedge clk) begin
      if (rst) begin
         MEM_WB_Type_o    <= '0;
         MEM_WB_IR_o      <= '0;
         MEM_WB_ALUOut_o  <= '0;
         MEM_WB_LMD_o     <= '0;
      end else begin
		   if (!halted_flag_i) begin
				MEM_WB_Type_o    <= EX_MEM_Type_i;
				MEM_WB_IR_o      <= EX_MEM_IR_i;
				MEM_WB_ALUOut_o  <= EX_MEM_ALUOut_i;
	
				// Load memory data only for LOAD instructions
				if (EX_MEM_Type_i == LOAD) begin
					MEM_WB_LMD_o <= rd_data;
				end	 
         end 
		end
   end

endmodule: MEM_Access
