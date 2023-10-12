;********************************** Indexado_02B.asm *************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Repetici�n del ejercicio "Indexado_02.asm" sobre la forma de implementar una tabla de 
; verdad, pero resuelto con m�s eficacia.
;
; ZONA DE DATOS **********************************************************************

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
	bcf	STATUS,C		; Lee los sensores y los multiplica por 2
	rlf	PORTA,W			; a�adiendo un "0" y desplazando hacia la izquierda.
	andlw	b'00001111'		; Se queda con los cuatro bits m�s bajos
	addwf	PCL,F			; Salta a la configuraci�n adecuada.
	movlw 	b'01100001'		; Estado "Vacio" (configuraci�n 0).
	goto	ActivaSalida
	movlw 	b'01100010'		; Estado "Llen�ndose" (configuraci�n 1).
	goto	ActivaSalida
	movlw 	b'00010000'		; Estado "Alarma" (configuraci�n 2).
	goto	ActivaSalida
	movlw 	b'00100100'		; Estado "Lleno" (configuraci�n 3).
	goto	ActivaSalida
	movlw 	b'00010000'		; Estado "Alarma" (configuraci�n 4).
	goto	ActivaSalida
	movlw 	b'00010000'		; Estado "Alarma" (configuraci�n 5).
	goto	ActivaSalida
	movlw 	b'00010000'		; Estado "Alarma" (configuraci�n 6).
	goto	ActivaSalida
	movlw 	b'00001000'		; Estado "Rebose" (configuraci�n 7).
ActivaSalida
	movwf	PORTB			; Visualiza por el puerto de salida.
	goto 	Principal

	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
