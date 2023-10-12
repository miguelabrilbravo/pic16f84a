;********************************** Indexado_01B.asm ************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Repetici�n del ejercicio Indexado_01.asm sobre la forma de implementar una tabla de
; verdad, pero resuelto con m�s eficacia.
;
; ZONA DE DATOS *********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A	
	INCLUDE  <P16F84A.INC>	

; ZONA DE C�DIGOS ********************************************************************

	ORG 	0			; El programa comienza en la direcci�n 0.
Inicio
	bsf	STATUS,RP0		; Acceso al Banco 1.
	clrf	TRISB			; Las l�neas del Puerto B se configuran como salida.
	movlw	b'00011111'		; Las 5 l�neas del Puerto A se configuran como entrada.
	movwf	TRISA
	bcf	STATUS,RP0		; Acceso al Banco 0.
Principal
	bcf	STATUS,C		; Multiplica por 2 el valor de la entrada
	rlf	PORTA,W			; a�adiendo un "0" y desplazando hacia la izquierda.
	andlw	b'00001111'		; Se queda con los cuatro bits m�s bajos.
	addwf	PCL,F			; Salta a la configuraci�n adecuada.
	movlw 	b'00001010'		; (Configuraci�n 0).
	goto	ActivaSalida
	movlw 	b'00001001'		; (Configuraci�n 1).
	goto	ActivaSalida
	movlw 	b'00100011'		; (Configuraci�n 2).
	goto	ActivaSalida
	movlw 	b'00001111'		; (Configuraci�n 3).
	goto	ActivaSalida
	movlw 	b'00100000'		; (Configuraci�n 4).
	goto	ActivaSalida
	movlw 	b'00000111'		; (Configuraci�n 5).
	goto	ActivaSalida
	movlw 	b'00010111'		; (Configuraci�n 6).
	goto	ActivaSalida
	movlw 	b'00111111'		; (Configuraci�n 7).
ActivaSalida
	movwf	PORTB			; Se visualiza por el puerto de salida.
	goto 	Principal

	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
