// UART TX + RX

module uart
	#(parameter 
		DATA_BITS = 8,
		COUNTER_BITS = 16,
		FIFO_ADDRESS_BITS = 4
	)
	(
		input wire clk, 
		input wire reset,

		input wire [COUNTER_BITS-1:0] baud_divisor,
		
		output wire tx,		
		input wire rx,
		
		output wire rts,

		input wire [DATA_BITS-1:0] tx_data,
		output wire [DATA_BITS-1:0] rx_data,

		input wire read, 
		input wire write, 

		output wire tx_full,
		output wire rx_empty
	);

	wire rx_done_tick;
	wire tx_done_tick;
	wire tx_empty;
	wire tx_fifo_not_empty;
	wire [DATA_BITS-1:0] tx_fifo_out; 
	wire [DATA_BITS-1:0] rx_data_out;

	uart_rx
	#(
		.DATA_BITS(DATA_BITS),
		.COUNTER_BITS(COUNTER_BITS)
	)
	uart_rx_unit
	(
		.clk(clk),
		.reset(reset),
		.rx(rx),
		.baud_divisor(baud_divisor),
		.done_tick(rx_done_tick),
		.data_out(rx_data_out)
	);

	fifo 
	#(
		.DATA_BITS(DATA_BITS),
		.ADDRESS_BITS(FIFO_ADDRESS_BITS)
	)
	fifo_rx_unit
	(
		.clk(clk),
		.reset(reset),
		.read(read),
		.write(rx_done_tick),
		.write_data(rx_data_out),
		.empty(rx_empty),
		.full(),
		.read_data(rx_data)
	);

	fifo
	#(
		.DATA_BITS(DATA_BITS), 
		.ADDRESS_BITS(FIFO_ADDRESS_BITS)
	)
	fifo_tx_unit
	(
		.clk(clk),
		.reset(reset),
		.read(tx_done_tick),
		.write(write),
		.write_data(tx_data),
		.empty(tx_empty),
		.full(tx_full),
		.read_data(tx_fifo_out)
	);

	uart_tx
	#(
		.DATA_BITS(DATA_BITS),
		.COUNTER_BITS(COUNTER_BITS)
	) 
	uart_tx_unit
	(
		.clk(clk),
		.reset(reset),
		.tx_start(tx_fifo_not_empty),
		.data_in(tx_fifo_out),
		.baud_divisor(baud_divisor),
		.tx(tx),
		.rts(rts),
		.tx_done_tick(tx_done_tick)		
	);

	assign tx_fifo_not_empty = ~tx_empty;

endmodule
