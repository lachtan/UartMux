// FIFO
// lehce prepsana verze z knihy

module fifo
	#(parameter 
		DATA_BITS = 8,
		ADDRESS_BITS = 4
	)
	(
		input wire clk, 
		input wire reset,
		input wire read,
		input wire write,
		input wire [DATA_BITS-1:0] write_data,
		output wire empty,
		output wire full,
		output wire [DATA_BITS-1:0] read_data
	);

	reg [DATA_BITS-1:0] fifo_array [2**ADDRESS_BITS-1:0];
	reg [ADDRESS_BITS-1:0] write_ptr_current, write_ptr_next, write_ptr_successive;
	reg [ADDRESS_BITS-1:0] read_ptr_current, read_ptr_next, read_ptr_successive;
	reg full_current, full_next;
	reg empty_current, empty_next;
	wire write_enable;

	localparam [1:0]
		NO_OP_STATE = 2'b00,
		READ_STATE = 2'b01,
		WRITE_STATE = 2'b10,
		WRITE_AND_READ_STATE = 2'b11;

	assign read_data = fifo_array[read_ptr_current];
	assign write_enable = write & ~full_current;

	always @(posedge clk) begin
		if (reset) begin
			write_ptr_current <= 0;
			read_ptr_current <= 0;
			full_current <= 1'b0;
			empty_current <= 1'b1;
		end
		else begin
			if (write_enable) begin
				fifo_array[write_ptr_current] <= write_data;
			end
			write_ptr_current <= write_ptr_next;
			read_ptr_current <= read_ptr_next;
			full_current <= full_next;
			empty_current <= empty_next;
		end
	end

	always @* begin
		write_ptr_successive = write_ptr_current + 1;
		read_ptr_successive = read_ptr_current + 1;

		write_ptr_next = write_ptr_current;
		read_ptr_next = read_ptr_current;
		full_next = full_current;
		empty_next = empty_current;
		
		case ({write, read})
			// NO_OP_STATE
         
	        READ_STATE: begin
	            if (~empty_current) begin
					read_ptr_next = read_ptr_successive;
					full_next = 1'b0;
					if (read_ptr_successive == write_ptr_current) begin
						empty_next = 1'b1;
					end
				end
			end
	         
			WRITE_STATE: begin
				if (~full_current) begin
					write_ptr_next = write_ptr_successive;
					empty_next = 1'b0;
					if (write_ptr_successive == read_ptr_current) begin
						full_next = 1'b1;
					end
				end
			end

			WRITE_AND_READ_STATE: begin
				write_ptr_next = write_ptr_successive;
				read_ptr_next = read_ptr_successive;
			end

		endcase
	end

	assign full = full_current;
	assign empty = empty_current;

endmodule

