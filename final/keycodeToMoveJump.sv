module keycode_to_move_jump (
								input logic [7:0] keycode,
								output logic[1:0] move,
								output logic		jump
);



	always_comb begin
		move = 2'b0;
		jump = 1'b0;
		unique case (keycode)
			8'h1a:	jump = 1'b1;
			8'h4:		move = 2'b10;
			8'h7:		move = 2'b01;
			8'h16:;
		endcase
	end
	
endmodule 