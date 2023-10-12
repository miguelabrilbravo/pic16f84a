;*********************************** Watchdog_02.asm ************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Este programa comprueba el funcionamiento del Watchdog, de la instrucci�n "sleep" y
; la forma de detectar la causa de un reset.
;
; Se conectar� un pulsador al pin RA4 y cada vez que se presione se incrementar� un contador
; que se visualizar� en el modulo LCD. Si tarda m�s de 1 segundo en pulsar el Watchdog se
; despertar� y en la pantalla aparecer� un mensaje.
;
; Con un prescaler de 64 el desbordamiento del Watchdog se producir� cada 
; 18 x 64 = 1152 ms, es decir, cada segundo aproximadamente.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_ON & _PWRTE_ON & _XT_OSC

; Observad que el Watchdog est� habilitado.

	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK	0x0C
	Contador
	ENDC

#DEFINE  Pulsador	PORTA,4

; ZONA DE C�DIGOS ********************************************************************

	ORG 	0
Inicio
	call	LCD_Inicializa
	btfss	STATUS,NOT_TO		; �El reset fu� producido por el Watchdog?
	goto	ResetPorWatchdog	; S�.
	movlw	MensajePulsacion		; No. Pues entonces aparece el texto
	call	LCD_Mensaje		; "   pulsaciones".
	bsf	STATUS,RP0		; Acceso al Banco 1.
	bsf	Pulsador			; La l�nea RA4 configurada como entrada.
	movlw	b'00001110'		; Un prescaler de 64 es asignado al Watchdog.
	movwf	OPTION_REG
	bcf	STATUS,RP0		; Acceso al Banco 0.
	clrf	Contador			; Inicializa el contador y lo visualiza.
	call	VisualizaContador
	call	Retardo_2s		; Retardo inicial de un par de segundos.
Principal
	btfss	Pulsador			; Lee el pulsador.
	call	IncrementaVisualiza		; salta a incrementar y visualizar el contador.
	goto	Principal
;
; Si se produce un reset por desbordamiento del Watchdog aparece un mensaje
; significativo y s�lo puede salir de aqu� apagando o reseteando el sistema.
;
ResetPorWatchdog
	movlw	MensajeWatchdog
	call	LCD_Mensaje
	sleep

; Subrutina "IncrementaVisualiza" -------------------------------------------------------
;
IncrementaVisualiza
	clrwdt				; Resetea el Watchdog.
	call	Retardo_20ms
	btfsc	Pulsador
	goto	FinIncrementa
	incf	Contador,F		; Incrementa el contador.
VisualizaContador
	call	LCD_Linea1		; Se pone al principio de la l�nea 1.
	movf	Contador,W
	call	BIN_a_BCD		; Se debe visualizar en BCD.
	call	LCD_Byte
EsperaDejePulsar
	clrwdt				; Resetea el Watchdog mientras mantenga pulsado.
	btfss	Pulsador
	goto	EsperaDejePulsar
FinIncrementa
	return
;
Mensajes
	addwf	PCL,F
MensajePulsacion
	DT "    pulsaciones ", 0x00
MensajeWatchdog
	DT "   Eres LENTO", 0x00
;
	INCLUDE  <RETARDOS.INC>
	INCLUDE  <BIN_BCD.INC>
	INCLUDE  <LCD_4BIT.INC>
	INCLUDE  <LCD_MENS.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
