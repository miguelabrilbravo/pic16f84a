;************************************ Display_02.asm ************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; En un display de 7 segmentos conectado al Puerto B se visualiza la cantidad leída por
; el Puerto A. Así por ejemplo, si por la entrada lee "---0101 en el display visualiza "5".
; Este programa es igual que el anterior pero aquí se va a utilizar la directiva "DT" para
; almacenar la tabla de conversión de binario a 7 segmentos.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0			; El programa comienza en la dirección 0.
Inicio
	bsf	STATUS,RP0		; Acceso al Banco 1.
	clrf	PORTB			; Las líneas del Puerto B se configuran como salida.
	movlw	b'00011111'		; Las 5 líneas del Puerto A se configuran como entrada.
	movwf	PORTA
	bcf	STATUS,RP0		; Acceso al Banco 0.
Principal
	movf	PORTA,W			; Lee la entrada.
	andlw	b'00001111'		; Máscara para quedarse al nibble bajo.
	call	Binario_a_7Segmentos	; Convierte un número binario a código 7 Segmentos.
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
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
