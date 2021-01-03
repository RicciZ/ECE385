module flytrap(input  logic [9:0] init_x,init_y,
					input  logic [9:0] trigger_x_left,trigger_x_right,
											 trigger_y_up,trigger_y_down,
					input  logic [9:0] man_x,man_y,
					input  logic [1:0] direction,		// 00->up, 01->right, 10->left, 11->down
					input  logic Clk,Reset,restart,frame_clk,
					input  logic [1:0] inmap,
					input  logic [3:0] speed,
					output logic trap_on,
					output logic [1:0] trapspikestate,	// 00->up, 01->right, 10->left, 11->down
					output logic [9:0] trap_x,trap_y);
		
		// flytrap in map1

		logic trap_on_next;
		logic [5:0] moving_counter,moving_counter_next;
		logic [9:0] trap_x_next,trap_y_next;
		
		assign trapspikestate = direction;
		
		// find the rising edge of the frame clk
		logic frame_clk_delayed, frame_clk_rising_edge;
		always_ff @ (posedge Clk) begin
			frame_clk_delayed <= frame_clk;
			frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
		end
		
		always_ff @ (posedge Clk)
		begin
			if (Reset || restart)
			begin
				trap_on <= 1'b0;
				trap_x <= init_x;
				trap_y <= init_y;
				moving_counter <= 6'b000000;
			end
			else
			begin
				trap_on <= trap_on_next;
				trap_x <= trap_x_next;
				trap_y <= trap_y_next;
				moving_counter <= moving_counter_next;
			end
		end


		always_comb
		begin
			trap_on_next = trap_on;
			trap_x_next = trap_x;
			trap_y_next = trap_y;
			moving_counter_next = moving_counter;
			if (frame_clk_rising_edge)
			begin
				if (man_x <= trigger_x_right && man_x >= trigger_x_left && 
					 (man_y+20) >= trigger_y_up && (man_y+20) <= trigger_y_down &&
					 inmap == 2'b01)
					trap_on_next = 1'b1;
				if (inmap == 2'b01 && trap_on)
				begin
					moving_counter_next = moving_counter+1;
					case (direction)
						2'b00: trap_y_next = trap_y-speed;
						2'b01: trap_x_next = trap_x+speed;
						2'b10: trap_x_next = trap_x-speed;
						2'b11: trap_y_next = trap_y+speed;
						default: ;
					endcase
				end
				if (moving_counter == 6'b111111)
				begin
					trap_on_next = 1'b0;
					moving_counter_next = 6'b111111;
				end
			end
		end
endmodule

module weaktrap(input  logic getshot,Clk,Reset,restart,
					 input  logic [1:0] direction,inmap,
					 input  logic [9:0] init_x,init_y,
					 output logic trap_on,
					 output logic [1:0] trapspikestate,	// 00->up, 01->right, 10->left, 11->down
					 output logic [9:0] trap_x,trap_y);
					 
		logic trap_on_next;
		logic [1:0] counter,counter_next;
		
		assign trapspikestate = direction;
		assign trap_x = init_x;
		assign trap_y = init_y;
			
		always_ff @(posedge Clk)
		begin
			if (Reset || restart)
			begin
				if (inmap==2'b00)
					trap_on <= 1'b1;
				else
					trap_on <= 1'b0;
				counter <= 2'b00;
			end
			else
			begin
				trap_on <= trap_on_next;
				counter <= counter_next;
			end
		end
		
		always_comb
		begin
			counter_next = counter;
			trap_on_next = trap_on;
			if (inmap != 2'b00)
				trap_on_next = 1'b0;
			if (getshot && trap_on)
				counter_next = counter + 1;
			if (counter==2'b11)
			begin
				trap_on_next = 1'b0;
				counter_next = 2'b11;
			end
		end
endmodule

module istrap(input  logic Reset,frame_clk,restart,Clk,

				  input  logic getshot2,
								   getshot3,
								   getshot4,
								   getshot5,
								   getshot6,
								   getshot7,
									
				  input  logic [1:0] inmap,
											
				  input  logic [9:0] DrawX,DrawY,
											man_x,man_y,

				  output logic is_trap,
									weak_2,
									weak_3,
									weak_4,
									weak_5,
									weak_6,
									weak_7,

				  output logic [1:0] trapspikestate,
				  output logic [9:0] trap_x,trap_y
				 );
				 
					 
		 flytrap				trap0(.*,
										.init_x(13*32),
										.init_y(7*32),
										.trigger_x_left(11*32),
										.trigger_x_right(12*32),
										.trigger_y_up(6*32),
										.trigger_y_down(9*32),
										.direction(2'b10),	// 00->up, 01->right, 10->left, 11->down
										.speed(10'd2),
										.trap_on(trap0_on),
										.trapspikestate(trap0spikestate),
										.trap_x(trap0_x),
										.trap_y(trap0_y));
										
		 flytrap				trap1(.*,
										.init_x(13*32),
										.init_y(8*32),
										.trigger_x_left(11*32),
										.trigger_x_right(12*32),
										.trigger_y_up(6*32),
										.trigger_y_down(9*32),
										.direction(2'b10),	// 00->up, 01->right, 10->left, 11->down
										.speed(10'd2),
										.trap_on(trap1_on),
										.trapspikestate(trap1spikestate),
										.trap_x(trap1_x),
										.trap_y(trap1_y));
										
		 weaktrap			trap2(.*,
										.getshot(getshot2),
										.init_x(12*32),
										.init_y(2*32),
										.direction(2'b00),	// 00->up, 01->right, 10->left, 11->down
										.trap_on(trap2_on),
										.trapspikestate(trap2spikestate),
										.trap_x(trap2_x),
										.trap_y(trap2_y));
										
		 weaktrap			trap3(.*,
										.getshot(getshot3),
										.init_x(13*32),
										.init_y(2*32),
										.direction(2'b00),	// 00->up, 01->right, 10->left, 11->down
										.trap_on(trap3_on),
										.trapspikestate(trap3spikestate),
										.trap_x(trap3_x),
										.trap_y(trap3_y));
										
		 weaktrap			trap4(.*,
										.getshot(getshot4),
										.init_x(14*32),
										.init_y(2*32),
										.direction(2'b00),	// 00->up, 01->right, 10->left, 11->down
										.trap_on(trap4_on),
										.trapspikestate(trap4spikestate),
										.trap_x(trap4_x),
										.trap_y(trap4_y));
										
		 weaktrap			trap5(.*,
										.getshot(getshot5),
										.init_x(15*32),
										.init_y(2*32),
										.direction(2'b00),	// 00->up, 01->right, 10->left, 11->down
										.trap_on(trap5_on),
										.trapspikestate(trap5spikestate),
										.trap_x(trap5_x),
										.trap_y(trap5_y));
										
		 weaktrap			trap6(.*,
										.getshot(getshot6),
										.init_x(16*32),
										.init_y(2*32),
										.direction(2'b00),	// 00->up, 01->right, 10->left, 11->down
										.trap_on(trap6_on),
										.trapspikestate(trap6spikestate),
										.trap_x(trap6_x),
										.trap_y(trap6_y));
		 weaktrap			trap7(.*,
										.getshot(getshot7),
										.init_x(17*32),
										.init_y(2*32),
										.direction(2'b00),	// 00->up, 01->right, 10->left, 11->down
										.trap_on(trap7_on),
										.trapspikestate(trap7spikestate),
										.trap_x(trap7_x),
										.trap_y(trap7_y));
										
		 flytrap				trap8(.*,
										.init_x(17*32),
										.init_y(5*32),
										.trigger_x_left(17*32-5),
										.trigger_x_right(640),
										.trigger_y_up(3*32-5),
										.trigger_y_down(6*32),
										.direction(2'b00),	// 00->up, 01->right, 10->left, 11->down
										.speed(10'd5),
										.trap_on(trap8_on),
										.trapspikestate(trap8spikestate),
										.trap_x(trap8_x),
										.trap_y(trap8_y));

		 flytrap				trap9(.*,
										.init_x(18*32),
										.init_y(5*32),
										.trigger_x_left(17*32-5),
										.trigger_x_right(640),
										.trigger_y_up(3*32-5),
										.trigger_y_down(6*32),
										.direction(2'b00),	// 00->up, 01->right, 10->left, 11->down
										.speed(10'd5),
										.trap_on(trap9_on),
										.trapspikestate(trap9spikestate),
										.trap_x(trap9_x),
										.trap_y(trap9_y));									
										
		 flytrap				trap10(.*,
										.Reset(Reset_h),
										.frame_clk(VGA_VS),
										.init_x(19*32),
										.init_y(5*32),
										.trigger_x_left(17*32-5),
										.trigger_x_right(640),
										.trigger_y_up(3*32-5),
										.trigger_y_down(6*32),
										.direction(2'b00),	// 00->up, 01->right, 10->left, 11->down
										.speed(10'd5),
										.trap_on(trap10_on),
										.trapspikestate(trap10spikestate),
										.trap_x(trap10_x),
										.trap_y(trap10_y));		
				 
		 logic trap0_on,
				 trap1_on,
				 trap2_on,
				 trap3_on,
				 trap4_on,
				 trap5_on,
				 trap6_on,
				 trap7_on,
				 trap8_on,
				 trap9_on,
				 trap10_on;
					 
		 logic [1:0] trap0spikestate,
						 trap1spikestate,
						 trap2spikestate,
						 trap3spikestate,
						 trap4spikestate,
						 trap5spikestate,
						 trap6spikestate,
						 trap7spikestate,
						 trap8spikestate,
						 trap9spikestate,
						 trap10spikestate;
						 
		 logic [9:0] trap0_x,trap0_y,
						 trap1_x,trap1_y,
						 trap2_x,trap2_y,
						 trap3_x,trap3_y,
						 trap4_x,trap4_y,
						 trap5_x,trap5_y,
						 trap6_x,trap6_y,
						 trap7_x,trap7_y,
						 trap8_x,trap8_y,
						 trap9_x,trap9_y,
						 trap10_x,trap10_y;
					 
		always_comb
		begin
			is_trap = 1'b0;
			trapspikestate = 2'b00;
			trap_x = 10'b0;
			trap_y = 10'b0;
			weak_2 = 1'b0;
			weak_3 = 1'b0;
			weak_4 = 1'b0;
			weak_5 = 1'b0;
			weak_6 = 1'b0;
			weak_7 = 1'b0;
			if (DrawX-trap0_x < 32 && DrawY-trap0_y < 32 && trap0_on)
			begin
				trap_x = DrawX-trap0_x;
				trap_y = DrawY-trap0_y;
				trapspikestate = trap0spikestate;
				is_trap = 1'b1;
			end
			else if (DrawX-trap1_x < 32 && DrawY-trap1_y < 32 && trap1_on)
			begin
				trap_x = DrawX-trap1_x;
				trap_y = DrawY-trap1_y;
				trapspikestate = trap1spikestate;
				is_trap = 1'b1;
			end
			else if (DrawX-trap2_x < 32 && DrawY-trap2_y < 32 && trap2_on)
			begin
				trap_x = DrawX-trap2_x;
				trap_y = DrawY-trap2_y;
				trapspikestate = trap2spikestate;
				is_trap = 1'b1;
				weak_2 = 1'b1;
			end
			else if (DrawX-trap3_x < 32 && DrawY-trap3_y < 32 && trap3_on)
			begin
				trap_x = DrawX-trap3_x;
				trap_y = DrawY-trap3_y;
				trapspikestate = trap3spikestate;
				is_trap = 1'b1;
				weak_3 = 1'b1;
			end
			else if (DrawX-trap4_x < 32 && DrawY-trap4_y < 32 && trap4_on)
			begin
				trap_x = DrawX-trap4_x;
				trap_y = DrawY-trap4_y;
				trapspikestate = trap4spikestate;
				is_trap = 1'b1;
				weak_4 = 1'b1;
			end
			else if (DrawX-trap5_x < 32 && DrawY-trap5_y < 32 && trap5_on)
			begin
				trap_x = DrawX-trap5_x;
				trap_y = DrawY-trap5_y;
				trapspikestate = trap5spikestate;
				is_trap = 1'b1;
				weak_5 = 1'b1;
			end
			else if (DrawX-trap6_x < 32 && DrawY-trap6_y < 32 && trap6_on)
			begin
				trap_x = DrawX-trap6_x;
				trap_y = DrawY-trap6_y;
				trapspikestate = trap6spikestate;
				is_trap = 1'b1;
				weak_6 = 1'b1;
			end
			else if (DrawX-trap7_x < 32 && DrawY-trap7_y < 32 && trap7_on)
			begin
				trap_x = DrawX-trap7_x;
				trap_y = DrawY-trap7_y;
				trapspikestate = trap7spikestate;
				is_trap = 1'b1;
				weak_7 = 1'b1;
			end
			else if (DrawX-trap8_x < 32 && DrawY-trap8_y < 32 && trap8_on)
			begin
				trap_x = DrawX-trap8_x;
				trap_y = DrawY-trap8_y;
				trapspikestate = trap8spikestate;
				is_trap = 1'b1;
			end
			else if (DrawX-trap9_x < 32 && DrawY-trap9_y < 32 && trap9_on)
			begin
				trap_x = DrawX-trap9_x;
				trap_y = DrawY-trap9_y;
				trapspikestate = trap9spikestate;
				is_trap = 1'b1;
			end
			else if (DrawX-trap10_x < 32 && DrawY-trap10_y < 32 && trap10_on)
			begin
				trap_x = DrawX-trap10_x;
				trap_y = DrawY-trap10_y;
				trapspikestate = trap10spikestate;
				is_trap = 1'b1;
			end
		end
		
endmodule
