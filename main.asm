;---------------------------------------------------------------
; Console I/O through the on board UART for MSP 430g2553 on the launchpad
; Do not to forget to set the jumpers on the launchpad board to the vertical
; direction for hardware TXD and RXD UART communications.  This program
; uses a hyperterminal program connected to the USB Code Composer
; interface com port .  Use the Device manager under the control panel
; to determine the com port address.  RS232 settings 1 stop, 8 data,
; no parity, 9600 baud, and no handshaking.
;---------------------------------------------------------------

;-------------------------------------------------------------------------------
;            .cdecls C,LIST,"msp430.h"       ; Include device header file
			.cdecls C,LIST,"msp430g2553.h"
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section
            .retainrefs                     ; Additionally retain any sections
                                            ; that have references to current
                                            ; section


; Main Code
;----------------------------------------------------------------
	; This is the stack and variable area of RAM and begins at
	; address 0x1100 can be used for program code or constants
	; .sect ".stack" ; data ram for the stack ; .sect ".const" ; data rom for initialized
	; data constants
	; .sect ".text" ; program rom for code
	; .sect ".cinit" ; program rom for global inits
	; .sect ".reset" ; MSP430 RESET Vector
	; .sect ".sysmem" ; data ram for initialized
	; variables. Use this .sect to
	; put data in RAM
	;data .byte 0x34 ; example of defining a byte
			.bss label, 4 ; allocates 4 bytes of
	; uninitialized memory with the
	; name label
			.word 0x1234 ; example of defining a 16 bit
	; word
	;strg2 .string "Hello World" ; example of a string store in
	; RAM
			.byte 0x0d,0x0a ; add a CR and a LF to the string
			.byte 0x00 ; null terminate the string
	; This is the constant area flash begins at address 0x3100 can be
	; used for program code or constants
			.sect ".const" ; initialized data rom for
	; constants. Use this .sect to
	; put data in ROM
strg1 		.string "This is a test" ; example of a string stored
	; in ROM
			.byte 0x0d,0x0a ; add a CR and a LF
			.byte 0x00 ; null terminate the string with
	; This is the code area flash begins at address 0x3100 can be
	; used for program code or constants
			.text ; program start
			.global _START ; define entry point
	;----------------------------------------------------------------
STRT 		mov.w #300h,SP ; Initialize 'x1121
; stackpointer
StopWDT 	mov.w #WDTPW+WDTHOLD,&WDTCTL ; Stop WDT
SetupP1 	bis.b #01h,&P1DIR ; P1.0 red led output
			call #Init_UART
Mainloop 	xor.b #01,&P1OUT ; Toggle P1.0

	call #NEWLINE
	mov.w #'>', R4
	call #OUTA
	call #INCHAR
	mov.w R4, R8
	call #OUTA
	cmp.w #'M' , R8
	jeq MEMORY
	cmp.w #'D', R8
	jeq DISPLAY
	cmp.w #'H', R8
	jne Mainloop
	call #INCHAR
	mov.w R4, R8
	call #OUTA
	cmp.w #'A', R8
	jeq	ITION
	cmp.w #'S', R8
	jeq	TRACT

	jmp Mainloop

DISPLAY
	call #SPACE
	call #HEX8IN ; Returns first address in R7 and second address in R6

	mov.w R6, R8 ; move upper address into R8
	and.w #0xFFFE, R7
	and.w #0xFFFE, R8

bDlp
	call #NEWLINE

	mov.w #8, R9

	mov.w R7, R11
	mov.w R7, R6
	call #HEX4OUT
	call #SPACE
plinval
	call #SPACE
	mov.w 0(R7), R6
	call #HEX4OUT
	dec R9
	cmp.w R8, R7
	jeq nextD
	incd R7
	cmp.w #0, R9
	jne plinval

nextD
	mov.w #7, R10
	sub.w R9, R10
	inc R10
	call #SPACE
	call #SPACE
	call #SPACE
	mov.w R11, R7

dlp2
	call #RANGEOUT
	cmp.w R8, R7
	jeq Mainloop
	incd R7
	dec R10
	cmp.w #0, R10
	jne dlp2

	jmp bDlp



RANGEOUT
	mov.w 0(R7), R6
	and.w #0xFF00, R6
	swpb R6
 	cmp.w #0x021, R6
	jhs cnt1
	mov.w #'.', R4
	call #OUTA
	jmp nxtdisp
cnt1	cmp.w #0x07F, R6
	jl cnt2
	mov.w #'.', R4
	call #OUTA
	jmp nxtdisp
cnt2
	mov.w R6, R4
	call #OUTA

nxtdisp
	mov.w 0(R7), R6
	and.w #0x00FF, R6
 	cmp.w #0x021, R6
	jhs cnt3
	mov.w #'.', R4
	call #OUTA
	jmp nxtdisp2
cnt3	cmp.w #0x07F, R6
	jl cnt4
	mov.w #'.', R4
	call #OUTA
	jmp nxtdisp2
cnt4
	mov.w R6, R4
	call #OUTA

nxtdisp2

	ret


PSTAT ; prints the curent status registers that is manually stored in R10 in form V=?, N=?, Z=?, C=?
	push.w R6
	push.w R4

	call #SPACE

	mov.w R10, R6	; prints V='value', by isolating V bit from within status register ie R2
	swpb R6
	bic.w #0xFFFE, R6
	mov.w #'V', R4
	call #OUTA
	mov.w #'=', R4
	call #OUTA
	call #HEXOUT
	mov.w #',', R4
	call #OUTA
	call #SPACE

	mov.w R10, R6	; prints N='value', by isolating N bit from within status register ie R2
	rra.w R6
	rra.w R6
	bic.w #0xFFFE, R6
	mov.w #'N', R4
	call #OUTA
	mov.w #'=', R4
	call #OUTA
	call #HEXOUT
	mov.w #',', R4
	call #OUTA
	call #SPACE

	mov.w R10, R6	; prints Z='value', by isolating Z bit from within status register ie R2
	rra.w R6
	bic.w #0xFFFE, R6
	mov.w #'Z', R4
	call #OUTA
	mov.w #'=', R4
	call #OUTA
	call #HEXOUT
	mov.w #',', R4
	call #OUTA
	call #SPACE

	mov.w R2, R6	; prints C='value', by isolating C bit from within status register ie R2
	bic.w #0xFFFE, R6
	mov.w #'C', R4
	call #OUTA
	mov.w #'=', R4
	call #OUTA
	call #HEXOUT
	mov.w #',', R4
	call #OUTA
	call #SPACE


	pop.w R4
	pop.w R6
	ret

ITION ; adds values from r6 and r7 and returns value to screen as R=value
	push.w R4

	call #SPACE
	call #HEX8IN
	call #SPACE

	cmp.w R7, R6
	mov.w R2, R10
	add.w R7, R6
	mov.w #'R', R4
	call #OUTA
	mov.w #'=', R4
	call #OUTA
	call #HEX4OUT
	call #PSTAT

	pop.w R4
	jmp Mainloop

TRACT		; takes in r6 and r7 and performs r7 -  r6 and prints out R=result
	call #SPACE
	call #HEX8IN
	call #SPACE


	cmp.w R6, R7
	mov.w R2, R10
	sub.w R6, R7
	mov.w R7, R6

	mov.w #'R', R4
	call #OUTA
	mov.w #'=', R4
	call #OUTA
	call #HEX4OUT
	call #PSTAT

	jmp Mainloop


MEMORY

	call #SPACE
	call #HEX4IN
	and.w #0xFFFE, R6
	mov.w R6, R11

membeg
	call #NEWLINE
	call #HEX4OUT
	call #SPACE
	call #HEX4INA
	mov.w R6, -2(R11)
	mov.w R11, R6
	jmp membeg


HEXIN	;Returns in R6
	call #INCHAR
	mov.w R4, R6
	call #OUTA
	cmp.b #0x3A, R6
	jl NUM


LET
	sub.b #0x37, R6
	jmp HEXINEXT
NUM
	sub.b #0x30, R6
HEXINEXT
	ret

HEX2IN ; TAKES IN AND RETURNS IN R6
	push.w R7

	call #HEXIN
	mov.w R6, R7
	call #HEXIN
	rla.b R7
	rla.b R7
	rla.b R7
	rla.b R7
	bis.b R7, R6

	pop.w R7
	ret

HEX4IN ; TAKES IN AND RETURNS IN R6
	push.w R7

	call #HEX2IN
	mov.w R6, R7
	call #HEX2IN
	swpb R7
	bis.w R7, R6

	pop.w R7
	ret

HEXINA	;Returns in R6
	push.w R9
	push.w R7
	call #INCHAR
	mov.w R4, R6
	call #OUTA
	cmp.w #' ', R6
	jne	pcondA
	jmp Mainloop
pcondA
	cmp.w #'p', R6
	jne ncondA
	incd R11
	mov.w R11, R6
	pop.w R7
	pop.w R9
	pop.w R7
	pop.w R7
	jmp membeg
ncondA
	cmp.w #'n', R6
	jne nocondA
	mov.w #1, R7
	decd R11
	mov.w R11, R6
	pop.w R7
	pop.w R9
	pop.w R7
	pop.w R7
	jmp membeg
nocondA
	cmp.b #0x3A, R6
	jl NUMA


LETA
	sub.b #0x37, R6
	jmp HEXINEXTA
NUMA
	sub.b #0x30, R6
HEXINEXTA
	pop.w R7
	pop.w R9
	ret



HEX2INA ; TAKES IN AND RETURNS IN R6
	push.w R7

	call #HEXINA
	mov.w R6, R7
	call #HEXINA
	rla.b R7
	rla.b R7
	rla.b R7
	rla.b R7
	bis.b R7, R6

	pop.w R7
	ret


HEX4INA ; TAKES IN AND RETURNS IN R6
	push.w R7

	call #HEX2INA
	mov.w R6, R7
	call #HEX2INA
	swpb R7
	bis.w R7, R6
	incd R11
	pop.w R7
	ret
quit

HEX8IN	;returns first number in R7 and second number in R6, prints space in between
	push.w R8

	call #HEX4IN
	mov.w R6, R7

	call #SPACE

	call #HEX4IN


	pop.w R8
	ret

er	pop.w R8
	call #NEWLINE
	jmp Mainloop

NEWLINE
	push.w R4
	mov.b #0x0A, R4    ; newline
	call #OUTA
	mov.b #0x0D, R4
	call #OUTA
	pop.w R4
	ret

SPACE
	push.w R4
	mov.b #0x20, R4    ; newline
	call #OUTA
	pop.w R4
	ret




MULTIPLICATION

	cmp.b #'*', R8
	mov.b #0x00, 4(R5)
	call #HEX2IN
	call #MULTIPLY


	mov.w #'=', R4
	call #OUTA

	call #HEX4OUT
	call #NEWLINE
	jmp Mainloop

MULTIPLY ; multiplies the numbers stored in r6 and r7 returns in R6
	push.w R7
	push.w R8
	push.w R9
	push.w R10
	push.w R11
	clr R10

	and.w #0x0ff, R6
	and.w #0x0ff, R7
	mov.w R6, R8
	mov.b #0x08, R11
MULTBEGIN
	mov.w R7, R9
	dec.b R11
	and.w #0x01, R9
	cmp.w #0x00, R9
	jeq MULTCONT
	add.w R8, R10
MULTCONT
	rla.w R8
	rra.w R7
	cmp.b #0x00, R11
	jnz MULTBEGIN

	mov.w R10, R6

	pop.w R11
	pop.w R10
	pop.w R9
	pop.w R8
	pop.w R7
	ret

HEX4OUT  ; takes bin number in R6 prints out on screen the ASCII
	push.w R7
	push.w R6

	mov.w R6, R7
	swpb R6
	call #HEX2OUT

	mov.w R7, R6
	call #HEX2OUT

	pop.w R6
	pop.w R7
	ret

HEX2OUT ; takes bin number in R6 prints out on screen the ASCII
	push.w R7
	push.w R6

	mov.w R6, R7
	and.w #0xF0, R6
	rra.b R6
	rra.b R6
	rra.b R6
	rra.b R6
	call #HEXOUT

	mov.w R7, R6
	and.w #0x0F, R6
	call #HEXOUT

	pop.w R6
	pop.w R7
	ret


HEXOUT	; takes in 4 lsbs from R6 and outputs ASCII HEX

	push.w R4
	and.w #0x0F, R6
	cmp.b #0x0A, R6
	jl NUMBER
	add.b #0x07, R6
NUMBER
	add.b #0x30, R6

	mov.w R6, R4
	call #OUTA

	pop.w R4
	ret

;
OUTA
;----------------------------------------------------------------
; prints to the screen the ASCII value stored in register 4 and
; uses register 5 as a temp value
;----------------------------------------------------------------
; IFG2 register (1) = 1 transmit buffer is empty,
; UCA0TXBUF 8 bit transmit buffer
; wait for the transmit buffer to be empty before sending the
; data out
			push R5
lpa 		mov.b &IFG2,R5
			and.b #0x02,R5
			cmp.b #0x00,R5
			jz lpa
; send the data to the transmit buffer UCA0TXBUF = A;
			mov.b R4,&UCA0TXBUF
			pop R5
			ret

INCHAR
;----------------------------------------------------------------
; returns the ASCII value in register 4
;----------------------------------------------------------------
; IFG2 register (0) = 1 receive buffer is full,
; UCA0RXBUF 8 bit receive buffer
; wait for the receive buffer is full before getting the data
			push R5
lpb 		mov.b &IFG2,R5
			and.b #0x01,R5
			cmp.b #0x00,R5
			jz lpb
			mov.b &UCA0RXBUF,R4
			pop R5
; go get the char from the receive buffer
			ret

Init_UART
;----------------------------------------------------------------
; Initialization code to set up the uart on the experimenter board to 8 data,
; 1 stop, no parity, and 9600 baud, polling operation
;----------------------------------------------------------------
;---------------------------------------------------------------
; Set up the MSP430g2553 for a 1 MHZ clock speed
; For the version 1.5 of the launchpad MSP430g2553
; BCSCTL1=CALBC1_1MHZ;
; DCOCTL=CALDCO_1MHZ;
; CALDCO_1MHZ and CALBC1_1MHZ is the location in the MSP430g2553
; so that the for MSP430 will run at 1 MHZ.
; give in the *.cmd file
; CALDCO_1MHZ        = 0x10FE;
; CALBC1_1MHZ        = 0x10FF;
			mov.b &CALBC1_1MHZ, &BCSCTL1
			mov.b &CALDCO_1MHZ, &DCOCTL
;--------------------------------------------------------------
; Set up the MSP430g2553 for 1.2 for the transmit pin and 1.1 receive pin
; For the version 1.5 of the launchpad MSP430g2553
; Need to connect the UART to port 1.
; 00 = P1SEL, P1sel2 = off, 01 = primary I/O, 10 = Reserved, 11 = secondary I/O for UART
; P1SEL =  0x06;    // transmit and receive to port 1 bits 1 and 2
; P1SEL2 = 0x06;   // transmit and receive to port 1 bits 1 and 2
;---------------------------------------------------------------
			mov.b #0x06,&P1SEL
			mov.b #0x06,&P1SEL2
; Bits p2.4 transmit and p2.5 receive UCA0CTL0=0
; 8 data, no parity 1 stop, uart, async
			mov.b #0x00,&UCA0CTL0
; (7)=1 (parity), (6)=1 Even, (5)= 0 lsb first,
; (4)= 0 8 data / 1 7 data, (3) 0 1 stop 1 / 2 stop, (2-1) --
; UART mode, (0) 0 = async
; select MLK set to 1 MHZ and put in software reset the UART
; (7-6) 00 UCLK, 01 ACLK (32768 hz), 10 SMCLK, 11 SMCLK
; (0) = 1 reset
; UCA0CTL1= 0x81;
			mov.b #0x81,&UCA0CTL1
; UCA0BR1=0;
; upper byte of divider clock word
			mov.b #0x00,&UCA0BR1
; UCA0BR0=68; ;
; clock divide from a MLK of 1 MHZ to a bit clock of 9600 -> 1MHZ /
; 9600 = 104.16 104 =0x68
			mov.b #0x68,&UCA0BR0
; UCA0BR1:UCA0BR0 two 8 bit reg to from 16 bit clock divider
; for the baud rate
; UCA0MCTL=0x06;
; low frequency mode module 3 modulation pater used for the bit
; clock
			mov.b #0x06,&UCA0MCTL
; UCA0STAT=0;
; do not loop the transmitter back to the receiver for echoing
			mov.b #0x00,&UCA0STAT
; (7) = 1 echo back trans to rec
; (6) = 1 framing, (5) = 1 overrun, (4) =1 Parity, (3) = 1 break
; (0) = 2 transmitting or receiving data
;UCA0CTL1=0x80;
; take UART out of reset
			mov.b #0x80,&UCA0CTL1
;IE2=0;
; turn transmit interrupts off
			mov.b #0x00,&IE2
; (0) = 1 receiver buffer Interrupts enabled
; (1) = 1 transmit buffer Interrupts enabled
;----------------------------------------------------------------
;****************************************************************
;----------------------------------------------------------------
; IFG2 register (0) = 1 receiver buffer is full, UCA0RXIFG
; IFG2 register (1) = 1 transmit buffer is empty, UCA0RXIFG
; UCA0RXBUF 8 bit receiver buffer, UCA0TXBUF 8 bit transmit
; buffer
			ret

;----------------------------------------------------------------
; Interrupt Vectors
;----------------------------------------------------------------
			.sect ".reset" ; MSP430 RESET Vector
			.short STRT
			.end
