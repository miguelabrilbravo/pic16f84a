;**************************** Librería "M24LC256.INC" ***********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Estas subrutinas permiten realizar las tareas de manejo de la memoria EEPROM serie
; 24LC256 que transmite y recibe la información vía serie a través de un bus I2C.
;
; Subrutina "M24LC256_InicializaEscritura" ----------------------------------------------
;
; Prepara la memoria para iniciar su escritura a partir de la posición de memoria fijada
; por los registros:
; - (M24LC256_AddressHigh), indica el número del bloque o página de memoria a escribir.
; - (M24LC256_AddressLow), indica posición a escribir dentro del bloque.

	CBLOCK
	M24LC256_AddressHigh		; Guarda el valor de la dirección de memoria a 
	M24LC256_AddressLow		; escribir o leer.
	M24LC256_Dato
	ENDC
;
M24LC256_DireccionEscritura	 EQU	b'10100000'; Dirección de la memoria 24LC256 para
M24LC256_DireccionLectura	 EQU	b'10100001'; escritura y lectura respectivamente.

M24LC256_InicializaEscritura
	call	I2C_EnviaStart		; Envía condición de Start.
	movlw	M24LC256_DireccionEscritura; Envía dirección de escritura del 
	call	I2C_EnviaByte		; esclavo.
	movf	M24LC256_AddressHigh,W	; A partir de la dirección apuntada por los 
	call	I2C_EnviaByte		; registros M24LC256_AddressHigh y
	movf	M24LC256_AddressLow,W	; M24LC256_AddressLow.
	call	I2C_EnviaByte
	return	

; Subrutina "M24LC256_InicializaLectura" ------------------------------------------------
;
; Prepara la memoria para iniciar su lectura a partir de la posición de memoria fijada
; por los registros:
; - (M24LC256_AddressHigh), indica el número del bloque o página de memoria a leer.
; - (M24LC256_AddressLow), indica posición a escribir dentro del bloque.

M24LC256_InicializaLectura
	bcf	I2C_UltimoByteLeer	; Todavía no ha comenzado a leer ningún dato.
	call	I2C_EnviaStart		; Envía condición de Start.
	movlw	M24LC256_DireccionEscritura; Envía dirección de escritura del 
	call	I2C_EnviaByte		; esclavo.
	movf	M24LC256_AddressHigh,W	; A partir de la dirección apuntada por los 
	call	I2C_EnviaByte		; registros M24LC256_AddressHigh y
	movf	M24LC256_AddressLow,W	; M24LC256_AddressLow.
	call	I2C_EnviaByte
	call	I2C_EnviaStop
;
	call	I2C_EnviaStart		; Envía condición de Start.
	movlw	M24LC256_DireccionLectura	; Indica a la memoria 24LC256 que va a 
	call	I2C_EnviaByte		; proceder a la lectura.
	return

; Subrutina "M24LC256_Mensaje_a_LCD" ----------------------------------------------------
;
; Lee el mensaje grabado en la memoria 24LC256 y lo visualiza en la pantalla del módulo LCD.
; En el registro de trabajo W se introduce la página de la memoria a partir de cuya primera
; posición se va a leer. La lectura termina cuando encuentre el código 0x00. Así por ejemplo,
; si (W)=2Fh lee el mensaje que comienza en la posición 0 de la página 2Fh de la memoria,
; que es la posición 2F00h absoluta. 
; 
	CBLOCK
;	M24LC256_ValorCaracter		; Valor ASCII del carácter leído.
	ENDC

;M24LC256_Mensaje_a_LCD
	movwf	M24LC256_AddressHigh	; Apunta al inicio de la página correspondiente.
	clrf	M24LC256_AddressLow
	call	M24LC256_InicializaLectura
M24LC256_LeeOtroByte
	call	I2C_LeeByte		; Lee la memoria 24LC256.
	movwf	M24LC256_ValorCaracter	; Guarda el valor de carácter.
	movf	M24LC256_ValorCaracter,F	; Lo único que hace es posicionar flag Z. En caso
	btfsc	STATUS,Z		; que sea "0x00", que es código indicador final	
	goto	M24LC256_FinMensaje	; del mensaje, sale de la subrutina.
	movf	M24LC256_ValorCaracter,W	; Recupera el valor leído.
	call	LCD_Caracter		; Lo visualiza en la pantalla del LCD.
	incf	M24LC256_AddressLow,F	; Apunta a la siguiente posición.
	goto	M24LC256_LeeOtroByte
;M24LC256_FinMensaje
;	call	M24LC_256_FinalizaLectura
;	return

; Subrutina "M24LC256_FinalizaLectura" ------------------------------------------------
;
; Activa el bit I2C_UltimoByteLeer para que la subrutina I2C_LeeByte ponga en alta
; impedancia la línea SDA y pueda ejecutarse posteriormente la condición de Start o Stop
; que fija el protocolo del bus I2C.

M24LC256_FinalizaLectura
	bsf	I2C_UltimoByteLeer	; Con estas dos instrucciones se pone en 
	call	I2C_LeeByte		; alta impedancia la línea SDA. No importa el
	call	I2C_EnviaStop		; resultado de la lectura realizada.
	return

; Subrutina "M24LC256_Mensaje_a_LCD" ----------------------------------------------------
;
; Lee un mensaje grabado en la memoria 24LC256 y lo visualiza por el módulo LCD. En caso que
; sea más largo que la longitud de la pantalla se desplaza hacia la izquierda con sensación
; de movimiento. En el registro de trabajo W se introduce la página de la memoria a partir
; de cuya primera posición va a leer. La visualización termina cuando encuentre el código
; 0x00. Así por ejemplo si (W)= 2Fh lee el mensaje que comienza en la posición 0 de la
; página 2Fh de la memoria, que es la posición 2F00h absoluta. 
; 
	CBLOCK
	M24LC256_ValorCaracter		; Valor ASCII del carácter leído.
	M24LC256_CursorPosicion
	ENDC
	
M24LC256_Mensaje_a_LCD
	bcf	I2C_UltimoByteLeer
	movwf	M24LC256_AddressHigh	; Apunta al inicio de la página correspondiente.
	clrf	M24LC256_AddressLow
	call	M24LC256_InicializaLectura
M24LC256_PrimeraPosicion
	clrf	M24LC256_CursorPosicion	; El cursor en la posición 0 de la línea.
	call	LCD_Borra		; Se sitúa en la primera posición de la línea 1 y
M24LC256_VisualizaCaracter			; borra la pantalla.
	movlw	LCD_CaracteresPorLinea	; ¿Ha llegado a final de línea?
	subwf	M24LC256_CursorPosicion,W
	btfss	STATUS,C
	goto	M24LC256_NoEsFinalLinea
M24LC256_EsFinalLinea
	call	Retardo_200ms		; Lo mantiene visualizado durante este tiempo.
	call	Retardo_200ms
	call	M24LC256_FinalizaLectura
	incf	M24LC256_AddressLow,F
	call	M24LC256_InicializaLectura
	goto	M24LC256_PrimeraPosicion
M24LC256_NoEsFinalLinea
	call	I2C_LeeByte		; Obtiene el ASCII del carácter apuntado.
	movwf	M24LC256_ValorCaracter	; Guarda el valor de carácter.
	movf	M24LC256_ValorCaracter,F	; Lo único que hace es posicionar flag Z. En caso
	btfsc	STATUS,Z		; que sea "0x00", que es código indicador final
	goto	M24LC256_FinMensaje	; de mensaje, sale fuera.
M24LC256_NoUltimoCaracter
	call	LCD_Caracter		; Visualiza el carácter ASCII leído.
	incf	M24LC256_CursorPosicion,F	; Contabiliza el incremento de posición del 
					; cursor en la pantalla.
	goto	M24LC256_VisualizaCaracter	; Vuelve a visualizar el siguiente carácter
M24LC256_FinMensaje			; de la línea.
	call	M24LC256_FinalizaLectura
	return

;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
