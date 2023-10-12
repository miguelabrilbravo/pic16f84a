;*********************************** Subrutinas_02.asm **********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Repetir el programa anterior de conversión de un número binario a decimal pero
; utilizando la libreria BIN_BCD.INC.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK	0x0C			; En esta posición empieza la RAM de usuario.
	ENDC

Numero	EQU	.124			; Por ejemplo.

; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0			; El programa comienza en la dirección 0.
Inicio
	bsf	STATUS,RP0		; Acceso al Banco 1.
	clrf	TRISB			; Líneas del Puerto B configuradas como salida.
	bcf	STATUS,RP0		; Acceso al Banco 0.
Principal
	movlw	Numero
	call	BIN_a_BCD
	movwf	PORTB			; El resultado se visualiza por la salida.
	goto	$			; Se queda permanentemente en este bucle.

	INCLUDE  <BIN_BCD.INC>		; La subrutina se añadirá al final del programa 
					; principal
	END				; Fin del programa.
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
