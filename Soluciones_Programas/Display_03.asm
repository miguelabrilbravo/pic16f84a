;************************************ Display_03.asm ************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Por el display de 7 segmentos conectado al Puerto B se visualiza una de las 26 letras
; del alfabeto internacional: de la "A" a la "Z". La letra a visualizar lo determina el
; orden leído por el Puerto A. Así por ejemplo:
; - Si por el Puerto A se lee "---0000"  (cero) la letra visualizada será la "A"
;   que es la que está en el orden cero.
; - Si por el Puerto A se lee "---1101" (veinticinco) la letra visualizada será la "Z"
;   que es la que está en el orden veinticinco.
;
; Por ahora no se contempla la posibilidad que el número de entrada sea mayor de 25.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0			; El programa comienza en la dirección 0.
Inicio
	bsf	STATUS,RP0		; Acceso al Banco 1.
	clrf	TRISB			; Las líneas del Puerto B se configuran como salida.
	movlw	b'00011111'		; Las 5 líneas del Puerto A se configuran como entrada.
	movwf	TRISA
	bcf	STATUS,RP0		; Acceso al Banco 0.
Principal
	movf	PORTA,W			; Lee la entrada.
	call	Letra_a_7Segmentos	; Convierte a 7 Segmentos.
	movwf	PORTB			; Resultado se visualiza por el puerto de salida.
	goto 	Principal

; Subrutina "Letra_a_7Segmentos" --------------------------------------------------------
;
Letra_a_7Segmentos
	addwf	PCL,F
InicioTabla
	DT	77h, 7Ch, 39h, 5Eh, 79h, 71h, 6Fh, 76h, 19h, 1Eh, 7Ah, 38h, 37h
	DT	54h, 3Fh, 73h, 67h, 50h, 6Dh, 78h, 1Ch, 3Eh, 1Dh, 70h, 6Eh, 49h
FinTabla
	END

;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
