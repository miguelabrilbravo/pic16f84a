;************************************ Timer0_01.asm *************************************
;
;	====================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS".
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	====================================================================
;
; Este programa comprueba el funcionamiento del Timer 0 como contador de los impulsos
; aplicados a la línea RA4/T0CKI, donde se ha conectado un pulsador. Cada vez que presiona
; el pulsadar se incrementa un contador visualizado en el display LCD.
;
; Como es un incremento por cada impulso aplicado al pin TOCKI no es necesario asignarle
; divisor de frecuencia al TMR0, por tanto, el Prescaler se asigna al Watchdog.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK	0x0C
	ENDC

; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0
Inicio
	call	LCD_Inicializa
	bsf	STATUS,RP0		; Acceso al Banco 1.
	movlw	b'00111000'		; TMR0 como contador por flanco descendente de 
	movwf	OPTION_REG		; RA4/T0CKI. Prescaler asignado al Watchdog.
	bcf	STATUS,RP0		; Acceso al Banco 0.
	clrf	TMR0			; Inicializa el contador.

; La sección "Principal" es de mantenimiento. Sólo se dedica a visualizar el Timer 0.

Principal
	call	LCD_Linea1		; Se pone al principio de la línea 1.
	movf	TMR0,W			; Lee el Timer 0.
	call	BIN_a_BCD		; Se debe visualizar en BCD.
	call	LCD_Byte		; Visualiza apagando las decenas en caso de que sean 0.
	goto	Principal

	INCLUDE  <RETARDOS.INC>
	INCLUDE  <BIN_BCD.INC>
	INCLUDE  <LCD_4BIT.INC>
	END
	
;	====================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS".
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	====================================================================
