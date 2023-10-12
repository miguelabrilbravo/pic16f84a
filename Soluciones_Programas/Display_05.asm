;************************************ Display_05.asm ************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Visualiza un car�cter ASCII en el display de 7 segmentos. Utiliza la subrutina 
; "ASCII_a_7Segmentos" contenida en la librer�a "DISPLAY_7S.INC".
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C			; En esta posici�n empieza la RAM de usuario.
	ENDC

Caracter EQU	'P'

; ZONA DE C�DIGOS ********************************************************************

	ORG 	0			; El programa comienza en la direcci�n 0.
Inicio
	bsf	STATUS,RP0		; Acceso al Banco 1.
	clrf	PORTB			; Las l�neas del Puerto B se configuran como salida.
	bcf	STATUS,RP0		; Acceso al Banco 0.
Principal
	movlw	Caracter			; Lee el car�cter de entrada
	call	ASCII_a_7Segmentos	; Convierte a 7 Segmentos.
	movwf	PORTB			; Resultado se visualiza por el puerto de salida.
	goto 	Principal

	INCLUDE  <DISPLAY_7S.INC>	; Subrutina ASCII_a_7Segmentos.
	END				; Fin del programa.
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
