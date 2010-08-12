	XDEF initLCD,lscored,rscored,updatedisplay	;declare subroutines

	INCLUDE 'derivative.inc'  		


LCD_DATA	EQU PORTK	;set values for LCD connection	
LCD_CTRL	EQU PORTK		
RS	EQU mPORTK_BIT0		
EN	EQU mPORTK_BIT1		


MY_EXTENDED_RAM: SECTION
;----------------------
R1:  DS.B   1	;R variables are used for controlling timing (using delays) of communication with LCD
R2:  DS.B   1	;and allocated here
R3:  DS.B   1
TEMP:  DS.B   1	;TEMP is used in the communication subroutines to store value of accumulator A temporarily, and allocated here
lscore:  DS.B   1	;allocate memory for left player score
rscore:  DS.B   1	;allocate memory for right player score
eeeCode:     SECTION


DisplayCode: SECTION

;code section
;----------------------------
initLCD:	;initializes scores
    movb 00,lscore	;set scores to zero
    movb 00,rscore
     
	RTC
;----------------------------	
lscored:	;handles left player scoring

	LDAA	lscore	;load left player score
	ADDA	#1	;increment left player score
	STAA	lscore	;store left player score in memory
	RTC	
;----------------------------	
rscored:	;handles right player scoring

	LDAA	rscore	;load left player score
	ADDA	#1	;increment left player score
	STAA	rscore	;store left player score in memory
	RTC	

;----------------------------
updatedisplay:	;handles updating display with current score

  	LDAA  #$FF	;the following lines send a few values to the port to prepare the LCD for the message 
	STAA  DDRK		
	LDAA  #$33
	JSR	COMWRT4    	
  	JSR   DELAY
  	LDAA  #$32
	JSR	COMWRT4		
 	JSR   DELAY
	LDAA	#$28	
	JSR	  COMWRT4    	
	JSR	  DELAY   		
	LDAA	#$0E     	
	JSR	  COMWRT4		
	JSR   DELAY
	LDAA	#$01     	
	JSR	  COMWRT4    	
	JSR   DELAY
	LDAA	#$06     	
	JSR	  COMWRT4    	
	JSR   DELAY
	LDAA	#$80     	
	JSR	  COMWRT4    	
	JSR   DELAY
	LDAA	#'L'	;this is where the message begins, with the word 'left'      	
	JSR	  DATWRT4    	
	JSR   DELAY
	LDAA  #'E'     	
	JSR	  DATWRT4 
	JSR   DELAY
	LDAA  #'F'     	
	JSR	  DATWRT4 
	JSR   DELAY
	LDAA  #'T'     	
	JSR	  DATWRT4 
	JSR   DELAY
	LDAA  #'-'   	
	JSR	  DATWRT4 
	JSR   DELAY

	LDAA lscore	;loads left player score into accumulator A
	DAA		;converts left player score into 2 digit binary coded decimal
	TAB		;copies BCD left player score to accumulator B
	LSRA		;shifts accumulator A right four times, to select the first digit of the decimal number
	LSRA		;shift		
	LSRA		;shift
	LSRA		;shift
	ANDB #$0F	;mask first decimal digit of the left player score, to select only the second bit
	ADDA #$30	;convert first decimal digit of left player score to ASCII
	ADDB #$30	;convert second decimal digit of left player score to ASCII
	JSR	  DATWRT4	;sends first decimal digit of left player score to the LCD 
	JSR   DELAY	
	TBA			;move second decimal digit of left player score to accumulator A
	JSR	  DATWRT4 	;sends second decimal digit of left player score to the LCD 
	JSR   DELAY

	LDAA	#' '     	;the following code is similar to the code above, and sends a label, then
	JSR	  DATWRT4    	;converts the right player score to BCD and sends it to the screen
	JSR   DELAY
	LDAA	#'R'     	
	JSR	  DATWRT4    	
	JSR   DELAY
	LDAA  #'I'     	
	JSR	  DATWRT4 
	JSR	DELAY
	LDAA	#'G'     	
	JSR	DATWRT4 
	JSR	DELAY
	LDAA	#'H'     	
	JSR	DATWRT4 
	JSR	DELAY
	LDAA	#'T'   	
	JSR	DATWRT4 
	JSR	DELAY	
	LDAA  #'-'   	
	JSR	  DATWRT4 
	JSR   DELAY

	LDAA	rscore	
	DAA
	TAB
	LSRA
	LSRA
	LSRA
	LSRA
	ANDB #$0F
	ADDA #$30
	ADDB #$30	
	JSR	  DATWRT4 
	JSR   DELAY	
	TBA
	JSR	  DATWRT4 
	JSR   DELAY
	RTC


;----------------------------
COMWRT4:               		;handles sending communication data to LCD ofur bits at a time
		  STAA	TEMP	;pushes value in accumulator A to memory	
		  ANDA  #$F0	;masks right four digits in accumulator A 
		  LSRA		;shift right twice, to adjust value
		  LSRA
		  STAA  LCD_DATA	;sends accumulator A value to the LCD's port
		  BCLR  LCD_CTRL,RS 	;clears LCD RS pin value in case it was set
		  BSET  LCD_CTRL,EN 	;enables LCD control pin
		  NOP			;short delay
		  NOP
		  NOP				
		  BCLR  LCD_CTRL,EN 	;clears LCD control pin
		  LDAA  TEMP		;reloads value from beginning of subroutine to accumulator A
		  ANDA  #$0F		;performs same operations as code above, to send four least significant bits in accumulator A to the LCD
    	LSLA
    	LSLA
  		STAA  LCD_DATA		
		  BCLR  LCD_CTRL,RS 	
		  BSET  LCD_CTRL,EN 	
		  NOP
		  NOP
		  NOP				
		  BCLR  LCD_CTRL,EN 	
		  RTS
;--------------		  
DATWRT4:			;handles sending ASCII characters to LCD, similar to COMWRT, but in separate subroutine for easier differentiation elsewhere in code
		  STAA	 TEMP		
		  ANDA   #$F0
		  LSRA
		  LSRA
		  STAA   LCD_DATA
		  BSET   LCD_CTRL,RS 	
		  BSET   LCD_CTRL,EN 	
		  NOP
		  NOP
		  NOP				
		  BCLR   LCD_CTRL,EN 	
		  LDAA   TEMP
		  ANDA   #$0F
    	LSLA
      LSLA
  		STAA   LCD_DATA
  		BSET   LCD_CTRL,RS
		  BSET   LCD_CTRL,EN 	
		  NOP
		  NOP
		  NOP				
		  BCLR   LCD_CTRL,EN 	
		  RTS
;-------------------		  
DELAY		;delay subroutine

        PSHA		;Save Reg A on Stack
        LDAA    #1		  
        STAA    R3		
;-- 1 msec delay. The Serial Monitor works at speed of 48MHz with XTAL=8MHz on Dragon12+ board
;Freq. for Instruction Clock Cycle is 24MHz (1/2 of 48Mhz). 
;(1/24MHz) x 10 Clk x240x100=1 msec. Overheads are excluded in this calculation.         
L3      LDAA    #100
        STAA    R2
L2      LDAA    #240
        STAA    R1
L1      NOP         ;1 Intruction Clk Cycle
        NOP         ;1
        NOP         ;1
        DEC     R1  ;4
        BNE     L1  ;3
        DEC     R2  ;Total Instr.Clk=10
        BNE     L2
        DEC     R3
        BNE     L3
;--------------        
        PULA			;Restore Reg A
        RTS
;-------------------