;*********************************** Int_Reloj_02.asm ***********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Este es el programa para un reloj digital en cuanto al ajuste manual de las horas,
; es decir, sólo se van a ajustar las horas, el resto del reloj digital no va a funcionar.
;
; Esto se va a realizar mediante el pulsador "INCREMENTAR" que se conecta al pin RB6 a
; través de una resistencia de 330 ohmios.
;
; El reloj se visualiza en un formato: " 8:00:00", donde los minutos y segundos siempre
; valdrán cero y el dígito de las horas se mantendrá intermitente. Cada vez que se pulse
; INCREMENTAR, el dígito de la horas se incrementará.
;
; Las temporizaciones necesarias del reloj se logran mediante el Timer 0, que produce una
; interrupción cada 50 ms. Con esto se consigue el tiempo base necesario para la intermitencia.
;
; La intermitencia utiliza el flag F_Intermitencia. Cuando está en "1", la visualización es
; normal. Cuando es (F_Intermitencia)=0, apaga el dígito correspondiente. Conmuta cada 500 ms.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	Hora				; Guarda las horas.
	Minuto				; Guarda los minutos.
	Segundo				; Guarda los segundos.
	Registro50ms			; Se incrementa cada 50ms
	Intermitencia			; Para lograr la intermitencia.
	ENDC
;
#DEFINE  IncrementarPulsador  PORTB,6
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
	bsf	IncrementarPulsador	; Configurado como entrada.
	bcf	STATUS,RP0		; Acceso al Banco 0.
	clrf	Hora			; Inicializa todos los datos del reloj. 
	clrf	Minuto
	clrf	Segundo	
	clrf	Registro50ms	
	movlw	TMR0_Carga50ms		; Carga el TMR0.
	movwf	TMR0		
	movlw	b'10101000'		; Activa interrupción TMR0 (TOIE), por cambio
	movwf	INTCON			; líneas del Puerto B (RBIE) y la general (GIE).
	
; La sección "Principal" es de mantenimiento. Sólo espera las interrupciones.
; No se puede poner en modo de bajo consumo porque la instrucción "sleep" detiene el Timer 0.

Principal
	goto	Principal

; Subrutina "ServicioInterrupcion" ------------------------------------------------------
;
; Detecta qué ha producido la interrupción y ejecuta la subrutina de atención correspondiente.

ServicioInterrupcion
	btfsc	INTCON,T0IF		; Si es una interrupción procedente del
	call	Reloj			; desbordamiento del Timer 0 actualiza el reloj.
	btfss	INTCON,RBIF		; Si es una interrupción RBI, lee los pulsadores.
	goto	FinInterrupcion
	btfss	IncrementarPulsador	; ¿Pulsado "INCREMENTAR"?
	call	Incrementar		; Sí, pasa a incrementar el registro de tiempo
FinInterrupcion				; correspondiente.
	bcf	INTCON,RBIF
	bcf	INTCON,T0IF
	retfie

; Subrutina "Reloj" ---------------------------------------------------------------------
;
; Esta subrutina actualiza los contadores MedioSegundo y Registro50ms. Se ejecuta debido a la
; petición de interrupción del Timer 0 cada 50 ms exactos, tal como se comprueba
; experimentalmente con la ventana Stopwatch del simulador del MPLAB.

Reloj	call	Retardo_50micros	; Retardo de 71 µs para
	call	Retardo_20micros	; ajustar a 50 ms exactos.
	nop
  	movlw	TMR0_Carga50ms		; Carga el Timer 0.
	movwf	TMR0
	call	IncrementaRegistro50ms
	btfss	STATUS,C		; ¿Ha contado 10 veces 50 ms = 1/2 segundo?
	goto	FinReloj		; No. Pues sale sin visualizar el reloj.

; Ahora conmuta el flag de intermitencia.
;
	movlw	b'11111111'		; Conmuta el flag F_Intermitencia.
	xorwf	Intermitencia,F
	call	VisualizaReloj		; Visualiza el reloj.
FinReloj
	return

; Subrutina "VisualizaReloj" ------------------------------------------------------------
;
; Visualiza el reloj en la segunda línea en formato: " 8:00:00" (Segunda Línea).
; Cuando ajusta una variable ésta debe aparecer en intermitencia. Utiliza el flag
; F_Intermitencia que conmuta cada 500 ms en la subrutina Reloj.
;
VisualizaReloj
	movlw	.4			; Para centrar visualización
	call	LCD_PosicionLinea2	; en la segunda línea.
	btfss	F_Intermitencia		; Intermitencia si procede.
	goto	ApagaHoras		; Apaga las horas en la intermitencia.
EnciendeHoras
	movf	Hora,W			; Va a visualizar las horas. 
	call	BIN_a_BCD		; Lo pasa a BCD.
	call	LCD_Byte		; Visualiza rechazando el cero de las decenas.
	goto	VisualizaMinutos
ApagaHoras
	call	LCD_DosEspaciosBlancos	; Visualiza dos espacios en blanco.
VisualizaMinutos
	movlw	':'			; Envía ":" para separar datos.
	call	LCD_Caracter
	movf	Minuto,W		; Visualiza minutos.
	call	BIN_a_BCD		; Lo pasa a BCD.
	call	LCD_ByteCompleto
	movlw	':'			; Envía ":" para separar datos.
	call	LCD_Caracter
	movf	Segundo,W		; Visualiza segundos.
	call	BIN_a_BCD		; Lo pasa a BCD.
	call	LCD_ByteCompleto
	return
;
; Subrutina "Incrementar" ---------------------------------------------------------------
;
; Subrutina de atención a la interrupción por cambio de la línea RB6 el cual se ha
; conectado el pulsador "INCREMENTAR". Incrementa la variable Hora.

Incrementar
	call	Retardo_20ms		; Si es un rebote sale.
	btfsc	IncrementarPulsador
	goto	FinIncrementar
	bsf	F_Intermitencia		; Visualiza siempre mientras incrementa.
	call	IncrementaHoras
	call	VisualizaReloj		; Visualiza mientras espera que deje
	call	Retardo_200ms		; de pulsar.
	btfss	IncrementarPulsador	; Mientras permanezca pulsado,
	goto	Incrementar		; incrementará el dígito.
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
	subwf	Registro50ms,W		; (W)=(Registro50ms)-10
	btfsc	STATUS,C		; ¿C=0?, ¿(W) negativo?, ¿(Registro50ms)<10?
	clrf	Registro50ms		; Lo inicializa si ha superado su valor máximo.
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
	INCLUDE  <RETARDOS.INC>
	INCLUDE  <LCD_4BIT.INC>
	INCLUDE  <BIN_BCD.INC>
	END

;	====================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS".
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	====================================================================
