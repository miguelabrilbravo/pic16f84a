;************************************ Pulsador_01.asm ***********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Cada vez que presione el pulsador conectado al pin RA4 incrementa un contador visualizado
; en el display.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	Contador				; El contador a visualizar.
	ENDC

#DEFINE Pulsador	PORTA,4			; Pulsador conectado a RA4.
#DEFINE Display	PORTB			; El display está conectado al Puerto B.

; ZONA DE CÓDIGOS ********************************************************************

	ORG	0			; El programa comienza en la dirección 0.
Inicio
  	bsf	STATUS,RP0		; Acceso al Banco 1.
	clrf	Display			; Estas líneas configuradas como salidas.
	bsf	Pulsador			; Línea del pulsador configurada como entrada.
	bcf	STATUS,RP0		; Acceso al Banco 0.
	call	InicializaContador		; Inicializa el Contador y lo visualiza.
	call	Visualiza
Principal
	btfsc	Pulsador			; ¿Pulsador presionado?, ¿(Pulsador)=0?
	goto	Fin			; No. Vuelve a leerlo.
	call	Retardo_20ms		; Espera que se estabilicen los niveles de tensión.
	btfsc	Pulsador			; Comprueba si es un rebote.
	goto	Fin			; Era un rebote y sale fuera.
	call	IncrementaVisualiza		; Incrementa el contador y lo visualiza.
EsperaDejePulsar
	btfss	Pulsador			; ¿Dejó de pulsar?. ¿(Pulsador)=1?
	goto	EsperaDejePulsar		; No. Espera que deje de pulsar.
Fin	goto	Principal

; Subrutina "IncrementaVisualiza" ---------------------------------------------------------

IncrementaVisualiza
	incf	Contador,F		; Incrementa el contador y comprueba si ha
	movlw 	d'10'			; llegado a su valor máximo mediante una
	subwf	Contador,W		; resta. (W)=(Contador)-10.
	btfsc	STATUS,C		; ¿C=0?, ¿(W) negativo?, ¿(Contador)<10?
InicializaContador
	clrf	Contador			; No, era igual o mayor. Por tanto, resetea.
Visualiza
	movf	Contador,W
	call	Numero_a_7Segmentos	; Lo pasa a siete segmento para poder ser
	movwf	Display			; visualizado en el display.
	return

	INCLUDE <DISPLAY_7S.INC>	; Subrutina Numero_a_7Segmentos
	INCLUDE <RETARDOS.INC>	; Subrutinas de retardo.
	END				; Fin del programa.
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
