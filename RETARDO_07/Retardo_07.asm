;************************************ Retardo_07.asm ************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Por la barra de diodos LEDs conectada al puerto de salida un LED encendido rota a la
; izquierda 0,2 s en cada posición. Cuando llega al final se apagan todos los LEDs
; y de nuevo repite la operación. Hay que realizarlo mediante una tabla.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	TablaLongitud
	TablaPosicion
	ENDC

; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0
Inicio
	bsf	STATUS,RP0
	clrf	PORTB
	bcf	STATUS,RP0
Principal
	movlw	TablaFin-TablaInicio	; Calcula la longitud de la tabla y la carga en
	movwf	TablaLongitud		; este registro que actuará como contador.	
	clrf	TablaPosicion		; Apunta a la primera posición de la tabla.
VisualizaOtraPosicion
	movf	TablaPosicion,W		; Posición de la tabla a leer.
	call	LeeTabla		; Visualiza la posición de la tabla.
	movwf	PORTB			; El resultado se visualiza por la salida.
	call	Retardo_200ms		; Durante el tiempo estimado.
	incf	TablaPosicion,F		; Apunta a la siguiente posición por visualizar.
	decfsz	TablaLongitud,F		; ¿Ha terminado la tabla?
	goto	VisualizaOtraPosicion	; No, pues visualiza la siguiente posición.	
	goto 	Principal		; Y repite el proceso.
;
; Subrutina "LeeTabla" ------------------------------------------------------------------
;
LeeTabla
	addwf	PCL,F
TablaInicio				; Para indicar la posición inicial de la tabla.
	retlw	b'00000000'
	retlw	b'00000001'
	retlw	b'00000010'
	retlw	b'00000100'
	retlw	b'00001000'
	retlw	b'00010000'
	retlw	b'00100000'
	retlw	b'01000000'
	retlw	b'10000000'
TablaFin				; Para indicar la posición final de la tabla.

	INCLUDE <RETARDOS.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
