		title   "LCD"
        list    p=16f84A
        radix   hex
        include "p16f84A.inc"
 		__config _XT_OSC & _WDT_OFF & _PWRTE_ON & _CP_OFF
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
NCARDO	EQU		d'27'	;NUMBER OF CARDS OPENED
STAR	EQU		d'28'	;2LSB:SELECT MODES,2MSB:DETERMINING PHASE
LCDAL	EQU		d'29'	;LCD ADDRESS LOWER BITS
LCDAU	EQU		d'30'	;LCD ADDRESS LOWER BITS
ACARDOL	EQU		d'31'	;LOWER ADDRESS OF CARD OPENED
CARDO	EQU		d'32'	;CARD OLD
ACARDOU	EQU		d'33'	;UPPER ADDRESS OF CARD OPENED
CARDN	EQU		d'34'	;CARD NEW
TEMP	EQU		d'35'	;TEMPORARY REGISTER
ERRC	EQU		d'36'	;ERROR COUNTER	
ERRAU	EQU		d'37'	;ERROR ADDRESS UPPER BITS (used to know where to print filled box)
ERRAL	EQU		d'38'	;ERROR ADDRESS LOWER BITS
TMRVAL	EQU		d'39'	;TIMER VALUE FOR MODE2
NMATCH	EQU		d'40'	;NUMBER OF MATCHES
RERR	EQU		d'41'	;MODE3 REVEALED ERRORS
S3		EQU		d'42'	;MODE3 SCORE	
COUNT4	EQU		d'43'	;timer0 counter

      	ORG    	0x0
		GOTO	START
		ORG		0x04
;		BTFSC	INTCON,INTF		;interrupts
;		GOTO	INTRB0
		BTFSC	INTCON,RBIF
		GOTO	INTRB5
		BTFSC	INTCON,T0IF
		GOTO	TIMERZ

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
		MOVLW	D'15'		; REGISTER P1
		MOVWF	FSR
		CALL	INITPOS
		CALL 	INITROU
		CALL	WLCM
		CALL	MENU
		;BSF		INTCON,T0IE
TASK	GOTO 	TASK
	
;;;;HANDLES LCD DISPLAY INTIALIZATION;;;;
INITROU CALL	DELAY
		MOVLW	b'00010'
		CALL 	ET
		MOVLW	b'00010'
		CALL 	ET
		MOVLW	b'01000'
		CALL 	ET
	;DISPLAY ON/OFF CONTROL
		CALL	COFF
	;CLEAR DISPLAY
		CALL	CLEAR
	;ENTRY MODE SET
		MOVLW	b'00000'
		CALL 	ET
		MOVLW	b'00110'
		CALL 	ET
		NOP
		RETURN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;COMMIT CHANGES TO LCD;;;;
ET		MOVWF	PORTA
		BSF 	PORTB,1
		NOP
		BCF		PORTB,1
		CALL 	DELAY1
		CALL	DELAY1			;2ms delay to make changes to LCD faster
		RETURN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;INTERUPT ROUTINES;;;;
;INTRB0	CALL 	DELAY1
;		BTFSS	PORTB,0
;		CLRF	PORTA
;		BCF		INTCON,INTF
;		RETFIE
;;;;;;;;;;;;;;;;;;;;;;;;;
INTRB5	CALL	DELAY1		;DEBOUNCE
		BTFSC	STAR,7		;goto to the right mode
		GOTO	INT1
		BTFSC	STAR,6
		GOTO	INT1
MMENU	BTFSS	PORTB,7
		GOTO	OK0
		BTFSS	PORTB,5		
		GOTO	ACT1
;		BTFSS	PORTB,4
;		GOTO	BUZZER
		GOTO	END5

ACT1	BTFSS	STAR,1
		GOTO	ACT2
		CLRF	STAR

		MOVLW	B'01000'	;GO BACK TO ADD:12
		CALL	ET
		MOVLW	B'01100'
		CALL 	ET
		CALL	PRINTSP

		MOVLW	B'01000'	;GO TO ADD:6
		CALL	ET
		MOVLW	B'00110'
		CALL 	ET
		CALL	PRINTST

		GOTO	END5
		
ACT2	INCF	STAR
		BTFSS	STAR,0
		GOTO	ACT3
		MOVLW	B'01000'	;GO BACK TO ADD:6
		CALL	ET
		MOVLW	B'00110'
		CALL 	ET
		CALL	PRINTSP		
		MOVLW	B'01000'	;GO TO ADD:9
		CALL	ET
		MOVLW	B'01001'
		CALL 	ET
		CALL	PRINTST
		GOTO	END5

ACT3	INCF	STAR
		MOVLW	B'01000'	;GO BACK TO ADD:9
		CALL	ET
		MOVLW	B'01001'
		CALL 	ET
		CALL	PRINTSP		
		MOVLW	B'01000'	;GO TO ADD:12
		CALL	ET
		MOVLW	B'01100'
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
		CALL	MODE3
		GOTO	END5

SET2	BSF		STAR,7
		BCF		STAR,6
		CALL	MODE2
		GOTO	END5

SET1	BCF		STAR,7
		BSF		STAR,6
		CALL	MODE1
		GOTO	END5		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
INT1	BTFSS	PORTB,7			;INTERRUPT ROUTINES FOR MODE 1
		GOTO	FLIP
		BTFSS	PORTB,6
		CALL	JL
		BTFSS	PORTB,5
		CALL	GOR
		BTFSS	PORTB,4
		CALL	GOL


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INT23	BTFSC	STAR,6
;		GOTO	INT3
;		
;INT2	
;
;INT3

END5	BCF		INTCON,RBIF
		RETFIE
		

TIMERZ	DECFSZ	COUNT4,F
		GOTO	FINISH
		CLRF	TMR0
		MOVLW	d'152'
		MOVWF	COUNT4
		DECFSZ	TMRVAL,F
		GOTO	T2
		GOTO	SCORE2
T2		MOVLW	B'01000'		;GOTO ADDRESS 13 TO CHANGE THE VALUE OF THE TIMER DISPLAYED
		CALL	ET
		MOVLW	D'13'
		CALL	ET
		CALL	PRINTFR			;PRINT NEW TMR VALUE
		CALL	SLCDA
FINISH	BCF		INTCON,T0IF
		RETFIE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;DELAYS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DELAY   MOVLW   H'0'		;40ms delay
        MOVWF   COUNT1
		MOVLW	d'52'
        MOVWF	COUNT2
LOOP3   INCFSZ	COUNT1,F
      	GOTO    LOOP3
		DECFSZ	COUNT2,F
		GOTO	LOOP3 
		RETURN

DELAY3S MOVLW	D'37'		;3s delay
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
INITPOS	BCF		INTCON,T0IE		;DISABLE TMR0
		MOVLW	B'10011'		;initial position 
		MOVWF	P1
		MOVLW	B'10001'
		MOVWF	P2
		MOVLW	B'10101'
		MOVWF	P3
		MOVLW	B'10110'
		MOVWF	P4
		MOVLW	B'10010'
		MOVWF	P5
		MOVLW	B'10100'
		MOVWF	P6
		MOVLW	B'10010'
		MOVWF	P7
		MOVLW	B'10100'
		MOVWF	P8
		MOVLW	B'10110'
		MOVWF	P9
		MOVLW	B'10011'
		MOVWF	P10
		MOVLW	B'10001'
		MOVWF	P11
		MOVLW	B'10101'
		MOVWF	P12
		MOVLW	D'0'
		MOVWF	STAR
		MOVWF	NCARDO
		MOVWF	ERRC
		MOVWF	NMATCH
		MOVWF	RERR
		MOVLW	B'10010000'
		MOVWF	CARDO
		MOVLW	B'00001100'
		MOVWF	CARDN
		MOVLW	B'01000'
		MOVWF	LCDAU
		MOVWF	ERRAU
		MOVLW	B'01001'
		MOVWF	ERRAL
		MOVLW	d'9'
		MOVWF	TMRVAL
		MOVLW	D'13'
		MOVWF	S3
		MOVLW	d'152'			;FOR MODE2
		MOVWF	COUNT4
		RETURN

WLCM	CALL	PRINTSP		;welcome screen
		CALL	PRINTSP
		CALL	PRINTSP
		CALL	PRINTM
		CALL	PRINTE
		CALL	PRINTM
		CALL	PRINTO
		CALL	PRINTR
		CALL	PRINTY
		CALL	PRINTSP
		CALL	PRINTG
		CALL	PRINTA
		CALL	PRINTM
		CALL	PRINTE
		CALL	DELAY3S
		CALL	CLEAR
		RETURN
			
MENU	CALL	COFF
		CALL	PRINTM		;mode select 
		CALL	PRINTO
		CALL	PRINTD
		CALL	PRINTE
		CALL	PRINTSP
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
		MOVLW	B'00110'		
		CALL 	ET
		CALL	PRINTST
		BSF		INTCON,RBIE		;enable interrupts
		BSF		INTCON,GIE
		RETURN

	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MODE1	CALL	CLEAR
		MOVLW	b'00000'
		CALL 	ET
		MOVLW	b'01110'		;enable cursor
		CALL 	ET
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
		CALL	LCDGH
		RETURN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MODE2	BSF		INTCON,T0IE		;enable timer0 interrupt
		CALL	CLEAR
		MOVLW	b'00000'
		CALL 	ET
		MOVLW	b'01110'		;enable cursor
		CALL 	ET
		CALL	UTIL			;PRINT BOXES
		CALL	PRINTSP
		CALL	PRINTSP
		CALL	PRINTR
		CALL	PRINTE
		CALL	PRINTM
		CALL	PRINTSP
		CALL	PRINTT
		CALL	PRINT9
		CALL	PRINT0
		MOVLW	B'01100'		;JUMP LINE
		CALL	ET
		MOVLW	B'00000'
		CALL	ET
		CALL	UTIL			;PRINT BOXES
		CALL	LCDGH
		RETURN

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MODE3	CALL	CLEAR
		MOVLW	b'00000'
		CALL 	ET
		MOVLW	b'01110'		;enable cursor
		CALL 	ET
		CALL	UTIL			;PRINT BOXES
		CALL	PRINTSP
		CALL	PRINTSP
		CALL	PRINTMI
		CALL	PRINT0
		CALL	PRINTSP
		CALL	PRINTSP
		CALL	PRINTPL
		CALL	PRINT0
		MOVLW	B'01100'		;JUMP LINE
		CALL	ET
		MOVLW	B'00000'
		CALL	ET
		CALL	UTIL			;PRINT BOXES
		CALL	PRINTSP
		CALL	PRINTSP
		CALL	PRINTSC
		CALL	PRINTSP
		CALL	PRINT1
		CALL	PRINT3
		CALL	LCDGH
		RETURN


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

PRINTR	MOVLW	B'10101'
		CALL	ET
		MOVLW	B'10010'
		CALL	ET
		RETURN

PRINTW	MOVLW	B'10101'
		CALL	ET
		MOVLW	B'10111'
		CALL	ET
		RETURN

PRINTK	MOVLW	B'10100'
		CALL	ET
		MOVLW	B'11011'
		CALL	ET
		RETURN

PRINTP	MOVLW	B'10101'
		CALL	ET
		MOVLW	B'10000'
		CALL	ET
		RETURN

PRINTY	MOVLW	B'10101'
		CALL	ET
		MOVLW	B'11001'
		CALL	ET
		RETURN

PRINTU	MOVLW	B'10101'
		CALL	ET
		MOVLW	B'10101'
		CALL	ET
		RETURN

PRINTD	MOVLW	B'10100'
		CALL	ET
		MOVLW	B'10100'
		CALL	ET
		RETURN

PRINTMI	MOVLW	B'10010'
		CALL	ET
		MOVLW	B'11101'
		CALL	ET
		RETURN

PRINTPL	MOVLW	B'10010'
		CALL	ET
		MOVLW	B'11011'
		CALL	ET
		RETURN

PRINT0	MOVLW	B'10011'
		CALL	ET
		MOVLW	B'10000'
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

PRINT4	MOVLW	B'10011'
		CALL	ET
		MOVLW	B'10100'
		CALL	ET
		RETURN

PRINT5	MOVLW	B'10011'
		CALL	ET
		MOVLW	B'10101'
		CALL	ET
		RETURN

PRINT6	MOVLW	B'10011'
		CALL	ET
		MOVLW	B'10110'
		CALL	ET
		RETURN

PRINT7	MOVLW	B'10011'
		CALL	ET
		MOVLW	B'10111'
		CALL	ET
		RETURN

PRINT8	MOVLW	B'10011'
		CALL	ET
		MOVLW	B'11000'
		CALL	ET
		RETURN

PRINT9	MOVLW	B'10011'
		CALL	ET
		MOVLW	B'11001'
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

PRINTV	MOVLW	B'10101'
		CALL	ET
		MOVLW	B'10110'
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

PRINTT	MOVLW	B'10101'
		CALL	ET
		MOVLW	B'10100'
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

PRINTFS	MOVLW	B'11111'		;PRINT FILLED SQUARE
		CALL	ET
		MOVLW	B'11111'
		CALL	ET
		RETURN

PRINTFR	MOVLW	B'10011'
		CALL	ET
;		BSF		TMRVAL,4
		MOVF	TMRVAL,W
		ADDLW	B'10000'
		CALL	ET
		RETURN

PRINTSC	CALL	PRINTS
		CALL	PRINTC
		CALL	PRINTO
		CALL	PRINTR
		CALL	PRINTE
		RETURN

FR		MOVLW	B'10011'
		CALL	ET
;		BSF		TMRVAL,4
		MOVF	TMRVAL,W
		ADDLW	B'10000'
		CALL	ET
		GOTO	ENDS2

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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SLCDA	MOVF	LCDAU,W			;SET LCD ADDRESS
		CALL	ET
		MOVF	LCDAL,W
		CALL	ET
		RETURN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LCDGH	MOVLW	B'00000'	;LCD GO HOME
		CALL	ET
		MOVLW	B'00010'
		CALL	ET
		CLRF	LCDAL
		BCF		LCDAU,2
		BCF		STAR,5
		MOVLW	D'15'
		MOVWF	FSR
		RETURN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
JL		BTFSC	STAR,5		;CHECK FLAG
		GOTO	SUB64
		BSF		LCDAU,2		;GO	TO LINE 2
		MOVLW	D'6'		;ADD 6
		ADDWF	FSR,1
		BSF		STAR,5
		GOTO	ENDJL
SUB64	MOVLW	D'6'		;SUBTRACT 6
		SUBWF	FSR,1
		BCF		LCDAU,2		;GO BACK TO LINE 1
		BCF		STAR,5
ENDJL	CALL	SLCDA		;SET LCD ADDRESS
		GOTO	END5		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
GOR		BTFSC	LCDAL,2		;GO RIGHT (RIGHT PB ACTION)
		GOTO	CHECK
		GOTO	INCR	

CHECK	BTFSC	LCDAL,0
		GOTO	BUZZER

INCR	INCF	FSR,F
		INCF	LCDAL,F
		CALL	SLCDA		;SET LCD ADDRESS
		GOTO	END5 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GOL		BTFSS	LCDAL,2		;GO LEFT (LEFT PB ACTION)
		GOTO	CHECKL1
		GOTO	DECR	

CHECKL1	BTFSS	LCDAL,1
		GOTO	CHECKL2
		GOTO	DECR

CHECKL2	BTFSS	LCDAL,0
		GOTO	BUZZER

DECR	DECF	FSR
		DECF	LCDAL
		CALL	SLCDA
		GOTO	END5
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FLIP	BTFSC	INDF,7		;CHECK IF CARD WAS OPENED BEFORE
		GOTO	BUZZER		
		MOVLW	B'10100'	;FLIP CARD (CONFIRM PB ACTION)
		CALL	ET	
		MOVF	INDF,W
		CALL	ET
		CALL	SLCDA		;RESET CURSOR TO CURRENT POSITION AFTER WRITING
		MOVF	CARDN,W		;MOVE FROM NEW TO OLD
		MOVWF	CARDO			
		MOVF	FSR,W		;GET NEW CARD OPENED		
		MOVWF	CARDN
		BSF		INDF,7		;FLAG THE CARD AS CURRENTLY OPENED
		INCF	NCARDO,F	;NUMBER OF CARDS OPENED+1			
		BTFSS	NCARDO,0	;CHECK IF 2 CARDS WERE OPENED
		CALL	HANDLE1
		MOVF 	LCDAL,W		;SAVE THE LOWER ADDRESS OF THE CARD THAT WAS OPENED
		MOVWF	ACARDOL		
		MOVF 	LCDAU,W		;SAVE THE UPPER ADDRESS OF THE CARD THAT WAS OPENED
		MOVWF	ACARDOU	
		CALL	LCDGH
		MOVF	NCARDO,W
		SUBLW	D'11'
		BTFSS	STATUS,C
		GOTO	CHECKSC	
		GOTO	END5
CHECKSC	BTFSS	STAR,7
		GOTO	SCORE1
		GOTO	SCORE2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
HANDLE1	MOVF	CARDN,W
		MOVWF	FSR
		MOVLW	B'00111111'	
		ANDWF	INDF,W		;GET ONLY CARD VALUE FROM INDF WITHOUT FLAGS BECAUSE THEY MIGHT BE DIFFERENT
		MOVWF	TEMP		;NEW CARD VALUE IS NOW IN TEMP
		MOVF	CARDO,W	
		MOVWF	FSR
		MOVLW	B'00111111'	
		ANDWF	INDF,W
		SUBWF	TEMP,W		;COMPARE THE 2 CARDS OPENED
		BTFSC	STATUS,2	;CHECK IF THE RESULT IS 0 (I.E MATCHING)
		GOTO	MATCH
		
		CALL	DELAY3S	
		MOVF	CARDN,W		;MOVE CURRENT CARD TO FSR
		MOVWF	FSR	
		CALL	PRINTSQ		;FLIP CURRENT CARD TO CLOSED
		BCF		INDF,7		;FLAG CURRENT CARD AS CLOSED

		MOVF	ACARDOL,W
		MOVWF	LCDAL
		MOVF	ACARDOU,W
		MOVWF	LCDAU
		CALL	SLCDA		;SET AS CURRENT ADDRESS
		CALL	PRINTSQ		;FLIP PREV CARD TO CLOSED
		MOVF	CARDO,W		;GET REG NUM OF PREV CARD
		MOVWF	FSR			;MOVE INTO THE FSR
		BCF		INDF,7		;FLAG PREV CARD AS CLOSED	
		MOVLW	D'2'		
		SUBWF	NCARDO,F	;SUBTRACT 2 FROM THE NUMBER OF CARDS OPENED (CLOSED THEM)
		INCF	ERRC,F		;INCREMENT THE ERROR COUNTER
		CALL	RLED		;BLINK RED LED
		MOVLW	D'12'
		SUBWF	ERRC,W			
		BTFSS	STATUS,C	;CHECK CARRY BIT
		GOTO	CHECKER	
		GOTO	RET

CHECKER	BTFSS	STAR,7
		GOTO	ERR1
		BTFSC	STAR,6
		GOTO	ERR3
		GOTO	RET
MATCH	INCF	NMATCH,F
		INCF	S3
		BTFSC	STAR,1
		CALL	MATCH3
		CALL	BUZZER1
RET		RETURN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MATCH3	MOVF	NMATCH,W
		MOVWF	TMRVAL
		MOVLW	B'01000'	;MOVE TO ADDRESS 13
		CALL	ET
		MOVLW	B'01101'
		CALL	ET
		CALL	PRINTFR

		CALL	UPDS3		;UPDATE SCORE
		RETURN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ERR1	BTFSS	ERRC,0		;CHECK IF THE ERROR COUNT IS ODD
		GOTO	RET

		MOVF	ERRAU,W
		CALL	ET
		MOVF	ERRAL,W
		CALL	ET
		CALL	PRINTFS
		INCF	ERRAL,F
		CALL	SLCDA
		RETURN	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ERR3	MOVF	CARDN,W
		MOVWF	FSR
		BTFSC	INDF,6		;CHECK IF NEW CARD WAS PREV REVEALED
		CALL	IERR
		BSF		INDF,6		;FLAG THE CARD AS REVEALED	
		MOVF	CARDO,W
		MOVWF	FSR
		BTFSC	INDF,6		;CHECK IF OLD CARD WAS PREV REVEALED
		CALL	IERR
		BSF		INDF,6		;FLAG THE CARD AS REVEALED

;		CALL	UPDS3		;UPDATE SCORE	

		MOVLW	B'01000'	;MOVE TO POS AFTER - TO UPDATE DISPLAY
		CALL	ET
		MOVLW	D'9'
		CALL	ET
		MOVLW	D'10'
		SUBWF	RERR,W		;TMRVAL
		MOVWF	TEMP
		BTFSC	STATUS,C
		GOTO	DD1			;DOUBLE DIGIT CASE
		MOVF	RERR,W
		MOVWF	TMRVAL
		BTFSS	STATUS,C
		CALL	PRINTFR
		CALL	UPDS3		;UPDATE SCORE
ENDR3	RETURN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
IERR	INCF	RERR,F		;INCREMENT ERROR
		DECF	S3,F
		RETURN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SCORE1	CALL	COFF
		MOVLW	B'01100'	;SET PRINTING ADDRESS
		CALL	ET
		MOVLW	B'01010'
		CALL 	ET
		MOVF	ERRC,W
		SUBLW	D'9'
		BTFSS	STATUS,C	;CHECK CARRY BIT
		GOTO	WEAK
		MOVF	ERRC,W
		SUBLW	D'4'
		BTFSS	STATUS,C	
		GOTO	AVG
		CALL	PRINTS		;print super
		CALL	PRINTU
		CALL	PRINTP
		CALL	PRINTE
		CALL	PRINTR
		CALL	DELAY3S	
		CALL	DELAY3S
		CALL	PATT
		GOTO	ENDGAM

WEAK	CALL	PRINTW		;print weak
		CALL	PRINTE
		CALL	PRINTA
		CALL	PRINTK
		CALL	DELAY3S	
		CALL	DELAY3S
		CALL	RLED	
		GOTO	ENDGAM

AVG		CALL	PRINTA		;print avg
		CALL	PRINTV
		CALL	PRINTG
		CALL	DELAY3S
		CALL	DELAY3S
		CALL	GLED		

ENDGAM	CALL	CLEAR		
		CALL	MENU
		CALL	INITPOS 	;RESET EVERYTHING
		GOTO	END5
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SCORE2	MOVLW	B'01000'		;GOTO ADDRESS 13 TO CHANGE THE VALUE OF THE TIMER DISPLAYED
		CALL	ET
		MOVLW	D'13'
		CALL	ET
		CALL	PRINT0		
		CALL	SLCDA
		CALL	COFF		;CURSOR OFF
		MOVF	NMATCH,W	
		ADDWF	TMRVAL,F
		MOVLW	B'01100'	;move to address 8 in lower bits
		CALL	ET
		MOVLW	B'01000'
		CALL	ET
		CALL	PRINTSC
		CALL	PRINTSP
		MOVLW	D'10'
		SUBWF	TMRVAL,W		;TMRVAL
		MOVWF	TEMP
		BTFSS	STATUS,C
		GOTO	FR
		CALL	DD			;DOUBLE DIGIT CASE
		
ENDS2	CALL	DELAY3S
		CALL	DELAY3S
		GOTO	ENDGAM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
UPDS3	MOVLW	D'13'		;CHECK IF SHOULD END GAME
		SUBWF	RERR,W	
		BTFSC	STATUS,C	;CHECK IF HAVE MORE THAN 13 REVEALED CARDS OPENED
		GOTO	ENDM3L		;END MODE 3 WITH A LOSS
		MOVLW	D'6'
		SUBWF	NMATCH,W
		BTFSC	STATUS,Z	;CHECK IF HAVE 6 MATCHES
		GOTO	ENDM3W		;END MODE 3 WITH A WIN
		
		MOVLW	B'01100'	;MOVE TO ADDRESS 15
		CALL	ET
		MOVLW	B'01111'
		CALL	ET
		CALL	PRINTSP

		MOVLW	B'01100'	;MOVE TO ADDRESS 14
		CALL	ET
		MOVLW	B'01110'
		CALL	ET

		MOVLW	D'10'
		SUBWF	S3,W		
		MOVWF	TEMP
		BTFSC	STATUS,C
		GOTO	DD			;DOUBLE DIGIT CASE
		MOVF	S3,W
		MOVWF	TMRVAL
		CALL	PRINTFR
		RETURN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ENDM3L	MOVLW	B'01100'	;MOVE TO ADDRESS 14
		CALL	ET
		MOVLW	B'01110'
		CALL	ET
		CALL	PRINT0
		CALL	BUZZER1	
		GOTO	ENDGAM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ENDM3W	CALL	PATT
		GOTO	ENDGAM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DD		CALL	PRINT1		;DOUBLE DIGIT CASE
		;BSF		TEMP,4
		MOVF	TEMP,W
		MOVWF	TMRVAL
		CALL	PRINTFR	
		RETURN

DD1		CALL	PRINT1		;DOUBLE DIGIT CASE
		;BSF		TEMP,4
		MOVF	TEMP,W
		MOVWF	TMRVAL
		CALL	PRINTFR	
		CALL	UPDS3
		RETURN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
BUZZER	BSF		PORTB,0
		CALL	DELAY3S
		BCF		PORTB,0
		GOTO	END5

BUZZER1	BSF		PORTB,0
		CALL	DELAY3S
		BCF		PORTB,0
		RETURN

RLED	BSF		PORTB,2
		CALL	DELAY3S
		BCF		PORTB,2
		RETURN

GLED	BSF		PORTB,3
		CALL	DELAY3S
		BCF		PORTB,3
		RETURN

PATT	CALL	GLED		;LED Pattern
		CALL	RLED
		CALL	GLED
		CALL	RLED
		RETURN
		
COFF	MOVLW	b'00000'	;cursor off
		CALL 	ET
		MOVLW	b'01100'		
		CALL 	ET
		RETURN
			
;CLEAR FUNCTION
CLEAR	MOVLW	B'00000'
		CALL	ET
		MOVLW	B'00001'
		CALL	ET
		RETURN		

END