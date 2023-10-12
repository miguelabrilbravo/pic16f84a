;*********************************** Int_INT_02.asm *************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Cada vez que presiona el pulsador conectado al pin RB0/INT se incrementa un contador
; que es visualizado en el m�dulo LCD. La lectura del pulsador se har� mediante interrupciones.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	Contador				; El contador a visualizar.
	ENDC

#DEFINE  Pulsador 	PORTB,0		; L�nea donde se conecta el pulsador.

; ZONA DE C�DIGOS ********************************************************************

	ORG 	0
	goto	Inicio
	ORG	4			; Vector de interrupci�n.
	goto	ServicioInterrupcion
Inicio
	call	LCD_Inicializa
	bsf	STATUS,RP0		; Acceso al Banco 1.
	bsf	Pulsador			; La l�nea RB0/INT se configura como entrada.
	bcf	OPTION_REG,NOT_RBPU	; Activa las resistencias de Pull-Up del Puerto B.
	bcf	OPTION_REG,INTEDG	; Interrupci�n INT se activa por flanco de bajada.
	bcf	STATUS,RP0		; Acceso al Banco 0.
	clrf	Contador			; Inicializa el contador y lo visualiza.
	call	VisualizaContador
	movlw	b'10010000'		; Habilita la interrupci�n INT y la general.
	movwf	INTCON

; La secci�n "Principal" es de mantenimiento. S�lo espera las interrupciones
; en modo de bajo consumo.

Principal
	sleep				; Pasa a modo de bajo consumo o reposo.
	goto	Principal

; Subrutina "ServicioInterrupcion" ------------------------------------------------------
;
; Subrutina de servicio a la interrupci�n. Incrementa un contador y lo visualiza.
;
ServicioInterrupcion
	call	Retardo_20ms		; Espera a que se estabilice el nivel de tensi�n.
	btfsc	Pulsador			; Comprueba si es un rebote.
	goto	FinInterrupcion		; Era un rebote y por tanto sale.
	incf	Contador,F		; Incrementa el contador y lo visualiza.
VisualizaContador
	call	LCD_Linea1
	movf	Contador,W
	call	BIN_a_BCD		; Se debe visualizar en BCD.
	call	LCD_Byte
FinInterrupcion
	bcf	INTCON,INTF		; Limpia flag de reconocimiento (INTF).
	retfie				; Retorna y rehabilita las interrupciones (GIE=1).

	INCLUDE   <RETARDOS.INC>
	INCLUDE   <BIN_BCD.INC>
	INCLUDE   <LCD_4BIT.INC>
	END

;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================

