module mux_21 #(N = 16) (
		input  logic         select, 
		input  logic [N-1:0] in0, in1,
		output logic [N-1:0] out
		);
		
	always_comb
	begin
		unique case (select)
			1'b0:				out = in0;
			1'b1:				out = in1;
			default: ;
		endcase
	end

endmodule

module mux_41 #(N = 16) (
		input  logic [1:0]   select, 
		input  logic [N-1:0] in00, in01, in10, in11,
		output logic [N-1:0] out
		);

	always_comb
	begin
		unique case (select)
			2'b00:				out = in00;
			2'b01:				out = in01;
			2'b10:				out = in10;
			2'b11:				out = in11;
			default: ;
		endcase
	end

endmodule

module BUSMUX #(N = 16) (
		input logic [3:0] select,
		input logic [N-1:0] MAR,PC,MDR,ALU,
		output logic [N-1:0] out
		);
		
	
	always_comb
	begin
		unique case (select)
			4'b1000:			out = MAR;
			4'b0100:			out = PC;
			4'b0010:			out = MDR;
			4'b0001:			out = ALU;
			default:			out = 16'b0;
		endcase
	end

endmodule

