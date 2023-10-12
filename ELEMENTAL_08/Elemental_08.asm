;*********************************** Elemental_08.asm ***********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Por el Puerto B se obtiene el dato del Puerto A desplazando un bit hacia la derecha, por
; la izquierda entrar� un "0". Por ejemplo, si por el Puerto A se introduce "---11001", 
; por el Puerto B aparecer� "0xxx1100".

; ZONA DE DATOS *********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A		; Procesador utilizado.
	INCLUDE  <P16F84A.INC>		; Definici�n de algunos operandos utilizados.

; ZONA DE C�DIGOS ********************************************************************

	ORG 	0			; El programa comienza en la direcci�n 0.
Inicio
	bsf	STATUS,RP0		; Acceso al Banco 1.
	clrf	TRISB			; Las l�neas del Puerto B se configuran como salida.
	movlw	b'00011111'		; Las 5 l�neas del Puerto A se configuran como entrada.
	movwf	TRISA
	bcf	STATUS,RP0		; Acceso al Banco 0.
Principal
 	bcf	STATUS,C		; Este "0" es el que entrar� por la izquierda.
	rrf	PORTA,W			; Rota los bits una posici�n a la derecha y lo
	movwf	PORTB			; lleva al Puerto B para que se visualice.
	goto 	Principal		; Se crea un bucle cerrado e infinito.

	END				; Fin del programa.
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
