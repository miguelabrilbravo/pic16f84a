;************************************ Int_RBI_03.asm ************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Por el zumbador se oirá un pitido largo cuando pulse RB7 y uno corto cuando pulse RB6.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK   0x0C
	ENDC	

#DEFINE   EntradaRB7	PORTB,7
#DEFINE   EntradaRB6	PORTB,6
#DEFINE   Zumbador	PORTB,2

; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0
	goto	Inicio
	ORG	4
	goto	ServicioInterrupcion
Inicio
	bsf	STATUS,RP0
	bsf	EntradaRB7
	bsf	EntradaRB6
	bcf	Zumbador
	bcf	OPTION_REG,NOT_RBPU
	bcf	STATUS,RP0
	movlw	b'10001000'
	movwf	INTCON
Principal
	sleep
	goto 	Principal

; Subrutina "ServicioInterrupcion" ------------------------------------------------------
;
ServicioInterrupcion
	call	Retardo_20ms
	btfss	EntradaRB7		; ¿Está presionado el pulsador de RB7?
	call	PitidoLargo
	btfss	EntradaRB6		; ¿Está presionado el pulsador de RB6?
	call	PitidoCorto
EsperaDejePulsar			; Espera a que desaparezcan las señales de entrada.
	btfss	EntradaRB7
	goto	EsperaDejePulsar
	btfss	EntradaRB6
	goto	EsperaDejePulsar
	bcf	INTCON,RBIF
	retfie

; Subrutinas "PitidoCorto" y "PitidoLargo" ----------------------------------------------------
;
PitidoLargo
	bsf	Zumbador
	call	Retardo_200ms
PitidoCorto
	bsf	Zumbador
	call	Retardo_20ms
	bcf	Zumbador
	return	

	INCLUDE   <RETARDOS.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
