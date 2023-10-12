;************************************* MotorPAP_02.asm *********************************
; 
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; El motor PAP realiza una vuelta en sentido y dos en sentido contrario utilizando el modo
; Full Step.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	P=16F84A
	INCLUDE <P16F84A.INC>
	
	CBLOCK  0x0C
	Ciclos				; Se decrementará cada ciclo de 4 pasos.
	VueltasHorario
	VueltasAntihorario
	ENDC

NumeroCiclos	EQU	.12		; Un ciclo de 4 pasos son 30 grados para un PAP
					; de 7,5º en modo Half-Step. Por tanto para
					; completar una vuelta de 360º, se requieren 12
					; ciclos de 4 pasos cada uno.
; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0
Inicio
	bsf	STATUS,RP0
	clrf	PORTB			; Las líneas del Puerto B configuradas como salidas.
	bcf	STATUS,RP0
Principal	
	movlw	0x02			; Dos vueltas en sentido horario.
	movwf	VueltasHorario
OtraVueltaDerecha
	movlw	NumeroCiclos
	movwf	Ciclos
OtroCicloDerecha
	call	GiroDerecha
	decfsz	Ciclos,F
	goto	OtroCicloDerecha
	decfsz	VueltasHorario,F
	goto	OtraVueltaDerecha
;
	movlw	0x01
	movwf	VueltasAntihorario		; Una vuelta en sentido antihorario.
OtraVueltaIzquierda				; Al ser una sola vuelta no haría falta el contador.
	movlw	NumeroCiclos		; Pero se deja para que el lector pueda hacer las
	movwf	Ciclos			; pruebas que crea oportunas cambiando la carga
OtroCicloIzquierda				; (VueltaAntihorario).
	call	GiroIzquierda
	decfsz	Ciclos,F
	goto	OtroCicloIzquierda
	decfsz	VueltasAntihorario,F
	goto	OtraVueltaIzquierda
	goto	Principal

; Subrutina "GiroIzquierda" -------------------------------------------------------------

GiroIzquierda
	movlw	b'00110101'		; Primer paso.
	call	ActivaSalida
	movlw	b'00110110'		; Segundo paso.
	call	ActivaSalida
	movlw	b'00111010'		; Tercer paso.
	call	ActivaSalida
	movlw	b'00111001'		; Cuarto  y último paso.
	call	ActivaSalida
	return

; Subrutina "GiroDerecha" -------------------------------------------------------------

GiroDerecha
	movlw	b'00111001'		; Primer paso para el giro hacia la derecha.
	call	ActivaSalida
	movlw	b'00111010'		; Segundo paso.
	call	ActivaSalida
	movlw	b'00110110'		; Tercer paso.
	call	ActivaSalida
	movlw	b'00110101'		; Cuarto y último paso.
	call	ActivaSalida
	return

; Subrutina "ActivaSalida" --------------------------------------------------------------

ActivaSalida
	movwf	PORTB
	call	Retardo_50ms		; Temporización antes del siguiente paso.
	return

	INCLUDE  <RETARDOS.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
