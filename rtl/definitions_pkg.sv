//////////////////////////////////////////////////////////////////////////////////
// Designer: Vivek Thakkar
// 
// Create Date: 27th August 2025 
// Package Name: definitions_pkg
// Project Name: 5Stage_Pipeline_Processor
// Target Devices: Generic FPGA
// Tool Versions: Vivado 2023.1
//
// Description: 
// This package defines opcode values, instruction types,
// and operation categories for the 5-stage pipelined MIPS32 processor.
//
//////////////////////////////////////////////////////////////////////////////////

package definitions_pkg;

   // ---------------------------------------------------------------
   // Primary Opcodes (6 bits)
   // ---------------------------------------------------------------
   localparam logic [5:0]
      OPCODE_RTYPE_SPECIAL1 = 6'b000_000,   // ADD, AND, MOVN, MOVZ, NOR, OR, DIV, SUB, SLL, SRA
      OPCODE_ADDI  			 = 6'b001_000,   // Add Immediate
      OPCODE_ANDI  			 = 6'b001_100,   // Bitwise And Immediate
      OPCODE_RTYPE_SPECIAL2 = 6'b011_100,   // CLZ, CLO
		OPCODE_MUL            = 6'b011_100,   // Multiply and store lower 32 bits
		OPCODE_ORI            = 6'b001_101,   // Immediate Bitwise OR
      OPCODE_SLTI  			 = 6'b001_010,   // Set Less Than Immediate
      OPCODE_LW    			 = 6'b100_011,   // Load Word
      OPCODE_SW    			 = 6'b101_011,   // Store Word
      OPCODE_BEQ   			 = 6'b000_100,   // Branch if Equal 
      OPCODE_BNE   			 = 6'b000_101,   // Branch if Not Equal 
		OPCODE_J              = 6'b000_010,   // Jump

   // ---------------------------------------------------------------
   // Function Codes (for R-Type Instructions) - Secondary Opcode
   // ---------------------------------------------------------------
   localparam logic [5:0]
      FUNCT_ADD  = 6'b100_000,
      FUNCT_AND  = 6'b100_100,
      FUNCT_MOVN = 6'b001_011,
      FUNCT_MOVZ = 6'b001_010,
      FUNCT_NOR  = 6'b100_111,
      FUNCT_OR   = 6'b100_101,
      FUNCT_DIV  = 6'b011_010,		
      FUNCT_SUB  = 6'b100_010,
      FUNCT_SLL  = 6'b000_000,
      FUNCT_SRA  = 6'b000_011,
		
		FUNCT_CLO  = 6'b100_001,              // R-Type SPECIAL 2
      FUNCT_CLZ  = 6'b100_000;              // R-Type SPECIAL 2

   // ---------------------------------------------------------------
   // Operation Type Encoding (for Control Unit)
   // ---------------------------------------------------------------
   localparam logic [2:0]
      OP_RRTYPE1 = 3'b001,   // Register-Register ALU Operations with having 2 source registers(Rs, Rt)
		OP_RRTYPE2 = 3'b010,   // REgister-Register ALU operations with having only 1 source register(Rs)
      OP_IRTYPE  = 3'b011,   // Immediate ALU Operations (ADDI, SUBI, etc.)
      OP_LOAD    = 3'b100,   // Load Word
      OP_STORE   = 3'b101,   // Store Word
      OP_BRANCH  = 3'b110,   // Branch Instructions
      OP_HALT    = 3'b111;   // Halt Operation

endpackage : definitions_pkg
