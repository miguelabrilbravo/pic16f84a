;************************************** Indexado_03.asm *********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Programa para comprobar el efecto de un uso incorrecto de la instrucci�n "addwf PCL,F".
; Se debe comprobar con el simulador del MPLAB.
;
; ZONA DE DATOS **********************************************************************

	INCLUDE  <P16F84.INC>	
	LIST	   P=16F84

; ZONA DE C�DIGOS ********************************************************************

	ORG 	0
Inicio
	goto	Principal		; Posici�n 000h de memoria de programa.
	clrw				; Posici�n 001h de memoria de programa.
	goto	Inicio			; Posici�n 002h de memoria de programa.

	ORG	0xFE			; Fija la posici�n de la memoria de programa en 0x0FE.
Principal
	movlw	.1			; Posici�n 0FEh de memoria de programa.
	addwf	PCL,F			; Posici�n 0FFh de memoria de programa.
	goto	Configuracion0		; Posici�n 100h de memoria de programa.
	goto	Configuracion1		; Posici�n 101h de memoria de programa.
	
; La intenci�n de la instrucci�n "addwf PCL,F" es saltar a la posici�n de la instrucci�n 
; "goto Configuracion1", que est� en la posici�n 101h de memoria de programa pero, como el
; contenido del registro PCLATH no ha cambiado de valor, realmente salta a la posici�n que 
; indica el contador de programa que en este caso es (PC)=(PCLATH)(PCL) = 0001h, es decir, ha 
; saltado a la posici�n donde se encuentra la instrucci�n "clrw". El salto se ha descontrolado.

Configuracion0
Configuracion1

	END				; Fin del programa.
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
