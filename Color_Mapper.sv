//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013										 --
//		Paint Adaptation by Kevin Perkins and Tarun Rajendran 12-09-2015   --
//                                                                       --
//    Fall 2014 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 7                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------


module  color_mapper ( input        [9:0] CursorX, CursorY, DrawX, DrawY,
								input				left_btn, vgaClk,
								input [1:0]		ramOut, ramOut2,
								input [2:0]		romOut, romOut2,
								input [3:0]		backOut, backOut2,
								input [7:0]		random2,
								input [3:0]		inputColor,
								output logic ram_read, ram_write, rom_read, rom_read2, 
								output logic back_write, back_read,
								output logic [1:0] ramIn, ramIn2,
								output logic [3:0] backIn,
                       output logic [7:0]  Red, Green, Blue );
    
	 
	 logic canvas, tools, logo, cursorInCanvas;
	 logic [3:0] curColor;
	 logic [9:0] Brush_size;
	 logic [2:0] Brush_type;
	 logic [18:0] counter;
	 logic pressed, horiz, vert, rando;
	 logic [3:0] toReplace;
	 logic [3:0] atCursor;
	 logic [3:0] randomish, rand1;
	  
    int DistX, DistY, DistX2, DistY2, Size;
	 assign DistX = DrawX - CursorX;
    assign DistY = DrawY - CursorY;
	 assign DistX2 = DrawX > CursorX ? DrawX - CursorX : CursorX - DrawX;
	 assign DistY2 = DrawY > CursorY ? DrawY - CursorY : CursorY - DrawY;
    assign Size = Brush_size;
	 assign ram_read = canvas || DrawX == 99;
	 assign ram_write = canvas || DrawX == 540;
	 assign back_read = canvas;
	 assign back_write = canvas;
	 assign rom_read = logo;
	 assign rom_read2 = tools;
	 assign rand1 = {ramOut[1]^ramOut[0]^DrawX[3]^DrawY[0],
								ramOut2[1]^ramOut2[0]^DrawX[2]^DrawY[1], 
								ramOut[0]^ramOut[1]^DrawX[1]^DrawY[2], 
								ramOut2[1]^ramOut[0]^DrawX[0]^DrawY[3]} ^ counter[3:0];
	 //assign randomish = counter[0] == 0 ? rand1 : ~rand1;
	 assign randomish = rand1 ^ ~random2;
	 
	 always_comb
	 begin
			if (DrawX < 540 && DrawY < 380 && DrawX >= 100 && DrawY >= 100)
				canvas = 1'b1;
			else
				canvas = 1'b0;
			if (DrawX < 625 && DrawY < 305 && DrawX >= 555 && DrawY >= 100)
				tools = 1'b1;
			else
				tools = 1'b0;
			if (DrawX < 290 && DrawY < 70 && DrawX >= 100 && DrawY >= 10)
				logo = 1'b1;
			else
				logo = 1'b0;
			if (CursorX < 540 && CursorY < 380 && CursorX >= 100 && CursorY >= 100)
				cursorInCanvas = 1'b1;
			else
				cursorInCanvas = 1'b0;
	 end
	 

	  always_ff @ (posedge vgaClk)
	  begin
			backIn <= {ramOut2, ramOut};
			ramIn <= ramOut;
			ramIn2 <= ramOut2;
			if (CursorX == DrawX && CursorY == DrawY)
				atCursor <= {ramOut2, ramOut};
			if ((left_btn && cursorInCanvas && Brush_type == 3'b100 && counter == 0) || counter != 0)
			begin
				if (horiz)
				begin
					pressed <= 1'b1;
					ramIn <= backOut[1:0];
					ramIn2 <= backOut[3:2];
				end
				else if (vert)
				begin
					pressed <= 1'b1;
					ramIn <= backOut2[1:0];
					ramIn2 <= backOut2[3:2];
				end
				else if (rando)
				begin
					pressed <= 1'b1;
					ramIn <= randomish[1:0];
					ramIn2 <= randomish[3:2];
				end
				else
				begin
					// Color Replacement
					pressed <= 1'b1;
					if (counter == 0)
						toReplace <= atCursor;
					if (!cursorInCanvas)
					begin
						ramIn <= 2'b00;
						ramIn2 <= 2'b00;
					end
					else if (toReplace[3:2] == ramOut2 && toReplace[1:0] == ramOut)
					begin
						ramIn <= curColor[1:0];
						ramIn2 <= curColor[3:2];
					end
				end
				if (counter == 419999)
				begin
					counter <= 0;
					horiz <= 1'b0;
					vert <= 1'b0;
					rando <= 1'b0;
				end
				else
					counter <= counter + 'b1;
			end
			else if (left_btn)
			begin
				// First set of 8 colors
				
				if (CursorX < 85 && CursorX >= 55 && CursorY < 130 && CursorY >= 100)
					curColor <= 4'b0000;
				else if (CursorX < 85 && CursorX >= 55 && CursorY < 165 && CursorY >= 135)
					curColor <= 4'b0001;
				else if (CursorX < 45 && CursorX >= 15 && CursorY < 130 && CursorY >= 100)
					curColor <= 4'b0010;
				else if (CursorX < 45 && CursorX >= 15 && CursorY < 165 && CursorY >= 135)
					curColor <= 4'b0011;
				else if (CursorX < 85 && CursorX >= 55 && CursorY < 200 && CursorY >= 170)
					curColor <= 4'b0100;
				else if (CursorX < 85 && CursorX >= 55 && CursorY < 235 && CursorY >= 205)
					curColor <= 4'b0101;
				else if (CursorX < 45 && CursorX >= 15 && CursorY < 200 && CursorY >= 170)
					curColor <= 4'b0110;
				else if (CursorX < 45 && CursorX >= 15 && CursorY < 235 && CursorY >= 205)
					curColor <= 4'b0111;
				
				// Second set of 8 colors
				
				else if (CursorX < 85 && CursorX >= 55 && CursorY < 270 && CursorY >= 240)
					curColor <= 4'b1000;
				else if (CursorX < 85 && CursorX >= 55 && CursorY < 305 && CursorY >= 275)
					curColor <= 4'b1001;
				else if (CursorX < 45 && CursorX >= 15 && CursorY < 270 && CursorY >= 240)
					curColor <= 4'b1010;
				else if (CursorX < 45 && CursorX >= 15 && CursorY < 305 && CursorY >= 275)
					curColor <= 4'b1011;
				else if (CursorX < 85 && CursorX >= 55 && CursorY < 340 && CursorY >= 310)
					curColor <= 4'b1100;
				else if (CursorX < 85 && CursorX >= 55 && CursorY < 375 && CursorY >= 345)
					curColor <= 4'b1101;
				else if (CursorX < 45 && CursorX >= 15 && CursorY < 340 && CursorY >= 310)
					curColor <= 4'b1110;
				else if (CursorX < 45 && CursorX >= 15 && CursorY < 375 && CursorY >= 345)
					curColor <= 4'b1111;
				
				// Larger Brush Size Button
				if (CursorX < 585 && CursorX >= 555 && CursorY < 130 && CursorY >= 100 && !pressed)
				begin
					pressed <= 1'b1;
					if (Brush_size < 10'h0ff)
						Brush_size <= Brush_size + 'b11;
				end
				// Smaller Brush Size Button
				else if (CursorX < 625 && CursorX >= 595 && CursorY < 130 && CursorY >= 100 && !pressed)
				begin
					pressed <= 1'b1;
					if (Brush_size > 10'b0)
						Brush_size <= Brush_size - 'b11;
				end
				// Circle Brush
				else if (CursorX < 585 && CursorX >= 555 && CursorY < 165 && CursorY >= 135)
					Brush_type <= 3'b000;
				// Sqaure Brush
				else if (CursorX < 625 && CursorX >= 595 && CursorY < 165 && CursorY >= 135)
					Brush_type <= 3'b001;
				// Horizontal Line Brush
				else if (CursorX < 585 && CursorX >= 555 && CursorY < 200 && CursorY >= 170)
					Brush_type <= 3'b010;
				// Vertical Line Brush
				else if (CursorX < 625 && CursorX >= 595 && CursorY < 200 && CursorY >= 170)
					Brush_type <= 3'b011;
				// Random
				else if (CursorX < 585 && CursorX >= 555 && CursorY < 235 && CursorY >= 205 && ~pressed)
				begin
					pressed <= 1'b1;
					counter <= 19'b01;
					rando <= 1'b1;
				end
				// Paint Bucket
				else if (CursorX < 625 && CursorX >= 595 && CursorY < 235 && CursorY >= 205)
					Brush_type <= 3'b100;
				// Eraser
				else if (CursorX < 585 && CursorX >= 555 && CursorY < 270 && CursorY >= 240)
				begin
					Brush_type <= 3'b001;
					curColor <= 4'b0000;
				end
				// Clear
				else if (CursorX < 625 && CursorX >= 595 && CursorY < 270 && CursorY >= 240 && ~pressed)
				begin
					pressed <= 1'b1;
					counter <= 19'b01;
				end
				// Flip Horizontal
				else if (CursorX < 585 && CursorX >= 555 && CursorY < 305 && CursorY >= 275 && ~pressed)
				begin
					pressed <= 1'b1;
					counter <= 19'b01;
					horiz <= 1'b1;
				end
				// Flip Horizontal
				else if (CursorX < 625 && CursorX >= 595 && CursorY < 305 && CursorY >= 275 && ~pressed)
				begin
					pressed <= 1'b1;
					counter <= 19'b01;
					vert <= 1'b1;
				end
			end
			else
			begin
				pressed <= 1'b0;
			end
				
			
			if ((Brush_type == 3'b000 &&( DistX*DistX + DistY*DistY) <= (Size * Size))//Inside Circle 
				|| (Brush_type == 3'b001 && DistX2 <= Size && DistY2 <= Size)//Inside Square
				|| (Brush_type == 3'b010 && DistY2 <= Size >> 3 && DistX2 <= Size)//Horizontal Brush
				|| (Brush_type == 3'b011 && DistX2 <= Size >> 3 && DistY2 <= Size))//Vertical Brush
			begin 
				// Write to canvas
				if (left_btn && cursorInCanvas)
				begin
					ramIn <= curColor[1:0];
					ramIn2 <= curColor[3:2];
					backIn <= curColor;
				end
				// Display brush 
				case (curColor)
				4'b0000:
					begin
						Red <= 8'hff;
						Green <= 8'hff;
						Blue <= 8'hff;
					end
				4'b0001:
					begin
						Red <= 8'h55;
						Green <= 8'h55;
						Blue <= 8'h55;
					end
				4'b0010:
					begin
						Red <= 8'haa;
						Green <= 8'haa;
						Blue <= 8'haa;
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
						Green <= 8'h00;
						Blue <= 8'h00;
					end
				4'b0101:
					begin
						Red <= 8'h00;
						Green <= 8'hff;
						Blue <= 8'h00;
					end
				4'b0110:
					begin
						Red <= 8'h55;
						Green <= 8'h00;
						Blue <= 8'h00;
					end
				4'b0111:
					begin
						Red <= 8'h00;
						Green <= 8'h55;
						Blue <= 8'h00;
					end
				
				4'b1000:
					begin
						Red <= 8'h00;
						Green <= 8'h00;
						Blue <= 8'hff;
					end
				4'b1001:
					begin
						Red <= 8'hff;
						Green <= 8'hff;
						Blue <= 8'h00;
					end
				4'b1010:
					begin
						Red <= 8'h00;
						Green <= 8'h00;
						Blue <= 8'h55;
					end
				4'b1011:
					begin
						Red <= 8'hff;
						Green <= 8'h55;
						Blue <= 8'h00;
					end
				4'b1100:
					begin
						Red <= 8'hff;
						Green <= 8'h00;
						Blue <= 8'hff;
					end
				4'b1101:
					begin
						Red <= 8'h00;
						Green <= 8'hff;
						Blue <= 8'hff;
					end
				4'b1110:
					begin
						Red <= 8'h66;
						Green <= 8'h00;
						Blue <= 8'h99;
					end
				4'b1111:
					begin
						Red <= 8'h99;
						Green <= 8'h33;
						Blue <= 8'h00;
					end
				endcase
			end
			
		  else if (DrawX < 100 || DrawX >= 540 || DrawY < 100 || DrawY >= 380)
			begin
				// Color Selections
				if (DrawX < 85 && DrawX >= 55 && DrawY < 130 && DrawY >= 100)
				begin// White
					Red <= 8'hff;
					Green <= 8'hff;
					Blue <= 8'hff;
				end
				else if (DrawX < 85 && DrawX >= 55 && DrawY < 165 && DrawY >= 135)
				begin// Dark Grey
					Red <= 8'h55;
					Green <= 8'h55;
					Blue <= 8'h55;
				end
				else if (DrawX < 45 && DrawX >= 15 && DrawY < 130 && DrawY >= 100)
				begin// Light Grey
					Red <= 8'haa;
					Green <= 8'haa;
					Blue <= 8'haa;
				end
				else if (DrawX < 45 && DrawX >= 15 && DrawY < 165 && DrawY >= 135)
				begin// Black
					Red <= 8'hf00;
					Green <= 8'h00;
					Blue <= 8'h00;
				end
				else if (DrawX < 85 && DrawX >= 55 && DrawY < 200 && DrawY >= 170)
				begin// Red
					Red <= 8'hff;
					Green <= 8'h00;
					Blue <= 8'h00;
				end
				else if (DrawX < 85 && DrawX >= 55 && DrawY < 235 && DrawY >= 205)
				begin// Green
					Red <= 8'h00;
					Green <= 8'hff;
					Blue <= 8'h00;
				end
				else if (DrawX < 45 && DrawX >= 15 && DrawY < 200 && DrawY >= 170)
				begin// Dark Red
					Red <= 8'h55;
					Green <= 8'h00;
					Blue <= 8'h00;
				end
				else if (DrawX < 45 && DrawX >= 15 && DrawY < 235 && DrawY >= 205)
				begin// Dark Green
					Red <= 8'h00;
					Green <= 8'h55;
					Blue <= 8'h00;
				end
				
				else if (DrawX < 85 && DrawX >= 55 && DrawY < 270 && DrawY >= 240)
				begin// Blue
					Red <= 8'h00;
					Green <= 8'h00;
					Blue <= 8'hff;
				end
				else if (DrawX < 85 && DrawX >= 55 && DrawY < 305 && DrawY >= 275)
				begin// Yellow
					Red <= 8'hff;
					Green <= 8'hff;
					Blue <= 8'h00;
				end// Dark Blue
				else if (DrawX < 45 && DrawX >= 15 && DrawY < 270 && DrawY >= 240)
				begin
					Red <= 8'h00;
					Green <= 8'h00;
					Blue <= 8'h55;
				end
				else if (DrawX < 45 && DrawX >= 15 && DrawY < 305 && DrawY >= 275)
				begin// Orange
					Red <= 8'hff;
					Green <= 8'h55;
					Blue <= 8'h00;
				end
				else if (DrawX < 85 && DrawX >= 55 && DrawY < 340 && DrawY >= 310)
				begin// Magenta
					Red <= 8'hff;
					Green <= 8'h00;
					Blue <= 8'hff;
				end
				else if (DrawX < 85 && DrawX >= 55 && DrawY < 375 && DrawY >= 345)
				begin// Cyan
					Red <= 8'h00;
					Green <= 8'hff;
					Blue <= 8'hff;
				end
				else if (DrawX < 45 && DrawX >= 15 && DrawY < 340 && DrawY >= 310)
				begin// Purple
					Red <= 8'h66;
					Green <= 8'h00;
					Blue <= 8'h99;
				end
				else if (DrawX < 45 && DrawX >= 15 && DrawY < 375 && DrawY >= 345)
				begin// Brown
					Red <= 8'h99;
					Green <= 8'h33;
					Blue <= 8'h00;
				end
				
				// Sprite for PaintBrushr Logo
				else if (logo)
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
						Red <= 8'hff;
						Green <= 8'hff;
						Blue <= 8'h00;
					end
				3'b010:
					begin
						Red <= 8'h00;
						Green <= 8'h00;
						Blue <= 8'h00;
					end
				3'b011:
					begin
						Red <= 8'h00;
						Green <= 8'hff;
						Blue <= 8'h00;
					end
				3'b101:
					begin
						Red <= 8'hff;
						Green <= 8'h00;
						Blue <= 8'h00;
					end
				3'b110:
					begin
						Red <= 8'hff;
						Green <= 8'h55;
						Blue <= 8'h00;
					end
				3'b001:
					begin
						Red <= 8'h00;
						Green <= 8'h00;
						Blue <= 8'hff;
					end
				default:
					begin
						Red <= 8'h88;
						Green <= 8'h88;
						Blue <= 8'h88;
					end
				endcase
				end
				
				// Sprite for tools
				else if (tools)
				begin
				case (romOut2)
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
				3'b011:
					begin
						Red <= 8'hbb;
						Green <= 8'hbb;
						Blue <= 8'hbb;
					end
				3'b001:
					begin
						Red <= 8'h88;
						Green <= 8'h88;
						Blue <= 8'h88;
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
			case (ramOut2)
			2'b00:
			begin
				case (ramOut)
				2'b00://White
					begin
						Red <= 8'hff;
						Green <= 8'hff;
						Blue <= 8'hff;
					end
				2'b01://Dark Grey
					begin
						Red <= 8'h55;
						Green <= 8'h55;
						Blue <= 8'h55;
					end
				2'b10://Light Grey
					begin
						Red <= 8'haa;
						Green <= 8'haa;
						Blue <= 8'haa;
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
					begin//Red
						Red <= 8'hff;
						Green <= 8'h00;
						Blue <= 8'h00;
					end
				2'b01:
					begin//Green
						Red <= 8'h00;
						Green <= 8'hff;
						Blue <= 8'h00;
					end
				2'b10:
					begin//Dark Red
						Red <= 8'h55;
						Green <= 8'h00;
						Blue <= 8'h00;
					end
				2'b11:
					begin//Dark Green
						Red <= 8'h00;
						Green <= 8'h55;
						Blue <= 8'h00;
					end
				endcase
			end
			2'b10:
			begin
				case (ramOut)
				2'b00:
					begin//Blue
						Red <= 8'h00;
						Green <= 8'h00;
						Blue <= 8'hff;
					end
				2'b01:
					begin//Yellow
						Red <= 8'hff;
						Green <= 8'hff;
						Blue <= 8'h00;
					end
				2'b10:
					begin//Dark Blue
						Red <= 8'h00;
						Green <= 8'h00;
						Blue <= 8'h55;
					end
				2'b11:
					begin//Orange
						Red <= 8'hff;
						Green <= 8'h55;
						Blue <= 8'h00;
					end
				endcase
			end
			2'b11:
			begin
				case (ramOut)
				2'b00:
					begin//Magenta
						Red <= 8'hff;
						Green <= 8'h00;
						Blue <= 8'hff;
					end
				2'b01:
					begin//Cyan
						Red <= 8'h00;
						Green <= 8'hff;
						Blue <= 8'hff;
					end
				2'b10:
					begin//Purple
						Red <= 8'h66;
						Green <= 8'h00;
						Blue <= 8'h99;
					end
				2'b11:
					begin//Brown
						Red <= 8'h99;
						Green <= 8'h33;
						Blue <= 8'h00;
					end
				endcase
			end
			endcase
		  end 
		  
		  // Draw crosshair
		  if (CursorX == DrawX)
		  begin
				Red <= 8'hff;
				Green <= 8'hff;
				Blue <= 8'hff;
		  end
		  if (CursorY == DrawY)
		  begin
				Red <= 8'hff;
				Green <= 8'hff;
				Blue <= 8'hff;
		  end
	  end
	  
	  
    
endmodule


