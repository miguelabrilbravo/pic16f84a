;************************************ Mensaje_05.asm ************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; En la primera línea de la pantalla aparece un mensaje fijo. En la segunda línea aparece
; un mensaje parpadeante.
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
	movlw	MensajeFijo		; Apunta al mensaje fijo y lo visualiza.
	call	LCD_Mensaje
Principal
	call	LCD_Linea2		; Pasa a la segunda línea.
	movlw	MensajeParpadeante	; Apunta al mensaje parpadeante.
	call	LCD_Mensaje		; Lo visualiza.
	call	Retardo_500ms		; Durante este tiempo.
	call	LCD_Linea2		; Vuelve a situarse al principio de la línea 2.
	call	LCD_LineaEnBlanco	; Visualiza línea en blanco.
	call	Retardo_500ms		; Durante este tiempo, produciendo un efecto de
	goto	Principal		; parpadeo.
;
; "Mensajes" ----------------------------------------------------------------------------
;
Mensajes
	addwf	PCL,F
MensajeFijo
	DT "    Estudia    ", 0x00;
MensajeParpadeante
	DT "  ELECTRONICA  ", 0x00	

	INCLUDE  <LCD_4BIT.INC>
	INCLUDE  <LCD_MENS.INC>
	INCLUDE  <RETARDOS.INC>
	END

;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
