;******************************* I2C_Display_Termometro_01.asm ************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Programa de control para un termómetro digital con el sensor de temperatura DS1624,
; y visualización en cuatro displays.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK   0x0C
	Registro50ms			; Guarda los incrementos cada 50 ms.
	ENDC

TMR0_Carga50ms	EQU	-d'195'		; Para conseguir interrupción cada 50 ms.
Carga2s		EQU	d'40'		; Leerá cada 2s = 40 x 50ms = 2000ms.

; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0
	goto	Inicio
	ORG	4
	goto	Termometro
Inicio
	call	DS1624_Inicializa		; Configura el DS1624 e inicia la conversión.
	bsf	STATUS,RP0
	movlw	b'00000111'		; Preescaler de 256 para el TMR0.
	movwf	OPTION_REG
	bcf	STATUS,RP0
	movlw	TMR0_Carga50ms		; Carga el TMR0 en complemento a 2.
	movwf	TMR0
	movlw	Carga2s			; Y el registro cuyo decremento contará los 2 s.
	movwf	Registro50ms
	movlw	b'10100000'		; Activa interrupción del TMR0 (T0IE),
	movwf	INTCON			; y la general (GIE).
Principal
	goto	Principal

; Subrutina "Termometro" ----------------------------------------------------------------
;
; Esta subrutina lee y visualiza el termómetro cada 2 segundos aproximadamente. Se ejecuta
; debido a la petición de interrupción del Timer 0, cada 50 ms. Para conseguir una
; temporización de 2 s habrá que repetir 40 veces el lazo de 50 ms (40x50ms=2000ms=2s).
;
Termometro
	movlw	TMR0_Carga50ms
	movwf	TMR0			; Recarga el TMR0.
	decfsz	Registro50ms,F		; Decrementa el contador.
	goto	Fin_Termometro		; No han pasado 2 segundos y por tanto sale.
	movlw	Carga2s			; Repone el contador nuevamente.
	movwf	Registro50ms
	call	DS1624_LeeTemperatura	; Lee la temperatura.
	call	DS1624_IniciaConversion	; Comienza conversión para la siguiente lectura.
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
	call	I2C_EnviaStart		; Envía condición de Start.
	movlw	SAA1064_Direccion	; Apunta al SAA1064.
	call	I2C_EnviaByte
	clrw				; El registro de control está en la posición 0.
	call	I2C_EnviaByte
	movlw	b'01000111'		; Palabra de control para luminosidad media
	call	I2C_EnviaByte		; (12 mA) y visualización dinámica multiplexada.
	movlw	'º'			; Escribe el símbolo de grados.
	call	ASCII_a_7Segmentos	; Última letra debido a la disposición de los
	call	I2C_EnviaByte		; displays.
	btfss	DS1624_Signo,7		; ¿Temperatura negativa?
	goto	TemperaturaPositiva		; No, la temperatura es positiva.
TemperaturaNegativa
	movf	DS1624_Temperatura,W	; Recupera el valor de la temperatura en BCD.	
	call	Numero_a_7Segmentos	; Las unidades se pasan a código siete segmentos.
	call	I2C_EnviaByte		; Lo envía al display.
	swapf	DS1624_Temperatura,W	; Las decenas se pasan a código de siete
	call	Numero_a_7Segmentos	; segmentos.
	call	I2C_EnviaByte		; Lo envía al display.
	movlw 	'-'			; Visualiza el signo "-" de temperatura negativa.
	call	ASCII_a_7Segmentos	; Lo pasa a siete segmentos.
	call	I2C_EnviaByte		; Lo envía al display.
	goto	Fin_VisualizaTemperatura
TemperaturaPositiva
	movf	DS1624_Decimal,W	; Visualiza la parte decimal.
	call	Numero_a_7Segmentos
	call	I2C_EnviaByte		; Lo envía al display.
	movf	DS1624_Temperatura,W	; Recupera el valor de la temperatura en BCD.	
	call	Numero_a_7Segmentos	; Las unidades se pasan a código siete segmentos.
	iorlw	b'10000000'		; Le añade el punto decimal.
	call	I2C_EnviaByte		; Lo envía al display.
	swapf	DS1624_Temperatura,W	; Las decenas se pasan a código de siete
	call	Numero_a_7Segmentos	; segmentos.
	call	I2C_EnviaByte		; Lo envía al display.
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
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
