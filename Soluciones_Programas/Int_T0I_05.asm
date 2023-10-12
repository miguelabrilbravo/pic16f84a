;************************************ Int_T0I_05.asm ************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; El módulo LCD visualiza constantemente un mensaje largo que se desplaza por la pantalla.
; Al mismo tiempo el diodo LED conectado a la línea RB1 se enciende durante 500 ms y se apaga
; durante otros 500 ms a modo de segundero.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	Registro50ms
	ENDC

Carga500ms	EQU	d'10'
TMR0_Carga50ms	EQU	-d'195'
#DEFINE		LED	PORTB,1

; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0
	goto	Inicio
	ORG	4
	goto	Timer0_Interrupcion
Inicio
	call	LCD_Inicializa
	bsf	STATUS,RP0
	bcf	LED
	movlw	b'00000111'
	movwf	OPTION_REG		; Prescaler de 256 para el TMR0
	bcf	STATUS,RP0
	movlw	TMR0_Carga50ms		; Carga el Timer 0.
	movwf	TMR0
	movlw	Carga500ms
	movwf	Registro50ms		; Número de veces a repetir la interrupción.
	movlw	b'10100000'		; Activa interrupción del TMR0 (TOIE) y la
	movwf	INTCON			; general (GIE).
Principal
	movlw	MensajeLargo
	call	LCD_MensajeMovimiento
	goto 	Principal

; Subrutina "Timer0_Interrupcion" -------------------------------------------------------
;
; La interrupción se produce cada 50 ms aproximadamente. Para conseguir una temporización
; de 500 ms habrá que repetir 10 veces el lazo de 50 ms.
; Como esta subrutina altera los valores del registro de trabajo W y del STATUS
; habrá que preservar su valor previo y restaurarlos al final.

	CBLOCK	
	Guarda_W
	Guarda_STATUS
	ENDC

Timer0_Interrupcion
	movwf	Guarda_W		; Guarda W y STATUS.
	swapf	STATUS,W		; Ya que "movf STATUS,W" corrompe el bit Z.
	movwf	Guarda_STATUS
	bcf	STATUS,RP0		; Para asegurarse de que trabaja con el banco 0.
	movlw	TMR0_Carga50ms
	movwf	TMR0			; Recarga el TMR0.
	decfsz	Registro50ms,F		; Decrementa el contador.
	goto	FinInterrupcion
	movlw	Carga500ms		; Repone el contador nuevamente.
	movwf	Registro50ms
	btfsc	LED			; Pasa a conmutar el estado del LED.
	goto	EstabaEncendido
EstabaApagado
	bsf	LED			; Lo enciende.
	goto	FinInterrupcion
EstabaEncendido
	bcf	LED			; Lo apaga.
FinInterrupcion
	swapf	Guarda_STATUS,W		; Restaura el STATUS.
	movwf	STATUS
	swapf	Guarda_W,F		; Restaura W como estaba antes de producirse
	swapf	Guarda_W,W		; la interrupción.
	bcf	INTCON,T0IF
	retfie

; Subrutina "Mensajes" ------------------------------------------------------------------
;
Mensajes
	addwf	PCL,F
MensajeLargo
	DT " 		    "
	DT "Estudia \"Desarrollo de Productos Electronicos\"."
	DT "                ", 0x00
;
	INCLUDE  <LCD_MENS.INC>
	INCLUDE  <LCD_4BIT.INC>
	INCLUDE  <RETARDOS.INC>
	END

;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================

