;************************************ Retardo_04.asm ************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Por la barra de diodos leds conectada al puerto de salida, un led encendido rota a la
; izquierda 0,3 s en cada posición. Cuando llega al final se apagan todos los leds y
; repite de nuevo la operación.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	ENDC

; ZONA DE CÓDIGOS ********************************************************************

	ORG	0
Inicio
	bsf	STATUS,RP0		; Acceso al Banco 1.
	clrf	PORTB			; Líneas del Puerto B se configuran como salidas.
	bcf	STATUS,RP0		; Acceso al Banco 0.
	bsf	STATUS,C		; Carga el dato inicial en el Carry
	clrf	PORTB			; y en la salida.
Principal
 	;call	Retardo_20ms
	call	Retardo_10ms		; Un retardo total de 300 ms.
	rlf	PORTB,F			; Rota un lugar a la izquierda. 
	goto 	Principal

	INCLUDE  <RETARDOS.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
