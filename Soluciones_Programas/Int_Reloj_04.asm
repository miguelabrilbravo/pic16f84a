;*********************************** Int_Reloj_04.asm ***********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Programa para un reloj digital en tiempo real con puesta en hora. Visualiza los datos
; en formato: 
; - "Mensaje Publicitario" (Primera Línea) 
; - "Horas:Minutos:Segundos", (Segunda Línea) 
; (por ejemplo	"Editorial  Ra-Ma" (Primera Linea)
;		" 8:47:39" (Segunda Línea).
;
; Las temporizaciones necesarias del reloj se logran mediante el Timer 0 que
; produce una interrupción cada 50 ms.

; La "PuestaEnHora" se logra mediante dos pulsadores: "MODO" e "INCREMENTAR".
; Su modo de operación es:
;   1º.	Pulsa MODO, las "Horas" se ponen intermitente y se ajustan mediante el
;	pulsador INCREMENTAR.
;   2º.	Pulsa MODO y pasa a ajustar los "Minutos" de forma similar.
;   3º.	Pulsa "MODO" y se acabó la "PuestaEnHora", pasando a visualización normal.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	Hora					; Guarda las horas.
	Minuto					; Guarda los minutos.
	Segundo					; Guarda los segundos.
	MedioSegundo				; Incrementa cada medio segundo.
	Registro50ms				; Incrementa cada 50 ms
	Intermitencia				; Para lograr la intermitencia.
	FlagsAjuste				; Guarda los flags para establecer los 
	ENDC					; ajustes de hora y minuto.
;
#DEFINE  ModoPulsador		PORTB,7		; Los pulsadores se conectan a estos
#DEFINE  IncrementarPulsador	PORTB,6		; pines del Puerto B.
#DEFINE  F_AjusteHora		FlagsAjuste,1	; Flags utilizados en la puesta en hora.
#DEFINE  F_AjusteMinuto		FlagsAjuste,0
#DEFINE  F_Intermitencia	Intermitencia,0	; Si es 0, apaga en intermitencia.
TMR0_Carga50ms		EQU	-d'195'		; Para conseguir la interrupción del
						; Timer 0 cada 50 ms.
; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0
	goto	Inicio
	ORG	4
	goto	ServicioInterrupcion

Mensajes
	addwf	PCL,F
MensajePublicitario
	DT "Editorial  Ra-Ma", 0x00

Inicio	call	LCD_Inicializa
	movlw	MensajePublicitario
	call	LCD_Mensaje
	bsf	STATUS,RP0		; Acceso al Banco 1.
	movlw	b'00000111'		; Prescaler de 256 para el TMR0 y habilita
	movwf	OPTION_REG		; resistencias de Pull-Up del Puerto B.
	bsf	ModoPulsador		; Configurados como entrada.
	bsf	IncrementarPulsador
	bcf	STATUS,RP0		; Acceso al Banco 0.
	clrf	FlagsAjuste		; Inicializa todos los flags de la puesta en hora.
	clrf	Hora			; Inicializa todos los datos del reloj. 
	clrf	Minuto
	clrf	Segundo
	clrf	MedioSegundo
	clrf	Registro50ms
	movlw	TMR0_Carga50ms		; Carga el TMR0.
	movwf	TMR0		
	movlw	b'10101000'		; Activa interrupción del TMR0 (TOIE), por cambio
	movwf	INTCON			; líneas del Puerto B (RBIE) y la general (GIE).
	call	PuestaEnHoraReset	; Puesta en hora por primera vez.
	
; La sección "Principal" es mantenimiento. Sólo espera las interrupciones.
; No se puede poner en modo de bajo consumo porque la instrucción "sleep" detiene el Timer 0.

Principal
	goto	Principal

; Subrutina "ServicioInterrupcion" ------------------------------------------------------
;
; Detecta qué ha producido la interrupción y ejecuta la subrutina de atención correspondiente.

ServicioInterrupcion
	btfsc	INTCON,T0IF		; Si es una interrupción procedente del
	call	Reloj			; desbordamiento del Timer 0, actualiza el reloj.
	btfss	INTCON,RBIF		; Si es una interrupción RBI, lee los pulsadores.
	goto	FinInterrupcion
	btfss	ModoPulsador		; ¿Está presionado el pulsador de "MODO"?
	call	PuestaEnHora		; Sí, pasa a poner en hora.
	btfss	IncrementarPulsador	; ¿Pulsado "INCREMENTAR"?.
	call	Incrementar		; Sí, pasa a incrementar el registro de tiempo
FinInterrupcion				; correspondiente.
	bcf	INTCON,RBIF
	bcf	INTCON,T0IF
	retfie

; Subrutina "Reloj" ---------------------------------------------------------------------
;
; Esta subrutina actualiza los contadores Horas, Minutos, Segundos y Registro50ms.
; Se ejecuta debido a la petición de interrupción del Timer 0 cada 50 ms.
;
; Como el PIC trabaja a una frecuencia de 4 MHz, el TMR0 evoluciona cada µs y se desborda cada
; 195 x 256 = 49920 µs. Sumádole el retardo de 71 µs y el pequeño tiempo de los saltos
; iniciales y de carga del contador, resulta un total de 50000 µs exactos. Es decir, el
; TMR0 producirá una interrupción cada 50 ms exactos, comprobado experimentalmente con la
; ventana Stopwatch del simulador del MPLAB.

Reloj	call	Retardo_50micros	; Retardo de 71 microsegundos para
	call	Retardo_20micros	; ajustar a 50 milisegundos exactos.
	nop
  	movlw	TMR0_Carga50ms		; Carga el Timer 0.
	movwf	TMR0
	call	IncrementaRegistro50ms
	btfss	STATUS,C		; ¿Ha contado 10 veces 50 ms = 1/2 segundo?
	goto	FinReloj		; No. Pues sale sin visualizar el reloj.

; Si está en "ModoAjusteHora", o "ModoAjusteMinuto" conmuta el flag de intermitencia y 
; salta a visualizar el reloj.
;
	movf	FlagsAjuste,F
	btfsc	STATUS,Z
	goto	IncrementaReloj
	movlw	b'00000001'		; Conmuta el flag F_Intermitencia cada 500 ms.
	xorwf	Intermitencia,F
	goto	ActualizaReloj		; Visualiza el reloj y sale.
IncrementaReloj
	bsf	F_Intermitencia		; Se mantendrá siempre encendido durante
	call	IncrementaMedioSegundo	; el funcionamiento normal.
	btfss	STATUS,C		; ¿Ha pasado 1 segundo?
	goto	ActualizaReloj		; No. Pues sale visualizando el reloj.
	call	IncrementaSegundos	; Sí. Incrementa el segundero.
	btfss	STATUS,C		; ¿Han pasado 60 segundos?
	goto	ActualizaReloj		; No. Pues sale visualizando el reloj.
	call	IncrementaMinutos	; Sí. Incrementa el minutero.
	btfss	STATUS,C		; ¿Han pasado 60 minutos?
	goto	ActualizaReloj		; No. Pues sale visualizando el reloj.
	call	IncrementaHoras		; Sí. Incrementa las horas.
ActualizaReloj
	call	VisualizaReloj		; Visualiza el reloj.
FinReloj
	return

; Subrutina "VisualizaReloj" ------------------------------------------------------------
;
; Visualiza el reloj en la segunda línea en formato: " 8:47:39".
; Cuando se ajusta una variable, ésta debe aparecer en intermitencia. Para ello, utiliza
; el flag F_Intermitencia que conmuta cada 500 ms en la subrutina Reloj.
;
VisualizaReloj
	movlw	.4			; Para centrar visualización
	call	LCD_PosicionLinea2	; en la segunda línea.
	btfss	F_AjusteHora		; ¿Está en la puesta en hora?
	goto	EnciendeHoras		; No. Visualización normal.
	btfss	F_Intermitencia		; Sí. Intermitencia si procede.
	goto	ApagaHoras		; Apaga las horas en la intermitencia.
EnciendeHoras
	movf	Hora,W			; Va a visualizar las horas. 
	call	BIN_a_BCD		; Lo pasa a BCD.
	call	LCD_Byte		; Visualiza rechazando cero de las decenas.
	goto	VisualizaMinutos
ApagaHoras
	call	LCD_DosEspaciosBlancos	; Visualiza dos espacios en blanco.
;
VisualizaMinutos
	movlw	':'			; Envía ":" para separar datos.
	call	LCD_Caracter
	btfss	F_AjusteMinuto		; ¿Está en la puesta en hora?.
	goto	EnciendeMinutos
	btfss	F_Intermitencia
	goto	ApagaMinutos
EnciendeMinutos
	movf	Minuto,W		; Visualiza minutos.
	call	BIN_a_BCD		; Lo pasa a BCD.
	call	LCD_ByteCompleto
	goto	VisualizaSegundos
ApagaMinutos
	call	LCD_DosEspaciosBlancos	; Visualiza dos espacios en blanco.
;
VisualizaSegundos
	movlw	':'			; Envía ":" para separar datos.
	call	LCD_Caracter
	movf	Segundo,W		; Visualiza segundos.
	call	BIN_a_BCD		; Lo pasa a BCD.
	call	LCD_ByteCompleto
	return
;
; Subrutina "Incrementar" ---------------------------------------------------------------
;
; Subrutina de atención a la interrupción por cambio de la línea RB6 al cual se ha conectado
; el pulsador "INCREMENTAR". Incrementa según corresponda una sola de las variables.

Incrementar
	call	Retardo_20ms		; Espera se estabilicen niveles de tensión.	
	btfsc	IncrementarPulsador	; Si es un rebote sale fuera.
	goto	FinIncrementar
	bsf	F_Intermitencia		; Visualiza siempre mientras incrementa.
	btfsc	F_AjusteHora
	call	IncrementaHoras
	btfsc	F_AjusteMinuto
	call	IncrementaMinutos
	call	VisualizaReloj		; Visualiza mientras espera que deje
	call	Retardo_200ms		; de pulsar.
	btfss	IncrementarPulsador	; Mientras permanezca pulsado,
	goto	Incrementar		; incrementa el dígito.
FinIncrementar
	return

; Subrutina "IncrementaRegistro50ms" ----------------------------------------------------
;
; Incrementa el valor de la variable Registro50ms. Cuando llega a 10, lo cual supone 
; medio segundo (50 ms x 10 = 500 ms), lo resetea y sale con el Carry a "1".
;
IncrementaRegistro50ms
	incf	Registro50ms,F
	movlw	.10
	subwf	Registro50ms,W		; (W)=(Registro50ms)-10.
	btfsc	STATUS,C		; ¿C=0?, ¿(W) negativo?, ¿(Registro50ms)<10?
	clrf	Registro50ms		; Lo inicializa si ha superado su valor máximo.
	return

; Subrutina "IncrementaMedioSegundo" --------------------------------------------------------
;
; Incrementa el valor de la variable MedioSegundo. Su bit de menor peso se pondrá a "1" una
; vez por segundo.

IncrementaMedioSegundo
	incf	MedioSegundo,F		; Incrementa.
	bsf	STATUS,C		; Supone que ha llegado al segundo.
	btfss	MedioSegundo,0		; El bit 0 se pondrá a uno cada segundo.
	bcf	STATUS,C
	return

; Subrutina "IncrementaSegundos" -----------------------------------------------------------
;
; Incrementa el valor de la variable Segundo. Si es igual al valor máximo de 60 lo resetea
; y sale con el Carry a "1".

IncrementaSegundos
	incf	Segundo,F		; Incrementa los segundos.
	movlw	.60
	subwf	Segundo,W		; ¿Ha superado valor máximo?. (W)=(Segundo)-60.
	btfsc	STATUS,C		; ¿C=0?, ¿(W) negativo?, ¿(Segundo)<60?
	clrf	Segundo			; Lo inicializa si ha superado su valor máximo.
	return

; Subrutina "IncrementaMinutos" -----------------------------------------------------------
;
; Incrementa el valor de la variable Minuto. Si es igual al valor máximo de 60 lo resetea
; y sale con el Carry a "1".
;
IncrementaMinutos
	incf	Minuto,F		; Incrementa los minutos.
	movlw	.60
	subwf	Minuto,W		; ¿Ha superado su valor máximo?. (W)=(Minuto)-60.
	btfsc	STATUS,C		; ¿C=0?, ¿(W) negativo?, ¿(Minuto)<60?
	clrf	Minuto			; Lo inicializa si ha superado su valor máximo.
	return

; Subrutina "IncrementaHoras" -----------------------------------------------------------
;
; Incrementa el valor de la variable Hora. Si es igual al valor máximo de 24 lo resetea
; y sale con el Carry a "1".
;
IncrementaHoras
	incf	Hora,F			; Incrementa las horas.
	movlw	.24
	subwf	Hora,W			; ¿Ha superado su valor máximo?. (W)=(Hora)-24.
	btfsc	STATUS,C		; ¿C=0?, ¿(W) negativo?, ¿(Hora)<24?
	clrf	Hora			; Lo inicializa si ha superado su valor máximo.
	return
;
; Subrutina "PuestaEnHora" --------------------------------------------------------------
;
; Subrutina de atención a la interrupción producida por el pulsador "MODO" que pone en hora
; el reloj. Cada vez que se pulsa, el "1" es desplazado a través del registro (FlagsAjuste),
; pasando a ajustar secuencialmente: horas y minutos.
;
; Para comprender el funcionamiento de esta subrutina hay que saber que el registro FlagsModos
; contiene 2 flags que permiten diferenciar cada uno de los ajustes de registros de tiempo.
; - "F_AjusteHora":	bit 1 de "FlagsAjuste", para ajustar las horas.
; - "F_AjusteMinuto":	bit 0 de "FlagsAjuste", para ajustar los minutos.
;
; Así pues el contenido del registro FlagAjuste identifica los siguientes ajustes:
; - (FlagsAjuste)=00000010. Está ajustando el registro Hora.
; - (FlagsAjuste)=00000001. Está ajustando el registro Minuto.
; - (FlagsAjuste)=00000000. Está en visualización normal del reloj en tiempo real.

; Pueden ocurrir tres casos:
;     -	Que pulse "MODO" estando en modo de visualización normal que se identifica porque
;	(FlagsAjuste)=0. En este caso debe activar el flag F_AjusteHora, es decir carga
;	(FlagsAjuste)=b'00000010', ya que "F_AjusteHora" es el bit 1 del registro FlagsAjuste.
;     -	Que pulse "MODO" estando ya en la puesta en hora, en cuyo caso debe pasar al ajuste
;	del siguiente registro de tiempo (minutos). Esto lo hace mediante un desplazamiento a
;	derechas. Así, por ejemplo, si antes estaba ajustando las horas (FlagsAjuste)=b'00000010',
;	pasará a (FlagsAjuste)=b'00000001' identificado como ajuste de los minutos.
;     -	Que pulse "MODO" estando en el último ajuste correspondiente a los minutos,
;	(FlagsAjuste)=b'00000001', pasará a (FlagsAjuste)=b'00000000', indicando que la puesta
;	en hora ha terminado y pasa a visualización normal del reloj en tiempo real.
;
PuestaEnHora
	call	Retardo_20ms		; Espera a que se estabilicen niveles.	
	btfsc	ModoPulsador		; Si es un rebote sale fuera.
	goto	FinPuestaEnHora
PuestaEnHoraReset			; Al pulsar "MODO" se apaga la variable de
	bcf	F_Intermitencia		; tiempo que se va a ajustar.
	movf	FlagsAjuste,F		; Si antes estaba en funcionamiento normal, ahora
	btfss	STATUS,Z 		; pasa a ajustar la hora.
	goto	AjustaSiguiente		; Si no pasa a ajustar la variable de tiempo siguiente.
	bsf	F_AjusteHora		; Pasa a ajustar la hora.
	clrf	Segundo			; Inicializa contador de segundos y el resto.
	clrf	MedioSegundo
	clrf	Registro50ms
	goto	FinPuestaEnHora
AjustaSiguiente				; Desplaza un "1" a la derecha del registro
	bcf	STATUS,C		; FlagsAjuste para ajustar secuencialmente
	rrf	FlagsAjuste,F		; cada uno de los registros de tiempo: 
FinPuestaEnHora				; hora y minuto.
	call	VisualizaReloj
	btfss	ModoPulsador		; Ahora espera deje de pulsar.
	goto	FinPuestaEnHora
	return

	INCLUDE  <RETARDOS.INC>
	INCLUDE  <LCD_4BIT.INC>
	INCLUDE  <LCD_MENS.INC>
	INCLUDE  <BIN_BCD.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
