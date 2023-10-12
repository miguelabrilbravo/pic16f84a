;*********************************** Subrutinas_03.asm **********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; El valor del puerto de entrada PORTA es convertido a BCD y el resultado se visualiza
; por el puerto de salida PORTB. Así por ejemplo, si por el PORTA se lee "---10111"
; (23 en decimal) por el PORTB se visualizará "00100011".
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C			; En esta posición empieza la RAM de usuario.
	ENDC

; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0			; El programa comienza en la dirección 0.
Inicio
	bsf	STATUS,RP0		; Acceso al Banco 1.
	clrf	TRISB			; Las líneas del Puerto B se configuran como salida.
	movlw	b'00011111'		; Las 5 líneas del Puerto A se configuran como entrada.
	movwf	TRISA
	bcf	STATUS,RP0		; Acceso al Banco 0.
Principal
	movf	PORTA,W			; Carga el número a convertir.
	call	BIN_a_BCD		; Lo pasa a BCD.
	movwf	PORTB			; Resultado se visualiza por el puerto de salida.
	goto	Principal		; Se queda permanentemente en este bucle.

	INCLUDE  <BIN_BCD.INC>		; La subrutina se añadirá al final del programa
	END				; principal.
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
