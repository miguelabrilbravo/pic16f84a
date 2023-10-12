;************************************* Tablas_01.asm ************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Lee las tres líneas más bajas del puerto A, que fijan la cantidad del número de LEDs a
; iluminar. Por ejemplo, si (PORTA)=b'---00101' (cinco) se encenderán cinco diodos LEDs
; (D4, D3, D2, D1 y D0). Se resolverá utilizando tablas mediante la instrucción "retlw".
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0			; El programa comienza en la dirección 0.
Inicio
	bsf	STATUS,RP0		; Acceso al Banco 1.
	clrf	TRISB			; Las líneas del Puerto B se configuran como salida.
	movlw	b'00011111'		; Las 5 líneas del Puerto A se configuran como entrada.
	movwf	TRISA
	bcf	STATUS,RP0		; Acceso al Banco 0.
Principal
	movf	PORTA,W			; Lee la entrada.
	andlw	b'00000111'		; Se queda con los tres bits más bajos de la entrada.
	call	IluminarLEDs		; Obtiene el código deseado.
	movwf	PORTB			; El resultado se visualiza por la salida.
	goto 	Principal

; Subrutina "IluminarLEDs" --------------------------------------------------------------
;
IluminarLEDs
	addwf	PCL,F
Tabla	retlw 	b'00000000'		; Todos los LEDs apagados.
	retlw 	b'00000001'		; Se enciende D0.
	retlw 	b'00000011'		; Se enciende D1 y D0.
	retlw 	b'00000111'		; Etc.
	retlw 	b'00001111'
	retlw 	b'00011111'
	retlw 	b'00111111'
	retlw 	b'01111111'

	END				; Fin del programa.
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
