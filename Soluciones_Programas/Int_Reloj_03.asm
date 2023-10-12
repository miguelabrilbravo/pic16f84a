;*********************************** Int_Reloj_03.asm ***********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Este es el programa para un reloj digital en cuanto al ajuste manual de las horas y
; minutos, más concretamente en cuanto al cambio entre ajuste de horas y minutos. Utiliza
; el pulsador "MODO" conectado a la línea RB7 a través de una resistencia de 330 ohmios.
;
; El reloj se visualiza en formato: " 0:00:00", donde las horas, minutos y segundos siempre
; valen cero. Se mantiene en intermitente el dígito seleccionado por el pulsador "MODO" de
; la siguiente forma.
;   1º	Pulsa "MODO", las Horas se ponen intermitente.
;   2º	Pulsa "MODO" y pasa a ajustar los Minutos de forma similar.
;   3º	Pulsa "MODO" y se acabó la PuestaEnHora, pasando a visualización normal.
;	(Por ahora todo a cero).
;
; La intermitencia utiliza el flag F_Intermitencia. Cuando está en "1" la visualización
; es normal. Cuando es "0" apaga el dígito correspondiente. Conmuta cada 500 ms.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	Hora				; Guarda las horas.
	Minuto				; Guarda los minutos.
	Segundo				; Guarda los segundos.
	Registro50ms			; Incrementa cada 50 ms
	Intermitencia			; Para lograr la intermitencia.
	FlagsAjuste			; Guarda los flags para establecer los 
	ENDC				; ajustes de hora y minuto.
;
#DEFINE  ModoPulsador	PORTB,7		; El pulsador se conecta a esta línea.
#DEFINE  F_AjusteHora	FlagsAjuste,1	; Flags utilizados en la puesta en hora.
#DEFINE  F_AjusteMinuto	FlagsAjuste,0
#DEFINE  F_Intermitencia	Intermitencia,0	; Si es 0 apaga en intermitencia.
TMR0_Carga50ms	EQU	-d'195'		; Para conseguir la interrupción del
					; Timer 0 cada 50 ms.
; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0
	goto	Inicio
	ORG	4
	goto	ServicioInterrupcion

Inicio	call	LCD_Inicializa
	bsf	STATUS,RP0		; Acceso al Banco 1.
	movlw	b'00000111'		; Prescaler de 256 para el TMR0 y habilita
	movwf	OPTION_REG		; resistencias de Pull-Up del Puerto B.
	bsf	ModoPulsador		; Configurado como entrada.
	bcf	STATUS,RP0		; Acceso al Banco 0.
	clrf	FlagsAjuste		; Inicializa todos los flags de la puesta en hora.
	clrf	Hora			; Inicializa todos los datos del reloj.
	clrf	Minuto
	clrf	Segundo
	clrf	Registro50ms
	movlw	TMR0_Carga50ms		; Carga el TMR0.
	movwf	TMR0
	movlw	b'10101000'		; Activa interrupción del TMR0 (TOIE), por cambio
	movwf	INTCON			; líneas del Puerto B (RBIE) y la general (GIE).
	call	PuestaEnHoraReset	; Puesta en hora por primera vez.
	
; La sección "Principal" es de mantenimiento. Sólo espera las interrupciones.
; No se puede poner en modo de bajo consumo porque la instrucción "sleep" detiene el Timer 0.

Principal
	goto	Principal

; Subrutina "ServicioInterrupcion" ------------------------------------------------------
;
ServicioInterrupcion
	btfsc	INTCON,T0IF		; Si es una interrupción procedente del
	call	Reloj			; desbordamiento del Timer 0 actualiza el reloj.
	btfss	INTCON,RBIF		; Si es una interrupción RBI lee los pulsadores.
	goto	FinInterrupcion
	btfss	ModoPulsador		; ¿Está presionado el pulsador de "MODO"?
	call	PuestaEnHora		; Sí, pasa a poner en la hora
FinInterrupcion				; correspondiente.
	bcf	INTCON,RBIF
	bcf	INTCON,T0IF
	retfie

; Subrutina "PuestaEnHora" --------------------------------------------------------------
;
; Subrutina de atención a la interrupción producida por el pulsador "MODO" que pone en hora
; el reloj. Cada vez que pulsa, el "1" es desplazado a través del registro FlagsAjuste,
; pasando a ajustar secuencialmente: horas y minutos.
;
; Para comprender el funcionamiento de esta subrutina hay que saber que el registro FlagsModos
; contiene 2 flags que permite diferenciar cada uno de los ajustes de registros de tiempo.
; - "F_AjusteHora":	bit 1 de FlagsAjuste, para ajustar las horas.
; - "F_AjusteMinuto":	bit 0 de FlagsAjuste, para ajustar los minutos.
;
; Así pues el contenido del registro FlagAjuste identifica los siguientes ajustes:
; - (FlagsAjuste)=00000010. Está ajustando el registro Hora.
; - (FlagsAjuste)=00000001. Está ajustando el registro Minuto.
; - (FlagsAjuste)=00000000. Está en visualización normal del reloj en tiempo real.

; Pueden ocurrir tres casos:
;     -	Que pulse "MODO" estando en modo de visualización normal, que se identifica porque
;	(FlagsAjuste)=0. En este caso debe activar el flag F_AjusteHora, es decir carga
;	(FlagsAjuste)=b'00000010', ya que "F_AjusteHora" es el bit 1 del registro FlagsAjuste.
;     -	Que pulse "MODO" estando ya en la puesta en hora, en cuyo caso debe pasar al ajuste
;	del siguiente registro de tiempo (minutos). Esto lo hace mediante un desplazamiento a
;	derechas. Así por ejemplo, si antes estaba ajustando las horas (FlagsAjuste)=b'00000010',
;	pasará a (FlagsAjuste)=b'00000001', identificado como ajuste de los minutos.
;     -	Que pulse "MODO" estando en el último ajuste correspondiente a los minutos,
;	(FlagsAjuste)=b'00000001', pasará a (FlagsAjuste)=b'00000000', indicando que la puesta
;	en hora ha terminado y pasa a visualización normal del reloj en tiempo real.
;
PuestaEnHora
	call	Retardo_20ms		; Espera a que se estabilice el nivel de tensión.
PuestaEnHoraReset			; Al pulsar "MODO" se apaga la variable de
	bcf	F_Intermitencia		; tiempo ajustada.
	movf	FlagsAjuste,F		; Si antes estaba en funcionamiento normal, ahora
	btfss	STATUS,Z 		; pasa a ajustar la hora.
	goto	AjustaSiguiente		; Si no pasa a ajustar la variable de tiempo siguiente.
	bsf	F_AjusteHora		; Pasa a ajustar la hora.
	clrf	Segundo			; Inicializa estos registros.
	clrf	Registro50ms
	goto	FinPuestaEnHora
AjustaSiguiente				; Desplaza un "1" a la derecha del registro
	bcf	STATUS,C		; FlagsAjuste para ajustar secuencialmente
	rrf	FlagsAjuste,F		; cada uno de los registros de tiempo: 
FinPuestaEnHora				; hora y minuto.
	call	VisualizaReloj
	btfss	ModoPulsador		; Ahora espera a que deje de pulsar.
	goto	FinPuestaEnHora
	return

; Subrutina "Reloj" ---------------------------------------------------------------------
;
; Esta subrutina actualiza el contador Registro50ms. Se ejecuta debido a la petición de
; interrupción del Timer 0 cada 50 ms exactos, comprobado experimentalmente con la
; ventana Stopwatch del simulador del MPLAB.

Reloj	call	Retardo_50micros	; Retardo de 71 microsegundos para
	call	Retardo_20micros	; ajustar a 50 milisegundos exactos.
	nop
  	movlw	TMR0_Carga50ms		; Carga el Timer 0.
	movwf	TMR0
	call	IncrementaRegistro50ms
	btfss	STATUS,C		; ¿C=1?, ¿Ha pasado medio segundo?
	goto	FinReloj		; No. Pues sale sin visualizar el reloj.
	movlw	b'11111111'		; Conmuta el flag F_Intermitencia cada 500 ms.
	xorwf	Intermitencia,F
ActualizaReloj
	call	VisualizaReloj		; Visualiza el reloj.
FinReloj
	return

; Subrutina "VisualizaReloj" ------------------------------------------------------------
;
; Visualiza el reloj en la segunda línea en formato: " 0:00:00".
; Cuando se ajusta una variable, ésta debe aparecer en intermitencia. Ello se logra con
; ayuda del flag F_Intermitencia que conmuta cada 500 ms en la subrutina Reloj.
;
VisualizaReloj
	movlw	.4			; Se coloca para centrar visualización
	call	LCD_PosicionLinea2	; en la segunda línea.
	btfss	F_AjusteHora		; ¿Está en la puesta en hora?.
	goto	EnciendeHoras		; No. Visualización normal.
	btfss	F_Intermitencia		; Sí. Intermitencia, si procede.
	goto	ApagaHoras		; Apaga las horas en la intermitencia.
EnciendeHoras
	movf	Hora,W			; Va a visualizar las horas. 
	call	BIN_a_BCD		; Lo pasa a BCD.
	call	LCD_Byte		; Visualiza rechazando el cero de las decenas.
	goto	VisualizaMinutos
ApagaHoras
	call	LCD_DosEspaciosBlancos	; Visualiza dos espacios en blanco.
;
VisualizaMinutos
	movlw	':'			; Envía ":" para separar datos.
	call	LCD_Caracter
	btfss	F_AjusteMinuto		; ¿Está en la puesta en hora?
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

; Subrutina "IncrementaRegistro50ms" ----------------------------------------------------
;
; Incrementa el valor de la variable Registro50ms. Cuando llega a 10, lo cual supone 
; medio segundo (50 ms x 10 = 500 ms), lo resetea y sale con el Carry a "1".
;
IncrementaRegistro50ms
	incf	Registro50ms,F
	movlw	.10
	subwf	Registro50ms,W		; (W)=(Registro50ms)-10
	btfsc	STATUS,C		; ¿C=0?, ¿(W) negativo?, ¿(Registro50ms)<10?
	clrf	Registro50ms		; Lo inicializa si ha superado su valor máximo.
	return

	INCLUDE  <RETARDOS.INC>
	INCLUDE  <LCD_4BIT.INC>
	INCLUDE  <BIN_BCD.INC>
	END

;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
