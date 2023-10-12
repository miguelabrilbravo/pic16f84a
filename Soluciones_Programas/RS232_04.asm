;************************************ RS232_04.asm ************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; En el modulo LCD se visualizan los caracteres que se escriben en el teclado del ordenador.
; Si pulsa la tecla Enter se comienza a escribir en la segunda l�nea de la pantalla del
; m�dulo LCD.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	GuardaDato
	ENDC

RetornoCarro	EQU	d'13'		; C�digo la de tecla "Enter".
CambioLinea	EQU	d'10'		; C�digo para el "Cambio de l�nea".

; ZONA DE C�DIGOS ********************************************************************

	ORG	0
Inicio
	call	LCD_Inicializa
	call	RS232_Inicializa
Principal
	call	RS232_LeeDato		; Espera recibir un car�cter.
	movwf	GuardaDato		; Guarda el dato recibido.
	sublw	RetornoCarro		; Comprueba si ha pulsado la tecla Enter.
	btfsc	STATUS,Z
	goto	SaltaLinea2		; S�, es Enter y por tanto salta a la 2� l�nea.
	movf	GuardaDato,W		; No es Enter y por tanto lo visualiza
	call	LCD_Caracter		; en el LCD.
	goto	EnviaCaracter_a_Ordenador
SaltaLinea2
	call	LCD_Linea2		; S�, lo ha pulsado, salta a la segunda l�nea y
	movlw	CambioLinea		; no lo visualiza en el LCD. En el monitor del 
	call	RS232_EnviaDato		; ordenador se debe apreciar tambi�n un cambio
EnviaCaracter_a_Ordenador		; de l�nea.
	movf	GuardaDato,W		; Y ahora lo reenv�a otra vez al ordenador.
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
