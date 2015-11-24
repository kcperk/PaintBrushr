module cursor (input Clk, Reset,
					input [7:0] byte1, byte2, byte3,
					output [9:0] cursorX, cursorY,
					output leftButton, middleButton, rightButton);

logic [9:0] curX, curY;
					
logic [7:0] lastb2, lastb3;
logic [8:0] magX, magY;
logic sX, sY;
					

assign cursorX = curX;
assign cursorY = curY;
assign sX = byte1[4];
assign sY = byte1[5];
assign magX = sX ? {1'b0,~byte3[7:0]}+'b1 : {1'b0,byte3[7:0]};
assign magY = sY ? {1'b0,~byte2[7:0]}+'b1 : {1'b0,byte2[7:0]};

always_ff @ (posedge Clk or posedge Reset)
begin
	if (Reset)
	begin
		leftButton <= 1'b0;
		middleButton <= 1'b0;
		rightButton <= 1'b0;
		curX <= 10'd105;
		curY <= 10'd105;
		lastb2 <= 8'h0;
		lastb3 <= 8'h0;
	end
	else
	begin
		leftButton <= byte1[0];
		middleButton <= byte1[2];
		rightButton <= byte1[1];
		
		if (byte3 != lastb3)
		curX <= (sX ? (curX-105>magX ? curX - magX : 105) 
			  : (curX < 535 - magX ? curX+magX : 535));
		if (byte2 != lastb2)
      curY <= (sY ? (curY < 375 - magY ? curY+magY : 375)
			  : (curY-105>magY ? curY - magY : 105));
		
		lastb2 <= byte2;
		lastb3 <= byte3;
	end
end

					
endmodule
