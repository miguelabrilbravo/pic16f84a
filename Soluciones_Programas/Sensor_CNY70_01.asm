;************************************* Sensor_CNY70_01.asm *****************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; En pantalla LCD se visualiza el color "Blanco" o "Negro" que está detectando el sensor CNY70,
; según la configuración del esquema correspondiente. Si:
;  - Color Blanco --> transistor saturado --> entrada al inversor "0" --> RA3 = "1".
;  - Color Negro  --> transistor en corte --> entrada al inversor "1" --> RA3 = "0".
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	ENDC

#DEFINE  Sensor PORTA,3			; Líneas donde se conecta el sensor.

; ZONA DE CÓDIGOS ********************************************************************

	ORG	0
Inicio
	call	LCD_Inicializa
	movlw	MensajeColor
	call	LCD_Mensaje
	bsf	STATUS,RP0
	bsf	Sensor			; Línea del sensor se configura como entrada. 
	bcf	STATUS,RP0
Principal
	call	LCD_Linea2
	movlw	MensajeNegro		; En principio considera que es negro.
	btfsc	Sensor			; Lee el sensor.
	movlw	MensajeBlanco		; No, es blanco.
	call	LCD_Mensaje		; Visualiza el resultado.
	goto	Principal
	
; "Mensajes" ----------------------------------------------------------------------------
;
Mensajes
	addwf	PCL,F
MensajeColor
	DT "    Color", 0x00
MensajeBlanco
	DT "    BLANCO", 0x00
MensajeNegro
	DT "    negro ", 0x00

	INCLUDE  <RETARDOS.INC>
	INCLUDE  <LCD_4BIT.INC>
	INCLUDE  <LCD_MENS.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
