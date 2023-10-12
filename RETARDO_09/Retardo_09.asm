;************************************ Retardo_09.asm ************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; El el display debe visualizarse un mensaje grabado en la memoria ROM mediante la directiva
; DT. Se utilizará la misma técnica que para la visualización de los juegos de luces
; anteriores.

; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	MensajeLongitud
	MensajePosicion
	ENDC

; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0
Inicio
	bsf	STATUS,RP0
	clrf	PORTB
	bcf	STATUS,RP0
Principal
	movlw	MensajeFin-MensajeInicio
	movwf	MensajeLongitud		; Este será el contador.
	clrf	MensajePosicion		; Apunta a la primera posición del mensaje.
VisualizaOtroCaracter
	movf	MensajePosicion,W	; Aquí posición a leer del mensaje.
	call	LeeCaracter		; Visualiza la posición del mensaje.
	call	ASCII_a_7Segmentos	; Lo pasa a 7 Segmentos.
	movwf	PORTB			; El resultado se visualiza por la salida.
	call	Retardo_500ms		; Durante el tiempo estimado.
	incf	MensajePosicion,F	; Apunta a la siguiente posición por visualizar.
	decfsz	MensajeLongitud,F	; Si hay más posiciones por visualizar.
	goto	VisualizaOtroCaracter	; Vuelve a visualizar la siguiente posición.	
	goto 	Principal
;
; Subrutina "LeeCaracter" ---------------------------------------------------------------
;
LeeCaracter
	addwf	PCL,F	
MensajeInicio				; Posición inicial del mensaje.
	DT " CICLOS FORMATIVOS DE ELECTRONICA.  "
MensajeFin				; Para indicar la posición final del mensaje.
;
	INCLUDE  <DISPLAY_7S.INC>
	INCLUDE  <RETARDOS.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
