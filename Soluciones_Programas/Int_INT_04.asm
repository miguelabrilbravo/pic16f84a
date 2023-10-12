;*********************************** Int_INT_04.asm *************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Cada vez que presiona el pulsador conectado a la l�nea RB0/INT conmutar� el estado
; de un LED conectado a la l�nea RB1.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	ENDC

#DEFINE  Pulsador	PORTB,0		; L�nea donde se conecta el pulsador.
#DEFINE  LED	PORTB,1			; L�nea donde se conecta el LED.

; ZONA DE C�DIGOS ********************************************************************

	ORG 	0
	goto	Inicio
	ORG	4			; Vector de interrupci�n
	goto	ServicioInterrupcion
Inicio
	bsf	STATUS,RP0		; Acceso al Banco 1.
	bsf	Pulsador		; La l�nea RB0/INT se configura como entrada.
	bcf	LED			; Se configura como salida.
	bcf	OPTION_REG,NOT_RBPU	; Activa las resistencias de Pull-Up del Puerto B.
	bcf	OPTION_REG,INTEDG	; Interrupci�n INT se activa por flanco de bajada.
	bcf	STATUS,RP0		; Acceso al Banco 0.
	movlw	b'10010000'		; Habilita la interrupci�n INT y la general.
	movwf	INTCON
Principal
	sleep				; Pasa a modo bajo consumo y espera interrupciones.
	goto	Principal

; Subrutina "ServicioInterrupcion" ------------------------------------------------------
;
; Subrutina de atenci�n a la interrupci�n. Conmuta el estado del LED.
;
ServicioInterrupcion
	call	Retardo_20ms
	btfsc	Pulsador
	goto	FinInterrupcion		; Era un rebote y por tanto sale.
	btfsc	LED			; Testea el �ltimo estado del LED.
 	goto	EstabaEncendido
EstabaApagado
	bsf	LED			; Estaba apagado y lo enciende.
	goto	FinInterrupcion
EstabaEncendido
	bcf	LED			; Estaba encendido y lo apaga.
FinInterrupcion
	bcf	INTCON,INTF		; Limpia flag de reconocimiento de la interrupci�n.
	retfie				; Retorna y rehabilita las interrupciones.

	INCLUDE   <RETARDOS.INC>
	END

;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================

