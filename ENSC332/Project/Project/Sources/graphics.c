#include <hidef.h>      /* common defines and macros */
#include "derivative.h"      /* derivative-specific definitions */

#include "graphics.h"
#include "interface.h"


void OLED_Die(char code)
{
	PORTB = code;

	//Something has gone wrong, do nothing more my young Padawan
	while(1) {}

	return;
}

void OLED_ResetDisplay(void)
{
	//Stagnating variators
	unsigned int x,y;
	
	//Drop it like its hot
	PORTB &= ~0x01;

	//Delay - make sure it has time to shutdown
	for(x=0;x<1000;x++)
		for(y=0;y<1000;y++);

	//Send the reset pin high again
	PORTB |= 0x01;
	
	//Give it some time to boot back up
	for(x=0;x<2000;x++)
		for(y=0;y<1000;y++);

	return;
}

// Return codes:
//	0 = ack
//	1 = nak
//	2 = unknown
int OLED_GetError(void)
{
	byte incomingByte = OLED_ACK;
	
	//Wait for valid data
	while (!SCI_InStatus()) {}
	
	//Retrieve that data
	incomingByte = SCI_InChar();

	//Check the response
	if(incomingByte == OLED_ACK)
	{
		//Everything is OK
		return 0;
	}
	else if(incomingByte == OLED_NAK)
	{
		//Curse the electron god.
		//I believe his name is bill.
		return 1;
	}
	else 
	{
		//Pull your hair out and jump up and down screaming with frustration.
		//Or start break dancing, your choice really.
		return 2;
	}
}

void OLED_Init(void)
{
	unsigned int x,y;
	
	//Assum reset is connected to B0
	DDRB |= 0x01;
	PORTB |= 0x01;

	OLED_ResetDisplay();  

	//Short delay - let the OLED restart
	for(x=0;x<1000;x++)
		for(y=0;y<1000;y++);

	
	SCI_OutChar(OLED_DETECT_BAUDRATE);
	if (OLED_GetError())
	{
		OLED_Die(OLED_DIE_INIT);
	}

	return;	
}

int GetRGB(int red, int green, int blue)
{
	int outR = ((red * 31) / 255);
	int outG = ((green * 63) / 255);
	int outB = ((blue * 31) / 255);

	return (outR << 11) | (outG << 5) | outB;
}

void OLED_Clear(void)
{
	SCI_OutChar(OLED_CLEAR);

	if (OLED_GetError())
	{
		OLED_Die(OLED_DIE_CLEAR);
	}

	return;	
}

void OLED_PutPixel(unsigned int x, unsigned int y, int color)
{
	SCI_OutChar(OLED_PUTPIXEL);
	
	SCI_OutWord(x);
	SCI_OutWord(y);
	
	SCI_OutWord(color);

	if (OLED_GetError())
	{
		OLED_Die(OLED_DIE_DRAW);
	}

	return;	
}

void OLED_DrawCircle(unsigned int x, unsigned int y, unsigned int radius, char filled, int color)
{
	SCI_OutChar(OLED_CIRCLE);
	SCI_OutWord(x);
	SCI_OutWord(y);

	SCI_OutWord(radius);
	SCI_OutWord(color);

	if (OLED_GetError())
	{
		OLED_Die(OLED_DIE_DRAW);
	}

	return;	
}

void OLED_CopyPaste(unsigned int xs, unsigned int ys, unsigned int xd, unsigned int yd, unsigned int width, unsigned int height)
{
	SCI_OutChar(OLED_COPYPASTE);
	SCI_OutWord(xs);
	SCI_OutWord(ys);
	
	SCI_OutWord(xd);
	SCI_OutWord(yd);

	SCI_OutWord(width);
	SCI_OutWord(height);

	if (OLED_GetError())
	{
		OLED_Die(OLED_DIE_DRAW);
	}

	return;	
}

void OLED_DrawRectangle(unsigned int x1, unsigned int y1, unsigned int x2, unsigned int y2, int color)
{
	SCI_OutChar(OLED_RECTANGLE);
	SCI_OutWord(x1);
	SCI_OutWord(y1);
	
	SCI_OutWord(x2);
	SCI_OutWord(y2);

	SCI_OutWord(color);

	if (OLED_GetError())
	{
		OLED_Die(OLED_DIE_DRAW);
	}

	return;	
}

void OLED_DrawLine(unsigned int x1, unsigned int y1, unsigned int x2, unsigned int y2, int color)
{
	SCI_OutChar(OLED_LINE);
	SCI_OutWord(x1);
	SCI_OutWord(y1);
	
	SCI_OutWord(x2);
	SCI_OutWord(y2);

	SCI_OutWord(color);

	if (OLED_GetError())
	{
		OLED_Die(OLED_DIE_DRAW);
	}

	return;	
}

void OLED_DrawTriangle(unsigned int x1, unsigned int y1, unsigned int x2, unsigned int y2, unsigned int x3, unsigned int y3, int color)
{
	SCI_OutChar(OLED_TRIANGLE);
	SCI_OutWord(x1);
	SCI_OutWord(y1);
	
	SCI_OutWord(x2);
	SCI_OutWord(y2);
	
	SCI_OutWord(x3);
	SCI_OutWord(y3);

	SCI_OutWord(color);

	if (OLED_GetError())
	{
		OLED_Die(OLED_DIE_DRAW);
	}

	return;	
}

