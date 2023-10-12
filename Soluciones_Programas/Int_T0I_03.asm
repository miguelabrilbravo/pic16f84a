;************************************ Int_T0I_03.asm ************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Un LED conectado a la línea 1 del puerto de salida se enciende durante 500 ms y apaga
; durante otros 500 ms. Los tiempos de temporización se realiza mediante la  utilización
; de la interrrupción por desbordamiento del Timer 0 del PIC.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	Registro50ms			; Registro auxiliar para conseguir una temporización
	ENDC				; mayor.

Carga500ms	EQU	d'10'
TMR0_Carga50ms	EQU	-d'195'
#DEFINE		LED	PORTB,1

; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0			; El programa comienza en la dirección 0.
	goto	Inicio
	ORG	4			; Vector de interrupción
	goto	Timer0_Interrupcion
Inicio
	bsf	STATUS,RP0		; Acceso al Banco 1.
	bcf	LED			; Línea del LED configurada como salida.
	movlw	b'00000111'
	movwf	OPTION_REG		; Prescaler de 256 para el TMR0
	bcf	STATUS,RP0		; Acceso al Banco 0.
	movlw	TMR0_Carga50ms		; Carga el TMR0.
	movwf	TMR0
	movlw	Carga500ms
	movwf	Registro50ms
	movlw	b'10100000'
	movwf	INTCON			; Activa interrupción del TMR0 (TOIE) y la general.
Principal				; No se puede utilizar el modo bajo consumo
	goto	$			; porque el timer se detiene.

; Subrutina "Timer0_Interrupcion" -------------------------------------------------------
;
; Como el PIC trabaja a una frecuencia de 4MHz, el TMR0 evoluciona cada microsegundo.
; El bucle central se hace en un tiempo de 50 ms. Para ello se utiliza un prescaler
; de 256 y el TMR0 tiene que contar 195 impulsos. Efectivamente:
; 195 x 256 = 49929 µs = 50 ms aproximadamente. 

; Para conseguir una temporización de 500 ms, habrá que repetir 10 veces el lazo de 50 ms.

Timer0_Interrupcion
	movlw	TMR0_Carga50ms
	movwf	TMR0			; Recarga el TMR0.
	decfsz	Registro50ms,F		; Decrementa el contador.
	goto	FinInterrupcion
	movlw	Carga500ms
	movwf	Registro50ms		; Repone el contador nuevamente 
	btfsc	LED			; Testea el último estado del LED.
	goto	EstabaEncendido	
EstabaApagado
	bsf	LED			; Estaba apagado y lo enciende.
	goto	FinInterrupcion
EstabaEncendido
	bcf	LED			; Estaba encendido y lo apaga.
FinInterrupcion
	bcf	INTCON,T0IF		; Repone flag del TMR0.
	retfie

; Con el simulador del MPLAB se comprueba que los tiempos son: En alto 499261 µs y en
; bajo 499258 µs. 

	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
