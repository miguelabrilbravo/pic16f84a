;************************************** LCD_03.asm *************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Programa ejemplo para comprender la utilizaci�n de las subrutinas "LCD_ByteCompleto",
; "LCD_Byte", "LCD_Nibble" y "LCD_DosEspaciosBlancos"
;
; Para ello se van a utilizar sucesivamente y en este orden las subrutinas: 
; "LCD_ByteCompleto", "LCD_DosEspaciosBlancos", "LCD_Byte",
; "LCD_DosEspaciosBlancos" y "LCD_Nibble" para dos n�meros que ser�n:
;
; - En la primera l�nea del LCD un n�mero con el nibble alto no cero. Por ejemplo: 1Dh.
; - En la segunda l�nea del LCD un n�mero con el nibble alto igual a cero. Ejemplo: 0Dh.
;
; As� por ejemplo, para los n�meros "1D" y "0D" se visualizar�a (donde "#" viene a significar
; espacio en blanco):
; "1D##1D##D"	(Primera l�nea).
; "0D###D##D"	(Segunda l�nea).
;       
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK	0x0C
	ENDC

Numero_NoCeroAlto	EQU	0x1D	; N�mero ejemplo nibble alto no cero.
Numero_CeroAlto		EQU	0x0D	; N�mero ejemplo nibble alto cero.

; ZONA DE C�DIGOS ********************************************************************

	ORG	0
Inicio
	call	LCD_Inicializa
Principal
	movlw	Numero_NoCeroAlto
	call	LCD_ByteCompleto
	call	LCD_DosEspaciosBlancos
	movlw	Numero_NoCeroAlto
	call	LCD_Byte
	call	LCD_DosEspaciosBlancos
	movlw	Numero_NoCeroAlto
	call	LCD_Nibble
	call	LCD_Linea2		; Se sit�a en la segunda l�nea.
	movlw	Numero_CeroAlto
	call	LCD_ByteCompleto
	call	LCD_DosEspaciosBlancos
	movlw	Numero_CeroAlto
	call	LCD_Byte
	call	LCD_DosEspaciosBlancos
	movlw	Numero_CeroAlto
	call	LCD_Nibble
	sleep

	INCLUDE  <LCD_4BIT.INC>
	INCLUDE  <RETARDOS.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================