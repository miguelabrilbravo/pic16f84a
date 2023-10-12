;************************************** Teclado_06.asm ********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; En pantalla aparecen el código de las teclas que se van pulsando. Cuando llega al final de la primera
; línea, pasa a la segunda línea. Cuando llega al final de la segunda línea borra todo y
; comienza de nuevo al principio de la línea 1.
;
; ZONA DE DATOS *********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	GuardaTecla			; Guarda el valor de la tecla pulsada.
	ContadorCaracteres		; Guarda el número de caracteres pulsados.
	ENDC

CaracteresUnaLinea	EQU	d'16'	; Número de caracteres de una línea.
CaracteresDosLineas  EQU	d'32'	; Número de caracteres de dos líneas.

; ZONA DE CÓDIGOS ********************************************************************

	ORG	0
	goto 	Inicio
	ORG	4
	goto	ServicioInterrupcion
Inicio
	call	LCD_Inicializa
	call	Teclado_Inicializa	; Configura líneas del teclado.
	movlw	b'10001000'		; Habilita la interrupción RBI y la general.
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
	movlw	CaracteresUnaLinea	; Comprueba si ha llegado al número máximo de
	subwf	ContadorCaracteres,W	; caracteres de una línea.
	btfsc	STATUS,Z
	call	LCD_Linea2		; Se sitúa en la segunda línea.
	movlw	CaracteresDosLineas	; Comprueba si ha llegado al número máximo de
	subwf	ContadorCaracteres,W	; caracteres de dos líneas.
	btfss	STATUS,Z
	goto	EscribeCaracter		; No, por tanto, sigue escribiendo.
	call	LCD_Borra		; Sí, borra pantalla e inicializa el contador.
	clrf	ContadorCaracteres
EscribeCaracter	
	incf	ContadorCaracteres,F	; Un nuevo carácter escrito.
	movf	GuardaTecla,W
	call	LCD_Nibble		; Visualiza el carácter en pantalla.
	call	Teclado_EsperaDejePulsar; Para que no se repita el mismo carácter.
	bcf	INTCON,RBIF		; Limpia flag.
	retfie

	INCLUDE  <TECLADO.INC>
	INCLUDE  <LCD_4BIT.INC>
	INCLUDE  <RETARDOS.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
