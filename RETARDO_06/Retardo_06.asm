;************************************ Retardo_06.asm ************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Por la barra de LEDs conectada al puerto de salida un LED encendido rota a la izquierda
; izquierda durante 0.5 s en cada posición empezando por la línea RB0. El número de
; posiciones a desplazar lo fija el valor de las tres primeras líneas del Puerto A entrada.
; Así por ejemplo, si (PORTA)=b'---00011' (3 decimal), la secuencia de salida sería:
; 00000000, 00000001, 00000010, 00000100, 00000000, 00000001, 00000010,... ( y repite) 
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	Contador
	ENDC

; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0	
Inicio
	bsf	STATUS,RP0		; Acceso al Banco 1.
	clrf	PORTB			; Líneas del Puerto B configuradas como salidas.
	movlw	b'00000111'		; Líneas del Puerto A configuradas como entradas. 
	movwf	PORTA	
	bcf	STATUS,RP0		; Acceso al Banco 0.
Principal
	clrf	PORTB			; Al principio apaga todos los LEDs.
	movf	PORTA,W			; Lee los interruptores. 
	andlw	b'00000111'		; Se queda con la información de las 3 primeras
	btfsc	STATUS,Z		; líneas y comprueba si es cero.
	goto	Final			; Sí, es cero. No visualiza led alguno.
	movwf	Contador		; En (Contador) el número de leds a desplazar.
	bsf	STATUS,C		; Carga el dato inicial en el Carry.
Rota 	call	Retardo_500ms		; Rota a izquierdas, visualizando la información
	rlf	PORTB,F			; durante 500 ms en cada posición.
	decfsz	Contador,F		; Rota tantas veces como le indique el
	goto	Rota 			; Contador.
	call	Retardo_500ms		; La última posición también debe tener retardo.
Final	goto	Principal

	INCLUDE  <RETARDOS.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
