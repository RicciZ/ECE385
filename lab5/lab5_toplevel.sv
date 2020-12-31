module lab5_toplevel
	(
	input logic Clk,
	input logic Reset, Run, ClearA_LoadB,
	input logic [7:0] S,
	output logic [7:0] Aval, Bval,
	output logic X,
	output logic [6:0] AhexL, AhexU, BhexL, BhexU,
	output logic [3:0] curr_state,
	output logic [2:0] counter,
	output logic [8:0] XA,
	output M
	);

	logic [7:0] A, B, Sin;
//	logic [8:0] XA;
//	logic M;
	logic X_out;
	logic A_out, Load_X, Shift_En, fn;
	logic Reset_SH, Run_SH, ClearA_LoadB_SH;
	logic add,sub,clr_ld;
	
	assign M = B[0];
	assign Aval = A;
	assign Bval = B;
	assign X = X_out;
	
	

	control 			  control_logic (
								.run(Run_SH),
								.clear(ClearA_LoadB_SH),
								.clk(Clk),
								.reset(Reset_SH),
								.M(M),
								.clr_ld(clr_ld),
								.shift(Shift_En),
								.add(add),
								.sub(sub),
								.fn(fn)
								);
	
	reg_8 			  reg_A (
								.Clk(Clk),
								.Reset(Reset_SH|clr_ld),
								.Shift_In(X_out),
								.Load(add|sub),
								.Shift_En,
								.D(XA[7:0]),
								.Shift_Out(A_out),
								.Data_Out(A));
								
	reg_8 			  reg_B (
								.Clk(Clk),
								.Reset(Reset_SH),
								.Shift_In(A_out),
								.Load(ClearA_LoadB_SH),
								.Shift_En,
								.D(S),
								.Shift_Out(),
								.Data_Out(B));
								
	Dreg				  D_flip_flop (
								.Clk(Clk),
								.Reset(Reset_SH|clr_ld),
								.Load(add|sub),
								.D(XA[8]),
								.Q(X_out) );
							
	ADD_SUB9			  ADD_SUB (
								.A(A),
								.B(S),
								.fn,
								.S(XA) );
								
	 HexDriver        HexAL (
                        .In0(A[3:0]),
                        .Out0(AhexL) );
								
	 HexDriver        HexBL (
                        .In0(B[3:0]),
                        .Out0(BhexL) );
								
	 HexDriver        HexAU (
                        .In0(A[7:4]),
                        .Out0(AhexU) );	
								
	 HexDriver        HexBU (
                       .In0(B[7:4]),
                        .Out0(BhexU) );
								
								
	 sync button_sync[2:0] (Clk, {~Reset, ~Run, ~ClearA_LoadB}, {Reset_SH, Run_SH, ClearA_LoadB_SH});
	 sync Sin_sync[7:0] (Clk, S, Sin);
	 
	 
	 
	 
endmodule
