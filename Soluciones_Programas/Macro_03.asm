;*********************************** Macro_03.asm *************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Programa para el Juego de la Bonoloto. Al presionar sobre el pulsador conectado al pin RA4,
; se incrementar� un contador r�pidamente de 1 a 49. Cuando se suelta el pulsador aparece el
; n�mero seleccionado.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK	0x0C
	Contador
	ENDC

Minimo	EQU	.1
Maximo	EQU	.49

#DEFINE	Pulsador 	PORTA,4		; L�nea donde se conecta el pulsador.

; ZONA DE C�DIGOS *******************************************************************

	INCLUDE  <MACROS.INC>		; La definici�n de las macros se deben realizar
					; antes que �stas sean invocadas.
	ORG 	0
Inicio
 	call	LCD_Inicializa
	movlw	MensajeBonoloto
	call	LCD_Mensaje
	bsf	STATUS,RP0		; Acceso al Banco 1.
	bsf	Pulsador		; L�nea del pulsador configurada como entrada.
	bcf	STATUS,RP0		; Acceso al Banco 0.
Principal
	btfsc	Pulsador		; Lee el pulsador.
	goto	Fin
	Incrementa	Contador,Minimo,Maximo,Visualiza
Visualiza
	movlw	.7			; Se sit�a en el centro de la segunda l�nea
	call	LCD_PosicionLinea2	; para visualizar el contador.
	VisualizaBCD	Contador
Fin	goto	Principal
;
; "Mensajes" ----------------------------------------------------------------------------
;
Mensajes
	addwf	PCL,F
MensajeBonoloto
	DT " Bono Loto:", 0x00

	INCLUDE  <RETARDOS.INC>
	INCLUDE  <BIN_BCD.INC>
	INCLUDE  <LCD_4BIT.INC>
	INCLUDE  <LCD_MENS.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
