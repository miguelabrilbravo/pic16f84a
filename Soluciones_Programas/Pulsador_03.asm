;************************************ Pulsador_03.asm ***********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Simula un dado electrónico que cuenta de 1 a 6. Mientras se mantenga presionado un pulsador,
; el display contará de 1 a 6 continuamente, manteniéndose un instante en cada valor. Cuando
; deje de estar pulsador permanecerá el último valor visualizado. Aquí el tema de los rebotes
; no es importante.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	Contador			; El contador a visualizar.
	ENDC

#DEFINE Pulsador	PORTA,4		; Pulsador conectado a RA4.
#DEFINE Display		PORTB		; El display está conectado al Puerto B.

; ZONA DE CÓDIGOS ********************************************************************

	ORG	0			; El programa comienza en la dirección 0.
Inicio
  	bsf	STATUS,RP0		; Acceso al Banco 1.
	clrf	Display			; Estas líneas configuradas como salidas.
	bsf	Pulsador		; Línea del pulsador configurada como entrada.
	bcf	STATUS,RP0		; Acceso al Banco 0.
	call	InicializaContador
Principal
	btfss	Pulsador		; ¿Pulsador reposo?, ¿Pulsador=1?
	call	IncrementaVisualiza	; Incrementa el contador y lo visualiza.
Fin	goto	Principal

; Subrutina "IncrementaVisualiza" ---------------------------------------------------------

IncrementaVisualiza
	incf	Contador,F		; Incrementa el contador y comprueba si ha
	movlw 	d'7'			; llegado a su valor máximo mediante una
	subwf	Contador,W		; resta. (W)=(Contador)-7.
	btfss	STATUS,C		; ¿C=1?, ¿(W) positivo?, ¿(Contador)>=7?
	goto	Visualiza		; No, pues salta a visualizar.
InicializaContador
	movlw	.1			; Inicializa el Contador y lo visualiza.
	movwf	Contador
Visualiza
	movf	Contador,W
	call	Numero_a_7Segmentos	; Lo pasa a siete segmentos para visualizarlo
	movwf	Display			; en el display.
	return

	INCLUDE <DISPLAY_7S.INC>	; Subrutina Numero_a_7Segmentos.
	END				; Fin del programa.

;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
