;************************************ Int_RBI_05.asm **********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; A las líneas RB7 y RB6 se conectan dos pulsadores que producen una interrupción cada vez
; que se pulsan. En el módulo LCD se visualizará el nombre del pulsador activado: "RB7" o "RB6".
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	Contador
	ENDC

#DEFINE  EntradaRB7	PORTB,7
#DEFINE  EntradaRB6	PORTB,6

; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0
	goto	Inicio
	ORG	4			; Vector de interrupción.
	goto	ServicioInterrupcion
Inicio
	call	LCD_Inicializa
	movlw	MensajeInicial
	call	LCD_Mensaje		; Visualiza el mensaje inicial.
	bsf	STATUS,RP0		; Acceso al Banco 1.
	bsf	EntradaRB7		; Las líneas se configuran como entrada.
	bsf	EntradaRB6
	bcf	STATUS,RP0		; Acceso al Banco 0.
	movlw	b'10001000'		; Activa interrupción  por cambio en las
	movwf	INTCON			; líneas del Puerto B (RBIE) y la general (GIE).
Principal
	sleep				; Pasa a modo bajo consumo esperando las
	goto 	Principal		; interrupciones.

; Subrutina "ServicioInterrupcion" ------------------------------------------------------
;
; Subrutina de atención a la interrupción. Detecta qué ha producido la interrupción y
; ejecuta la subrutina correspondiente.

ServicioInterrupcion
	call	Retardo_20ms		; Espera se estabilicen niveles.	
	btfss	EntradaRB7		; ¿Está presionado el pulsador RB7?
	call	VisualizaRB7
	btfss	EntradaRB6		; ¿Está presionado el pulsador RB6?
	call	VisualizaRB6
	bcf	INTCON,RBIF
	retfie				; Retorna y rehabilita las interrupciones, GIE=1.

; Subrutinas "VisualizaRB7" y "VisualizaRB6" --------------------------------------------

VisualizaRB7
	call	LCD_Borra
	movlw	MensajeRB7		; Visualiza el mensaje para RB7.
	call	LCD_Mensaje
	return

VisualizaRB6
	call	LCD_Borra
	movlw	MensajeRB6		; Visualiza el mensaje para RB6.
	call	LCD_Mensaje
	return

; "Mensajes" ----------------------------------------------------------------------------
;
Mensajes
	addwf	PCL,F
MensajeInicial
	DT "Editorial  Ra-Ma", 0x00
MensajeRB7
	DT "  Pulsador RB7", 0x00
MensajeRB6
	DT "   Ahora RB6  ", 0x00

	INCLUDE   <LCD_4BIT.INC>
	INCLUDE   <LCD_MENS.INC>
	INCLUDE   <RETARDOS.INC>
	END

;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================

