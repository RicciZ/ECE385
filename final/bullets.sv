module bullets (
					input logic 			Clk,
												Reset,
												frame_clk,
												shoot,
					input logic [9:0]		man_x,
												man_y,
					input	logic				is_right,
												bullet1_off,
												bullet2_off,
												bullet3_off,
												
					output logic			bullet,
					
					output logic [9:0]	bullet1_x,
												bullet1_y,
												
												bullet2_x,
												bullet2_y,
												
												bullet3_x,
												bullet3_y,
							
					output logic			bullet1_active,
												bullet2_active,
												bullet3_active
);
			
			
			
			logic [9:0]		bullet1_x_next, bullet1_y_next,
								bullet2_x_next, bullet2_y_next,
								bullet3_x_next, bullet3_y_next;
			logic				bullet1_active_next, bullet2_active_next, bullet3_active_next;
			
			logic [1:0]		bullet_counter, bullet_counter_next;
			logic [5:0]		timecounter1, timecounter2, timecounter3,
								timecounter1_next, timecounter2_next, timecounter3_next;
			logic				direction, direction_next;
			logic	[9:0]		direction1, direction1_next, direction2, direction2_next, direction3, direction3_next;	
			logic				shoot_delay, shoot_delay_next, shoot_h;
			logic				bullet1_inactive, bullet2_inactive, bullet3_inactive, inactive1, inactive2, inactive3,
								bullet1_inactive_next, bullet2_inactive_next, bullet3_inactive_next;
			
			assign inactive1 = bullet1_off & bullet1_active;
			assign inactive2 = bullet2_off & bullet2_active;
			assign inactive3 = bullet3_off & bullet3_active;
			
			
			
			// find the rising edge of the frame clk
			logic frame_clk_delayed, frame_clk_rising_edge;
			always_ff @ (posedge Clk) begin
				frame_clk_delayed <= frame_clk;
				frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
			end
			
			
			
			always_ff @ (posedge Clk)
			begin
				if (Reset) begin
					bullet1_x <= 10'd1*32;
					bullet1_y <= 10'd6*32;
					bullet1_active <= 1'b0;
					
					bullet2_x <= 10'd1*32;
					bullet2_y <= 10'd6*32;
					bullet2_active <= 1'b0;
					
					bullet3_x <= 10'd1*32;
					bullet3_y <= 10'd6*32;
					bullet3_active <= 1'b0;
					
					bullet_counter <= 2'b11;
					timecounter1 <= 6'b0;
					timecounter2 <= 6'b0;
					timecounter3 <= 6'b0;
					
					direction <= 1'b1;
					direction1 <= 9'd5;
					direction2 <= 9'd5;
					direction3 <= 9'd5;
					
					shoot_delay <= 1'b0;
					
					bullet1_inactive <= 1'b0;
					bullet2_inactive <= 1'b0;
					bullet3_inactive <= 1'b0;
				end
				else begin
					bullet1_x <= bullet1_x_next;
					bullet1_y <= bullet1_y_next;
					bullet1_active <= bullet1_active_next;
					
					bullet2_x <= bullet2_x_next;
					bullet2_y <= bullet2_y_next;
					bullet2_active <= bullet2_active_next;
					
					bullet3_x <= bullet3_x_next;
					bullet3_y <= bullet3_y_next;
					bullet3_active <= bullet3_active_next;
					
					bullet_counter <= bullet_counter_next;
					timecounter1 <= timecounter1_next;
					timecounter2 <= timecounter2_next;
					timecounter3 <= timecounter3_next;
					
					direction <= direction_next;
					direction1 <= direction1_next;
					direction2 <= direction2_next;
					direction3 <= direction3_next;
					
					shoot_delay <= shoot_delay_next;
					
					bullet1_inactive <= bullet1_inactive_next;
					bullet2_inactive <= bullet2_inactive_next;
					bullet3_inactive <= bullet3_inactive_next;
				end
			end
			
			
			
			// bullet in the air
			always_comb
			begin
				bullet1_x_next = bullet1_x;
				bullet2_x_next = bullet2_x;
				bullet3_x_next = bullet3_x;
				bullet1_y_next = bullet1_y;
				bullet2_y_next = bullet2_y;
				bullet3_y_next = bullet3_y;
				
				direction1_next = direction1;
				direction2_next = direction2;
				direction3_next = direction3;

				if (frame_clk_rising_edge) begin
				
					if (bullet1_active) begin
						if (timecounter1 == 6'b0) begin
							if (direction == 1'b1)
								direction1_next = 9'd5;
							else 
								direction1_next = ~(9'd5) + 9'd1;
						end
						bullet1_x_next = bullet1_x + direction1_next;
					end
					else begin
						bullet1_x_next = man_x + 10'd16;
						bullet1_y_next = man_y + 10'd16;
					end
						
					if (bullet2_active) begin
						if (timecounter2 == 6'b0) begin
							if (direction == 1'b1)
								direction2_next = 9'd5;
							else 
								direction2_next = ~(9'd5) + 9'd1;
						end
						bullet2_x_next = bullet2_x + direction2_next;
					end
					else begin
						bullet2_x_next = man_x + 10'd16;
						bullet2_y_next = man_y + 10'd16;
					end
					
					if (bullet3_active) begin
						if (timecounter3 == 6'b0) begin
							if (direction == 1'b1)
								direction3_next = 9'd5;
							else 
								direction3_next = ~(9'd5) + 9'd1;
						end
						bullet3_x_next = bullet3_x + direction3_next;
					end
					else begin
						bullet3_x_next = man_x + 10'd16;
						bullet3_y_next = man_y + 10'd16;
					end
					
				end
			end
			
			
			
			// bullet counter
			always_comb
			begin
				bullet_counter_next = bullet_counter;

				if (frame_clk_rising_edge) begin
					if (bullet_counter != 2'b0 && shoot_h)
						bullet_counter_next = bullet_counter + ~(2'b01) + 2'b1; 	// bullet_counter - 1
					if (bullet_counter == 2'b0) begin
						if ((!bullet1_active) && (~bullet2_active) && (!bullet3_active)) 
							bullet_counter_next = 2'b11;
					end
				end
			end
			
			
			
			// time counter
			always_comb
			begin
				timecounter1_next = timecounter1;
				timecounter2_next = timecounter2;
				timecounter3_next = timecounter3;
				
				if (frame_clk_rising_edge) begin
					if (bullet1_active)
						timecounter1_next = timecounter1 + 6'b1;
					else
						timecounter1_next = 6'b0;
					if (bullet2_active)
						timecounter2_next = timecounter2 + 6'b1;
					else
						timecounter2_next = 6'b0;
					if (bullet3_active)
						timecounter3_next = timecounter3 + 6'b1;
					else
						timecounter3_next = 6'b0;
				end
			end	
			
			
			
			// bullet active
			always_comb
			begin
				bullet1_active_next = bullet1_active;
				bullet2_active_next = bullet2_active;
				bullet3_active_next = bullet3_active;
				
				if (frame_clk_rising_edge) begin
				
					if (bullet1_active == 1'b1) begin
						if (timecounter1 == 6'h37 || bullet1_inactive)
							bullet1_active_next = 1'b0;
					end
					if (bullet2_active == 1'b1) begin
						if (timecounter2 == 6'h37 || bullet2_inactive)
							bullet2_active_next = 1'b0;
					end
					if (bullet3_active == 1'b1) begin
						if (timecounter3 == 6'h37 || bullet3_inactive)
							bullet3_active_next = 1'b0;
					end
					
					unique case (bullet_counter)
						2'b11:	begin
									if (shoot_h) begin
										bullet1_active_next = 1'b1;
									end
						end
						2'b10:	begin
									if (shoot_h) begin
										bullet2_active_next = 1'b1;
									end
						end
						2'b01:	begin
									if (shoot_h) begin
										bullet3_active_next = 1'b1;
									end
						end
						2'b00:	;
					endcase
				end
			end
			
			
			
			// direction and shoot delay
			always_comb
			begin
				direction_next = direction;
				if (frame_clk_rising_edge) begin
					direction_next = is_right;
				end
			end
			
			assign bullet = ((bullet1_active && timecounter1 == 6'h0) || (bullet2_active && timecounter2 == 6'h0) || 
									(bullet3_active && timecounter3 == 6'h0));
			assign shoot_h = shoot & (~shoot_delay);
			
			always_comb
			begin
				shoot_delay_next = shoot_delay;
				if (frame_clk_rising_edge)
					shoot_delay_next = shoot;
			end
			
			
			
			// bullet deactive
			always_comb
			begin
				bullet1_inactive_next = bullet1_inactive;
				bullet2_inactive_next = bullet2_inactive;
				bullet3_inactive_next = bullet3_inactive;
				
				if (timecounter1 == 6'h0) begin
					bullet1_inactive_next = 1'b0;
				end
				else if (inactive1) begin
					bullet1_inactive_next = 1'b1;
				end
				
				if (timecounter2 == 6'h0) begin
					bullet2_inactive_next = 1'b0;
				end
				else if (inactive2) begin
					bullet2_inactive_next = 1'b1;
				end
				
				if (timecounter3 == 6'h0) begin
					bullet3_inactive_next = 1'b0;
				end
				else if (inactive3) begin
					bullet3_inactive_next = 1'b1;
				end
			end
			
endmodule 