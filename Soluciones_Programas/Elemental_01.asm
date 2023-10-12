;*********************************** Elemental_01.asm ***********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Por el Puerto B se obtiene el dato de las cinco l�neas del Puerto A, al que est� conectado
; un array de interruptores, sum�ndole el valor de una constante, por ejemplo 74.
; Es decir: (PORTB)=(PORTA)+Constante

; ZONA DE DATOS *********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A		; Procesador utilizado.
	INCLUDE  <P16F84A.INC>		; Definici�n de algunos operandos utilizados.

Constante  EQU	d'74'			; En sistema decimal se pone as�.

; ZONA DE C�DIGOS *******************************************************************

	ORG 	0			; El programa comienza en la direcci�n 0.
Inicio
	bsf	STATUS,RP0		; Pone a 1 el bit 5 del STATUS. Acceso al Banco 1.
	clrf	TRISB			; Las l�neas del Puerto B configuradas como salidas.
	movlw	b'00011111'		; Las 5 l�neas del Puerto A configuradas como entradas.
	movwf	TRISA
	bcf	STATUS,RP0		; Pone a 0 el bit 5 de STATUS. Acceso al Banco 0.
Principal
	movf 	PORTA,W			; Carga el registro de datos del Puerto A en (W).
	addlw	Constante		; (W)=(PORTA)+Constante. 
	movwf	PORTB			; El contenido de W se deposita en el puerto de salida.
	goto 	Principal		; Crea un bucle cerrado e infinito.

	END				; Fin del programa.
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
