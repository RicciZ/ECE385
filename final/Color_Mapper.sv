//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  10-06-2017                               --
//                                                                       --
//    Fall 2017 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 8                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------

// color_mapper: Decide which color to be output to VGA for each pixel.
module  color_mapper ( input  logic Clk,
                       input 	logic [9:0] man_x,man_y,
							  input  logic [9:0] DrawX, DrawY,
                       output logic [7:0] VGA_R, VGA_G, VGA_B
                     );
							
    
	 testRAM test(.*,.read_address(x+(y*10'd40)),.data_Out(color));
							
	
    logic [7:0] Red, Green, Blue;
    logic [10:0] x,y;
    logic [3:0] color;
    
    // Output colors to VGA
    assign VGA_R = Red;
    assign VGA_G = Green;
    assign VGA_B = Blue;
	 
	 always_comb
	 begin
			x = 10'd0;
			y = 10'd0;
			if (DrawX-man_x < 10'd40 && DrawY-man_y < 10'd40)
			begin
				x = DrawX-man_x;
				y = DrawY-man_y;
			end
	 end
    
    // Assign color based on is_ball signal
    always_comb
    begin
        if (x > 10'd0 && y > 10'd0) 
        begin
            case (color)
            4'b0001:
                begin
                // White ball
                Red = 8'hff;
                Green = 8'hec;
                Blue = 8'h00;
                end
            4'b0010:
                begin
                // White ball
                Red = 8'h00;
                Green = 8'h00;
                Blue = 8'h00;
                end
            4'b0011:
                begin
                // White ball
                Red = 8'hff;
                Green = 8'hff;
                Blue = 8'hff;
                end
            4'b0100:
                begin
                // White ball
                Red = 8'hf6;
                Green = 8'h77;
                Blue = 8'h00;
                end
            default:
                begin
                // White ball
                Red = 8'h3f; 
                Green = 8'h00;
                Blue = 8'h7f - {1'b0, DrawX[9:3]};
            end
				endcase
        end
        else 
        begin
            // Background with nice color gradient
            Red = 8'h3f; 
            Green = 8'h00;
            Blue = 8'h7f - {1'b0, DrawX[9:3]};
        end
    end 
    
endmodule
