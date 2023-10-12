;************************************ RS232_04.asm ************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; En el modulo LCD se visualizan los caracteres que se escriben en el teclado del ordenador.
; Si pulsa la tecla Enter se comienza a escribir en la segunda línea de la pantalla del
; módulo LCD.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	GuardaDato
	ENDC

RetornoCarro	EQU	d'13'		; Código la de tecla "Enter".
CambioLinea	EQU	d'10'		; Código para el "Cambio de línea".

; ZONA DE CÓDIGOS ********************************************************************

	ORG	0
Inicio
	call	LCD_Inicializa
	call	RS232_Inicializa
Principal
	call	RS232_LeeDato		; Espera recibir un carácter.
	movwf	GuardaDato		; Guarda el dato recibido.
	sublw	RetornoCarro		; Comprueba si ha pulsado la tecla Enter.
	btfsc	STATUS,Z
	goto	SaltaLinea2		; Sí, es Enter y por tanto salta a la 2ª línea.
	movf	GuardaDato,W		; No es Enter y por tanto lo visualiza
	call	LCD_Caracter		; en el LCD.
	goto	EnviaCaracter_a_Ordenador
SaltaLinea2
	call	LCD_Linea2		; Sí, lo ha pulsado, salta a la segunda línea y
	movlw	CambioLinea		; no lo visualiza en el LCD. En el monitor del 
	call	RS232_EnviaDato		; ordenador se debe apreciar también un cambio
EnviaCaracter_a_Ordenador		; de línea.
	movf	GuardaDato,W		; Y ahora lo reenvía otra vez al ordenador.
	call	RS232_EnviaDato	
	goto	Principal

	INCLUDE  <RS232.INC>
	INCLUDE  <LCD_4BIT.INC>
	INCLUDE  <RETARDOS.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
