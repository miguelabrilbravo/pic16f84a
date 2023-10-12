;************************************ I2C_EEPROM_02.asm *******************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Lee un mensaje almacenado en la memoria 24LC256 y lo visualiza por la pantalla del módulo
; LCD desplazándose hacia la izquierda.
; El mensaje tiene que haber sido grabado previamente mediante el IC-Prog o un software similar.
; También se puede grabar mediante el procedimiento explicado en el programa I2C_EEPROM_01.asm.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK	0x0C
	ENDC

Pagina	EQU	0x00
		
; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0
Inicio
	call	LCD_Inicializa
Principal
	movlw	Pagina			; Lee a partir de la dirección 0 de esta página
	call	M24LC256_Mensaje_a_LCD	; de la memoria.
	call	Retardo_1s
	goto	Principal

	INCLUDE  <BUS_I2C.INC>		; Subrutinas de control del bus I2C.
	INCLUDE  <M24LC256.INC>	; Subrutinas de control de la memoria 24LC256.
	INCLUDE  <RETARDOS.INC>
	INCLUDE  <LCD_4BIT.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
