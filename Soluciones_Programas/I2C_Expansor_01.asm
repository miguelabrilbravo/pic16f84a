;************************************ I2C_Expansor_01.asm *****************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Programa para comprobar el funcionamiento del PCF8574 que es un expansor de bus I2C.
; Utiliza dos circuitos integrados tal como se indica en el esquema correspondiente:
;  -  Uno como entrada, leyendo un array de 8 interruptores. Su pin A0 se conecta a masa.
;  -  Otro como salida, visualizando los datos en un array de diodos LEDs. Su pin A0 se 
;     conecta a Vcc.
;
; Este programa lee los switches conectados al PCF8574 que act�a como entrada y su valor se
; visualiza en los LEDs conectados al PCF8574 de salida.
; 
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE   <P16F84A.INC>

	CBLOCK  0x0C
	Dato
	ENDC

PCF8574_DireccionLectura	EQU	b'01000001'
PCF8574_DireccionEscritura	EQU	b'01000010'

#DEFINE  PCB8574_INT	PORTB,0		; L�nea donde se conecta la l�nea de 
					; interrupci�n del expansor de bus I2C.
; ZONA DE C�DIGOS ********************************************************************

	ORG 	0
	goto	Inicio
	ORG	4
	goto	ServicioInterrupcion
Inicio
	bsf	STATUS,RP0		; Acceso Banco 1.
	bsf	PCB8574_INT 		; La l�nea RB0/INT se configura como entrada.
	bcf	OPTION_REG,NOT_RBPU	; Habilita las resistencia de Pull-Up del Puerto B.
	bcf	OPTION_REG,INTEDG	; Interrupci�n INT activa por flanco de bajada.
	bcf	STATUS,RP0		; Acceso Banco 0.
	call	ServicioInterrupcion	; Para que lea y escriba por primera vez.
	movlw	b'10010000'		; Habilita la interrupci�n INT y la general.
	movwf	INTCON
Principal
	sleep				; Pasa a modo de reposo.
	goto	Principal

; Subrutina "ServicioInterrupcion" ------------------------------------------------------
;
; Lee los interruptores conectados al PCF8574 que act�a como entrada y el resultado lo visualiza
; en los diodos LEDs conectados al PCF8574 configurado como salida.

ServicioInterrupcion
	call	Retardo_20ms		; Espera unos instante a que se estabilicen los
	call	PCF8574_Lee		; niveles de tensi�n y lee la entrada.
	movwf	Dato			; Complementa el dato le�do porque los diodos
	comf	Dato,W			; se activan con nivel bajo, (ver esquema).
	call	PCF8574_Escribe		; Lo visualiza en los diodos LEDs.
	bcf	INTCON,INTF
	retfie

	INCLUDE  <BUS_I2C.INC>
	INCLUDE  <PCF8574.INC>	
	INCLUDE  <RETARDOS.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
