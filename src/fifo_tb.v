`timescale 1ns / 1ps

module fifo_tb;

	// Inputs
	reg clk;
	reg reset;
	reg read;
	reg write;
	reg [7:0] write_data;

	// Outputs
	wire empty;
	wire full;
	wire [7:0] read_data;

	// Instantiate the Unit Under Test (UUT)
	fifo  
	#(.ADDRESS_BITS(1))
	uut
	(
		.clk(clk), 
		.reset(reset), 
		.read(read), 
		.write(write), 
		.write_data(write_data), 
		.empty(empty), 
		.full(full), 
		.read_data(read_data)
	);

	initial begin
		clk = 1'b0;
		reset = 1'b1;
		repeat(4) #10 clk = ~clk;
		reset = 1'b0;
		forever #10 clk = ~clk; // generate a clock
	end
	
	initial begin
		// Initialize Inputs
		read = 0;
		write = 0;
		write_data = 0;

		// Wait 100 ns for global reset to finish
		#100;
		
		write_data = 8'h88;
		#10;
		write = 1'b1;
		#10;
		write = 1'b0;
        
		write_data = 8'h33;
		#10;
		write = 1'b1;
		#10;
		write = 1'b0;
		
		#10;
		read = 1'b1;
		#10;
		read = 1'b0;
		
		#10;
		read = 1'b1;
		#10;
		read = 1'b0;
   
	// Add stimulus here

	end
      
endmodule

