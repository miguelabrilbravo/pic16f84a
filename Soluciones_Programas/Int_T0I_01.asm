;************************************ Int_T0I_01.asm ************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Por la l�nea 3 del puerto B se genera una onda cuadrada de 10 kHz, cada semiperiodo dura
; 50 �s. Los tiempos de temporizaci�n se lograr�n mediante la interrupci�n por desbordamiento
; del Timer 0. A la l�nea de salida se puede conectar un altavoz que producir� un pitido.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	ENDC

TMR0_Carga50us	EQU	-d'50'
#DEFINE		Salida	PORTB,3

; ZONA DE C�DIGOS ********************************************************************

	ORG 	0
	goto	Inicio
	ORG	4			; Vector de interrupci�n.
	goto	Timer0_Interrupcion
Inicio
	bsf	STATUS,RP0		; Acceso al Banco 1.
	bcf	Salida			; L�nea configurada como salida.
	movlw	b'00001000'
	movwf	OPTION_REG		; Sin prescaler para TMR0 (se asigna al Watchdog).
	bcf	STATUS,RP0		; Acceso al Banco 0.
	movlw	TMR0_Carga50us		; Carga el TMR0.
	movwf	TMR0
	movlw	b'10100000'
	movwf	INTCON			; Autoriza interrupci�n T0I y la general (GIE).
Principal					; No puede pasar a modo de bajo consumo
	goto 	$			; porque detendr�a el Timer 0.

; Subrutina "Timer0_Interrupcion" -------------------------------------------------------
;
; Como el PIC trabaja a una frecuencia de 4 MHz el TMR0 evoluciona cada microsegundo. Para
; conseguir un retardo de 50 �s con un prescaler de 1 el TMR0 tiene que contar 50 impulsos.
; Efectivamente: 1 �s x 50 x 1 = 50 �s.
;
Timer0_Interrupcion
	movlw 	TMR0_Carga50us
	movwf 	TMR0			; Recarga el timer TMR0.
	btfsc 	Salida			; Testea el anterior estado de la salida.
	goto 	EstabaAlto
EstabaBajo
	bsf	Salida			; Estaba bajo y lo pasa a alto.
	goto 	FinInterrupcion
EstabaAlto
	bcf 	Salida			; Estaba alto y lo pasa a bajo.
FinInterrupcion
	bcf	INTCON,T0IF		; Repone flag del TMR0.
	retfie

; Comprobando con el simulador del MPLAB se obtienen unos tiempos para la onda cuadrada de 
; 56 �s para el nivel alto y de 55 �s para el bajo.

	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
