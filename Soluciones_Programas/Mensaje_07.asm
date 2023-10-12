;************************************ Mensaje_07.asm ************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; El m�dulo LCD visualiza un mensaje largo (m�s de 16 caracteres) que se desplaza a lo largo
; de la pantalla. Se utiliza la subrutina LCD_MensajeMovimiento de la librer�a LCD_MENS.INC.
; 
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	ENDC

; ZONA DE C�DIGOS ********************************************************************

	ORG	0
Inicio
	call	LCD_Inicializa		; Prepara la pantalla.
Principal
	movlw	Mensaje0		; Apunta al mensaje.
	call	LCD_MensajeMovimiento
	goto	Principal		; Repite la visualizaci�n.

; "Mensajes" ----------------------------------------------------------------------------
;
Mensajes
	addwf	PCL,F
Mensaje0				; Posici�n inicial del mensaje.
	DT "                 "		; Espacios en blanco al principio para mejor
	DT "Estudia un Ciclo Formativo "	; visualizaci�n.
	DT "de ELECTRONICA."
	DT "                ", 0x0	; Espacios en blanco al final.
;
	INCLUDE  <LCD_MENS.INC>		; Subrutina LCD_MensajeMovimiento.
	INCLUDE  <LCD_4BIT.INC>		; Subrutinas de control del LCD.
	INCLUDE  <RETARDOS.INC>		; Subrutinas de retardos.
	END				; Fin del programa.
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
