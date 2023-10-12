;*********************************** Servos_02.asm *************************************
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
; de tiempo en alto) hasta 180� (para un tiempo en alto de 2,1 ms)
;
; En este programa la l�neas del Puerto A controlan el �ngulo de posicionamiento con una 
; resoluci�n de 10� seg�n los valores que se indican en la siguiente tabla, tomando como
; tiempo patr�n 100 �s (0,1 ms) conseguidos mediante interrupciones por desbordamiento del
; Timer 0.
;
; Entrada		FactorAlto	Tiempo Alto	Tiempo Bajo		Angulo
; RA4:RA0	(3+Entrada)	0,1xFactorAlto	0,1x(200-FactorAlto)		(Grados)
; ---------		-------------	--------------	------------------		-----------
;   0		   3		    0,3 ms	 	   19,7 ms			  0�
;   1		   4		    0,4 ms	 	   19,6 ms			 10�
;   2		   5		    0,5 ms	 	   19,5 ms			 20�
;   3		   6		    0,6 ms	 	   19,4 ms			 30�
;   ...		  ....		     ...		      ...			...
;
;   17		   20		    2,0 ms	 	   18,0 ms			170�
;   18		   21		    2,1 ms	  	  17,9 ms			180�
;
; A partir de una entrada superior a 18 el servo vibrar�.

; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	FactorAlto			; Factor por el que se va a multiplicar el tiempo
	ENDC				; patr�n de 100 �s para obtener el tiempo en alto.

TMR0_Carga	EQU	-d'90'		; Valor obtenido experimentalmente con la ventana
					; Stopwatch para un tiempo de 100 �s.

; La pr�xima constante hay que variarla seg�n el tipo de Servomotor utilizado.

AltoCeroGrados	EQU	d'300'		; Tiempo en alto para 0�. Para el Futaba S3003, 300 �s.
TiempoPatron	EQU	d'100'		; 100 �s conseguido mediante interrupciones.

FactorMinimo	EQU	AltoCeroGrados/TiempoPatron

#DEFINE  Salida		PORTB,0		; L�nea del Puerto B donde se conecta el servomotor.

; ZONA DE C�DIGOS ******************************************************************** 

	ORG 	0
   	goto	Inicio
	ORG	.4
	goto	Timer0_Interrupcion
Inicio
	bsf	STATUS,RP0
	bcf	Salida			; Esta l�nea se configura como salida.
	movlw	b'00011111'		; Puerto A configurado como entrada.
	movwf	PORTA
	movlw	b'00001000'		; TMR0 sin prescaler.
	movwf	OPTION_REG
	bcf	STATUS,RP0
	movlw 	TMR0_Carga
	movwf	TMR0			; Carga el Timer 0.
	movlw	b'10100000'
	movwf	INTCON			; Autoriza interrupci�n T0I y la general (GIE).
Principal
	movf	PORTA,W		; Lee el puerto de entrada
	andlw	b'00011111'		; Se queda con los bits v�lidos.
	addlw	FactorMinimo		; Para conseguir el tiempo m�nimo correspondiente a 0�.
	movwf	FactorAlto		; Valor entregado a la subrutina de
	goto	Principal			; atenci�n a la interrupci�n.

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

	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
