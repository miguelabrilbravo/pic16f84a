;************************************ Int_RBI_04.asm ************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Al presionar el pulsador conectado a RB7 aparece en pantalla LCD "FLANCO de bajada".
; Cuando se deja de presionar, en la pantalla del módulo LCD aparece "Flanco de SUBIDA".
;
; Este ejercicio pretende demostrar que la interrupción RBI por cambio en las líneas 
; <RB7:RB4> del Puerto B se produce tanto en el flanco de bajada como en el de subida.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK   0x0C
	ENDC

#DEFINE   Pulsador	PORTB,7

; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0
	goto	Inicio
	ORG	4
	goto	ServicioInterrupcion
Inicio
	call	LCD_Inicializa
	bsf	STATUS,RP0
	bsf	Pulsador
	bcf	OPTION_REG,NOT_RBPU
	bcf	STATUS,RP0
	movlw	b'10001000'
	movwf	INTCON
Principal
	sleep
	goto	Principal

; Subrutina "ServicioInterrupcion" ------------------------------------------------------
;
; Detecta si se ha producido la interrupción por flanco de bajada (cuando presiona el
; pulsador) o de subida (cuando se suelta el pulsador). 
;
ServicioInterrupcion
	call	Retardo_20ms		; Espera a que se estabilicen los niveles de tensión.
	call	LCD_Linea1
	movlw	MensajeFlancoBajada	; Supone que es flanco descendente.
	btfsc	Pulsador		; ¿Es flanco ascendente o descendente?
	movlw	MensajeFlancoSubida	; Ha sido flanco ascendente.
	call	LCD_Mensaje
	bcf	INTCON,RBIF
	retfie

; "Mensajes" ----------------------------------------------------------------------------

Mensajes
	addwf	PCL,F
MensajeFlancoBajada
	DT "FLANCO de Bajada", 0x00
MensajeFlancoSubida
	DT "Flanco de SUBIDA ", 0x00

	INCLUDE   <RETARDOS.INC>
	INCLUDE   <LCD_4BIT.INC>
	INCLUDE   <LCD_MENS.INC>
	END

;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================

