;*********************************** Int_INT_08.asm *************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Cada vez que se oprima el pulsador conectado a la línea RB0/INT se pondrá intermitente,
; o no, un mensaje publicitario que aparece en la pantalla del módulo LCD.
; En la línea superior aparecerá "Mensaje FIJO" o "M. INTERMITENTE".
; En la línea inferior aparecerá un mensaje publicitario fijo o intermitente según
; corresponda.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	Intermitencia			; Si está a 0 el mensaje permanece fijo.
	ENDC				; En caso contrario se pone en intermitencia.

#DEFINE   Pulsador	PORTB,0

; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0
	goto	Inicio
	ORG	4
	goto	ServicioInterrupcion
Inicio
	call	LCD_Inicializa
	bsf	STATUS,RP0
	bsf	Pulsador
	bcf	OPTION_REG,NOT_RBPU
	bcf	OPTION_REG,INTEDG
	bcf	STATUS,RP0
	clrf	Intermitencia		; En principio mensaje fijo.
	movlw	b'10010000'
	movwf	INTCON
Principal
	call	LCD_Linea1
	movlw	MensajeFijo		; En principio supone mensaje fijo
	btfsc	Intermitencia,0		; Testea cualquier bit.
	movlw	MensajeIntermitencia	; Está en intermitencia.
	call	LCD_Mensaje
	call	LCD_Linea2		; Visualiza el mensaje publicitario en la
	movlw	MensajePublicitario	; línea 2.
	call	LCD_Mensaje
	call	Retardo_200ms
	call	LCD_Linea2		; Se sitúa de nuevo al inicio de la línea 2.
	btfsc	Intermitencia,0		; Si está a 0 no se produce la intermitencia.
	call	LCD_LineaEnBlanco	; Borra la segunda línea para producir la 
	call	Retardo_200ms		; intermitencia.
	goto	Principal

; Subrutina "ServicioInterrupcion" ------------------------------------------------------
;
	CBLOCK	
	Guarda_W
	Guarda_STATUS
	Guarda_R_ContA
	Guarda_R_ContB
	ENDC

ServicioInterrupcion			; Conmuta el valor "Intermitencia",
	movwf	Guarda_W		; Guarda W y STATUS.
	swapf	STATUS,W		; Ya que "movf STATUS,W", corrompe el bit Z.
	movwf	Guarda_STATUS
	bcf	STATUS,RP0		; Para asegurarse que trabaja con el banco 0.
	movf	R_ContA,W		; Guarda los registros utilizados en esta 
	movwf	Guarda_R_ContA		; subrutina y también en la principal.
	movf	R_ContB,W
	movwf	Guarda_R_ContB
;
	call	Retardo_20ms
	btfsc	Pulsador		; Comprueba si es un rebote.
	goto	FinInterrupcion		; Era un rebote y por tanto sale.
	comf	Intermitencia,F		; Complementa su estado.
FinInterrupcion
	swapf	Guarda_STATUS,W		; Restaura el STATUS.
	movwf	STATUS
	swapf	Guarda_W,F		; Restaura W como estaba antes de producirse
	swapf	Guarda_W,W		; interrupción.
	movf	Guarda_R_ContA,W	; Restaura los registros utilizados en esta 
	movwf	R_ContA			; subrutina y también en la principal.
	movf	Guarda_R_ContB,W
	movwf	R_ContB
	bcf	INTCON,INTF
	retfie

; "Mensajes" ----------------------------------------------------------------------------

Mensajes
	addwf	PCL,F
MensajePublicitario
	DT "Editorial  Ra-Ma", 0x00
MensajeIntermitencia
	DT "M. INTERMITENTE", 0x00
MensajeFijo
	DT "  Mensaje FIJO   ", 0x00
;
	INCLUDE   <RETARDOS.INC>
	INCLUDE   <LCD_4BIT.INC>
	INCLUDE   <LCD_MENS.INC>
	END

;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
