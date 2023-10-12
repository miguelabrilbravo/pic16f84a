;************************************ Int_T0I_06.asm ************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; En la línea superior de la pantalla aparece un mensaje fijo. En la línea inferior aparece
; un mensaje intermitente que se enciende durante 500 ms y se apaga durante 300 ms.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	Registro50ms
	Intermitencia			; Si es cero se apaga en intermitencia. Para
	ENDC				; cualquier otro valor se enciende.

Carga500ms	EQU	10		; 500 ms, ya que 50ms x 10 = 500ms 
Carga300ms	EQU	6		; 300ms, ya que 50ms x 6 = 300ms 
TMR0_Carga50ms	EQU	-d'195'		; Para conseguir la interrupción del
					; Timer 0 cada 50 ms.
; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0
	goto	Inicio
	ORG	4			; Vector de interrupción.
	goto	ServicioInterrupcion
Inicio
	call	LCD_Inicializa
	movlw	MensajeFijo		; Visualiza mensaje fijo en la primera
	call	LCD_Mensaje		; línea.
	bsf	STATUS,RP0
	movlw	b'00000111'		; Prescaler de 256 para el TMR0.
	movwf	OPTION_REG
	bcf	STATUS,RP0
	movlw	TMR0_Carga50ms		; Carga el TMR0.
	movwf	TMR0
	movlw	Carga500ms
	movwf	Registro50ms
	movlw	b'10100000'
	movwf	INTCON
Principal
	goto	$

; Subrutina "ServicioInterrupcion" ------------------------------------------------------
;
ServicioInterrupcion
	movlw	TMR0_Carga50ms		; Carga el Timer 0.
	movwf	TMR0
	decfsz	Registro50ms,F		; Decrementa el contador.
	goto	FinInterrupcion
	comf	Intermitencia,F		; Conmuta la intermitencia
	call	Visualiza
FinInterrupcion
	bcf	INTCON,T0IF
	retfie
	
; Subrutina "Visualiza" -----------------------------------------------------------------
;
; Visualiza, o no, un mensaje en función del contenido del registro Intermitencia.
;
Visualiza
	call	LCD_Linea2		; Se sitúa en la segunda línea.
	btfss	Intermitencia,0		; ¿Apaga o enciende el mensaje en intermitencia?
	goto	ApagaMensaje		; Apaga el mensaje.
	movlw	MensajeIntermitente	; Visualiza el mensaje intermitente.
	call	LCD_Mensaje
	movlw	Carga500ms		; Debe estar 500 ms encendido.
	movwf	Registro50ms
	goto	FinVisualiza
ApagaMensaje
	call	LCD_LineaEnBlanco	; Visualiza una línea en blanco.
	movlw	Carga300ms		; Debe estar 300 ms apagado.
	movwf	Registro50ms
FinVisualiza
	return

; "Mensajes" ----------------------------------------------------------------------------
;
Mensajes
	addwf	PCL,F
MensajeFijo
	DT "    Estudia", 0x00
MensajeIntermitente
	DT "  ELECTRONICA", 0x00

	INCLUDE  <RETARDOS.INC>
	INCLUDE  <LCD_4BIT.INC>
	INCLUDE  <LCD_MENS.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
