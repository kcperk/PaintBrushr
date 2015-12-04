//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//                                                                       --
//    Fall 2014 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 7                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------


module  color_mapper ( input        [9:0] BallX, BallY, DrawX, DrawY,
								input				left_btn, vgaClk,
								input [1:0]		ramOut, ramOut2,
								input [2:0]		romOut,
								output logic ram_read, ram_write, rom_read,
								output logic [1:0] ramIn, ramIn2,
                       output logic [7:0]  Red, Green, Blue );
    
	 logic [9:0] bX, bY;
	 logic canvas, tools;
	 logic [3:0] curColor;
	 logic [9:0] Brush_size;
	 logic [1:0] Brush_type;
	 logic pressed;
	 
	 
 /* Old Ball: Generated square box by checking if the current pixel is within a square of length
    2*Ball_Size, centered at (BallX, BallY).  Note that this requires unsigned comparisons.
	 
    if ((DrawX >= BallX - Ball_size) &&
       (DrawX <= BallX + Ball_size) &&
       (DrawY >= BallY - Ball_size) &&
       (DrawY <= BallY + Ball_size))

     New Ball: Generates (pixelated) circle by using the standard circle formula.  Note that while 
     this single line is quite powerful descriptively, it causes the synthesis tool to use up three
     of the 12 available multipliers on the chip!  Since the multiplicants are required to be signed,
	  we have to first cast them from logic to int (signed by default) before they are multiplied). */
	  
    int DistX, DistY, DistX2, DistY2, Size;
	 assign DistX = DrawX - BallX;
    assign DistY = DrawY - BallY;
	 assign DistX2 = DrawX > BallX ? DrawX - BallX : BallX - DrawX;
	 assign DistY2 = DrawY > BallY ? DrawY - BallY : BallY - DrawY;
    assign Size = Brush_size;
	 assign bX = DrawX - 100;
	 assign bY = DrawY - 100;
	 assign ram_read = canvas || DrawX == 99;
	 assign ram_write = canvas;
	 assign rom_read = tools || DrawX == 554;
	 
	 always_comb
	 begin
			if (DrawX < 540 && DrawY < 380 && DrawX >= 100 && DrawY >= 100)
				canvas = 1'b1;
			else
				canvas = 1'b0;
			if (DrawX < 625 && DrawY < 270 && DrawX >= 555 && DrawY >= 100)
				tools = 1'b1;
			else
				tools = 1'b0;
	 end
	 

	  always_ff @ (posedge vgaClk)
	  begin
			ramIn <= ramOut;
			ramIn2 <= ramOut2;
			if (left_btn)
			begin
				// First set of 8 colors
				if (BallX < 85 && BallX >= 55 && BallY < 130 && BallY >= 100)
					curColor <= 4'b0000;
				else if (BallX < 85 && BallX >= 55 && BallY < 165 && BallY >= 135)
					curColor <= 4'b0001;
				else if (BallX < 45 && BallX >= 15 && BallY < 130 && BallY >= 100)
					curColor <= 4'b0010;
				else if (BallX < 45 && BallX >= 15 && BallY < 165 && BallY >= 135)
					curColor <= 4'b0011;
				else if (BallX < 85 && BallX >= 55 && BallY < 200 && BallY >= 170)
					curColor <= 4'b0100;
				else if (BallX < 85 && BallX >= 55 && BallY < 235 && BallY >= 205)
					curColor <= 4'b0101;
				else if (BallX < 45 && BallX >= 15 && BallY < 200 && BallY >= 170)
					curColor <= 4'b0110;
				else if (BallX < 45 && BallX >= 15 && BallY < 235 && BallY >= 205)
					curColor <= 4'b0111;
				// Second set of 8 colors
				else if (BallX < 85 && BallX >= 55 && BallY < 270 && BallY >= 240)
					curColor <= 4'b1000;
				else if (BallX < 85 && BallX >= 55 && BallY < 305 && BallY >= 275)
					curColor <= 4'b1001;
				else if (BallX < 45 && BallX >= 15 && BallY < 270 && BallY >= 240)
					curColor <= 4'b1010;
				else if (BallX < 45 && BallX >= 15 && BallY < 305 && BallY >= 275)
					curColor <= 4'b1011;
				else if (BallX < 85 && BallX >= 55 && BallY < 340 && BallY >= 310)
					curColor <= 4'b1100;
				else if (BallX < 85 && BallX >= 55 && BallY < 375 && BallY >= 345)
					curColor <= 4'b1101;
				else if (BallX < 45 && BallX >= 15 && BallY < 340 && BallY >= 310)
					curColor <= 4'b1110;
				else if (BallX < 45 && BallX >= 15 && BallY < 375 && BallY >= 345)
					curColor <= 4'b1111;
				// Larger Brush Size Button
				else if (BallX < 585 && BallX >= 555 && BallY < 130 && BallY >= 100 && !pressed)
				begin
					if (Brush_size < 10'h0ff)
						Brush_size <= Brush_size + 'b11;
					pressed <= 1'b1;
				end
				// Smaller Brush Size Button
				else if (BallX < 625 && BallX >= 595 && BallY < 130 && BallY >= 100 && !pressed)
				begin
					if (Brush_size > 10'b0)
						Brush_size <= Brush_size - 'b11;
					pressed <= 1'b1;
				end
				// Circle Brush
				else if (BallX < 585 && BallX >= 555 && BallY < 165 && BallY >= 135)
					Brush_type <= 2'b00;
				// Sqaure Brush
				else if (BallX < 625 && BallX >= 595 && BallY < 165 && BallY >= 135)
					Brush_type <= 2'b01;
				// Horizontal Line Brush
				else if (BallX < 585 && BallX >= 555 && BallY < 200 && BallY >= 170)
					Brush_type <= 2'b10;
				// Vertical Line Brush
				else if (BallX < 625 && BallX >= 595 && BallY < 200 && BallY >= 170)
					Brush_type <= 2'b11;
			end
			else
				pressed <= 1'b0;
				
			if ((Brush_type == 2'b00 &&( DistX*DistX + DistY*DistY) <= (Size * Size))
				|| (Brush_type == 2'b01 && DistX2 <= Size && DistY2 <= Size)
				|| (Brush_type == 2'b10 && DistY2 <= Size >> 3 && DistX2 <= Size)
				|| (Brush_type == 2'b11 && DistX2 <= Size >> 3 && DistY2 <= Size))
			begin 
				if (left_btn && BallX < 540 && BallY < 380 && BallX >= 100 && BallY >= 100)
				begin
					ramIn <= curColor[1:0];
					ramIn2 <= curColor[3:2];
				end
				case (curColor)
				4'b0000:
					begin
						Red <= 8'hff;
						Green <= 8'h00;
						Blue <= 8'h00;
					end
				4'b0001:
					begin
						Red <= 8'h00;
						Green <= 8'hff;
						Blue <= 8'h00;
					end
				4'b0010:
					begin
						Red <= 8'h00;
						Green <= 8'h00;
						Blue <= 8'hff;
					end
				4'b0011:
					begin
						Red <= 8'h00;
						Green <= 8'h00;
						Blue <= 8'h00;
					end
				4'b0100:
					begin
						Red <= 8'hff;
						Green <= 8'hff;
						Blue <= 8'hff;
					end
				4'b0101:
					begin
						Red <= 8'hff;
						Green <= 8'hff;
						Blue <= 8'h00;
					end
				4'b0110:
					begin
						Red <= 8'h00;
						Green <= 8'hff;
						Blue <= 8'hff;
					end
				4'b0111:
					begin
						Red <= 8'hff;
						Green <= 8'h00;
						Blue <= 8'hff;
					end
				
				4'b1000:
					begin
						Red <= 8'h55;
						Green <= 8'h55;
						Blue <= 8'h55;
					end
				4'b1001:
					begin
						Red <= 8'haa;
						Green <= 8'haa;
						Blue <= 8'haa;
					end
				4'b1010:
					begin
						Red <= 8'hff;
						Green <= 8'h55;
						Blue <= 8'h00;
					end
				4'b1011:
					begin
						Red <= 8'haa;
						Green <= 8'h00;
						Blue <= 8'haa;
					end
				4'b1100:
					begin
						Red <= 8'h55;
						Green <= 8'h00;
						Blue <= 8'h00;
					end
				4'b1101:
					begin
						Red <= 8'h00;
						Green <= 8'h55;
						Blue <= 8'h00;
					end
				4'b1110:
					begin
						Red <= 8'h00;
						Green <= 8'h00;
						Blue <= 8'h55;
					end
				4'b1111:
					begin
						Red <= 8'haa;
						Green <= 8'h55;
						Blue <= 8'h00;
					end
				endcase
			end
			
		  else if (DrawX < 100 || DrawX >= 540 || DrawY < 100 || DrawY >= 380)
			begin
				if (DrawX < 85 && DrawX >= 55 && DrawY < 130 && DrawY >= 100)
				begin
					Red <= 8'hff;
					Green <= 8'h00;
					Blue <= 8'h00;
				end
				else if (DrawX < 85 && DrawX >= 55 && DrawY < 165 && DrawY >= 135)
				begin
					Red <= 8'h00;
					Green <= 8'hff;
					Blue <= 8'h00;
				end
				else if (DrawX < 45 && DrawX >= 15 && DrawY < 130 && DrawY >= 100)
				begin
					Red <= 8'h00;
					Green <= 8'h00;
					Blue <= 8'hff;
				end
				else if (DrawX < 45 && DrawX >= 15 && DrawY < 165 && DrawY >= 135)
				begin
					Red <= 8'hf00;
					Green <= 8'h00;
					Blue <= 8'h00;
				end
				else if (DrawX < 85 && DrawX >= 55 && DrawY < 200 && DrawY >= 170)
				begin
					Red <= 8'hff;
					Green <= 8'hff;
					Blue <= 8'hff;
				end
				else if (DrawX < 85 && DrawX >= 55 && DrawY < 235 && DrawY >= 205)
				begin
					Red <= 8'hff;
					Green <= 8'hff;
					Blue <= 8'h00;
				end
				else if (DrawX < 45 && DrawX >= 15 && DrawY < 200 && DrawY >= 170)
				begin
					Red <= 8'h00;
					Green <= 8'hff;
					Blue <= 8'hff;
				end
				else if (DrawX < 45 && DrawX >= 15 && DrawY < 235 && DrawY >= 205)
				begin
					Red <= 8'hff;
					Green <= 8'h00;
					Blue <= 8'hff;
				end
				
				else if (DrawX < 85 && DrawX >= 55 && DrawY < 270 && DrawY >= 240)
				begin
					Red <= 8'h55;
					Green <= 8'h55;
					Blue <= 8'h55;
				end
				else if (DrawX < 85 && DrawX >= 55 && DrawY < 305 && DrawY >= 275)
				begin
					Red <= 8'haa;
					Green <= 8'haa;
					Blue <= 8'haa;
				end
				else if (DrawX < 45 && DrawX >= 15 && DrawY < 270 && DrawY >= 240)
				begin
					Red <= 8'hff;
					Green <= 8'h55;
					Blue <= 8'h00;
				end
				else if (DrawX < 45 && DrawX >= 15 && DrawY < 305 && DrawY >= 275)
				begin
					Red <= 8'haa;
					Green <= 8'h00;
					Blue <= 8'haa;
				end
				else if (DrawX < 85 && DrawX >= 55 && DrawY < 340 && DrawY >= 310)
				begin
					Red <= 8'h55;
					Green <= 8'h00;
					Blue <= 8'h00;
				end
				else if (DrawX < 85 && DrawX >= 55 && DrawY < 375 && DrawY >= 345)
				begin
					Red <= 8'h00;
					Green <= 8'h55;
					Blue <= 8'h00;
				end
				else if (DrawX < 45 && DrawX >= 15 && DrawY < 340 && DrawY >= 310)
				begin
					Red <= 8'h00;
					Green <= 8'h00;
					Blue <= 8'h55;
				end
				else if (DrawX < 45 && DrawX >= 15 && DrawY < 375 && DrawY >= 345)
				begin
					Red <= 8'haa;
					Green <= 8'h55;
					Blue <= 8'h00;
				end
				
				else if (tools)
				begin
				case (romOut)
				3'b000:
					begin
						Red <= 8'h88;
						Green <= 8'h88;
						Blue <= 8'h88;
					end
				3'b100:
					begin
						Red <= 8'h49;
						Green <= 8'h49;
						Blue <= 8'h49;
					end
				3'b111:
					begin
						Red <= 8'hff;
						Green <= 8'hff;
						Blue <= 8'hff;
					end
				3'b010:
					begin
						Red <= 8'h00;
						Green <= 8'h00;
						Blue <= 8'h00;
					end
				default:
					begin
						Red <= 8'h88;
						Green <= 8'h88;
						Blue <= 8'h88;
					end
				endcase
				end
				
				else
				begin
					Red <= 8'h88;
					Green <= 8'h88;
					Blue <= 8'h88;
				end
			end
        else 
        begin 
				if (canvas)
				begin
				case (ramOut2)
				2'b00:
				begin
					case (ramOut)
					2'b00://Red
						begin
							Red <= 8'hff;
							Green <= 8'h00;
							Blue <= 8'h00;
						end
					2'b01://Green
						begin
							Red <= 8'h00;
							Green <= 8'hff;
							Blue <= 8'h00;
						end
					2'b10://Blue
						begin
							Red <= 8'h00;
							Green <= 8'h00;
							Blue <= 8'hff;
						end
					2'b11:
						begin//Black
							Red <= 8'h00;
							Green <= 8'h00;
							Blue <= 8'h00;
						end
					endcase
				end
				2'b01:
				begin
					case (ramOut)
					2'b00:
						begin//White
							Red <= 8'hff;
							Green <= 8'hff;
							Blue <= 8'hff;
						end
					2'b01:
						begin//Yellow
							Red <= 8'hff;
							Green <= 8'hff;
							Blue <= 8'h00;
						end
					2'b10:
						begin//Cyan
							Red <= 8'h00;
							Green <= 8'hff;
							Blue <= 8'hff;
						end
					2'b11:
						begin//Magenta
							Red <= 8'hff;
							Green <= 8'h00;
							Blue <= 8'hff;
						end
					endcase
				end
				2'b10:
				begin
					case (ramOut)
					2'b00:
						begin//Dark Grey
							Red <= 8'h55;
							Green <= 8'h55;
							Blue <= 8'h55;
						end
					2'b01:
						begin//Light Gray
							Red <= 8'haa;
							Green <= 8'haa;
							Blue <= 8'haa;
						end
					2'b10:
						begin//Orange
							Red <= 8'hff;
							Green <= 8'h55;
							Blue <= 8'h00;
						end
					2'b11:
						begin//Purple
							Red <= 8'haa;
							Green <= 8'h00;
							Blue <= 8'haa;
						end
					endcase
				end
				2'b11:
				begin
					case (ramOut)
					2'b00:
						begin//Dark Red
							Red <= 8'h55;
							Green <= 8'h00;
							Blue <= 8'h00;
						end
					2'b01:
						begin//Dark Green
							Red <= 8'h00;
							Green <= 8'h55;
							Blue <= 8'h00;
						end
					2'b10:
						begin//Dark Blue
							Red <= 8'h00;
							Green <= 8'h00;
							Blue <= 8'h55;
						end
					2'b11:
						begin//Brown
							Red <= 8'haa;
							Green <= 8'h55;
							Blue <= 8'h00;
						end
					endcase
				end
				endcase
				end
				
		  end 
		  if (BallX == DrawX)
		  begin
				Red <= 8'hff;
				Green <= 8'hff;
				Blue <= 8'hff;
		  end
		  if (BallY == DrawY)
		  begin
				Red <= 8'hff;
				Green <= 8'hff;
				Blue <= 8'hff;
		  end
	  end
	  
    
endmodule


