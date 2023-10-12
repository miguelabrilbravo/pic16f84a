;************************************ Display_01.asm ************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; En un display de 7 segmentos conectado al Puerto B se visualiza la cantidad le�da por
; el Puerto A. As� por ejemplo si por la entrada lee "---0101" en el display visualiza "5".
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
	movf	PORTA,W		; Lee la entrada
	andlw	b'00001111'		; M�scara para quedarse con el valor de las
					; entradas correspondientes al nibble bajo.
	call	Binario_a_7Segmentos	; Convierte c�digo binario a 7 segmentos del display.
	movwf	PORTB			; Resultado se visualiza por el puerto de salida.
	goto 	Principal

; Subrutina "Binario_7Segmentos" --------------------------------------------------------
;
Binario_a_7Segmentos			; Tabla para display de 7 segmentos.
	addwf	PCL,F	
Tabla	retlw	3Fh			; El c�digo 7 segmentos para el "0".
	retlw	06h			; El c�digo 7 segmentos para el "1".
	retlw	5Bh			; El c�digo 7 segmentos para el "2".
	retlw	4Fh			; El c�digo 7 segmentos para el "3".
	retlw	66h			; El c�digo 7 segmentos para el "4".
	retlw	6Dh			; El c�digo 7 segmentos para el "5".
	retlw	7Dh			; El c�digo 7 segmentos para el "6".
	retlw	07h			; El c�digo 7 segmentos para el "7".
	retlw	7Fh			; El c�digo 7 segmentos para el "8".
	retlw	67h			; El c�digo 7 segmentos para el "9".
	retlw	77h			; El c�digo 7 segmentos para el "A".
	retlw	7Ch			; El c�digo 7 segmentos para el "B".
	retlw	39h			; El c�digo 7 segmentos para el "C".
	retlw	5Eh			; El c�digo 7 segmentos para el "D".
	retlw	79h			; El c�digo 7 segmentos para el "E".
	retlw	71h			; El c�digo 7 segmentos para el "F".

	END				; Fin del programa.
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
