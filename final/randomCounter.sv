module randomCounter (	
							input logic		Clk,
												Reset,
												frame_clk,
												hit,
												restart,
							output logic	thorn1,
												thorn2,
												thorn3,
												thorn4
);


			logic thorn1_next, thorn2_next, thorn3_next, thorn4_next;
			logic [3:0] randomcounter, randomcounter_next;
			logic hold, hold_next, hit_hold, hit_hold_next;
			
			
			
			always_ff @ (posedge Clk)
			begin
				if (Reset) begin
					thorn1 <= 1'b1;
					thorn2 <= 1'b1;
					thorn3 <= 1'b1;
					thorn4 <= 1'b1;
					randomcounter <= 4'b0; 
					hold <= 1'b0;
					hit_hold <= 1'b0;
				end
				else begin
					thorn1 <= thorn1_next;
					thorn2 <= thorn2_next;
					thorn3 <= thorn3_next;
					thorn4 <= thorn4_next;
					randomcounter <= randomcounter_next;
					hold <= hold_next;
					hit_hold <= hit_hold_next;
				end
			end
			
			
			
			// find the rising edge of the frame clk
			logic frame_clk_delayed, frame_clk_rising_edge;
			always_ff @ (posedge Clk) begin
				frame_clk_delayed <= frame_clk;
				frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
			end
			
			
			
			always_comb
			begin
				thorn1_next = thorn1;
				thorn2_next = thorn2;
				thorn3_next = thorn3;
				thorn4_next = thorn4;
				randomcounter_next = randomcounter;
				hold_next = hold;
				hit_hold_next = hit_hold | hit;
				if (restart)
					hit_hold_next = 1'b0;
				
				if (frame_clk_rising_edge) begin
					randomcounter_next = randomcounter + 4'b1;
					if ((hold == 1'b0) && hit_hold) begin
						thorn1_next = randomcounter[0];
						thorn2_next = randomcounter[1];
						thorn3_next = randomcounter[2];
						thorn4_next = randomcounter[3];
						hold_next = 1'b1;
					end
					if (restart) begin
						hold_next = 1'b0;
						thorn1_next = 1'b1;
						thorn2_next	= 1'b1;
						thorn3_next = 1'b1;
						thorn4_next	= 1'b1;
					end
				end
			end

endmodule 