;**************************** Librería "PCF8574.INC" **********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Estas subrutinas permiten realizar las tareas de manejo del expansor de bus I2C PCF8574
; que convierte un bus de 8 líneas paralelo a bus serie I2C y viceversa.
;
; Como es posible que haya más de un expansor en el mismo circuito, se deja a la subrutina
; de llamada a éstas que determine las direcciones de escritura y lectura mediante las
; etiquetas "PCF8574_DireccionLectura" y "PCF8574_DireccionEscritura", atendiendo a las
; características del hardware utilizado.
;
; ZONA DE DATOS **********************************************************************

	CBLOCK
	PCF8574_Dato			; Aquí guarda el resultado del dato leído o que
	ENDC				; se va a escribir.

; Subrutina "PCF8574_Lee" -------------------------------------------------------------
;
; Lee el periférico conectado al bus paralelo de 8 líneas del PCF8574 que actúa como
; entrada y el resultado lo proporciona en el registro de trabajo W.

PCF8574_Lee
	call	I2C_EnviaStart		; Envía la condición de Start.
	movlw	PCF8574_DireccionLectura	; Apunta al expansor de lectura.
	call	I2C_EnviaByte
	bsf	I2C_UltimoByteLeer
	call	I2C_LeeByte		; Lee el puerto.
	movwf	PCF8574_Dato		; Lo guarda en el registro correspondiente.
	call	I2C_EnviaStop		; Acaba de leer.
	movf	PCF8574_Dato,W		; Recupera el valor del dato leído.
	return

; Subrutina "PCF8574_Escribe" ----------------------------------------------------------
;
; Escribe en el periférico conectado bus paralelo de 8 líneas del expansor PCF8574 que
; actúa como salida, el dato que le llega por el registro de trabajo W. El dato escrito
; es recuperado finalmente en el registro W.
;
PCF8574_Escribe
	movwf	PCF8574_Dato		; Guarda el dato a escribir.
	call	I2C_EnviaStart		; Envia condición de Start.
	movlw	PCF8574_DireccionEscritura	; Apunta al expansor que actúa como salida.
	call	I2C_EnviaByte
	movf	PCF8574_Dato,W		; Recupera el valor del dato a enviar.
	call	I2C_EnviaByte		; Envía el dato.
	call	I2C_EnviaStop		; Termina.
	movf	PCF8574_Dato,W		; Recupera el valor del dato escrito.
	return

;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
