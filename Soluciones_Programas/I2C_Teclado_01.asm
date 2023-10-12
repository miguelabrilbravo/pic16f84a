;********************************* I2C_Teclado_01.asm ************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Programa para comprobar el funcionamiento y control de un teclado hexadecimal conectado a un
; bus I2C a través de un expansor PCF8574 tal como se indica en el esquema correspondiente.
; El módulo LCD visualiza el valor hexadecimal de la tecla pulsada.
; 
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST 	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	ENDC

#DEFINE  Zumbador	PORTB,2		; Aquí se conecta el zumbador.

; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0
	goto	Inicio
	ORG	4	
	goto	ServicioInterrupcion
Inicio
	call	LCD_Inicializa
	bsf	STATUS,RP0		; Acceso Banco 1.
	bcf	Zumbador		; La línea del zumbador se define como salida.
	bcf	STATUS,RP0		; Acceso Banco 0.
	call	PitidoCorto		; Pitido al conectarlo.
	call	Teclado_Inicializa		; Prepara al PCF8574 para interrumpir.
	movlw	b'10010000'		; Habilita la interrupción INT y la general.
	movwf	INTCON
Principal
	sleep 				; Pasa a modo de bajo consumo.
	goto 	Principal

; Subrutina "ServicioInterrupcion" ------------------------------------------------------
;
; Lee el teclado conectado al PCF8574 y el resultado se visualiza en la pantalla.

ServicioInterrupcion
	call	Teclado_LeeHex		; Obtiene el valor hex. de la tecla pulsada.
	call	LCD_Nibble		; Sí, ha pulsado. Visualiza el valor en la
	call	PitidoCorto		; pantalla y suena un pitido en el zumbador.
	call	Teclado_EsperaDejePulsar	; Para que no se repita el mismo carácter.
	bcf	INTCON,INTF
	retfie

; Subrutina "PitidoCorto" ---------------------------------------------------------------
;
PitidoCorto
	bsf	Zumbador
	call	Retardo_20ms
	bcf	Zumbador
	return

	INCLUDE  <PCF8574_Teclado.INC>
	INCLUDE  <BUS_I2C.INC>
	INCLUDE  <PCF8574.INC>
	INCLUDE  <RETARDOS.INC>
	INCLUDE  <LCD_4BIT.INC>
	END

;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
