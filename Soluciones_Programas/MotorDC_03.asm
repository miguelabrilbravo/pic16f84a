;*********************************** MotorDC_03.asm ***********************************
; 
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Programa de control de velocidad de un motor de corriente continua mediante la modulación
; de anchura de pulso (PWM) similar al MotorDC_02.asm donde el control de tiempos se realiza
; mediante interrupciones por desbordamiento del Timer 0.
;
; El sentido de giro del motor se decide en función del valor de la línea RA4.
;
; El control de las lineas de salida se realizará mediante direccionamiento por bit con 
; las instrucciones "bsf" y "bcf".
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	CicloTrabajo			; Ciclo de trabajo deseado.
	GuardaEntrada
	Timer0_ContadorA			; Contador auxiliar.
	ENDC

TMR0_Carga	EQU	-d'245'		; Valor obtenido experimentalmente con la ventana
					; Stopwatch para un tiempo de 1 ms.
MaximaEntrada	EQU	.10

#DEFINE  SalidaSentido0	PORTB,0		; Salidas que determinan el sentido de giro.
#DEFINE  SalidaSentido1	PORTB,1
#DEFINE  SalidaMarcha	PORTB,4		; Salida  de puesta en marcha o paro del motor.
#DEFINE  EntradaSentido	PORTA,4		; Interruptor de sentido de giro.

; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0
 	goto	Inicio
	ORG	.4
	goto	Timer0_Interrupcion

Inicio
	bsf	STATUS,RP0
	bcf	SalidaMarcha		; Estas líneas se configuran como salida.
	bcf	SalidaSentido0
	bcf	SalidaSentido1
	movlw	b'00011111'		; Puerto A configurado como entrada.
	movwf	PORTA
	movlw	b'00000001'		; TMR0 con prescaler de 4.
	movwf	OPTION_REG
	bcf	STATUS,RP0
	bcf	SalidaMarcha		; Al principio el motor parado.
Principal
	btfsc	EntradaSentido		; Comprueba el sentido de giro deseado.
	goto	OtroSentido
	bsf	SalidaSentido0		; Gira en un sentido.
	bcf	SalidaSentido1	
	goto	TesteaVelocidad
OtroSentido
	bcf	SalidaSentido0		; Gira en el sentido opuesto.
	bsf	SalidaSentido1
TesteaVelocidad
	movf	PORTA,W		; Lee el puerto de entrada
	andlw	b'00001111'
	movwf	GuardaEntrada		; Guarda el valor.
	btfsc	STATUS,Z		
	goto	DC_CeroPorCiento
	sublw	MaximaEntrada		; (W)=10-(PORTA)
	btfsc	STATUS,Z
	goto	DC_100PorCiento	
	btfss	STATUS,C		; ¿C=1?, ¿(W) positivo?, ¿(PORTA)<=10?
	goto	DC_CeroPorCiento		; Ha resultado PORTA>10.
	movf	GuardaEntrada,W
	movwf	CicloTrabajo
	movlw	b'10100000'
	movwf	INTCON			; Autoriza interrupción T0I y la general (GIE).
	goto	Fin
DC_CeroPorCiento
	bcf	SalidaMarcha		; Pone la salida siempre en bajo.
	goto	InhabilitaInterrupcion
DC_100PorCiento
	bsf	SalidaMarcha		; Pone la salida siempre en alto.
InhabilitaInterrupcion
	clrf	INTCON			; Inhabilita interrupciones.
Fin	goto	Principal

; Subrutina "Timer0_Interrupcion" -------------------------------------------------------
;
; Mantiene la salida en alto un tiempo igual a 1 ms x (CicloTrabajo)
; y en bajo un tiempo igual a 1 ms x (10-CicloTrabajo).
;
	CBLOCK	
	Guarda_W
	Guarda_STATUS
	ENDC

Timer0_Interrupcion
	movwf	Guarda_W		; Guarda los valores de tenían W y STATUS en el
	swapf	STATUS,W		; programa principal.
	movwf	Guarda_STATUS
	bcf	STATUS,RP0		; Garantiza que trabaja en el Banco 0.
	movlw 	TMR0_Carga
	movwf 	TMR0
	decfsz 	Timer0_ContadorA,F	; Decrementa el contador.
	goto 	Fin_Timer0_Interrupcion
	btfsc 	SalidaMarcha		; Testea el anterior estado de la salida.
	goto 	EstabaAlto
EstabaBajo
	bsf	SalidaMarcha		; Estaba bajo y lo pasa a alto.
	movf	CicloTrabajo,W		; Repone el contador nuevamente con el tiempo en 
	movwf 	Timer0_ContadorA		; alto.
	goto 	Fin_Timer0_Interrupcion
EstabaAlto
	bcf 	SalidaMarcha		; Estaba alto y lo pasa a bajo.
	movf	CicloTrabajo,W		; Repone el contador nuevamente con el tiempo
	sublw	.10			; en bajo.
	movwf 	Timer0_ContadorA
Fin_Timer0_Interrupcion
	swapf	Guarda_STATUS,W	; Restaura registros W y STATUS.
	movwf	STATUS
	swapf	Guarda_W,F
	swapf	Guarda_W,W
	bcf	INTCON,RBIF
	bcf	INTCON,T0IF
	retfie

	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================

