;************************************ Mensaje_06.asm ************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; En el módulo LCD se pueden visualizar varios mensajes diferentes. El paso de uno
; a otro se realiza al actuar sobre un pulsador conectado a la línea RA4.
; En pantalla aparecerá por ejemplo:
; 	"    Mensaje 2   "	(primera línea).
;	"COSLADA moderna."	(segunda línea).
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	Contador			; El contador a visualizar.
	ENDC			

#DEFINE		Pulsador PORTA,4	; Línea donde se conecta el pulsador.
ValorMaximo	EQU	.2		; Ultimo mensaje.

; ZONA DE CÓDIGOS *******************************************************************

	ORG	0
Inicio
	call	LCD_Inicializa
	bsf	STATUS,RP0
	bsf	Pulsador		; Línea del pulsador configurada como entrada. 
	bcf	STATUS,RP0
	clrf	Contador
	call	Visualiza		; Inicializa contador y los visualiza por 1ª vez.
Principal
	btfsc	Pulsador		; Lee el pulsador.
	goto	Fin
	call	Retardo_20ms		; Espera estabilicen niveles de tensión.
	btfsc	Pulsador		; Vuelve a leer el pulsador.
	goto	Fin
	call	IncrementaContador	; Incrementa el contador.
	call	Visualiza		; Visualiza el mensaje correspondiente.
EsperaDejePulsar
	btfss	Pulsador
	goto	EsperaDejePulsar
Fin	goto	Principal
	
; Subrutina "IncrementaContador" ---------------------------------------------------------
;
; Incrementa el valor de la variable Contador. Si llega al valor máximo lo resetea.

IncrementaContador
	incf	Contador,F		; Incrementa el contador.
	movf	Contador,W		; ¿Ha superado su valor máximo? 
	sublw	ValorMaximo		; (W)=ValorMaximo-(Contador).
	btfss	STATUS,C		; ¿C=1?, ¿(W) positivo?, ¿(ValorMaximo>=(Contador)?
	clrf	Contador		; Lo inicializa si ha superado su valor máximo.
	return	

; Subrutina "Visualiza" -----------------------------------------------------------------
;
Visualiza
	call	LCD_Borra		; Borra la pantalla y se sitúa en la línea 1.
	movlw	MensajeN		; Apunta a este mensaje.
	call	LCD_Mensaje		; Lo visualiza.
	movf	Contador,W		; A continuación visualiza el contador.
	call	BIN_a_BCD		; Se debe visualizar en BCD.
	call	LCD_Byte
	call	LCD_Linea2		; Al principio de la segunda línea del LCD.
	movf	Contador,W
	call	ApuntaMensaje		; Apunta al mensaje que se va a visualizar.
	call	LCD_Mensaje		; Lo visualiza.
	return
	
ApuntaMensaje
	addwf	PCL,F
	retlw	Mensaje0
	retlw	Mensaje1
	retlw	Mensaje2
	
; Subrutina "Mensajes" ------------------------------------------------------------------
;
Mensajes
	addwf	PCL,F
Mensaje0				; Posición inicial del mensaje 0.
	DT " ROSAS ROJAS ",0x00
Mensaje1				; Posición inicial del mensaje 1.
	DT "ESTAR Consciente", 0x00
Mensaje2				; Posición inicial del mensaje 2.
	DT "OBSERVAR", 0x00
MensajeN
	DT "   Mensaje ", 0x00

	INCLUDE  <LCD_MENS.INC>
	INCLUDE  <LCD_4BIT.INC>
	INCLUDE  <RETARDOS.INC>
	INCLUDE  <BIN_BCD.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
