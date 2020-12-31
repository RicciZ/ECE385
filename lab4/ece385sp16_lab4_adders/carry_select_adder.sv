module carry_select_adder
(
    input   logic[15:0]     A,
    input   logic[15:0]     B,
    output  logic[15:0]     Sum,
    output  logic           CO
);


	 logic C4, C80, C81, C120, C121, C160, C161;
	 logic [15:0] temp0, temp1;

    four_bit_ra FRA0(.x(A[3 : 0]), .y(B[3 : 0]), .cin(0), .s(Sum[3 : 0]), .cout(C4));
    four_bit_ra FRA1(.x(A[7 : 4]), .y(B[7 : 4]), .cin(0), .s(temp0[7 : 4]), .cout(C80));
    four_bit_ra FRA2(.x(A[11: 8]), .y(B[11: 8]), .cin(0), .s(temp0[11: 8]), .cout(C120));
    four_bit_ra FRA3(.x(A[15:12]), .y(B[15:12]), .cin(0), .s(temp0[15:12]), .cout(C160));
	 
    four_bit_ra FRA4(.x(A[7 : 4]), .y(B[7 : 4]), .cin(1), .s(temp1[7 : 4]), .cout(C81));
    four_bit_ra FRA5(.x(A[11: 8]), .y(B[11: 8]), .cin(1), .s(temp1[11: 8]), .cout(C121));
    four_bit_ra FRA6(.x(A[15:12]), .y(B[15:12]), .cin(1), .s(temp1[15:12]), .cout(C161));
    
	 assign C8  = C80  | C81  & C4;
	 assign C12 = C120 | C121 & C8;
	 assign CO  = C160 | C161 & C12;
	 
	 always_comb
		begin
		 if (C4 == 1'b1)
			Sum[7:4] = temp1[7:4];
		 else
			Sum[7:4] = temp0[7:4];
		
		 if (C8 == 1'b1)
			Sum[11: 8] = temp1[11: 8];
		 else
			Sum[11: 8] = temp0[11: 8];
			
		 if (C12 == 1'b1)
			Sum[15:12] = temp1[15:12];
		 else
			Sum[15:12] = temp0[15:12];
			
		end
	 
endmodule