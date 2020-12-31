module sound_control (
								input logic				Clk,
															Reset,
															bullet,
															gameover,
															victory,
								output logic [2:0]	sound_select		
);

			logic vic_hold, vic_hold_next;
			logic [28:0] counter1;
			logic [25:0] counter2;
			
			always_ff @ (posedge Clk)
			begin
				if (Reset) begin
					sound_select <= 3'b0;
				end
				else begin
					if (gameover)
						sound_select <= 3'b001;
					else if (counter1 != 29'b0)
						sound_select <= 3'b010;
					else if (counter2 != 26'b0)
						sound_select <= 3'b100;
					else
						sound_select <= 3'b0;
				end
			end
			
			always_ff @ (posedge Clk)
			begin
				if (Reset)
					counter1 <= 29'b0;
				else begin
					if (counter1 == 29'b0) begin
						if (victory) begin
							counter1 <= counter1 + 29'b1;
						end
					end
					else begin
						if (counter1 == 29'd300000000)
							counter1 <= 29'b0;
						else
							counter1 <= counter1 + 29'b1;
					end
				end
			end
			
			always_ff @ (posedge Clk)
			begin
				if (Reset) begin
					counter2 <= 26'b0;
				end
				else begin
					counter2 <= counter2;
					if (counter2 == 26'b0) begin
						if (bullet) begin
							counter2 <= counter2 + 26'b1;
						end
					end
					else begin
							if (counter2 == 26'd25000000)
								counter2 <= 26'b0;
							else
								counter2 <= counter2 + 27'b1;
					end
				end
			end
			
endmodule 