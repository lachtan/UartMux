
module uart_switch
	#(parameter
		DATA_BITS = 8,
		COUNTER_BITS = 16
	)
	(
		input wire clk,
		input wire reset,
		input wire usb_rx,
		output wire usb_tx
	);
	
	wire [COUNTER_BITS-1:0] baud_divisor = (66000000 / 921600) - 1;
	
	wire [DATA_BITS-1:0] data;
	
	wire can_read;
	
	wire tx_full;
	wire rx_empty;
	
	wire read_uart;
	wire write_uart;
	
	uart uart_inst
	(
		.clk(clk),
		.reset(reset),
		
		.baud_divisor(baud_divisor),
		
		.tx(usb_tx),		
		.rx(usb_rx),
		
		.rts(),
		
		.tx_full(tx_full),
		.rx_empty(rx_empty),
		
		.tx_data(data),
		.rx_data(data),
		
		.read_uart(read_uart),
		.write_uart(write_uart)
	);
	
	assign can_read = ~tx_full & ~rx_empty;
	assign read_uart = can_read;
	assign write_uart = can_read;

endmodule
