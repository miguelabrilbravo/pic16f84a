;************************************ Mensaje_05.asm ************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; En la primera l�nea de la pantalla aparece un mensaje fijo. En la segunda l�nea aparece
; un mensaje parpadeante.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	ENDC

; ZONA DE C�DIGOS ********************************************************************

	ORG	0
Inicio
	call	LCD_Inicializa
	movlw	MensajeFijo		; Apunta al mensaje fijo y lo visualiza.
	call	LCD_Mensaje
Principal
	call	LCD_Linea2		; Pasa a la segunda l�nea.
	movlw	MensajeParpadeante	; Apunta al mensaje parpadeante.
	call	LCD_Mensaje		; Lo visualiza.
	call	Retardo_500ms		; Durante este tiempo.
	call	LCD_Linea2		; Vuelve a situarse al principio de la l�nea 2.
	call	LCD_LineaEnBlanco	; Visualiza l�nea en blanco.
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
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
