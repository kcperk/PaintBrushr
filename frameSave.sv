module frameSave (input [9:0] xPos, yPos,
						input Clk,
						input [7:0] Ri, Gi, Bi,
						output [7:0] Ro, Go, Bo);
		
		byte r [0:439][0:279];
		byte g [0:439][0:279];
		byte b [0:439][0:279];
		always @ (posedge Clk)
		begin
			if (xPos >= 100 && yPos >= 100 && xPos < 540 && yPos < 380)
			begin
				Ro <= r[bX][bY];
				Go <= g[bX][bY];
				Bo <= b[bX][bY];
				r[bX][bY] <= Ri;
				g[bX][bY] <= Gi;
				b[bX][bY] <= Bi;
			end
			else
			begin
				Ro <= 8'h00;
				Go <= 8'h00;
				Bo <= 8'h00;
			end
		end
		assign bX = xPos - 100;
		assign bY = yPos - 100;
		
endmodule
