;************************************** Teclado_07.asm **********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Los valores decimales que va escribiendo por el teclado aparecen en pantalla. Si pulsa cualquier
; otra tecla que no sea un número decimal lo interpreta como tecla de borrado de pantalla.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	ENDC

; ZONA DE CÓDIGOS ********************************************************************

	ORG	0
	goto 	Inicio
	ORG	4
	goto	ServicioInterrupcion
Inicio
	call	LCD_Inicializa
	call	Teclado_Inicializa	; Configura líneas del teclado.
	movlw	b'10001000'		; Habilita la interrupción RBI y la general.
	movwf	INTCON
Principal
	sleep
	goto	Principal

; Subrutina "ServicioInterrupcion" ------------------------------------------------------
;
	CBLOCK
	GuardaValor
	ENDC

ServicioInterrupcion
	call	Teclado_LeeHex		; Obtiene el valor hexadecimal de la tecla pulsada.
	movwf	GuardaValor		; Guarda el valor leído.
	sublw	0x09			; Comprueba si es mayor de 9.
	btfss	STATUS,C
	goto	BorraPantalla		; Si no es un carácter numérico salta a borrar.
	movf	GuardaValor,W		; Recupera el valor leído y lo
	call	LCD_Nibble		; visualiza en la pantalla.
	goto	EsperaDejePulsar
BorraPantalla
	call	LCD_Borra		; Borra la pantalla.
EsperaDejePulsar
	call	Teclado_EsperaDejePulsar; Para que no se repita el mismo carácter.
	bcf	INTCON,RBIF
	retfie

	INCLUDE  <TECLADO.INC>
	INCLUDE  <LCD_4BIT.INC>
	INCLUDE  <RETARDOS.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
