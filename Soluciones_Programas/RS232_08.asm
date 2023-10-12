;************************************ RS232_08.asm **************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Programa que visualiza en el modulo LCD el c�digo ASCII en formato hexadecimal de la
; tecla pulsada y tambi�n en el monitor del ordenador en formato decimal. Por ejemplo:
;    - 	Monitor del ordenador: " k-107", donde la "k" es la tecla pulsada y el "107" el
;	c�digo ASCII en formato decimal.
;    - 	Pantalla del LCD: " k-6B", donde la "k" es la tecla pulsada y el "6B" el
;	c�digo ASCII en formato hexadecimal.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK	0x0C
	GuardaDato
	ENDC

; ZONA DE C�DIGOS ********************************************************************

	ORG	0
Inicio
	call	LCD_Inicializa
	call	RS232_Inicializa
Principal
	call	RS232_LeeDato		; Espera recibir un car�cter.
	movwf	GuardaDato		; Guarda el dato recibido.
	call	LCD_Borra		; Despeja la pantalla del visualizador LCD.
	movf	GuardaDato,W		; Recupera el dato le�do.
	call	LCD_Caracter		; Visualiza el car�cter de la tecla pulsada.
	movlw	'-'			; Visualiza el gui�n.
	call	LCD_Caracter
	movf	GuardaDato,W
	call	LCD_ByteCompleto	; Visualiza en el LCD el c�digo ASCII.
	movf	GuardaDato,W		; Visualiza en la pantalla del ordenador el 
	call	RS232_EnviaDato		; car�cter pulsado.
	movlw	'-'			; Visualiza en el ordenador el gui�n.
	call	RS232_EnviaDato
	movf	GuardaDato,W		; Lo pasa a BCD antes de visualizarlo.
	call	BIN_a_BCD
	movf	BCD_Centenas,W		; Visualiza el resultado en la pantalla  del
	call	RS232_EnviaNumero	; ordenador comenzando por las centenas.
	movf	BCD_Decenas,W
	call	RS232_EnviaNumero
	movf	BCD_Unidades,W
	call	RS232_EnviaNumero
	movlw	' '			; Env�a un espacio en blanco para separarlo del
	call	RS232_EnviaDato		; anterior.
	goto	Principal
;
	INCLUDE  <RS232.INC>
	INCLUDE  <LCD_4BIT.INC>
	INCLUDE  <RETARDOS.INC>
	INCLUDE  <BIN_BCD.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
