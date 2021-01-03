module barrier_detect(input  logic [1:0] inmap,
							 input  logic [1:0] map [599:0],
							 input  logic [9:0] man_x,man_y,
							 output logic [3:0] barrier);

		always_comb
				begin
					barrier = 4'b1111;
					if (inmap == 2'b00 || inmap == 2'b01)
					begin
						if (map[inmap*300+(man_x+26)/32+(man_y+11)/32*20]==2'b01 || 
							 map[inmap*300+(man_x+23)/32+(man_y+ 5)/32*20]==2'b01 ||
							 map[inmap*300+(man_x+22)/32+(man_y+19)/32*20]==2'b01 ||
							 man_x+26>=10'd640)
							barrier[0] = 1'b0;		// right
						if (map[inmap*300+(man_x-1)/32+(man_y+11)/32*20]==2'b01 ||
							 map[inmap*300+(man_x+3)/32+(man_y+ 5)/32*20]==2'b01 ||
							 map[inmap*300+(man_x+4)/32+(man_y+19)/32*20]==2'b01 ||
							 man_x-10'd1<=10'd3)
							barrier[1] = 1'b0;		// left
						if (map[inmap*300+(man_x+ 4)/32+(man_y-1)/32*20]==2'b01 ||
							 map[inmap*300+(man_x+13)/32+(man_y-1)/32*20]==2'b01 ||
							 map[inmap*300+(man_x+21)/32+(man_y-1)/32*20]==2'b01 ||
							 man_y-10'd1<=10'd5)
							barrier[2] = 1'b0;		// up
						if (map[inmap*300+(man_x+ 9)/32+(man_y+24)/32*20]==2'b01 ||
							 map[inmap*300+(man_x+21)/32+(man_y+24)/32*20]==2'b01 ||
							 map[inmap*300+(man_x+ 6)/32+(man_y+24)/32*20]==2'b01)
							barrier[3] = 1'b0;		// down
					end
					else
					begin
						if (man_x+26>=10'd640)
							barrier[0] = 1'b0;
						if (man_x-1<=10'd10)
							barrier[1] = 1'b0;
						if (man_y-1<=10'd0)
							barrier[2] = 1'b0;
						if (man_y+23>=10'd400)
							barrier[3] = 1'b0;						
					end
				end
		
endmodule
