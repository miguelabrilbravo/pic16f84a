;************************************* Teclado_05.asm ***********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Primero aparece un mensaje de presentación en movimiento. Luego en la primera línea aparece
; un mensaje estático y lo que se va escribiendo por el teclado aparece en la segunda fila.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	ENDC

; ZONA DE CÓDIGOS ********************************************************************

	ORG	0
	goto 	Inicio
	ORG	4
	goto	ServicioInterrupcion
Inicio
	call	LCD_Inicializa
	movlw	MensajePresentacion	; Visualiza el mensaje en movimiento.
	call	LCD_MensajeMovimiento
	call	LCD_Borra		; Borra la pantalla y se sitúa en la 1ª línea.
	movlw	MensajePulsa		; Visualiza el mensaje fijo de la primera línea.
	call	LCD_Mensaje
	call	LCD_Linea2		; Pasa a la segunda línea.
	call	Teclado_Inicializa	; Configura líneas del teclado.
	movlw	b'10001000'		; Habilita la interrupción RBI y la general.
	movwf	INTCON
Principal
	sleep
	goto	Principal

; Subrutina "ServicioInterrupcion" ------------------------------------------------------
;
ServicioInterrupcion
	call	Teclado_LeeHex		; Obtiene el valor hexadecimal de la tecla pulsada.
	call	LCD_Nibble		; Visualiza el valor en pantalla.
	call	Teclado_EsperaDejePulsar
	bcf	INTCON,RBIF
	retfie

; "Mensajes" ----------------------------------------------------------------------------

Mensajes
	addwf	PCL,F
MensajePresentacion
	DT "              "
	DT "Estudia \"Desarrollo de Productos Electronicos\" "
	DT "              ", 0x00
MensajePulsa
	DT "LUCAS, pulsa:", 0x00

	INCLUDE  <TECLADO.INC>
	INCLUDE  <LCD_4BIT.INC>
	INCLUDE  <LCD_MENS.INC>
	INCLUDE  <RETARDOS.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================	
