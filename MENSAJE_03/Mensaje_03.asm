;************************************ Mensaje_03.asm ************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; En la pantalla se visualizan varios mensajes, uno detrás de otro. Cada mensaje permanece
; durante 2 segundos. Entre mensaje y mensaje la pantalla se apaga durante unos 200 ms.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	ENDC

; ZONA DE CÓDIGOS ********************************************************************

	ORG	0
Inicio
	call	LCD_Inicializa
Principal
	movlw	Mensaje0		; Apunta al mensaje 0.
	call	Visualiza
	movlw	Mensaje1		; Apunta al mensaje 1.
	call	Visualiza
	movlw	Mensaje2		; Apunta al mensaje 2.
	call	Visualiza
	call	Retardo_5s		; Permanece apagada durante este tiempo.
	goto	Principal		; Repite la visualización de todos los mensajes.
;
; Subrutina "Visualiza" -----------------------------------------------------------------
;
Visualiza
	call	LCD_Mensaje
	call	Retardo_2s		; Visualiza el mensaje durante este tiempo.
	call	LCD_Borra		; Borra la pantalla y se mantiene así durante 
	call	Retardo_200ms		; este tiempo.
	return
;
; "Mensajes" ----------------------------------------------------------------------------
;
Mensajes
	addwf	PCL,F
Mensaje0				; Posición inicial del mensaje 0.
	DT "Estudia PIC, es", 0x00
Mensaje1				; Posición inicial del mensaje 1.
	DT "muy divertido.", 0x00	
Mensaje2				; Posición inicial del mensaje 2.
	DT "IES ISAAC PERAL", 0x00

	INCLUDE  <LCD_4BIT.INC>
	INCLUDE  <LCD_MENS.INC>
	INCLUDE  <RETARDOS.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================

