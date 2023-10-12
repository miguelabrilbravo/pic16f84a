;************************************ RS232_01.asm **************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; En la pantalla del modulo LCD se visualizarán los caracteres que se reciban a través del
; puerto serie del ordenador. Lo que se escriba por el teclado del ordenador aparecerá en la
; pantalla del sistema con microcontrolador.
;
; Se utilizará un programa de comunicaciones para que el ordenador pueda enviar datos a través
; de su puerto serie. Este programa puede ser el Hyperterminal de Windows o alguno similar.
;       
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK	0x0C
	ENDC

; ZONA DE CÓDIGOS ********************************************************************

	ORG	0
Inicio
	call	LCD_Inicializa		; Inicializa el LCD y las líneas que se
	call	RS232_Inicializa	; van a utilizar en la comunicación con el puerto
Principal				; serie RS232.
	call	RS232_LeeDato		; Espera recibir un carácter.
	call	LCD_Caracter	 	; Lo visualiza.
	goto	Principal		; Repite el proceso.

	INCLUDE  <RS232.INC>		; Subrutinas de control de la comunicación con el
	INCLUDE  <LCD_4BIT.INC>		; puerto serie RS232 del ordenador.
	INCLUDE  <RETARDOS.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
