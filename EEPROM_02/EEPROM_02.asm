;************************************ EEPROM_02.asm **********************************
;
;	====================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS".
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	====================================================================
;
; Este programa indica un procedimiento para que un prototipo con PIC funcione sólo un
; número determinado de veces fijado por el diseñador.
;
; Cada vez que el sistema es reseteado incrementa un contador, que se guarda en la primera
; posición de la memoria EEPROM de datos del PIC y visualiza en la pantalla. El sistema admite
; un máximo de reseteados (por ejemplo 13), a partir del cual ya no funcionará más. Cada vez
; que se vuelva a alimentar el circuito aparecerá un mensaje de bloqueo. Para que el PIC vuelva
; a funcionar hay que volverlo a grabar.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK	0x0C
	Contador
	ENDC

	ORG	0x2100			; Corresponde a la dirección 0 de la zona EEPROM
					; de datos.
	DE	0x00			; El contador en principio a cero.

NumeroSecreto	EQU	.100

; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0			; El programa comienza en la dirección 0.
Inicio
	call	LCD_Inicializa
	clrw				; Leerá la primera posición de memoria EEPROM.
	call	EEPROM_LeeDato
	movwf	Contador			; Lo guarda.
	movlw	NumeroSecreto		; Ahora lo compara con el número secreto.
	subwf	Contador,W		; Si llega al máximo pasa al modo bloqueado.
	btfsc	STATUS,C
	goto	ModoBloqueado
	movf	Contador,W
	call	BIN_a_BCD		; Se visualiza.
	call	LCD_Byte
	movlw	MensajeReseteado
	call	LCD_Mensaje
	incf	Contador,F		; Incrementa el contador.
	movf	Contador,W		; Ahora se graba en la EEPROM de datos.
	call	EEPROM_EscribeDato
Principal
	sleep				; Pasa a modo de bajo consumo.
	goto	Principal

ModoBloqueado				; La única forma de salir de este bloqueo
	movlw	MensajeBloqueado		; es volver a grabar el PIC.
	call	LCD_Mensaje
	sleep
	goto	ModoBloqueado

Mensajes
	addwf	PCL,F
MensajeReseteado
	DT " reseteados.   ", 0x00
MensajeBloqueado
	DT "Estoy BLOQUEADO.", 0x00

	INCLUDE   <EEPROM.INC>		; Control de la EEPROM de datos del PIC.
	INCLUDE   <RETARDOS.INC>
	INCLUDE   <BIN_BCD.INC>
	INCLUDE   <LCD_4BIT.INC>
	INCLUDE   <LCD_MENS.INC>
	END
	
;	====================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS".
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	====================================================================
