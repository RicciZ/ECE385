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
module  color_mapper ( input  logic Clk,frame_clk,Reset,god,button,
												is_block,is_spike,is_check,
												is_right,is_dead,checking,restart,
												bullet1_active,bullet2_active,bullet3_active,
												is_trap,
												weak_2,
												weak_3,
												weak_4,
												weak_5,
												weak_6,
												weak_7,
                       input  logic [1:0]	man_state,			// 00 -> idle, 01 -> x-walk, 10 -> jump, 11 -> fall
														man_graph_counter,
														mapspikestate,
														inmap,
														trapspikestate,
							  input  logic [3:0] tenths, ones,
							  input 	logic [9:0] man_x,man_y,
														mapx,mapy,
														DrawX, DrawY,
														bullet1_x,bullet1_y,
														bullet2_x,bullet2_y,
														bullet3_x,bullet3_y,
														trap_x,trap_y,
							  output logic dead,
												check,
												hit,
												bullet1_off,
												bullet2_off,
												bullet3_off,
												getshot2,
												getshot3,
												getshot4,
												getshot5,
												getshot6,
												getshot7,
							  output logic [7:0] VGA_R, VGA_G, VGA_B
                     );


		background bg(.*,.read_address(DrawX+(DrawY*10'd640)),.data_Out(bgcolor));
		paint_background pbg(.*,.r(bg_r),.g(bg_g),.b(bg_b));

		kid_idle 		idle0(.*,
								  .read_address(man_graph_counter*26+x+(y*104)),
								  .data_Out(idle));
		kid_walk 		walk0(.*,
								  .read_address(man_graph_counter*26+x+(y*104)),
								  .data_Out(walk));
		kid_jump 		jump0(.*,
								  .read_address(x+(y*52)),
								  .data_Out(jump));
		kid_jump 		fall0(.*,
								  .read_address(26+x+(y*52)),
								  .data_Out(fall));
		block 			block0(.*,
								  .read_address(map_x+(map_y*32)),
								  .data_Out(blockcolor));
		spike 			spike0(.*,
								  .read_address(spike_state*32+map_x+(map_y*128)),
								  .data_Out(spikecolor));
		checkpoint		check0(.*,
								  .read_address(checking*32+map_x+(map_y*64)),
								  .data_Out(checkcolor));
		dead				dead0(.*,
								  .read_address(dead_x+(dead_y*320)),
								  .data_Out(deadcolor));
		font_rom			font0(.*);									
		
		
		logic is_kid,is_bg,is_bullet1,is_bullet2,is_bullet3,
				d_on,e_on,a_on,t_on,h_on,colon_on,tenths_on,ones_on;
		logic [1:0] spike_state;
		logic [3:0] kidcolor,bgcolor,idle,walk,jump,fall,spikecolor,checkcolor,
						blockcolor,deadcolor;
		logic [7:0] r,g,b,bg_r,bg_g,bg_b,data;
		logic [10:0] addr;
		logic [11:0] x,y,map_x,map_y;
		logic [14:0] dead_x,dead_y;
		
		parameter [9:0] bullet_size = 10'd2;
		 
		assign VGA_R = r;
		assign VGA_G = g;
		assign VGA_B = b;
		assign dead_x = DrawX-10'd159;
		assign dead_y = DrawY-10'd190;
		
		int DistX1,DistY1,
			 DistX2,DistY2,
			 DistX3,DistY3,
			 Size;
		assign DistX1 = DrawX - bullet1_x;
		assign DistY1 = DrawY - bullet1_y;
		assign DistX2 = DrawX - bullet2_x;
		assign DistY2 = DrawY - bullet2_y;
		assign DistX3 = DrawX - bullet3_x;
		assign DistY3 = DrawY - bullet3_y;
		assign Size = bullet_size;

		always_comb				// signal processing (define this pixel)
		begin
			x = 10'd0;
			y = 10'd0;			// used for reading from kid rom
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
			addr = 11'b0;		// used for reading from font rom
			
			map_x = 10'b0;
			map_y = 10'b0;		// used for reading from map rom
			spike_state = 2'b00;
			hit = 1'b0;
			
			is_bullet1 = 1'b0;
			is_bullet2 = 1'b0;
			is_bullet3 = 1'b0;
			bullet1_off = 1'b0;
         bullet2_off = 1'b0;
			bullet3_off = 1'b0;
			getshot2 = 1'b0;
			getshot3 = 1'b0;
			getshot4 = 1'b0;
			getshot5 = 1'b0;
			getshot6 = 1'b0;
			getshot7 = 1'b0;
			
			// death counter
			if (DrawX >= 32+0*8 && DrawX < 32+1*8 &&
				 DrawY >= 32 && DrawY < 32+16)
			begin
				d_on = 1'b1;
				addr = DrawY-32+16*'h0a;
			end
			else if (DrawX >= 32+1*8 && DrawX < 32+2*8 &&
				 DrawY >= 32 && DrawY < 32+16)
			begin
				e_on = 1'b1;
				addr = DrawY-32+16*'h0b;
			end
			else if (DrawX >= 32+2*8 && DrawX < 32+3*8 &&
				 DrawY >= 32 && DrawY < 32+16)
			begin
				a_on = 1'b1;
				addr = DrawY-32+16*'h0c;
			end
			else if (DrawX >= 32+3*8 && DrawX < 32+4*8 &&
				 DrawY >= 32 && DrawY < 32+16)
			begin
				t_on = 1'b1;
				addr = DrawY-32+16*'h0d;
			end
			else if (DrawX >= 32+4*8 && DrawX < 32+5*8 &&
				 DrawY >= 32 && DrawY < 32+16)
			begin
				h_on = 1'b1;
				addr = DrawY-32+16*'h0e;
			end
			else if (DrawX >= 32+5*8 && DrawX < 32+6*8 &&
				 DrawY >= 32 && DrawY < 32+16)
			begin
				colon_on = 1'b1;
				addr = DrawY-32+16*'h0f;
			end
			else if (DrawX >= 32+6*8 && DrawX < 32+7*8 &&
				 DrawY >= 32 && DrawY < 32+16)
			begin
				tenths_on = 1'b1;
				addr = DrawY-32+16*tenths;
			end
			else if (DrawX >= 32+7*8 && DrawX < 32+8*8 &&
				 DrawY >= 32 && DrawY < 32+16)
			begin
				ones_on = 1'b1;
				addr = DrawY-32+16*ones;
			end
				
			// map
			if (is_block || is_spike || is_check)
			begin
				is_bg = 1'b0;
				map_x = DrawX-mapx;
				map_y = DrawY-mapy;
				spike_state = mapspikestate;
			end
			
			// trap
			if (is_trap)
			begin
				map_x = trap_x;
				map_y = trap_y;
				spike_state = trapspikestate;
				is_bg = 1'b0;
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
			
			// bullet
			if ((DistX1*DistX1 + DistY1*DistY1) <= (Size*Size) && bullet1_active) 
            is_bullet1 = 1'b1;
			if ((DistX2*DistX2 + DistY2*DistY2) <= (Size*Size) && bullet2_active) 
            is_bullet2 = 1'b1;
			if ((DistX3*DistX3 + DistY3*DistY3) <= (Size*Size) && bullet3_active) 
            is_bullet3 = 1'b1;
			
			// bullet hit
			if ((is_spike || is_trap) && spikecolor > 4'b0000)
			begin				
				if (is_bullet1 || is_bullet2 || is_bullet3)
				begin
					if (weak_2) getshot2 = 1'b1;
					if (weak_3) getshot3 = 1'b1;
					if (weak_4) getshot4 = 1'b1;
					if (weak_5) getshot5 = 1'b1;
					if (weak_6) getshot6 = 1'b1;
					if (weak_7) getshot7 = 1'b1;
				end
				if (is_bullet1) bullet1_off = 1'b1;
				if (is_bullet2) bullet2_off = 1'b1;
				if (is_bullet3) bullet3_off = 1'b1;
			end
			
			if ((is_bullet1 || is_bullet2 || is_bullet3) &&
				 DrawX/10'd32==5 && DrawY/10'd32==9)
				 hit = 1'b1;
			
			if (~god && (is_kid && kidcolor > 4'b0000 && kidcolor != 4'b0011 && 
				 (is_spike || is_trap) && spikecolor > 4'b0000 || 
				 inmap && man_y+10'd23>10'd480 || man_y-10'd1<10'd0))
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
		 
		always_comb					// draw (assign r,g,b)
		begin
			// background
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
					if (~button)
						case (blockcolor)
							4'b0100:
							begin
								r = 8'hab;
								g = 8'hf4;
								b = 8'hf9;
							end
							default: ;
						endcase
					else
						case (blockcolor)
							4'b0100:
							begin
								r = 8'hff-8'hab;
								g = 8'hff-8'hf4;
								b = 8'hff-8'hf9;
							end
							default: ;
						endcase
				end
				
				else		// not a block
				begin
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
					
					if (is_spike || is_trap)
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
										
					if (inmap == 2'b10)	// win
					begin
						r = bg_r;
						g = bg_g;
						b = bg_b;
//						r = 8'hff;
//						g = 8'hff;
//						b = 8'hff;
					end
					
					if (is_bullet1 || is_bullet2 || is_bullet3)
					begin
						r = 8'h3f;
						g = 8'h00;
						b = 8'h7f - {1'b0,DrawX[9:3]};
					end
					
					if (is_kid && kidcolor > 4'b0000 &&
						(is_bg || is_check || (is_trap || is_spike) && spikecolor==4'b0000))	
						// paint kid if the pixel is kid and is background
					begin
						if (~god)			// not god mode
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
						else					// god mode
							case (kidcolor)
								4'b0001:
									begin
									r = 8'h00;
									g = 8'h00;
									b = 8'h00;
									end
								4'b0010:
									begin
									r = 8'hff-8'h3f;
									g = 8'hff-8'h06;
									b = 8'hff-8'h06;
									end
								4'b0011:
									begin
									r = 8'hff-8'hab;
									g = 8'hff-8'h00;
									b = 8'hff-8'h00;
									end
								4'b0100:
									begin
									r = 8'hff-8'h5a;
									g = 8'hff-8'h27;
									b = 8'hff-8'h12;
									end
								4'b0101:
									begin
									r = 8'hff-8'hff;
									g = 8'hff-8'hc7;
									b = 8'hff-8'h8f;
									end
								4'b0110:
									begin
									r = 8'hff-8'h15;
									g = 8'hff-8'h42;
									b = 8'hff-8'h69;
									end
								4'b0111:
									begin
									r = 8'hff-8'h11;
									g = 8'hff-8'h1a;
									b = 8'hff-8'h8f;
									end
								default: ;
							endcase
					end		// end for paint kid (is kid and is background)
				end			// end for not a block
				
				if (d_on 		&& data[8-(DrawX-32+0*8)] ||
					 e_on 		&& data[8-(DrawX-32+1*8)] ||
					 a_on 		&& data[8-(DrawX-32+2*8)] ||
					 t_on 		&& data[8-(DrawX-32+3*8)] ||
					 h_on 		&& data[8-(DrawX-32+4*8)] ||
					 colon_on 	&& data[8-(DrawX-32+5*8)] ||
					 tenths_on 	&& data[8-(DrawX-32+6*8)] ||
					 ones_on 	&& data[8-(DrawX-32+7*8)])			// death counter
				begin
					r = 8'h3f;
					g = 8'h00;
					b = 8'h7f - {1'b0,DrawX[9:3]};
				end				// end for death counter
			end					// end for not dead
		end 						// end for always_comb
    
endmodule
