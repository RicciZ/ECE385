/*
 * ECE385-HelperTools/PNG-To-Txt
 * Author: Rishi Thakkar
 *
 */

module  kid_idle
(
		input [11:0] read_address,
		input Clk,

		output logic [3:0] data_Out
);

		// 104x23=2392
		logic [3:0] mem [0:2391];

		initial
		begin
			 $readmemh("sprites_txt/kid_idle.txt", mem);
		end


		always_ff @ (posedge Clk) begin
			data_Out<= mem[read_address];
		end
endmodule

module  kid_walk
(
		input [11:0] read_address,
		input Clk,

		output logic [3:0] data_Out
);

		// 104x23=2392
		logic [3:0] mem [0:2391];

		initial
		begin
			 $readmemh("sprites_txt/kid_walk.txt", mem);
		end


		always_ff @ (posedge Clk) begin
			data_Out<= mem[read_address];
		end
endmodule

module  kid_jump
(
		input [10:0] read_address,
		input Clk,

		output logic [3:0] data_Out
);

		// 52x25=1300
		logic [3:0] mem [0:1300];

		initial
		begin
			 $readmemh("sprites_txt/kid_jump.txt", mem);
		end


		always_ff @ (posedge Clk) begin
			data_Out<= mem[read_address];
		end
endmodule

module  background
(
		input [18:0] read_address,
		input Clk,

		output logic [3:0] data_Out
);

		// 640x480=307200
		logic [3:0] mem [0:307199];

		initial
		begin
			 $readmemh("sprites_txt/background.txt", mem);
		end


		always_ff @ (posedge Clk) begin
			data_Out<= mem[read_address];
		end
endmodule

module  spike
(
		input [11:0] read_address,
		input Clk,

		output logic [3:0] data_Out
);

		// 128x32=4096
		logic [3:0] mem [0:4095];

		initial
		begin
			 $readmemh("sprites_txt/spike.txt", mem);
		end


		always_ff @ (posedge Clk) begin
			data_Out<= mem[read_address];
		end
endmodule

module  block
(
		input [9:0] read_address,
		input Clk,

		output logic [3:0] data_Out
);

		// 32x32=1024
		logic [3:0] mem [0:1023];

		initial
		begin
			 $readmemh("sprites_txt/block.txt", mem);
		end


		always_ff @ (posedge Clk) begin
			data_Out<= mem[read_address];
		end
endmodule

module  checkpoint
(
		input [10:0] read_address,
		input Clk,

		output logic [3:0] data_Out
);

		// 64x32=2048
		logic [3:0] mem [0:2047];

		initial
		begin
			 $readmemh("sprites_txt/checkpoint.txt", mem);
		end


		always_ff @ (posedge Clk) begin
			data_Out<= mem[read_address];
		end
endmodule

module  dead
(
		input [14:0] read_address,
		input Clk,

		output logic [3:0] data_Out
);

		// 320x66=21120
		logic [3:0] mem [0:32767];

		initial
		begin
			 $readmemh("sprites_txt/dead.txt", mem);
		end


		always_ff @ (posedge Clk) begin
			data_Out<= mem[read_address];
		end
endmodule