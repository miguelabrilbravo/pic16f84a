;************************************ MotorPAP_04.asm **********************************
; 
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Programa de control de velocidad de un motor PAP. La velocidad del motor estar� gobernada
; por el valor de las cuatro l�neas bajas del Puerto A. El sentido de giro de motor se decide
; en funci�n del valor de la l�nea RA4.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	Velocidad
	ENDC

#DEFINE  EntradaSentido	PORTA,4		; Interruptor de sentido de giro.

; ZONA DE C�DIGOS ********************************************************************

	ORG 	0
Inicio
	bsf	STATUS,RP0
	movlw	b'00011111'		; El Puerto A se configura como entrada.
	movwf	PORTA
	clrf	PORTB			; Las l�neas del Puerto B configuradas como salidas.
	bcf	STATUS,RP0
Principal
	movf	PORTA,W		; Lee el puerto de entrada
	andlw	b'00001111'		; Se queda con los cuatro bits bajos.
	btfsc	STATUS,Z
	goto	ParaMotor		; Si es cero se mantiene parado.
	call	SeleccionaVelocidad	; Pasa a seleccionar el factor por el que se va
	movwf	Velocidad			; a multiplicar el retardo patr�n.
	btfsc	EntradaSentido		; Comprueba el sentido de giro deseado.
	goto	A_Izquierda
	call	GiroDerecha
	goto	Fin
A_Izquierda
	call	GiroIzquierda
	goto	Fin
ParaMotor
	clrf	PORTB			; Para el motor, poniendo a cero la l�nea de
Fin	goto	Principal		; habilitaci�n.

; Subrutina "SeleccionaVelocidad" -------------------------------------------------------

; Alterando los valores de esta	 tabla se pueden conseguir diferentes retardos.

SeleccionaVelocidad
	addwf	PCL,F
	DT	0, d'75', d'70', d'65', d'60', d'55', d'50', d'45', d'40'
	DT	d'35', d'30', d'25', d'20', d'15', d'10', d'5'

; Subrutina "GiroIzquierda" -------------------------------------------------------------

GiroIzquierda
	movlw	b'00110101'		; Primer paso.
	call	ActivaSalida		; Lo env�a a la salida donde est� conectado el motor PAP.
	movlw	b'00110110'		; Segundo paso.
	call	ActivaSalida
	movlw	b'00111010'		; Tercer paso.
	call	ActivaSalida
	movlw	b'00111001'		; Cuarto y �ltimo paso
	call	ActivaSalida
	return

; Subrutina "GiroDerecha" ---------------------------------------------------------------

GiroDerecha
	movlw	b'00111001'		; Primer paso.
	call	ActivaSalida
	movlw	b'00111010' 		; Segundo paso.
	call	ActivaSalida
	movlw	b'00110110'		; Tercer paso.
	call	ActivaSalida
	movlw	b'00110101'		; �ltimo paso.
	call	ActivaSalida
	return
;
; Subrutina "ActivaSalida" --------------------------------------------------------------

	CBLOCK
	Contador
	ENDC

ActivaSalida
	movwf	PORTB
	movf	Velocidad,W		; Y ahora el retardo en funci�n del valor de
	movwf	Contador			; de la variable Velocidad.
Retardo
	call	Retardo_1ms
	decfsz	Contador,F
	goto	Retardo
	return

	INCLUDE  <RETARDOS.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
