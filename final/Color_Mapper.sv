//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  10-06-2017                               --
//                                                                       --
//    Fall 2017 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 8                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------

// color_mapper: Decide which color to be output to VGA for each pixel.
module  color_mapper ( input  logic Clk, is_right,is_block,is_spike,is_check,is_dead,checking,
                       input 	logic [9:0] man_x,man_y,
							  input  logic [9:0] map_x,map_y,
							  input  logic [9:0] DrawX, DrawY,
							  input  logic [3:0] tenths, ones,
							  input  logic [1:0]	man_state,			// 00 -> idle, 01 -> x-walk, 10 -> jump, 11 -> fall
							  input  logic [1:0] man_graph_counter,
							  output logic dead,check,
							  output logic [7:0] VGA_R, VGA_G, VGA_B
                     );

							
	//	background bg(.*,.read_address(DrawX+(DrawY*10'd640)),.data_Out(bgcolor));
	//	paint_background pbg(.color(bgcolor),.r(bg_r),.g(bg_g),.b(bg_b));

		kid_idle 		idle0(.*,
								  .read_address(man_graph_counter*10'd26+x+(y*10'd104)),
								  .data_Out(idle));
		kid_walk 		walk0(.*,
								  .read_address(man_graph_counter*10'd26+x+(y*10'd104)),
								  .data_Out(walk));
		kid_jump 		jump0(.*,
								  .read_address(x+(y*10'd52)),
								  .data_Out(jump));
		kid_jump 		fall0(.*,
								  .read_address(10'd26+x+(y*10'd52)),
								  .data_Out(fall));
		block 			block0(.*,
								  .read_address(DrawX-map_x+(DrawY-map_y*10'd32)),
								  .data_Out(blockcolor));
		spike 			spike0(.*,
								  .read_address(DrawX-map_x+(DrawY-map_y*10'd64)),
								  .data_Out(spikecolor));
		checkpoint		check0(.*,
								  .read_address(checking*10'd32+DrawX-map_x+(DrawY-map_y*10'd64)),
								  .data_Out(checkcolor));
		dead				dead0(.*,
								  .read_address(dead_x+(dead_y*10'd320)),
								  .data_Out(deadcolor));
		font_rom			font0(.*);
		
		logic [7:0] r,g,b,bg_r,bg_g,bg_b;
		logic [11:0] x,y;
		logic [3:0] kidcolor,bgcolor,idle,walk,jump,fall,spikecolor,checkcolor,blockcolor,deadcolor;
		logic [14:0] dead_x,dead_y;
		logic [10:0] addr,data;
		logic is_kid,is_bg,d_on,e_on,a_on,t_on,h_on,colon_on,tenths_on,ones_on;
		 
		 
		// Output colors to VGA
		assign VGA_R = r;
		assign VGA_G = g;
		assign VGA_B = b;
		assign dead_x = DrawX-10'd159;
		assign dead_y = DrawY-10'd190;

		always_comb
		begin
			x = 10'd0;
			y = 10'd0;
			is_kid = 1'b0;
			is_bg = 1'b1;
			dead = 1'b0;
			check = 1'b0;
			d_on = 1'b0;
			e_on = 1'b0;
			a_on = 1'b0;
			t_on = 1'b0;
			h_on = 1'b0;
			colon_on = 1'b0;
			tenths_on = 1'b0;
			ones_on = 1'b0;
			
			// death counter
			if (DrawX >= 32+0*8 && DrawX < 32+1*8 &&
				 DrawY >= 32 && DrawY < 32+16)
			begin
				d_on = 1'b1;
				addr = DrawY-32+16*'h0b;
			end
			if (DrawX >= 32+1*8 && DrawX < 32+2*8 &&
				 DrawY >= 32 && DrawY < 32+16)
			begin
				e_on = 1'b1;
				addr = DrawY-32+16*'h0c;
			end
			if (DrawX >= 32+2*8 && DrawX < 32+3*8 &&
				 DrawY >= 32 && DrawY < 32+16)
			begin
				a_on = 1'b1;
				addr = DrawY-32+16*'h0d;
			end
			if (DrawX >= 32+3*8 && DrawX < 32+4*8 &&
				 DrawY >= 32 && DrawY < 32+16)
			begin
				t_on = 1'b1;
				addr = DrawY-32+16*'h0e;
			end
			if (DrawX >= 32+4*8 && DrawX < 32+5*8 &&
				 DrawY >= 32 && DrawY < 32+16)
			begin
				h_on = 1'b1;
				addr = DrawY-32+16*'h0f;
			end
			if (DrawX >= 32+5*8 && DrawX < 32+6*8 &&
				 DrawY >= 32 && DrawY < 32+16)
			begin
				colon_on = 1'b1;
				addr = DrawY-32+16*'h10;
			end
			if (DrawX >= 32+6*8 && DrawX < 32+7*8 &&
				 DrawY >= 32 && DrawY < 32+16)
			begin
				tenths_on = 1'b1;
				addr = DrawY-32+16*('h01+tenths);
			end
			if (DrawX >= 32+7*8 && DrawX < 32+8*8 &&
				 DrawY >= 32 && DrawY < 32+16)
			begin
				ones_on = 1'b1;
				addr = DrawY-32+16*('h01+ones);
			end
			
			// kid
			if (DrawX >= man_x && DrawX-man_x < 10'd26 && 
				 DrawY >= man_y && DrawY-man_y < 10'd25)
			begin
				is_kid = 1'b1;
				if (is_right)
				begin
					x = DrawX-man_x;
					y = DrawY-man_y;
				end
				else
				begin
					x = 10'd25-DrawX+man_x;
					y = DrawY-man_y;
				end
			end
			if (is_kid && kidcolor > 4'b0000 && 
				 is_spike && spikecolor > 4'b0000 || man_y+10'd23>10'd480 || man_y-10'd1<10'd0)
				dead = 1'b1;
			if (is_kid && kidcolor > 4'b0000 && is_check && checkcolor > 4'b0000)
				check = 1'b1;
			case (man_state)
				2'b00: kidcolor = idle;
				2'b01: kidcolor = walk;
				2'b10: kidcolor = jump;
				2'b11: kidcolor = fall;
			endcase
		end
		 
		always_comb
		begin
		 
			// background
	//		r = bg_r;
	//		g = bg_g;
	//		b = bg_b;
			r = 8'hff;
			g = 8'hff;
			b = 8'hff;			
			
			if (is_dead)
			begin
				if (dead_x < 10'd320 && dead_y < 10'd99)
					case (deadcolor)
						4'b0001:
							begin
							r = 8'h00;
							g = 8'h00;
							b = 8'h00;
							end
						4'b0010:
							begin
							r = 8'hff;
							g = 8'hff;
							b = 8'hff;
							end
						default: 
							begin
							r = 8'h5a;
							g = 8'h5a;
							b = 8'h5a;
							end
					endcase
				else
				begin
					r = 8'h5a;
					g = 8'h5a;
					b = 8'h5a;
				end
			end			// end for is_dead
			
			else			// not dead
			begin
				if (is_block)
				begin
					case (blockcolor)
						4'b0100:
						begin
							r = 8'hab;
							g = 8'hf4;
							b = 8'hf9;
						end
						default: ;
					endcase
				end
				
				else		// not a block
				begin
					if (is_spike)
					begin
						case (spikecolor)
							4'b0001:
							begin
								r = 8'h00;
								g = 8'h00;
								b = 8'h00;
							end
							4'b0010:
							begin
								r = 8'hef;
								g = 8'heb;
								b = 8'hef;
							end
							4'b0011:
							begin
								r = 8'h94;
								g = 8'h96;
								b = 8'h94;
							end
							4'b0100:
							begin
								r = 8'hd6;
								g = 8'hd7;
								b = 8'hd6;
							end
							default: ;
						endcase
					end
					
					if (is_check)
					begin
						case (checkcolor)
							4'b0001:
							begin
								r = 8'h00;
								g = 8'h00;
								b = 8'h00;
							end
							4'b0010:
							begin
								r = 8'h73;
								g = 8'h71;
								b = 8'h73;
							end
							4'b0011:
							begin
								r = 8'hde;
								g = 8'hdb;
								b = 8'hde;
							end
							4'b0100:
							begin
								r = 8'hef;
								g = 8'h41;
								b = 8'h10;
							end
							4'b0101:
							begin
								r = 8'hde;
								g = 8'hd7;
								b = 8'h42;
							end
							4'b0110:
							begin
								r = 8'h7b;
								g = 8'h8e;
								b = 8'h29;
							end
							4'b0111:
							begin
								r = 8'h00;
								g = 8'hff;
								b = 8'h00;
							end
							default: ;
						endcase
					end
					
					if (is_kid && kidcolor > 4'b0000 &&
						(is_bg || is_check || is_spike && spikecolor==4'b0000))	
						// paint kid if the pixel is kid and is background
					begin
						case (kidcolor)
							4'b0001:
								begin
								r = 8'h00;
								g = 8'h00;
								b = 8'h00;
								end
							4'b0010:
								begin
								r = 8'h3f;
								g = 8'h06;
								b = 8'h06;
								end
							4'b0011:
								begin
								r = 8'hab;
								g = 8'h00;
								b = 8'h00;
								end
							4'b0100:
								begin
								r = 8'h5a;
								g = 8'h27;
								b = 8'h12;
								end
							4'b0101:
								begin
								r = 8'hff;
								g = 8'hc7;
								b = 8'h8f;
								end
							4'b0110:
								begin
								r = 8'h15;
								g = 8'h42;
								b = 8'h69;
								end
							4'b0111:
								begin
								r = 8'h11;
								g = 8'h1a;
								b = 8'h8f;
								end
							default: ;
						endcase
					end		// end for paint kid (is kid and is background)
				end			// end for not a block
				
				if (d_on 		&& data[DrawX-32+0*8] ||
					 e_on 		&& data[DrawX-32+1*8] ||
					 a_on 		&& data[DrawX-32+2*8] ||
					 t_on 		&& data[DrawX-32+3*8] ||
					 h_on 		&& data[DrawX-32+4*8] ||
					 colon_on 	&& data[DrawX-32+5*8] ||
					 tenths_on 	&& data[DrawX-32+6*8] ||
					 ones_on 	&& data[DrawX-32+7*8])
				begin
					r = 8'h3f;
					g = 8'h00;
					b = 8'h7f - {1'b0,DrawX[9:3]};
				end
			end				// end for not dead
		end 				// end for always_comb
    
endmodule
