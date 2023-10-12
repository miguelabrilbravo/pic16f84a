;************************************* Tablas_02.asm ************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; La lectura del Puerto A indica el número de diodos LEDs a iluminar. Por ejemplo , si lee 
; el dato "---00101" (cinco) se iluminarán cinco diodos LEDs (D4, D3, D2, D1 y D0).
; Si supera el número 8 se encienden los LEDs pares.
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
	movf	PORTA,W			; Va a comprobar si es menor o igual a 8.
	sublw	d'8'			; (W)=8-(PORTA)
	btfss	STATUS,C		; ¿C=1?, ¿(W) positivo?, ¿(PORTA)<=8?
	goto	MayorDe8		; No, (PORTA) es mayor de 8.
	movf	PORTA,W			; Sí. El número de LEDs a encender pasa al
	call	IluminarLEDs 		; registro W.
	goto	ActivarSalida
MayorDe8
	movlw	b'01010101'		; Para encender los LEDs pares.
ActivarSalida
	movwf	PORTB			; Resultado se visualiza por la salida.
	goto 	Principal

; Subrutina "IluminarLEDs" --------------------------------------------------------------
;
IluminarLEDs
	addwf	PCL,F
Tabla	retlw 	b'00000000'		;Todos los LEDs apagados.
	retlw 	b'00000001'		;Se activa D0, etc.
	retlw 	b'00000011'
	retlw 	b'00000111'
	retlw 	b'00001111'
	retlw 	b'00011111'
	retlw 	b'00111111'
	retlw 	b'01111111'
	retlw 	b'11111111'

	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
