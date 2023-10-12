;************************************ Int_T0I_02.asm ************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Por la l�nea 3 del puerto B se genera una onda cuadrada de 10 kHz. Cada semiperiodo dura
; 50 �s exactos. Los tiempos de temporizaci�n se lograr�n mediante la interrupci�n del
; Timer 0. A la l�nea de salida se puede conectar un altavoz que producir� un pitido.
;
; El c�lculo de la carga del TMR0 se realiza teniendo en cuenta los tiempos que tardan en
; ejecutarse las instrucciones y saltos para conseguir tiempos exactos. Para calcular el valor
; de carga del TMR0 se ayuda del simulador del MPLAB y de la ventana de reloj Stopwatch.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	ENDC

TMR0_Carga50us	EQU	-d'43'		; Obtenido experimentalmente con ayuda del
#DEFINE  Salida	PORTB,3			; simulador del MPLAB.

; ZONA DE C�DIGOS ********************************************************************

	ORG 	0
	goto	Inicio
	ORG	4			; Vector de interrupci�n.
	goto	Timer0_Interrupcion
Inicio
	bsf	STATUS,RP0		; Acceso al Banco 1.
	bcf	Salida			; Esta l�nea se configura como salida.
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
; conseguir un retardo de 50 microsegundos con un prescaler de 1 el TMR0 tiene que contar 
; 43 impulsos. Efectivamente: 1�s x 1 x 43 + tiempo de los saltos y otros = 50 �s. 
;
; Las instrucciones "nop" se ponen para ajustar el tiempo a 50 �s exacto y lograr una onda
; cuadrada perfecta. El simulador del MPLAB comprueba unos tiempos para la onda cuadrada de
; 10 kHz exactos de 50 �s para el nivel alto y otros 50 �s para el bajo.

Timer0_Interrupcion
	nop
	movlw 	TMR0_Carga50us
	movwf 	TMR0			; Recarga el TMR0.
	btfsc 	Salida			; Testea el anterior estado de la salida.
	goto 	EstabaAlto
EstabaBajo
	nop
	bsf	Salida			; Estaba bajo y lo pasa a alto.
	goto 	FinInterrupcion
EstabaAlto
	bcf 	Salida			; Estaba alto y lo pasa a bajo.
FinInterrupcion
	bcf	INTCON,T0IF		; Repone flag del TMR0.
	retfie				; Retorno de interrupci�n

	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
