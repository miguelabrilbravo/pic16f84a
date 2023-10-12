;************************************* Tablas_04.asm ************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Repetir ejercicio Tablas_03.asm utilizando la directiva DT.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	P=16F84A
	INCLUDE  <P16F84A.INC>

; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0
Inicio
	bsf	STATUS,RP0
	clrf	PORTB
	movlw	b'00011111'
	movwf	PORTA
	bcf	STATUS,RP0
Principal
	movf	PORTA,W		; Lee el valor de las variables de entrada.
	andlw	b'00000111'		; Se queda con los tres bits de entrada.
	call	TablaVerdad 		; Obtiene la configuración de salida.
	movwf	PORTB			; Se visualiza por el puerto de salida.
	goto 	Principal

; Subrutina "TablaVerdad" ---------------------------------------------------------------
;
TablaVerdad
	addwf	PCL,F
	DT	0x0A, 0x09, 0x23, 0x0F, 0x20, 0x07, 0x17, 0x03F ; Configuraciones
							; de salida.
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
