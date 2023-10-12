;************************************ Retardo_09.asm ************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; El el display debe visualizarse un mensaje grabado en la memoria ROM mediante la directiva
; DT. Se utilizar� la misma t�cnica que para la visualizaci�n de los juegos de luces
; anteriores.

; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	MensajeLongitud
	MensajePosicion
	ENDC

; ZONA DE C�DIGOS ********************************************************************

	ORG 	0
Inicio
	bsf	STATUS,RP0
	clrf	PORTB
	bcf	STATUS,RP0
Principal
	movlw	MensajeFin-MensajeInicio
	movwf	MensajeLongitud		; Este ser� el contador.
	clrf	MensajePosicion		; Apunta a la primera posici�n del mensaje.
VisualizaOtroCaracter
	movf	MensajePosicion,W	; Aqu� posici�n a leer del mensaje.
	call	LeeCaracter		; Visualiza la posici�n del mensaje.
	call	ASCII_a_7Segmentos	; Lo pasa a 7 Segmentos.
	movwf	PORTB			; El resultado se visualiza por la salida.
	call	Retardo_500ms		; Durante el tiempo estimado.
	incf	MensajePosicion,F	; Apunta a la siguiente posici�n por visualizar.
	decfsz	MensajeLongitud,F	; Si hay m�s posiciones por visualizar.
	goto	VisualizaOtroCaracter	; Vuelve a visualizar la siguiente posici�n.	
	goto 	Principal
;
; Subrutina "LeeCaracter" ---------------------------------------------------------------
;
LeeCaracter
	addwf	PCL,F	
MensajeInicio				; Posici�n inicial del mensaje.
	DT " CICLOS FORMATIVOS DE ELECTRONICA.  "
MensajeFin				; Para indicar la posici�n final del mensaje.
;
	INCLUDE  <DISPLAY_7S.INC>
	INCLUDE  <RETARDOS.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
