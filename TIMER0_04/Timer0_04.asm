;************************************** Timer0_04.asm ***********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Por la línea RB3 se genera una onda rectangular de 500 µs en alto y 300 µs en bajo.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK	0x0C
	ENDC

TMR0_Carga_500us EQU	-d'242'		; Estos valores se han obtenido
TMR0_Carga_300us EQU	-d'143'		; experimentalmente.
#DEFINE		Salida	PORTB,3

; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0
Inicio
	bsf	STATUS,RP0
	bcf	Salida			; Esta línea se configura como salida.
	movlw	b'00000000'
	movwf	OPTION_REG		; Prescaler de 2 para el TMR0
	bcf	STATUS,RP0
Principal
	bsf	Salida			; La salida pasa a nivel alto
	call	Timer0_500us		; durante este tiempo.
	bcf	Salida			; La salida pasa a nivel bajo
	call	Timer0_300us		; durante este tiempo.
	goto 	Principal

; Subrutinas "Timer0_500us" y "Timer0_300us" --------------------------------------------
;
Timer0_500us
	nop				; Para ajustar el tiempo exacto.
	nop
	movlw	TMR0_Carga_500us
	goto	Timer0_Temporizador
Timer0_300us
	movlw	TMR0_Carga_300us
Timer0_Temporizador
	movwf	TMR0			; Carga el Timer 0.
	bcf	INTCON,T0IF		; Resetea el flag de desbordamiento del TMR0. 
Timer0_Rebosamiento
	btfss	INTCON,T0IF		; ¿Se ha producido desbordamiento?
	goto	Timer0_Rebosamiento	; Todavía no. Repite.
	return

	END

;	====================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS".
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	====================================================================
