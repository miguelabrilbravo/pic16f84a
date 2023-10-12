;************************************** Mensaje_09.asm **********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; En pantalla visualiza "Cerrado" o "Abierto" según si un pulsador está presionado o no.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	ENDC

#DEFINE  Pulsador PORTA,4		; Línea donde se conecta el pulsador.

; ZONA DE CÓDIGOS ********************************************************************

	ORG	0
Inicio
	call	LCD_Inicializa
	movlw	MensajePulsador
	call	LCD_Mensaje
	bsf	STATUS,RP0
	bsf	Pulsador		; Línea del pulsador que se configura como entrada. 
	bcf	STATUS,RP0
Principal
	call	LCD_Linea2
	movlw	MensajeCerrado		; En principio considera que está presionado.
	btfsc	Pulsador		; Lee el pulsador.
	movlw	MensajeAbierto		; No, estaba en reposo.
	call	LCD_Mensaje		; Visualiza el resultado.
	goto	Principal
	
; "Mensajes" ----------------------------------------------------------------------------
;
Mensajes
	addwf	PCL,F
MensajePulsador
	DT "    Pulsador"
MensajeAbierto
	DT "    abIERto", 0x00
MensajeCerrado
	DT "    CErraDO", 0x00

	INCLUDE  <RETARDOS.INC>
	INCLUDE  <LCD_4BIT.INC>
	INCLUDE  <LCD_MENS.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
