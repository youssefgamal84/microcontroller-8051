$NOMOD51
;-----------------------------------------------------------------------------
;	Copyright (C) 2007 Silicon Laboratories, Inc.
; 	All rights reserved.
;
;
; 	
; 	TARGET MCU	:	C8051F000 
; 	DESCRIPTION	:	This program illustrates how to disable the watchdog timer,
;                 configure the Crossbar, configure a port and write to a port
;                 I/O pin.
;
;
; 	NOTES: 
;
; 	(1) This note intentionally left blank.
;
;
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
; EQUATES
;-----------------------------------------------------------------------------

$include (c8051f000.inc)					; Include register definition file.
          	
TABLE EQU 100H


;-----------------------------------------------------------------------------
; VARIABLES
;-----------------------------------------------------------------------------
ORG TABLE
DB 3FH,06H,5BH,4FH,66H,6DH,7DH,07H,7FH,6FH
;-----------------------------------------------------------------------------
; RESET and INTERRUPT VECTORS
;-----------------------------------------------------------------------------


           ; Reset Vector
           cseg AT 0
           ljmp Main                 ; Locate a jump to the start of code at 
                                     ; the reset vector.


;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------

Code_Seg  segment  CODE

          rseg     Code_Seg          ; Switch to this code segment.
          using    0                 ; Specify register bank for the following
                                     ; program code.

Main: 			; Disable the WDT. (IRQs not enabled at this point.)
					; If interrupts were enabled, we would need to explicitly disable
					; them so that the 2nd move to WDTCN occurs no more than four clock 
					; cycles after the first move to WDTCN.
					mov	WDTCN, #0DEh
					mov	WDTCN, #0ADh

				
					; Enable the Port I/O Crossbar
					mov		XBR2, #40h

					; Set P1 (7-segment) as push-pull output, set p2.0 and p2.7 as input (open drain)
					orl 	PRT1CF,#11111111b 
					setb P2.0
					setb P2.7

					; Initialize 7-segment Loop
				COUNT:	MOV DPTR, #TABLE 
          MOV A, #00H 
          MOV R0 , A       
          ; 7-seg Loop
					LOOP:			mov R7 , #021h
										jnb P2.0, NXT
										mov R7, #04h
							 NXT: jnb p2.7,NXT2
							 			mov R7 , #042h
							NXT2: MOVC A, @A+DPTR
                    MOV P1, A
                    INC  R0
                    MOV  A, R0
                    ACALL DELAY
                    CJNE  R0 , #0AH, LOOP
                    JMP COUNT

				

					; Simple delay loop.
DELAY:			
Loop0:			mov	R6, #00h
Loop1:			mov	R5, #00h
					djnz	R5, $
					djnz	R6, Loop1
					djnz	R7, Loop0
					RET


;-----------------------------------------------------------------------------
; End of file.

END
