;*********************************** Int_INT_07.asm *************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Comprueba el funcionamiento de la interrupción por activación del pin RB0/INT y analiza
; cómo deben guardarse los datos que se corrompen durante el proceso de la llamada a subrutina.
;
; Cada vez que presione el pulsador conectado al pin RB0/INT conmutará el estado de un LED
; conectado a la línea RB1. Al mismo tiempo en el módulo LCD se visualizará un mensaje
; desplazándose por pantalla.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC

	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	ENDC

#DEFINE  Pulsador  PORTB,0		; Línea donde se conecta el pulsador.
#DEFINE  LED	   PORTB,1		; Línea donde se conecta el LED.

; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0
	goto	Inicio
	ORG	4			; Vector de interrupción.
	goto	ServicioInterrupcion
Inicio
	call	LCD_Inicializa
	bsf	STATUS,RP0		; Acceso al Banco 1.
	bsf	Pulsador		; La línea RB0/INT se configura como entrada.
	bcf	LED			; Se configura como salida.
	bcf	OPTION_REG,NOT_RBPU	; Activa las resistencias de Pull-Up del Puerto B.
	bcf	OPTION_REG,INTEDG	; Interrupción INT se activa por flanco de bajada.
	bcf	STATUS,RP0		; Acceso al Banco 0.
	movlw	b'10010000'		; Habilita la interrupción INT y la general.
	movwf	INTCON
Principal
	movlw	MensajeLargo		; Visualiza el mensaje desplazándose por la
	call	LCD_MensajeMovimiento	; pantalla.
	goto	Principal

; Subrutina "ServicioInterrupcion" ------------------------------------------------------
;
; Subrutina de atención a la interrupción. Conmuta el estado del LED.

; Como esta subrutina altera los valores del registro de trabajo W, del STATUS, y de los
; registros R_ContA y R_ContB utilizados en los retardos, habrá que preservar su valor
; previo y después restaurarlo al final.

	CBLOCK	
	Guarda_W
	Guarda_STATUS
	Guarda_R_ContA
	Guarda_R_ContB
	ENDC

ServicioInterrupcion
	movwf	Guarda_W		; Guarda W y STATUS.
	swapf	STATUS,W		; Ya que "movf STATUS,W" corrompe el bit Z.
	movwf	Guarda_STATUS
	bcf	STATUS,RP0		; Para asegurarsede que trabaja con el Banco 0.
	movf	R_ContA,W		; Guarda los registros utilizados en esta 
	movwf	Guarda_R_ContA		; subrutina y también en la principal.
	movf	R_ContB,W
	movwf	Guarda_R_ContB
;
	call	Retardo_20ms
	btfsc	Pulsador		; Comprueba si es un rebote.
	goto	FinInterrupcion		; Era un rebote y por tanto sale.
	btfsc	LED			; Testea el último estado del LED.
 	goto	EstabaEncendido
EstabaApagado
	bsf	LED			; Estaba apagado y lo enciende.
	goto	FinInterrupcion
EstabaEncendido
	bcf	LED			; Estaba encendido y lo apaga.
FinInterrupcion
	swapf	Guarda_STATUS,W		; Restaura el STATUS.
	movwf	STATUS
	swapf	Guarda_W,F		; Restaura W como estaba antes de producirse
	swapf	Guarda_W,W		; interrupción.
	movf	Guarda_R_ContA,W	; Restaura los registros utilizados en esta 
	movwf	R_ContA			; subrutina y también en la principal.
	movf	Guarda_R_ContB,W
	movwf	R_ContB
	bcf	INTCON,INTF		; Limpia flag de reconocimiento de la interrupción.
	retfie				; Retorna y rehabilita las interrupciones.

; "Mensajes" ----------------------------------------------------------------------------

Mensajes
	addwf	PCL,F		
MensajeLargo
	DT " 		    "
	DT "Me gusta desarrollar proyectos con PICs."
	DT "                ", 0x00

	INCLUDE   <LCD_MENS.INC>
	INCLUDE   <LCD_4BIT.INC>
	INCLUDE   <RETARDOS.INC>
	END

;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================

