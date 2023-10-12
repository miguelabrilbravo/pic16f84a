;*********************************** Macro_01.asm *************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Se conectará un pulsador al pin RA4 y mientras se mantenga pulsado se incrementarán dos
; contadores distintos que se visualizarán en la pantalla del modulo LCD:
;   - El Contador1 se visualiza en la línea 1 y cuenta de 3 a 16.
;   - El Contador2 se visualiza en la línea 2 y cuenta de 7 a 21.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK	0x0C
	Contador1
	Contador2
	ENDC

Minimo1 EQU	.3
Maximo1	EQU	.16
Minimo2	EQU	.7
Maximo2	EQU	.21

#DEFINE  Pulsador 	PORTA,4			; Línea donde se conecta el pulsador.

; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0
Inicio
	call	LCD_Inicializa
	bsf	STATUS,RP0		; Acceso al Banco 1.
	bsf	Pulsador			; Línea del pulsador configurada como entrada.
	bcf	STATUS,RP0		; Acceso al Banco 0.
	movlw	Minimo1			; Inicializa los contadores
	movwf	Contador1
	movlw	Minimo2
	movwf	Contador2
	call	VisualizaContadores
Principal
	btfss	Pulsador			; Lee el pulsador.
	call	IncrementaVisualiza		; Salta a incrementar y visualizar el contador.
	goto	Principal
;
; Subrutina "IncrementaVisualiza" -------------------------------------------------------
;
; Subrutina que incrementa el contador y lo visualiza.
;
IncrementaVisualiza
	incf	Contador1,F		; Incrementa el contador 1.
	movf	Contador1,W		; ¿Ha llegado a su valor máximo?
	sublw	Maximo1			; (W) = Maximo1 - (Contador1).
	btfsc	STATUS,C		; ¿C=0?, ¿(W) negativo?, ¿Maximo1<(Contador1)?
	goto	IncrementaContador2	; No, ha resultado Maximo1>=(Contador1)
	movlw	Minimo1			; Sí, ha resultado Maximo1<(Contador1), entonces
	movwf	Contador1		; inicializa el registro.
IncrementaContador2
	incf	Contador2,F		; Incrementa el contador 2.
	movf	Contador2,W		; ¿Ha llegado a su valor máximo?
	sublw	Maximo2			; (W) = Maximo2 - (Contador2).
	btfsc	STATUS,C		; ¿C=0?, ¿(W) negativo?, ¿Maximo2<(Contador2)?
	goto	VisualizaContadores	; No, ha resultado Maximo2>=(Contador2)
	movlw	Minimo2			; Sí, ha resultado Maximo2<(Contador2), entonces
	movwf	Contador2		; inicializa el registro.
VisualizaContadores
	call	LCD_Linea1
	movf	Contador1,W
	call	BIN_a_BCD
	call	LCD_Byte
	call	LCD_Linea2
	movf	Contador2,W
	call	BIN_a_BCD
	call	LCD_Byte
	call	Retardo_200ms		; Se incrementa cada 200 ms.
	return
;
	INCLUDE  <RETARDOS.INC>
	INCLUDE  <BIN_BCD.INC>
	INCLUDE  <LCD_4BIT.INC>
	END

;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
