`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Designer: Vivek Thakkar
// 
// Create Date: 29th August 2025 
// Module Name: Data_Memory
// Project Name: 5Stage_Pipeline_Processor
// Target Devices: Generic FPGA
// Tool Versions: Vivado 2023.1
//
// Description: 
// 
//
//////////////////////////////////////////////////////////////////////////////////



module Data_Memory (
   input   logic		   clk         ,
   input   logic 		   Wr_Enable   ,
	input   logic [31:0]	Address     ,
	input   logic [31:0] Write_Data  ,
	output  logic [31:0] Read_Data   
);
	
	logic [31:0] Data_Mem [1023:0];
	
	always_ff @(posedge clk) begin 
		if (Wr_Enable) begin 
			Data_Mem[Address]    <=  Write_Data;
		end
	end
	
	assign Read_Data = Data_Mem[Address];

endmodule : Data_Memory

   	