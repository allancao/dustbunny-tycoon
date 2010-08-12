#include <hidef.h>      /* common defines and macros */
#include "derivative.h"      /* derivative-specific definitions */

#include "interface.h"

#define RDRF 0x20 // Receive Data Register Full Bit
#define TDRE 0x80 // Transmit Data Register Empty Bit

void SCI_Init()
{
	
	SCI1BDH = 0;
	
	// 24000000/(16 x 9600)
	SCI1BDL = 156;

	// Simple configuration
	SCI1CR1 = 0;

	// Enable TX and RX functionality
	SCI1CR2 = 0x0C;
}

char SCI_InChar()
{
	while((SCI1SR1 & RDRF) == 0){};
	return(SCI1DRL);
}

void SCI_OutChar(char data)
{
	while((SCI1SR1 & TDRE) == 0){};
	SCI1DRL = data;
}

// Checks if new input is ready, TRUE if new input is ready
char SCI_InStatus()
{
	return(SCI1SR1 & RDRF);
}

void SCI_OutWord(unsigned int data)
{
	SCI_OutChar(data >> 8);
	SCI_OutChar(data & 0xFF);
}