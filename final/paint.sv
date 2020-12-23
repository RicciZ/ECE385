module paint_background(input logic [3:0] color,output [7:0] r,g,b);

	always_comb
	begin
		case (color)
			4'b0000:
				 begin
				 r = 8'hb3;
				 g = 8'h58;
				 b = 8'h10;
				 end
			4'b0001:
				 begin
				 r = 8'hec;
				 g = 8'h88;
				 b = 8'h11;
				 end
			4'b0010:
				 begin
				 r = 8'hff;
				 g = 8'ha8;
				 b = 8'h2a;
				 end
			4'b0011:
				 begin
				 r = 8'he4;
				 g = 8'ha5;
				 b = 8'h42;
				 end
			4'b0100:
				 begin
				 r = 8'he9;
				 g = 8'hc5;
				 b = 8'h65;
				 end
			4'b0101:
				 begin
				 r = 8'hf9;
				 g = 8'he1;
				 b = 8'h82;
				 end
			4'b0110:
				 begin
				 r = 8'hff;
				 g = 8'hc8;
				 b = 8'h5f;
				 end
			4'b0111:
				 begin
				 r = 8'hff;
				 g = 8'hd4;
				 b = 8'h6a;
				 end
			default:
				 begin
				 r = 8'hff;
				 g = 8'hff;
				 b = 8'hff;
				 end
		endcase
	end
	
endmodule
