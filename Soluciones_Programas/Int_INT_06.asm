;*********************************** Int_INT_06.asm *************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Cada tres veces que se presione el pulsador RB0/INT el LED conectado a RB1 conmuta de 
; estado.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	NumeroPulsaciones		; Almacena el n�mero de veces pulsadas desde
	ENDC				; la �ltima conmutaci�n del LED.

MaximasPulsaciones	EQU	.3	; El LED conmuta cada tantas pulsaciones.

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
	clrf	NumeroPulsaciones	; Lleva 0 veces pulsadas.
	movlw	b'10010000'		; Habilita la interrupci�n INT y la general.
	movwf	INTCON
Principal
	sleep				; Pasa a modo bajo consumo y espera interrupciones
	goto	Principal

; Subrutina "ServicioInterrupcion" ------------------------------------------------------
;
; Subrutina de atenci�n a la interrupci�n. Conmuta el estado del LED cada tres pulsaciones.

ServicioInterrupcion
	call	Retardo_20ms
	btfsc	Pulsador
	goto	FinInterrupcion
	incf	NumeroPulsaciones,F	; Una pulsaci�n m�s.
	movlw	MaximasPulsaciones	; �Ha llegado al m�ximo de pulsaciones antes de
	subwf	NumeroPulsaciones,W	; conmutar el LED?. (W)=(NumeroPulsaciones)-M�x.
	btfss	STATUS,C		; �C=1?, �(W) posit.?, �(NumeroPulsaciones)>=M�x?
	goto	FinInterrupcion		; No ha llegado al n�mero m�ximo de pulsaciones.
ConmutaLED
	clrf	NumeroPulsaciones	; Inicializa el contador de n� de veces pulsadas.
	btfsc 	LED			; Testea el �ltimo estado del LED.
	goto	EstabaEncendido	
EstabaApagado
	bsf	LED			; Estaba apagado y lo enciende.
	goto	FinInterrupcion
EstabaEncendido
	bcf 	LED			; Estaba encendido y lo apaga.
FinInterrupcion
	bcf	INTCON,INTF		; Limpia flag de reconocimiento de la interrupci�n.
	retfie				; Retorna y rehabilita las interrupciones.

	INCLUDE  <RETARDOS.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================

