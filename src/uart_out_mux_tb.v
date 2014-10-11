`timescale 1ns / 1ps

module uart_out_mux_tb;

	// Inputs
	reg clk;
	reg reset;
	
	reg [7:0] fifo_write_data;
	reg fifo_write;
	
	wire fifo_read;
	wire fifo_empty;
	wire fifo_full;
	wire [7:0] fifo_read_data;
	
	wire read;
	wire [7:0] data;

	fifo fifo_inst
	(
		.clk(clk), 
		.reset(reset), 
		.read(fifo_read),
		.write(fifo_write),
		.write_data(fifo_write_data),
		.empty(fifo_empty),
		.full(fifo_full),
		.read_data(fifo_read_data)
	);
	
	// Instantiate the Unit Under Test (UUT)
	uart_out_mux 
	#(.UART_COUNT(1))
	uut (
		.clk(clk), 
		.reset(reset), 
		.fifo_empty(fifo_empty), 
		.fifo_read(fifo_read), 
		.fifo_data(fifo_read_data), 
		.write(write), 
		.data(data)
	);

	initial begin
		clk = 1'b0;
		reset = 1'b1;
		repeat(4) #10 clk = ~clk;
		reset = 1'b0;
		forever #10 clk = ~clk; // generate a clock
	end

	initial begin
		// Wait 100 ns for global reset to finish
		fifo_write_data = 0;
		fifo_write = 0;
		#100;
        
		fifo_write_data = 0;
		#10;
		fifo_write = 1'b1;
		#10
		fifo_write = 1'b0;
		
		#100;
		
		fifo_write_data = 8'h88;
		#10;
		fifo_write = 1'b1;
		#10
		fifo_write = 1'b0;
	end

endmodule
