;********************************** Indexado_02B.asm *************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Repetición del ejercicio "Indexado_02.asm" sobre la forma de implementar una tabla de 
; verdad, pero resuelto con más eficacia.
;
; ZONA DE DATOS **********************************************************************

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
	bcf	STATUS,C		; Lee los sensores y los multiplica por 2
	rlf	PORTA,W			; añadiendo un "0" y desplazando hacia la izquierda.
	andlw	b'00001111'		; Se queda con los cuatro bits más bajos
	addwf	PCL,F			; Salta a la configuración adecuada.
	movlw 	b'01100001'		; Estado "Vacio" (configuración 0).
	goto	ActivaSalida
	movlw 	b'01100010'		; Estado "Llenándose" (configuración 1).
	goto	ActivaSalida
	movlw 	b'00010000'		; Estado "Alarma" (configuración 2).
	goto	ActivaSalida
	movlw 	b'00100100'		; Estado "Lleno" (configuración 3).
	goto	ActivaSalida
	movlw 	b'00010000'		; Estado "Alarma" (configuración 4).
	goto	ActivaSalida
	movlw 	b'00010000'		; Estado "Alarma" (configuración 5).
	goto	ActivaSalida
	movlw 	b'00010000'		; Estado "Alarma" (configuración 6).
	goto	ActivaSalida
	movlw 	b'00001000'		; Estado "Rebose" (configuración 7).
ActivaSalida
	movwf	PORTB			; Visualiza por el puerto de salida.
	goto 	Principal

	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
