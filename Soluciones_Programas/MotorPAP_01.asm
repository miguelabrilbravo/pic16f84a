;************************************* MotorPAP_01.asm *********************************
; 
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Programa de control para un motor paso a paso (PAP) en funcionamiento y sentido de
; giro. Con RA0 a "0" el motor se pone en marcha y su sentido de giro dependerá del valor
; que tenga RA4.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK	0x0C
	ENDC

#DEFINE EntradaMarcha	PORTA,0		; Interruptor de puesta en marcha.
#DEFINE EntradaSentido	PORTA,4		; Interruptor de sentido de giro.

; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0
Inicio
	bsf	STATUS,RP0
	bsf	EntradaMarcha		; Estas líneas se configuran como entrada.
	bsf	EntradaSentido
	clrf	PORTB			; Las líneas del Puerto B configuradas como salidas.
	bcf	STATUS,RP0
Principal
	btfss	EntradaMarcha		; ¿Puesta en marcha?
	goto	Gira			; Sí.
	clrf	PORTB			; No, para el motor, poniendo a cero la línea
	goto	Fin			; de habilitación.
Gira	btfsc	EntradaSentido		; Comprueba el sentido de giro deseado.
	goto	A_Izquierda
	call	GiroDerecha		; Gira en un sentido.
	goto	Fin
A_Izquierda
	call	GiroIzquierda		; Gira en sentido contrario.
Fin	goto	Principal

; Subrutina "GiroIzquierda" -------------------------------------------------------------

GiroIzquierda
	movlw	b'00110101'		; Primer paso.
	call	ActivaSalida		; Lo envía a la salida donde está conectado el motor PAP.
	movlw	b'00110110'		; Segundo paso.
	call	ActivaSalida
	movlw	b'00111010'		; Tercer paso.
	call	ActivaSalida
	movlw	b'00111001'		; Cuarto y último paso
	call	ActivaSalida
	return

; Subrutina "GiroDerecha" ---------------------------------------------------------------

GiroDerecha
	movlw	b'00111001'		; Primer paso.
	call	ActivaSalida	
	movlw	b'00111010' 		; Segundo paso.
	call	ActivaSalida
	movlw	b'00110110'		; Tercer paso.
	call	ActivaSalida
	movlw	b'00110101'		; Último paso.
	call	ActivaSalida
	return

; Subrutina "ActivaSalida" --------------------------------------------------------------

ActivaSalida
	movwf	PORTB
	call	Retardo_10ms		; Temporización antes del siguiente paso.
	return

	INCLUDE  <RETARDOS.INC>
	END

;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
