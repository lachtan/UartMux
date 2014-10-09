
module led_snake
	(
		input wire clk,
		input wire reset,
		output wire [3:0] leds
	);
	
	localparam [3:0] led_init_state = 4'b0011;
	
	wire slow_tick;
	reg [3:0] led_shift = led_init_state;
	
	counter_tick counter_tick_inst
	(
		.reset(reset),
		.clk(clk),
		.tick(slow_tick)
	);
	
	always @(posedge clk) begin
		if (reset) begin
			led_shift <= led_init_state;
		end
		else begin
			if (slow_tick) begin
				led_shift <= {led_shift[2:0], led_shift[3]};
			end
		end
	end

	assign leds = led_shift;

endmodule
