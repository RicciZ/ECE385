module datapath(
		input logic  Clk, Reset,
		input logic  GatePC, GateMDR, GateALU, GateMARMUX,
		input logic  LD_MAR, LD_MDR, LD_IR, LD_BEN, LD_CC, LD_REG, LD_PC, LD_LED,
		input logic  [1:0] PCMUX, ADDR2MUX, ALUK,
		input logic  DRMUX, SR1MUX, SR2MUX, ADDR1MUX,
		input logic [15:0] MDR_In,
		input logic	 MIO_EN,
		output logic [15:0] MAR, MDR, IR, PC,
		output logic BEN,
		output logic [11:0] LED
);

	logic [15:0] BUS,
					 SR1OUT,
					 SR2OUT,
					 IR_out,
					 PC_out,
					 PC_in,
					 ADDR1,
					 ADDR2,
					 MDR_out,
					 MAR_out,
					 SR2mux_out,
					 ALU,
					 MDRmux_out;
	logic [2:0]  SR1,SR2,DR;
	logic BEN_out;
	
	assign SR2 = IR[2:0];
	assign MAR = MAR_out;
	assign MDR = MDR_out;
	assign IR  = IR_out ;
	assign PC  = PC_out ;
	assign BEN = BEN_out;
	
	always_ff @ (posedge Clk)
	begin
		if (LD_LED)
			LED <= IR_out[11:0];
		else
			LED <= 12'b0;
	end

	reg_16 PC_reg (.*,.Load(LD_PC), .Din(PC_in), .data_out(PC_out));
	reg_16 MDR_reg(.*,.Load(LD_MDR),.Din(MDRmux_out),.data_out(MDR_out));
	reg_16 MAR_reg(.*,.Load(LD_MAR),.Din(BUS),   .data_out(MAR_out));
	reg_16 IR_reg (.*,.Load(LD_IR), .Din(BUS),   .data_out(IR_out));
	Reg_File regfile(.*);

	mux_41 PCmux(
						.select(PCMUX),
						.in00(PC_out+1'b1),
						.in01(BUS),
						.in10(ADDR1+ADDR2),
						.in11(),
						.out(PC_in)
					 );
	
	mux_21 #(3) DRmux(
						.select(DRMUX),
						.in0(IR[11:9]),
						.in1(3'b111),
						.out(DR)
					 );
	
	mux_21 #(3) SR1mux(
						.select(SR1MUX),
						.in0(IR_out[11:9]),
						.in1(IR_out[8:6]),
						.out(SR1)
					 );
	
	mux_21 SR2mux(
						.select(SR2MUX),
						.in0(SR2OUT),
						.in1({{11{IR_out[4]}},IR_out[4:0]}),
						.out(SR2mux_out)
					 );
	
	mux_21 ADDR1mux(
						.select(ADDR1MUX),
						.in0(PC_out),
						.in1(SR1OUT),
						.out(ADDR1)
					 );

	mux_41 ADDR2mux(
						.select(ADDR2MUX),
						.in00(16'h0000),
						.in01({{10{IR_out[5]}},IR_out[5:0]}),
						.in10({{7{IR_out[8]}},IR_out[8:0]}),
						.in11({{5{IR_out[10]}},IR_out[10:0]}),
						.out(ADDR2)
					 );
					 
	BUSMUX BUSmux(
						.select({GateMARMUX, GatePC, GateMDR, GateALU}),
						.MAR(ADDR1+ADDR2),
						.PC(PC_out),
						.MDR(MDR_out),
						.ALU(ALU),
						.out(BUS)
					 );
					 
	ALU ALU_unit(
						.A(SR1OUT),
						.B(SR2mux_out),
						.ALUK(ALUK),
						.out(ALU)
					 );

	BEN BEN_unit(.*,.IR(IR_out[11:9]),.out(BEN_out));

	mux_21 MDRmux(
						.select(MIO_EN),
						.in0(BUS),
						.in1(MDR_In),
						.out(MDRmux_out)
					 );

	
endmodule

























