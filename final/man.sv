module man (	
					input logic				Clk,             	// 50 MHz clock
												Reset,         	// Active-high reset signal
												frame_clk,        // The clock indicating a new frame (~60Hz)
					input logic  [1:0]	move,					
					input logic  [3:0]	barrier,
					input logic				jump,
												dead,
												check,
												restart,
					output logic [9:0] 	man_x,
												man_y,
					output logic [1:0]	man_state,			// 00 -> still, 01 -> x-move, 10 -> jump, 11 -> fall
												man_graph_counter,
					output logic			is_right,
												is_dead,
												checking,
					input logic [9:0]		map_x,
												map_y
);
				  
				  
				  
		logic [9:0] man_x_next, man_y_next;
		logic [9:0] motion_x, motion_y;
		logic [3:0]	jump_state, jump_state_next;
		logic [1:0] man_state_next, man_graph_counter_next;
		logic change_graph;
		logic	is_right_next;
		logic [1:0] lower_frequency, lower_frequency_next;
		logic	low_rising_edge;
		logic jump_gap, jump_gap_next, jump_prev, doubleJump, doubleJump_next;
		logic	dead_state, dead_state_next;
		logic check_state, check_state_next;
		logic [9:0]	mapX, mapY, mapX_next, mapY_next;
	 
	 
	 
		// find the rising edge of the frame clk
		logic frame_clk_delayed, frame_clk_rising_edge;
		always_ff @ (posedge Clk) begin
			frame_clk_delayed <= frame_clk;
			frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
		end

	 
	 
		// the registers which hold the position and motion status of the man
		always_ff @ (posedge Clk)
		begin
			if (Reset) begin
				man_x <= 10'd3*10'd32;
				man_y <= 10'd6*10'd32;
				jump_state <= 4'b0;
				man_state <= 2'b0; 
				man_graph_counter <= 2'b0;
				is_right <= 1'b1;
				lower_frequency <= 2'b0;
				doubleJump <= 1'b0;
				jump_gap <= 1'b0;
				dead_state <= 1'b0;
				check_state <= 1'b0;
				mapX <= 10'd3*10'd32;
				mapY <= 10'd6*10'd32;
			end
			else if (restart) begin
				man_x <= mapX;
				man_y <= mapY;
				jump_state <= 4'b0;
				man_state <= 2'b0; 
				man_graph_counter <= 2'b0;
				is_right <= 1'b1;
				lower_frequency <= 2'b0;
				doubleJump <= 1'b0;
				jump_gap <= 1'b0;
				dead_state <= 1'b0;
				check_state <= 1'b0;
				mapX <= mapX;
				mapY <= mapY;
			end
			else begin
				man_x <= man_x_next;
				man_y <= man_y_next;
				jump_state <= jump_state_next;
				man_state <= man_state_next;
				man_graph_counter <= man_graph_counter_next;
				is_right <= is_right_next;
				lower_frequency <= lower_frequency_next;
				doubleJump <= doubleJump_next;
				jump_gap <= jump_gap_next;
				dead_state <= dead_state_next;
				check_state <= check_state_next;
				mapX <= mapX_next;
				mapY <= mapY_next;
			end
		end
		
		always_ff @ (posedge Clk)
		begin
			if (Reset) 
				jump_prev <= 1'b0;
			if (frame_clk_rising_edge)
				jump_prev <= jump;
		end


		
		// the combinational logic of position and movement
		// By default, keep motion and position unchanged
		
		// x-motion
		always_comb
		begin
			man_x_next = man_x;
			motion_x = 10'b0;
			is_right_next = is_right;
			
			// Update position and motion only at rising edge of frame clock
			if (frame_clk_rising_edge)	begin
				// check whether x-movement is legal
				unique case (move)
					2'b00:;
					2'b10: begin
							is_right_next = 1'b0;
							if (barrier[1] == 1)
								motion_x = ~(10'd2) + 10'b1;
						end
					2'b01: begin
							is_right_next = 1'b1;
							if (barrier[0] == 1)
								motion_x = 10'd2;
						end
					default:;
				endcase
			end
			
			// Update the man's position with its motion
			man_x_next = man_x + motion_x;
		end
		
		// y-motion
		always_comb
		begin
			man_y_next = man_y;
			motion_y = 10'b0;
			
			// Update position and motion only at rising edge of frame clock
			if (frame_clk_rising_edge)	begin
				// check whether y-movement is legal
				if (jump_state == 4'b000) begin	// all zero represents not jumping --> still or falling
					if (barrier[3] == 1'b1)
						motion_y = 10'd3;
				end
				else if (jump_state != 4'b1111) begin
					if (barrier[2] == 1'b1)
						motion_y = ~(10'd5) + 10'b1;
				end
				else begin
					if (barrier[3] == 1'b1)
						motion_y = 10'd3;
				end
				
			// Update the man's position with its motion
			man_y_next = man_y + motion_y;
			end
		end
				
		// update jump_state
		always_comb
		begin
			jump_gap_next = jump_gap;
			doubleJump_next = doubleJump;
			jump_state_next = jump_state;
			
			if (frame_clk_rising_edge)	begin
				if (jump_state == 4'b000) begin
					jump_gap_next = 1'b0;
					doubleJump_next = 1'b0;
					if (jump == 1'b1)
						jump_state_next = 4'b0001;
				end
				else begin
					jump_gap_next = ((jump_prev == 1'b1 & jump == 1'b0) | jump_gap);
					
					if (jump_state != 4'b1111)
						jump_state_next = jump_state + 4'b1;
					else begin
						if (barrier[3] == 1'b0)
							jump_state_next = 4'b0000;
					end
						
					if (jump_gap == 1'b1 & doubleJump == 1'b0 & jump == 1'b1) begin
						doubleJump_next = 1'b1;
						jump_state_next = 4'b0001;
					end
				end
			end
		end
			

		
		// man_state and man_graph_counter
		always_comb
		begin
			man_state_next = man_state;
			
			if (frame_clk_rising_edge)	begin
				if (jump_state_next == 4'b0000) begin
					if (motion_y != 10'b0) 
						man_state_next = 2'b11;
					else if (motion_x == 10'b0)
						man_state_next = 2'b00;
					else 
						man_state_next = 2'b01;
				end
				else begin
					if (jump_state_next == 4'b1111)
						man_state_next = 2'b11;
					else 
						man_state_next = 2'b10;
				end
			end
		end
		
		assign change_graph = (man_state != man_state_next);
		
		always_comb
		begin
			man_graph_counter_next = man_graph_counter;
			
			if (frame_clk_rising_edge)	begin
				if (change_graph)
					man_graph_counter_next = 2'b0;
				else if (low_rising_edge) begin
					if (man_graph_counter == 2'b11)
						man_graph_counter_next = 2'b0;
					else
						man_graph_counter_next = man_graph_counter + 2'b1;
				end
			end
		end
		
		
		
		// lower_frequency
		always_comb
		begin
			lower_frequency_next = lower_frequency;
			
			if (frame_clk_rising_edge)	begin
				if (lower_frequency == 2'b11)
					lower_frequency_next = 2'b00;
				else
					lower_frequency_next = lower_frequency + 2'b01;
			end
		end
		
		assign low_rising_edge = (lower_frequency == 2'b00);
		
		
		
		// dead state, check state and checkpoint location
		assign is_dead = dead_state;
		assign checking = check_state;
		assign check_state_next = check;
		
		always_comb
		begin
		dead_state_next = dead_state;
			if (dead)
				dead_state_next = 1'b1;
			if (restart)
				dead_state_next = 1'b0;
		end
		
		always_comb
		begin
			if (check) begin
				mapX_next = map_x;
				mapY_next = map_y;
			end
			else begin
				mapX_next = mapX;
				mapY_next = mapY;
			end
		end

		
endmodule
