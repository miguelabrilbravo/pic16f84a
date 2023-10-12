;******************************** Int_Cuadradas_02.asm **********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; A la línea de salida se conecta un altavoz que produce el sonido de una sirena que será fijado
; por el diseñador. En esta solución la frecuencia es de 300 Hz, subiendo hasta 4 kHz y bajando
; después, más lentamente, a su valor inicial y repitiendo el proceso.

; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK 0x0C
	ApuntadorFrecuencia
	SentidoFrecuencia		; (SentidoFrecuencia)=0 (frecuencia ascendente).
	ENDC				; (SentidoFrecuencia)=1 (frecuencia descendente).

MaximoPeriodo	EQU	d'200'		; Corresponden a una frecuencia entre 300 Hz y 
MinimoPeriodo	EQU	d'15'		; 4 kHz tal como se demuestra posteriormente.
#DEFINE  Salida	PORTB,3

; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0
	goto	Inicio
	ORG	4
	goto	Timer0_Interrupcion
Inicio
	bsf	STATUS,RP0
	bcf	Salida
	movlw	b'00000010'		; Prescaler de 8 asignado al TMR0.
	movwf	OPTION_REG
	bcf	STATUS,RP0
	clrf	SentidoFrecuencia	; Inicializa el sentido de la variación de
	movlw	MaximoPeriodo		; frecuencia ascendente en la sirena.
	movwf	ApuntadorFrecuencia	; Inicializa a la frecuencia mínima.
	sublw	.0			; Carga en el Timero 0 con signo negativo.
	movwf	TMR0	
	movlw	b'10100000'
	movwf	INTCON			; Activa interrupción del TMR0 (TOIE).
Principal
	btfss	SentidoFrecuencia,0
	goto	FrecuenciaAscendente
FrecuenciaDescendente
	call	Retardo_20ms		; Mantiene la frecuencia durante este tiempo.
	incf	ApuntadorFrecuencia,F	; Aumenta el periodo, disminuye la frecuencia.
	movlw	MaximoPeriodo		; ¿Ha llegado a su máximo valor de periodo?
	subwf	ApuntadorFrecuencia,W	; (W)=(ApuntadorFrecuencia)-MaximoPeriodo
	btfsc	STATUS,C		; ¿C=0?,¿(W) negativo?, ¿(ApuntadorFrecuencia)<Maximo.
	clrf	SentidoFrecuencia	; No. La siguiente pasada entra en "FrecuenciaAscendente".
	goto	Fin
FrecuenciaAscendente
	call	Retardo_10ms		; Mantiene la frecuencia durante este tiempo.
	decf	ApuntadorFrecuencia,F	; Disminuye el periodo, aumenta la frecuencia.
	movlw	MinimoPeriodo		; ¿Ha llegado a su mínimo valor de periodo?
	subwf	ApuntadorFrecuencia,W	; (W)=(ApuntadorFrecuencia)-MinimoPeriodo
	btfss	STATUS,C		; ¿C=1?,¿(W) positivo?, ¿(ApuntadorFrecuencia)>=Minimo.
	incf	SentidoFrecuencia,F	; No. La siguiente pasada entra en "FrecuenciaDescendente".
Fin	goto 	Principal

; Subrutina "Timer0_Interrupcion" -------------------------------------------------------
;
; Con un prescaler de 8 el periodo variará según el valor de ApuntadorFrecuencia entre:
; - Para (ApuntadorFrecuencia)=15, frecuencia = 4 kHz.
;   (efectivamente 15 x 8 = 120 µs de semiperiodo que son 4 kHz aproximadamente).
; - Para (ApuntadorFrecuencia)=200, frecuencia = 300 Hz.
;   (efectivamente 200 x 8 = 1600 µs de semiperiodo que son 300 Hz aproximadamente).

	CBLOCK	
	Guarda_W
	Guarda_STATUS
	ENDC

Timer0_Interrupcion
	movwf	Guarda_W		; Guarda el valor de W y STATUS.
	swapf	STATUS,W
	movwf	Guarda_STATUS
	bcf	STATUS,RP0
	movf	ApuntadorFrecuencia,W
	sublw	.0			; Carga en el Timer 0 con signo negativo.
	movwf	TMR0
	btfsc	Salida
	goto	EstabaAlto
EstabaBajo
	bsf	Salida
	goto	Fin_Timer0_Interrupcion
EstabaAlto
	bcf	Salida
Fin_Timer0_Interrupcion
	swapf	Guarda_STATUS,W		; Restaura el valor de W y STATUS.
	movwf	STATUS
	swapf	Guarda_W,F
	swapf	Guarda_W,W
	bcf	INTCON,T0IF
	retfie
;
	INCLUDE  <RETARDOS.INC>
	END

;	====================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS".
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	====================================================================
