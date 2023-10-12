;************************************* MotorDC_01.asm ********************************** 
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Programa de control para un motor de corriente continua en funcionamiento y sentido de
; giro. Con RA0=0, el motor se pone en marcha y su sentido de giro dependerá del valor
; que tenga RA4.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

#DEFINE  EntradaMarcha	PORTA,0		; Interruptor de puesta en marcha.
#DEFINE  EntradaSentido	PORTA,4		; Interruptor de sentido de giro.

; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0
Inicio
	bsf	STATUS,RP0
	bsf	EntradaMarcha		; Configura las líneas de entrada.
	bsf	EntradaSentido
	clrf	PORTB			; Las líneas del Puerto B configuradas como salida.
	bcf	STATUS,RP0
Principal	
	clrw				; Con esta combinación se detiene el motor.
 	btfsc	EntradaMarcha		; Comprueba el estado del interruptor de funcionamiento.
	goto	ActivaSalida
	movlw	b'00010010'		; Gira en un sentido.
	btfsc	EntradaSentido     		; Comprueba el sentido de giro deseado.
	movlw	b'00010001'		; Gira en el otro sentido.
ActivaSalida
	movwf	PORTB
	goto	Principal

	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================

