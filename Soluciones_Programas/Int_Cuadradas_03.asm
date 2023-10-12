;******************************** Int_Cuadradas_03.asm ********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Al actuar sobre el pulsador conectado a la línea RB7 se produce la activación de una
; sirena y el módulo LCD visualiza un mensaje del tipo "Sirena ACTIVADA".
; Para apagar la sirena hay que actuar sobre el pulsador conectado a la línea RB6. En la 
; pantalla visualiza un mensaje del tipo "Sirena APAGADA".
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	Flags
	ApuntadorFrecuencia
	SentidoFrecuencia		; (SentidoFrecuencia)=0 (frecuencia ascendente).
	ENDC				; (SentidoFrecuencia)=1 (frecuencia descendente).

MaximoPeriodo	EQU	d'200'		; Corresponden a una frecuencia entre 300 Hz y 
MinimoPeriodo	EQU	d'15'		; 4 kHz tal como se demuestra posteriormente.
#DEFINE  Salida		PORTB,3
#DEFINE  EntradaActivar	PORTB,7
#DEFINE  EntradaApagar	PORTB,6
#DEFINE  AutorizaSirena	Flags,0

; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0
	goto	Inicio
	ORG	4
	goto	ServicioInterrupcion
Inicio
	call	LCD_Inicializa
	bsf	STATUS,RP0
	bcf	Salida
	bsf	EntradaApagar
	bsf	EntradaActivar
	movlw	b'00000010'		; Prescaler de 8 asignado al TMR0.
	movwf	OPTION_REG
	bcf	STATUS,RP0
	call	ApagarSirena		; En principio apaga la sirena.
	clrf	SentidoFrecuencia	; Inicializa el sentido de la variación de
	movlw	MaximoPeriodo		; frecuencia ascendente en la sirena.
	movwf	ApuntadorFrecuencia	; Inicializa a la frecuencia mínima.
	sublw	.0			; Carga en el Timer 0 con signo negativo.
	movwf	TMR0	
	movlw	b'10101000'		; Activa interrupción del TMR0 (TOIE), por cambio
	movwf	INTCON			; líneas del Puerto B (RBIE) y la general (GIE)

; El programa principal se dedica exclusivamente a generar el sonido de la sirena con 
; ayuda de la interrupción del Timer 0 en caso de que esté activada.

Principal
	btfss	AutorizaSirena
	goto	SirenaNoAutorizada	; Si no se autoriza sirena, va a modo de bajo
SirenaAutorizada			; consumo
	btfss	SentidoFrecuencia,0
	goto	FrecuenciaAscendente
FrecuenciaDescendente
	call	Retardo_20ms		; Mantiene la frecuencia durante este tiempo.
	incf	ApuntadorFrecuencia,F	; Aumenta el periodo, disminuye la frecuencia.
	movlw	MaximoPeriodo		; ¿Ha llegado a su máximo valor de periodo?
	subwf	ApuntadorFrecuencia,W	; (W)=(ApuntadorFrecuencia)-MaximoPeriodo.
	btfsc	STATUS,C		; ¿C=0?,¿(W) negativo?, ¿(ApuntadorFrecuencia)<Maximo?
	clrf	SentidoFrecuencia	; No. La siguiente pasada entra en "FrecuenciaAscendente".
	goto	Fin
FrecuenciaAscendente
	call	Retardo_10ms		; Mantiene la frecuencia durante este tiempo.
	decf	ApuntadorFrecuencia,F	; Disminuye el período, aumenta la frecuencia.
	movlw	MinimoPeriodo		; ¿Ha llegado a su minimo valor de periodo?
	subwf	ApuntadorFrecuencia,W	; (W)=(ApuntadorFrecuencia)-MinimoPeriodo
	btfss	STATUS,C		; ¿C=1?,¿(W) positivo?, ¿(ApuntadorFrecuencia)>=Minimo.
	incf	SentidoFrecuencia,F	; No. La siguiente pasada entra en "FrecuenciaDescendente".
	goto	Fin
SirenaNoAutorizada
	bcf	Salida			; Pone la salida en bajo.
	sleep				; Detiene el Timer 0 y espera en modo bajo consumo 
Fin	goto	Principal		; una interrupción del pulsador.

; Subrutina "ServicioInterrupcion" ------------------------------------------------------
;
	CBLOCK	
	Guarda_W
	Guarda_STATUS
	Guarda_R_ContA
	Guarda_R_ContB
	ENDC

ServicioInterrupcion
	movwf	Guarda_W
	swapf	STATUS,W
	movwf	Guarda_STATUS
	bcf	STATUS,RP0		; Garantiza que se trabaja en el Banco 0.
	movf	R_ContA,W		; Guarda los registros utilizados en esta 
	movwf	Guarda_R_ContA		; subrutina y también en la principal.
	movf	R_ContB,W
	movwf	Guarda_R_ContB
;
	btfsc	INTCON,RBIF		; ¿Interrupción por cambio en el Puerto B?
	call	RBI_Interrupcion
	btfsc	INTCON,T0IF		; ¿Interrupción por desbordamiento del TMR0?
	call	Timer0_Interrupcion	; No. Entonces ha sido el Timer 0.
;
	swapf	Guarda_STATUS,W		; Restaura registros W y STATUS.
	movwf	STATUS
	swapf	Guarda_W,F
	swapf	Guarda_W,W
	movf	Guarda_R_ContA,W
	movwf	R_ContA
	movf	Guarda_R_ContB,W
	movwf	R_ContB
	bcf	INTCON,RBIF
	bcf	INTCON,T0IF
	retfie

; Subrutina "RBI_Interrupcion" -------------------------------------------------------
;
RBI_Interrupcion
	call	Retardo_20ms		; Espera a que se estabilicen niveles.	
	btfsc	EntradaApagar		; ¿Está presionado el pulsador de apagado?
	goto	CompruebaActivar	; No, compueba el pulsador de activación.
ApagarSirena
	bcf	AutorizaSirena		; La sirena se apaga en el programa principal.
	call	LCD_Borra
	movlw	MensajeApagado		; Visualiza el mensaje.
	goto	Visualiza
CompruebaActivar
	btfsc	EntradaActivar		; ¿Está presionado el pulsador de activación?.
	goto	EsperaDejePulsar	; No hay activado pulsador alguno y sale.
ActivarSirena
	bsf	AutorizaSirena		; La sirena se activa en el programa principal.
	call	LCD_Borra
	movlw	MensajeActivada		; Visualiza el mensaje.
Visualiza
	call	LCD_Mensaje
EsperaDejePulsar			; Espera que desaparezcan las señales de entrada.
	btfss	EntradaApagar
	goto	EsperaDejePulsar
	btfss	EntradaActivar
	goto	EsperaDejePulsar
	return

; Subrutina "Timer0_Interrupcion" -------------------------------------------------------
;
; Con un prescaler de 8 el periodo variará según el valor de ApuntadorFrecuencia entre:
; - Para (ApuntadorFrecuencia)=15, frecuencia = 4 kHz.
;   (efectivamente 15 x 8 = 120 µs de semiperiodo que son 4 kHz aproximadamente).
; - Para (ApuntadorFrecuencia)=200, frecuencia = 300 Hz.
;   (efectivamente 200 x 8 = 1600 µs de semiperiodo que son 300 Hz aproximadamente).

Timer0_Interrupcion
	movf	ApuntadorFrecuencia,W
	sublw	.0			; Carga en el Timer 0 con signo negativo.
	movwf	TMR0 
	btfsc	Salida			; Testea el último estado de la salida.
	goto	EstabaAlto	
EstabaBajo
	bsf	Salida			; Estaba bajo y lo pasa a alto.
	goto	Fin_Timer0_Interrupcion
EstabaAlto
	bcf	Salida			; Estaba alto y lo pasa a bajo.
Fin_Timer0_Interrupcion
	return

; "Mensajes" ----------------------------------------------------------------------------
;
Mensajes
	addwf	PCL,F
MensajeApagado
	DT " Sirena APAGADA", 0x00
MensajeActivada
	DT " Ahora ACTIVADA", 0x00

	INCLUDE  <LCD_4BIT.INC>
	INCLUDE  <LCD_MENS.INC>
	INCLUDE  <RETARDOS.INC>
	END

;	====================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS".
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	====================================================================
