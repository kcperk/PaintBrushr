
module PS2_Demo (
	// Inputs
	CLOCK_50,
	KEY,

	// Bidirectionals
	PS2_CLK,
	PS2_DAT,
	
	// Outputs
	HEX0,
	HEX1,
	HEX2,
	HEX3,
	HEX4,
	HEX5,
	HEX6,
	HEX7,
	byte1,
	byte2,
	byte3
);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/


/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/

// Inputs
input				CLOCK_50;
input		[3:0]	KEY;

// Bidirectionals
inout				PS2_CLK;
inout				PS2_DAT;

// Outputs
output		[6:0]	HEX0;
output		[6:0]	HEX1;
output		[6:0]	HEX2;
output		[6:0]	HEX3;
output		[6:0]	HEX4;
output		[6:0]	HEX5;
output		[6:0]	HEX6;
output		[6:0]	HEX7;
output		[7:0] byte1;
output		[7:0] byte2;
output		[7:0] byte3;

/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/

// Internal Wires
wire		[7:0]	ps2_key_data;
wire				ps2_key_pressed;

// Internal Registers
reg			[7:0]	last_data_received;
reg			[7:0] second_data;
reg			[7:0] first_data;
reg			[1:0] counter;

// State Machine Registers

/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/


/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/

always @(posedge CLOCK_50)
begin
	if (KEY[0] == 1'b0)
	begin
		last_data_received <= 8'h00;
		counter <= 2'b00;
	end
	else if (ps2_key_pressed == 1'b1)
	begin
		if (counter == 0)
		begin
			first_data <= ps2_key_data;
			counter <= 2'b01;
		end
		else if (counter == 1)
		begin
			second_data <= ps2_key_data;
			counter <= 2'b10;
		end
		else
		begin
			last_data_received <= ps2_key_data;
			counter <= 2'b00;
		end
	end
end

/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/

assign HEX6 = 7'h7F;
assign HEX7 = 7'h7F;
assign byte1 = last_data_received;
assign byte2 = second_data;
assign byte3 = first_data;

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/

PS2_Controller PS2 (
	// Inputs
	.CLOCK_50				(CLOCK_50),
	.reset				(~KEY[0]),

	// Bidirectionals
	.PS2_CLK			(PS2_CLK),
 	.PS2_DAT			(PS2_DAT),

	// Outputs
	.received_data		(ps2_key_data),
	.received_data_en	(ps2_key_pressed)
);

HexDriver Segment0 (
	// Inputs
	.In0			(last_data_received[3:0]),

	// Bidirectional

	// Outputs
	.Out0	(HEX0)
);

HexDriver Segment1 (
	// Inputs
	.In0			(last_data_received[7:4]),

	// Bidirectional

	// Outputs
	.Out0	(HEX1)
);

HexDriver Segment2 (
	// Inputs
	.In0			(second_data[3:0]),

	// Bidirectional

	// Outputs
	.Out0	(HEX2)
);

HexDriver Segment3 (
	// Inputs
	.In0			(second_data[7:4]),

	// Bidirectional

	// Outputs
	.Out0	(HEX3)
);

HexDriver Segment4 (
	// Inputs
	.In0			(first_data[3:0]),

	// Bidirectional

	// Outputs
	.Out0	(HEX4)
);

HexDriver Segment5 (
	// Inputs
	.In0			(first_data[7:4]),

	// Bidirectional

	// Outputs
	.Out0	(HEX5)
);




endmodule
