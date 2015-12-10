
module  lab8 		( input         CLOCK_50,
                       input[3:0]    KEY, //bit 0 is set up as Reset
							  output [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7,
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
							  inout			 PS2_CLK,				// PS2 Clock
							  input [7:0]	 TD_DATA					// Generates a bit of randomness
							  
											);
    
    logic Reset_h, Clk, vgaClock, left_btn, middle_btn, right_btn, ram_re, ram_we, rom_re;
	 logic back_we, back_re;
    logic [9:0] drawxsig, drawysig, cursorX, cursorY;
	 logic [9:0] xOffset, yOffset, xToolOffset, yLogoOffset;
	 logic [1:0] ramIn, ramOut, ramIn2, ramOut2;
	 logic [3:0] backIn, backOut, backOut2;
	 logic [2:0] romOut, romOut2;
	 logic [17:0] ramAddrRead, ramAddrWrite;
	 logic [16:0] backAddrRead, backAddrWrite, backAddrWrite2;
	 logic [13:0] romAddrRead, romAddrRead2;
    
	 assign Clk = CLOCK_50;
    assign {Reset_h}=~ (KEY[0]);  // The push buttons are active low
	 assign VGA_CLK = vgaClock;
	 assign xOffset = drawxsig-100;
	 assign yOffset = drawysig-100;
	 assign xToolOffset = drawxsig-555;
	 assign yLogoOffset = drawysig -10;
	 assign ramAddrRead = {xOffset[8:0]+ 'b1, yOffset[8:0]};
	 assign ramAddrWrite = {xOffset[8:0] - 'b1, yOffset[8:0]};
	 assign romAddrRead = (yLogoOffset[8:0] * 190) + xOffset[8:0] + 'b1;
	 assign romAddrRead2  = (yOffset[8:0] * 70) + xToolOffset[8:0] + 'b1;
	 assign backAddrRead = (yOffset[8:0] * 440) + xOffset + 'b1;
	 assign backAddrWrite = (yOffset[8:0] * 440) + (440 - xOffset) - 'b1;
	 assign backAddrWrite2 = ((279 - yOffset[8:0]) * 440) + xOffset - 'b1;
	 

    vga_controller vgasync_instance(.Clk(Clk), .Reset(Reset_h),
												.hs(VGA_HS), .vs(VGA_VS),
												.pixel_clk(vgaClock), .blank(VGA_BLANK_N),
												.sync(VGA_SYNC_N), 
												.DrawX(drawxsig), .DrawY(drawysig)
												);
												
	 Mouse cursor_0 (.CLOCK_50(Clk), .KEY(KEY), .PS2_CLK(PS2_CLK), .PS2_DAT(PS2_DAT), 
							.HEX0(HEX0), .HEX1(HEX1), .HEX2(HEX2),
							.HEX3(HEX3), .HEX4(HEX4), .HEX5(HEX5),
							.cursorX(cursorX), .cursorY(cursorY), 
							.leftButton(left_btn), .middleButton(middle_btn), .rightButton(right_btn));

    color_mapper color_instance(.CursorX(cursorX), .CursorY(cursorY),
											.DrawX(drawxsig), .DrawY(drawysig),
											.left_btn(left_btn), .vgaClk(vgaClock),
											.ramIn(ramIn), .ramIn2(ramIn2),
											.backIn(backIn), .backOut(backOut), .backOut2(backOut2),
											.ramOut(ramOut), .ramOut2(ramOut2),
											.romOut(romOut), .romOut2(romOut2),
											.ram_read(ram_re), .ram_write(ram_we), 
											.rom_read(rom_re), .rom_read2(rom_re2),
											.back_write(back_we), .back_read(back_re),
											.random2(TD_DATA),
											.Red(VGA_R), .Green(VGA_G), .Blue(VGA_B) );
											
	ram screen0 ( .data(ramIn),
					.rdaddress(ramAddrRead), .rdclock(~vgaClock), .rden(ram_re), 
					.wraddress(ramAddrWrite), .wrclock(~vgaClock), .wren(ram_we), 
					.q(ramOut));
	ram screen1 ( .data(ramIn2),
					.rdaddress(ramAddrRead), .rdclock(~vgaClock), .rden(ram_re), 
					.wraddress(ramAddrWrite), .wrclock(~vgaClock), .wren(ram_we), 
					.q(ramOut2));
					
	back horizScreen ( .data(backIn),
					.rdaddress(backAddrRead), .rdclock(~vgaClock), .rden(back_re), 
					.wraddress(backAddrWrite), .wrclock(~vgaClock), .wren(back_we), 
					.q(backOut));
	
	back vertScreen ( .data(backIn),
					.rdaddress(backAddrRead), .rdclock(~vgaClock), .rden(back_re), 
					.wraddress(backAddrWrite2), .wrclock(~vgaClock), .wren(back_we), 
					.q(backOut2));
	
					
	rom logoSprite ( .address(romAddrRead), .clock(~vgaClock), .rden(rom_re),
					.q(romOut));
	
	rom2 toolSprite ( .address(romAddrRead2), .clock(~vgaClock), .rden(rom_re2),
					.q(romOut2));
										  
    
endmodule
