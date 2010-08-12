#ifndef _PADDLE_H
#define _PADDLE_H

typedef struct
{
	int x;
	int y;
	unsigned char width;
	unsigned char height;
} paddle;

typedef enum PaddleTypeType
{
	PADDLE_RIGHT,
	PADDLE_LEFT
} PaddleType;

void paddle_init(paddle* ppaddle, PaddleType ptype, unsigned char width, unsigned char height);

void paddle_draw(paddle* ppaddle, unsigned char buffer_x, unsigned char buffer_y, int color);

void paddle_move(paddle* ppaddle, int amt);


#endif /* _PADDLE_H */