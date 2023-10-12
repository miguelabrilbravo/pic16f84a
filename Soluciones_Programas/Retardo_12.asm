;************************************ Retardo_12.asm ************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Si la línea RA0 del Puerto A es "0", por el display se visualiza un contador descendente
; (9, 8, 7, 6, 5, 4, 3, 2, 1, 0, 9, ..) con una cadencia de 0,5 segundos.
; Si la línea RA0 del Puerto A es "1", por el display se visualizará un contador ascendente
; (0, 1, 2, 3, 5, 6, 7, 8, 9, 0, 1, 2, ..) con una cadencia de 0,5 s.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK 0x0C
	Contador
	ENDC

#DEFINE  Display	PORTB
#DEFINE  PinSeleccion	PORTA,0

; ZONA DE CÓDIGOS ********************************************************************

	ORG	0
Inicio
	bsf	STATUS,RP0
	clrf	Display			; Configurado como salida.
	bsf	PinSeleccion		; Configurado como entrada.
	bcf	STATUS,RP0
Principal
	btfss	PinSeleccion		; Lee este pin para saber lo que tiene que hacer.
	goto	Decrementar		; Es 0, entonces a decrementar.
Incrementar				; Es 1, entonces a incrementar.
	clrf	Contador		; Al incrementar, empieza por 0.
Visualiza_e_Incrementa
	call	VisualizaContador
	incf	Contador,F
	movlw	d'10'			; Comprueba si llega al final de la cuenta.
	subwf	Contador,W		; (W)=(Contador)-10.
	btfss	STATUS,C		; ¿C=1?, ¿(W) positivo?, ¿(Contador)>=10?
	goto	Visualiza_e_Incrementa	; No. Vuelve a visualizar e incrementar.
	goto	Fin			; Sí, resetea y repite el ciclo.
Decrementar
	movlw	.9			; Al decrementar, empieza por 9.
	movwf	Contador
Visualiza_y_Decrementa
	call	VisualizaContador
	decfsz	Contador,F
	goto	Visualiza_y_Decrementa
	call	VisualizaContador 	; Visualiza también el 0.
Fin	clrf	Display			; Se apaga el display y se repite el ciclo.
	call	Retardo_1s
	goto	Principal	

; Subrutina "VisualizaContador" -----------------------------------------------------------

VisualizaContador
	movf	Contador,W
	call	Numero_a_7Segmentos	; Lo pasa a siete segmentos para poder ser
	movwf	Display			; visualizado en el display.
	call	Retardo_500ms		; Durante este tiempo.
	return

	INCLUDE  <DISPLAY_7S.INC>
	INCLUDE  <RETARDOS.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
