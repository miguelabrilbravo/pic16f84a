;************************************* Tablas_06.asm ************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Halla la longitud de un mensaje grabado en la ROM mediante la directiva DT y visualiza
; el resultado en binario por los LEDs de la salida.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK	0x0C			; En esta posici�n empieza la RAM de usuario.
	ENDC

; ZONA DE C�DIGOS ********************************************************************

	ORG 	0			; El programa comienza en la direcci�n 0.
Inicio
	bsf	STATUS,RP0		; Acceso al Banco 1.
	clrf	PORTB			; Las l�neas del Puerto B se configuran como salida.
	bcf	STATUS,RP0		; Acceso al Banco 0.
Principal
	movlw	(MensajeFin-MensajeInicio)	; Halla la longitud del mensaje.
	movwf	PORTB			; Resultado se visualiza por el puerto de salida.
	goto 	Principal
;
MensajeInicio				; Indica la posici�n inicial del mensaje.
	DT	"DESARROLLO DE PRODUCTOS ELECTRONICOS"
MensajeFin				; Indica la posici�n final del mensaje.

	END				; Fin del programa.

;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================

