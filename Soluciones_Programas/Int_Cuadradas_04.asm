;************************************ Int_Cuadradas_04 ********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Ejemplo de control del ciclo de trabajo.
;
; Por la línea 3 del Puerto B se genera una onda cuadrada de frecuencia constante a 100 Hz y
; ciclo de trabajo variable desde 0% a 100%, es decir, el tiempo en alto varía entre  0 µs (0%)
; y 10.000 µs (100%).
; El valor del ciclo de trabajo cambia mediante activación del pulsador conectado al pin
; 7 del Puerto B, de la siguiente forma:
;
; 	PULSACIÓN	DC (%)		   SEMIPERIODO ALTO	   SEMIPERIODO BAJO
; 	---------	-------		----------------------	-----------------------
; 	Inicial	 	 0 %	   	   0 µs =   0 x 100 µs	10000 µs = 100 x 100 µs
; 	Primera	  	10 %	  	1000 µs =  10 x 100 µs	 9000 µs =  90 x 100 µs
; 	Segunda	  	20 %	  	2000 µs =  20 x 100 µs	 8000 µs =  80 x 100 µs
; 	Tercera	  	30 %	  	3000 µs =  30 x 100 µs	 7000 µs =  70 x 100 µs
; 	Cuarta		40 %	 	4000 µs =  40 x 100 µs	 6000 µs =  60 x 100 µs
; 	Quinta		50 %	 	5000 µs =  50 x 100 µs	 5000 µs =  50 x 100 µs
; 	Sexta		60 %	 	6000 µs =  60 x 100 µs	 4000 µs =  40 x 100 µs
; 	Septima	 	70 %		7000 µs =  70 x 100 µs	 3000 µs =  30 x 100 µs
;	Octava		80 %		8000 µs =  80 x 100 µs	 2000 µs =  20 x 100 µs
;	Novena		90 %		9000 µs =  90 x 100 µs	 1000 µs =  10 x 100 µs
;	Décima		100 %		10000µs = 100 x 100 µs	    0 µs =   0 x 100 µs	
;
; Al conectarlo por primera vez se genera un ciclo de trabajo de 0%, al presionar el pulsador
; cambia al 10%, al actuar una segunda vez cambia al 20%, y así sucesivamente.
; El módulo LCD visualiza el ciclo de trabajo vigente en cada momento.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	CicloTrabajo			; Ciclo de trabajo deseado.
	Timer0_ContadorA		; Contador auxiliar.
	ENDC

TMR0_Carga	EQU	-d'89'		; El semiperiodo patrón va a ser de 100 µs.
IncrementoDC	EQU	d'10'		; Incremento de cada paso del ciclo de trabajo.
#DEFINE  Salida	PORTB,3
#DEFINE  Pulsador	PORTB,7

; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0
	goto	Inicio
	ORG	.4
	goto	ServicioInterrupcion

Mensajes
	addwf	PCL,F
Mensaje_DC
	DT "Duty Cycle: ", 0x00
Mensaje_TantoPorCiento
	DT "%  ", 0x00

Inicio	bsf	STATUS,RP0
	bcf	Salida
	bsf	Pulsador
	movlw	b'00001000'		; TMR0 sin prescaler.
	movwf	OPTION_REG
	bcf	STATUS,RP0
	call	LCD_Inicializa
	call	DC_CeroPorCiento	; Inicializa con un DC=0%, por tanto salida
	movlw	b'10001000'		; en bajo permanentemente.
	movwf	INTCON			; Habilita solo interrupción RBI.
Principal
	goto 	Principal

; Subrutina "ServicioInterrupcion" ------------------------------------------------------
;
ServicioInterrupcion
	btfsc	INTCON,RBIF		; ¿Interrupción por cambio en el Puerto B?
	call	Pulsador_Interrupcion
	btfsc	INTCON,T0IF		; ¿Interrupción por desbordamiento del TMR0?
	call	Timer0_Interrupcion
	bcf	INTCON,RBIF		; Limpia flags de reconocimiento.
	bcf	INTCON,T0IF
	retfie

; Subrutina "Pulsador_Interrupcion" -----------------------------------------------------
;
; Subrutina de atención a la interrupción por cambio en la línea RB7 donde se ha
; conectado un pulsador.
; Incrementa el registro (CicloTrabajo), desde 0 (que corresponde a un DC = 0%
; hasta d'100' (que corresponde a un ciclo de trabajo del 100%).
;
Pulsador_Interrupcion
	call	Retardo_20ms
	btfsc	Pulsador		; Si no es la línea del pulsador sale.
	goto	Fin_PulsadorInterrupcion
	bsf	INTCON,T0IE		; En principio habilita interrupciones TMR0.
	movlw	IncrementoDC		; Se le va a sumar al ciclo de trabajo
	addwf	CicloTrabajo,W		; (W)=(CicloTrabajo)+IncrementoDC
	movwf	CicloTrabajo		; Guarda resultado.
	sublw	.100			; Si DC ha llegado al 100% la salida pasa a 
	btfsc	STATUS,Z		; alto permanentemente.
	goto	DC_100PorCiento
	btfsc	STATUS,C		; Si pasa de 100, lo inicializa. 
	goto	Visualiza
DC_CeroPorCiento
	bcf	Salida			; Pone la salida siempre en bajo.
	clrf	CicloTrabajo		; Inicializa el ciclo de trabajo a 0%.
	goto	InhabilitaInterrupcionTMR0
DC_100PorCiento
	bsf	Salida			; Pone la salida siempre en alto.
	movlw	.100			; Está al máximo, DC=100%.
	movwf	CicloTrabajo
InhabilitaInterrupcionTMR0
	bcf	INTCON,T0IE
Visualiza
	call	VisualizaCicloTrabajo	; Visualiza el ciclo de trabajo seleccionado.
EsperaDejePulsar
	btfss	Pulsador
	goto	EsperaDejePulsar
Fin_PulsadorInterrupcion
	movf	CicloTrabajo,W		; Carga todos los contadores.
	movwf 	Timer0_ContadorA
	movlw 	TMR0_Carga
	movwf 	TMR0
	return

; Subrutina "Timer0_Interrupcion" -------------------------------------------------------
;
; Mantiene la salida en alto un tiempo igual a 100µs x (CicloTrabajo)
; y en bajo un tiempo igual a 100µs x (100-CicloTrabajo).
;
Timer0_Interrupcion
	movlw 	TMR0_Carga
	movwf 	TMR0
	decfsz 	Timer0_ContadorA,F	; Decrementa el contador.
	goto 	Fin_Timer0_Interrupcion
	btfsc 	Salida			; Testea el anterior estado de la salida.
	goto 	EstabaAlto
EstabaBajo
	nop
	bsf	Salida			; Estaba bajo y lo pasa a alto.
	movf	CicloTrabajo,W		; Repone el contador nuevamente con el tiempo en 
	movwf 	Timer0_ContadorA	; alto.
	nop
	goto 	Fin_Timer0_Interrupcion
EstabaAlto
	bcf 	Salida			; Estaba alto y lo pasa a bajo.
	movf	CicloTrabajo,W		; Repone el contador nuevamente con el tiempo
	sublw	.100			; en bajo.
	movwf 	Timer0_ContadorA
Fin_Timer0_Interrupcion
	return

; Subrutina "VisualizaCicloTrabajo" -----------------------------------------------------
;
; Visualiza el ciclo de trabajo en el visualizador LCD. Se hace de manera tal que cuando
; haya que visualizar un número mayor de 9, las decenas siempre se visualicen aunque sean
; cero. Y cuando sea menor de 99 las decenas no se visualicen si es cero.
;
VisualizaCicloTrabajo
	call	LCD_Linea1		; Visualiza el ciclo de trabajo seleccionado.
	movlw	Mensaje_DC
	call	LCD_Mensaje
	movf	CicloTrabajo,W
	call	BIN_a_BCD		; Lo pasa a BCD.
	movf	BCD_Centenas,W		; Visualiza las centenas.
	btfss	STATUS,Z		; Si son cero no visualiza las centenas.
	goto	VisualizaCentenas
	movf	CicloTrabajo,W		; Vuelve a recuperar este valor.
	call	BIN_a_BCD		; Lo pasa a BCD.
	call	LCD_Byte		; Visualiza las decenas y unidades.
	goto	VisualizaTantoPorCiento
VisualizaCentenas
	call	LCD_Nibble		; Visualiza las centenas.
	movf	CicloTrabajo,W		; Vuelve a recuperar este valor.
	call	BIN_a_BCD		; Lo pasa a BCD.
	call	LCD_ByteCompleto	; Visualiza las decenas (aunque sea cero) y
VisualizaTantoPorCiento			; unidades.
	movlw	Mensaje_TantoPorCiento	; Y ahora el simbolo "%".
	call	LCD_Mensaje
	return

	INCLUDE  <LCD_MENS.INC>
	INCLUDE  <LCD_4BIT.INC>
	INCLUDE  <RETARDOS.INC>
	INCLUDE  <BIN_BCD.INC>
	END

;	====================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS".
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	====================================================================
