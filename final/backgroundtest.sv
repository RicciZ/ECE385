module background_test (
								input [9:0] 	man_x,
													man_y,
								output logic [3:0] barrier
);
		always_comb begin
			if (man_y >= 10'd12*10'd32+10'd23)
				barrier = 4'b0111;
			else
				barrier = 4'b1111;
		end
		
endmodule
