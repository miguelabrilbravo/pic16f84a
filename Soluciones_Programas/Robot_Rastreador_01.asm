;********************************* Robot_Rastreador_01.asm *******************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Programa de control para el microbot TRASTO, el cual se desplaza siguiendo una línea negra
; marcada sobre fondo blanco a modo de pista.
;
; Los sensores ópticos de reflexión CNY70 están situados en la parte delantera inferior del
; microbot: El sensor de la derecha está conectado a RA0 y el sensor de la izquierda a RA1. 
;
; El programa adopta la estrategia de seguir la línea por el borde derecho:
;   - Si detecta que está en el borde derecho: sensor izquierdo sobre negro y derecho sobre
;     blanco sigue en hacia delante.
;   - Si el sensor de la derecha detecta línea negra gira hacia la derecha buscando el borde,
;     independientemente de como esté el sensor de la izquierda.
;   - Si el microbot tiene los dos sensores fuera de la línea, se le hace girar a la izquierda
;     hasta que vuelva a encontrarla.
;
; La señal de los sensores CNY70 se aplican a las entradas del microcontrolador a través de un
; inversor 40106 de manera tal, que para color:
;  - Color Blanco --> transistor saturado --> entrada al inversor "0" --> RAx = "1".
;    (No está encima de la línea negra, se ha salido de la pista)	
;  - Color Negro   --> transistor en corte --> entrada al inversor "1" --> RAx = "0".
;    (Está encima de la línea negra, está dentro de la pista)	
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

#DEFINE SensorDerecha	PORTA,0		; Sensor óptico Derecho.
#DEFINE SensorIzquierda	PORTA,1		; Sensor óptico Izquierdo.

; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0
Inicio
	bsf	STATUS,RP0		; Selecciona Banco 1 de registros.
	bsf	SensorDerecha		; Estas líneas se configuran como entrada.
	bsf	SensorIzquierda
	clrf	PORTB			; Las líneas del Puerto B se configuran como salidas.
	bcf	STATUS,RP0		; Selecciona Banco 0 de registros.
Principal	
	movlw 	b'00001110'		; Para girar a la derecha.
	btfss	SensorDerecha		; ¿Ha salido por la derecha?, ¿detecta blanco?
	goto	ActivaSalida		; No, el detector derecho está encima de la línea
					; negra, gira a la derecha.
	movlw	b'00000111'		; Para girar a la izquierda.
	btfss	SensorIzquierda		; ¿Ha salido también por la izquierda?
	movlw	b'00001111'		; No, está en el borde derecho. Sigue recto.
ActivaSalida
	movwf	PORTB
	goto	Principal

	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
