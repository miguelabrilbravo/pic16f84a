;************************************ EEPROM_03.asm **********************************
;
;	====================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS".
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	====================================================================
;
; Programa de control para las máquinas de tipo "Su Turno" habituales en múltiples comercios.
; En el modulo LCD se visualiza el número de turno actual, que se incrementa cada vez que se
; presiona un pulsador. En la memoria EEPROM de datos del PIC se almacena el último número,
; de forma que, ante un fallo de alimentación reanuda la cuenta correctamente.

; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK   0x0C
	Contador
	ENDC

	ORG	0x2100			; Corresponde a la dirección 0 de la zona EEPROM
NumeroTurno				; de datos.
	DE	0x00			; El número de turno se guarda en esta posición
					; memoria EEPROM de datos.
#DEFINE   Pulsador	PORTA,4

; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0
Inicio
	call	LCD_Inicializa
	bsf	STATUS,RP0
	bsf	Pulsador		; La línea del pulsador se configura como entrada.
	bcf	STATUS,RP0
	movlw	NumeroTurno		; Lee la posición 0x00 de memoria EEPROM de datos
	call	EEPROM_LeeDato		; donde se guarda el turno.
	movwf	Contador		; Se guarda.
	call	Visualiza		; Lo visualiza.
Principal
	btfss	Pulsador		; Lee el pulsador.
	call	IncrementaVisualiza	; Salta a incrementar y visualizar el contador.
	goto	Principal

; Subrutina "IncrementaVisualiza" -------------------------------------------------------

IncrementaVisualiza
	call	Retardo_20ms
	btfsc	Pulsador
	goto	Fin_Visualiza
	incf	Contador,F		; Incrementa el contador y lo visualiza.
Visualiza
	call	LCD_Linea1
	movlw	MensajeSuTurno
	call	LCD_Mensaje
	movlw	.100			; Ahora comprueba si el contador supera la
	subwf	Contador,W		; centena. (W = Contador-100).
	btfsc	STATUS,C		; ¿C=0?, ¿W es negativo?, ¿Contador < 100?
	clrf	Contador		; Pone a cero el contador.
	movf	Contador,W
	call	BIN_a_BCD		; Lo pasa a BCD.
	call	LCD_Byte		; Lo visualiza
	movlw	NumeroTurno		; Se escribe en la posición de memoria EEPROM de
	movwf	EEADR			; datos donde se guarda el turno. En este caso en 
	movf	Contador,W		; la posición 00h de la EEPROM.
	call	EEPROM_EscribeDato
EsperaDejePulsar
	btfss	Pulsador
	goto	EsperaDejePulsar
Fin_Visualiza
	return

Mensajes
	addwf	PCL,F
MensajeSuTurno
	DT "Su Turno: ", 0x00

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
