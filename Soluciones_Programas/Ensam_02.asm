;************************************** Ensam_02.asm ************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Los LEDs conectados al nibble bajo del Puerto B se apagan y los conectados al nibble alto
; se encienden.
; 
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC	; Configuración para el
								; grabador.
	LIST	   P=16F84A		; Procesador utilizado.
	INCLUDE  <P16F84A.INC>		; En este fichero se definen las etiquetas del PIC.

Constante  EQU	b'11110000'

; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0			; El programa comienza en la dirección 0 de la
Inicio					; memoria de programa.
	bsf	STATUS,RP0		; Pone a 1 el bit 5 del STATUS. Acceso al Banco 1.
	clrf	TRISB			; Las líneas del Puerto B configuradas como salida.
	bcf	STATUS,RP0		; Pone a 0 el bit 5 del STATUS. Acceso al Banco 0.
	movlw	Constante		; Carga el registro de trabajo W con la constante.
Principal
	movwf	PORTB			; El contenido de W se deposita en el puerto de salida.
	goto 	Principal		; Crea un bucle cerrado e infinito

	END				; Fin del programa.
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
