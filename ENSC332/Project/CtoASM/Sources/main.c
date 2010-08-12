#include <hidef.h>      /* common defines and macros */
#include "derivative.h"      /* derivative-specific definitions */

#include "main_asm.h" /* interface to the assembly module */

int asdf;

int testfcn(char a)//, int b, char c)
{
	asdf = 1 << (a + 4);
	//asdf = asdf + a;
	//asdf = asdf + b;
	//asdf = asdf + c;
	return asdf;
}

void dostuff_init(void);
int dostuff(char arg, char arg2);

void main(void)
{
	int temp;
	
	EnableInterrupts;
	
	DDRB = 0xFF;
	
	dostuff_init();
	
	for(;;)
	{
		//temp = testfcn(1, 3, 32);
		temp = testfcn(1);
		//temp = dostuff(3, 4);
		if(temp > 3)
		{
			PORTB = temp;
		}
	}
	
	for(;;) 
	{
    	_FEED_COP(); /* feeds the dog */
    } /* loop forever */
}
