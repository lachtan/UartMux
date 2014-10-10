`timescale 1 ns / 1 ps

module uart_mux_top
	(
		input wire CLK_66MHZ,
		input wire USER_RESET,
		
		output wire [3:0] LED,
		
		input wire USB_RS232_RXD,
		output wire USB_RS232_TXD,
		
		output wire UART0_TX,
		output wire UART0_RTS,
		input wire UART0_RX,
		
		output wire UART1_TX,
		output wire UART1_RTS,
		input wire UART1_RX,

		output wire UART2_TX,
		output wire UART2_RTS,
		input wire UART2_RX,

		output wire UART3_TX,
		output wire UART3_RTS,
		input wire UART3_RX
	);
	
	localparam DATA_BITS = 8;
	localparam COUNTER_BITS = 16;
	localparam UART_COUNT = 4;
	
	localparam [15:0] USB_DIVISOR = 66000000 / 921600;
	localparam [15:0] UART_DIVISOR = 66000000 / 115200;

	wire clk;
	wire reset;
		
	assign reset = USER_RESET;	
	
	BUFG BUFG_inst
	(
		.I(CLK_66MHZ),
		.O(clk)
	);
	
	wire uart_usb_tx_full;
	wire uart_usb_rx_empty;
	wire [DATA_BITS-1:0] uart_usb_tx_data;
	wire [DATA_BITS-1:0] uart_usb_rx_data;
	wire usb_uart_read;
	wire usb_uart_write;
		
	uart
	#(
		.DATA_BITS(DATA_BITS),
		.COUNTER_BITS(COUNTER_BITS)
	)
	uart_usb_inst
	(
		.clk(clk),
		.reset(reset),		
		.baud_divisor(USB_DIVISOR),
		.tx(USB_RS232_TXD),
		.rx(USB_RS232_RXD),
		.rts(),
		.tx_full(uart_usb_tx_full),
		.rx_empty(uart_usb_rx_empty),
		.tx_data(uart_usb_tx_data),
		.rx_data(uart_usb_rx_data),		
		.read(uart_usb_read),
		.write(uart_usb_write)
	);
	
	wire uart0_tx_full;
	wire uart0_rx_empty;
	wire [DATA_BITS-1:0] uart0_tx_data;
	wire [DATA_BITS-1:0] uart0_rx_data;
	wire uart0_read;
	wire uart0_write;

	uart
	#(
		.DATA_BITS(DATA_BITS),
		.COUNTER_BITS(COUNTER_BITS)
	)
	uart0_inst
	(
		.clk(clk),
		.reset(reset),		
		.baud_divisor(UART_DIVISOR),
		.tx(UART0_TX),
		.rx(UART0_RX),
		.rts(UART0_RTS),
		.tx_full(uart0_tx_full),
		.rx_empty(uart0_rx_empty),		
		.tx_data(uart0_tx_data),
		.rx_data(uart0_rx_data),		
		.read(uart0_read),
		.write(uart0_write)
	);

	wire uart1_tx_full;
	wire uart1_rx_empty;
	wire [DATA_BITS-1:0] uart1_tx_data;
	wire [DATA_BITS-1:0] uart1_rx_data;
	wire uart1_read;
	wire uart1_write;

	uart
	#(
		.DATA_BITS(DATA_BITS),
		.COUNTER_BITS(COUNTER_BITS)
	)
	uart1_inst
	(
		.clk(clk),
		.reset(reset),		
		.baud_divisor(UART_DIVISOR),
		.tx(UART1_TX),
		.rx(UART1_RX),
		.rts(UART1_RTS),
		.tx_full(uart1_tx_full),
		.rx_empty(uart1_rx_empty),		
		.tx_data(uart1_tx_data),
		.rx_data(uart1_rx_data),		
		.read(uart1_read),
		.write(uart1_write)
	);
	
	wire uart2_tx_full;
	wire uart2_rx_empty;
	wire [DATA_BITS-1:0] uart2_tx_data;
	wire [DATA_BITS-1:0] uart2_rx_data;
	wire uart2_read;
	wire uart2_write;

	uart
	#(
		.DATA_BITS(DATA_BITS),
		.COUNTER_BITS(COUNTER_BITS)
	)
	uart2_inst
	(
		.clk(clk),
		.reset(reset),		
		.baud_divisor(UART_DIVISOR),
		.tx(UART2_TX),
		.rx(UART2_RX),
		.rts(UART2_RTS),
		.tx_full(uart2_tx_full),
		.rx_empty(uart2_rx_empty),		
		.tx_data(uart2_tx_data),
		.rx_data(uart2_rx_data),		
		.read(uart2_read),
		.write(uart2_write)
	);

	wire uart3_tx_full;
	wire uart3_rx_empty;
	wire [DATA_BITS-1:0] uart3_tx_data;
	wire [DATA_BITS-1:0] uart3_rx_data;
	wire uart3_read;
	wire uart3_write;

	uart
	#(
		.DATA_BITS(DATA_BITS),
		.COUNTER_BITS(COUNTER_BITS)
	)
	uart3_inst
	(
		.clk(clk),
		.reset(reset),		
		.baud_divisor(UART_DIVISOR),
		.tx(UART3_TX),
		.rx(UART3_RX),
		.rts(UART3_RTS),
		.tx_full(uart3_tx_full),
		.rx_empty(uart3_rx_empty),		
		.tx_data(uart3_tx_data),
		.rx_data(uart3_rx_data),		
		.read(uart3_read),
		.write(uart3_write)
	);

	uart_in_mux
	#(
		.DATA_BITS(DATA_BITS),
		.COUNTER_BITS(COUNTER_BITS),
		.UART_COUNT(UART_COUNT)
	)
	uart_in_mux_inst
	(
		.clk(clk),
		.reset(reset),		
		.fifo_full(uart_usb_tx_full),
		.fifo_write(uart_usb_write),
		.fifo_data(uart_usb_tx_data),
		
		.read({uart3_read, uart2_read, uart1_read, uart0_read}),
		.empty({uart3_rx_empty, uart2_rx_empty, uart1_rx_empty, uart0_rx_empty}),
		.data({uart3_rx_data, uart2_rx_data, uart1_rx_data, uart0_rx_data})
	);
	
	uart_out_mux
	#(
		.DATA_BITS(DATA_BITS),
		.COUNTER_BITS(COUNTER_BITS),
		.UART_COUNT(UART_COUNT)
	)
	uart_out_mux_inst
	(
		.clk(clk),
		.reset(reset),		
		.fifo_empty(uart_usb_rx_empty),
		.fifo_read(uart_usb_read),
		.fifo_data(uart_usb_rx_data),

		.write({uart3_write, uart2_write, uart1_write, uart0_write}),
		.full({uart3_tx_full, uart2_tx_full, uart1_tx_full, uart0_tx_full}),
		.data({uart3_tx_data, uart2_tx_data, uart1_tx_data, uart0_tx_data})
	);
	
	led_snake led_snake_inst
	(
		.clk(clk),
		.reset(reset),
		.leds(LED)
	);

endmodule
