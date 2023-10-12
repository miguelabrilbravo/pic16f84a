;******************************* I2C_Display_Termometro_01.asm ************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Programa de control para un term�metro digital con el sensor de temperatura DS1624,
; y visualizaci�n en cuatro displays.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK   0x0C
	Registro50ms			; Guarda los incrementos cada 50 ms.
	ENDC

TMR0_Carga50ms	EQU	-d'195'		; Para conseguir interrupci�n cada 50 ms.
Carga2s		EQU	d'40'		; Leer� cada 2s = 40 x 50ms = 2000ms.

; ZONA DE C�DIGOS ********************************************************************

	ORG 	0
	goto	Inicio
	ORG	4
	goto	Termometro
Inicio
	call	DS1624_Inicializa		; Configura el DS1624 e inicia la conversi�n.
	bsf	STATUS,RP0
	movlw	b'00000111'		; Preescaler de 256 para el TMR0.
	movwf	OPTION_REG
	bcf	STATUS,RP0
	movlw	TMR0_Carga50ms		; Carga el TMR0 en complemento a 2.
	movwf	TMR0
	movlw	Carga2s			; Y el registro cuyo decremento contar� los 2 s.
	movwf	Registro50ms
	movlw	b'10100000'		; Activa interrupci�n del TMR0 (T0IE),
	movwf	INTCON			; y la general (GIE).
Principal
	goto	Principal

; Subrutina "Termometro" ----------------------------------------------------------------
;
; Esta subrutina lee y visualiza el term�metro cada 2 segundos aproximadamente. Se ejecuta
; debido a la petici�n de interrupci�n del Timer 0, cada 50 ms. Para conseguir una
; temporizaci�n de 2 s habr� que repetir 40 veces el lazo de 50 ms (40x50ms=2000ms=2s).
;
Termometro
	movlw	TMR0_Carga50ms
	movwf	TMR0			; Recarga el TMR0.
	decfsz	Registro50ms,F		; Decrementa el contador.
	goto	Fin_Termometro		; No han pasado 2 segundos y por tanto sale.
	movlw	Carga2s			; Repone el contador nuevamente.
	movwf	Registro50ms
	call	DS1624_LeeTemperatura	; Lee la temperatura.
	call	DS1624_IniciaConversion	; Comienza conversi�n para la siguiente lectura.
	call	VisualizaTermometro	; Visualiza el resultado de la lectura.
Fin_Termometro
	bcf	INTCON,T0IF
	retfie

; Subrutina "VisualizaTermometro" -----------------------------------------------------------------
;
; Visualiza la temperatura en los cuatro displays de siete segmentos controlados por el SAA1064.
; Se escribe comenzando por el final, por el display de la derecha.
;
; Entradas:	- (DS1624_Temperatura), temperatura medida en valor absoluto.
;		- (DS1624_Decimal), parte decimal de la temperatura medida.
;		- (DS1624_Signo), indica signo de la temperatura.

SAA1064_Direccion	EQU	b'01110000'	; SAA1064 como esclavo en bus I2C.

VisualizaTermometro
	movf	DS1624_Temperatura,W	; Hay que visualizar el valor absoluto de la
	call	BIN_a_BCD		; temperatura en BCD.
	movwf	DS1624_Temperatura	; Guarda el valor de la temperatura en BCD.
	call	I2C_EnviaStart		; Env�a condici�n de Start.
	movlw	SAA1064_Direccion	; Apunta al SAA1064.
	call	I2C_EnviaByte
	clrw				; El registro de control est� en la posici�n 0.
	call	I2C_EnviaByte
	movlw	b'01000111'		; Palabra de control para luminosidad media
	call	I2C_EnviaByte		; (12 mA) y visualizaci�n din�mica multiplexada.
	movlw	'�'			; Escribe el s�mbolo de grados.
	call	ASCII_a_7Segmentos	; �ltima letra debido a la disposici�n de los
	call	I2C_EnviaByte		; displays.
	btfss	DS1624_Signo,7		; �Temperatura negativa?
	goto	TemperaturaPositiva		; No, la temperatura es positiva.
TemperaturaNegativa
	movf	DS1624_Temperatura,W	; Recupera el valor de la temperatura en BCD.	
	call	Numero_a_7Segmentos	; Las unidades se pasan a c�digo siete segmentos.
	call	I2C_EnviaByte		; Lo env�a al display.
	swapf	DS1624_Temperatura,W	; Las decenas se pasan a c�digo de siete
	call	Numero_a_7Segmentos	; segmentos.
	call	I2C_EnviaByte		; Lo env�a al display.
	movlw 	'-'			; Visualiza el signo "-" de temperatura negativa.
	call	ASCII_a_7Segmentos	; Lo pasa a siete segmentos.
	call	I2C_EnviaByte		; Lo env�a al display.
	goto	Fin_VisualizaTemperatura
TemperaturaPositiva
	movf	DS1624_Decimal,W	; Visualiza la parte decimal.
	call	Numero_a_7Segmentos
	call	I2C_EnviaByte		; Lo env�a al display.
	movf	DS1624_Temperatura,W	; Recupera el valor de la temperatura en BCD.	
	call	Numero_a_7Segmentos	; Las unidades se pasan a c�digo siete segmentos.
	iorlw	b'10000000'		; Le a�ade el punto decimal.
	call	I2C_EnviaByte		; Lo env�a al display.
	swapf	DS1624_Temperatura,W	; Las decenas se pasan a c�digo de siete
	call	Numero_a_7Segmentos	; segmentos.
	call	I2C_EnviaByte		; Lo env�a al display.
Fin_VisualizaTemperatura
	return

	INCLUDE  <DISPLAY_7S.INC>
	INCLUDE  <BUS_I2C.INC>
	INCLUDE  <DS1624.INC>
	INCLUDE  <BIN_BCD.INC>
	INCLUDE  <RETARDOS.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
