#ifndef _GRAPHICS_H
#define _GRAPHICS_H


#define	OLED_DETECT_BAUDRATE	0x55

#define	OLED_CLEAR				0x45
#define	OLED_COPYPASTE			0x63

#define	OLED_LINE				0x4C
#define	OLED_CIRCLE				0x43
#define	OLED_PUTPIXEL			0x50
#define	OLED_RECTANGLE			0x72
#define	OLED_TRIANGLE			0x47

#define OLED_ACK  0x06  // Ok
#define OLED_NAK  0x15  // Error


#define OLED_DIE_INIT	1
#define OLED_DIE_CLEAR	2
#define OLED_DIE_DRAW	3

void OLED_Die(char code);

void OLED_ResetDisplay(void);

int OLED_GetError(void);

void OLED_Init(void);

int GetRGB(int red, int green, int blue);

void OLED_Clear(void);

void OLED_PutPixel(unsigned int x, unsigned int y, int color);

void OLED_DrawCircle(unsigned int x, unsigned int y, unsigned int radius, char filled, int color);

void OLED_DrawRectangle(unsigned int x1, unsigned int y1, unsigned int x2, unsigned int y2, int color);

void OLED_DrawLine(unsigned int x1, unsigned int y1, unsigned int x2, unsigned int y2, int color);

void OLED_DrawTriangle(unsigned int x1, unsigned int y1, unsigned int x2, unsigned int y2, unsigned int x3, unsigned int y3, int color);

void OLED_CopyPaste(unsigned int xs, unsigned int ys, unsigned int xd, unsigned int yd, unsigned int width, unsigned int height);

#endif /* _GRAPHICS_H */