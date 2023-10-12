;************************************ Saltos_01.asm *************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84A. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; El Puerto B, que actúa como salida es controlado por el bit 0 del Puerto A, que actúa como
; entrada. De manera tal que:
;    -	Si el bit 0 del PORTA es "1", se encienden todos los LEDs de salida.
;    -	Si el bit 0 del PORTA es "0", se encienden los LEDs del nibble alto y se apagan los bajo.
;
; ZONA DE DATOS *********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0			; El programa comienza en la dirección 0.
Inicio
	bsf		STATUS,RP0		; Acceso al Banco 1.
	clrf	TRISB			; Las líneas del Puerto B se configuran como salida.
	movlw	b'00011111'		; Las 5 líneas del Puerto A se configuran como entrada.
	movwf	TRISA
	bcf		STATUS,RP0		; Acceso al Banco 0.
Principal				; Supone que el bit de entrada estará a "1" y por
	movlw	b'11111111'		; tanto se van encender todos los LEDs de salida.
	btfss	PORTA,0			; ¿Bit 0 del PORTA es "1"?
	movlw	b'11110000'		; No, entonces se enciende sólo el nibble alto.
	movwf	PORTB			; Resultado se visualiza por el puerto de salida.
	goto 	Principal		; Crea un bucle cerrado e infinito.

	END				; Fin del programa.
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84A. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================

