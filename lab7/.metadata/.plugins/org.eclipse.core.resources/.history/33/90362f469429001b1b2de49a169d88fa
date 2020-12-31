// Main.c - makes LEDG0 on DE2-115 board blink if NIOS II is set up correctly
// for ECE 385 - University of Illinois - Electrical and Computer Engineering
// Author: Zuofu Cheng

int main()
{
	int i = 0;
	volatile unsigned int *LED_PIO = (unsigned int*)0x60; //make a pointer to access the PIO block
	volatile unsigned int *KEY2 = (unsigned int*)0x40;
	volatile unsigned int *KEY3 = (unsigned int*)0x30;
	volatile unsigned int *SW = (unsigned int*)0x50;
	int flag = 0;

	*LED_PIO = 0; //clear all LEDs
	while ( (1+1) != 3) //infinite loop
	{
//		if (*KEY3 == 0 && flag == 0)
//		{
//			*LED_PIO += *SW;
//			flag = 1;
//		}
//		if (*KEY3 == 1)
//		{
//			flag = 0;
//		}
//		if (*KEY2 == 0)
//		{
//			*LED_PIO = 0;
//		}
		for (i = 0; i < 100000; i++); //software delay
		*LED_PIO |= 0x1; //set LSB
		for (i = 0; i < 100000; i++); //software delay
		*LED_PIO &= ~0x1; //clear LSB
	}
	return 1; //never gets here
}

