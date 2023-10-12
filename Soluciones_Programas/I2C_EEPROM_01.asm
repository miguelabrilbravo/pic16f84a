;************************************ I2C_EEPROM_01.asm *******************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Programa para manejar la escritura y lectura en la memoria EEPROM serie 24LC256.
; Tiene dos partes:
;    1ª	Escribe un mensaje grabado en el programa del PIC16F84A a partir de la posición
;	3B00h dentro de la 24LC256.
;    2ª	Lee el mensaje grabado en la memoria 24LC256 anteriormente y lo visualiza en la
;	pantalla del módulo LCD.
;
; El mensaje tendrá menos de 16 caracteres, que es la máxima longitud de la pantalla.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK	0x0C
	ENDC

Pagina	EQU	0x3B			; Escribe y lee en esta página, por ejemplo.

; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0
Inicio
	call	LCD_Inicializa
Principal
	movlw	Pagina			; Escribe a partir de la dirección 0 de esta
	call 	M24LC256_EscribeMensaje	; página de la memoria.
	movlw	Pagina			; Lee a partir de la dirección 0 de esta página
	call	M24LC256_Mensaje_a_LCD	; de la memoria.
	sleep				; Pasa a reposo.

; Subrutina "M24LC256_EscribeMensaje" ----------------------------------------------------------------
;
; Escribe la memoria M24LC256 con el mensaje grabado al final de este programa a partir
; de la posición 0 de la página de la memoria 24LC256, señalada por el contenido del
; registro de trabajo W.
; El tamaño de memoria que se puede grabar por este procedimiento es de 64 bytes como máximo.

	CBLOCK
	ValorCaracter			; Valor ASCII del carácter a escribir.
	ENDC

M24LC256_EscribeMensaje
	movwf	M24LC256_AddressHigh	; El registro W apunta a la página donde va a
	clrf	M24LC256_AddressLow	; grabar el mensaje a partir de la dirección 0.
	call	M24LC256_InicializaEscritura
M24LC256_EscribeOtroByte
	movf	M24LC256_AddressLow,W
	call	Mensaje			; Obtiene el código ASCII del carácter.
	movwf	ValorCaracter		; Guarda el valor de carácter que ha leído del
	call	I2C_EnviaByte		; mensaje y lo escribe en la 24LC256.
	call	Retardo_5ms		; Tiempo de escritura entre byte y byte.
	movf	ValorCaracter,F		; Lo único que hace es posicionar flag Z. En caso
	btfsc	STATUS,Z		; de que sea "0x00", que es código indicador final
	goto	FinEscribeMensaje		; del mensaje sale de la subrutina.
	incf	M24LC256_AddressLow,F
	goto	M24LC256_EscribeOtroByte
FinEscribeMensaje
	call	I2C_EnviaStop		; Termina la escritura.
	call	Retardo_5ms
	return

Mensaje
	addwf	PCL,F
	DT " Estudia D.P.E.",0x0

	INCLUDE  <BUS_I2C.INC>		; Subrutinas de control del bus I2C.
	INCLUDE  <M24LC256.INC>	; Subrutinas de control de la memoria 24LC256.
	INCLUDE  <RETARDOS.INC>
	INCLUDE  <LCD_4BIT.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
