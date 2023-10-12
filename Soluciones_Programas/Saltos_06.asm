;************************************* Saltos_06.asm ************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84A. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Lee las tres líneas más bajas del puerto A, que fijan la cantidad del número de LEDs a
; iluminar. Por ejemplo, si (PORTA)=b'---00101' (cinco) se encenderán cinco diodos LEDs
; (D4, D3, D2, D1 y D0). Hay que utilizar la instrucción de rotación "rlf".
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	P=16F84A
	INCLUDE <P16F84A.INC>

	CBLOCK	0x0C			; RAM de usuario a partir de esta dirección.
	Contador			; Contará las veces que tiene que rotar el diodo.
	RegDesplaza			; Registro que se desplazará.
	ENDC

; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0			; El programa comienza en la dirección 0.
Inicio
	bsf	STATUS,RP0		; Acceso al Banco 1.
	clrf	TRISB			; Las líneas del Puerto B se configuran como salida.
	movlw	b'00011111'		; Las 5 líneas del Puerto A se configuran como entrada.
	movwf	TRISA
	bcf	STATUS,RP0		; Acceso al Banco 0.
Principal
	movf	PORTA,W			; Lee el dato de entrada.
	andlw	b'00000111'		; Se queda con los tres bits más bajos.
	movwf	Contador		; El dato de entrada pasará al Contador.
	movf	Contador,F		; Solo sirve para posicionar flag Z del STATUS.
	btfsc	STATUS,Z		; ¿Z=0?, ¿(Contador) es distinto de cero?
	goto	ActivaSalida		; No. Es cero. Los LEDs se apagan.
	clrf	RegDesplaza		; Si, efectivamente es distinto de cero. Rota.
DesplazaOtraVez				; La primera vez con todos los LEDs apagados.
	bsf	STATUS,C		; Pone a 1 el Carry. Este 1 será el que rote a
	rlf	RegDesplaza,F		; izquierdas por el registro RegDesplaza.
	decfsz 	Contador,F		; Rota tantas veces como indique el (Contador).
	goto	DesplazaOtraVez
	movf	RegDesplaza,W		; Se carga en W para visualizarlo a la salida.
ActivaSalida
	movwf	PORTB			; Resultado se visualiza por el puerto de salida.
	goto 	Principal

	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84A. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================

