;************************************** Ensam_03.asm ************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Por el Puerto B se obtiene el dato de las cinco l�neas del Puerto A al que est� conectado
; un array de interruptores. Por ejemplo, si por el Puerto A se introduce "---11001", por
; el Puerto B aparecer� "xxx11001" (el valor de las tres l�neas superiores no importa).

; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC	; Configuraci�n para el
								; grabador.
	LIST	P=16F84A	; Procesador.
	INCLUDE <P16F84A.INC>	; Definici�n de los operandos utilizados.

; ZONA DE C�DIGOS ********************************************************************

	ORG 	0		; El programa comienza en la direcci�n 0 de memoria de
				; programa.
Inicio	bsf	STATUS,RP0	; Pone a 1 el bit 5 del STATUS. Acceso al Banco 1.
	clrf	TRISB		; Las l�neas del Puerto B se configuran como salidas.
	movlw	b'11111111'
	movwf	TRISA		; Las l�neas del Puerto A se configuran como entradas.
	bcf	STATUS,RP0	; Pone a 0 el bit 5 de STATUS. Acceso al Banco 0.
Principal
	movf 	PORTA,W		; Lee el Puerto A.
	movwf	PORTB		; El contenido de W se visualiza por el Puerto B.
	goto 	Principal	; Crea un bucle cerrado.

	END			; Fin del programa.

;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
