;************************************ RS232_03.asm **************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Lo que se escriba por el teclado se visualiza en el LCD y en el monitor del ordenador,
; pero en �ste �ltimo se visualiza un solo car�cter por l�nea.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK	0x0C
	GuardaDato
	ENDC

RetornoCarro	EQU	.13		; C�digo de tecla "Enter" o "Retorno de Carro".
CambioLinea	EQU	.10		; C�digo para el cambio de l�nea.

; ZONA DE C�DIGOS ********************************************************************

	ORG	0
Inicio
	call	LCD_Inicializa
	call	RS232_Inicializa
Principal
	call	RS232_LeeDato		; Espera recibir un car�cter.
	movwf	GuardaDato		; Guarda el dato recibido.
	call	LCD_Caracter		; Lo visualiza.
	movf	GuardaDato,W		; Y ahora lo reenv�a otra vez al ordenador.
	call	RS232_EnviaDato
	movlw	RetornoCarro		; Ahora el cursor se sit�a al principio de la
	call	RS232_EnviaDato		; l�nea siguiente en la pantalla del ordenador.
	movlw	CambioLinea
	call	RS232_EnviaDato
	goto	Principal

	INCLUDE  <RS232.INC>
	INCLUDE  <LCD_4BIT.INC>
	INCLUDE  <RETARDOS.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
