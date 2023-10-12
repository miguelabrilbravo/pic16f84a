;************************************ Int_T0I_04.asm ************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Un LED conectado a la l�nea 1 del puerto de salida se enciende durante 800 ms y apaga
; durante otros 500 ms. Los tiempos de temporizaci�n se realizar�n mediante la utilizaci�n
; de la interrupci�n por desbordamiento del Timer 0 del PIC.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	Registro50ms			; Registro auxiliar para conseguir una
	ENDC				; temporizaci�n mayor.

Carga500ms	EQU	d'10'
Carga800ms	EQU	d'16'
TMR0_Carga50ms	EQU	-d'195'
#DEFINE		LED	PORTB,1

; ZONA DE C�DIGOS ********************************************************************

	ORG 	0
	goto	Inicio
	ORG	4			; Vector de interrupci�n.
	goto	Timer0_Interrupcion
Inicio
	bsf	STATUS,RP0		; Acceso al Banco 1.
	bcf	LED			; L�nea del LED configurada como salida.
	movlw	b'00000111'
	movwf	OPTION_REG		; Prescaler de 256 asignado al TMR0
	bcf	STATUS,RP0		; Acceso al Banco 0.
	movlw	TMR0_Carga50ms		; Carga el TMR0.
	movwf	TMR0
	movlw	Carga500ms
	movwf	Registro50ms
	movlw	b'10100000'
	movwf	INTCON			; Autoriza interrupci�n del TMR0 (T0IE) y la GIE.
Principal					; No puede pasar a modo bajo consumo porque
	goto	$			; el Timer 0 se detendr�a.

; Subrutina "Timer0_Interrupcion" -------------------------------------------------------
;
; Como el PIC trabaja a una frecuencia de 4 MHz el TMR0 evoluciona cada microsegundo.
; El bucle central se hace en un tiempo de 50 ms. Para ello se utiliza un prescaler
; de 256 y el TMR0 tiene que contar 195. Efectivamente 195 x 256 = 49929 �s = 50 ms.
; Para conseguir una temporizaci�n de 500 ms habr� que repetir 10 veces el lazo de 50 ms.
; Para conseguir una temporizaci�n de 800 ms habr� que repetir 16 veces el lazo de 50 ms.

Timer0_Interrupcion
	movlw	TMR0_Carga50ms
	movwf	TMR0			; Recarga el TMR0.
	decfsz	Registro50ms,F		; Decrementa el contador.
	goto	FinInterrupcion
	btfsc	LED			; Testea el �ltimo estado del LED.
	goto	EstabaEncendido	
EstabaApagado
	bsf	LED			; Estaba apagado y lo enciende.	
	movlw	Carga800ms		; Repone el contador nuevamente para que est�
	goto	CargaRegistro50ms		; 800 ms encendido.
EstabaEncendido
	bcf	LED			; Estaba encendido y lo apaga.
	movlw	Carga500ms		; Repone el contador nuevamente para que est�
CargaRegistro50ms				; 500 ms apagado.
	movwf	Registro50ms
FinInterrupcion
	bcf	INTCON,T0IF		; Repone flag del TMR0.
	retfie				; Retorno de interrupci�n.

	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
