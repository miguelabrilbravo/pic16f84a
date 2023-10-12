;************************************* Tablas_05.asm ************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Repite el ejercicio Indexado_02.asm sobre el control del nivel de un depósito de líquido
; del capítulo 9. Pero aquí se resolverá mediante tablas.
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
	movf	PORTA,W			; Lee los sensores.
	andlw	b'00000111'		; Máscara para quedarse con valor de sensores.
	call	Estado
	movwf	PORTB			; Resultado se visualiza por el puerto de salida.
	goto 	Principal

; Subrutina "Estado" --------------------------------------------------------------------
;
Estado
	addwf	PCL,F
	retlw	b'01100001'		; Entrada "Vacio".
	retlw	b'01100010'		; Estado "Llenándose".
	retlw	b'00010000'		; Estado "Alarma".
	retlw	b'00100100'		; Estado "Lleno".
	retlw	b'00010000'		; Estado "Alarma".
	retlw	b'00010000'		; Estado "Alarma".
	retlw	b'00010000'		; Estado "Alarma".
	retlw	b'00001000'		; Estado "Rebose".

	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
