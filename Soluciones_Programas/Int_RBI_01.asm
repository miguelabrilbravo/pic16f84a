;************************************ Int_RBI_01.asm ************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Este programa comprueba el funcionamiento de la interrupción por cambio de estado de una
; línea de la parte alta del Puerto B, por ejemplo la RB6. Cada vez que presiona el pulsador
; conectado al pin RB6 se incrementará un contador que se visualiza en el módulo LCD.
;
; No olvidar conectar una resistencia de unos 330 ohmios en serie con el pulsador.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK   0x0C
	Contador
	ENDC

#DEFINE   Pulsador	PORTB,6		; Línea donde se conecta el pulsador.

; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0
	goto	Inicio
	ORG	4
	goto	ServicioInterrupcion
Inicio
	call	LCD_Inicializa
	bsf	STATUS,RP0
	bsf	Pulsador		; La línea se configura como entrada.
	bcf	OPTION_REG,NOT_RBPU	; Activa las resistencias de Pull-up del Puerto B.
	bcf	STATUS,RP0
	clrf	Contador		; Inicializa el contador y lo visualiza.
	call	VisualizaContador
	movlw	b'10001000'		; Habilita la interrupción RBI y la general.
	movwf	INTCON
Principal
	sleep				; Pasa a modo de bajo consumo y espera las
	goto	Principal		; interrupciones.

; Subrutina "ServicioInterrupcion" ------------------------------------------------------
;
; Subrutina de atención a la interrupción. Incrementa el contador y lo visualiza.
;
ServicioInterrupcion
	call	Retardo_20ms		; Para salvaguardar de los rebotes.
	btfsc	Pulsador		; Comprueba si es un rebote.
	goto	FinInterrupcion		; Era un rebote y por tanto sale.
	incf	Contador,F		; Incrementa el contador y lo visualiza.
VisualizaContador
	call	LCD_Linea1		; Se pone al principio de la línea 1.
	movf	Contador,W
	call	BIN_a_BCD		; Se debe visualizar en BCD.
	call	LCD_Byte
EsperaDejePulsar
	btfss	Pulsador		; Para que no interrumpa también en el flanco
	goto	EsperaDejePulsar	; de subida cuando suelte el pulsador.
FinInterrupcion
	bcf	INTCON,RBIF		; Limpia flag de reconocimiento RBIF.
	retfie

	INCLUDE   <RETARDOS.INC>
	INCLUDE   <BIN_BCD.INC>
	INCLUDE   <LCD_4BIT.INC>
	END

;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
