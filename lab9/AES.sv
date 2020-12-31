/************************************************************************
AES Decryption Core Logic

Dong Kai Wang, Fall 2017

For use with ECE 385 Experiment 9
University of Illinois ECE Department
************************************************************************/

module AES (
	input	 logic CLK,
	input  logic RESET,
	input  logic AES_START,
	output logic AES_DONE,
	input  logic [127:0] AES_KEY,
	input  logic [127:0] AES_MSG_ENC,
	output logic [127:0] AES_MSG_DEC
//	output logic [3:0] statecheck
);

	enum logic [3:0] {Halt,Done,KeyEx,firstAddRoundKey,
							nineInvShiftRows,nineInvSubBytes,
							nineAddRoundKey,InvMixColumns_1,
							InvMixColumns_2,InvMixColumns_3,
							InvMixColumns_4,lastInvShiftRows,
							lastInvSubBytes,lastAddRoundKey} curr_state, next_state;

							
	logic [1407:0] keys;
	logic round_reset,round_in;
	logic [3:0] round;
	logic key_reset,key_in;
	logic [3:0] key_count;
	logic [127:0] state128;
	logic [127:0] ISRO;
	logic [127:0] ISBO;
	logic [31:0] IMC1O,IMC2O,IMC3O,IMC4O;
	logic [127:0] ARKO;
	
	assign statecheck = curr_state;
	assign AES_MSG_DEC = state128;
	
	KeyExpansion keyex(.clk(CLK),
							.Cipherkey(AES_KEY),
							.KeySchedule(keys));
	
	counter rc(.CLK,
				  .RESET(round_reset),
				  .in(round_in),
				  .out(round));
					
	counter kc(.CLK,
				  .RESET(key_reset),
				  .in(key_in),
				  .out(key_count));
				  
	InvShiftRows ISR(.data_in(state128),.data_out(ISRO));
	
	InvSubState ISB(.clk(CLK),.in(state128),.out(ISBO));
	
	AddRoundKey ARK(.in(state128),.keys(keys),.round,.out(ARKO));
	
	InvMixColumns IMC1(.in(state128[127:96]),.out(IMC1O));
	
	InvMixColumns IMC2(.in(state128[ 95:64]),.out(IMC2O));
	
	InvMixColumns IMC3(.in(state128[ 63:32]),.out(IMC3O));
	
	InvMixColumns IMC4(.in(state128[ 31: 0]),.out(IMC4O));
	
	always_ff @ (posedge CLK)
	begin
		if (RESET)
			curr_state <= Halt;
			
		else
			curr_state <= next_state;
			
		if (RESET)
			state128 <= 128'b0;
		else
			unique case(curr_state)
				Halt:					state128 <= AES_MSG_ENC;
				KeyEx:				state128 <= AES_MSG_ENC;
				firstAddRoundKey: state128 <= ARKO;
				nineInvShiftRows: state128 <= ISRO;
				nineInvSubBytes:  state128 <= ISBO;
				nineAddRoundKey:  state128 <= ARKO;
				InvMixColumns_1:  state128 <= {IMC1O,state128[95:0]};
				InvMixColumns_2:  state128 <= {state128[127:96],IMC2O,state128[63:0]};
				InvMixColumns_3:  state128 <= {state128[127:64],IMC3O,state128[31:0]};
				InvMixColumns_4:  state128 <= {state128[127:32],IMC4O};
				lastInvShiftRows: state128 <= ISRO;
				lastInvSubBytes:  state128 <= ISBO;
				lastAddRoundKey:  state128 <= ARKO;
				Done:					state128 <= state128;
				default: ;
			endcase
			
		
	end

	always_comb
	begin
		round_reset = 1;
		round_in = 0;
		key_reset = 1;
		key_in = 0;
		AES_DONE = 0;
		
		unique case(curr_state)
			Halt:
				if (AES_START)
					next_state = KeyEx;
				else
					next_state = Halt;
			KeyEx:
				begin
					if (key_count < 4'b1010)
						next_state = KeyEx;
					else
						next_state = firstAddRoundKey;
				end
			firstAddRoundKey:
				next_state = nineInvShiftRows;
			nineInvShiftRows:
				next_state = nineInvSubBytes;
			nineInvSubBytes:
				next_state = nineAddRoundKey;
			nineAddRoundKey:
				next_state = InvMixColumns_1;
			InvMixColumns_1:
				next_state = InvMixColumns_2;
			InvMixColumns_2:
				next_state = InvMixColumns_3;
			InvMixColumns_3:
				next_state = InvMixColumns_4;
			InvMixColumns_4:
				begin
					if (round < 4'b1001)
						next_state = nineInvShiftRows;
					else
						next_state = lastInvShiftRows;
				end
			lastInvShiftRows:
				next_state = lastInvSubBytes;
			lastInvSubBytes:
				next_state = lastAddRoundKey;
			lastAddRoundKey:
				next_state = Done;
			Done:
				begin
					AES_DONE = 1;
					if (AES_START)
						next_state = Done;
					else
						next_state = Halt;
				end
			default: ;
		endcase
		
		unique case(curr_state)
			KeyEx:
				begin
					key_reset = 0;
					key_in = 1;				
				end
			nineInvShiftRows:
				begin
					round_reset = 0;
					round_in = 1;
				end
			nineInvSubBytes:
				round_reset = 0;
			nineAddRoundKey:
				round_reset = 0;
			InvMixColumns_1:
				round_reset = 0;
			InvMixColumns_2:
				round_reset = 0;
			InvMixColumns_3:
				round_reset = 0;
			InvMixColumns_4:
				round_reset = 0;
			lastInvShiftRows:
				round_reset = 0;
			lastInvSubBytes:
				begin
					round_reset = 0;
					round_in = 1;
				end
			lastAddRoundKey:
				round_reset = 0;
			default: ;
		endcase
	end
endmodule
