module frameClk (
						input logic		Clk,
											Reset,
											VGA_VS,
						output logic	frame_clk
);


			logic frame_clk_next, VGA_VS_delayed, VGA_VS_rising_edge, double, double_next;
			
			always_ff @ (posedge Clk)
			begin
				VGA_VS_delayed <= VGA_VS;
				VGA_VS_rising_edge <= (VGA_VS == 1'b1) && (VGA_VS_delayed == 1'b0);
				if (Reset) begin
					frame_clk <= 1'b0;
					double <= 1'b0;
				end
				else begin
					frame_clk <= frame_clk_next;
					double <= double_next;
				end
			end
			
			
			
			always_comb
			begin
				frame_clk_next = frame_clk;
				double_next = double;
				
				if (VGA_VS_rising_edge) begin
					if (double == 1'b0) begin
						double_next = 1'b1;
						if (frame_clk == 1'b0)
							frame_clk_next = 1'b1;
						else
							frame_clk_next = 1'b0;
					end
					else begin
						double_next = 1'b0;
					end
				end
			end
			
endmodule 