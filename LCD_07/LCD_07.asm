;************************************** LCD_07.asm *************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Mientras se mantenga presionado el pulsador conectado al pin RA4, incrementa un contador
; que se visualiza en la pantalla. Cuando llegue a su valor máximo (por ejemplo 59) se resetea
; y comienza de nuevo la cuenta. Se mantiene 200 ms en cada cuenta.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	Contador			; El contador a visualizar.
	ENDC

#DEFINE  Pulsador PORTA,4		; Línea donde se conecta el pulsador.

; ZONA DE CÓDIGOS ********************************************************************

	ORG	0
Inicio
	call	LCD_Inicializa
	bsf	STATUS,RP0
	bsf	Pulsador		; Línea del pulsador configurada como entrada. 
	bcf	STATUS,RP0
	clrf	Contador
	call	Visualiza		; Inicializa contador y los visualiza por 1ª vez.
Principal
	btfss	Pulsador		; Lee el pulsador.
	call	IncrementaVisualiza	; Si pulsa salta a incrementar y visualizar el
	goto	Principal		; contador
	
; Subrutina "IncrementaVisualiza" -------------------------------------------------------
;
IncrementaVisualiza
	call	Retardo_20ms		; Espera a que se estabilice el nivel de tensión.
	btfsc	Pulsador		; Vuelve a leer el pulsador.
	goto	Fin_Incrementa
	call	IncrementaContador	; Incrementa el contador y después lo visualiza.
Visualiza
	movlw	.7			; Se sitúa en el centro de la línea 1.
	call	LCD_PosicionLinea1
	movf	Contador,W
	call	BIN_a_BCD
	call	LCD_Byte
	call	Retardo_200ms		; Se mantiene durante este tiempo.
Fin_Incrementa
	return
	
; Subrutina "IncrementaContador" ---------------------------------------------------------
;
; Incrementa el valor de la variable Contador. Si llega al valor máximo lo resetea.

ValorMaximo	EQU	.59		; Valor máximo de la cuenta.

IncrementaContador
	incf	Contador,F		; Incrementa el contador
	movf	Contador,W		; ¿Ha superado su valor máximo?
	sublw	ValorMaximo		; (W)=ValorMaximo-(Contador).
	btfss	STATUS,C		; ¿C=1?, ¿(W) positivo?, ¿(ValorMaximo>=(Contador)?
	clrf	Contador		; Lo inicializa si ha superado su valor máximo.
	return	

	INCLUDE  <LCD_4BIT.INC>
	INCLUDE  <RETARDOS.INC>
	INCLUDE  <BIN_BCD.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================