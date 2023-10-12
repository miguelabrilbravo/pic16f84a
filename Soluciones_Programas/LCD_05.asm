;************************************** LCD_05.asm *************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Cada vez que presiona el pulsador conectado al pin RA4 incrementa un contador
; visualizado en el centro de la primera l�nea de la pantalla.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	Contador			; El contador a visualizar.
	ENDC

#DEFINE  Pulsador PORTA,4		; L�nea donde se conecta el pulsador.

; ZONA DE C�DIGOS ********************************************************************

	ORG	0
Inicio
	call	LCD_Inicializa
	bsf	STATUS,RP0
	bsf	Pulsador		; L�nea del pulsador se configura como entrada. 
	bcf	STATUS,RP0
	clrf	Contador		; Inicializa contador y los visualiza por 1� vez,
	call	Visualiza
Principal
	btfss	Pulsador		; Lee el pulsador.
	call	IncrementaVisualiza	; Si pulsa salta a incrementar y visualizar el
	goto	Principal		; contador
	
; Subrutina "IncrementaVisualiza" -------------------------------------------------------
;
IncrementaVisualiza
	call	Retardo_20ms		; Espera a que se estabilicen los niveles de tensi�n.
	btfsc	Pulsador		; Vuelve a leer el pulsador.
	goto	Fin_Incrementa
	incf	Contador,F		; Incrementa el contador y despu�s lo visualiza.
Visualiza
	movlw	.7			; Se sit�a en el centro de la l�nea 1.
	call	LCD_PosicionLinea1
	movf	Contador,W
	call	BIN_a_BCD		; Se debe visualizar en decimal.
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
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
