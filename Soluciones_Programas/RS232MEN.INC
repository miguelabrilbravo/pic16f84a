;***************************** Librería "RS232MEN.INC" **********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84A. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Estas subrutinas permiten transmitir mensajes desde el microcontrolador hacia el 
; ordenador a través del puerto serie RS232.
;
; Subrutina "RS232_Mensaje" -------------------------------------------------------------
;
; Envía por el puerto serie el mensaje apuntado por el registro W y grabado en memoria
; de programa del PIC. El mensaje se visualizará en el monitor del ordenador. Esta
; subrutina sigue la estructura de funcionamiento similar a la ya conocida "LCD_Mensaje"
; para visualización de mensajes en pantallas de  modulos LCD.
;
	CBLOCK
	RS232_ApuntaCaracter		; Apunta al carácter a visualizar.
	RS232_ValorCaracter		; Valor ASCII del carácter a visualizar.
	ENDC

RS232_Mensaje
	movwf	RS232_ApuntaCaracter	; Posición del primer carácter del mensaje.
	movlw	Mensajes			; Halla la posición relativa del primer carácter
	subwf	RS232_ApuntaCaracter,F	; del mensaje respecto del comienzo de todos los
					; mensajes (identificados mediante la etiqueta
					; "Mensajes").
	decf	RS232_ApuntaCaracter,F	; Para compensar la posición que ocupa la 
RS232_VisualizaOtroCaracter			; instrucción "addwf PCL,F".
	movf	RS232_ApuntaCaracter,W	; Apunta al carácter a visualizar.
	call	Mensajes			; Obtiene el código ASCII del carácter apuntado.
	movwf	RS232_ValorCaracter	; Guarda el valor de carácter.
	movf	RS232_ValorCaracter,F	; Lo único que hace es posicionar flag Z. En caso
	btfsc	STATUS,Z		; que sea "0x00", que es código indicador final	
	goto	RS232_FinMensaje 		; de mensaje, sale fuera.
RS232_NoUltimoCaracter
	call	RS232_EnviaDato		; Visualiza el carácter ASCII leído.
	incf	RS232_ApuntaCaracter,F	; Apunta a la posición del siguiente carácter
	goto	RS232_VisualizaOtroCaracter	; dentro del mensaje.
RS232_FinMensaje
	return

; Subrutina "RS232_LineasBlanco" ------------------------------------------------
;
; Visualiza unas cuantas líneas en blanco en el monitor del ordenador.

	CBLOCK
	RS232_ContadorLineas
	ENDC

RS232_LineasBlanco
	movlw	d'10'			; Por ejemplo este número de líneas en
	movwf	RS232_ContadorLineas	; blanco.
R232_LineasBlancoLazo
	movlw	.10			; Código del salto de línea
	call	RS232_EnviaDato
	decfsz	RS232_ContadorLineas,F
	goto	R232_LineasBlancoLazo
	movlw	.13			; Código del retorno de carro.
	call	RS232_EnviaDato		; Finaliza con un retorno de carro.
	return
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84A. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
