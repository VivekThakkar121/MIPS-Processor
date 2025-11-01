`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Designer: Vivek Thakkar
// 
// Create Date: 27th August 2025 
// Module Name: Instruction_Mem
// Project Name: 5Stage_Pipeline_Processor
// Target Devices: Generic FPGA
// Tool Versions: Vivado 2023.1
//
// Description: 
// This module loads instruction words from an external memory file (rom_data.mem).
// The memory is a 1024 x 32-bit ROM, inferred as block memory. The input program 
// counter (PC) is word-addressed and increments by 1 for each instruction. 
// The ROM is also word-addressed.
//
//////////////////////////////////////////////////////////////////////////////////



module Instruction_Mem (
   input  logic   [31:0]  pc_address,
   output logic   [31:0]  instruction_code
);

   // ROM: 1024 x 32-bit
   (* rom_style = "block" *) logic [31:0] Instruction_Mem_ROM [0:1023];

   // Instruction fetch (synchronous read)
   //always_comb begin
   //   instruction_code = Inst_Mem_ROM[pc_address];
   //end
	
	always_ff @(posedge clk) begin 
		if (rst) begin 
			instruction_code <= 32'b0;
		end else begin 
			instruction_code <= Instruction_Mem_ROM[pc_address];
		end
	end


   // Initialize ROM from external file
   initial begin
      $readmemb("rom_data.mem", Instruction_Mem_ROM); 
      // Use binary (.mem) or switch to $readmemh for hex
   end

endmodule : Instruction_Mem

   	