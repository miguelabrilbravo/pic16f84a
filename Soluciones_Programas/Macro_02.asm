;*********************************** Macro_02.asm *************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Es el mismo ejercicio que Macro_01.asm, pero resueltos con macros.
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

; ZONA DE CÓDIGOS *******************************************************************

	INCLUDE  <MACROS.INC>		; La definición de las macros se deben realizar
					; antes de que esta sean invocadas.
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
	Incrementa	Contador1,Minimo1,Maximo1,IncrementaContador2
IncrementaContador2
	Incrementa	Contador2,Minimo2,Maximo2,VisualizaContadores
VisualizaContadores
	call	LCD_Linea1
	VisualizaBCD	Contador1
	call	LCD_Linea2
	VisualizaBCD	Contador2
	call	Retardo_200ms
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
