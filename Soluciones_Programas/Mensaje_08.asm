;************************************** Mensaje_08.asm *********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Programa para el juego de la Quiniela: Al presionar sobre el pulsador conectado al pin RA4
; se incrementará en pantalla aparecerá rapidamente "1", "X", "2". Cuando se suelta el pulsador
; permanece el signo seleccionado.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	Contador
	ENDC

#DEFINE  Pulsador PORTA,4		; Línea donde se conecta el pulsador.

; ZONA DE CÓDIGOS ********************************************************************

	ORG	0
Inicio
	call	LCD_Inicializa
	movlw	MensajeQuiniela
	call	LCD_Mensaje
	bsf	STATUS,RP0
	bsf	Pulsador		; Línea del pulsador que se configura como entrada. 
	bcf	STATUS,RP0
Principal
	btfss	Pulsador		; Lee el pulsador.
	call	IncrementaVisualiza	; Si pulsa salta a incrementar y visualizar el
	goto	Principal		; contador
	
; Subrutina "IncrementaVisualiza" -------------------------------------------------------
;
IncrementaVisualiza
	incf	Contador,F
	movlw	.7			; Se sitúa en el centro de la línea 2.
	call	LCD_PosicionLinea2
	movf	Contador,W
	andlw	b'00011111'		; Se queda con las 5 líneas bajas: 32 posibilidades
	call	SignoQuiniela		; Lo convierte a signo de la quiniela.
	call	LCD_Caracter		; Lo visualiza.
	return

SignoQuiniela
	addwf	PCL,F
	DT	"1X121X121X121X1X1X121X121X121X12"  ; 50% de "1", 28% de "X" y 21% de "2".

; "Mensajes" ----------------------------------------------------------------------------
;
Mensajes
	addwf	PCL,F
MensajeQuiniela
	DT "   Quiniela:", 0x00

	INCLUDE  <RETARDOS.INC>
	INCLUDE  <BIN_BCD.INC>
	INCLUDE  <LCD_4BIT.INC>
	INCLUDE  <LCD_MENS.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
