;************************************ EEPROM_03.asm **********************************
;
;	====================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS".
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	====================================================================
;
; Programa de control para las m�quinas de tipo "Su Turno" habituales en m�ltiples comercios.
; En el modulo LCD se visualiza el n�mero de turno actual, que se incrementa cada vez que se
; presiona un pulsador. En la memoria EEPROM de datos del PIC se almacena el �ltimo n�mero,
; de forma que, ante un fallo de alimentaci�n reanuda la cuenta correctamente.

; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK   0x0C
	Contador
	ENDC

	ORG	0x2100			; Corresponde a la direcci�n 0 de la zona EEPROM
NumeroTurno				; de datos.
	DE	0x00			; El n�mero de turno se guarda en esta posici�n
					; memoria EEPROM de datos.
#DEFINE   Pulsador	PORTA,4

; ZONA DE C�DIGOS ********************************************************************

	ORG 	0
Inicio
	call	LCD_Inicializa
	bsf	STATUS,RP0
	bsf	Pulsador		; La l�nea del pulsador se configura como entrada.
	bcf	STATUS,RP0
	movlw	NumeroTurno		; Lee la posici�n 0x00 de memoria EEPROM de datos
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
	btfsc	STATUS,C		; �C=0?, �W es negativo?, �Contador < 100?
	clrf	Contador		; Pone a cero el contador.
	movf	Contador,W
	call	BIN_a_BCD		; Lo pasa a BCD.
	call	LCD_Byte		; Lo visualiza
	movlw	NumeroTurno		; Se escribe en la posici�n de memoria EEPROM de
	movwf	EEADR			; datos donde se guarda el turno. En este caso en 
	movf	Contador,W		; la posici�n 00h de la EEPROM.
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
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	====================================================================
