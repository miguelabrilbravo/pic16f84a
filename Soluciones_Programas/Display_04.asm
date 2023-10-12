;************************************ Display_04.asm ************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; En un display de 7 segmentos conectado al Puerto B se visualiza una de las 26 letras
; del alfabeto internacional: de la "A" a la "Z". La letra a visualizar la determina el
; valor de la constante "Caracter". El car�cter de entrada debe estar en may�sculas.
; As�, por ejemplo, si "Caracter EQU 'P'" se visualizar� la letra "P" en el display.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C			; En esta posici�n empieza la RAM de usuario.
	ENDC

Caracter EQU	'P'

; ZONA DE C�DIGOS ********************************************************************

	ORG 	0			; El programa comienza en la direcci�n 0.
Inicio
	bsf	STATUS,RP0		; Acceso al Banco 1.
	clrf	PORTB			; Las l�neas del Puerto B se configuran como salida.
	bcf	STATUS,RP0		; Acceso al Banco 0.
Principal
	movlw	Caracter		; Lee el car�cter de entrada.
	call	Letra_a_7Segmentos	; Convierte a 7 Segmentos.
	movwf	PORTB			; Resultado se visualiza por el puerto de salida.
	goto 	Principal

; Subrutina "Letra_a_7Segmentos" --------------------------------------------------------

	CBLOCK
	Display7s_Dato			; Aqu� se reservar� el valor de W.
	ENDC
	
Letra_a_7Segmentos
	movwf	Display7s_Dato		; La letra 'A' est� en la posici�n cero de la
	movlw	'A' 			; tabla y resto de las letras despu�s. As� pues,
	subwf	Display7s_Dato,W	; hay que hacer esta operaci�n.
	addwf	PCL,F
	DT	77h, 7Ch, 39h, 5Eh, 79h, 71h, 6Fh, 76h, 19h, 1Eh, 7Ah, 38h, 37h
	DT	54h, 3Fh, 73h, 67h, 50h, 6Dh, 78h, 1Ch, 3Eh, 1Dh, 70h, 6Eh, 49h

	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
