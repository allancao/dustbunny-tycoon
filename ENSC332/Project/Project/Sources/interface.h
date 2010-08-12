#ifndef _INTERFACE_H
#define _INTERFACE_H

//Module for serial communication

void SCI_Init();

char SCI_InStatus();

char SCI_InChar();

void SCI_OutChar(char data);

void SCI_OutWord(unsigned int data);

#endif /* _INTERFACE_H */