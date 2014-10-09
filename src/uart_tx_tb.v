`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   16:31:21 10/04/2014
// Design Name:   uart_tx
// Module Name:   C:/src/FPGA/MicroBoardLed/uart_tx_tb.v
// Project Name:  MicroBoardLed
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: uart_tx
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module uart_tx_tb;

	// Inputs
	reg clk;
	reg reset;
	reg tx_start;
	reg [7:0] data_in;
	reg [15:0] baud_divisor;

	// Outputs
	wire tx;
	wire rts;
	wire tx_done_tick;

	// Instantiate the Unit Under Test (UUT)
	uart_tx uut (
		.clk(clk), 
		.reset(reset), 
		.tx_start(tx_start), 
		.data_in(data_in), 
		.baud_divisor(baud_divisor), 
		.tx(tx), 
		.rts(rts),
		.tx_done_tick(tx_done_tick)
	);

	initial begin
		clk = 1'b0;
		reset = 1'b1;
		repeat(4) #10 clk = ~clk;
		reset = 1'b0;
		forever #10 clk = ~clk; // generate a clock
	end
	 
	initial begin
		tx_start = 0;
		data_in = 0;
		baud_divisor = 2;

		// Wait 100 ns for global reset to finish
		#100;
		
		data_in = 8'b10101010;
		#10;
		tx_start = 1'b1;
		#10;
		tx_start = 1'b0;
        
		// Add stimulus here
	end
      
endmodule

