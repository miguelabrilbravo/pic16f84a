;************************************ RS232_02.asm **************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; En el módulo LCD se visualizan los caracteres que se escriban en el teclado del ordenador
; y se transmiten a  través de su puerto serie. Estos datos volverán a ser enviados por el
; microcontrolador al ordenador, por lo que también se visualizarán en su monitor.
;
; Se utilizará un programa de comunicaciones para que el ordenador pueda enviar datos
; a través de su puerto serie, como el HyperTerminal de Windows o alguno similar.

; Concluyendo, lo que se escriba en el teclado del ordenador aparecerá en la pantalla del
; módulo LCD y en el monitor del HyperTerminal.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK	0x0C
	GuardaDato
	ENDC

; ZONA DE CÓDIGOS ********************************************************************

	ORG	0
Inicio
	call	LCD_Inicializa		; Inicializa el LCD y las líneas que se
	call	RS232_Inicializa		; van a utilizar en la comunicación con el puerto
Principal					; serie RS232.
	call	RS232_LeeDato		; Espera recibir un carácter.
	movwf	GuardaDato		; Guarda el dato recibido.
	call	LCD_Caracter		; Lo visualiza.
	movf	GuardaDato,W		; Y ahora lo reenvía otra vez al ordenador.
	call	RS232_EnviaDato
	goto	Principal			; Repite el proceso.
;
	INCLUDE  <RS232.INC>
	INCLUDE  <LCD_4BIT.INC>
	INCLUDE  <RETARDOS.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
