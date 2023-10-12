;************************************ RS232_02.asm **************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; En el m�dulo LCD se visualizan los caracteres que se escriban en el teclado del ordenador
; y se transmiten a  trav�s de su puerto serie. Estos datos volver�n a ser enviados por el
; microcontrolador al ordenador, por lo que tambi�n se visualizar�n en su monitor.
;
; Se utilizar� un programa de comunicaciones para que el ordenador pueda enviar datos
; a trav�s de su puerto serie, como el HyperTerminal de Windows o alguno similar.

; Concluyendo, lo que se escriba en el teclado del ordenador aparecer� en la pantalla del
; m�dulo LCD y en el monitor del HyperTerminal.
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
	call	LCD_Inicializa		; Inicializa el LCD y las l�neas que se
	call	RS232_Inicializa		; van a utilizar en la comunicaci�n con el puerto
Principal					; serie RS232.
	call	RS232_LeeDato		; Espera recibir un car�cter.
	movwf	GuardaDato		; Guarda el dato recibido.
	call	LCD_Caracter		; Lo visualiza.
	movf	GuardaDato,W		; Y ahora lo reenv�a otra vez al ordenador.
	call	RS232_EnviaDato
	goto	Principal			; Repite el proceso.
;
	INCLUDE  <RS232.INC>
	INCLUDE  <LCD_4BIT.INC>
	INCLUDE  <RETARDOS.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
