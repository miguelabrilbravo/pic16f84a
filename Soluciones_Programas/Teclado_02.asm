;************************************** Teclado_02.asm **********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; En pantalla aparece el valor hexadecimal de la tecla pulsada. Se está leyendo constatemente
; el teclado mediante técnica Polling.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	    P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	ENDC

; ZONA DE CÓDIGOS ********************************************************************

	ORG	0
Inicio
	call	LCD_Inicializa
	call	Teclado_Inicializa	; Configura las líneas del teclado.
Principal
	call	Teclado_LeeHex		; Lee el teclado hexadecimal.
	btfss	STATUS,C		; ¿Pulsa alguna tecla?, ¿C=1?
	goto	Fin			; No, por tanto, sale.
	call	LCD_Nibble		; Visualiza el valor en pantalla.
	call	Teclado_EsperaDejePulsar; No sale hasta que levante el dedo.
Fin	goto	Principal

	INCLUDE  <TECLADO.INC>		; Subrutinas de control del teclado.
	INCLUDE  <LCD_4BIT.INC>
	INCLUDE  <RETARDOS.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================

