;************************************ EEPROM_01.asm **********************************
;
;	====================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS".
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	====================================================================
;
; Este programa comprueba el funcionamiento de la lectura y escritura en la memoria EEPROM de
; datos. Cada vez que el sistema es reseteado se incrementa un contador que se guarda en la
; primera posición de la memoria EEPROM de datos del PIC y es visualizado en el modulo LCD.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A	
	INCLUDE  <P16F84A.INC>	

	CBLOCK   0x0C
	Contador
	ENDC		

	ORG	0x2100			; Corresponde a la dirección 0 de la zona EEPROM
					; de datos.
	DE	0x00			; El contador en principio a cero.
	
; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0			; El programa comienza en la dirección 0.
Inicio
	call	LCD_Inicializa
	clrw				; Leerá la primera posición de memoria EEPROM.
	call	EEPROM_LeeDato
	movwf	Contador			; Se guarda en Contador.
	call	BIN_a_BCD		; Se visualiza en BCD
	call	LCD_Byte		; con nibble alto apagado si es cero.
	movlw	MensajeReseteado
	call	LCD_Mensaje
	incf	Contador,F		; Se incrementa.
	movf	Contador,W		; Ahora se graba en la EEPROM de datos.
	call	EEPROM_EscribeDato
Principal
	sleep				; Pasa a modo de reposo.
	goto	Principal

; "Mensajes" ----------------------------------------------------------------------------
;
Mensajes
	addwf	PCL,F	
MensajeReseteado
	DT " reseteados.   ", 0x00
FinMensajes

	INCLUDE   <EEPROM.INC>		; Subrutinas básicas de control de la EEPROM de
	INCLUDE   <RETARDOS.INC>	; datos del PIC.
	INCLUDE   <BIN_BCD.INC>
	INCLUDE   <LCD_4BIT.INC>
	INCLUDE   <LCD_MENS.INC>
	END

;	====================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS".
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	====================================================================
