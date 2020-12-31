module register_unit (input  logic Clk, Reset, A_In, ClearA_LoadB, 
                            Shift_En, Load_A,
                      input  logic [7:0]  D, 
                      output logic [7:0]  A,
                      output logic [7:0]  B);

	 logic A_out;
	 
    reg_8  reg_A (.*, .Shift_In(A_In), .Load(Load_A),
	               .Shift_Out(A_out), .Data_Out(A));
    reg_8  reg_B (.*, .Shift_In(A_out), .Load(ClearA_LoadB),
	               .Shift_Out(), .Data_Out(B));

endmodule
