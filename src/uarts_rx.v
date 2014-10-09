
module uart_in_mux
	#(parameter 
		DATA_BITS = 8,
		COUNTER_BITS = 16,
		UART_COUNT = 4
	)
	(
		input wire clk,
		input wire reset,

		input wire out_fifo_full,
		output reg out_fifo_write,
		output reg [DATA_BITS-1:0] out_fifo_data,

		input wire [UART_COUNT-1:0] rx,		
		output wire [UART_COUNT-1:0] read,
		input wire [UART_COUNT-1:0] empty,
		//input wire [DATA_BITS-1:0] data [UART_COUNT-1:0]
		input wire [DATA_BITS-1:0] data
	);
			
	localparam [1:0]
		CHECK_STATE = 2'd0,
		SEND_INDEX_STATE = 2'd1,
		SEND_VALUE_STATE = 2'd2;

	reg [7:0] uart_index_current, uart_index_next;
	reg [1:0] state_current, state_next;
	reg read_current, read_next;
	reg [DATA_BITS-1:0] data_reg;

	always @(posedge clk) begin
		if (reset) begin
			state_current <= CHECK_STATE;
			uart_index_current <= 0;
			read_current <= 0;
		end
		else begin
			state_current <= state_next;
			uart_index_current <= uart_index_next;
			read_current <= read_next;
		end
	end

	always @* begin
		state_next = state_current;
		uart_index_next = uart_index_current;
		read_next = 0;
		out_fifo_write = 0;

		case (state_current)
			CHECK_STATE: begin
				if (~empty[uart_index_current]) begin
					state_next = SEND_INDEX_STATE;
				end
			end

			SEND_INDEX_STATE: begin
				if (~out_fifo_full) begin
					state_next = SEND_VALUE_STATE;
					out_fifo_write = 1'b1;
					out_fifo_data = uart_index_current;
				end
			end

			SEND_VALUE_STATE: begin
				if (~out_fifo_full) begin
					state_next = CHECK_STATE;
					read_next = 1'b1;
					read[uart_index_current] = read_current;
					out_fifo_write = 1'b1;
					out_fifo_data = data;
					if (uart_index_current == UART_COUNT - 1) begin
						uart_index_next = 0;
					end
					else begin
						uart_index_next = uart_index_current + 1;
					end
				end			
			end

		endcase
	end

endmodule