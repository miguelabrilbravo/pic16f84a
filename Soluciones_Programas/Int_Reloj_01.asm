;*********************************** Int_Reloj_01.asm ***********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Programa para un reloj digital en tiempo real sin puesta en hora. Visualiza en un formato:
; " 8:47:39" (Segunda L�nea).
;
; Las temporizaciones necesarias del reloj se logran mediante interrupciones por desbordamiento
; del Timer 0 cada 50 ms. Tambi�n actualiza un contador llamado MedioSegundo incrementado cada
; 500 ms y que ser� utilizado en las intermitencias de posteriores programas.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	Hora				; Guarda las horas.
	Minuto				; Guarda los minutos.	
	Segundo				; Guarda los segundos.
	MedioSegundo			; Se incrementa cada medio segundo.
	Registro50ms			; Se incrementa cada 50ms.
	ENDC
;
TMR0_Carga50ms	EQU	-d'195'		; Para conseguir la interrupci�n del
					; Timer 0 cada 50 ms.
; ZONA DE C�DIGOS ********************************************************************

	ORG 	0
	goto	Inicio
	ORG	4
	goto	ServicioInterrupcion

Inicio	call	LCD_Inicializa
	bsf	STATUS,RP0		; Acceso al Banco 1.
	movlw	b'00000111'		; Prescaler de 256 para el TMR0 y habilita
	movwf	OPTION_REG		; resistencias de Pull-Up del Puerto B.
	bcf	STATUS,RP0		; Acceso al Banco 0.
	clrf	Hora			; Inicializa todos los datos del reloj. 
	clrf	Minuto
	clrf	Segundo
	clrf	MedioSegundo
	clrf	Registro50ms
	movlw	TMR0_Carga50ms		; Carga el TMR0.
	movwf	TMR0		
	movlw	b'10100000'		; Activa interrupci�n del TMR0 (TOIE)
	movwf	INTCON			; y la general (GIE).
	
; La secci�n "Principal" es de mantenimiento. S�lo espera las interrupciones.
; No se puede poner en modo de bajo consumo porque la instrucci�n "sleep" detiene el Timer 0.

Principal
	goto	Principal

; Subrutina "ServicioInterrupcion" ------------------------------------------------------
;
ServicioInterrupcion
	btfsc	INTCON,T0IF		; Si es una interrupci�n procedente del
	call	Reloj			; desbordamiento del Timer 0, actualiza el reloj.
FinInterrupcion				; correspondiente.
	bcf	INTCON,T0IF
	retfie

; Subrutina "Reloj" ---------------------------------------------------------------------
;
; Esta subrutina actualiza los contadores Horas, Minutos, Segundos, MedioSegundo y Registro50ms.
; Se ejecuta debido a la petici�n de interrupci�n del Timer 0, cada 50 ms.
;
; Como el PIC trabaja a una frecuencia de 4 MHz, el TMR0 evoluciona cada �s y se desborda cada
; 195 x 256 = 49920 �. Sum�dole el retardo de 71 �s y el peque�o tiempo de los saltos iniciales
; y de carga del contador, resulta un total de 50000 �s exactos. Es decir, el TMR0 producir�
; una interrupci�n cada 50 ms exactos, comprobado experimentalmente con la ventana Stopwatch del
; simulador del MPLAB.

Reloj	call	Retardo_50micros	; Retardo de 71 �s para
	call	Retardo_20micros	; ajustar a 50 ms exactos.
	nop
  	movlw	TMR0_Carga50ms		; Carga el timer 0.
  	movwf	TMR0
	call	IncrementaRegistro50ms
	btfss	STATUS,C		; �Ha contado 10 veces 50 ms = 1/2 segundo?
	goto	FinReloj		; No. Pues sale sin visualizar el reloj.
IncrementaReloj
	call	IncrementaMedioSegundo
	btfss	STATUS,C		; �Ha pasado 1 segundo?
	goto	ActualizaReloj		; No. Pues sale visualizando el reloj.
	call	IncrementaSegundos	; S�. Incrementa el segundero.
	btfss	STATUS,C		; �Han pasado 60 segundos?
	goto	ActualizaReloj		; No. Pues sale visualizando el reloj.
	call	IncrementaMinutos	; S�. Incrementa el minutero.
	btfss	STATUS,C		; �Han pasado 60 minutos?
	goto	ActualizaReloj		; No. Pues sale visualizando el reloj.
	call	IncrementaHoras		; S�. Incrementa las horas.
ActualizaReloj
	call	VisualizaReloj		; Visualiza el reloj.
FinReloj
	return

; Subrutina "VisualizaReloj" ------------------------------------------------------------
;
; Visualiza el reloj en la segunda l�nea en formato: " 8:47:39" (Segunda L�nea).
;
VisualizaReloj
	movlw	.4			; Se coloca para centrar la visualizaci�n
	call	LCD_PosicionLinea2	; en la segunda l�nea.
	movf	Hora,W			; Va a visualizar las horas. 
	call	BIN_a_BCD		; Lo pasa a BCD.
	call	LCD_Byte		; Visualiza rechazando el cero de las decenas.
	movlw	':'			; Env�a ":" para separar datos.
	call	LCD_Caracter
	movf	Minuto,W		; Visualiza minutos.
	call	BIN_a_BCD		; Lo pasa a BCD.
	call	LCD_ByteCompleto
	movlw	':'			; Env�a ":" para separar datos.
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
	btfsc	STATUS,C		; �C=0?, �(W) negativo?, �(Registro50ms)<10?
	clrf	Registro50ms		; Lo inicializa si ha superado su valor m�ximo.
	return

; Subrutina "IncrementaMedioSegundo" --------------------------------------------------------
;
; Incrementa el valor de la variable MedioSegundo. Su bit de menor peso se pondr� a "1" una
; vez por segundo.

IncrementaMedioSegundo
	incf	MedioSegundo,F		; Incrementa.
	bsf	STATUS,C		; Supone que ha llegado al segundo.
	btfss	MedioSegundo,0		; El bit 0 se pondr� a "1" cada segundo.
	bcf	STATUS,C
	return

; Subrutina "IncrementaSegundos" -----------------------------------------------------------
;
; Incrementa el valor de la variable Segundos. Si es igual al valor m�ximo de 60 lo resetea
; y sale con el Carry a "1".

IncrementaSegundos
	incf	Segundo,F		; Incrementa los segundos.
	movlw	.60
	subwf	Segundo,W		; �Ha superado valor m�ximo?. (W)=(Segundo)-60.
	btfsc	STATUS,C		; �C=0?, �(W) negativo?, �(Segundo)<60?
	clrf	Segundo			; Lo inicializa si ha superado su valor m�ximo.
	return

; Subrutina "IncrementaMinutos" -----------------------------------------------------------
;
; Incrementa el valor de la variable Minuto. Si es igual al valor m�ximo de 60 lo resetea
; y sale con el Carry a "1".
;
IncrementaMinutos
	incf	Minuto,F		; Incrementa los minutos.
	movlw	.60
	subwf	Minuto,W		; �Ha superado su valor m�ximo?. (W)=(Minuto)-60.
	btfsc	STATUS,C		; �C=0?, �(W) negativo?, �(Minuto)<60?
	clrf	Minuto			; Lo inicializa si ha superado su valor m�ximo.
	return

; Subrutina "IncrementaHoras" -----------------------------------------------------------
;
; Incrementa el valor de la variable Hora. Si es igual al valor m�ximo de 24 lo resetea
; y sale con el Carry a "1".
;
IncrementaHoras
	incf	Hora,F			; Incrementa las horas.
	movlw	.24
	subwf	Hora,W			; �Ha superado su valor m�ximo?. (W)=(Hora)-24.
	btfsc	STATUS,C		; �C=0?, �(W) negativo?, �(Hora)<24?
	clrf	Hora			; Lo inicializa si ha superado su valor m�ximo.
	return
;
	INCLUDE  <RETARDOS.INC>
	INCLUDE  <LCD_4BIT.INC>
	INCLUDE  <BIN_BCD.INC>
	END
	
;	====================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS".
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	====================================================================
