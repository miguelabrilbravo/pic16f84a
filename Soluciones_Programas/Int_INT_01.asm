;*********************************** Int_INT_01.asm *************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Cada vez que presione el pulsador conectado al pin RB0, se incrementará un contador
; que es visualizará en el módulo LCD. La lectura se realiza mediante la técnica Polling
; leyendo constantemente el estado de la entrada.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	Contador				; El contador a visualizar.
	ENDC

#DEFINE  Pulsador 	PORTB,0		; Línea donde se conecta el pulsador.

; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0
Inicio
	call	LCD_Inicializa
	bsf	STATUS,RP0		; Acceso al Banco 1.
	bsf	Pulsador			; La línea RB0/INT se configura como entrada.
	bcf	OPTION_REG,NOT_RBPU	; Activa las resistencias de Pull-Up del Puerto B.
	bcf	STATUS,RP0		; Acceso al Banco 0.
	clrf	Contador			; Inicializa el contador y lo visualiza.
	call	VisualizaContador

; La sección "Principal" es de mantenimiento. Está leyendo constantemente 
; la línea de entrada mediante técnica Polling.

Principal
	btfss	Pulsador			; Lee el pulsador.
	call	IncrementaVisualiza		; Si pulsa, salta a incrementar y visualizar el contador.
	goto	Principal
;
; Subrutina "IncrementaVisualiza" -------------------------------------------------------
;
; Incrementa un contador y lo visualiza.
;
IncrementaVisualiza
	call	Retardo_20ms		; Espera a que se estabilice el nivel de tensión.
	btfsc	Pulsador			; Confirma si es un rebote.
	goto	Fin_Incrementa
	incf	Contador,F		; Incrementa el contador y después lo visualiza.
VisualizaContador
	call	LCD_Linea1
	movf	Contador,W
	call	BIN_a_BCD		; Se debe visualizar en BCD.
	call	LCD_Byte
EsperaDejePulsar
	btfss	Pulsador
	goto	EsperaDejePulsar
Fin_Incrementa
	return

	INCLUDE  <RETARDOS.INC>
	INCLUDE  <BIN_BCD.INC>
	INCLUDE  <LCD_4BIT.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================

