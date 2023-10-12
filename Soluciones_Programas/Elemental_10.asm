;*********************************** Elemental_10.asm ***********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Por el Puerto B se obtiene el dato de las cinco líneas del Puerto A al que están conectado
; un array de interruptores. Por ejemplo, si por el Puerto A se introduce "---11001", por
; el Puerto B aparecerá "xxx11001" (el valor de las tres líneas superiores no importa).
;
; Esta operación la realizará una única vez. Después el programa entrará en modo
; "Standby" o de bajo consumo del cual no podrá salir después.

; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC	; Configuración para el
								; grabador.
	LIST	   P=16F84A		; Procesador utilizado.
	INCLUDE  <P16F84A.INC>		; Definición de algunos operandos utilizados.

; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0			; El programa comienza en la dirección 0.
Inicio
	bsf	STATUS,RP0		; Acceso al Banco 1.
	clrf	TRISB			; Las líneas del Puerto B configuradas como salida.
	movlw	b'00011111'		; Las 5 líneas del Puerto A configuradas como entrada.
	movwf	TRISA
	bcf	STATUS,RP0		; Acceso al Banco 0.
Principal
	movf 	PORTA,W			; Carga el registro de datos del Puerto A en W.
	movwf	PORTB			; El contenido de W se deposita en el Puerto B.
	sleep 				; El programa entra en modo "Bajo Consumo" del cual no
					; podrá salir.
	END				; Fin del programa.
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
