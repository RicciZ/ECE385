 
module keycodeDecoder (	
								input	logic			Clk,
								input logic			Reset,
								input logic [31:0]keycode,
								output logic[1:0] move,
								output logic		jump,
								output logic		restart,
								output logic		shoot,
								output logic		god
);


		
		// assign key values
		logic w, a, d, r, j, f, i, n, l;
		logic	press1, press1_next, pressed, esc;
		logic	god_next;
		logic [1:0] move_next;
		
		assign w = (keycode[31:24] == 8'h1a | keycode[23:16] == 8'h1a | keycode[15:8] == 8'h1a | keycode[7:0] == 8'h1a);
		assign a = (keycode[31:24] == 8'h4 | keycode[23:16] == 8'h4 | keycode[15:8] == 8'h4 | keycode[7:0] == 8'h4);
		assign d = (keycode[31:24] == 8'h7 | keycode[23:16] == 8'h7 | keycode[15:8] == 8'h7 | keycode[7:0] == 8'h7);
		assign r = (keycode[31:24] == 8'h15 | keycode[23:16] == 8'h15 | keycode[15:8] == 8'h15 | keycode[7:0] == 8'h15);
		assign j = (keycode[31:24] == 8'hd | keycode[23:16] == 8'hd | keycode[15:8] == 8'hd | keycode[7:0] == 8'hd);
		assign f = (keycode[31:24] == 8'h9 | keycode[23:16] == 8'h9 | keycode[15:8] == 8'h9 | keycode[7:0] == 8'h9);
		assign i = (keycode[31:24] == 8'hc | keycode[23:16] == 8'hc | keycode[15:8] == 8'hc | keycode[7:0] == 8'hc);
		assign n = (keycode[31:24] == 8'h11 | keycode[23:16] == 8'h11 | keycode[15:8] == 8'h11 | keycode[7:0] == 8'h11);
		assign l = (keycode[31:24] == 8'hf | keycode[23:16] == 8'hf | keycode[15:8] == 8'hf | keycode[7:0] == 8'hf);
		assign esc = (keycode[31:24] == 8'h29 | keycode[23:16] == 8'h29 | keycode[15:8] == 8'h29 | keycode[7:0] == 8'h29);
		assign pressed = (keycode != 32'b0);

		
		always_ff @ (posedge Clk)
		begin
			if (Reset) begin
				move <= 2'b0;
				press1 <= 1'b0;
				god <= 1'b0;
			end
			else begin
				move <= move_next;
				press1 <= press1_next;
				god <= god_next;
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
		
		
		
		// state machine to detect 'final a'
		enum logic [3:0] {nothing, F, I, N, A, L, ACTIVE}	curr_state, next_state;
		
		always_ff @ (posedge Clk)
		begin
			if (Reset)
				curr_state <= nothing;
			else
				curr_state <= next_state;
		end
		
		always_comb
		begin
			next_state = curr_state;
			god_next = god;
			
			unique case (curr_state)
				nothing:	begin
					if (f)
						next_state = F;
				end
				
				F:	begin
					if (pressed) begin
						if (i)
							next_state = I;
						else if (f)
							next_state = F;
						else
							next_state = nothing;
					end
				end
				
				I:	begin
					if (pressed) begin
						if (n)
							next_state = N;
						else if (i)
							next_state = I;
						else
							next_state = nothing;
					end
				end
				
				n:	begin
					if (pressed) begin
						if (a)
							next_state = A;
						else if (n)
							next_state = N;
						else
							next_state = nothing;
					end
				end
				
				A:	begin
					if (pressed) begin
						if (l)
							next_state = L;
						else if (a)
							next_state = A;
						else
							next_state = nothing;
					end
				end
				
				L:	begin
					if (pressed) begin
						if (a)
							next_state = ACTIVE;
						else if (l)
							next_state = L;
						else
							next_state = nothing;
					end
				end
				
				ACTIVE:	begin
					god_next = 1'b1;
					next_state = nothing;
				end
			endcase
			
			if (esc)
				god_next = 1'b0;
		end
	
endmodule 