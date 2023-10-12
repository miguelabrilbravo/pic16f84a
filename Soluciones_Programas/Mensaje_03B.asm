;************************************ Mensaje_03B.asm ***********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Se repite el programa anterior, pero resuelto de una forma más eficaz.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK	0x0C
	Contador			; Contabiliza el mensaje a visualizar.
	ENDC
	
ValorMaximo	EQU	.6		; Número de mensajes a visualizar

; ZONA DE CÓDIGOS ********************************************************************

	ORG	0
Inicio
	call	LCD_Inicializa
	clrf	Contador		; Contabiliza el mensaje 0.
Principal
	movlw	ValorMaximo		; Comprueba que Contador no haya llegado al máximo.
	subwf	Contador,W		; (W)=(Contador)-ValorMaximo
	btfss	STATUS,C		; ¿C=1?, ¿W positivo?, ¿(Contador)>=ValorMaximo?
	goto	Visualiza		; No. El contador todavía no ha llegado al máximo.
	clrf	Contador		; Sí. Inicializa el contador y lo visualiza.	
	call	LCD_Borra		; Pantalla apagada durante unos instantes 
	call	Retardo_5s		; para señalar el último mensaje de la lista.
Visualiza
	call	LCD_Borra		; Borra la pantalla y se sitúa en la línea 1.
	call	Retardo_200ms
	movf	Contador,W		; Apunta al mensaje que se va a visualizar.
	call	ApuntaMensaje
	call	LCD_Mensaje		; Lo visualiza.
	call	Retardo_2s		; Se visualiza el mensaje durante este tiempo.
	incf	Contador,F		; Incrementa el contador.
	goto	Principal		; Repite el proceso.
;
ApuntaMensaje
	addwf	PCL,F
	retlw	Mensaje0
	retlw	Mensaje1
	retlw	Mensaje2
	retlw	Mensaje3
	retlw	Mensaje4
	retlw	Mensaje5

; "Mensajes" ----------------------------------------------------------------------------
;
Mensajes
	addwf	PCL,F
Mensaje0				; Posición inicial del mensaje 0.
	DT "Estudia PIC, es", 0x00;
Mensaje1				; Posición inicial del mensaje 1.
	DT "muy divertido.", 0x00	
Mensaje2				; Posición inicial del mensaje 2.
	DT "IES ISAAC PERAL", 0x00	
Mensaje3				; Posición inicial del mensaje 3.
	DT "Torrejon.", 0x00	
Mensaje4				; Posición inicial del mensaje 4.
	DT "    Estudia ", 0x00
Mensaje5				; Posición inicial del mensaje 5.
	DT "  ELECTRONICA ", 0x00

	INCLUDE  <LCD_4BIT.INC>
	INCLUDE  <LCD_MENS.INC>
	INCLUDE  <RETARDOS.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
