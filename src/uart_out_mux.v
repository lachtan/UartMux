
// USB -> UART

module uart_out_mux
	#(parameter 
		DATA_BITS = 8,
		COUNTER_BITS = 16,
		UART_COUNT = 1
	)
	(
		input wire clk,
		input wire reset,

		input wire fifo_empty,
		output wire fifo_read,
		input wire [DATA_BITS-1:0] fifo_data,

		output wire [UART_COUNT-1:0] write,
		output wire [UART_COUNT * DATA_BITS - 1 : 0] data
	);
			
	localparam [2:0]
		S1_STATE = 3'd0,
		S2_STATE = 3'd1,
		S3_STATE = 3'd2,
		S4_STATE = 3'd3,
		S5_STATE = 3'd4;

	reg [1:0] state_current, state_next;
	reg [7:0] uart_index_current, uart_index_next;
	reg fifo_read_current, fifo_read_next;
	reg [UART_COUNT-1:0] write_current, write_next;
	reg [UART_COUNT * DATA_BITS - 1 : 0] data_current, data_next;

	always @(posedge clk) begin
		if (reset) begin
			state_current <= S1_STATE;
			uart_index_current <= 0;
			fifo_read_current <= 0;
			write_current <= 0;
			data_current <= 0;
		end
		else begin
			state_current <= state_next;
			uart_index_current <= uart_index_next;
			fifo_read_current <= fifo_read_next;
			write_current <= write_next;
			data_current <= data_next;
		end
	end

	always @* begin
		state_next = state_current;
		uart_index_next = uart_index_current;
		fifo_read_next = 0;
		write_next = 0;
		data_next = data_current;

		case (state_current)
			S1_STATE: begin
				if (~fifo_empty) begin
					state_next = S2_STATE;
					fifo_read_next = 1'b1;
					uart_index_next = fifo_data;
				end
			end

			S2_STATE: begin
				state_next = S3_STATE;
			end
			
			S3_STATE: begin
				if (~fifo_empty) begin
					state_next = S4_STATE;
					fifo_read_next = 1'b1;
					data_next = 0;
					data_next[uart_index_current * DATA_BITS +: DATA_BITS] = fifo_data;
				end
			end
			
			S4_STATE: begin
				state_next = S1_STATE;
				if (uart_index_current < UART_COUNT) begin
					write_next[uart_index_current] = 1'b1;
				end
			end

			S5_STATE: begin
				state_next = S1_STATE;
			end

		endcase
	end

	assign fifo_read = fifo_read_current;
	assign write = write_current;
	assign data = data_current;
	
endmodule
