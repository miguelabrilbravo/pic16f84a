;*********************************** Elemental_03.asm ************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Por el Puerto B obtiene el dato del Puerto A, pero en la salida los bits pares se
; fijan siempre a "1". El orden de los bits será "b7 b6 b5 b4 b3 b2 b1 b0", siendo los 
; pares el b6, b4, b2 y el b0.
;
; Por ejemplo, si por el Puerto A se introduce el dato b'---01100', por el Puerto B se
; visualiza  b'01011101'. Observar que los bits pares están a "1" (efectivamente:
; Puerto B = b'x1x1x1x1') y los impares permanecen con el dato del puerto de entrada
; (efectivamente: Puerto A = b'---x1x0x' y Puerto B = b'xxxx1x0x'). 

; ZONA DE DATOS *********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A		; Procesador utilizado.
	INCLUDE  <P16F84A.INC>		; Definición de algunos operandos utilizados.

Mascara	EQU	b'01010101'		; Máscara de bits pares siempre a "1".

; ZONA DE CÓDIGOS *******************************************************************

	ORG 	0			; El programa comienza en la dirección 0.
Inicio
	bsf	STATUS,RP0		; Pone a 1 el bit 5 del STATUS. Acceso al Banco 1.
	clrf	TRISB			; Las líneas del Puerto B se configuran como salidas.
	movlw	b'00011111'
	movwf	TRISA			; Las líneas del Puerto A se configuran como entradas.
	bcf	STATUS,RP0		; Pone a 0 el bit 5 de STATUS. Acceso al Banco 0.
Principal
	movf 	PORTA,W			; Carga el registro de datos del Puerto A en W.
	iorlw	Mascara			; Pone a "1" los bits pares.
	movwf	PORTB			; El contenido de W se deposita en el Puerto B.
	goto 	Principal		; Crea un bucle cerrado e infinito.

	END				; Fin del programa.
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
