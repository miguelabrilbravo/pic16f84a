;*********************************** Int_INT_04B.asm **********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Cada vez que presiona el pulsador conectado a la l�nea RB0/INT conmutar� el estado de
; un LED conectado a la l�nea RB1. La complementaci�n se realiza con ayuda de una funci�n XOR.
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
	sleep				; Pasa a modo bajo consumo y espera interrupciones
	goto	Principal

; Subrutina "ServicioInterrupcion" ------------------------------------------------------
;
; Subrutina de atenci�n a la interrupci�n. Conmuta el estado del LED. La complementaci�n se
; realiza con una funci�n XOR. Observar que es mucho m�s eficaz que la soluci�n anterior.

ServicioInterrupcion
	call	Retardo_20ms		; Para salvaguardarse de los rebotes.
	btfsc	Pulsador		; Comprueba si es un rebote.
	goto	FinInterrupcion		; Era un rebote y por tanto sale.
	movlw	b'00000010'		; Se hace una XOR para complementar.
	xorwf	PORTB,F
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
