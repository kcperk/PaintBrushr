module testbench();

timeunit 10ns;	// Clock cycle at 50 MHz
			// This is the amount of time represented by #1 
timeprecision 1ns;

// These signals are internal because the processor will be 
// instantiated as a submodule in testbench.
logic vgaClock = 0;
logic [9:0] cursorX, cursorY, drawxsig, drawysig;
logic left_btn;
logic [3:0] inputColor;
logic [1:0] ramOut, ramOut2, ramIn, ramIn2;
logic ram_re, ram_we;
logic [7:0] VGA_R, VGA_G, VGA_B;

		
// Instantiating the DUT
// Make sure the module and signal names match with those in your design
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
											.random2(TD_DATA), .inputColor(inputColor),
											.Red(VGA_R), .Green(VGA_G), .Blue(VGA_B) );

// Toggle the clock
// #1 means wait for a delay of 1 timeunit
always begin : CLOCK_GENERATION
#2 vgaClock = ~vgaClock;
end

initial begin: CLOCK_INITIALIZATION
    vgaClock = 0;
end 

// Testing begins here
// The initial block is not synthesizable
// Everything happens sequentially inside an initial block
// as in a software program
initial begin: TEST_VECTORS
//Reset = 0;		// Toggle Rest
//Run = 0;
//Ciphertext[127:0] = 128'h0123456789abcdef;
//Cipherkey[127:0] = 128'hfedcba9876543210;
//
//#3 Reset = 1;
//
//#2 Run = 0;		// Toggle Run
//
//#10 Run = 1;
cursorX = 10'b0010110010;
cursorY = 10'b0111000100;
left_btn = 1'b1;
inputColor = 4'b1010;
ramOut = 2'b00;
ramOut2 = 2'b11;
ramIn = 2'b00;
ramIn2 = 2'b11;
ram_re = 1'b1;
ram_we = 1'b0;

drawxsig = 10'b0010110000;
drawysig = 10'b0111000100;

#2 drawxsig = 10'b0010110001;

#2 drawxsig = 10'b0010110010;
	ramOut = 2'b10;
	ramOut2 = 2'b10;
	ramIn = 2'b10;
	ramIn2 = 2'b10;

#2 drawxsig = 10'b0010110011;


#2 drawxsig = 10'b0010110100;
	
#2 drawxsig = 10'b0010110101;
	
#2 drawxsig = 10'b0010110110;
	ramOut = 2'b00;
	ramOut2 = 2'b11;
	ramIn = 2'b00;
	ramIn2 = 2'b11;

end
endmodule
