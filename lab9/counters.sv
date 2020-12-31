module counter (input logic CLK, input logic RESET, 
					input logic in, output logic [3:0] out);

	always_ff @ (posedge CLK)
	begin
		if (RESET)
			out <= 4'b0;
		else if (in)
			out <= out+1;
		else
			out <= out;
	end

endmodule
