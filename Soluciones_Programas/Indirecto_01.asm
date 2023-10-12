;*********************************** Indirecto_01.asm ***********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Este programa comprueba el funcionamiento del direccionamiento indirecto. Se trata de
; escribir con el valor de una constante a partir de la �ltima direcci�n ocupada de
; la memoria RAM de datos hasta el final.
; Su correcto funcionamiento debe comprobarse con el simulador del MPLAB.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF  &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK	0x0C
	RAM_Contador
	ENDC

Constante		EQU	2Ah		; Por ejemplo.
RAM_UltimaDireccion  EQU	4Fh		; Ultima direcci�n de RAM de datos utilizada para
					; el PIC16F84A.
; ZONA DE C�DIGOS ********************************************************************

	ORG 	0
Inicio
	movlw	RAM_UltimaDireccion-RAM_Contador	; N�mero de posiciones a escribir.
	movwf	RAM_Contador
	movlw	RAM_Contador+1		; Primera posici�n de RAM libre.
	movwf	FSR			; Primera direcci�n de memoria RAM a escribir
RAM_EscribeConstante
	movlw	Constante			; Escribe el valor de la constante en la posici�n
	movwf	INDF			; apuntada por FSR. (W) -> ((FSR))
	incf	FSR,F			; Apunta a la siguiente direcci�n de memoria.
	decfsz	RAM_Contador,F
	goto	RAM_EscribeConstante
Principal
	sleep				; Pasa a reposo.

	END

;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
