;************************************** Teclado_08.asm ********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Suma el valor de tres teclas pulsadas consecutivamente. En la primera l�nea de la pantalla del
; modulo LCD aparece en hexadecimal y en la segunda en decimal. As� por ejemplo, si pulsa
; "A", "6" y "F" en pantalla aparece:
;	Hex: A+6+F=1F	(Primera L�nea)
;	Dec: 10+06+15=31(Segunda L�nea)
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

; ZONA DE C�DIGOS ********************************************************************

VisualizaHex	MACRO	Operando,Caracter
	movf	GuardaValor,W		; Recupera el valor y lo visualiza.
	movwf	Operando		; Lo guarda para sumar despu�s.
	call	LCD_Nibble		; Visualiza el valor en la pantalla
	movlw	Caracter
	call	LCD_Caracter		; Visualiza el signo '+' � '-' seg�n corresponda.
	incf	ContadorTeclasPulsadas,F
	ENDM

VisualizaDec	MACRO	Operando,Caracter
	movf	Operando,W		; (Operando) -> (W)
	call	BIN_a_BCD		; Lo pasa a BCD.
	call	LCD_ByteCompleto	; Visualiza en pantalla.
	movlw	Caracter		; A continuaci�n signo '+' o '=' seg�n corresponda.
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
	movlw	b'10001000'		; Habilita la interrupci�n RBI y la general.
	movwf	INTCON
Principal
	sleep				; Espera en modo bajo consumo que pulse.
	goto	Principal

; Subrutina "ServicioInterrupcion" ------------------------------------------------------
;
ServicioInterrupcion
	call	Teclado_LeeHex		; Obtiene el valor hexadecimal de la tecla pulsada.
	movwf	GuardaValor		; Guarda el valor.
	movf	ContadorTeclasPulsadas,W; Seg�n el n�mero de tecla pulsada realiza una
	addwf	PCL,F			; funci�n distinta.
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
	call	LCD_Linea2		; Ahora visualiza la segunda l�nea.
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
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
