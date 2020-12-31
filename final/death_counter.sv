module death_counter (
								input logic 			Clk,
															frame_clk,
															Reset,
															is_dead,
								output logic [3:0]	tenths,
															ones
);



			logic [3:0] tenths_next, ones_next;
			logic hold, hold_next;
			
			
			
			// find the rising edge of the frame clk
			logic frame_clk_delayed, frame_clk_rising_edge;
			always_ff @ (posedge Clk) begin
				frame_clk_delayed <= frame_clk;
				frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
			end
			
			
			
			always_ff @ (posedge Clk)
			begin
				if (Reset) begin
					tenths <= 4'b0;
					ones <= 4'b0;
					hold <= 1'b0;
				end
				else begin
					tenths <= tenths_next;
					ones <= ones_next;
					hold <= hold_next;
				end
			end
			
			
			
			always_comb
			begin
				ones_next = ones;
				tenths_next = tenths;
				hold_next = hold;
				
				if (frame_clk_rising_edge) begin
					if (hold == 1'b0) begin
						if (is_dead) begin
							hold_next = 1'b1;
							if (ones == 4'b1001) begin
								ones_next = 4'b0000;
								if (tenths == 4'b1001) begin
									tenths_next = 4'b0000;
								end else
									tenths_next = tenths + 4'b1;
							end else
								ones_next = ones + 4'b1;
						end
					end
					else begin
						if (is_dead == 1'b0) begin
							hold_next = 1'b0;
						end
					end
				end
			end
			
			
			
endmodule 