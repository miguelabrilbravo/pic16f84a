;************************************ Display_02.asm ************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; En un display de 7 segmentos conectado al Puerto B se visualiza la cantidad le�da por
; el Puerto A. As� por ejemplo, si por la entrada lee "---0101 en el display visualiza "5".
; Este programa es igual que el anterior pero aqu� se va a utilizar la directiva "DT" para
; almacenar la tabla de conversi�n de binario a 7 segmentos.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

; ZONA DE C�DIGOS ********************************************************************

	ORG 	0			; El programa comienza en la direcci�n 0.
Inicio
	bsf	STATUS,RP0		; Acceso al Banco 1.
	clrf	PORTB			; Las l�neas del Puerto B se configuran como salida.
	movlw	b'00011111'		; Las 5 l�neas del Puerto A se configuran como entrada.
	movwf	PORTA
	bcf	STATUS,RP0		; Acceso al Banco 0.
Principal
	movf	PORTA,W			; Lee la entrada.
	andlw	b'00001111'		; M�scara para quedarse al nibble bajo.
	call	Binario_a_7Segmentos	; Convierte un n�mero binario a c�digo 7 Segmentos.
	movwf	PORTB			; Resultado se visualiza por el puerto de salida.
	goto 	Principal

; Subrutina "Binario_7Segmentos" --------------------------------------------------------
;
Binario_a_7Segmentos
	addwf	PCL,F
	DT	3Fh, 06h, 5Bh, 4Fh, 66h, 6Dh, 7Dh, 07h, 7Fh, 6Fh	; Del "0" al "9"
	DT	77h, 7Ch, 39h, 5Eh, 79h, 71h	; "A", "B", "C", "D", "E" y "F".

	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
