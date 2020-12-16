//-------------------------------------------------------------------------
//    Ball.sv                                                            --
//    Viral Mehta                                                        --
//    Spring 2005                                                        --
//                                                                       --
//    Modified by Stephen Kempf 03-01-2006                               --
//                              03-12-2007                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  12-08-2017                               --
//    Spring 2018 Distribution                                           --
//                                                                       --
//    For use with ECE 385 Lab 8                                         --
//    UIUC ECE Department                                                --
//-------------------------------------------------------------------------


module man 	(	input logic				Clk,             	// 50 MHz clock
												Reset,         	// Active-high reset signal
												frame_clk,        // The clock indicating a new frame (~60Hz)
					input logic  [1:0]	move,					
					input logic  [3:0]	barrier,
					input logic				jump,
					output logic [9:0] 	man_x,
												man_y
);
				  
				  
				  
		logic [9:0] man_x_next, man_y_next;
		logic [9:0] motion_x, motion_y;
		logic [2:0]	jump_state, jump_state_next; 
	 
	 
	 
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
				man_x <= 10'd300;
				man_y <= 10'd200;
				jump_state <= 3'b000;
			end
			else begin
				man_x <= man_x_next;
				man_y <= man_y_next;
				jump_state <= jump_state_next;
			end
		end
		
		
		
		// the combinational logic of the 'next'
		always_comb
		begin
			// By default, keep motion and position unchanged
			man_x_next = man_x;
			man_y_next = man_y;
			jump_state_next = jump_state;
			motion_x = 10'b0;
			motion_y = 10'b0;
        
			// Update position and motion only at rising edge of frame clock
			if (frame_clk_rising_edge)	begin
				// check whether x-movement is legal
				unique case (move)
					2'b00:;
					2'b10: 
						begin
							if (barrier[1] == 1)
								motion_x = ~(10'b1) + 10'b1;
						end
					2'b01: 
						begin
							if (barrier[0] == 1)
								motion_x = 10'b1;
						end
					default:;
				endcase
				
				
				// check whether y-movement is legal
				if (jump_state == 3'b000) begin
					if (barrier[3] == 1'b1)
						motion_y = 10'b1;
				end
				else if (jump_state != 3'b111) begin
					if (barrier[2] == 1'b1)
						motion_y = ~(10'b1) + 1;
				end
				else begin
					if (barrier[3] == 1'b1)
						motion_y = 10'b1;
				end
				
				
				// update jump_state
				if (jump_state == 3'b000 && jump == 1'b1)
					jump_state_next = 3'b001;
				else if (jump_state != 3'b111)
					jump_state_next = jump_state + 3'b1;
				else begin
					if (barrier[3] == 1'b0)
						jump_state_next = 3'b000;
				end
					
				
				// Update the man's position with its motion
				man_x_next = man_x + motion_x;
				man_y_next = man_y + motion_y;
			end
		end
		
endmodule
