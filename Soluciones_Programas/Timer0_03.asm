;************************************** Timer0_03.asm ***********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Por la l�nea 3 del puerto B se genera una onda cuadrada de 1 kHz, por tanto, cada
; semiperiodo dura 500 �s. Los tiempos de temporizaci�n se consiguen mediante la
; utilizaci�n del Timer 0 del PIC.
;
; A esta l�nea de salida se puede conectar un altavoz, tal como se indica en el esquema
; correspondiente, con lo que se escuchar� un pitido.
;
; El c�lculo de la carga del TMR0 se har� de forma que se tenga en cuenta los tiempos de
; las instrucciones para conseguir tiempos exactos. Para calcular los valores de carga 
; del TMR0 hay que ayudarse del simulador del MPLAB y de la ventana de reloj Stopwatch.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK	0x0C
	ENDC

#DEFINE	 Salida	PORTB,3

; ZONA DE C�DIGOS ********************************************************************

	ORG 	0
Inicio
	bsf	STATUS,RP0		; Acceso al Banco 1.
	bcf	Salida			; Esta l�nea se configura como salida.
	movlw	b'00000000'
	movwf	OPTION_REG		; Prescaler de 2 para el TMR0
	bcf	STATUS,RP0		; Acceso al Banco 0.
Principal
	bsf	Salida			; La salida pasa a nivel alto
	call	Timer0_500us		; durante este tiempo.
	nop				; Dos ciclos mediante "nop" para compensar
	nop				; la instrucci�n "goto Principal" del nivel bajo.
	bcf	Salida			; La salida pasa a nivel bajo
	call	Timer0_500us		; durante este tiempo.
	goto 	Principal
;
; Subrutina "Timer0_500us" -------------------------------------------------------
;
; Con el simulador se comprueba que se obtienen unos tiempos para la onda cuadrada
; de 1kHz exactos, 500 �s tanto para el nivel alto como para el bajo.
;
TMR0_Carga500us	EQU	-d'242'		; Este valor se ha obtenido experimentalmente
					; con ayuda del simulador del MPLAB.
Timer0_500us
	nop				; Algunos "nop" para ajustar a 500 �s exactos.
	nop
	movlw	TMR0_Carga500us		; Carga el Timer 0.
	movwf	TMR0
	bcf	INTCON,T0IF		; Resetea el flag de desbordamiento del TMR0. 
Timer0_Rebosamiento
	btfss	INTCON,T0IF		; �Se ha producido desbordamiento?
	goto	Timer0_Rebosamiento	; Todav�a no. Repite.
	return

	END
	
;	====================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS".
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	====================================================================
