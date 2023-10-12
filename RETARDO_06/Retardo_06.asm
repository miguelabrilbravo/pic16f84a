;************************************ Retardo_06.asm ************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Por la barra de LEDs conectada al puerto de salida un LED encendido rota a la izquierda
; izquierda durante 0.5 s en cada posici�n empezando por la l�nea RB0. El n�mero de
; posiciones a desplazar lo fija el valor de las tres primeras l�neas del Puerto A entrada.
; As� por ejemplo, si (PORTA)=b'---00011' (3 decimal), la secuencia de salida ser�a:
; 00000000, 00000001, 00000010, 00000100, 00000000, 00000001, 00000010,... ( y repite) 
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	Contador
	ENDC

; ZONA DE C�DIGOS ********************************************************************

	ORG 	0	
Inicio
	bsf	STATUS,RP0		; Acceso al Banco 1.
	clrf	PORTB			; L�neas del Puerto B configuradas como salidas.
	movlw	b'00000111'		; L�neas del Puerto A configuradas como entradas. 
	movwf	PORTA	
	bcf	STATUS,RP0		; Acceso al Banco 0.
Principal
	clrf	PORTB			; Al principio apaga todos los LEDs.
	movf	PORTA,W			; Lee los interruptores. 
	andlw	b'00000111'		; Se queda con la informaci�n de las 3 primeras
	btfsc	STATUS,Z		; l�neas y comprueba si es cero.
	goto	Final			; S�, es cero. No visualiza led alguno.
	movwf	Contador		; En (Contador) el n�mero de leds a desplazar.
	bsf	STATUS,C		; Carga el dato inicial en el Carry.
Rota 	call	Retardo_500ms		; Rota a izquierdas, visualizando la informaci�n
	rlf	PORTB,F			; durante 500 ms en cada posici�n.
	decfsz	Contador,F		; Rota tantas veces como le indique el
	goto	Rota 			; Contador.
	call	Retardo_500ms		; La �ltima posici�n tambi�n debe tener retardo.
Final	goto	Principal

	INCLUDE  <RETARDOS.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
