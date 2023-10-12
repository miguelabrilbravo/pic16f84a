;*********************************** MotorDC_02.asm ***********************************
; 
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Programa de regulación de velocidad de un motor de corriente continua mediante la modulación
; de anchura de pulso (PWM). Por la línea de salida se genera una onda cuadrada de frecuencia
; constante a 100 Hz (periodo de 10 ms) y ciclo de trabajo variable desde 0% a 100%, dependiendo
; del valor de la entrada del Puerto A. Es decir, el tiempo en alto varía entre  0 ms (0%) y 10
; ms (100%)  de acuerdo con la siguiente tabla:
;					   (Ciclos_ON)		   (Ciclos_OFF)	
; 	Entrada		DC (%)		SEMIPERIODO ALTO	  SEMIPERIODO BAJO
; 	---------	-------		------------------	-------------------
; 	   0	 	  0 %	   	 0 ms =  0 x 1 ms	10 ms = 10 x 1 ms
; 	   1	  	 10 %	  	 1 ms =  1 x 1 ms	 9 ms =  9 x 1 ms
; 	   2	  	 20 %	  	 2 ms =  2 x 1 ms	 8 ms =  8 x 1 ms
; 	   3	  	 30 %	  	 3 ms =  3 x 1 ms	 7 ms =  7 x 1 ms
; 	   4		 40 %	 	 4 ms =  4 x 1 ms	 6 ms =  6 x 1 ms
; 	   5		 50 %	 	 5 ms =  5 x 1 ms	 5 ms =  5 x 1 ms
; 	   6		 60 %	 	 6 ms =  6 x 1 ms	 4 ms =  4 x 1 ms
; 	   7	 	 70 %		 7 ms =  7 x 1 ms	 3 ms =  3 x 1 ms
;	   8		 80 %		 8 ms =  8 x 1 ms	 2 ms =  2 x 1 ms
;	   9		 90 %		 9 ms =  9 x 1 ms	 1 ms =  1 x 1 ms
;	  10		100 %		10 ms = 10 x 1 ms	 0 ms =  0 x 1 ms
;	 >10		  0 %
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	Ciclos_ON
	Ciclos_OFF
	GuardaEntrada
	ENDC

MaximaEntrada	EQU	.10

; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0
Inicio
	bsf	STATUS,RP0
	movlw	b'00001111'		; RA3:RA0 como entradas.
	movwf	TRISA
	clrf	TRISB			; Las líneas del Puerto B se configuran como salidas.
	bcf	STATUS,RP0
Principal
	movf	PORTA,W		; Lee el puerto de entrada.
	andlw	b'00001111'
	movwf	GuardaEntrada		; Guarda el valor.
	btfsc	STATUS,Z		; Si RA3:RA0=0 el motor se detiene.
	goto	DC_CeroPorCiento
	sublw	MaximaEntrada		; (W)=10-(PORTA)
	btfsc	STATUS,Z
	goto	DC_100PorCiento	
	btfss	STATUS,C		; ¿C=1?, ¿(W) positivo?, ¿(PORTA)<=10?
	goto	DC_CeroPorCiento		; Ha resultado (PORTA>10)
	movwf	Ciclos_OFF		; 10-(PORTA)-->(Ciclos_OFF).
	movf	GuardaEntrada,W
	movwf	Ciclos_ON		; Carga RA3:RA0 en (Ciclos_ON).
Motor_ON
	movlw	b'00010010'		; Habilita los drivers y un sentido de giro.
	movwf	PORTB
	call	Retardo_1ms
	decfsz	Ciclos_ON,F		; Si (Ciclos_ON)=0 salta a Motor_OFF.
	goto	Motor_ON+2
Motor_OFF
	clrf	PORTB			; Inhabilita los drivers. Motor parado.
	call	Retardo_1ms
	decfsz	Ciclos_OFF,F		; Si (Ciclos_OFF)=0 salta a Principal.
	goto	Motor_OFF+1
	goto	Fin
DC_CeroPorCiento
	clrf	PORTB			; Inhabilita los drivers. Motor parado.
	goto	Fin
DC_100PorCiento
	movlw	b'00010010'		; Habilita los drivers y un sentido de giro.
	movwf	PORTB
Fin	goto	Principal

	INCLUDE  <RETARDOS.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
