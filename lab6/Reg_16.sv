module reg_16 (input  logic Clk, Reset, Load,
              input  logic [15:0]  Din,
              output logic [15:0]  data_out);

    always_ff @ (posedge Clk)
    begin
	 	 if (Reset) //notice, this is a sycnrhonous reset, which is recommended on the FPGA
			  data_out <= 16'h0;
		 else if (Load)
			  data_out <= Din;
    end

endmodule
