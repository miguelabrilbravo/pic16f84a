;******************************** Librería DS1307.INC ***********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Estas subrutinas permiten realizar las tareas de manejo del reloj-calendario DS1307
; Este dispositivo transmite la información vía serie a través de un bus I2C.
;
; ZONA DE DATOS **********************************************************************

	CBLOCK
	Anho				; Guarda el año.
	Mes				; Guarda el mes.
	Dia				; Guarda el día.
	DiaSemana			; Guarda el día de la semana: lunes, etc.
	Hora				; Guarda las horas.
	Minuto				; Guarda los minutos.
	Segundo				; Guarda los segundos.
	ENDC

DS1307_DireccionEscritura	EQU	0xD0	; Dirección del DS1307.
DS1307_DireccionLectura	EQU	0xD1
 
; Subrutina "DS1307_Inicializa" ---------------------------------------------------------
;
; Configura la señal cuadrada que genera el DS1307 en su pin SQW/OUT a 1 Hz.

DS1307_Inicializa
	call	I2C_EnviaStart		; Envía condición de Start.
	movlw	DS1307_DireccionEscritura	; Indica al DS1307 que el byte a escribir,
	call	I2C_EnviaByte		; está en la posición 07h, que corresponde
	movlw	0x07			; al control de la señal cuadrada.
	call	I2C_EnviaByte
	movlw	b'00010000'		; Escribe en el registro de control para
	call	I2C_EnviaByte		; configurar onda cuadrada del DS1307 a 1 Hz.
	call	I2C_EnviaStop		; Termina de enviar datos.
	return

; Subrutina "DS1307_Lee" ----------------------------------------------------------------
;
; Se leen las variables de tiempo del DS1307 y se guardan en los registros correspondientes.
;
DS1307_Lee
	bcf	I2C_UltimoByteLeer
	call	I2C_EnviaStart		; Envía condición de Start.
	movlw	DS1307_DireccionEscritura	; Indica al DS1307 que el primer byte
	call	I2C_EnviaByte		; a leer está en la posición 00H, que corresponde
	movlw	0x00			; a los segundos.
	call	I2C_EnviaByte
	call	I2C_EnviaStop		; Envía condición de Stop.
					; Ahora va a leer el DS1307.
	call	I2C_EnviaStart		; Envía condición de Start.
	movlw	DS1307_DireccionLectura
	call	I2C_EnviaByte
	call	I2C_LeeByte		; Lee los segundos.
	movwf	Segundo			; Lo carga en el registro correspondiente.
	call	I2C_LeeByte		; Lee el resto de los registros utilizando
	movwf	Minuto			; el mismo procedimiento.
	call	I2C_LeeByte
	movwf	Hora
	call	I2C_LeeByte
	movwf	DiaSemana
	call	I2C_LeeByte
	movwf	Dia
	call	I2C_LeeByte
	movwf	Mes
	bsf	I2C_UltimoByteLeer	; Para terminar.
	call	I2C_LeeByte
	movwf	Anho
	call	I2C_EnviaStop		; Acaba de leer.
	return

; Subrutina "DS1307_CargaInicial" -------------------------------------------------------
;
; Realiza una carga inicial en los registros internos del reloj-calendario DS1307 a fecha
; Lunes, 1 de Enero de 2004 a las 0:00:00.
;
DS1307_CargaInicial
	movlw	.1			; Inicializa todos los datos del reloj: Año, mes,
	movwf	Dia			; día, día de la semana, hora, minuto y segundo.
	movwf	Mes
	movwf	DiaSemana
	movlw	.4
	movwf	Anho			; Inicializa en el año 2004.
	clrf	Hora
	clrf	Minuto
	clrf	Segundo			; Después lo graba en el DS1307 para
;	call	DS1307_Escribe		; ponerlo en marcha.
;	return
;
; Subrutina "DS1307_Escribe" ----------------------------------------------------------------
;
; Carga los datos de los registros Anho, Mes, etc., dentro del DS1307.

DS1307_Escribe
	call	I2C_EnviaStart		; Envía condición de Start.
	movlw	DS1307_DireccionEscritura	; Indica al DS1307 que el primer byte a escribir
	call	I2C_EnviaByte		; está en la posición 00h que corresponde
	movlw	0x00			; a los segundos.
	call	I2C_EnviaByte
	movf	Segundo,W		; Pasa los segundos de la memoria del PIC16F84A al
	call	I2C_EnviaByte		; DS1307.
	movf	Minuto,W		; Y se repite el proceso para el resto.
	call	I2C_EnviaByte
	movf	Hora,W
	call	I2C_EnviaByte
	movf	DiaSemana,W
	call	I2C_EnviaByte
	movf	Dia,W
	call	I2C_EnviaByte
	movf	Mes,W
	call	I2C_EnviaByte
	movf	Anho,W
	call	I2C_EnviaByte
	call	I2C_EnviaStop		; Termina de enviar datos.
	return

;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================

