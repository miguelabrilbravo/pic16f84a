;************************************* Servos_01.asm *************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Programa de control del posicionamiento de un servomotor Futaba S3003. Controla el �ngulo
; mediante una se�al cuadrada PWM de 20 ms de periodo que se aplica a su l�nea de control.
; El �ngulo es gobernado por el tiempo en alto de la se�al cuadrada desde 0� (para 0,3 ms
; de tiempo en alto), hasta 180� (para un tiempo en alto de 2,1 ms).
;
; En este programa el servomotor se posiciona en 0�, 90�, 180�, vuelve a 90� y repite el ciclo.
; Permanece en cada posici�n durante 1 s. El funcionamiento se explica en la siguiente tabla
; donde se ha tomado como tiempo patr�n 100 �s (0,1 ms) conseguidos mediante interrupciones
; por desbordamiento del Timer 0.
;
; 				Tiempo Alto	Tiempo Bajo		Angulo
; 		FactorAlto	0,1�FactorAlto	0,1�(200-FactorAlto)		(Grados)
; 		------------		--------------	----------------------		---------
;   		     3		    0,3 ms	 	    19,7 ms		 	   0�
;   		   12		    1,2 ms		    18,8 ms			 90�
;		   21		    2,1 ms		    17,9 ms			180�
;   		   12		    1,2 ms		    18,8 ms			 90�
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	Contador
	FactorAlto			; Factor por el que se va a multiplicar el tiempo
	ENDC				; patr�n de 100 �s para obtener el tiempo en alto.

TMR0_Carga	EQU	-d'90'		; Valor obtenido experimentalmente con la ventana
					; Stopwatch para un tiempo de 100 �s.
#DEFINE  Salida	PORTB,0			; L�nea del Puerto B donde se conecta el servomotor.

; ZONA DE C�DIGOS ******************************************************************** 

	ORG 	0
   	goto	Inicio
	ORG	.4
	goto	Timer0_Interrupcion
Inicio
	bsf	STATUS,RP0
	bcf	Salida			; Esta l�nea se configura como salida.
	movlw	b'00001000'		; TMR0 sin prescaler.
	movwf	OPTION_REG
	bcf	STATUS,RP0
	movlw	b'10100000'
	movwf	INTCON			; Autoriza interrupci�n T0I y la general (GIE).
	clrf	Contador
Principal
	movf	Contador,W
	andlw	b'00000011'
	call	SeleccionaFactorAlto
	movwf	FactorAlto
	call	Retardo_1s
	incf	Contador,F
	goto	Principal

SeleccionaFactorAlto
	addwf	PCL,F
	DT	d'3', d'12', d'21', d'12'	; Tabla para el servo Futaba S3003.

; Subrutina "Timer0_Interrupcion" -------------------------------------------------------
;
; Mantiene la salida en alto un tiempo igual a 100�s x (FactorAlto) y en bajo un tiempo igual
; a 100�s x (200-FactorAlto). El periodo de la se�al cuadrada lo mantiene en 20 ms.
;
	CBLOCK	
	Guarda_W
	Guarda_STATUS
	Timer0_ContadorA			; Contador auxiliar.
	ENDC

Timer0_Interrupcion
	movwf	Guarda_W		; Guarda los valores de ten�an W y STATUS en el
	swapf	STATUS,W		; programa principal.
	movwf	Guarda_STATUS
	bcf	STATUS,RP0		; Garantiza que trabaja en el Banco 0.
	movlw 	TMR0_Carga
	movwf 	TMR0
	decfsz 	Timer0_ContadorA,F	; Decrementa el contador.
	goto 	Fin_Timer0_Interrupcion
	btfsc 	Salida			; Testea el anterior estado de la salida.
	goto 	EstabaAlto
EstabaBajo
	bsf	Salida			; Estaba bajo y lo pasa a alto.
	movf	FactorAlto,W		; Repone el contador nuevamente con el tiempo en 
	movwf 	Timer0_ContadorA		; alto.
	goto 	Fin_Timer0_Interrupcion
EstabaAlto
	bcf 	Salida			; Estaba alto y lo pasa a bajo.
	movf	FactorAlto,W		; Repone el contador nuevamente con el tiempo
	sublw	.200			; en bajo.
	movwf 	Timer0_ContadorA		; El periodo ser� de 100�s�200=20000�s=20ms.
Fin_Timer0_Interrupcion
	swapf	Guarda_STATUS,W	; Restaura registros W y STATUS.
	movwf	STATUS
	swapf	Guarda_W,F
	swapf	Guarda_W,W
	bcf	INTCON,RBIF
	bcf	INTCON,T0IF
	retfie
	
	INCLUDE <RETARDOS.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================

