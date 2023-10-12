;************************************ Timer0_06.asm *************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Frecuencímetro elemental para la señal aplicada al pin RA4. La frecuencia máxima será
; de 255 Hz.
;
; Este programa muestra el fundamento para realizar un frecuencimetro digital completo con
; diferentes escalas. Se anima al lector a desarrollarlo como proyecto.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK	0x0C
	Frecuencia
	ENDC	

; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0
Inicio
 	call	LCD_Inicializa
	bsf	STATUS,RP0		; Acceso al Banco 1.
	movlw	b'00111000'		; TMR0 como contador por flanco descendente de 
	movwf	OPTION_REG		; RA4/T0CKI. Prescaler asignado al Watchdog.
	bcf	STATUS,RP0		; Acceso al Banco 0.
Principal
	clrf	TMR0			; Inicializa contador.
	call	Retardo_1s		; Tiempo durante el cual contará los pulsos.
	movf	TMR0,W			; Lee el Timer 0 o, lo que es lo mismo, el número
	movwf	Frecuencia		; de pulsaciones por segundo.
	call	LCD_Borra
	movlw	.5			; Se sitúa en el centro de la segunda línea.
	call	LCD_PosicionLinea2
	movf	Frecuencia,W		; Visualiza la frecuencia.
	call	VisualizaNumero
	movlw	MensajeHz
	call	LCD_Mensaje
	call	Retardo_2s		; Tiempo de espera para la siguiente medida
	goto	Principal

; Subrutina "VisualizaNumero" -----------------------------------------------------------
;
; Cuando haya que visualizar un número mayor de 99 las decenas siempre se visualizan aunque
; sean cero. Cuando sea menor de 99 las decenas no se visualizan si son cero.
;
	CBLOCK	0x0C
	GuardaNumero
	ENDC

VisualizaNumero
	movwf	GuardaNumero		; Reserva el número.
	call	BIN_a_BCD		; Pasa el número a BCD.
	movf	BCD_Centenas,W		; Primero las centenas.
	btfss	STATUS,Z		; Si son cero no visualiza las centenas.
	goto	VisualizaCentenas
	movf	GuardaNumero,W		; Vuelve a recuperar este valor.
	call	BIN_a_BCD		; Lo pasa a BCD.
	call	LCD_Byte		; Visualiza las decenas y unidades.
	goto	FinVisualizaNumero
VisualizaCentenas
	call	LCD_Nibble		; Visualiza las centenas.
	movf	GuardaNumero,W		; Vuelve a recuperar este valor.
	call	BIN_a_BCD		; Lo pasa a BCD.
	call	LCD_ByteCompleto	; Visualiza las decenas aunque sea cero.
FinVisualizaNumero
	return

; Subrutina "Mensajes" ------------------------------------------------------------------

Mensajes
	addwf	PCL,F
MensajeHz
	DT " Hz   ", 0x00

	INCLUDE  <RETARDOS.INC>
	INCLUDE  <BIN_BCD.INC>
	INCLUDE  <LCD_4BIT.INC>
	INCLUDE  <LCD_MENS.INC>
	END
	
;	====================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS".
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	====================================================================
