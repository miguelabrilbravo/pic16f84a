;************************************* Robot_Baliza_01.asm *******************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Programa de control para Microbot TRASTO el cual detecta una baliza que genera
; una señal infrarroja modulada a 38 kHz.
;
; Los sensores ópticos SFH5110 están situados en la parte frontal del microbot:
; El sensor de la derecha está conectado a RA2 y el sensor de la izquierda a RA3. 
;
; Cuando el sensor SFH5110 detecta luz infrarroja modulada, proporciona un nivel bajo en su
; línea de salida.
;
; El programa adopta la estrategia siguiente:
;     - Si no se detecta la baliza por ningún sensor el microbot gira siempre a la derecha.
;     -	Si los dos sensores detectan portadora el microbot avanza hacia adelante.
;     -	Si se detecta portadora en el sensor de la izquierda y no en el de la derecha el
;	microbot gira a la izquierda hasta que los dos sensores detecten la baliza.	
;     -	Si se detecta portadora en el sensor de la derecha y no en el de la izquierda el
;	microbot gira a la derecha hasta que los dos sensores detecten la baliza.	
;
; ZONA DE DATOS *********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	P=16F84A
	INCLUDE <P16F84A.INC>

#DEFINE SensorDerecha	PORTA,2		; Sensor Derecho.
#DEFINE SensorIzquierda	PORTA,3		; Sensor Izquierdo.

; ZONA DE CÓDIGOS *********************************************************************

	ORG 	0
Inicio
	bsf	STATUS,RP0		; Selecciona Banco 1 de registros.
	bsf	SensorDerecha		; Estas líneas se configuran como entrada.
	bsf	SensorIzquierda
	clrf	PORTB			; Las líneas del Puerto B se configuran como salidas.
	bcf	STATUS,RP0		; Selecciona Banco 0 de registros.
Principal	
	btfsc	SensorDerecha		; ¿Ha detectado señal por la derecha?	
	goto	Ver_Izquierda		; No recibe por la derecha.
	btfsc	SensorIzquierda		; Sí, ¿también señal por la izquierda?
	goto	GiroDerecha		; No, solo señal por la derecha, gira a derecha.
	movlw	b'00001111'		; Sí, recibe por los dos sensores. Sigue recto.
	goto	ActivaSalida
Ver_Izquierda
	btfsc	SensorIzquierda		; Por la derecha no recibe. ¿Y por la izquierda?
	goto	GiroDerecha		; Tampoco, ni por la derecha ni por la izquierda.
GiroIzquierda
	movlw	b'00000111'		; Gira a la izquierda.
	goto	ActivaSalida
GiroDerecha
	movlw 	b'00001110'		; Gira a la derecha.
ActivaSalida
	movwf	PORTB
	goto	Principal

	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
