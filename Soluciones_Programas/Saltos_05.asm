;************************************ Saltos_05.asm *************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Compara el dato del puerto de entrada PORTA con un "Numero". Tres posibilidades:
;   - Si (PORTA) = Numero se encienden todos los LEDs de salida.
;   - Si (PORTA) > Numero se activan los LEDs pares de salida.
;   - Si (PORTA) < Numero se encienden los LEDs del nibble alto y se apagan los del bajo.
;
; Hay que destacar que al no haber instrucciones de comparación, estas se realizan
; mediante restas.

; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A		; Procesador utilizado.
	INCLUDE  <P16F84A.INC>		; Fichero donde se definen las etiquetas del PIC.

Numero	EQU	d'13'			; Por ejemplo, este número a comparar.

; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0			; El programa comienza en la dirección 0.
Inicio
	bsf	STATUS,RP0		; Acceso al Banco 1.
	clrf	TRISB			; Las líneas del Puerto B se configuran como salida.
	movlw	b'00011111'		; Las 5 líneas del Puerto A se configuran como entrada.
	movwf	TRISA
	bcf	STATUS,RP0		; Acceso al Banco 0.
Principal
	movlw	Numero			; Carga el número a comparar.
	subwf	PORTA,W		; (PORTA) - Numero --> (W).
	movlw	b'11110000'		; Supone (PORTA) es menor.
	btfss	STATUS,C		; ¿C=1?, ¿(W) positivo?, ¿(PORTA) >= Numero?.
	goto	ActivaSalida		; No. C=0, por tanto (PORTA) < Numero.
	movlw	b'11111111'		; Supone que son iguales.
	btfsc	STATUS,Z		; ¿Z=0?, ¿son distintos?.
	goto	ActivaSalida		; No. Son iguales ya que Z = 1.
	movlw	b'01010101'		; Sí, por tanto (PORTA) > Numero.
ActivaSalida
	movwf	PORTB			; Resultado se visualiza por el puerto de salida.
	goto 	Principal			; Crea un bucle cerrado e infinito.

	END				; Fin del programa.
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
