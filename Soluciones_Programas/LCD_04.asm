;************************************** LCD_04.asm *************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; El módulo LCD visualiza un contador descendente que cuenta desde 59 hasta 0 y vuelve a
; repetir la cuenta ininterrumpidamente. En cada valor estará unos 500 ms en pantalla.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK	0x0C
	Contador			; El contador a visualizar.
	ENDC

NumeroCarga	EQU	.59

; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0
Inicio
	call	LCD_Inicializa
Principal
	movlw	NumeroCarga		; Realiza carga inicial.
	movwf	Contador
Visualiza
	call	VisualizaContador	; Visualiza el valor del Contador.
	decfsz	Contador,F		; Decrementa el contador hasta llegar a cero.
	goto	Visualiza		; Si no ha llegado a cero visualiza el siguiente.
	call	VisualizaContador	; Ahora también debe visualizar el cero.
	call	LCD_Borra		; Borra la pantalla
	call	Retardo_1s		; durante un segundo.
	goto	Principal		; Repite el proceso.
;
; Subrutina "VisualizaContador" ---------------------------------------------------------
;
VisualizaContador
	call	LCD_Linea1		; Se sitúa en la primera posición de la línea 1.
	movf	Contador,W		; Lo pasa a BCD.
	call	BIN_a_BCD
	call	LCD_Byte		; Visualiza el dato númerico.
	call	Retardo_500ms		; Durante este tiempo.
	return

	INCLUDE  <RETARDOS.INC>
	INCLUDE  <BIN_BCD.INC>
	INCLUDE  <LCD_4BIT.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
