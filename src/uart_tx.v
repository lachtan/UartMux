// UART transimtter

module uart_tx
	#(parameter
		DATA_BITS = 8,
		COUNTER_BITS = 16
	)
	(
		input wire clk,
		input wire reset,
		input wire tx_start,
		input wire [DATA_BITS-1:0] data_in,
		input wire [COUNTER_BITS-1:0] baud_divisor,
		output wire tx,
		output wire rts,
		output reg tx_done_tick
	);

	localparam [1:0]
		IDLE_STATE  = 2'd0,
		START_STATE = 2'd1,
		DATA_STATE  = 2'd2,
		STOP_STATE  = 2'd3;
	
	reg [1:0] state_current, state_next;
	reg [COUNTER_BITS-1:0] clk_counter_current, clk_counter_next;
	reg [2:0] bits_counter_current, bits_counter_next;
	reg [DATA_BITS-1:0] data_current, data_next;
	reg tx_current, tx_next;
	reg rts_current, rts_next;

	always @(posedge clk) begin
		if (reset) begin
			state_current <= IDLE_STATE;
			clk_counter_current <= 0;
			bits_counter_current <= 0;
			tx_current <= 1'b1;
			rts_current <= 0;
			data_current <= 0;
		end
		else begin
			state_current <= state_next;
			clk_counter_current <= clk_counter_next;
			bits_counter_current <= bits_counter_next;
			tx_current <= tx_next;
			rts_current <= rts_next;
			data_current <= data_next;
		end
	end

	always @* begin
		state_next = state_current;
		clk_counter_next = clk_counter_current;
		bits_counter_next = bits_counter_current;
		tx_next = tx_current;
		rts_next = rts_current;
		data_next = data_current;
		tx_done_tick = 1'b0;		

		case (state_current)

			IDLE_STATE: begin
				tx_next = 1'b1;
				rts_next = 0;
				if (tx_start) begin
					state_next = START_STATE;
					clk_counter_next = 0;
					data_next = data_in;
				end
			end

			START_STATE: begin
				tx_next = 1'b0;
				rts_next = 1'b1;
				if (clk_counter_current == baud_divisor) begin
					state_next = DATA_STATE;
					clk_counter_next = 0;
					bits_counter_next = 0;
				end
				else begin
					clk_counter_next = clk_counter_current + 1;
				end
			end

			DATA_STATE: begin
				tx_next = data_current[0];
				rts_next = 1'b1;
				if (clk_counter_current == baud_divisor) begin
					clk_counter_next = 0;
					data_next = data_current >> 1;
					if (bits_counter_current == (DATA_BITS-1)) begin
						state_next = STOP_STATE;
					end
					else begin
						bits_counter_next = bits_counter_current + 1;
					end
				end
				else begin
					clk_counter_next = clk_counter_current + 1;
				end
			end

			STOP_STATE: begin
				tx_next = 1'b1;
				rts_next = 1'b1;
				if (clk_counter_current == baud_divisor) begin
					state_next = IDLE_STATE;
					tx_done_tick = 1'b1;
				end
				else begin
					clk_counter_next = clk_counter_current + 1;					
				end
			end

		endcase
	end

	assign tx = tx_current;
	assign rts = rts_current;

endmodule
