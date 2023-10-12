;************************************** LCD_02.asm **************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; El módulo LCD visualiza el mensaje "Hola". La escritura de cada letra se realiza cada
; 500 ms. Después se borra y comienza de nuevo.
;       
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK 0x0C
	ENDC

; ZONA DE CÓDIGOS ********************************************************************

	ORG	0
Inicio
	call	LCD_Inicializa
Principal
	movlw	'H'
	call	LCD_Caracter
	call	Retardo_500ms
	movlw	'o'
	call	LCD_Caracter
	call	Retardo_500ms
	call	LCD_Linea2		;el siguiente caracter se escribira en la linea 2
	movlw	'l'
	call	LCD_Caracter
	call	Retardo_500ms
	movlw	'a'
	call	LCD_Caracter
	call	Retardo_500ms
	call	LCD_Borra		; Borra la pantalla.
	call	Retardo_500ms
	goto	Principal

	INCLUDE <LCD_4BIT.INC>
	INCLUDE <RETARDOS.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
