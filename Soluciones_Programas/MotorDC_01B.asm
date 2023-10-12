;*********************************** MotorDC_01B.asm ********************************
; 
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Programa de control para un motor de corriente continua en funcionamiento y sentido de
; giro. Con RA0=1, el motor se pone en marcha y su sentido de giro dependerá del valor
; que tenga RA1. Se diferencia del anterior que trabaja con bits.
;
; ZONA DE DATOS *************************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	P=16F84A
	INCLUDE <P16F84A.INC>

#DEFINE  SalidaSentido		PORTB,0		; Salida que determina el sentido de giro.
#DEFINE  SalidaMarcha		PORTB,1		; Salida de puesta en marcha o paro del motor.
#DEFINE  EntradaMarcha		PORTA,0		; Interruptor de puesta en marcha.
#DEFINE  EntradaSentido		PORTA,4		; Interruptor de sentido de giro.

; ZONA DE CÓDIGOS *********************************************************************

	ORG 	0
Inicio
	bsf	STATUS,RP0
	bsf	EntradaMarcha		; Configura las líneas de entrada y salida.
	bsf	EntradaSentido
	bcf	SalidaMarcha
	bcf	SalidaSentido
	bcf	STATUS,RP0
Principal	
 	btfsc	EntradaMarcha		; Comprueba el estado del interruptor de funcionamiento.
	goto	Gira
	bcf	SalidaMarcha		; Para el motor, poniendo a cero la línea de
	goto	Fin			; habilitación y sale.
Gira	bsf	SalidaMarcha		; Pone en marcha el motor.
	btfsc	EntradaSentido     	; Comprueba el sentido de giro deseado.
	goto	GiroOtroSentido
	bcf	SalidaSentido		; Gira en un sentido.
	goto	Fin                                                          		 
GiroOtroSentido
	bsf	SalidaSentido		; Gira en el otro sentido.
Fin	goto	Principal

	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================

