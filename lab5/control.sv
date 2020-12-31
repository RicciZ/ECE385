module control2 (input Clk, Reset, Run, ClearA_LoadB, M,
					 output logic Load_A, Load_X, Shift_En, fn,
					 output logic [3:0] curr,
					 output logic [2:0] count
					 );
					 
		enum logic [3:0] {A,B,C,D,E} curr_state, next_state;
		logic [2:0] counter = 3'b000;
		assign curr = curr_state;
		assign count = counter;
		
		always_ff @ (posedge Clk)
		begin
			if (Reset)
				curr_state <= A;
			else
				curr_state <= next_state;
				
			if (Shift_En)
				counter <= counter + 1'b1;
			else
				counter <= counter;
			
			if (counter == 7)
				fn = 1;
			else
				fn = 0;
		end
		
		
		always_comb
		begin
			next_state = curr_state;
			unique case (curr_state)
			
				A:		begin
							Load_A = 1'b0;
							Load_X = 1'b0;
							Shift_En = 1'b0;			
							if (Run)
								next_state = B;		
						end							// wait state
						
				B:		begin
							Load_A = 1'b0;
							Load_X = 1'b0;
							Shift_En = 1'b0;
							if (M)
								next_state = C;
							else
								next_state = D;		
						end							// start state
							
				C:		begin
							Load_A = 1'b1;
							Load_X = 1'b1;
							Shift_En = 1'b0;
							next_state = D;			
						end							// add state
						
				D:		begin
						Load_A = 1'b0;
						Load_X = 1'b0;
						Shift_En = 1'b1;
						if (counter == 7)
							next_state = E;
						else if (M)
							next_state = C;
						else
							next_state = D;
						end							// shift state
				E:		begin
						Load_A = 1'b0;
						Load_X = 1'b0;
						Shift_En = 1'b0;			
						if (~Run)
							next_state = A;
						end							// hold state
			endcase
		end
endmodule
