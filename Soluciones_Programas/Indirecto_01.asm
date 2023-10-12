;*********************************** Indirecto_01.asm ***********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Este programa comprueba el funcionamiento del direccionamiento indirecto. Se trata de
; escribir con el valor de una constante a partir de la última dirección ocupada de
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
RAM_UltimaDireccion  EQU	4Fh		; Ultima dirección de RAM de datos utilizada para
					; el PIC16F84A.
; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0
Inicio
	movlw	RAM_UltimaDireccion-RAM_Contador	; Número de posiciones a escribir.
	movwf	RAM_Contador
	movlw	RAM_Contador+1		; Primera posición de RAM libre.
	movwf	FSR			; Primera dirección de memoria RAM a escribir
RAM_EscribeConstante
	movlw	Constante			; Escribe el valor de la constante en la posición
	movwf	INDF			; apuntada por FSR. (W) -> ((FSR))
	incf	FSR,F			; Apunta a la siguiente dirección de memoria.
	decfsz	RAM_Contador,F
	goto	RAM_EscribeConstante
Principal
	sleep				; Pasa a reposo.

	END

;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
