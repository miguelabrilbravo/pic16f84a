;**************************** Librer�a "M24LC256.INC" ***********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Estas subrutinas permiten realizar las tareas de manejo de la memoria EEPROM serie
; 24LC256 que transmite y recibe la informaci�n v�a serie a trav�s de un bus I2C.
;
; Subrutina "M24LC256_InicializaEscritura" ----------------------------------------------
;
; Prepara la memoria para iniciar su escritura a partir de la posici�n de memoria fijada
; por los registros:
; - (M24LC256_AddressHigh), indica el n�mero del bloque o p�gina de memoria a escribir.
; - (M24LC256_AddressLow), indica posici�n a escribir dentro del bloque.

	CBLOCK
	M24LC256_AddressHigh		; Guarda el valor de la direcci�n de memoria a 
	M24LC256_AddressLow		; escribir o leer.
	M24LC256_Dato
	ENDC
;
M24LC256_DireccionEscritura	 EQU	b'10100000'; Direcci�n de la memoria 24LC256 para
M24LC256_DireccionLectura	 EQU	b'10100001'; escritura y lectura respectivamente.

M24LC256_InicializaEscritura
	call	I2C_EnviaStart		; Env�a condici�n de Start.
	movlw	M24LC256_DireccionEscritura; Env�a direcci�n de escritura del 
	call	I2C_EnviaByte		; esclavo.
	movf	M24LC256_AddressHigh,W	; A partir de la direcci�n apuntada por los 
	call	I2C_EnviaByte		; registros M24LC256_AddressHigh y
	movf	M24LC256_AddressLow,W	; M24LC256_AddressLow.
	call	I2C_EnviaByte
	return	

; Subrutina "M24LC256_InicializaLectura" ------------------------------------------------
;
; Prepara la memoria para iniciar su lectura a partir de la posici�n de memoria fijada
; por los registros:
; - (M24LC256_AddressHigh), indica el n�mero del bloque o p�gina de memoria a leer.
; - (M24LC256_AddressLow), indica posici�n a escribir dentro del bloque.

M24LC256_InicializaLectura
	bcf	I2C_UltimoByteLeer	; Todav�a no ha comenzado a leer ning�n dato.
	call	I2C_EnviaStart		; Env�a condici�n de Start.
	movlw	M24LC256_DireccionEscritura; Env�a direcci�n de escritura del 
	call	I2C_EnviaByte		; esclavo.
	movf	M24LC256_AddressHigh,W	; A partir de la direcci�n apuntada por los 
	call	I2C_EnviaByte		; registros M24LC256_AddressHigh y
	movf	M24LC256_AddressLow,W	; M24LC256_AddressLow.
	call	I2C_EnviaByte
	call	I2C_EnviaStop
;
	call	I2C_EnviaStart		; Env�a condici�n de Start.
	movlw	M24LC256_DireccionLectura	; Indica a la memoria 24LC256 que va a 
	call	I2C_EnviaByte		; proceder a la lectura.
	return

; Subrutina "M24LC256_Mensaje_a_LCD" ----------------------------------------------------
;
; Lee el mensaje grabado en la memoria 24LC256 y lo visualiza en la pantalla del m�dulo LCD.
; En el registro de trabajo W se introduce la p�gina de la memoria a partir de cuya primera
; posici�n se va a leer. La lectura termina cuando encuentre el c�digo 0x00. As� por ejemplo,
; si (W)=2Fh lee el mensaje que comienza en la posici�n 0 de la p�gina 2Fh de la memoria,
; que es la posici�n 2F00h absoluta. 
; 
	CBLOCK
;	M24LC256_ValorCaracter		; Valor ASCII del car�cter le�do.
	ENDC

;M24LC256_Mensaje_a_LCD
	movwf	M24LC256_AddressHigh	; Apunta al inicio de la p�gina correspondiente.
	clrf	M24LC256_AddressLow
	call	M24LC256_InicializaLectura
M24LC256_LeeOtroByte
	call	I2C_LeeByte		; Lee la memoria 24LC256.
	movwf	M24LC256_ValorCaracter	; Guarda el valor de car�cter.
	movf	M24LC256_ValorCaracter,F	; Lo �nico que hace es posicionar flag Z. En caso
	btfsc	STATUS,Z		; que sea "0x00", que es c�digo indicador final	
	goto	M24LC256_FinMensaje	; del mensaje, sale de la subrutina.
	movf	M24LC256_ValorCaracter,W	; Recupera el valor le�do.
	call	LCD_Caracter		; Lo visualiza en la pantalla del LCD.
	incf	M24LC256_AddressLow,F	; Apunta a la siguiente posici�n.
	goto	M24LC256_LeeOtroByte
;M24LC256_FinMensaje
;	call	M24LC_256_FinalizaLectura
;	return

; Subrutina "M24LC256_FinalizaLectura" ------------------------------------------------
;
; Activa el bit I2C_UltimoByteLeer para que la subrutina I2C_LeeByte ponga en alta
; impedancia la l�nea SDA y pueda ejecutarse posteriormente la condici�n de Start o Stop
; que fija el protocolo del bus I2C.

M24LC256_FinalizaLectura
	bsf	I2C_UltimoByteLeer	; Con estas dos instrucciones se pone en 
	call	I2C_LeeByte		; alta impedancia la l�nea SDA. No importa el
	call	I2C_EnviaStop		; resultado de la lectura realizada.
	return

; Subrutina "M24LC256_Mensaje_a_LCD" ----------------------------------------------------
;
; Lee un mensaje grabado en la memoria 24LC256 y lo visualiza por el m�dulo LCD. En caso que
; sea m�s largo que la longitud de la pantalla se desplaza hacia la izquierda con sensaci�n
; de movimiento. En el registro de trabajo W se introduce la p�gina de la memoria a partir
; de cuya primera posici�n va a leer. La visualizaci�n termina cuando encuentre el c�digo
; 0x00. As� por ejemplo si (W)= 2Fh lee el mensaje que comienza en la posici�n 0 de la
; p�gina 2Fh de la memoria, que es la posici�n 2F00h absoluta. 
; 
	CBLOCK
	M24LC256_ValorCaracter		; Valor ASCII del car�cter le�do.
	M24LC256_CursorPosicion
	ENDC
	
M24LC256_Mensaje_a_LCD
	bcf	I2C_UltimoByteLeer
	movwf	M24LC256_AddressHigh	; Apunta al inicio de la p�gina correspondiente.
	clrf	M24LC256_AddressLow
	call	M24LC256_InicializaLectura
M24LC256_PrimeraPosicion
	clrf	M24LC256_CursorPosicion	; El cursor en la posici�n 0 de la l�nea.
	call	LCD_Borra		; Se sit�a en la primera posici�n de la l�nea 1 y
M24LC256_VisualizaCaracter			; borra la pantalla.
	movlw	LCD_CaracteresPorLinea	; �Ha llegado a final de l�nea?
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
	call	I2C_LeeByte		; Obtiene el ASCII del car�cter apuntado.
	movwf	M24LC256_ValorCaracter	; Guarda el valor de car�cter.
	movf	M24LC256_ValorCaracter,F	; Lo �nico que hace es posicionar flag Z. En caso
	btfsc	STATUS,Z		; que sea "0x00", que es c�digo indicador final
	goto	M24LC256_FinMensaje	; de mensaje, sale fuera.
M24LC256_NoUltimoCaracter
	call	LCD_Caracter		; Visualiza el car�cter ASCII le�do.
	incf	M24LC256_CursorPosicion,F	; Contabiliza el incremento de posici�n del 
					; cursor en la pantalla.
	goto	M24LC256_VisualizaCaracter	; Vuelve a visualizar el siguiente car�cter
M24LC256_FinMensaje			; de la l�nea.
	call	M24LC256_FinalizaLectura
	return

;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
