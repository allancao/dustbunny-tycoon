; export symbols
	XDEF chkbtn
    
; Include derivative-specific definitions 
	INCLUDE 'derivative.inc'  		

; code section
ChkBtnCode:     SECTION


; Return: char
; Arg 1: char amt
; Arg 2: char btncol
chkbtn:
	
	; Create the mask for detecting button presses
	; The amount to shift is passed to this function (chkbtn) 
	; in register B.
	LDAA #%0001000
chkbtn_sl: 
	TSTB
	BEQ chkbtn_sld
	LSLA
	DECB
	BRA chkbtn_sl
chkbtn_sld: 
	PSHA ; Store the mask on the stack

	;Check first button
	MOVB #%00000010,PORTA
	LDAA PORTA
	ANDA 0,sp ;Apply the mask
	BEQ chkbtn_skp1 ; Skip ahead since the button has not been pressed
	LDAB 4,sp ; Load the return value (second function argument) into B - the result
	LEAS 1,sp ; Clear the space allocated for the mask
	MOVB #0,PORTA ; Power down the buttons
	RTC
chkbtn_skp1: 

	;Check second button
	MOVB #%00000001,PORTA
	LDAA PORTA
	ANDA 0,sp ;Apply the mask, its almost like halloween
	BEQ chkbtn_skp2
	LDAB 4,sp ; Load the return value
	NEGB ; Opposite direction (down)
	LEAS 1,sp ; Clear the allocation for the mask
	MOVB #0,PORTA
	RTC
chkbtn_skp2:

	; Niether button was pressed, return 0 (load it into B)
	LDAB #0
	LEAS 1,sp
	MOVB #0,PORTA
	RTC