;*********************************** Watchdog_01.asm ************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Este programa comprueba el funcionamiento de la instrucción "sleep" y el "Watchdog".
; El PIC se pone en modo bajo consumo. El despertar del mismo se producirá cada vez que el
; Watchdog desborde su cuenta, en ese momento se producirá un incremento de un contador que se
; visualizará en pantalla. El proceso debe repetirse cada medio segundo aproximadamente.
;
; Con un preescaler de 32 el desbordamiento del Watchdog se producirá cada 
; 18 x 32 = 576 ms, es decir, cada medio segundo aproximadamente.

; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_ON & _PWRTE_ON & _XT_OSC

; Observad que se ha habilitado el Watchdog.

	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK	0x0C
	Contador
	ENDC

; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0
Inicio
	call	LCD_Inicializa
	bsf	STATUS,RP0
	movlw	b'00001101'		; Un prescaler de 32 es asignado al Watchdog.
	movwf	OPTION_REG
	bcf	STATUS,RP0
	clrf	Contador		; Inicializa el contador y lo visualiza.

; La sección "Principal" es de mantenimiento. Visualiza y pasa a modo bajo consumo
; del cual solo puede salir por desbordamiento del Watchdog.

Principal
	call	LCD_Linea1
	movf	Contador,W		; Pasa a visualizar el contador.
	call	BIN_a_BCD		; Se debe visualizar en BCD.
	call	LCD_Byte		; Visualiza el contador.
	sleep				; Pasa a modo de bajo consumo.
	incf	Contador,F		; El Watchdog incrementa el contador.
	goto	Principal

	INCLUDE  <RETARDOS.INC>
	INCLUDE  <BIN_BCD.INC>
	INCLUDE  <LCD_4BIT.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
