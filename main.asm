		title   "LCD"
        list    p=16f84A
        radix   hex
        include "p16f84A.inc"
;;;;;INTIAL VARIABLES;;;; 
;;;;COUNT1->3:USED FOR DELAYS;;;;
COUNT1  EQU    	d'12'
COUNT2	EQU		d'13'
COUNT3	EQU		d'14'
;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;P1->P12 :designate the positions of the letters;;;;;
P1		EQU		d'15'
P2		EQU		d'16'
P3		EQU		d'17'
P4		EQU		d'18'
P5		EQU		d'19'
P6		EQU		d'20'
P7		EQU		d'21'
P8		EQU		d'22'
P9		EQU		d'23'
P10		EQU		d'24'
P11		EQU		d'25'
P12		EQU		d'26'
;;;;;;;;;;;;;;;;;;;;;;;
FLAG	EQU		d'27'	
STAR	EQU		d'28'	;2LSB:SELECT MODES,2MSB:DETERMING PHASE
					
      	ORG    	0x0
		GOTO	START
		ORG		0x04
;		BTFSC	INTCON,INTF		;interrupts
;		GOTO	INTRB0
		BTFSC	INTCON,RBIF
		GOTO	INTRB5
;		BTFSC	INTCON,T0IF
;		GOTO	TIMERZ

;;;;INTIALIZING IO PORTS;;;;
START	BSF		STATUS,RP0
		CLRF	TRISA		;LCD DB(4,7) = RA(0-3)	//	RS = RA4
		CLRF	TRISB		;LCD ENABLE = RB1	// RED LED = RB2
							;GREEN LED = RB3	//	BUZZER=RB0
		BSF		TRISB,4		;LEFT
		BSF		TRISB,5		;RIGHT
		BSF		TRISB,6		;UP/DOWM
		BSF		TRISB,7		;CONFIRM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		MOVLW	B'10000111'
		MOVWF	OPTION_REG
		BCF		STATUS,RP0
		CLRF	PORTA
		CLRF	PORTB
		CLRF	INTCON
		BSF		INTCON,RBIE
;		BSF		INTCON,T0IE
		BSF		INTCON,GIE
		CALL	INITPOS
		CALL 	INITROU
		CALL	WLCM
		CALL	MENU
TASK	GOTO 	TASK
	
	;INIT ROUTINE
INITROU CALL	DELAY
		MOVLW	b'00010'
		CALL 	ET
		MOVLW	b'00010'
		CALL 	ET
		MOVLW	b'01000'
		CALL 	ET
	;DISPLAY ON/OFF CONTROL
		MOVLW	b'00000'
		CALL 	ET
		MOVLW	b'01110'		;changed lsb to 0 to disable blinking
		CALL 	ET
	;CLEAR DISPLAY
		MOVLW	b'00000'
		CALL 	ET
		MOVLW	b'00001'
		CALL 	ET
	;ENTRY MODE SET
		MOVLW	b'00000'
		CALL 	ET
		MOVLW	b'00110'
		CALL 	ET
		NOP
		RETURN

ET		MOVWF	PORTA
		BSF 	PORTB,1
		NOP
		BCF		PORTB,1
		CALL 	DELAY1
		CALL	DELAY1			;change to <40ms to write faster
		RETURN

;interrupt routines
INTRB0	CALL 	DELAY1
		BTFSS	PORTB,0
		CLRF	PORTA
		BCF		INTCON,INTF
		RETFIE

INTRB5	CALL	DELAY1		;DEBOUNCE
		BTFSC	STAR,7
		GOTO	INT23
		BTFSC	STAR,6
		GOTO	INT1
		
MMENU	BTFSS	PORTB,7
		GOTO	OK0
		BTFSS	PORTB,5		
		GOTO	ACT1
		GOTO	END5

ACT1	BTFSS	STAR,1
		GOTO	ACT2
		CLRF	STAR

		MOVLW	B'01000'	;GO BACK TO ADD:11
		CALL	ET
		MOVLW	B'01011'
		CALL 	ET
		CALL	PRINTSP

		MOVLW	B'01000'	;GO TO ADD:5
		CALL	ET
		MOVLW	B'00101'
		CALL 	ET
		CALL	PRINTST

		GOTO	END5
		
ACT2	INCF	STAR
		BTFSS	STAR,0
		GOTO	ACT3
		MOVLW	B'01000'	;GO BACK TO ADD:5
		CALL	ET
		MOVLW	B'00101'
		CALL 	ET
		CALL	PRINTSP		
		MOVLW	B'01000'	;GO TO ADD:8
		CALL	ET
		MOVLW	B'01000'
		CALL 	ET
		CALL	PRINTST
		GOTO	END5

ACT3	INCF	STAR
		MOVLW	B'01000'	;GO BACK TO ADD:8
		CALL	ET
		MOVLW	B'01000'
		CALL 	ET
		CALL	PRINTSP		
		MOVLW	B'01000'	;GO TO ADD:11
		CALL	ET
		MOVLW	B'01011'
		CALL 	ET
		CALL	PRINTST
		GOTO	END5

OK0		BTFSC	STAR,1
		GOTO	SET3
		BTFSC	STAR,0
		GOTO	SET2
		GOTO	SET1
		GOTO	END5

SET3	BSF		STAR,7
		BSF		STAR,6
		GOTO	END5

SET2	BSF		STAR,7
		BCF		STAR,6
		GOTO	END5

SET1	BCF		STAR,7
		BSF		STAR,6
		CALL	MODE1
		GOTO	END5		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
INT1	



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
INT23	BTFSC	STAR,6
		GOTO	INT3
		
INT2

INT3

END5	BCF		INTCON,RBIF
		RETFIE
		

TIMERZ	MOVLW	d'16'
		MOVWF	COUNT1
		DECFSZ	COUNT1,F
		GOTO	FINISH
		INCF	PORTA
		CLRF	TMR0
		MOVLW	d'16'
		MOVWF	COUNT1
FINISH	BCF		INTCON,T0IF
		RETFIE

;DELAYS
DELAY   MOVLW   H'0'		;40ms delay
        MOVWF   COUNT1
		MOVLW	d'52'
        MOVWF	COUNT2
LOOP3   INCFSZ	COUNT1,F
      	GOTO    LOOP3
		DECFSZ	COUNT2,F
		GOTO	LOOP3 
		RETURN

DELAY3S MOVLW	D'37'
		MOVWF	COUNT3
D3L		DECFSZ	COUNT3,F
		GOTO	D3LA
		RETURN	
D3LA	CALL	DELAY
		GOTO	D3L
		 
DELAY1  MOVLW   H'06'		;1ms delay
        MOVWF   COUNT1
            
LOOP    NOP
		INCFSZ	COUNT1,F
        GOTO    LOOP
        RETURN

INITPOS	MOVLW	D'12'
		MOVWF	P1
		MOVLW	D'10'
		MOVWF	P2
		MOVLW	D'14'
		MOVWF	P3
		MOVLW	D'15'
		MOVWF	P4
		MOVLW	D'11'
		MOVWF	P5
		MOVLW	D'13'
		MOVWF	P6
		MOVLW	D'11'
		MOVWF	P7
		MOVLW	D'13'
		MOVWF	P8
		MOVLW	D'15'
		MOVWF	P9
		MOVLW	D'12'
		MOVWF	P10
		MOVLW	D'10'
		MOVWF	P11
		MOVLW	D'14'
		MOVWF	P12
		MOVLW	D'0'
		MOVWF	STAR
		RETURN

WLCM	CALL	PRINTSP
		CALL	PRINTSP
		CALL	PRINTSP
		CALL	PRINTSP
		CALL	PRINTM
		CALL	PRINTE
		CALL	PRINTM
		CALL	PRINTSP
		CALL	PRINTG
		CALL	PRINTA
		CALL	PRINTM
		CALL	PRINTE
		CALL	DELAY3S
		CALL	CLEAR
		RETURN

MENU	CALL	PRINTM
		CALL	PRINTO
		CALL	PRINTD
		CALL	PRINTE
		CALL	PRINTSP
		CALL	PRINTSP
		CALL	PRINT1
		CALL	PRINTSP
		CALL	PRINTSP
		CALL	PRINT2
		CALL	PRINTSP
		CALL	PRINTSP
		CALL	PRINT3
		MOVLW	B'01000'
		CALL	ET
		MOVLW	B'00101'
		CALL 	ET
		CALL	PRINTST
		RETURN

	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MODE1	CALL	CLEAR
		CALL	UTIL			;PRINT BOXES
		CALL	PRINTSP
		CALL	PRINTSP
		CALL	PRINTS
		CALL	UTIL2
		CALL	PRINTW
		MOVLW	B'01100'		;JUMP LINE
		CALL	ET
		MOVLW	B'00000'
		CALL	ET
		CALL	UTIL			;PRINT BOXES
		RETURN

;LETTERS FUNCTIONS
PRINTM	MOVLW	B'10100'
		CALL	ET
		MOVLW	B'11101'
		CALL	ET
		RETURN

PRINTE	MOVLW	B'10100'
		CALL	ET
		MOVLW	B'10101'
		CALL	ET
		RETURN

PRINTO	MOVLW	B'10100'
		CALL	ET
		MOVLW	B'11111'
		CALL	ET
		RETURN

PRINTD	MOVLW	B'10100'
		CALL	ET
		MOVLW	B'10100'
		CALL	ET
		RETURN

PRINT1	MOVLW	B'10011'
		CALL	ET
		MOVLW	B'10001'
		CALL	ET
		RETURN

PRINT2	MOVLW	B'10011'
		CALL	ET
		MOVLW	B'10010'
		CALL	ET
		RETURN

PRINT3	MOVLW	B'10011'
		CALL	ET
		MOVLW	B'10011'
		CALL	ET
		RETURN

PRINTA	MOVLW	B'10100'
		CALL	ET
		MOVLW	B'10001'
		CALL	ET
		RETURN

PRINTB	MOVLW	B'10100'
		CALL	ET
		MOVLW	B'10010'
		CALL	ET
		RETURN

PRINTC	MOVLW	B'10100'
		CALL	ET
		MOVLW	B'10011'
		CALL	ET
		RETURN

PRINTF	MOVLW	B'10100'
		CALL	ET
		MOVLW	B'10110'
		CALL	ET
		RETURN

PRINTG	MOVLW	B'10100'
		CALL	ET
		MOVLW	B'10111'
		CALL	ET
		RETURN

PRINTS	MOVLW	B'10101'
		CALL	ET
		MOVLW	B'10011'
		CALL	ET
		RETURN

PRINTW	MOVLW	B'10101'
		CALL	ET
		MOVLW	B'10111'
		CALL	ET
		RETURN

PRINTST	MOVLW	B'10010'		;PRINT STAR
		CALL	ET
		MOVLW	B'11010'
		CALL	ET
		RETURN

PRINTSP	MOVLW	B'11010'		;PRINT SPACE
		CALL	ET
		MOVLW	B'10000'
		CALL	ET
		RETURN

PRINTSQ	MOVLW	b'11101'		;PRINT BOX SQUARE
		CALL 	ET
		MOVLW	b'11011'
		CALL 	ET	
		RETURN

PRINTPH	MOVLW	B'11010'		;PRINT THING BETWEEN S AND W
		CALL	ET
		MOVLW	B'10011'
		CALL	ET
		RETURN

UTIL	MOVLW	d'6'			;PRINT 6 BOXES
		MOVWF	COUNT3
L		CALL 	PRINTSQ
		DECFSZ	COUNT3,F
		GOTO	L
		RETURN

UTIL2	MOVLW	d'6'			;PRINT 6 PLACE HOLDERS
		MOVWF	COUNT3
L1		CALL 	PRINTPH
		DECFSZ	COUNT3,F
		GOTO	L1
		RETURN


;CLEAR FUNCTION
CLEAR	MOVLW	B'00000'
		CALL	ET
		MOVLW	B'00001'
		CALL	ET
		RETURN		

END