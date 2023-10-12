;
__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

Numero  	EQU 	b'00001111'

ORG 	0			; El programa comienza en la dirección 0.
Inicio
	bsf		STATUS,RP0		; Acceso al Banco 1.
	clrf	TRISB			; Las líneas del Puerto B se configuran como salida.
	movlw	b'00011111'		; Las 5 líneas del Puerto A se configuran como entrada.
	movwf	TRISA
	bcf		STATUS,RP0		; Acceso al Banco 0.
Principal


	movlw	Numero			; Carga el número a comparar.
	addlw	b'00000001'
	;movlw	b'11111111'		; Supone que son iguales y por tanto va a
					; encender todos los LEDs de salida.
	;btfss	STATUS,C		; ¿C=1?, ¿(W) positivo?, ¿(PORTA)>=Numero?
	;movlw	b'01010101'		; No, PORTA  es menor (ha resultado C=0).
	movlw	b'11111111'
	andwf	STATUS,0
	movwf	PORTB			; Resultado se visualiza por el puerto de salida.
;	goto 	Principal		; Crea un bucle cerrado e infinito.
sleep 
END