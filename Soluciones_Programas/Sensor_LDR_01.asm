;********************************** Sensor_LDR_01.asm ***********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Una LDR se conecta a la entrada Trigger Schmitt RA4/T0CKI aplicando impulsos al Timer 0 cada
; vez que se oscurece al interponerse un objeto entre la fuente de luz y la LDR. En la pantalla
; del m�dulo LCD se visualiza el n�mero de veces que se interrumpe el haz de luz en dos d�gitos
; (hasta 99 m�ximo).
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK	0x0C
	ENDC

; ZONA DE C�DIGOS ********************************************************************

	ORG 	0
Inicio
	call	LCD_Inicializa
	bsf	STATUS,RP0		; Acceso al Banco 1.
	movlw	b'00101000'		; TMR0 como contador por flanco ascendente de 
	movwf	OPTION_REG		; RA4/T0CKI. Prescaler asignado al Watchdog.
	bcf	STATUS,RP0		; Acceso al Banco 0.
	clrf	TMR0			; Inicializa contador.

; La secci�n "Principal" es de mantenimiento. S�lo se dedica a visualizar el Timer 0, cuya
; cuenta se incrementa con los flancos ascendentestes procedente de la entrada Trigger Schmitt
; RA4/T0CKI donde se ha conectado la LDR.

Principal
	call	LCD_Linea1		; Se pone al principio de la l�nea 1.
	movf	TMR0,W			; Lee el Timer 0.
	call	BIN_a_BCD		; Se debe visualizar en BCD.
	call	LCD_Byte		; Visualiza, apagando las decenas en caso de que sean 0.
	goto	Principal

	INCLUDE  <RETARDOS.INC>
	INCLUDE  <BIN_BCD.INC>
	INCLUDE  <LCD_4BIT.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
