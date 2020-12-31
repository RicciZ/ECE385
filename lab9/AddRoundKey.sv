module AddRoundKey ( input  logic [127:0]  in,
							input  logic [1407:0] keys,
							input  logic [3:0]    round,
							output logic [127:0]  out );
	
	logic [127:0] RoundKey;
	
	always_comb
		begin
			case(round)
				4'b1010:
					RoundKey = keys[1407:1280];
				4'b1001:
					RoundKey = keys[1279:1152];
				4'b1000:
					RoundKey = keys[1151:1024];
				4'b0111:
					RoundKey = keys[1023:896];
				4'b0110:
					RoundKey = keys[895:768];
				4'b0101:
					RoundKey = keys[767:640];
				4'b0100:
					RoundKey = keys[639:512];
				4'b0011:
					RoundKey = keys[511:384];
				4'b0010:
					RoundKey = keys[383:256];
				4'b0001:
					RoundKey = keys[255:128];
				4'b0000:
					RoundKey = keys[127:0];
				default: RoundKey = 128'b0;
			endcase
		end
	assign out = in ^ RoundKey;				


							
							
							
							
endmodule
