;************************************** Indexado_03.asm *********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Programa para comprobar el efecto de un uso incorrecto de la instrucción "addwf PCL,F".
; Se debe comprobar con el simulador del MPLAB.
;
; ZONA DE DATOS **********************************************************************

	INCLUDE  <P16F84.INC>	
	LIST	   P=16F84

; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0
Inicio
	goto	Principal		; Posición 000h de memoria de programa.
	clrw				; Posición 001h de memoria de programa.
	goto	Inicio			; Posición 002h de memoria de programa.

	ORG	0xFE			; Fija la posición de la memoria de programa en 0x0FE.
Principal
	movlw	.1			; Posición 0FEh de memoria de programa.
	addwf	PCL,F			; Posición 0FFh de memoria de programa.
	goto	Configuracion0		; Posición 100h de memoria de programa.
	goto	Configuracion1		; Posición 101h de memoria de programa.
	
; La intención de la instrucción "addwf PCL,F" es saltar a la posición de la instrucción 
; "goto Configuracion1", que está en la posición 101h de memoria de programa pero, como el
; contenido del registro PCLATH no ha cambiado de valor, realmente salta a la posición que 
; indica el contador de programa que en este caso es (PC)=(PCLATH)(PCL) = 0001h, es decir, ha 
; saltado a la posición donde se encuentra la instrucción "clrw". El salto se ha descontrolado.

Configuracion0
Configuracion1

	END				; Fin del programa.
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
