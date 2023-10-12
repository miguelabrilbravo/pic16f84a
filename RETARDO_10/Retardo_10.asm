;************************************ Retardo_10.asm **********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; El el display debe visualizarse un mensaje grabado en la memoria ROM mediante la
; directiva DT. En lugar de medir la longitud del mensaje como en programas anteriores,
; detectará el fin de mensaje mediante el código 0x00 grabado al final.

; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	MensajePosicion
	ValorCaracter
	ENDC

; ZONA DE CÓDIGOS ******************************************************************

	ORG 	0
Inicio
	bsf	STATUS,RP0
	clrf	PORTB
	bcf	STATUS,RP0
Principal
	clrf	MensajePosicion		; Apunta a la primera posición del mensaje.
VisualizaOtroCaracter
	movf	MensajePosicion,W	; Aquí posición a leer del mensaje.
	call	Mensajes		; Visualiza el carácter correspondiente.
	movwf	ValorCaracter		; Guarda el valor de carácter.
	movf	ValorCaracter,F		; Lo único que hace es posicionar flag Z. En caso
	btfsc	STATUS,Z		; de que sea "0x00", que es código indicador final	
	goto	Fin			; de mensaje, comienza de nuevo.
NoUltimoCaracter
	call	ASCII_a_7Segmentos	; Lo pasa a 7 Segmentos.
	movwf	PORTB			; El resultado se visualiza por la salida.
	call	Retardo_500ms		; Durante el tiempo estimado.
	incf	MensajePosicion,F	; Apunta a la siguiente posición por visualizar.
	goto	VisualizaOtroCaracter	; Vuelve a visualizar la siguiente posición.
Fin	goto 	Principal
;
; Subrutina "Mensajes" ------------------------------------------------------------------
;
Mensajes
	addwf	PCL,F
	DT " ESTUDIA ELECTRONICA.   ",0x00	; Observa que ha señalado el final del mensaje
					; con el código "0x00".
	INCLUDE  <DISPLAY_7S.INC>
	INCLUDE  <RETARDOS.INC>
	END

;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
