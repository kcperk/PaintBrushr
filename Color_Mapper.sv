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
								input				left_btn,
								input 		[7:0] RedPrev, GreenPrev, BluePrev,
                       output logic [7:0]  Red, Green, Blue );
    
    logic [1:0] canvas;
	 
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
	  
    always_comb
    begin:Ball_on_proc
		  if (DrawX < 100 || DrawX > 540 || DrawY < 100 || DrawY > 380 )
				canvas = 2'b11;
        else if ( ( DistX*DistX + DistY*DistY) <= (Size * Size) ) 
            canvas = 2'b01;
        else 
            canvas = 1'b00;
     end 
       
    always_comb
    begin:RGB_Display
		  if (canvas == 2'b11)
		  begin
				Red = 8'h88;
				Green = 8'h88;
				Blue = 8'h88;
		  end
        else if ((canvas == 2'b01)) 
        begin 
				if (left_btn)
				begin
					Red = 8'hff;
					Green = 8'h00;
					Blue = 8'hff;
				end
				else
				begin
					Red = 8'hff;
					Green = 8'hff;
					Blue = 8'hff;
				end
        end       
        else 
        begin 
            //Red = RedPrev; 
            //Green = GreenPrev;
            //Blue = BluePrev;
				Red = 8'h00;
				Green = 8'h00;
				Blue = 8'h00;
        end      
    end 
    
endmodule
