
module counter_tick
	#(parameter DENOMINATOR = (66000000 / 2))
	(
		input wire clk,
		input wire reset,
		output reg tick
	);
	 
	reg [31:0] counter;

	always @(posedge clk) begin
		if (reset) begin
			counter <= 0;
			tick <= 0;
		end
		else begin
			if (counter == DENOMINATOR) begin
				counter <= 0;
				tick <= 1;
			end
			else begin
				counter <= counter + 1;
				tick <= 0;
			end
		end
	end

endmodule
