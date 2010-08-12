/*******************************************************

  uOLED-160-GMD1 Driver for Arduino
  Code: Oscar Gonzalez
  August 2007
  
  www.bricogeek.com

 *******************************************************/

#define OLED_BAUDRATE                                           9600//57600
#define OLED_RESETPIN                                           8      // PIN of reset
#define OLED_INITDELAYMS                                        5000
 
// Initialisation routine
#define	OLED_DETECT_BAUDRATE					0x55

// Drawing routines
#define	OLED_CLEAR						0x45
#define	OLED_BKGCOLOR						0x42
#define	OLED_COPYPASTE						0x63

#define	OLED_LINE						0x4C
#define	OLED_CIRCLE						0x43
#define	OLED_CIRCLEFILL						0x69
#define	OLED_PUTPIXEL						0x50
#define	OLED_READPIXEL						0x52
#define	OLED_RECTANGLE						0x72
#define	OLED_PAINTAREA						0x70

// Text properties
#define	OLED_SETFONTSIZE					0x46
  #define	OLED_FONT5X7					0x01
  #define	OLED_FONT8X8					0x02
  #define	OLED_FONT8X12					0x03
#define	OLED_TEXTFORMATED					0x54

// OLED Control
#define	OLED_COMMAND_CONTROL					0x59
#define	OLED_COMMAND_DISPLAY					0x01
#define	OLED_COMMAND_CONTRAST					0x02
#define	OLED_COMMAND_POWER					0x03

#define OLED_ACK  0x06  // Ok
#define OLED_NAK  0x15  // Error

void OLED_ResetDisplay()
{
  digitalWrite(OLED_RESETPIN, LOW);
  delay(20);                  
  digitalWrite(OLED_RESETPIN, HIGH);
  delay(20);  
                 
}

char OLED_GetResponse()
{
  byte incomingByte = OLED_ACK;
  
  // Wait for data avaliable
  while (!Serial.available()) { delay(1); }
  
  // Read incoming byte
  incomingByte = Serial.read();
  
  return incomingByte;
}

// Initialise OLED display. You must first activate a serial comunication!
void OLED_Init()
{
  // First reset display
  OLED_ResetDisplay();  

  delay(OLED_INITDELAYMS);                       // Wait for init
  // Autodetect baudrate
  printByte(OLED_DETECT_BAUDRATE); 
  OLED_GetResponse(); 
  
}

// Get 16bits value from RGB (0 to 63, 565 format)
int GetRGB(int red, int green, int blue)
{

	char text[255];

	int outR = ((red * 31) / 255);
	int outG = ((green * 63) / 255);
	int outB = ((blue * 31) / 255);

	return (outR << 11) | (outG << 5) | outB;
}

void OLED_Clear()
{

	printByte(OLED_CLEAR); // Pixel write
delay(20);
        OLED_GetResponse();

}

void OLED_PutPixel(char x, char y, int color)
{

	// Putpixel
	printByte(OLED_PUTPIXEL); // Pixel write
	printByte(x);	// x
	printByte(y);

	// Color
	printByte(color >> 8);		// MSB			
	printByte(color & 0xFF);		// LSB

        OLED_GetResponse();

}

void OLED_DrawLine(char x1, char y1, char x2, char y2, int color)
{

	// Line drawing
	printByte(OLED_LINE); // Line

	printByte(x1);	// x1
	printByte(y1);		// y1
	printByte(x2);	// x2
	printByte(y2);		// y2

	// Color
	printByte(color >> 8);		// MSB			
	printByte(color & 0xFF);		// LSB

        OLED_GetResponse();

}

void OLED_DrawRectangle(char x, char y, char width, char height, char filled, int color)
{

	//int color = 0xFFFF;

	// Rectangle drawing
	printByte(OLED_RECTANGLE); 

	printByte(x);			// x1
	printByte(y);		// y1

	printByte(x+width);		// x2
	printByte(y+height);		// y1

	// Color
	printByte(color >> 8);		// MSB			
	printByte(color & 0xFF);		// LSB
	/*
	if (filled == 1) { printByte(0x01); }	// Filled
	else { printByte(0x00); }				// Outline
	*/
	OLED_GetResponse();
}

void OLED_DrawCircle(char x, char y, char radius, char filled, int color)
{
        printByte(OLED_CIRCLE); 

	printByte(x);	// x
	printByte(y);	// y
	printByte(radius);	// radius

	// Color
	printByte(color >> 8);		// MSB			
	printByte(color & 0xFF);		// LSB

        OLED_GetResponse();

}

/*
 Change font format:
 FontType can be:
    OLED_FONT5X7
    OLED_FONT8X8
    OLED_FONT8X12
*/  
void OLED_SetFontSize(char FontType)
{
    printByte(OLED_SETFONTSIZE);
    printByte(FontType);
    
    OLED_GetResponse();
}

void OLED_DrawText(char column, char row, char font_size, char *mytext, int color)
{
	//char mytext[] = "Arkanoid by pK";

	printByte(0x73); // s (Formated text)
	
        //printByte(column); // column
        
        // Adjust to center of the screen (26 Columns at font size 0)
        int newCol = 13 - (strlen(mytext)/2);
        //printByte(newCol); // column
        printByte(column); // column
        
	printByte(row); // row
	printByte(font_size); // font size (0 = 5x7 font, 1 = 8x8 font, 2 = 8x12 font)

	// Color
	printByte(color >> 8);		// MSB			
	printByte(color & 0xFF);		// LSB

	for (int i=0 ; i<strlen(mytext) ; i++)
	{
		printByte(mytext[i]); // character to write
	}
	printByte(0x00); // string terminator (always 0x00)

        OLED_GetResponse();

}

void OLED_DrawSingleChar(char column, char row, char font_size, char MyChar, int color)
{

	printByte(OLED_TEXTFORMATED); // T (Formated)
	
        printByte(MyChar);
        printByte(column);
        printByte(row);
        
	// Color
	printByte(color >> 8);		// MSB			
	printByte(color & 0xFF);	// LSB

        OLED_GetResponse();

}
