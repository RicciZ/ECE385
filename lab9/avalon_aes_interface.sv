/************************************************************************
Avalon-MM Interface for AES Decryption IP Core

Dong Kai Wang, Fall 2017

For use with ECE 385 Experiment 9
University of Illinois ECE Department

Register Map:

 0-3 : 4x 32bit AES Key
 4-7 : 4x 32bit AES Encrypted Message
 8-11: 4x 32bit AES Decrypted Message
 12: Not Used
 13: Not Used
 14: 32bit Start Register
 15: 32bit Done Register

************************************************************************/

module avalon_aes_interface (
	// Avalon Clock Input
	input logic CLK,
	
	// Avalon Reset Input
	input logic RESET,
	
	// Avalon-MM Slave Signals
	input  logic AVL_READ,					// Avalon-MM Read
	input  logic AVL_WRITE,					// Avalon-MM Write
	input  logic AVL_CS,						// Avalon-MM Chip Select
	input  logic [3:0] AVL_BYTE_EN,		// Avalon-MM Byte Enable
	input  logic [3:0] AVL_ADDR,			// Avalon-MM Address
	input  logic [31:0] AVL_WRITEDATA,	// Avalon-MM Write Data
	output logic [31:0] AVL_READDATA,	// Avalon-MM Read Data
	
	// Exported Conduit
	output logic [31:0] EXPORT_DATA		// Exported Conduit Signal to LEDs
);


	logic [15:0][31:0] Regfile;
	logic done;
	logic [127:0] dec;
	
	assign EXPORT_DATA = {Regfile[0][31:16],Regfile[3][15:0]};
	
	AES aes(.*,
			  .AES_START(Regfile[14][0]),
			  .AES_DONE(done),
			  .AES_KEY({Regfile[0], Regfile[1], Regfile[2], Regfile[3]}),
			  .AES_MSG_ENC({Regfile[4], Regfile[5], Regfile[6], Regfile[7]}),
			  .AES_MSG_DEC(dec));

	always_ff @ (posedge CLK)
	begin
		if (RESET)
			begin
				Regfile[ 0] <= 32'b0;
				Regfile[ 1] <= 32'b0;
				Regfile[ 2] <= 32'b0;
				Regfile[ 3] <= 32'b0;
				Regfile[ 4] <= 32'b0;
				Regfile[ 5] <= 32'b0;
				Regfile[ 6] <= 32'b0;
				Regfile[ 7] <= 32'b0;
				Regfile[ 8] <= 32'b0;
				Regfile[ 9] <= 32'b0;
				Regfile[10] <= 32'b0;
				Regfile[11] <= 32'b0;
				Regfile[12] <= 32'b0;
				Regfile[13] <= 32'b0;
				Regfile[14] <= 32'b0;
				Regfile[15] <= 32'b0;
			end
		else
			begin
				Regfile[15] <= {31'b0,done};
				Regfile[8] <= dec[127:96];
				Regfile[9] <= dec[95:64];
				Regfile[10]  <= dec[63:32];
				Regfile[11]  <= dec[31:0];
				if (AVL_CS==1 && AVL_WRITE==1)
						unique case(AVL_BYTE_EN)
							4'b1111: Regfile[AVL_ADDR][31: 0] <= AVL_WRITEDATA[31: 0];
							4'b1100: Regfile[AVL_ADDR][31:16] <= AVL_WRITEDATA[31:16];
							4'b0011: Regfile[AVL_ADDR][15: 0] <= AVL_WRITEDATA[15: 0];
							4'b1000: Regfile[AVL_ADDR][31:24] <= AVL_WRITEDATA[31:24];
							4'b0100: Regfile[AVL_ADDR][23:16] <= AVL_WRITEDATA[23:16];
							4'b0010: Regfile[AVL_ADDR][15: 8] <= AVL_WRITEDATA[15: 8];
							4'b0001: Regfile[AVL_ADDR][ 7: 0] <= AVL_WRITEDATA[ 7: 0];
							default: Regfile[AVL_ADDR][31: 0] <= 32'b0;
						endcase
			end
	end
	
	always_comb
	begin
		if (AVL_CS==1 && AVL_READ==1)
			AVL_READDATA = Regfile[AVL_ADDR];
		else
			AVL_READDATA = 32'b0;		
	end

endmodule
