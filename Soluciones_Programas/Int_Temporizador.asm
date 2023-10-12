;********************************** INT_Temporizador.asm ********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Programa de control para un temporizador digital de precisi�n. La programaci�n del tiempo
; de temporizaci�n se realiza mediante dos pulsadores: "AJUSTE" y "ON/INCREM". Funcionamiento:
;     -	En estado de reposo la salida del temporizador est� apagada y el pantalla aparece el
;	tiempo deseado para la pr�xima temporizaci�n.
;     - Si se pulsa "ON/INCREM" comienza la temporizaci�n.
;     - Cuando acaba la temporizaci�n pasa otra vez a reposo.
;     -	Si pulsa "AJUSTE" antes que haya acabado el tiempo de temporizaci�n act�a como pulsador
;	de paro: interrumpe la temporizaci�n, apaga la carga y pasa al estado de reposo.
;
; Para ajustar la temporizaci�n al tiempo deseado. 
;     -	Pulsa "AJUSTE" y ajusta el tiempo deseado mediante el pulsador "ON/INCREM".
;     -	Se vuelve a pulsar "AJUSTE" y pasa a modo de reposo.
;
; Al apagar el sistema debe conservar el tiempo de temporizaci�n deseado para la pr�xima vez
; que se encienda.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	TiempoDeseado				; El tiempo deseado de temporizaci�n.
	Tiempo					; Tiempo que resta de temporizaci�n.
	FlagsModos				; Guarda los flags con los diferentes
	ENDC					; modos de funcionamiento.

	ORG	0x2100				; Corresponde a la direcci�n 0 de la zona
						; EEPROM de datos. Aqu� se va a guardar el
	DE	0x00				; tiempo de temporizaci�n deseado.

#DEFINE  F_Temporizador_ON	FlagsModos,2
#DEFINE  F_Temporizador_Ajuste	FlagsModos,1
#DEFINE  F_Temporizador_OFF	FlagsModos,0

#DEFINE  SalidaTemporizador 	PORTB,1		; Salida donde se conecta la carga.
#DEFINE  Zumbador	 	PORTB,2		; Salida donde se conecta el zumbador.
#DEFINE  AjustePulsador		PORTB,7		; Los pulsadores est�n conectados a estas
#DEFINE  IncrementarPulsador	PORTB,6		; l�neas del Puerto B.

; ZONA DE C�DIGOS ********************************************************************

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

; Instrucciones de inicializaci�n. ------------------------------------------------------
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
	clrw				; Lee la posici�n 0x00 de memoria EEPROM de datos
	call	EEPROM_LeeDato		; donde se guarda el tiempo deseado de la �ltima vez
	movwf	TiempoDeseado		; que se ajust�.
	call	ModoTemporizador_OFF	; Modo de funcionamiento inicial.
	movlw	b'10001000'		; Activa interrupciones RBI.
	movwf	INTCON
Principal
	goto	Principal

; Subrutina "ServicioInterrupcion" ------------------------------------------------------
;
; Detecta qu� ha producido la interrupci�n y ejecuta la subrutina de atenci�n correspondiente.

ServicioInterrupcion
	btfsc	INTCON,T0IF
	call	Temporizador
	btfss	INTCON,RBIF		; Si es una interrupci�n RBI lee los pulsadores.
	goto	FinInterrupcion
	btfss	AjustePulsador		; �Est� presionado el pulsador de "AJUSTE"?.
	call	CambiarModo		; S�, pues salta a la subrutina correspondiente.
	btfsc	IncrementarPulsador		; �Pulsado "ON/INCREM"?.
	goto	FinInterrupcion		; No, pues salta al final y sale.
;
	call	Retardo_20ms		; Espera que se estabilice el nivel de tensi�n.
	btfsc	IncrementarPulsador	; Si es un rebote del pulsador "ON/INCREM" sale fuera.
	goto	FinInterrupcion
	btfsc	F_Temporizador_OFF	; �Estaba en reposo cuando puls� "ON/INCREM"?
	call	ModoTemporizador_ON	; S�, pues comienza la temporizaci�n.
	btfsc	F_Temporizador_Ajuste	; �Estaba ajustando tiempo?
	call	IncrementarTiempoDeseado	; S�, pues pasa a incrementar el tiempo deseado.
FinInterrupcion
	bcf	INTCON,RBIF		; Limpia los flags de reconocimiento.
	bcf	INTCON,T0IF
	retfie

; Subrutinas "CambiarModo" y todas las de MODO de funcionamiento ------------------------
;
; Subrutina de atenci�n a la interrupci�n producida al presionar el pulsador "AJUSTE" que cambia
; el modo de funcionamiento.

; Hay identificados tres modos de funcionamiento que se diferencian mediante los tres flags:
;    A)	Modo "Temporizador_OFF" o estado inicial. A �l se pasa en el estado inicial cada vez
;	que termina una temporizaci�n o cuando se aborta la temporizaci�n sin esperar a que
;	finalice. Reconocido por el flag F_Temporizador_OFF, bit 0 del registro FlagsModos.
; 	una temporizaci�n  o cada vez que se aborta la temporizaci�n sin esperar a que finalice.
;    B)	Modo "Temporizador_Ajuste", donde se ajusta la temporizaci�n deseada cuando funcione
;	como temporizador. Reconocido por el flag F_Temporizador_Ajuste, bit 1 del FlagsModos.
;    C)	Modo "Temporizador_ON", la salida est� activada mientras dure la temporizaci�n.
;	Reconocido por el flag F_Temporizaci�n_ON, que es el bit 2 del registro FlagsModos.
;
; El programa consigue que est� activado uno s�lo de los flags anteriores.

; El contenido del registro (FlagsModos) diferencia los siguientes modos de funcionamiento:
; - (FlagsModos)=b'00000001'. Est� en el modo "Temporizador_OFF", en reposo.
; - (FlagsModos)=b'00000010'. Est� en el modo "Temporizador_Ajuste", ajustando tiempo deseado.
; - (FlagsModos)=b'00000100'. Est� en el modo "Temporizador_ON", activa la carga y temporizador.
;
; Al pulsar "AJUSTE" pueden darse tres casos:
; - Si estaba en modo "Temporizador_OFF", pasa a modo "Temporizador_Ajuste".
; - Si estaba en modo "Temporizador_Ajuste", pasa a modo "Temporizador_OFF", pero antes salva
;   el tiempo de temporizaci�n deseado en la EEPROM de datos.	   
; - Si estaba en modo "Temporizador_ON", pasa a modo "Temporizador_OFF". (Interrumpe la
;   temporizaci�n).

CambiarModo
	call	PitidoCorto		; Cada vez que pulsa origina un pitido. 
	btfsc	AjustePulsador		; Si es un rebote sale fuera.
	goto	EsperaDejePulsar
	btfsc	F_Temporizador_OFF	; �Est� en reposo?
	goto	ModoTemporizador_Ajuste	; S�, pues pasa a ajustar la temporizaci�n.
	btfss	F_Temporizador_Ajuste	; �Est� ajustando?
	goto	ModoTemporizador_OFF	; No, pues pasa a reposo.
					; S�, pues antes de pasar a reposo salva en la
	clrw				; posici�n 00h de memoria EEPROM de datos el tiempo 
	movwf	EEADR			; de temporizaci�n deseado. Se conserva aunque se
	movf	TiempoDeseado,W		; apague la alimentaci�n.
	call	EEPROM_EscribeDato
ModoTemporizador_OFF
	bcf	SalidaTemporizador		; Apaga la carga y resetea tiempo deseado.
	call	Pitido
	movlw	b'00000001'		; Actualiza el registro FlagsModos pasando al
	movwf	FlagsModos		; modo inicial "Temporizador_OFF".
	bcf	INTCON,T0IE		; Proh�be las interrupciones del TMR0.
	movf	TiempoDeseado,W		; Repone otra vez el tiempo que se desea para la 
	movwf	Tiempo			; pr�xima temporizaci�n.
	call	LCD_Borra		; Borra la pantalla.
	movlw	Mensaje_OFF		; En pantalla el mensaje correspondiente.
	goto	FinCambiarModo

ModoTemporizador_Ajuste
	bcf	SalidaTemporizador		; Apaga la carga
	movlw	b'00000010'		; Actualiza el registro FlagsModos pasando al
	movwf	FlagsModos		; modo "Temporizador_Ajuste".
	clrf	Tiempo			; Resetea el tiempo.
	clrf	TiempoDeseado
	bcf	INTCON,T0IE		; Proh�be las interrupciones del TMR0.
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
	movlw	Carga_1s			; Y el registro cuyo decremento contar� los
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
; Esta subrutina va decrementando el tiempo de temporizaci�n y visualiz�ndolo en la pantalla.
; Se ejecuta debido a la petici�n de interrupci�n del Timer 0 cada 50 ms exactos, comprobado
; experimentalmente con la ventana "Stopwatch" del simulador del MPLAB.

	CBLOCK
	Registro50ms			; Guarda los incrementos cada 50 ms.
	ENDC

TMR0_Carga50ms	EQU	-d'195'		; Para conseguir la interrupci�n cada 50 ms.
Carga_1s	EQU	d'20'			; Leer� cada segundo (20 x 50ms = 1000 ms).	

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
	btfss	F_Temporizador_ON	; Si no est� en modo "Temporizador_ON" sale
	goto	FinTemporizador		; fuera.
	decfsz	Tiempo,F
	goto	VisualizaContador		; Visualiza el tiempo restante.
	bcf	SalidaTemporizador		; Apaga la salida
	call	VisualizaTiempo		; Visualiza cero segundos en la pantalla.
	call	Pitido			; Tres pitidos indican final de la temporizaci�n.
	call	Retardo_500ms
	call	Pitido
	call	Retardo_500ms
	call	PitidoLargo
	call	Retardo_500ms
	call	ModoTemporizador_OFF	; Acab� la temporizaci�n.
	goto	FinTemporizador
VisualizaContador
	call	VisualizaTiempo
FinTemporizador
	return

; Subrutina "VisualizaTiempo" -----------------------------------------------------------------
;
; Visualiza el registro Tiempo en formato "Minutos:Segundos". As� por ejemplo, si
; (Tiempo)=124 segundos en la segunda l�nea de la pantalla visualiza " 2:04", ya que 124
; segundos es igual a 2 minutos m�s 4 segundos.
;
VisualizaTiempo
	movlw	.5			; Para centrar visualizaci�n en la
	call	LCD_PosicionLinea2	; segunda l�nea.
	movf	Tiempo,W		; Convierte el tiempo deseado (y expresado s�lo en
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
; El m�ximo n�mero a convertir ser�el 255 que es el m�ximo valor que puede adquirir el
; n�mero binario de entrada de 8 bits. (255 segundos = 4 minutos + 15 segundos)
;
; El procedimiento utilizado es mediante restas de 60 tal como se explica en el siguiente
; ejemplo que trata de la conversi�n del 124 segundos a minutos y segundos.
; 124 segundos = 2 minutos + 4 segundos. 
;
; Minutos		Segundos 	�(Segundos)<60?
; -------		--------	------------------------------------------------
;     0		      124		NO. Resta 60 a (Segundos) e incrementa (Minutos).
;     1		       64 		NO. Resta 60 e (Segundos) e incrementa (Minutos).
;     2		        4		S�, se acab�. 
;
; Entrada:	En el registro W el n�mero de segundos a convertir.
; Salidas:	En (TemporizadorMinutos) y (TemporizadorSegundos) el resultado.

	CBLOCK
	TemporizadorMinutos
	TemporizadorSegundos
	ENDC
;
MinutosSegundos
	movwf	TemporizadorSegundos	; Carga el n�mero de segundos a convertir.
	clrf	TemporizadorMinutos	; Carga los registros con el resultado inicial.
Resta60
	movlw	.60			; Resta 60 en cada pasada.
	subwf	TemporizadorSegundos,W	; (W)=(TemporizadorSegundos)-60.
	btfss	STATUS,C		; �(W) positivo?, �(TemporizadorSegundos)>=60?.
	goto 	FinMinutosSegundos	; No, es menor de 60. Acab�.
	movwf	TemporizadorSegundos	; S�, por tanto, recupera lo que queda por restar.
	incf	TemporizadorMinutos,F	; Incrementa los minutos.
	goto	Resta60			; Y vuelve a dar otra pasada.
FinMinutosSegundos
	return

; Subrutina "IncrementarTiempoDeseado" --------------------------------------------------
;
; Subrutina de atenci�n a la interrupci�n por cambio de la l�nea RB6 a la cual se ha
; conectado el pulsador "INCREMENTAR".
; Estando en el modo "Temporizador_Ajustar" incrementa el valor del tiempo deseado
; expresado en segundos en intervalos de 5 segundos y hasta un m�ximo de 255 segundos.
;
SaltoIncremento	EQU	.5

IncrementarTiempoDeseado
	call	PitidoCorto		; Cada vez que pulsa se oye un pitido.
	movlw	SaltoIncremento		; Incrementa el tiempo deseado de temporizaci�n
	addwf	Tiempo,F			; saltos de "SaltoIncremento" segundos.
	btfsc	STATUS,C		; Si pasa del valor m�ximo lo inicializa.
	clrf	Tiempo
	call	VisualizaTiempo		; Visualiza mientras espera que deje de pulsar.
	call	Retardo_100ms
	btfss	IncrementarPulsador	; Mientras permanezca pulsado,
	goto	IncrementarTiempoDeseado	; incrementa el d�gito.
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
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
