;************************************** Teclado_01.asm **********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; El módulo LCD visualiza el orden de la tecla pulsada expresado en decimal. Utiliza 
; técnica Polling o lectura constante del puerto al que está conectado el teclado.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	ENDC

; ZONA DE CÓDIGOS ********************************************************************

	ORG	0
Inicio
	call	LCD_Inicializa
	call	Teclado_Inicializa	; Configura las líneas del teclado.
Principal
	call	Teclado_LeeOrdenTecla	; Lee el teclado.
	btfss	STATUS,C		; ¿Pulsa alguna tecla?, ¿C=1?
	goto	Fin			; No, por tanto sale.
	call	BIN_a_BCD		; Lo pasa a BCD.
	call	LCD_ByteCompleto	; Visualiza en pantalla.
	call	Teclado_EsperaDejePulsar; No sale hasta que levante el dedo.
Fin	goto	Principal

	INCLUDE  <TECLADO.INC>		; Subrutinas de control del teclado.
	INCLUDE  <BIN_BCD.INC>
	INCLUDE  <LCD_4BIT.INC>
	INCLUDE  <RETARDOS.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
