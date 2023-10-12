;************************************ Retardo_13.asm ************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Por la barra de LEDs conectada al puerto de salida se visualiza un juegos de luces.
;
; La velocidad del movimiento será fijada por la lectura de las tres líneas conectadas
; al puerto A, de manera que se visualice cada posición durante un tiempo:
;  - Si (PORTA)=0, cada posición se visualiza durante 0 x 100 ms =  0 ms. (Apagado).
;  - Si (PORTA)=1, cada posición se visualiza durante 1 x 100 ms = 100 ms. aproximadamente.
;  - Si (PORTA)=2, cada posición se visualiza durante 2 x 100 ms = 200 ms. aproximadamente.
;	    .... ( y así sucesivamente hasta...)
;  - Si (PORTA)=7, cada posición se visualiza durante 7 x 100 ms = 700 ms. aproximadamente.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	TablaLongitud
	TablaPosicion
	ContadorTiempo
	GuardaContador
	ENDC

; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0	
Inicio
	bsf	STATUS,RP0
	clrf	PORTB
	movlw	b'00000111'
	movwf	PORTA
	bcf	STATUS,RP0
Principal
	clrf	PORTB			; En principio el puerto de salida apagado.		
	movf	PORTA,W			; Lee el puerto de entrada.
	andlw	b'00000111'		; Se queda con la información válida.
	movwf	ContadorTiempo		; Lo pasa al contador
	movwf	GuardaContador		; y a su copia.
	movf	ContadorTiempo,F	; Comprueba si es cero.
	btfsc	STATUS,Z		; Si es cero sale fuera.
	goto	Fin
	movlw	TablaFin-TablaInicio	; Calcula la longitud de la tabla y la carga en
	movwf	TablaLongitud		; este registro que actuará como contador.	
	clrf	TablaPosicion		; Apunta a la primera posición de la tabla.
VisualizaOtraPosicion
	movf	TablaPosicion,W		; Aquí posición a leer de la tabla.
	call	LeeTabla		; Visualiza la posición de la tabla.
	movwf	PORTB			; El resultado se visualiza por la salida.
	movf	GuardaContador,W	; Recupera el valor del contador.
	movwf	ContadorTiempo
MantieneVisualizacion			; Durante un tiempo igual a (ContadorTiempo)x100 ms.
	call	Retardo_100ms	
	decfsz	ContadorTiempo,F
	goto	MantieneVisualizacion
	incf	TablaPosicion,F		; Apunta a la siguiente posición por visualizar.
	decfsz	TablaLongitud,F		; ¿Ha terminado la tabla?
	goto	VisualizaOtraPosicion	; No, pues visualiza la siguiente posición.	
Fin	goto 	Principal

; Subrutina "LeeTabla" ------------------------------------------------------------------
;
LeeTabla
	addwf	PCL,F
TablaInicio				; Indica la posición inicial de la tabla.
	retlw	b'00000000'
	retlw	b'10000001'
	retlw	b'01000010'
	retlw	b'00100100'
	retlw	b'00011000'
	retlw	b'00111100'
	retlw	b'01111110'
	retlw	b'11111111'
	retlw	b'11100111'
	retlw	b'11000011'
	retlw	b'10000001'
	retlw	b'10000001'
	retlw	b'11000011'
	retlw	b'11100111'
	retlw	b'11111111'
	retlw	b'11111111'
	retlw	b'01111110'
	retlw	b'00111100'
	retlw	b'00011000'
	retlw	b'00100100'
	retlw	b'01000010'
	retlw	b'10000001'
TablaFin				; Indica la posición final de la tabla.

	INCLUDE <RETARDOS.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
