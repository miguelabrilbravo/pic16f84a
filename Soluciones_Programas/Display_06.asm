;************************************* Display_06.asm ***********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Visualiza por el display conectado a la salida, un carácter determinado dentro de un
; mensaje grabado en la memoria ROM de programa mediante la directiva "DT". El número del
; carácter a visualizar será la cantidad leída por la entrada.
;
; Así por ejemplo, si el texto grabado en la ROM es: "ESTUDIA ELECTRONICA" y la cantidad
; leída por la entrada es "---01001" (9 en decimal) por el display aparecerá "L" que es
; el carácter situado en el lugar 9 del mensaje (la primera letra "E" está en el lugar 0).
;
; Si el número de caracteres del mensaje es menor que la cantidad de entrada se encenderá
; el punto decimal.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C			; En esta posición empieza la RAM de usuario.
	ENDC

; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0			; El programa comienza en la dirección 0.
Inicio
	bsf	STATUS,RP0		; Acceso al Banco 1.
	clrf	PORTB			; Las líneas del Puerto B se configuran como salida.
	movlw	b'00011111'		; Las 5 líneas del Puerto A se configuran como entrada.
	movwf	PORTA
	bcf	STATUS,RP0		; Acceso al Banco 0.
Principal
	movlw	(MensajeFin-MensajeInicio)	; Halla la longitud del mensaje.
	subwf	PORTA,W			; (W)=(PORTA)-Longitud Mensaje.
	btfsc	STATUS,C		; ¿C=0?, ¿(W) negativo?, ¿(PORTA)<Longitud Mensaje?
	goto	MensajeMenor		; No. Entonces la entrada se pasa de valor.
	movf	PORTA,W			; Lee el número de carácter dentro del mensaje.
	call	LeeCaracter		; Obtiene el carácter dentro del mensaje y lo
	call	ASCII_a_7Segmentos 	; pasa a código de 7 segmentos.
	goto	ActivarSalida
MensajeMenor
	movlw	b'10000000'		; Como el mensaje es de menor longitud que el número de
ActivarSalida				; carácter solicitado, se enciende el punto decimal.
	movwf	PORTB			; Resultado se visualiza por el puerto de salida.
	goto 	Principal
;
; Subrutina "LeeCaracter" ---------------------------------------------------------------
;
LeeCaracter
	addwf	PCL,F
MensajeInicio				; Indica la posición inicial del mensaje.
	DT	"ESTUDIA ELECTRONICA"
MensajeFin				; Indicar la posición final del mensaje.
;
	INCLUDE  <DISPLAY_7S.INC>	; Subrutina ASCII_a_7Segmentos.
	END

;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
