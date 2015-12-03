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


module  color_mapper ( input        [9:0] BallX, BallY, DrawX, DrawY, Ball_size,
								input				left_btn, Clk, vgaClk,
								input [1:0]		ramOut, ramOut2,
								output logic ram_read, ram_write,
								output logic [1:0] ramIn, ramIn2,
                       output logic [7:0]  Red, Green, Blue );
    
	 logic [9:0] bX, bY;
	 logic canvas, tools;
	 logic [3:0] curColor;
	 
	 
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
	  
    int DistX, DistY, Size;
	 assign DistX = DrawX - BallX;
    assign DistY = DrawY - BallY;
    assign Size = Ball_size;
	 assign bX = DrawX - 100;
	 assign bY = DrawY - 100;
	 assign ram_read = canvas || DrawX == 99;
	 assign ram_write = canvas;
	 
	 always_comb
	 begin
			if (DrawX < 540 && DrawY < 380 && DrawX >= 100 && DrawY >= 100)
			begin
				canvas = 1'b1;
			end
			else
				canvas = 1'b0;
			if (DrawX < 625 && DrawY < 235 && DrawX >= 555 && DrawY >= 100)
				tools = 1'b1;
			else
				tools = 1'b0;
	 end
	 

	  always_ff @ (posedge vgaClk)
	  begin
			ramIn <= ramOut;
			ramIn2 <= ramOut2;
			if ( ( DistX*DistX + DistY*DistY) <= (Size * Size) ) 
			begin 
				if (left_btn)
				begin
					ramIn <= curColor[1:0];
					ramIn2 <= curColor[3:2];
					if (DrawX < 85 && DrawX >= 55 && DrawY < 130 && DrawY >= 100)
						curColor <= 4'b0000;
					else if (DrawX < 85 && DrawX >= 55 && DrawY < 165 && DrawY >= 135)
						curColor <= 4'b0001;
					else if (DrawX < 45 && DrawX >= 15 && DrawY < 130 && DrawY >= 100)
						curColor <= 4'b0010;
					else if (DrawX < 45 && DrawX >= 15 && DrawY < 165 && DrawY >= 135)
						curColor <= 4'b0011;
					else if (DrawX < 85 && DrawX >= 55 && DrawY < 200 && DrawY >= 170)
						curColor <= 4'b0100;
					else if (DrawX < 85 && DrawX >= 55 && DrawY < 235 && DrawY >= 205)
						curColor <= 4'b0101;
					else if (DrawX < 45 && DrawX >= 15 && DrawY < 200 && DrawY >= 170)
						curColor <= 4'b0110;
					else if (DrawX < 45 && DrawX >= 15 && DrawY < 235 && DrawY >= 205)
						curColor <= 4'b0111;
						
					else if (DrawX < 85 && DrawX >= 55 && DrawY < 270 && DrawY >= 240)
						curColor <= 4'b1000;
					else if (DrawX < 85 && DrawX >= 55 && DrawY < 305 && DrawY >= 275)
						curColor <= 4'b1001;
					else if (DrawX < 45 && DrawX >= 15 && DrawY < 270 && DrawY >= 240)
						curColor <= 4'b1010;
					else if (DrawX < 45 && DrawX >= 15 && DrawY < 305 && DrawY >= 275)
						curColor <= 4'b1011;
					else if (DrawX < 85 && DrawX >= 55 && DrawY < 340 && DrawY >= 310)
						curColor <= 4'b1100;
					else if (DrawX < 85 && DrawX >= 55 && DrawY < 375 && DrawY >= 345)
						curColor <= 4'b1101;
					else if (DrawX < 45 && DrawX >= 15 && DrawY < 340 && DrawY >= 310)
						curColor <= 4'b1110;
					else if (DrawX < 45 && DrawX >= 15 && DrawY < 375 && DrawY >= 345)
						curColor <= 4'b1111;
					
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


