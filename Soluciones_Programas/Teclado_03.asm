;************************************* Teclado_03.asm ***********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; El m�dulo LCD visualiza el valor hexadecimal de la tecla pulsada. Para la lectura del
; teclado se utiliza la interrupci�n RBI o por cambio en las l�neas <RB7:RB4> del Puerto B.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	ENDC

; ZONA DE C�DIGOS ********************************************************************

	ORG	0
	goto 	Inicio
	ORG	4
	goto	ServicioInterrupcion
Inicio
	call	LCD_Inicializa
	call	Teclado_Inicializa		; Configura las l�neas del teclado.
	movlw	b'10001000'		; Habilita la interrupci�n RBI y la general.
	movwf	INTCON
Principal
	sleep				; Espera en modo bajo consumo que pulse teclado.
	goto	Principal
	
; Subrutina "ServicioInterrupcion" ------------------------------------------------------
;
ServicioInterrupcion
	call	Teclado_LeeHex		; Obtiene el valor hexadecimal de la tecla pulsada.
	call	LCD_Nibble		; Visualiza el valor en pantalla.
	call	Teclado_EsperaDejePulsar	; Para que no se repita el mismo car�cter 
	bcf	INTCON,RBIF		; mientras permanece pulsado.  Limpia flag.
	retfie

	INCLUDE  <TECLADO.INC>	; Subrutinas de control del teclado.
	INCLUDE  <LCD_4BIT.INC>
	INCLUDE  <RETARDOS.INC>
	END

;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
