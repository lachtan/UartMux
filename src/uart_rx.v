// UART Receiver
// resi chybny stav pri start a stop bitu

// http://stackoverflow.com/questions/13340301/size-bits-verilog

module uart_rx
	#(parameter
	 	DATA_BITS = 8,
	 	COUNTER_BITS = 16
	)
	(
		input wire clk,
		input wire reset,
		input wire rx,
		input wire [COUNTER_BITS-1:0] baud_divisor,
		output reg done_tick,
		output wire [DATA_BITS-1:0] data_out
	);

	localparam [2:0]
		IDLE_STATE  = 3'd0,
		START_STATE = 3'd1,
		DATA_STATE  = 3'd2,
		STOP_STATE  = 3'd3,
		WAIT_STATE  = 3'd4;

	reg [2:0] state_current, state_next;
	reg [COUNTER_BITS-1:0] clk_counter_current, clk_counter_next;
	reg [2:0] bits_counter_current, bits_counter_next;
	reg [DATA_BITS-1:0] data_current, data_next;

	always @(posedge clk) begin
		if (reset) begin
			state_current <= IDLE_STATE;
			clk_counter_current <= 0;
			bits_counter_current <= 0;
			data_current <= 0;
		end
		else begin
			state_current <= state_next;
			clk_counter_current <= clk_counter_next;
			bits_counter_current <= bits_counter_next;
			data_current <= data_next;
		end
	end

	always @* begin
		state_next = state_current;		
		clk_counter_next = clk_counter_current;
		bits_counter_next = bits_counter_current;
		data_next = data_current;
		done_tick = 0;

		case (state_current)
			
			IDLE_STATE: begin
				if (~rx) begin
					state_next = START_STATE;
					clk_counter_next = 0;
				end
			end

			START_STATE: begin
				if (clk_counter_current == (baud_divisor >> 1)) begin
				//if (clk_counter_current == baud_divisor[$bits(baud_divisor)-1:1]) begin
					if (rx) begin
						state_next = IDLE_STATE;
					end
					else begin
						state_next = DATA_STATE;
						clk_counter_next = 0;
						bits_counter_next = 0;
					end					
				end
				else begin
					clk_counter_next = clk_counter_current + 1;
				end
			end
			 
			 DATA_STATE: begin
			 	if (clk_counter_current == baud_divisor) begin
			 		clk_counter_next = 0;
			 		data_next = {rx, data_current[7:1]};
			 		if (bits_counter_current == (DATA_BITS - 1)) begin
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
			 	if (clk_counter_current == baud_divisor) begin
			 		if (rx) begin
			 			state_next = IDLE_STATE;
			 			done_tick = 1'b1;
			 		end
			 		else begin
			 			state_next = WAIT_STATE;
			 		end
			 	end
			 	else begin
			 		clk_counter_next = clk_counter_current + 1;
			 	end
			 end
			
			WAIT_STATE: begin
				if (rx) begin
					state_next = IDLE_STATE;
				end
			end

		endcase	
	end
	
	assign data_out = data_current;

endmodule
