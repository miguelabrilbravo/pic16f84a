;************************************** I2C_Display_01.asm ****************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Visualiza la palabra "HOLA" en los displays de 7 segmentos conectados al SAA1064.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK   0x0C
	ENDC

SAA1064_Direccion  EQU	b'01110000'	; SAA1064 como esclavo en bus I2C

; ZONA DE CÓDIGOS *********************************************************************

	ORG 	0
Inicio
	call	I2C_EnviaStart		; Envia condición de Start.
	movlw	SAA1064_Direccion	; Apunta al SAA1064.
	call	I2C_EnviaByte
	clrw				; El registro de control está en la posición 0.
	call	I2C_EnviaByte
	movlw	b'01000111'		; Palabra de control para luminosidad media
	call	I2C_EnviaByte		; (12 mA) y visualización dinámica multiplexada.
	movlw	'A'			; Escribe la palabra "HOLA" empezando por la
	call	ASCII_a_7Segmentos	; última letra debido a la disposición de los
	call	I2C_EnviaByte		; displays.
	movlw	'L'
	call	ASCII_a_7Segmentos
	call	I2C_EnviaByte
	movlw	'O'
	call	ASCII_a_7Segmentos
	call	I2C_EnviaByte
	movlw	'H'
	call	ASCII_a_7Segmentos
	call	I2C_EnviaByte
	call	I2C_EnviaStop		; Termina de enviar datos.
Principal
	sleep				; Pasa a reposo.
	goto	Principal

	INCLUDE  <DISPLAY_7S.INC>
	INCLUDE  <BUS_I2C.INC>
	INCLUDE  <RETARDOS.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
