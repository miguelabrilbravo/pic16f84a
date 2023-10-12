;************************************ Retardo_08.asm ************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Por la barra de diodos LEDs conectada al puerto de salida se visualizar� un juegos de
; luces que al lector le resulte divertido. Hay que utilizar una tabla de datos.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	TablaLongitud
	TablaPosicion
	ENDC

; ZONA DE C�DIGOS ********************************************************************

	ORG 	0
Inicio
	bsf	STATUS,RP0
	clrf	PORTB
	bcf	STATUS,RP0
Principal
	movlw	TablaFin-TablaInicio	; Calcula la longitud de la tabla y la carga en
	movwf	TablaLongitud		; este registro que actuar� como contador.	
	clrf	TablaPosicion		; Apunta a la primera posici�n de la tabla.
VisualizaOtraPosicion
	movf	TablaPosicion,W		; Posici�n de la tabla a leer.
	call	LeeTabla		; Visualiza la posici�n de la tabla.
	movwf	PORTB			; El resultado se visualiza por la salida.
	call	Retardo_200ms		; Durante el tiempo estimado.
	incf	TablaPosicion,F		; Apunta a la siguiente posici�n por visualizar.
	decfsz	TablaLongitud,F		; �Ha terminado la tabla?
	goto	VisualizaOtraPosicion	; No, pues visualiza la siguiente posici�n.	
	goto 	Principal		; Repite el proceso.
;
; Subrutina "LeeTabla" ------------------------------------------------------------------
;
LeeTabla
	addwf	PCL,F
TablaInicio				; Indica la posici�n inicial de la tabla.
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
TablaFin				; Indica la posici�n final de la tabla.

	INCLUDE  <RETARDOS.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
