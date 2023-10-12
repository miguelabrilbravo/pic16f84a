;************************************ Mensaje_04.asm ************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; En las dos líneas de la pantalla aparecerán dos mensajes parpadeantes.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK	0x0C
	ENDC

; ZONA DE CÓDIGOS ********************************************************************

	ORG	0
Inicio
	call	LCD_Inicializa
Principal
	movlw	Mensaje0		; Apunta al mensaje de la primera línea y
	call	LCD_Mensaje		; lo visualiza.
	call	LCD_Linea2		; Pasa a la segunda línea.
	movlw	Mensaje1		; Apunta al mensaje de la segunda línea.
	call	LCD_Mensaje		; Lo visualiza.
	call	Retardo_500ms		; Durante este tiempo.
	call	LCD_Borra		; Borra la pantalla.
	call	Retardo_500ms		; Durante este tiempo, produciendo un efecto de
	goto	Principal		; parpadeo.
;
; "Mensajes" ----------------------------------------------------------------------------
;
Mensajes
	addwf	PCL,F
Mensaje0				; Posición inicial del mensaje 0.
	DT "  Estudia   un", 0x00
Mensaje1				; Posición inicial del mensaje 1.
	DT "Ciclo  Formativo", 0x00

	INCLUDE  <LCD_4BIT.INC>
	INCLUDE  <LCD_MENS.INC>
	INCLUDE  <RETARDOS.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
