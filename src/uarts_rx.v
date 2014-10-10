
// UART -> USB

module uart_in_mux
	#(parameter 
		DATA_BITS = 8,
		COUNTER_BITS = 16,
		UART_COUNT = 1
	)
	(
		input wire clk,
		input wire reset,

		input wire fifo_full,
		output wire fifo_write,
		output wire [DATA_BITS-1:0] fifo_data,

		output wire [UART_COUNT-1:0] read,
		input wire [UART_COUNT-1:0] empty,
		input wire [UART_COUNT * DATA_BITS - 1 : 0] data
	);
			
	localparam [1:0]
		CHECK_STATE = 2'd0,
		SEND_INDEX_STATE = 2'd1,
		SEND_VALUE_STATE = 2'd2;

	reg [7:0] uart_index_current, uart_index_next;
	reg [1:0] state_current, state_next;
	reg fifo_write_current, fifo_write_next;
	reg [UART_COUNT-1:0] read_current, read_next;
	reg [DATA_BITS-1:0] fifo_data_current, fifo_data_next;

	always @(posedge clk) begin
		if (reset) begin
			state_current <= CHECK_STATE;
			uart_index_current <= 0;
			fifo_write_current <= 0;
			fifo_data_current <= 0;
			read_current <= 0;
		end
		else begin
			state_current <= state_next;
			uart_index_current <= uart_index_next;
			fifo_write_current <= fifo_write_next;
			fifo_data_current <= fifo_data_next;
			read_current <= read_next;
		end
	end

	always @* begin
		state_next = state_current;
		uart_index_next = uart_index_current;
		fifo_write_next = 0;
		fifo_data_next = 0;
		read_next = 0;

		case (state_current)
			CHECK_STATE: begin
				if (empty[uart_index_current]) begin
					if (uart_index_current == UART_COUNT - 1) begin
						uart_index_next = 0;
					end else begin
						uart_index_next = uart_index_current + 1;
					end
				end else begin
					state_next = SEND_INDEX_STATE;
				end
			end

			SEND_INDEX_STATE: begin
				if (~fifo_full) begin
					state_next = SEND_VALUE_STATE;
					fifo_write_next = 1'b1;
					fifo_data_next = uart_index_current;
				end
			end

			SEND_VALUE_STATE: begin
				if (~fifo_full) begin
					state_next = CHECK_STATE;
					read_next[uart_index_current] = 1'b1;
					fifo_write_next = 1'b1;
					fifo_data_next = data[uart_index_current * DATA_BITS +: DATA_BITS];				
					if (uart_index_current == UART_COUNT - 1) begin
						uart_index_next = 0;
					end else begin
						uart_index_next = uart_index_current + 1;
					end
				end			
			end

		endcase
	end
	
	assign fifo_write = fifo_write_current;
	assign fifo_data = fifo_data_current;
	assign read = read_current;

endmodule