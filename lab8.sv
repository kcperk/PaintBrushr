
module  lab8 		( input         CLOCK_50,
                       input[3:0]    KEY, //bit 0 is set up as Reset
							  output [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7,
							  output [8:0]  LEDG,
							  //output [7:0]  LEDR,
							  output [17:0] LEDR,
							  // VGA Interface 
                       output [7:0]  VGA_R,					//VGA Red
							                VGA_G,					//VGA Green
												 VGA_B,					//VGA Blue
							  output        VGA_CLK,				//VGA Clock
							                VGA_SYNC_N,			//VGA Sync signal
												 VGA_BLANK_N,			//VGA Blank signal
												 VGA_VS,					//VGA virtical sync signal	
												 VGA_HS,					//VGA horizontal sync signal
								// PS2 Interface
							  inout			 PS2_DAT,				// PS2 Data Bus
							  inout			 PS2_CLK					// PS2 Clock 
							  
											);
    
    logic Reset_h, Clk, vgaClock, left_btn, middle_btn, right_btn, ram_re, ram_we, rom_re;
    logic [9:0] drawxsig, drawysig, cursorX, cursorY;
	 logic [9:0] xOffset, yOffset, xOffset2, yOffset2, xOffset3, yOffset3, xToolOffset;
	 logic [1:0] ramIn, ramOut, ramIn2, ramOut2;
	 logic [2:0] romOut;
	 logic [17:0] ramAddrRead, ramAddrWrite;
	 logic [13:0] romAddrRead;
    
	 assign Clk = CLOCK_50;
    assign {Reset_h}=~ (KEY[0]);  // The push buttons are active low
	 assign VGA_CLK = vgaClock;
	 assign xOffset = drawxsig-100;
	 assign xOffset2 = (xOffset == 439) ? 0 : xOffset+1;
	 assign xOffset3 = (xOffset == 0) ? 439 : xOffset-1;
	 assign yOffset = drawysig-100;
	 assign yOffset2 = (xOffset == 439) ? (yOffset == 279) ? 0 :  yOffset + 1 : yOffset;
	 assign yOffset3 = (xOffset == 0) ? (yOffset == 0) ? 279 : yOffset - 1 : yOffset;
	 assign xToolOffset = drawxsig-555;
	 assign ramAddrRead = {xOffset2[8:0], yOffset2[8:0]};
	 assign ramAddrWrite = {xOffset3[8:0], yOffset3[8:0]};
	 assign romAddrRead  = (yOffset[8:0] * 70) + xToolOffset[8:0] + 'b1;
	 

    vga_controller vgasync_instance(.Clk(Clk), .Reset(Reset_h),
												.hs(VGA_HS), .vs(VGA_VS),
												.pixel_clk(vgaClock), .blank(VGA_BLANK_N),
												.sync(VGA_SYNC_N), 
												.DrawX(drawxsig), .DrawY(drawysig)
												);
												
	Mouse 	cursor_0 (.CLOCK_50(Clk), .KEY(KEY), .PS2_CLK(PS2_CLK), .PS2_DAT(PS2_DAT), 
							.HEX0(HEX0), .HEX1(HEX1), .HEX2(HEX2),
							.HEX3(HEX3), .HEX4(HEX4), .HEX5(HEX5),
							.cursorX(cursorX), .cursorY(cursorY), 
							.leftButton(left_btn), .middleButton(middle_btn), .rightButton(right_btn));

    color_mapper color_instance(.BallX(cursorX), .BallY(cursorY),
											.DrawX(drawxsig), .DrawY(drawysig),
											.left_btn(left_btn), .vgaClk(vgaClock),
											.ramIn(ramIn), .ramIn2(ramIn2), 
											.ramOut(ramOut), .ramOut2(ramOut2),
											.romOut(romOut),
											.ram_read(ram_re), .ram_write(ram_we), .rom_read(rom_re),
											.Red(VGA_R), .Green(VGA_G), .Blue(VGA_B) );
											
	ram ram_0 ( .data(ramIn),
					.rdaddress(ramAddrRead), .rdclock(~vgaClock), .rden(ram_re), 
					.wraddress(ramAddrWrite), .wrclock(~vgaClock), .wren(ram_we), 
					.q(ramOut));
	ram ram_1 ( .data(ramIn2),
					.rdaddress(ramAddrRead), .rdclock(~vgaClock), .rden(ram_re), 
					.wraddress(ramAddrWrite), .wrclock(~vgaClock), .wren(ram_we), 
					.q(ramOut2));
	/*				
	rom rom_1 ( .address(romAddrRead), .clock(~vgaClock), .rden(rom_re),
					.q(romOut));
	*/
	rom2 rom_1 ( .address(romAddrRead), .clock(~vgaClock), .rden(rom_re),
					.q(romOut));
										  
    
endmodule
