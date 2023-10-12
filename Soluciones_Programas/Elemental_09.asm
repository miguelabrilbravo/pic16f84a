;*********************************** Elemental_09.asm ***********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Por el Puerto B se obtiene el dato del Puerto A invirtiendo los bits pares. Los impares
; se dejan como en la entrada. El orden de los bits será "b7 b6 b5 b4 b3 b2 b1 b0", siendo
; los pares el b6, b4, b2 y el b0.
;
; Por ejemplo, si por el Puerto A se introduce "---11001", por el Puerto B aparecerá
; "xxx01100".  Observar que los bits pares están invertidos (efectivamente:
; Puerto A = "---1x0x1" y Puerto B = "xxxx0x1x0") y en los impares permanece el dato del
; puerto de entrada (efectivamente: Puerto A = "---x1x0x' y Puerto B = b'xxxx1x0x'). 
;
; Ayuda: Utiliza la función XOR y la máscara b'01010101'

; ZONA DE DATOS *********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A		; Procesador utilizado.
	INCLUDE  <P16F84A.INC>		; Definición de algunos operandos utilizados.

Mascara	EQU	b'01010101'		; Máscara para invertir los bits pares mediante la
					; función XOR con "1".
; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0			; El programa comienza en la dirección 0.
Inicio
	bsf	STATUS,RP0		; Acceso al Banco 1.
	clrf	TRISB			; Las líneas del Puerto B se configuran como salida.
	movlw	b'00011111'		; Las 5 líneas del Puerto A se configuran como entrada.
	movwf	TRISA
	bcf	STATUS,RP0		; Acceso al Banco 0.
Principal
	movf 	PORTA,W			; Carga el registro de datos del Puerto A en W.
	xorlw	Mascara			; Invierte los bits pares, dejando igual los impares.
	movwf	PORTB			; El resultado se visualiza por el puerto de salida.
	goto 	Principal		; Se crea un bucle cerrado e infinito.

	END				; Fin del programa.
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
