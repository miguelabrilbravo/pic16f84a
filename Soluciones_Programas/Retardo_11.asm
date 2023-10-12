;************************************ Retardo_11.asm ************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Por el display conectado al puerto de salida se visualizará un contador descendente que
; cuenta desde la cantidad leída por el puerto de entrada hasta cero y vuelve a repetir.
; Cada dígito se visualizará durante un segundo. Por ejemplo, si por el puerto de entrada
; se lee "---00101" en el display se visualizarán las cantidades: 5, 4, 3, 2, 1, 0, 5,
; 4, 3, ... Si en la entrada se lee una cantidad mayor de 9 o un 0 se encenderá
; únicamente el punto decimal del display.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	Contador
	ENDC

; ZONA DE CÓDIGOS ********************************************************************

	ORG	0
Inicio
	bsf	STATUS,RP0		; Acceso al Banco 1.
	clrf	PORTB			; Las líneas del Puerto B como salidas.
	movlw	0xFF			; Las líneas del Puerto A como entradas.
	movwf	PORTA
	bcf	STATUS,RP0		; Acceso al Banco 0.
Principal
	movf	PORTA,W			; Lee los interruptores. 
	movwf	Contador	 	; Guarda el contenido de la entrada.
	movf	Contador,F		; Se hace ésto sólo para posicionar el flag Z.
	btfsc	STATUS,Z		; Comprueba si es cero.
	goto	PuntoDecimal		; Si es cero, visualiza el punto decimal.
	sublw	d'9'			; Si es mayor de 9, activa punto decimal.
	btfss	STATUS,C
	goto	PuntoDecimal
Visualiza
	call	VisualizaContador	; Lo pasa a siete segmento  y visualiza.
	decfsz	Contador,F		; Decrementa del contador.
	goto	Visualiza
	call	VisualizaContador	; Visualiza el cero.
	clrf	PORTB			; Apaga el display durante un segundo.
	call	Retardo_1s
	goto	Fin			; Repite el ciclo
PuntoDecimal
	movlw	b'10000000'		; Enciende sólo el punto décimal. 
	movwf	PORTB
Fin	goto	Principal
;
; Subrutina "VisualizaContador" ---------------------------------------------------------
;
VisualizaContador
	movf	Contador,W
	call	Numero_a_7Segmentos	; Lo pasa a siete segmentos para poder ser
	movwf	PORTB			; visualizado en el display.
	call	Retardo_1s		; Durante este tiempo.
	return

	INCLUDE <DISPLAY_7S.INC>
	INCLUDE <RETARDOS.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
