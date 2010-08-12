#include "derivative.h"      /* derivative-specific definitions */

#include "paddle.h"
#include "graphics.h"

void paddle_init(paddle* ppaddle, PaddleType ptype, unsigned char width, unsigned char height)
{
	ppaddle->x = 240/2 - width/2;
	ppaddle->height = height;
	ppaddle->width = width;
	
	switch(ptype)
	{
		case PADDLE_RIGHT:
		{
			ppaddle->y = 0;
			break;
		}
		case PADDLE_LEFT:
		{
			ppaddle->y = 319 - height;
			break;
		}
		default:
		{
			// Die
			for(;;){} 
			break;
		}
	}
	
	
}

void paddle_draw(paddle* ppaddle, unsigned char buffer_x, unsigned char buffer_y, int color)
{
	OLED_DrawRectangle(	ppaddle->x + buffer_x, // x min
						ppaddle->y + buffer_y, // y min
						ppaddle->x + ppaddle->width - buffer_x, // x max
						ppaddle->y + ppaddle->height - buffer_y, // y max
						color);
}

void paddle_move(paddle* ppaddle, int amt)
{
	if(ppaddle->x + amt < 0)
	{
		// Would be off screen on the top - dont update
		return;
	}
	else if(ppaddle->x + ppaddle->width + amt > 239)
	{
		// Would be off screen on the bottom - dont update
		return;
	}
	
	if(amt != 0)
	{
		//Only send update commands when needed
		
		OLED_CopyPaste(	ppaddle->x, ppaddle->y,
						ppaddle->x + amt, ppaddle->y, 
						ppaddle->width + 1 , 
						ppaddle->height + 1);
		
		ppaddle->x += amt;
	}
}