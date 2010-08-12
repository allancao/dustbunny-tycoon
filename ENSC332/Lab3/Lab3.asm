	; Example Assembly Language Program
	ABSENTRY EntryA1 ; for absolute assembly mark this as application entry point
	; Include derivative-specific definitions
	INCLUDE 'mc9s12dg256.inc'
ROMStart EQU $4000 ; absolute address to place my code/constant data
	; $4000 is where code ROM starts for 9s12dx256 up to $7fff
	; variable/data section
	ORG RAMStart ; RAMStart is defined in mc9s12dj256.inc as $1000
	; Insert here your data definition.
Counter DS.W 1 ; set aside 1 word for counter in RAM
FiboRes DS.W 1
; code section
	ORG ROMStart

;**************************************************************
;* Delay
;**************************************************************

EntryDelay:
	CLRA
	LDX #$0002
	
LoopOuter:
	LDY #$0003
LoopInner:
		
	;Some action
	;ADDA #$01 
	NOP
	
	DEY
	BNE LoopInner
	DEX
	BNE LoopOuter

	;End
	;RTS
	JMP HERE
	
;**************************************************************
;* IR CHECKER
;**************************************************************

IRCheck:
	LDX #$00
	BRSET	PTS, %00000100,IRno
	LDX #$01
IRno:	
	JMP HERE	

;**************************************************************
;* Activities
;**************************************************************

;CountUpSR:
;	INCA
;	CBA
;	BNE DoneReset
;	LDAA #$00
;DoneReset:
;	STAA PORTB
;	RTS

EntryA1:
	
	BSET	DDRJ, %00000010	;set port j pin1 as output
	BSET 	PTJ, %00000010	;set port j pin1 to high to enable LEDs
	
	BSET	DDRS, %00001000	;set port s pin3 to output
	BSET	PTS, %00000000	;set port s pin3 to low, to enable IR transmitter
	
	BSET	DDRT, %00010000	;set port t bit 5 to output to allow control of speaker
	BSET	PTT, %00000000
	
	BSET	DDRB, %01111111	;set port b as output port to allow control of LEDs
	BSET	PORTB, %00000000	;set all LEDs off	
	
	LDAA #$0
	LDAB #$0
	LDX #$01
	LDY #$FF
	;END OF INITIALIZATION


Repeat:	
	STAA PTJ	;set Speaker
	STAB PORTB	;set LEDs
			
	PSHA
	PSHB
	PSHX
	PSHY
	JSR EntryDelay	;Delay determines frequency of speaker
	PULY
	PULX
	PULB
	PULA
	;JSR IRCheck
		
	INX
	DBEQ X, Bttnpress

	BRSET	PORTA, %00000001,Bttnpress
	BRSET	PORTA, %00000010,Bttnpress	
	BRSET	PORTA, %00000100,Bttnpress
	BRSET	PORTA, %00001000,Bttnpress
	
	DBEQ Y, Ledchange
	BRA Repeat
	
Bttnpress:
	COMA
	DBEQ Y, Ledchange
	
Ledchange:
	COMB
	LDY #FF	;LED Changes once for every F*F Changes of the speaker signal
	BRA Repeat

	JMP HERE
	
;**************************************************************
;* End - Loop
;**************************************************************

HERE JMP HERE
	END ; if system has monitor program END can be removed
;**************************************************************
;* Where to go when reset key is pressed *
;**************************************************************
	ORG $FFFE
	DC.W Entry ; Reset Vector