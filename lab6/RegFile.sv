module Reg_File (
		input logic [2:0] SR1, SR2, DR,
		input logic [15:0] BUS,
		input logic Clk, Reset, LD_REG,
		output logic [15:0] SR1OUT,SR2OUT		
		);
		
	logic [7:0][15:0] Reg;
		
   always_ff @ (posedge Clk)
   begin
		if (Reset) //notice, this is a sycnrhonous reset, which is recommended on the FPGA
			begin
				Reg[0] <= 16'h0;
				Reg[1] <= 16'h0;
				Reg[2] <= 16'h0;
				Reg[3] <= 16'h0;
				Reg[4] <= 16'h0;
				Reg[5] <= 16'h0;
				Reg[6] <= 16'h0;
				Reg[7] <= 16'h0;
			end
		else if (LD_REG)
			begin
				unique case (DR)
				3'b000:		Reg[0]<=BUS;
				3'b001:		Reg[1]<=BUS;
				3'b010:		Reg[2]<=BUS;
				3'b011:		Reg[3]<=BUS;
				3'b100:		Reg[4]<=BUS;
				3'b101:		Reg[5]<=BUS;
				3'b110:		Reg[6]<=BUS;
				3'b111:		Reg[7]<=BUS;
				default: ;
				endcase
			end
	end
	
	always_comb
	begin
		unique case (SR1)
			3'b000:			SR1OUT = Reg[0];
			3'b001:			SR1OUT = Reg[1];
			3'b010:			SR1OUT = Reg[2];
			3'b011:			SR1OUT = Reg[3];
			3'b100:			SR1OUT = Reg[4];
			3'b101:			SR1OUT = Reg[5];
			3'b110:			SR1OUT = Reg[6];
			3'b111:			SR1OUT = Reg[7];
			default: ;
		endcase
		
		unique case (SR2)
			3'b000:			SR2OUT = Reg[0];
			3'b001:			SR2OUT = Reg[1];
			3'b010:			SR2OUT = Reg[2];
			3'b011:			SR2OUT = Reg[3];
			3'b100:			SR2OUT = Reg[4];
			3'b101:			SR2OUT = Reg[5];
			3'b110:			SR2OUT = Reg[6];
			3'b111:			SR2OUT = Reg[7];
			default: ;
		endcase
	end

		
endmodule
