;*********************************** Elemental_02.asm ***********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Por el Puerto B se obtiene el dato del Puerto A multiplicado por 2.
; Es decir: (PORTB)=2(PORTA)=(PORTA)+(PORT A).

; ZONA DE DATOS *********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A		; Procesador utilizado.
	INCLUDE  <P16F84A.INC>		; Definición de algunos operandos utilizados.

; ZONA DE CÓDIGOS *******************************************************************

	ORG 	0			; El programa comienza en la dirección 0.

Inicio	bsf	STATUS,RP0		; Pone a 1 el bit 5 del STATUS. Acceso al Banco 1.
	clrf	TRISB			; Las líneas del Puerto B se configuran como salidas.
	movlw	b'00011111'
	movwf	TRISA			; Las líneas del Puerto A como entradas.
	bcf	STATUS,RP0		; Pone a 0 el bit 5 de STATUS. Acceso al Banco 0.
Principal
	movf 	PORTA,W			; Carga el registro de datos del Puerto A en (W).
	addwf	PORTA,W			; (W)=(PORTA)+(PORTA)=2(PORTA).
	movwf	PORTB			; El contenido de W se deposita en el Puerto B.
	goto 	Principal		; Crea un bucle cerrado e infinito.

	END				; Fin del programa.
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
