;************************************ Saltos_04.asm *************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84A. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Compara el dato del puerto de entrada PORTA con un "Numero" (por ejemplo el 13):
;   - Si (PORTA) es mayor que "Numero" se encienden todos los LEDs de salida.
;   - Si (PORTA) es menor o igual que "Numero" se activan los LEDs pares de salida.
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
	movf	PORTA,W			; Carga el número con el dato de entrada.
	sublw	Numero			; (W)=Numero-(PORTA).
	movlw	b'11111111'		; Supone que (PORTA)>Numero, por tanto va a
					; encender todos los LEDs de salida.
	btfsc	STATUS,C		; ¿C=0?, ¿(W) negativo?, ¿Numero<(PORTA)?
	movlw	b'01010101'		; NO, PORTA es menor o igual (ha resultado C=1).
	movwf	PORTB			; Resultado se visualiza por el puerto de salida.
	goto 	Principal

	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84A. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
