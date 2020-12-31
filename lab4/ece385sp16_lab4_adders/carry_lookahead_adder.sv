module carry_lookahead_adder
(
    input   logic[15:0]     A,
    input   logic[15:0]     B,
    output  logic[15:0]     Sum,
    output  logic           CO
);

    logic C4 , C8 , C12, pg0, pg4, pg8, pg12, gg0, gg4, gg8, gg12;
	 logic c0 , c1 , c2 , c3 , p0 , p1 , p2  , p3 , g0 , g1 , g2  , g3 ;
	 logic c4 , c5 , c6 , c7 , p4 , p5 , p6  , p7 , g4 , g5 , g6  , g7 ;
	 logic c8 , c9 , c10, c11, p8 , p9 , p10 , p11, g8 , g9 , g10 , g11;
	 logic c12, c13, c14, c15, p12, p13, p14 , p15, g12, g13, g14 , g15;
	 
	 assign p0 = A[0] ^ B[0];
	 assign p1 = A[1] ^ B[1];
	 assign p2 = A[2] ^ B[2];
	 assign p3 = A[3] ^ B[3];
	 assign g0 = A[0] & B[0];
	 assign g1 = A[1] & B[1];
	 assign g2 = A[2] & B[2];
	 assign g3 = A[3] & B[3];
	 
	 assign p4 = A[4] ^ B[4];
	 assign p5 = A[5] ^ B[5];
	 assign p6 = A[6] ^ B[6];
	 assign p7 = A[7] ^ B[7];
	 assign g4 = A[4] & B[4];
	 assign g5 = A[5] & B[5];
	 assign g6 = A[6] & B[6];
	 assign g7 = A[7] & B[7];
	 
	 assign p8  = A[8 ] ^ B[8 ];
	 assign p9  = A[9 ] ^ B[9 ];
	 assign p10 = A[10] ^ B[10];
	 assign p11 = A[11] ^ B[11];
	 assign g8  = A[8 ] & B[8 ];
	 assign g9  = A[9 ] & B[9 ];
	 assign g10 = A[10] & B[10];
	 assign g11 = A[11] & B[11];
	
	 assign p12 = A[12] ^ B[12];
	 assign p13 = A[13] ^ B[13];
	 assign p14 = A[14] ^ B[14];
	 assign p15 = A[15] ^ B[15];
	 assign g12 = A[12] & B[12];
	 assign g13 = A[13] & B[13];
	 assign g14 = A[14] & B[14];
	 assign g15 = A[15] & B[15];
	 
	 assign pg0 = p0 & p1 & p2 & p3;
	 assign gg0 = g3 | g2 & p3 | g1 & p3 & p2 | g0 & p3 & p2 & p1;
	 
	 assign pg4 = p4 & p5 & p6 & p7;
	 assign gg4 = g7 | g6 & p7 | g5 & p7 & p6 | g4 & p7 & p6 & p5;
	 
	 assign pg8 = p8 & p9 & p10 & p11;
	 assign gg8 = g11 | g10 & p11 | g9 & p11 & p10 | g8 & p11 & p10 & p9;
	 
	 assign pg12 = p12 & p13 & p14 & p15;
	 assign gg12 = g15 | g14 & p15 | g13 & p15 & p14 | g12 & p15 & p14 & p13;
	 
	 assign C4 = gg0 | 0 & pg0;
	 assign C8 = gg4 | gg0 & pg4 | 0 & pg0 & pg4;
	 assign C12 = gg8 | gg4 & pg8 | gg0 & pg8 & pg4 | 0 & pg0 & pg4 & pg8;
	 assign CO = gg12 | gg8 & pg12 | gg4 & pg12 & pg8 | gg0 & pg12 & pg8 & pg4 | 0 & pg0 & pg4 & pg8 & pg12;

    four_bit_cla CLA0(.x(A[3 : 0]), .y(B[3 : 0]), .cin( 0), .s(Sum[3 : 0]));
    four_bit_cla CLA1(.x(A[7 : 4]), .y(B[7 : 4]), .cin(C4), .s(Sum[7 : 4]));
    four_bit_cla CLA2(.x(A[11: 8]), .y(B[11: 8]), .cin(C8), .s(Sum[11: 8]));
    four_bit_cla CLA3(.x(A[15:12]), .y(B[15:12]), .cin(C12), .s(Sum[15:12]));
	 
	 
endmodule

module four_bit_cla(
                   input [3:0] x,
                   input [3:0] y,
                   input cin,
                   output logic [3:0] s
                   );

    logic c0, c1, c2, c3, p0, p1, p2, p3, g0, g1, g2, g3;
	 
    assign p0 = x[0] ^ y[0];
    assign p1 = x[1] ^ y[1];
    assign p2 = x[2] ^ y[2];
    assign p3 = x[3] ^ y[3];
    assign g0 = x[0] & y[0];
    assign g1 = x[1] & y[1];
    assign g2 = x[2] & y[2];
    assign g3 = x[3] & y[3];
	 
	 assign c0 = cin;
	 assign c1 = cin & p0 | g0;
	 assign c2 = cin & p0 & p1 | g0 & p1 | g1;
	 assign c3 = cin & p0 & p1 & p2 | g0 & p1 & p2 | g1 & p2 | g2;
	 
    assign s[0] = x[0] ^ y[0] ^ c0;
    assign s[1] = x[1] ^ y[1] ^ c1;
    assign s[2] = x[2] ^ y[2] ^ c2;
    assign s[3] = x[3] ^ y[3] ^ c3;

//	 assign pg = p0 & p1 & p2 & p3;
//	 assign gg = g3 | g2 & p3 | g1 & p3 & p2 | g0 & p3 & p2 & p1;
	 
endmodule
