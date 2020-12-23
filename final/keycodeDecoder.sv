 
module keycodeDecoder (	
								input	logic			Clk,
								input logic			Reset,
								input logic [31:0]keycode,
								output logic[1:0] move,
								output logic		jump,
								output logic		restart,
								output logic		shoot
);


		
		// assign key values
		logic w, a, d, r, j, press1, press1_next;
		logic [1:0] move_next;
		
		assign w = (keycode[31:24] == 8'h1a | keycode[23:16] == 8'h1a | keycode[15:8] == 8'h1a | keycode[7:0] == 8'h1a);
		assign a = (keycode[31:24] == 8'h4 | keycode[23:16] == 8'h4 | keycode[15:8] == 8'h4 | keycode[7:0] == 8'h4);
		assign d = (keycode[31:24] == 8'h7 | keycode[23:16] == 8'h7 | keycode[15:8] == 8'h7 | keycode[7:0] == 8'h7);
		assign r = (keycode[31:24] == 8'h15 | keycode[23:16] == 8'h15 | keycode[15:8] == 8'h15 | keycode[7:0] == 8'h15);
		assign j = (keycode[31:24] == 8'hd | keycode[23:16] == 8'hd | keycode[15:8] == 8'hd | keycode[7:0] == 8'hd);

		
		always_ff @ (posedge Clk)
		begin
			if (Reset) begin
				move <= 2'b0;
				press1 <= 1'b0;
			end
			else begin
				move <= move_next;
				press1 <= press1_next;
			end
		end
		
		
		
		// decoder
		always_comb 
		begin
			if (w)
				jump = 1'b1;
			else 
				jump = 1'b0;
		end
		
		always_comb
		begin
			if (r)
				restart = 1'b1;
			else
				restart = 1'b0;
		end
		
		always_comb
		begin
			if (j)
				shoot = 1'b1;
			else
				shoot = 1'b0;
		end
		
		always_comb
		begin
			press1_next = press1;
			move_next = move;
			
			if (press1 == 1'b0) begin
				if (d) begin
					move_next = 2'b01;
					press1_next = 1'b1;
				end else if (a) begin
					move_next = 2'b10;
					press1_next = 1'b1;
				end
			end
			
			if (press1 == 1'b1) begin
				if (d & a) begin	;	end
				else begin
					if (d) begin
						move_next = 2'b01;
					end else if (a) begin
						move_next = 2'b10;
					end else begin
						press1_next = 1'b0;
						move_next = 2'b00;
					end
				end
			end
		end
	
endmodule 