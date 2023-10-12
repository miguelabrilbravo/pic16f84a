;************************************** Teclado_08.asm ********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Suma el valor de tres teclas pulsadas consecutivamente. En la primera línea de la pantalla del
; modulo LCD aparece en hexadecimal y en la segunda en decimal. Así por ejemplo, si pulsa
; "A", "6" y "F" en pantalla aparece:
;	Hex: A+6+F=1F	(Primera Línea)
;	Dec: 10+06+15=31(Segunda Línea)
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	ContadorTeclasPulsadas
	GuardaValor
	Operando1
	Operando2
	Operando3
	Resultado
	ENDC

; ZONA DE CÓDIGOS ********************************************************************

VisualizaHex	MACRO	Operando,Caracter
	movf	GuardaValor,W		; Recupera el valor y lo visualiza.
	movwf	Operando		; Lo guarda para sumar después.
	call	LCD_Nibble		; Visualiza el valor en la pantalla
	movlw	Caracter
	call	LCD_Caracter		; Visualiza el signo '+' ó '-' según corresponda.
	incf	ContadorTeclasPulsadas,F
	ENDM

VisualizaDec	MACRO	Operando,Caracter
	movf	Operando,W		; (Operando) -> (W)
	call	BIN_a_BCD		; Lo pasa a BCD.
	call	LCD_ByteCompleto	; Visualiza en pantalla.
	movlw	Caracter		; A continuación signo '+' o '=' según corresponda.
	call	LCD_Caracter
	ENDM

	ORG	0
	goto 	Inicio
	ORG	4
	goto	ServicioInterrupcion
Inicio
	call	LCD_Inicializa
	call	Teclado_Inicializa
	clrf	ContadorTeclasPulsadas	; Resetea este contador.
	movlw	b'10001000'		; Habilita la interrupción RBI y la general.
	movwf	INTCON
Principal
	sleep				; Espera en modo bajo consumo que pulse.
	goto	Principal

; Subrutina "ServicioInterrupcion" ------------------------------------------------------
;
ServicioInterrupcion
	call	Teclado_LeeHex		; Obtiene el valor hexadecimal de la tecla pulsada.
	movwf	GuardaValor		; Guarda el valor.
	movf	ContadorTeclasPulsadas,W; Según el número de tecla pulsada realiza una
	addwf	PCL,F			; función distinta.
	goto	PrimeraTeclaPulsada
	goto	SegundaTeclaPulsada
	goto	TerceraTeclaPulsada
PrimeraTeclaPulsada
	call	LCD_Borra		; Borra la pantalla anterior.
	movlw	MensajeHex		; En pantalla el mensaje "Hex:"
	call	LCD_Mensaje
	VisualizaHex Operando1,'+'
	goto	FinInterrupcion
SegundaTeclaPulsada
	VisualizaHex Operando2,'+'
	goto	FinInterrupcion
TerceraTeclaPulsada
	VisualizaHex Operando3,'='
;
	movf	Operando1,W		; Procede a la suma de los tres valores.
	addwf	Operando2,W
	addwf	Operando3,W
	movwf	Resultado
	call	LCD_Byte		; Visualiza el resultado.
	call	LCD_Linea2		; Ahora visualiza la segunda línea.
	movlw	MensajeDec		; En pantalla el mensaje "Dec:"
	call	LCD_Mensaje
	VisualizaDec Operando1,'+'
	VisualizaDec Operando2,'+'
	VisualizaDec Operando3,'='
	VisualizaDec Resultado,' '
	clrf	ContadorTeclasPulsadas	; Resetea este contador.
FinInterrupcion
	call	Teclado_EsperaDejePulsar; Espera  a que levante el dedo.
	bcf	INTCON,RBIF
	retfie	

; "Mensajes" ----------------------------------------------------------------------------

Mensajes
	addwf	PCL,F
MensajeHex
	DT	"Hex: ", 0x0
MensajeDec
	DT	"Dec: ", 0x0

	INCLUDE  <TECLADO.INC>
	INCLUDE  <LCD_4BIT.INC>
	INCLUDE  <LCD_MENS.INC>
	INCLUDE  <RETARDOS.INC>
	INCLUDE  <BIN_BCD.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
