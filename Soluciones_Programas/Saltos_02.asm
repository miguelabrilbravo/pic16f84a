;************************************ Saltos_02.asm *************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84A. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Compara el dato del puerto de entrada PORTA y un "Numero" (por ejemplo el 13):
;   - Si (PORTA) = Numero, se encienden todos los LEDs de salida.
;   - Si (PORTA) y Numero no son iguales, se activan los LEDs pares de salida y apagan impares.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

Numero	EQU	d'13'			; Por ejemplo, este número a comparar.

; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0			; El programa comienza en la dirección 0.
Inicio
	bsf	STATUS,RP0		; Acceso al Banco 1.
	clrf	TRISB			; Las líneas del Puerto B se configuran como salida.
	movlw	b'00011111'		; Las 5 líneas del Puerto A se configuran como entrada.
	movwf	TRISA
	bcf	STATUS,RP0		; Acceso al Banco 0.
Principal
	movlw	Numero			; Carga el número a comparar.
	subwf	PORTA,W			; (W)=(PORTA)-Numero.
	movlw	b'11111111'		; Supone que son iguales y por tanto va a
					; encender todos los LEDs de salida.
	btfss	STATUS,Z		; ¿Z=1?, ¿(PORTA) = Numero?
	movlw	b'01010101'		; No, son distintos. Se encienden pares.
	movwf	PORTB			; Resultado se visualiza por el puerto de salida.
	goto	Principal		; Crea un bucle cerrado e infinito.

	END				; Fin del programa.
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84A. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
