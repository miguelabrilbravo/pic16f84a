;********************************** Indexado_01.asm *************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Implementar una tabla de la verdad mediante el manejo de tablas grabadas en ROM.
; Por ejemplo, la tabla será de 3 entradas y 6 salidas tal como la siguiente:
; 
; 		C  B  A  | S5  S4  S3  S2  S1  S0
; 		-----------|---------------------------
; 		0   0   0   |   0    0    1    0    1    0	; (Configuración 0).
; 		0   0   1   |   0    0    1    0    0    1	; (Configuración 1).
; 		0   1   0   |   1    0    0    0    1    1	; (Configuración 2).
; 		0   1   1   |   0    0    1    1    1    1	; (Configuración 3).
; 		1   0   0   |   1    0    0    0    0    0	; (Configuración 4).
; 		1   0   1   |   0    0    0    1    1    1	; (Configuración 5).
; 		1   1   0   |   0    1    0    1    1    1	; (Configuración 6).
; 		1   1   1   |   1    1    1    1    1    1	; (Configuración 7).
;
; Las entradas C, B, A se conectarán a las líneas del puerto A: RA2 (C), RA1 (B) y RA0 (A).
; Las salidas se obtienen en el puerto B:
; RB5 (S5), RB4 (S4), RB3 (S3), RB2 (S2), RB1 (S1) y RB0 (S0).
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
	movf	PORTA,W		; Lee el valor de las variables de entrada.
	andlw	b'00000111'		; Se queda con los tres bits de entrada.
	addwf	PCL,F			; Salta a la configuración adecuada.
Tabla
	goto	Configuracion0
	goto	Configuracion1
	goto	Configuracion2
	goto	Configuracion3
	goto	Configuracion4
	goto	Configuracion5
	goto	Configuracion6
	goto	Configuracion7
Configuracion0
	movlw 	b'00001010'		; (Configuración 0).
	goto	ActivaSalida
Configuracion1
	movlw 	b'00001001'		; (Configuración 1).
	goto	ActivaSalida
Configuracion2
	movlw 	b'00100011'		; (Configuración 2).
	goto	ActivaSalida
Configuracion3
	movlw 	b'00001111'		; (Configuración 3).
	goto	ActivaSalida
Configuracion4
	movlw 	b'00100000'		; (Configuración 4).
	goto	ActivaSalida
Configuracion5
	movlw 	b'00000111'		; (Configuración 5).
	goto	ActivaSalida
Configuracion6
	movlw 	b'00010111'		; (Configuración 6).
	goto	ActivaSalida
Configuracion7
	movlw 	b'00111111'		; (Configuración 7).
ActivaSalida
	movwf	PORTB			; Visualiza por el puerto de salida.
	goto 	Principal

	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
