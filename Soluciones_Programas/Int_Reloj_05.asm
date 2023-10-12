;*********************************** Int_Reloj_05.asm ************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Visualiza el tiempo que mantiene presionado un pulsador.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	Segundo				; Guarda los segundos.
	Centesima			; Incrementa cada 10 ms.
	ENDC
;
#DEFINE  IncrementarPulsador	PORTB,6

TMR0_Carga10ms		EQU	-d'156'	; Para conseguir la interrupción del
					; Timer 0 cada 10 ms.
; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0
	goto	Inicio
	ORG	4
	goto	ServicioInterrupcion

Inicio	call	LCD_Inicializa
	bsf	STATUS,RP0
	movlw	b'00000101'		; Prescaler de 64 para el TMR0.
	movwf	OPTION_REG
	bsf	IncrementarPulsador
	bcf	STATUS,RP0
	clrf	Segundo			; Inicializa los registros y visualiza.
	clrf	Centesima
	call	Visualiza
Principal
	btfsc	IncrementarPulsador
	goto	Fin			; Si no está pulsado visualiza el último tiempo.
	call	LCD_Borra		; Borra la pantalla.
	clrf	Segundo			; Inicializa los registros.
	clrf	Centesima
	movlw	TMR0_Carga10ms		; Carga el TMR0.
	movwf	TMR0
	movlw	b'10100000'		; Autoriza interrupción del TMR0 (T0IE).
	movwf	INTCON
EsperaDejePulsar
	btfsc	IncrementarPulsador
	goto	InhabilitaInterrupciones
	call	Visualiza		; Visualiza el tiempo que lleva pulsado.
	goto	EsperaDejePulsar
	goto	Fin
InhabilitaInterrupciones
	clrf	INTCON			; Prohibe interrupciones.
Fin	goto	Principal
	
; Subrutina "ServicioInterrupcion" ------------------------------------------------------
;
; Se ejecuta debido a la petición de interrupción del Timer 0 cada 10 ms.
;
	CBLOCK	
	Guarda_W
	Guarda_STATUS
	ENDC

ServicioInterrupcion
	movwf	Guarda_W		; Guarda los valores de tenían W y STATUS en el
	swapf	STATUS,W		; programa principal.
	movwf	Guarda_STATUS
	bcf	STATUS,RP0		; Garantiza que trabaja en el Banco 0.
	call	Retardo_5micros		; Para ajustar a 10 ms exactos.
	nop
  	movlw	TMR0_Carga10ms		; Carga el Timer 0.
	movwf	TMR0
	call	IncrementaCentesimas
	btfss	STATUS,C		; ¿Ha contado 100 veces 10 ms = 1 segundo?
	goto	FinInterrupcion		; No. Pues sale.
	incf	Segundo,F		; Sí. Incrementa el segundero.
FinInterrupcion
	swapf	Guarda_STATUS,W	; Restaura registros W y STATUS.
	movwf	STATUS
	swapf	Guarda_W,F
	swapf	Guarda_W,W
	bcf	INTCON,T0IF
	retfie

; Subrutina "Visualiza" -----------------------------------------------------------------
;
Visualiza
	movlw	.5			; Para centrar visualización
	call	LCD_PosicionLinea1
	movf	Segundo,W		; Visualiza segundos.
	call	BIN_a_BCD		; Lo pasa a BCD.
	call	LCD_Byte
	movlw	','			; Visualiza la coma.
	call	LCD_Caracter
	movf	Centesima,W		; Visualiza las centésimas de segundo.
	call	BIN_a_BCD		; Lo pasa a BCD.
	call	LCD_ByteCompleto
	return
;
; Subrutina "IncrementaCentesimas" ----------------------------------------------------
;
IncrementaCentesimas
	incf	Centesima,F
	movlw	.100
	subwf	Centesima,W		; (W)=(Centesima)-100.
	btfsc	STATUS,C		; ¿C=0?, ¿(W) negativo?, ¿(Centesima) < 100?
	clrf	Centesima		; Lo inicializa si ha superado su valor máximo.
	return

	INCLUDE  <RETARDOS.INC>
	INCLUDE  <LCD_4BIT.INC>
	INCLUDE  <BIN_BCD.INC>
	END

;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
