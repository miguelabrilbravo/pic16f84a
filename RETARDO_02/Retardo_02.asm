;************************************ Retardo_02.asm ************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; El LED conectado a la línea 0 del puerto de salida se enciende durante 400 ms y se
; apaga durante 300 ms. Utiliza las subrutinas de la librería RETARDOS.INC.
;
; ZONA DE DATOS *********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	ENDC
	
#DEFINE  LED	PORTB,0

; ZONA DE CÓDIGOS *******************************************************************

	ORG	0
Inicio
	bsf	STATUS,RP0		; Acceso al Banco 1.
	bcf	LED			; Línea del LED configurada como salida.
	bcf	STATUS,RP0		; Acceso al Banco 0.
Principal
	bsf	LED			; Enciende el LED
	call	Retardo_200ms		; durante la suma de este tiempo.
	call	Retardo_200ms
	bcf	LED			; Lo apaga durante la suma de los siguientes
	call	Retardo_200ms		; retardos.
	call	Retardo_100ms
	goto 	Principal

	INCLUDE  <RETARDOS.INC>	; Librería con subrutinas de retardo.
	END				; Fin del programa.
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
