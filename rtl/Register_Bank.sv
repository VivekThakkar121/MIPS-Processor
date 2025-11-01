`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Designer: Vivek Thakkar
// 
// Create Date: 27th August 2025 
// Module Name: Register_Bank
// Project Name: 5Stage_Pipeline_Processor
// Target Devices: Generic FPGA
// Tool Versions: Vivado 2023.1
//
// Description: We have 4 General purpose registers R0, R1, R2 and R3 and each have 2 bit address starting from 00 to 11. We have 2 reading ports and 1 writing port.
//              We have addresses of source1, source2 and destination register, which tells us to operate on which register. If Wr_Enable_i is active then we write the data into the register.              
// 
//
//////////////////////////////////////////////////////////////////////////////////


module Register_Bank (                    // 2 Read port and 1 write port
	input  logic         clk                ,
	input  logic         rst                ,
	input  logic  [31:0] Wr_Data_i          ,      // Writing 32 bit data using Wr_Data port
	input  logic         Wr_Enable_i        ,	
	input  logic  [4:0]  write_port_Addr_i  ,	
	input  logic  [4:0]  read_port1_Addr_i  ,      // Add Rd, Rs1, Rs2. Addresses of all three registers
	input  logic  [4:0]  read_port2_Addr_i  ,
   output logic  [31:0] Read_Data1_o       ,      // Reading 32 bits from the read_port 1
   output logic  [31:0] Read_Data2_o		           // Reading 32 bits from the read_port 2
);
	
	logic [31:0] Registers [31:0];           
	integer k;
	

	
	always_ff @(posedge clk) begin 
		if (rst) begin
			for (k=0; k< 32; k++) begin 
			   Registers[k] <= 'b0;
		   end		
		end else if (Wr_Enable_i && (write_port_Addr_i != 5'b0)) begin 
			Registers[write_port_Addr_i] <= Wr_Data_i; 
		end 
	end 
	
	always_ff @(posedge clk) begin 
		if (rst) begin 
			Read_Data1_o    <= 32'b0;
			Read_Data2_o    <= 32'b0;
		end else begin 
			Read_Data1_o    <= Registers[read_port1_Addr_i];
			Read_Data2_o    <= Registers[read_port2_Addr_i];
		end
	end
	
endmodule: Register_Bank