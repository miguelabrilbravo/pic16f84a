;*********************************** Elemental_06.asm ***********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Por el Puerto B obtiene el dato del Puerto A intercambiando los nibbles alto y bajo. Por
; ejemplo, si por el Puerto A se introduce "---11001" por el Puerto B aparecerá "1001xxx1".
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A		; Procesador utilizado.
	INCLUDE  <P16F84A.INC>		; Definición de algunos operandos utilizados.

; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0			; El programa comienza en la dirección 0.
Inicio
	bsf	STATUS,RP0		; Acceso al Banco 1.
	clrf	TRISB			; Las líneas del Puerto B se configuran como salida.
	movlw	b'00011111'		; Las 5 líneas del Puerto A se configuran como entrada.
	movwf	TRISA
	bcf	STATUS,RP0		; Acceso al Banco 0.
Principal
	swapf	PORTA,W			; Intercambia nibbles del Puerto A y el resultado lo
	movwf	PORTB			; lleva al Puerto B para que se visualice.
	goto 	Principal		; Crea un bucle cerrado e infinito.

	END				; Fin del programa.
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
