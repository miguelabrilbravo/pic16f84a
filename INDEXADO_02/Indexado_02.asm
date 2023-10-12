;********************************** Indexado_02.asm *************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Controla el nivel de un dep�sito de l�quido. Utiliza (entre par�ntesis las l�neas del
; microcontrolador a la que se han conectado):
;     -	Tres sondas detectoras: SV, Sonda de Vac�o (RA0); SLL, Sonda de LLenado (RA1);
;	SR, Sonda de Rebose (RA2).
;     -	Dos bombas de agua: B1 (RB5), B2 (RB6).
;     - Cinco indicadores: Vacio (RB0), Llenandose (RB1), Lleno (RB2), Rebose (RB3),
;	Alarma (RB4).
;
; Su funcionamiento: 
;    -	Cuando ninguna de las sondas est� mojada se entiende que el dep�sito est� vac�o y
;	se accionar�n las dos bombas. El indicador "Vacio" se iluminar�.
;    -	Cuando el nivel del l�quido toque la sonda de vac�o "SV" seguir� llen�ndose el
; 	dep�sito con las dos bombas. El indicador "Llenandose" se ilumina.
;    -	Cuando el nivel del l�quido toca la sonda de llenado "SLL", para la bomba B2, quedando
;	B1 activada en modo mantenimiento. El indicador "Lleno" se ilumina.
;    -	Si el nivel del l�quido moja la sonda de rebose "SR" se apaga tambi�n la bomba B1,
;	quedando las dos bombas fuera de servicio. El indicador "Rebose" se enciende.
;   -	Cuando se produce un fallo o mal funcionamiento en las sondas de entrada (por
;	ejemplo que se active la sonda de rebose y no active la de vac�o) se paran
;	las dos bombas. El indicador "Alarma" se ilumina.
;
; Seg�n el enunciado del problema, teniendo en cuenta las conexiones citadas y poniendo la
; salida no utilizada (RB7) siempre a cero, la tabla de verdad resultante es:
;
; RA2.. RA0 | RB7 ...          ... RB0
; ------------|--------------------------------
;  0   0   0  |  0   1   1   0   0   0   0   1	(Configuraci�n 0. Estado "Vacio").
;  0   0   1  |  0   1   1   0   0   0   1   0	(Configuraci�n 1. Estado "Llenandose").
;  0   1   0  |  0   0   0   1   0   0   0   0	(Configuraci�n 2. Estado "Alarma").
;  0   1   1  |  0   0   1   0   0   1   0   0	(Configuraci�n 3. Estado "Lleno").
;  1   0   0  |  0   0   0   1   0   0   0   0	(Configuraci�n 4. Estado "Alarma").
;  1   0   1  |  0   0   0   1   0   0   0   0	(Configuraci�n 5. Estado "Alarma").
;  1   1   0  |  0   0   0   1   0   0   0   0	(Configuraci�n 6. Estado "Alarma").
;  1   1   1  |  0   0   0   0   1   0   0   0	(Configuraci�n 7. Estado "Rebose").
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

; ZONA DE C�DIGOS ********************************************************************

	ORG 	0			; El programa comienza en la direcci�n 0.
Inicio
	clrf	PORTB			; Debe estar a cero cuando el puerto se configure
					; como salida.
	bsf	STATUS,RP0		; Acceso al Banco 1.
	clrf	TRISB			; Las l�neas del Puerto B se configuran como salida.
	movlw	b'00011111'		; Las 5 l�neas del Puerto A se configuran como entrada.
	movwf	TRISA
	bcf	STATUS,RP0		; Acceso al Banco 0.
Principal
	movf	PORTA,W			; Lee los sensores.
	andlw	b'00000111'		; M�scara para quedarse con el valor de los sensores.
	addwf	PCL,F			; Salta a la configuraci�n adecuada.
	goto	Configuracion0
	goto	Configuracion1
	goto	Configuracion2
	goto	Configuracion3
	goto	Configuracion4
	goto	Configuracion5
	goto	Configuracion6
	goto	Configuracion7
Configuracion0
	movlw 	b'01100001'		; Estado "Vacio" (configuraci�n 0).
	goto	ActivaSalida
Configuracion1
	movlw 	b'01100010'		; Estado "Llen�ndose" (configuraci�n 1).
	goto	ActivaSalida
Configuracion2
	movlw 	b'00010000'		; Estado "Alarma" (configuraci�n 2).
	goto	ActivaSalida
Configuracion3
	movlw 	b'00100100'		; Estado "Lleno" (configuraci�n 3).
	goto	ActivaSalida
Configuracion4
	movlw 	b'00010000'		; Estado "Alarma" (configuraci�n 4).
	goto	ActivaSalida
Configuracion5
	movlw 	b'00010000'		; Estado "Alarma" (configuraci�n 5).
	goto	ActivaSalida
Configuracion6
	movlw 	b'00010000'		; Estado "Alarma" (configuraci�n 6).
	goto	ActivaSalida
Configuracion7
	movlw 	b'00001000'		; Estado "Rebose" (configuraci�n 7).
ActivaSalida
	movwf	PORTB			; Visualiza por el puerto de salida.
	goto 	Principal

	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
