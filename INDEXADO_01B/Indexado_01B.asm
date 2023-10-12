;********************************** Indexado_01B.asm ************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Repetición del ejercicio Indexado_01.asm sobre la forma de implementar una tabla de
; verdad, pero resuelto con más eficacia.
;
; ZONA DE DATOS *********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A	
	INCLUDE  <P16F84A.INC>	

; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0			; El programa comienza en la dirección 0.
Inicio
	bsf	STATUS,RP0		; Acceso al Banco 1.
	clrf	TRISB			; Las líneas del Puerto B se configuran como salida.
	movlw	b'00011111'		; Las 5 líneas del Puerto A se configuran como entrada.
	movwf	TRISA
	bcf	STATUS,RP0		; Acceso al Banco 0.
Principal
	bcf	STATUS,C		; Multiplica por 2 el valor de la entrada
	rlf	PORTA,W			; añadiendo un "0" y desplazando hacia la izquierda.
	andlw	b'00001111'		; Se queda con los cuatro bits más bajos.
	addwf	PCL,F			; Salta a la configuración adecuada.
	movlw 	b'00001010'		; (Configuración 0).
	goto	ActivaSalida
	movlw 	b'00001001'		; (Configuración 1).
	goto	ActivaSalida
	movlw 	b'00100011'		; (Configuración 2).
	goto	ActivaSalida
	movlw 	b'00001111'		; (Configuración 3).
	goto	ActivaSalida
	movlw 	b'00100000'		; (Configuración 4).
	goto	ActivaSalida
	movlw 	b'00000111'		; (Configuración 5).
	goto	ActivaSalida
	movlw 	b'00010111'		; (Configuración 6).
	goto	ActivaSalida
	movlw 	b'00111111'		; (Configuración 7).
ActivaSalida
	movwf	PORTB			; Se visualiza por el puerto de salida.
	goto 	Principal

	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
