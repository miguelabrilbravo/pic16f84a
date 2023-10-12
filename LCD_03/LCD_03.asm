;************************************** LCD_03.asm *************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Programa ejemplo para comprender la utilización de las subrutinas "LCD_ByteCompleto",
; "LCD_Byte", "LCD_Nibble" y "LCD_DosEspaciosBlancos"
;
; Para ello se van a utilizar sucesivamente y en este orden las subrutinas: 
; "LCD_ByteCompleto", "LCD_DosEspaciosBlancos", "LCD_Byte",
; "LCD_DosEspaciosBlancos" y "LCD_Nibble" para dos números que serán:
;
; - En la primera línea del LCD un número con el nibble alto no cero. Por ejemplo: 1Dh.
; - En la segunda línea del LCD un número con el nibble alto igual a cero. Ejemplo: 0Dh.
;
; Así por ejemplo, para los números "1D" y "0D" se visualizaría (donde "#" viene a significar
; espacio en blanco):
; "1D##1D##D"	(Primera línea).
; "0D###D##D"	(Segunda línea).
;       
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK	0x0C
	ENDC

Numero_NoCeroAlto	EQU	0x1D	; Número ejemplo nibble alto no cero.
Numero_CeroAlto		EQU	0x0D	; Número ejemplo nibble alto cero.

; ZONA DE CÓDIGOS ********************************************************************

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
	call	LCD_Linea2		; Se sitúa en la segunda línea.
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
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================