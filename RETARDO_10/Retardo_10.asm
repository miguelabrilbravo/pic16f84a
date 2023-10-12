;************************************ Retardo_10.asm **********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; El el display debe visualizarse un mensaje grabado en la memoria ROM mediante la
; directiva DT. En lugar de medir la longitud del mensaje como en programas anteriores,
; detectar� el fin de mensaje mediante el c�digo 0x00 grabado al final.

; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	MensajePosicion
	ValorCaracter
	ENDC

; ZONA DE C�DIGOS ******************************************************************

	ORG 	0
Inicio
	bsf	STATUS,RP0
	clrf	PORTB
	bcf	STATUS,RP0
Principal
	clrf	MensajePosicion		; Apunta a la primera posici�n del mensaje.
VisualizaOtroCaracter
	movf	MensajePosicion,W	; Aqu� posici�n a leer del mensaje.
	call	Mensajes		; Visualiza el car�cter correspondiente.
	movwf	ValorCaracter		; Guarda el valor de car�cter.
	movf	ValorCaracter,F		; Lo �nico que hace es posicionar flag Z. En caso
	btfsc	STATUS,Z		; de que sea "0x00", que es c�digo indicador final	
	goto	Fin			; de mensaje, comienza de nuevo.
NoUltimoCaracter
	call	ASCII_a_7Segmentos	; Lo pasa a 7 Segmentos.
	movwf	PORTB			; El resultado se visualiza por la salida.
	call	Retardo_500ms		; Durante el tiempo estimado.
	incf	MensajePosicion,F	; Apunta a la siguiente posici�n por visualizar.
	goto	VisualizaOtroCaracter	; Vuelve a visualizar la siguiente posici�n.
Fin	goto 	Principal
;
; Subrutina "Mensajes" ------------------------------------------------------------------
;
Mensajes
	addwf	PCL,F
	DT " ESTUDIA ELECTRONICA.   ",0x00	; Observa que ha se�alado el final del mensaje
					; con el c�digo "0x00".
	INCLUDE  <DISPLAY_7S.INC>
	INCLUDE  <RETARDOS.INC>
	END

;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
