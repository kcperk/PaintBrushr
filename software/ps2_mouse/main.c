#define RLEDs ((volatile long *) 0x00000050)
#define GLEDs ((volatile long *) 0x00000040)
#define cursorX ((volatile unsigned short *) 0x00000030)
#define cursorY ((volatile unsigned short *) 0x00000020)

#define minX 65
#define minY 65
#define maxX 575
#define maxY 415

int main() {
	unsigned char byte1 = 0;
	unsigned char byte2 = 0;
	unsigned char byte3 = 0;

  	volatile int * PS2_ptr = (int *) 0x000000e0;  // PS/2 port address

	unsigned int PS2_data, RAVAIL, PS2_prev;
	unsigned short curX = 65;
	unsigned short curY = 65;

	char counter = 0;

	//printf("Entering Stream Mode\n");
	/*
	*(PS2_ptr) = 0xF6;
	while (*(PS2_ptr) & 0xFF != 0xFA)
		printf("Ps2 Info: %2x", (*(PS2_ptr) & 0xFF));
	*(PS2_ptr) = 0xF4;
	while (*(PS2_ptr) & 0xFF != 0xFA)
		printf("Ps2 Info: %2x", (*(PS2_ptr) & 0xFF));
	*/

	while (1) {
		PS2_data = *(PS2_ptr);	// read the Data register in the PS/2 port
		//printf("PS2 Data: %x\n", PS2_data);
		RAVAIL = (PS2_data & 0xFFFF0000) >> 16;	// extract the RAVAIL field
		if (RAVAIL > 0)
		{
			/* always save the last three bytes received */
			if (counter == 0)
				byte1 = PS2_data & 0xFF;
			if (counter == 1)
				byte2 = PS2_data & 0xFF;
			if (counter == 2)
				byte3 = PS2_data & 0xFF;
			//printf("Byte 3: %2x, Byte 2: %2x, Byte 1: %2x\n", byte3, byte2, byte1);
		}
		if ( (byte2 == (char) 0xAA) && (byte3 == (char) 0x00) )
		{
			// mouse inserted; initialize sending of data
			*(PS2_ptr) = 0xF4;
		}
		// Display last 3 bytes on LEDs
		// byte 3 on Green LEDs, byte 2 on red 0--7, and byte 1 on red 8--15


		if (counter == 2 && PS2_data != PS2_prev)
		{
			*GLEDs = byte3;
			int t = byte1;
			*RLEDs = ((t << 8) | byte2) & 0xffff;
		if (byte1 & 0x10)
			curX -= byte2 >> 5;
		else
			curX += byte2 >> 5;
		if (curX >= maxX)
			curX = maxX;
		if (curX <= minX)
			curX  = minX;

		if (byte1 & 0x20)
			curY += byte3 >> 5;
		else
			curY -= byte3 >> 5;
		if (curY >= maxY)
			curY = maxY;
		if (curY <= minY)
			curY  = minY;
		//printf("Cursor X: %d, Cursor Y: %d\n", curX, curY);
		*cursorX = curX;
		*cursorY = curY;

		}

		counter++;
		if (counter >= 3)
			counter = 0;

		PS2_prev = PS2_data;
	}
}
