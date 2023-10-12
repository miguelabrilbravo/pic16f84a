;************************************** Timer0_02.asm ***********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Por la línea 3 del puerto B se genera una onda cuadrada de 1 kHz, por tanto, cada
; semiperiodo dura 500 µs. Los tiempos de temporización se consiguen mediante la
; utilización del Timer 0 del PIC.
;
; A la línea de salida se puede conectar un altavoz, tal como se indica en el esquema
; correspondiente, con lo que se escuchará un pitido.

; El cálculo de la carga del TMR0 se hará de forma simple despreciando el tiempo que 
; tardan en ejecutarse las instrucciones.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK	0x0C
	ENDC

#DEFINE		Salida	PORTB,3

; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0
Inicio
	bsf	STATUS,RP0		; Acceso al Banco 1.
	bcf	Salida			; Esta línea se configura como salida.
	movlw	b'00000000'
	movwf	OPTION_REG		; Prescaler de 2 asignado al TMR0
	bcf	STATUS,RP0		; Acceso al Banco 0.
Principal
	bsf	Salida			; La salida pasa a nivel alto
	call	Timer0_500us		; durante este tiempo.
	bcf	Salida			; La salida pasa a nivel bajo
	call	Timer0_500us		; durante este tiempo.
	goto 	Principal

; Subrutina "Timer0_500us" -------------------------------------------------------
;
; Como el PIC trabaja a una frecuencia de 4 MHz, el TMR0 evoluciona cada microsegundo.
; Para conseguir un retardo de 500 µs con un prescaler de 2 el TMR0 debe contar 250
; impulsos. Efectivamente: 1 µs x 250 x 2 = 500 µs.
;
; Comprobando con la ventana Stopwatch" del simulador se obtienen unos tiempos para la onda
; cuadrada de 511 µs para el nivel alto y 513 µs para el bajo.
;
TMR0_Carga500us	EQU	d'256'-d'250'

Timer0_500us
	movlw	TMR0_Carga500us		; Carga el Timer 0.
	movwf	TMR0
	bcf	INTCON,T0IF		; Resetea el flag de desbordamiento del TMR0. 
Timer0_Rebosamiento
	btfss	INTCON,T0IF		; ¿Se ha producido desbordamiento?
	goto	Timer0_Rebosamiento	; Todavía no. Repite.
	return

; Comprobando con la ventana Stopwatch del simulador se obtienen unos tiempos para la onda
; cuadrada de 511 µs para el nivel alto y 513 µs para el bajo.

	END
	
;	====================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS".
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	====================================================================
