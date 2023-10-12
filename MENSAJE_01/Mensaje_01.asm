;************************************ Mensaje_01.asm ***********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; En la pantalla del módulo LCD se visualiza un mensaje de menos de 16 caracteres grabado
; en la memoria ROM mediante la directiva DT.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	LCD_ApuntaCaracter		; Indica la posición del carácter a visualizar
					; respecto del comienzo de todos los mensajes
					; (posición de la etiqueta "Mensajes").
	LCD_ValorCaracter		; Valor del código ASCII del carácter a 
	ENDC				; visualizar.

; ZONA DE CÓDIGOS ********************************************************************

	ORG	0
Inicio
	call	LCD_Inicializa
	clrf	LCD_ApuntaCaracter	; Se visualizará la primera posición del mensaje.
LCD_VisualizaOtroCaracter
	movf	LCD_ApuntaCaracter,W
	call	Mensajes		; Obtiene el código ASCII del carácter apuntado.
	movwf	LCD_ValorCaracter	; Guarda el valor de carácter.
	movf	LCD_ValorCaracter,F	; Lo único que hace es posicionar flag Z. En caso
	btfsc	STATUS,Z		; que sea "0x00", que es código indicador final	
	goto	Fin			; de mensaje, sale fuera.
LCD_NoUltimoCaracter
	call	LCD_Caracter		; Visualiza el carácter ASCII leído.
	incf	LCD_ApuntaCaracter,F	; Apunta a la posición del siguiente carácter 
	goto	LCD_VisualizaOtroCaracter	; dentro del mensaje.
Fin	sleep				; Pasa a modo bajo consumo.

; Subrutina "Mensajes" ---------------------------------------------------------------
;
Mensajes
	addwf	PCL,F
Mensaje0				; Posición inicial del mensaje.
	DT "Hola!, que tal?", 0x00

	INCLUDE  <LCD_4BIT.INC>
	INCLUDE  <RETARDOS.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
