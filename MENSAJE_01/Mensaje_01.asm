;************************************ Mensaje_01.asm ***********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; En la pantalla del m�dulo LCD se visualiza un mensaje de menos de 16 caracteres grabado
; en la memoria ROM mediante la directiva DT.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	LCD_ApuntaCaracter		; Indica la posici�n del car�cter a visualizar
					; respecto del comienzo de todos los mensajes
					; (posici�n de la etiqueta "Mensajes").
	LCD_ValorCaracter		; Valor del c�digo ASCII del car�cter a 
	ENDC				; visualizar.

; ZONA DE C�DIGOS ********************************************************************

	ORG	0
Inicio
	call	LCD_Inicializa
	clrf	LCD_ApuntaCaracter	; Se visualizar� la primera posici�n del mensaje.
LCD_VisualizaOtroCaracter
	movf	LCD_ApuntaCaracter,W
	call	Mensajes		; Obtiene el c�digo ASCII del car�cter apuntado.
	movwf	LCD_ValorCaracter	; Guarda el valor de car�cter.
	movf	LCD_ValorCaracter,F	; Lo �nico que hace es posicionar flag Z. En caso
	btfsc	STATUS,Z		; que sea "0x00", que es c�digo indicador final	
	goto	Fin			; de mensaje, sale fuera.
LCD_NoUltimoCaracter
	call	LCD_Caracter		; Visualiza el car�cter ASCII le�do.
	incf	LCD_ApuntaCaracter,F	; Apunta a la posici�n del siguiente car�cter 
	goto	LCD_VisualizaOtroCaracter	; dentro del mensaje.
Fin	sleep				; Pasa a modo bajo consumo.

; Subrutina "Mensajes" ---------------------------------------------------------------
;
Mensajes
	addwf	PCL,F
Mensaje0				; Posici�n inicial del mensaje.
	DT "Hola!, que tal?", 0x00

	INCLUDE  <LCD_4BIT.INC>
	INCLUDE  <RETARDOS.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
