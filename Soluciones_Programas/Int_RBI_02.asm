;************************************ Int_RBI_02.asm **********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Al presionar sobre el pulsador conectado al pin RB6 se incrementa un minutero, es decir,
; cuenta de 0 a 59. Mientras se mantenga pulsado se incrementará cada 100 ms. Cada vez que
; pulse se oíra un pitido procedente de un zumbador.
;
; ZONA DE DATOS *********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK   0x0C
	Minuto
	ENDC

#DEFINE   Pulsador	PORTB,6		; Línea donde se conecta el pulsador.
#DEFINE   Zumbador	PORTB,2		; Línea donde se conecta el zumbador.

; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0
	goto	Inicio
	ORG	4			; Vector de interrupción.
	goto	ServicioInterrupcion
Inicio
	call	LCD_Inicializa
	movlw	MensajePulsacion	; Aparece el texto "   minutos.".
	call	LCD_Mensaje
	bsf	STATUS,RP0
	bsf	Pulsador
	bcf	Zumbador
	bcf	OPTION_REG,NOT_RBPU
	bcf	STATUS,RP0
	clrf	Minuto			; Inicializa el minutero y lo visualiza.
	call	VisualizaContador
	movlw	b'10001000'		; Habilita la interrupción por cambio de nivel en
	movwf	INTCON			; línea del Puerto B (RBIE)  y la general (GIE).
Principal
	sleep				; Pasa a modo de bajo consumo y espera las
	goto	Principal		; interrupciones.

; Subrutina "ServicioInterrupcion" ------------------------------------------------------
;
; Subrutina de atención a la interrupción. Incrementa el contador y lo visualiza.
;
ServicioInterrupcion
	call	Retardo_20ms		; Espera a que se estabilicen los niveles de tensión.
	btfsc	Pulsador		; ¿Es el pulsador conectado a RB6?
	goto	FinInterrupcion
	call	PitidoCorto
	call	IncrementaMinutos
VisualizaContador
	call	LCD_Linea1		; Se sitúa al principio de la línea 1.
	movf	Minuto,W
	call	BIN_a_BCD		; Debe visualizar en BCD.
	call	LCD_Byte
	call	Retardo_100ms		; Si se mantiene pulsado se incrementará cada 100 ms.
	btfss	Pulsador
	goto	ServicioInterrupcion
FinInterrupcion
	bcf	INTCON,RBIF		; Limpia flags de reconocimiento (RBIF) y
	retfie				; rehabilita las interrupciones (GIE=1).
	
; Subrutina "IncrementaMinutos" ---------------------------------------------------------
;
; Incrementa el valor de la variable "Minuto". Si llega al valor máximo de 60 lo resetea
; y sale con el Carry a 1.
;
IncrementaMinutos
	incf	Minuto,F		; Incrementa los Minutos.
	movlw	.60
	subwf	Minuto,W		; ¿Ha superado su valor máximo?. (W)=(Minuto)-60.
	btfsc	STATUS,C		; ¿C=0?, ¿(W) negativo?, ¿(Minuto) < 60?
	clrf	Minuto			; Lo inicializa si ha superado su valor máximo.
	return
	
; Subrutina "PitidoCorto" ---------------------------------------------------------------

PitidoCorto
	bsf	Zumbador
	call	Retardo_20ms
	bcf	Zumbador
	return	

; "Mensajes" ----------------------------------------------------------------------------
;
Mensajes
	addwf	PCL,F
MensajePulsacion
	DT "   minutos.", 0x00
;
	INCLUDE   <RETARDOS.INC>
	INCLUDE   <BIN_BCD.INC>
	INCLUDE   <LCD_4BIT.INC>
	INCLUDE   <LCD_MENS.INC>
	END

;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================

