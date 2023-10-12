;************************************** Teclado_06.asm ********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; En pantalla aparecen el c�digo de las teclas que se van pulsando. Cuando llega al final de la primera
; l�nea, pasa a la segunda l�nea. Cuando llega al final de la segunda l�nea borra todo y
; comienza de nuevo al principio de la l�nea 1.
;
; ZONA DE DATOS *********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	GuardaTecla			; Guarda el valor de la tecla pulsada.
	ContadorCaracteres		; Guarda el n�mero de caracteres pulsados.
	ENDC

CaracteresUnaLinea	EQU	d'16'	; N�mero de caracteres de una l�nea.
CaracteresDosLineas  EQU	d'32'	; N�mero de caracteres de dos l�neas.

; ZONA DE C�DIGOS ********************************************************************

	ORG	0
	goto 	Inicio
	ORG	4
	goto	ServicioInterrupcion
Inicio
	call	LCD_Inicializa
	call	Teclado_Inicializa	; Configura l�neas del teclado.
	movlw	b'10001000'		; Habilita la interrupci�n RBI y la general.
	movwf	INTCON
	clrf	ContadorCaracteres	; En principio no hay caracteres escritos.
Principal
	sleep				; Espera en modo bajo consumo que pulse tecla.
	goto	Principal

; Subrutina "ServicioInterrupcion" ------------------------------------------------------
;
ServicioInterrupcion
	call	Teclado_LeeHex		; Obtiene el valor de la tecla pulsada.
	movwf	GuardaTecla		; Reserva el valor de la tecla pulsada.
	movlw	CaracteresUnaLinea	; Comprueba si ha llegado al n�mero m�ximo de
	subwf	ContadorCaracteres,W	; caracteres de una l�nea.
	btfsc	STATUS,Z
	call	LCD_Linea2		; Se sit�a en la segunda l�nea.
	movlw	CaracteresDosLineas	; Comprueba si ha llegado al n�mero m�ximo de
	subwf	ContadorCaracteres,W	; caracteres de dos l�neas.
	btfss	STATUS,Z
	goto	EscribeCaracter		; No, por tanto, sigue escribiendo.
	call	LCD_Borra		; S�, borra pantalla e inicializa el contador.
	clrf	ContadorCaracteres
EscribeCaracter	
	incf	ContadorCaracteres,F	; Un nuevo car�cter escrito.
	movf	GuardaTecla,W
	call	LCD_Nibble		; Visualiza el car�cter en pantalla.
	call	Teclado_EsperaDejePulsar; Para que no se repita el mismo car�cter.
	bcf	INTCON,RBIF		; Limpia flag.
	retfie

	INCLUDE  <TECLADO.INC>
	INCLUDE  <LCD_4BIT.INC>
	INCLUDE  <RETARDOS.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
