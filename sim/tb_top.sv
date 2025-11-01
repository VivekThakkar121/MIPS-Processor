`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Designer: Vivek Thakkar
// 
// Create Date: 31th August 2025   
// Module Name: Test_Bench
// Project Name: 5Stage_Pipeline_Processor
// Target Devices: Generic FPGA
// Tool Versions: Vivado 2023.1
//
// Description: This module checks the opecode and decides the execution_type if non halted condition. This also fetch the register value by looking the source register address from the instruction code available in IF_ID_IR_i.
// 
//
//////////////////////////////////////////////////////////////////////////////////

module tb_top ();
	
	logic clk,
		   rst;
	
	Top_Module Top_Module_Inst1 (
		.clk(clk),
		.rst(rst)
	);
	
	always #4 clk = ~clk;
	
	initial begin 
		rst = 1;
		clk = 0;
		#1000;
		
		rst = 0;
	end
	
endmodule: tb_top