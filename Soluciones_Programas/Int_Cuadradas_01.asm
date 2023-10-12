;******************************** Int_Cuadradas_01.asm **********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Por la l�nea 3 del puerto B se genera una onda cuadrada. La frecuencia de la onda cuadrada cambia
; mediante activaci�n del pulsador conectado al pin 7 del puerto B, de la siguiente forma:
;
; 	PULSACI�N	FRECUENCIA		     SEMIPERIODO
; 	---------	----------		-----------------------
; 	(Inicial)	  10 kHz		   50 �s. =   1 x 50 �s
; 	Primera	  	   5 kHz		  100 �s. =   2 x 50 �s
; 	Segunda	  	   2 kHz		  250 �s. =   5 x 50 �s
; 	Tercera	  	   1 kHz		  500 �s. =  10 x 50 �s
; 	Cuarta		 500  Hz		 1000 �s. =  20 x 50 �s
; 	Quinta		 200  Hz		 2500 �s. =  50 x 50 �s
; 	Sexta		 100  Hz		 5000 �s. = 100 x 50 �s
; 	Septima	 	  50  Hz		10000 �s. = 200 x 50 �s
;
; Al conectarlo por primera vez se genera una frecuencia de 10 kHz, al activar el
; pulsador cambia a 5 kHz, al actuar una segunda vez cambia a 2 kHz, y as� sucesivamente.
;
; El m�dulo LCD visualizar� la frecuencia generada. A la l�nea de salida se puede conectar
; un altavoz que producir� un pitido.

; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK   0x0C
	ApuntadorFrecuencia
	Semiperiodo
	ENDC

TMR0_Carga50us	EQU	-d'42'		; El semiperiodo patr�n va a ser de 50 �s.
NumeroFrec	EQU	d'8'		; Ocho posibles frecuencias: 10 kHz, 5 kHz, 2 kHz,
					; 1 kHz, 500 Hz, 200 Hz, 100 Hz y 50 Hz.
#DEFINE  Salida	PORTB,3
#DEFINE  Pulsador PORTB,7

; ZONA DE C�DIGOS ********************************************************************

	ORG 	0
	goto	Inicio
	ORG	4
	goto	ServicioInterrupcion

; Subrutina "CargaContador" -------------------------------------------------------------

CargaContador
	addwf	PCL,F
	retlw	.1	; Semiperiodo   1 x 50 =    50 �s, frecuencia =  10 kHz.
	retlw	.2	; Semiperiodo   2 x 50 =   100 �s, frecuencia =   5 kHz.
	retlw	.5	; Semiperiodo   5 x 50 =   250 �s, frecuencia =   2 kHz.
	retlw	.10	; Semiperiodo  10 x 50 =   500 �s, frecuencia =   1 kHz.
	retlw	.20	; Semiperiodo  20 x 50 =  1000 �s, frecuencia = 500  Hz.
	retlw	.50	; Semiperiodo  50 x 50 =  2500 �s, frecuencia = 200  Hz.
	retlw	.100	; Semiperiodo 100 x 50 =  5000 �s, frecuencia = 100  Hz.
	retlw	.200	; Semiperiodo 200 x 50 = 10000 �s, frecuencia =  50  Hz.

; Subrutina "CargaMensaje" -------------------------------------------------------------

CargaMensaje
	addwf	PCL,F
	retlw	Mensaje10kHz
	retlw	Mensaje5kHz
	retlw	Mensaje2kHz
	retlw	Mensaje1kHz
	retlw	Mensaje500Hz
	retlw	Mensaje200Hz
	retlw	Mensaje100Hz
	retlw	Mensaje50Hz

; Subrutina "Mensajes" ------------------------------------------------------------------
;
Mensajes
	addwf	PCL,F
MensajeFrecuencia
	DT "Frec.: ", 0x00
Mensaje10kHz
	DT "10 kHz. ", 0x00
Mensaje5kHz
	DT "5 kHz.  ", 0x00
Mensaje2kHz
	DT "2 kHz.  ", 0x00
Mensaje1kHz
	DT "1 kHz.  ", 0x00
Mensaje500Hz
	DT "500 Hz. ", 0x00
Mensaje200Hz
	DT "200 Hz. ", 0x00
Mensaje100Hz
	DT "100 Hz. ", 0x00
Mensaje50Hz
	DT "50 Hz.  ", 0x00

; Programa Principal ------------------------------------------------------------------

Inicio
	call	LCD_Inicializa
	bsf	STATUS,RP0
	bcf	Salida
	bsf	Pulsador
	movlw	b'00001000'		; TMR0 sin prescaler.
	movwf	OPTION_REG
	bcf	STATUS,RP0
	call	EstadoInicial		; Visualiza la frecuencia inicial.
	movlw	TMR0_Carga50us		; Carga el TMR0.
	movwf	TMR0	
	movlw	b'10101000'
	movwf	INTCON			; Activa interrupciones del TMR0, RBI y general.
Principal
	goto	Principal

; Subrutina "ServicioInterrupcion" ------------------------------------------------------
;
; Detecta qu� ha producido la interrupci�n y ejecuta la subrutina correspondiente.

ServicioInterrupcion
	btfsc	INTCON,T0IF		; �Interrupci�n por desbordamiento del TMR0?.
	call	Timer0_Interrupcion
	btfsc	INTCON,RBIF		; �Interrupci�n por cambio en el Puerto B?.
	call	Pulsador_Interrupcion
	bcf	INTCON,T0IF		; Repone flag del TMR0.
	bcf	INTCON,RBIF		; Repone flag del RBI.
	retfie

; Subrutina "Pulsador_Interrupcion" -----------------------------------------------------
;
; Subrutina de atenci�n a la interrupci�n por cambio en la l�nea RB7 donde se ha
; conectado un pulsador. 
; Incrementa el registro (ApuntadorFrecuencia) desde b'00000000' (que corresponde a una
; frecuencia de 10 kHz) hasta b'00000111' (que corresponde a una frecuencia de 50 Hz), seg�n
; la tabla especificada en el enunciado del ejercicio.
;
Pulsador_Interrupcion
	call	Retardo_20ms
	btfsc	Pulsador
	goto	Fin_PulsadorInterrupcion
	incf	ApuntadorFrecuencia,F	; Apunta a la siguiente frecuencia.
	movlw	NumeroFrec		; Va a comprobar si ha llegado al m�ximo.
	subwf	ApuntadorFrecuencia,W	; (W)=(ApuntadorFrecuencia)-NumeroFrec
	btfsc	STATUS,C		; �Ha llegado a su m�ximo?
EstadoInicial
	clrf	ApuntadorFrecuencia	; Si llega al m�ximo lo inicializa.
	movf	ApuntadorFrecuencia,W	; Va a cargar el valor del factor de
	call	CargaContador		; multiplicaci�n del semiperiodo seg�n la 
	movwf	Semiperiodo		; tabla.
	movwf	Timer0_ContadorA
	call	LCD_Linea1		; Visualiza la frecuencia seleccionada.
	movlw	MensajeFrecuencia
	call	LCD_Mensaje
	movf	ApuntadorFrecuencia,W
	call	CargaMensaje
	call	LCD_Mensaje
EsperaDejePulsar
	btfss	Pulsador
	goto	EsperaDejePulsar
Fin_PulsadorInterrupcion
	return

; Subrutina "Timer0_Interrupcion" -------------------------------------------------------
;
	CBLOCK
	Timer0_ContadorA
	ENDC

Timer0_Interrupcion
	movlw	TMR0_Carga50us
	movwf	TMR0			; Recarga el TMR0.
	decfsz	Timer0_ContadorA,F	; Decrementa el contador.
	goto	Fin_Timer0_Interrupcion
	movf	Semiperiodo,W		; Repone el contador nuevamente.
	movwf	Timer0_ContadorA
	btfsc	Salida			; Testea el �ltimo estado de la salida.
	goto	EstabaAlto
EstabaBajo
	bsf	Salida			; Estaba bajo y lo pasa a alto.
	goto	Fin_Timer0_Interrupcion
EstabaAlto
	bcf	Salida			; Estaba alto y lo pasa a bajo.
Fin_Timer0_Interrupcion
	return

	INCLUDE  <LCD_MENS.INC>
	INCLUDE  <LCD_4BIT.INC>
	INCLUDE  <RETARDOS.INC>
	END

;	====================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS".
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	====================================================================
