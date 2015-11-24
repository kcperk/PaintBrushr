//-------------------------------------------------------------------------
//      lab7_usb.sv                                                      --
//      Christine Chen                                                   --
//      Fall 2014                                                        --
//                                                                       --
//      Fall 2014 Distribution                                           --
//                                                                       --
//      For use with ECE 385 Lab 7                                       --
//      UIUC ECE Department                                              --
//-------------------------------------------------------------------------


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
							  // CY7C67200 Interface
							  inout [15:0]  OTG_DATA,						//	CY7C67200 Data bus 16 Bits
							  output [1:0]  OTG_ADDR,						//	CY7C67200 Address 2 Bits
							  output        OTG_CS_N,						//	CY7C67200 Chip Select
												 OTG_RD_N,						//	CY7C67200 Write
												 OTG_WR_N,						//	CY7C67200 Read
												 OTG_RST_N,						//	CY7C67200 Reset
							  input			 OTG_INT,						//	CY7C67200 Interrupt
							  // SDRAM Interface for Nios II Software
							  output [12:0] DRAM_ADDR,				// SDRAM Address 13 Bits
							  inout [31:0]  DRAM_DQ,				// SDRAM Data 32 Bits
							  output [1:0]  DRAM_BA,				// SDRAM Bank Address 2 Bits
							  output [3:0]  DRAM_DQM,				// SDRAM Data Mast 4 Bits
							  output			 DRAM_RAS_N,			// SDRAM Row Address Strobe
							  output			 DRAM_CAS_N,			// SDRAM Column Address Strobe
							  output			 DRAM_CKE,				// SDRAM Clock Enable
							  output			 DRAM_WE_N,				// SDRAM Write Enable
							  output			 DRAM_CS_N,				// SDRAM Chip Select
							  output			 DRAM_CLK,				// SDRAM Clock
							  inout			 PS2_DAT,
							  inout			 PS2_CLK
							  
											);
    
    logic Reset_h, vssig, Clk, vgaClock, left_btn, middle_btn, right_btn;
    logic [9:0] drawxsig, drawysig, ballsizesig, cursorX, cursorY;
	 logic [15:0] keycode;
	 logic [7:0] RPrev, GPrev, BPrev, byte1, byte2, byte3;
    
	 assign Clk = CLOCK_50;
    assign {Reset_h}=~ (KEY[0]);  // The push buttons are active low
	 assign VGA_CLK = vgaClock;
	
	 
	 wire [1:0] hpi_addr;
	 wire [15:0] hpi_data_in, hpi_data_out;
	 wire hpi_r, hpi_w,hpi_cs;
	 
	 hpi_io_intf hpi_io_inst(   .from_sw_address(hpi_addr),
										 .from_sw_data_in(hpi_data_in),
										 .from_sw_data_out(hpi_data_out),
										 .from_sw_r(hpi_r),
										 .from_sw_w(hpi_w),
										 .from_sw_cs(hpi_cs),
		 								 .OTG_DATA(OTG_DATA),    
										 .OTG_ADDR(OTG_ADDR),    
										 .OTG_RD_N(OTG_RD_N),    
										 .OTG_WR_N(OTG_WR_N),    
										 .OTG_CS_N(OTG_CS_N),    
										 .OTG_RST_N(OTG_RST_N),   
										 .OTG_INT(OTG_INT),
										 .Clk(Clk),
										 .Reset(Reset_h)
	 );
	 
	 //The connections for nios_system might be named different depending on how you set up Qsys
	 nios_system nios_system(
										 .clk_clk(Clk),         
										 .reset_reset_n(KEY[0]),   
										 .sdram_wire_addr(DRAM_ADDR), 
										 .sdram_wire_ba(DRAM_BA),   
										 .sdram_wire_cas_n(DRAM_CAS_N),
										 .sdram_wire_cke(DRAM_CKE),  
										 .sdram_wire_cs_n(DRAM_CS_N), 
										 .sdram_wire_dq(DRAM_DQ),   
										 .sdram_wire_dqm(DRAM_DQM),  
										 .sdram_wire_ras_n(DRAM_RAS_N),
										 .sdram_wire_we_n(DRAM_WE_N), 
										 .sdram_clk_clk(DRAM_CLK),
										 .keycode_export(keycode),  
										 .otg_hpi_address_export(hpi_addr),
										 .otg_hpi_data_in_port(hpi_data_in),
										 .otg_hpi_data_out_port(hpi_data_out),
										 .otg_hpi_cs_export(hpi_cs),
										 .otg_hpi_r_export(hpi_r),
										 .otg_hpi_w_export(hpi_w),
										 );
	
	//Fill in the connections for the rest of the modules 
    vga_controller vgasync_instance(.Clk(Clk), .Reset(Reset_h),
												.hs(VGA_HS), .vs(VGA_VS),
												.pixel_clk(vgaClock), .blank(VGA_BLANK_N),
												.sync(VGA_SYNC_N), 
												.DrawX(drawxsig), .DrawY(drawysig)
												);
												
	PS2_Demo 	ps2 (.CLOCK_50(Clk), .KEY(KEY), .PS2_CLK(PS2_CLK), .PS2_DAT(PS2_DAT), 
							.HEX0(HEX0), .HEX1(HEX1), .HEX2(HEX2),
							.HEX3(HEX3), .HEX4(HEX4), .HEX5(HEX5),
							.byte1(byte1), .byte2(byte2), .byte3(byte3));
   /*
    ball ball_instance(.Reset(Reset_h), .frame_clk(VGA_VS),
								.keycode(keycode[7:0]),
								.BallX(ballxsig), .BallY(ballysig), .BallS(ballsizesig)
								);
   */
	
	 cursor cursor0 (.Clk(Clk), .Reset(Reset_h), 
						.byte1(byte1), .byte2(byte2), .byte3(byte3),
						.cursorX(cursorX), .cursorY(cursorY), 
						.leftButton(left_btn), .middleButton(middle_btn), .rightButton(right_btn));
	
	 /*
	 frameSave	frame_0 (.xPos(drawxsig), .yPos(drawxsig), .Clk(vgaClock),
								.Ri(VGA_R), .Gi(VGA_G), .Bi(VGA_B), 
								.Ro(RPrev), .Go(GPrev), .Bo(BPrev));
	*/
    color_mapper color_instance(.BallX(cursorX), .BallY(cursorY),
											.DrawX(drawxsig), .DrawY(drawysig), .Ball_size(10'b0100),
											.left_btn(left_btn),
											//.RedPrev(RPrev), .GreenPrev(GPrev), .BluePrev(BPrev),
											.Red(VGA_R), .Green(VGA_G), .Blue(VGA_B) );
										  
    

	 /**************************************************************************************
	    ATTENTION! Please answer the following quesiton in your lab report! Points will be allocated for the answers!
		 Hidden Question #1/2:
          What are the advantages and/or disadvantages of using a USB interface over PS/2 interface to
			 connect to the keyboard? List any two.  Give an answer in your Post-Lab.
     **************************************************************************************/
endmodule
