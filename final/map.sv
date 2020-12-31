module map(input  logic Clk,Reset,restart,
			  input  logic [9:0] DrawX,DrawY,
			  input  logic [9:0] man_x,man_y,
			  input  logic thorn1,thorn2,thorn3,thorn4,
			  output logic is_block,is_spike,is_check,reset1,reset2,reset3,victory,button,
			  output logic [9:0] mapx,mapy,
			  output logic [1:0] mapspikestate, // 00->up, 01->right, 10->left, 11->down
										inmap,			// 00->map0, 01->map1, 10->victory
			  output logic [3:0] barrier);
			  
		barrier_detect		bd0(.*);

		integer i,j;
		logic [1:0] inmap_next;
		logic [1:0] map [599:0];		// 00->background, 01->block, 10->spike, 11->checkpoint
		logic [1:0] spikemap [599:0];	// 00->up, 01->right, 10->left, 11->down
		
		always_comb					// create map0
		begin
			// init
			for (i=0;i<300;i++)
			begin
				map[i] = 2'b00;
				spikemap[i] = 2'b00;
			end

			// init floor
			for (i=0;i<5;i++)		// bottom
			begin
				map[i+10*20] = 2'b01;
				map[i+9*20] = 2'b01;
				map[i+4+8*20] = 2'b01;
				map[i+4+7*20] = 2'b01;
				map[i+8+6*20] = 2'b01;
				map[i+8+5*20] = 2'b01;
			end
			for (i=12;i<20;i++)
			begin
				map[i+4*20] = 2'b01;
				map[i+3*20] = 2'b01;			
				map[i+14*20] = 2'b01;
				map[i+13*20] = 2'b01;
			end
			map[19+2*20] = 2'b01;
			map[5+9*20] = 2'b01;
			
			// init spike
			map[ 3+8*20] = 2'b10;
			map[ 3+7*20] = 2'b10;
			map[ 7+6*20] = 2'b10;
			map[ 7+5*20] = 2'b10;
			map[11+4*20] = 2'b10;
			map[11+3*20] = 2'b10;

			spikemap[ 3+8*20] = 2'b10;
			spikemap[ 3+7*20] = 2'b10;
			spikemap[ 7+6*20] = 2'b10;
			spikemap[ 7+5*20] = 2'b10;
			spikemap[11+4*20] = 2'b10;
			spikemap[11+3*20] = 2'b10;
			
			map[12+14*20] = 2'b10;
			map[12+13*20] = 2'b10;
			map[13+12*20] = 2'b10;
			
			spikemap[12+14*20] = 2'b10;
			spikemap[12+13*20] = 2'b10;
			spikemap[13+12*20] = 2'b00;
			
			map[ 8+14*20] = {thorn1,1'b0};
			map[ 9+14*20] = {thorn2,1'b0};
			map[10+14*20] = {thorn3,1'b0};
			map[11+14*20] = {thorn4,1'b0};
			
			// init checkpoint
			map[1+7*20] = 2'b11;
			map[19+11*20] = 2'b11;
		end
		
		always_comb					// create map1
		begin
			// init
			for (i=300;i<600;i++)
			begin
				map[i] = 2'b00;
				spikemap[i] = 2'b00;
			end

			// init floor
			for (i=0;i<9;i++)		// bottom
			begin
				map[300+i+13*20] = 2'b01;
				map[300+i+14*20] = 2'b01;
			end
			map[300+0+12*20] = 2'b01;
			map[300+19+12*20] = 2'b01;
			for (i=11;i<20;i++)
			begin
				map[300+i+13*20] = 2'b01;
				map[300+i+14*20] = 2'b01;
			end
			for (i=3;i<20;i++)
			begin
				map[300+i+6*20] = 2'b01;
			end
			for (i=0;i<17;i++)
			begin
				map[300+i+3*20] = 2'b01;
				map[300+i+9*20] = 2'b01;
			end
			map[300+0+2*20] = 2'b01;
			
			// init spike
			for (i=1;i<3;i++)
			begin
				map[300+i+2*20] = 2'b10;
				spikemap[300+i+2*20] = 2'b00;
			end
			for (i=11;i<18;i+=3)
			begin
				map[300+i+12*20] = 2'b10;
				spikemap[300+i+12*20] = 2'b00;
			end
			for (i=5;i<14;i+=4)
			begin
				map[300+i+5*20] = 2'b10;
				spikemap[300+i+5*20] = 2'b00;
			end
			for (i=7;i<12;i+=4)
			begin
				map[300+i+4*20] = 2'b10;
				spikemap[300+i+4*20] = 2'b11;
			end
			map[300+17+9*20] = 2'b10;
			spikemap[300+17+9*20] = 2'b01;
				
			// init checkpoint
			map[300+0+1*20] = 2'b11;
			map[300+1+7*20] = 2'b11;

			// init poping spike
			if (man_x >= 11*32 && man_x <= 17*32 && 
				 man_y >= 10*32 && man_y <= 11*32)
				for (i=11;i<17;i++)
				begin
					map[300+i+12*20] = 2'b10;
					spikemap[300+i+12*20] = 2'b00;
				end
			if (man_x >= 11*32 && man_x <= 17*32 && 
				 man_y >= 11*32 && man_y <= 13*32)
				for (i=12;i<14;i++)
					map[300+i+12*20] = 2'b00;
		end
		
		always_ff @(posedge Clk)
		begin
			if (Reset)
				inmap = 2'b00;
			else
				inmap <= inmap_next;
		end
		
		always_comb					// signal processing
		begin
			is_block = 1'b0;
			is_spike = 1'b0;
			is_check = 1'b0;
			reset1 = 1'b0;
			reset2 = 1'b0;
			reset3 = 1'b0;
			victory = 1'b0;
			button = 1'b0;
			inmap_next = inmap;
			mapspikestate = 2'b00;
			mapx = DrawX/10'd32*10'd32;
			mapy = DrawY/10'd32*10'd32;
			
			if (DrawX/10'd32==10'd5 && DrawY/10'd32==10'd9 && inmap==2'b00)
				button = 1'b1;
				
			if (inmap == 2'b00 && man_x+26 > 620 && man_y > 0 && man_y < 3*32)
			begin
				inmap_next = 2'b01;
				reset1 = 1'b1;
				victory = 1'b1;
			end
			
			if (inmap == 2'b01 && man_x < 6 && man_y > 10*32 && man_y < 13*32)
			begin
				inmap_next = 2'b00;
				reset2 = 1'b1;
				victory = 1'b1;
			end
			
			if (inmap == 2'b00 && man_x < 12*32 && (man_y+24) > 470)
			begin
				inmap_next = 2'b10;
				reset3 = 1'b1;
				victory = 1'b1;
			end
			
			if (map[inmap*300+DrawX/10'd32+DrawY/10'd32*10'd20]==2'b01)
				is_block = 1'b1;
			else if (map[inmap*300+DrawX/10'd32+DrawY/10'd32*10'd20]==2'b10)
			begin
				is_spike = 1'b1;
				mapspikestate = spikemap[inmap*300+DrawX/10'd32+DrawY/10'd32*10'd20];
			end
			else if (map[inmap*300+DrawX/10'd32+DrawY/10'd32*10'd20]==2'b11)
				is_check = 1'b1;
		end


endmodule
