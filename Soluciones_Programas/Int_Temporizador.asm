;********************************** INT_Temporizador.asm ********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Programa de control para un temporizador digital de precisión. La programación del tiempo
; de temporización se realiza mediante dos pulsadores: "AJUSTE" y "ON/INCREM". Funcionamiento:
;     -	En estado de reposo la salida del temporizador está apagada y el pantalla aparece el
;	tiempo deseado para la próxima temporización.
;     - Si se pulsa "ON/INCREM" comienza la temporización.
;     - Cuando acaba la temporización pasa otra vez a reposo.
;     -	Si pulsa "AJUSTE" antes que haya acabado el tiempo de temporización actúa como pulsador
;	de paro: interrumpe la temporización, apaga la carga y pasa al estado de reposo.
;
; Para ajustar la temporización al tiempo deseado. 
;     -	Pulsa "AJUSTE" y ajusta el tiempo deseado mediante el pulsador "ON/INCREM".
;     -	Se vuelve a pulsar "AJUSTE" y pasa a modo de reposo.
;
; Al apagar el sistema debe conservar el tiempo de temporización deseado para la próxima vez
; que se encienda.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	TiempoDeseado				; El tiempo deseado de temporización.
	Tiempo					; Tiempo que resta de temporización.
	FlagsModos				; Guarda los flags con los diferentes
	ENDC					; modos de funcionamiento.

	ORG	0x2100				; Corresponde a la dirección 0 de la zona
						; EEPROM de datos. Aquí se va a guardar el
	DE	0x00				; tiempo de temporización deseado.

#DEFINE  F_Temporizador_ON	FlagsModos,2
#DEFINE  F_Temporizador_Ajuste	FlagsModos,1
#DEFINE  F_Temporizador_OFF	FlagsModos,0

#DEFINE  SalidaTemporizador 	PORTB,1		; Salida donde se conecta la carga.
#DEFINE  Zumbador	 	PORTB,2		; Salida donde se conecta el zumbador.
#DEFINE  AjustePulsador		PORTB,7		; Los pulsadores están conectados a estas
#DEFINE  IncrementarPulsador	PORTB,6		; líneas del Puerto B.

; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0
	goto	Inicio
	ORG	4
	goto	ServicioInterrupcion

Mensajes
	addwf	PCL,F
Mensaje_ON
	DT "   En MARCHA", 0x00
Mensaje_Ajuste
	DT "Tiempo  deseado:", 0x00
Mensaje_OFF
	DT "     PARADO", 0x00

; Instrucciones de inicialización. ------------------------------------------------------
;
Inicio	call	LCD_Inicializa
	bsf	STATUS,RP0
	movlw	b'00000111'		; Prescaler de 256 asignado al TMR0 habilita
	movwf	OPTION_REG		; resistencias de Pull-Up del Puerto B.
	bsf	AjustePulsador		; Configurados como entradas.
	bsf	IncrementarPulsador
	bcf	SalidaTemporizador		; Configurados como salidas.
	bcf	Zumbador
	bcf	STATUS,RP0
	clrw				; Lee la posición 0x00 de memoria EEPROM de datos
	call	EEPROM_LeeDato		; donde se guarda el tiempo deseado de la última vez
	movwf	TiempoDeseado		; que se ajustó.
	call	ModoTemporizador_OFF	; Modo de funcionamiento inicial.
	movlw	b'10001000'		; Activa interrupciones RBI.
	movwf	INTCON
Principal
	goto	Principal

; Subrutina "ServicioInterrupcion" ------------------------------------------------------
;
; Detecta qué ha producido la interrupción y ejecuta la subrutina de atención correspondiente.

ServicioInterrupcion
	btfsc	INTCON,T0IF
	call	Temporizador
	btfss	INTCON,RBIF		; Si es una interrupción RBI lee los pulsadores.
	goto	FinInterrupcion
	btfss	AjustePulsador		; ¿Está presionado el pulsador de "AJUSTE"?.
	call	CambiarModo		; Sí, pues salta a la subrutina correspondiente.
	btfsc	IncrementarPulsador		; ¿Pulsado "ON/INCREM"?.
	goto	FinInterrupcion		; No, pues salta al final y sale.
;
	call	Retardo_20ms		; Espera que se estabilice el nivel de tensión.
	btfsc	IncrementarPulsador	; Si es un rebote del pulsador "ON/INCREM" sale fuera.
	goto	FinInterrupcion
	btfsc	F_Temporizador_OFF	; ¿Estaba en reposo cuando pulsó "ON/INCREM"?
	call	ModoTemporizador_ON	; Sí, pues comienza la temporización.
	btfsc	F_Temporizador_Ajuste	; ¿Estaba ajustando tiempo?
	call	IncrementarTiempoDeseado	; Sí, pues pasa a incrementar el tiempo deseado.
FinInterrupcion
	bcf	INTCON,RBIF		; Limpia los flags de reconocimiento.
	bcf	INTCON,T0IF
	retfie

; Subrutinas "CambiarModo" y todas las de MODO de funcionamiento ------------------------
;
; Subrutina de atención a la interrupción producida al presionar el pulsador "AJUSTE" que cambia
; el modo de funcionamiento.

; Hay identificados tres modos de funcionamiento que se diferencian mediante los tres flags:
;    A)	Modo "Temporizador_OFF" o estado inicial. A él se pasa en el estado inicial cada vez
;	que termina una temporización o cuando se aborta la temporización sin esperar a que
;	finalice. Reconocido por el flag F_Temporizador_OFF, bit 0 del registro FlagsModos.
; 	una temporización  o cada vez que se aborta la temporización sin esperar a que finalice.
;    B)	Modo "Temporizador_Ajuste", donde se ajusta la temporización deseada cuando funcione
;	como temporizador. Reconocido por el flag F_Temporizador_Ajuste, bit 1 del FlagsModos.
;    C)	Modo "Temporizador_ON", la salida está activada mientras dure la temporización.
;	Reconocido por el flag F_Temporización_ON, que es el bit 2 del registro FlagsModos.
;
; El programa consigue que esté activado uno sólo de los flags anteriores.

; El contenido del registro (FlagsModos) diferencia los siguientes modos de funcionamiento:
; - (FlagsModos)=b'00000001'. Está en el modo "Temporizador_OFF", en reposo.
; - (FlagsModos)=b'00000010'. Está en el modo "Temporizador_Ajuste", ajustando tiempo deseado.
; - (FlagsModos)=b'00000100'. Está en el modo "Temporizador_ON", activa la carga y temporizador.
;
; Al pulsar "AJUSTE" pueden darse tres casos:
; - Si estaba en modo "Temporizador_OFF", pasa a modo "Temporizador_Ajuste".
; - Si estaba en modo "Temporizador_Ajuste", pasa a modo "Temporizador_OFF", pero antes salva
;   el tiempo de temporización deseado en la EEPROM de datos.	   
; - Si estaba en modo "Temporizador_ON", pasa a modo "Temporizador_OFF". (Interrumpe la
;   temporización).

CambiarModo
	call	PitidoCorto		; Cada vez que pulsa origina un pitido. 
	btfsc	AjustePulsador		; Si es un rebote sale fuera.
	goto	EsperaDejePulsar
	btfsc	F_Temporizador_OFF	; ¿Está en reposo?
	goto	ModoTemporizador_Ajuste	; Sí, pues pasa a ajustar la temporización.
	btfss	F_Temporizador_Ajuste	; ¿Está ajustando?
	goto	ModoTemporizador_OFF	; No, pues pasa a reposo.
					; Sí, pues antes de pasar a reposo salva en la
	clrw				; posición 00h de memoria EEPROM de datos el tiempo 
	movwf	EEADR			; de temporización deseado. Se conserva aunque se
	movf	TiempoDeseado,W		; apague la alimentación.
	call	EEPROM_EscribeDato
ModoTemporizador_OFF
	bcf	SalidaTemporizador		; Apaga la carga y resetea tiempo deseado.
	call	Pitido
	movlw	b'00000001'		; Actualiza el registro FlagsModos pasando al
	movwf	FlagsModos		; modo inicial "Temporizador_OFF".
	bcf	INTCON,T0IE		; Prohíbe las interrupciones del TMR0.
	movf	TiempoDeseado,W		; Repone otra vez el tiempo que se desea para la 
	movwf	Tiempo			; próxima temporización.
	call	LCD_Borra		; Borra la pantalla.
	movlw	Mensaje_OFF		; En pantalla el mensaje correspondiente.
	goto	FinCambiarModo

ModoTemporizador_Ajuste
	bcf	SalidaTemporizador		; Apaga la carga
	movlw	b'00000010'		; Actualiza el registro FlagsModos pasando al
	movwf	FlagsModos		; modo "Temporizador_Ajuste".
	clrf	Tiempo			; Resetea el tiempo.
	clrf	TiempoDeseado
	bcf	INTCON,T0IE		; Prohíbe las interrupciones del TMR0.
	call	LCD_Borra
	movlw	Mensaje_Ajuste		; En pantalla el mensaje correspondiente.
	goto	FinCambiarModo

ModoTemporizador_ON
	movf	TiempoDeseado,W		; Si el tiempo deseado es cero pasa a modo
	btfsc	STATUS,Z		; de trabajo "Temporizador_OFF".
	goto	ModoTemporizador_OFF
	movwf	Tiempo
	call	PitidoCorto
	movlw	b'00000100'		; Actualiza el registro FlagsModos pasando al
	movwf	FlagsModos		; modo "Temporizador_ON".
	movlw	TMR0_Carga50ms		; Carga el TMR0.
	movwf	TMR0
	movlw	Carga_1s			; Y el registro cuyo decremento contará los
	movwf	Registro50ms		; segundos.
	bsf	INTCON,T0IE		; Autoriza las interrupciones de TMR0.
	call	LCD_Borra
	bsf	SalidaTemporizador		; Enciende la carga.
	movlw	Mensaje_ON		; En pantalla el mensaje correspondiente.
FinCambiarModo
	call	LCD_Mensaje
	call	VisualizaTiempo
EsperaDejePulsar
	btfss	AjustePulsador		; Espera deje de pulsar.
	goto	EsperaDejePulsar
	return

; Subrutina "Temporizador" ----------------------------------------------------------------
;
; Esta subrutina va decrementando el tiempo de temporización y visualizándolo en la pantalla.
; Se ejecuta debido a la petición de interrupción del Timer 0 cada 50 ms exactos, comprobado
; experimentalmente con la ventana "Stopwatch" del simulador del MPLAB.

	CBLOCK
	Registro50ms			; Guarda los incrementos cada 50 ms.
	ENDC

TMR0_Carga50ms	EQU	-d'195'		; Para conseguir la interrupción cada 50 ms.
Carga_1s	EQU	d'20'			; Leerá cada segundo (20 x 50ms = 1000 ms).	

Temporizador
	call	Retardo_50micros		; Ajuste fino de 71 microsegundos para
	call	Retardo_20micros		; ajustar a 50 milisegundos exactos.
	nop
  	movlw	TMR0_Carga50ms		; Carga el Timer0.
	movwf	TMR0
	decfsz	Registro50ms,F		; Decrementa el contador.
	goto	FinTemporizador		; No ha pasado 1 segundo y por tanto sale.
	movlw	Carga_1s			; Repone el contador nuevamente.
	movwf	Registro50ms
	btfss	F_Temporizador_ON	; Si no está en modo "Temporizador_ON" sale
	goto	FinTemporizador		; fuera.
	decfsz	Tiempo,F
	goto	VisualizaContador		; Visualiza el tiempo restante.
	bcf	SalidaTemporizador		; Apaga la salida
	call	VisualizaTiempo		; Visualiza cero segundos en la pantalla.
	call	Pitido			; Tres pitidos indican final de la temporización.
	call	Retardo_500ms
	call	Pitido
	call	Retardo_500ms
	call	PitidoLargo
	call	Retardo_500ms
	call	ModoTemporizador_OFF	; Acabó la temporización.
	goto	FinTemporizador
VisualizaContador
	call	VisualizaTiempo
FinTemporizador
	return

; Subrutina "VisualizaTiempo" -----------------------------------------------------------------
;
; Visualiza el registro Tiempo en formato "Minutos:Segundos". Así por ejemplo, si
; (Tiempo)=124 segundos en la segunda línea de la pantalla visualiza " 2:04", ya que 124
; segundos es igual a 2 minutos más 4 segundos.
;
VisualizaTiempo
	movlw	.5			; Para centrar visualización en la
	call	LCD_PosicionLinea2	; segunda línea.
	movf	Tiempo,W		; Convierte el tiempo deseado (y expresado sólo en
	call	MinutosSegundos		; segundos) a minutos y segundos.
	movf	TemporizadorMinutos,W	; Visualiza los minutos.
	call	BIN_a_BCD		; Lo pasa a BCD.
	call	LCD_Byte
	movlw	':'			; Visualiza dos puntos.
	call	LCD_Caracter
	movf	TemporizadorSegundos,W	; Visualiza los segundos.
	call	BIN_a_BCD		; Lo pasa a BCD.
	goto	LCD_ByteCompleto
	return

; Subrutina "MinutosSegundos" -----------------------------------------------------------
;
; Una cantidad expresada exclusivamente en segundos y contenida en el registro W es
; convertida a minutos y segundos. El resultado se guarda en dos posiciones de memoria
; llamadas TemporizadorMinutos y TemporizadorSegundos.
;
; El máximo número a convertir será el 255 que es el máximo valor que puede adquirir el
; número binario de entrada de 8 bits. (255 segundos = 4 minutos + 15 segundos)
;
; El procedimiento utilizado es mediante restas de 60 tal como se explica en el siguiente
; ejemplo que trata de la conversión del 124 segundos a minutos y segundos.
; 124 segundos = 2 minutos + 4 segundos. 
;
; Minutos		Segundos 	¿(Segundos)<60?
; -------		--------	------------------------------------------------
;     0		      124		NO. Resta 60 a (Segundos) e incrementa (Minutos).
;     1		       64 		NO. Resta 60 e (Segundos) e incrementa (Minutos).
;     2		        4		Sí, se acabó. 
;
; Entrada:	En el registro W el número de segundos a convertir.
; Salidas:	En (TemporizadorMinutos) y (TemporizadorSegundos) el resultado.

	CBLOCK
	TemporizadorMinutos
	TemporizadorSegundos
	ENDC
;
MinutosSegundos
	movwf	TemporizadorSegundos	; Carga el número de segundos a convertir.
	clrf	TemporizadorMinutos	; Carga los registros con el resultado inicial.
Resta60
	movlw	.60			; Resta 60 en cada pasada.
	subwf	TemporizadorSegundos,W	; (W)=(TemporizadorSegundos)-60.
	btfss	STATUS,C		; ¿(W) positivo?, ¿(TemporizadorSegundos)>=60?.
	goto 	FinMinutosSegundos	; No, es menor de 60. Acabó.
	movwf	TemporizadorSegundos	; Sí, por tanto, recupera lo que queda por restar.
	incf	TemporizadorMinutos,F	; Incrementa los minutos.
	goto	Resta60			; Y vuelve a dar otra pasada.
FinMinutosSegundos
	return

; Subrutina "IncrementarTiempoDeseado" --------------------------------------------------
;
; Subrutina de atención a la interrupción por cambio de la línea RB6 a la cual se ha
; conectado el pulsador "INCREMENTAR".
; Estando en el modo "Temporizador_Ajustar" incrementa el valor del tiempo deseado
; expresado en segundos en intervalos de 5 segundos y hasta un máximo de 255 segundos.
;
SaltoIncremento	EQU	.5

IncrementarTiempoDeseado
	call	PitidoCorto		; Cada vez que pulsa se oye un pitido.
	movlw	SaltoIncremento		; Incrementa el tiempo deseado de temporización
	addwf	Tiempo,F			; saltos de "SaltoIncremento" segundos.
	btfsc	STATUS,C		; Si pasa del valor máximo lo inicializa.
	clrf	Tiempo
	call	VisualizaTiempo		; Visualiza mientras espera que deje de pulsar.
	call	Retardo_100ms
	btfss	IncrementarPulsador	; Mientras permanezca pulsado,
	goto	IncrementarTiempoDeseado	; incrementa el dígito.
	movf	Tiempo,W		; Actualiza el tiempo deseado.
	movwf	TiempoDeseado		; Este es el tiempo deseado.
	return
	
; Subrutinas "PitidoLargo", "Pitido" y "PitidoCorto" -------------------------------------
;
PitidoLargo
	bsf	Zumbador
	call	Retardo_500ms
Pitido	bsf	Zumbador
	call	Retardo_200ms
PitidoCorto
	bsf	Zumbador
	call	Retardo_20ms
	bcf	Zumbador
	return
;
	INCLUDE  <RETARDOS.INC>
	INCLUDE  <BIN_BCD.INC>
	INCLUDE  <LCD_4BIT.INC>
	INCLUDE  <LCD_MENS.INC>
	INCLUDE  <EEPROM.INC>
	END

;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
