	; Example Assembly Language Program
	ABSENTRY EntryA2 ; for absolute assembly mark this as application entry point
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
;* Activity 1
;**************************************************************

EntryA1:
	CLRA
	LDX #$000F
	
Loop:
	ADDA #$03
	DEX
	BNE Loop
	
	JMP HERE

;**************************************************************
;* Activity 2
;**************************************************************

EntryA2:
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
;* Activity 3
;**************************************************************


CountUpSR:
	INCA
	CBA
	BNE DoneReset
	LDAA #$00
DoneReset:
	STAA PORTB
	RTS



EntryA3:
	MOVB #$FF, DDRB
	MOVB #$FF, PORTB
	LDAA #$00
	LDAB #$0B
	LDX #$0016

Repeat:

	JSR CountUpSR
	
	PSHA
	PSHX
	JSR EntryA2 ;Delay
	PULX
	PULA
	
	DEX
	BNE Repeat
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