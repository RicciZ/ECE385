module map(input  logic [9:0] DrawX,DrawY,
			  input  logic [9:0] man_x,man_y,
			  output logic is_block,is_spike,is_check,
			  output logic [9:0] map_x,map_y,
			  output logic [3:0] barrier);

		integer i,j;
		logic [1:0] map [299:0];		// 00->background, 01->block, 10->spike, 11->checkpoint

		always_comb			// create map
		begin
			// init background
			for (i=0;i<300;i++)
				map[i] = 2'b00;
			// init floor
			for (i=0;i<9;i++)		// bottom
			begin
				map[i+13*20] = 2'b01;
				map[i+14*20] = 2'b01;
			end
			map[0+12*20] = 2'b01;
			map[19+12*20] = 2'b01;
			for (i=11;i<20;i++)		// bottom
			begin
				map[i+13*20] = 2'b01;
				map[i+14*20] = 2'b01;
			end
			for (i=6;i<14;i++)
			begin
				map[i+9*20] = 2'b01;
				map[i+6*20] = 2'b01;
				map[i+3*20] = 2'b01;
			end
			
			// init spike
			for (i=8;i<14;i+=2)
				map[i+12*20] = 2'b10;
				
			// init checkpoint
			map[3+11*20] = 2'b11;
			map[17+11*20] = 2'b11;
			
			// init trap
			if (man_x >= 16*10'd32)
				for (i=10;i<17;i++)
					map[i+12*20] = 2'b10;
		
			is_block = 1'b0;
			is_spike = 1'b0;
			is_check = 1'b0;
			map_x = DrawX/10'd32*10'd32;
			map_y = DrawY/10'd32*10'd32;

			if (map[DrawX/10'd32+DrawY/10'd32*10'd20]==2'b01)
				is_block = 1'b1;
			else if (map[DrawX/10'd32+DrawY/10'd32*10'd20]==2'b10)
				is_spike = 1'b1;
			else if (map[DrawX/10'd32+DrawY/10'd32*10'd20]==2'b11)
				is_check = 1'b1;
		end

		always_comb
		begin
			barrier = 4'b1111;
			if (map[(man_x+26)/32+(man_y+11)/32*20]==2'b01 || 
				 map[(man_x+23)/32+(man_y+ 5)/32*20]==2'b01 ||
				 map[(man_x+22)/32+(man_y+19)/32*20]==2'b01 ||
				 man_x+26>=10'd640)
				barrier[0] = 1'b0;
			if (map[(man_x-1)/32+(man_y+11)/32*20]==2'b01 ||
				 map[(man_x+3)/32+(man_y+ 5)/32*20]==2'b01 ||
				 map[(man_x+4)/32+(man_y+19)/32*20]==2'b01 ||
				 man_x-10'd1<=10'd0)
				barrier[1] = 1'b0;
			if (map[(man_x+ 4)/32+(man_y-1)/32*20]==2'b01 ||
				 map[(man_x+13)/32+(man_y-1)/32*20]==2'b01 ||
				 map[(man_x+21)/32+(man_y-1)/32*20]==2'b01)
				barrier[2] = 1'b0;
			if (map[(man_x+ 9)/32+(man_y+24)/32*20]==2'b01 ||
				 map[(man_x+21)/32+(man_y+24)/32*20]==2'b01 ||
				 map[(man_x+ 6)/32+(man_y+24)/32*20]==2'b01)
				barrier[3] = 1'b0;
		end

endmodule
