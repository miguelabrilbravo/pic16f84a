;************************************ RS232_11.asm **************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; SISTEMA DE GOBIERNO DESDE ORDENADOR: Desde el teclado de un ordenador se desea comandar
; el movimiento de una estructura m�vil, seg�n la siguiente tabla:
;
;	TECLA (Por ejemplo)	MOVIMIENTO
;	-------------------		----------
;		t		Adelante
;		b		Atr�s
;		a		Izquierda
;		l		Derecha
;	     Espacio		Parada
;
; La pulsaci�n de cualquiera de estas teclas activa el estado de las salidas correspondiente
; RB3 (Adelante), RB2 (Atr�s), RB1 (Izquierda), RB0 (Derecha) y apaga el resto.
;
; El movimiento que se est� realizando aparece reflejado en un mensaje en el visualizador LCD
; del sistema y tambi�n en la pantalla del ordenador.
;
; El programa debe permitir modificar facilmente en posteriores revisiones en el hardware de
; la salida. Es decir, para activar las salidas conviene utilizar el direccionamiento por bit
; en lugar de por byte (utilizar instrucciones "bsf" y "bcf", en lugar de "mov..").
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16f84A.INC>

	CBLOCK   0x0C		
	TeclaPulsada			; Va a guardar el contenido de la tecla pulsada.
	MensajeApuntado			; Va a guarda la direcci�n del mensaje apuntado.
	ENDC

#DEFINE  SalidaAdelante	PORTB,3		; Define d�nde se sit�an las salidas.
#DEFINE  SalidaAtras	PORTB,2
#DEFINE  SalidaIzquierda	PORTB,1
#DEFINE  SalidaDerecha	PORTB,0

TeclaAdelante	EQU	't'		; C�digo de las teclas utilizadas.
TeclaAtras	EQU	'b'
TeclaIzquierda	EQU	'a'
TeclaDerecha	EQU	'l'
TeclaParada	EQU	' '		; C�digo de la tecla espaciadora, (hay un espacio,
					; tened cuidado al teclear el programa).
; ZONA DE C�DIGOS ********************************************************************

	ORG	0
Inicio
	call	LCD_Inicializa
	call	RS232_Inicializa
	bsf	STATUS,RP0		; Configura como salidas las 4 l�neas del
	bcf	SalidaAdelante		; del Puerto B respetando la configuraci�n del
	bcf	SalidaAtras		; resto de las l�neas.
	bcf	SalidaIzquierda
	bcf	SalidaDerecha
	bcf	STATUS,RP0
	call	Parado			; En principio todas las salidas deben estar 
Principal					; apagadas.
	call	RS232_LeeDato		; Espera a recibir un car�cter.
	call	TesteaTeclado
	goto	Principal

; "Mensajes" ----------------------------------------------------------------------------
;
Mensajes
	addwf	PCL,F
MensajeParado
	DT "Sistema PARADO", 0x00
MensajeAdelante
	DT "Marcha ADELANTE", 0x00
MensajeAtras
	DT "Marcha ATRAS", 0x00
MensajeIzquierda
	DT "Hacia IZQUIERDA", 0x00
MensajeDerecha
	DT "Hacia DERECHA", 0x00

; Subrutina "TesteaTeclado" -------------------------------------------------------------
;
; Testea el teclado y act�a en consecuencia.

TesteaTeclado
	movwf	TeclaPulsada		; Guarda el contenido de la tecla pulsada.
	xorlw	TeclaAdelante		; �Es la tecla del movimiento hacia adelante?
	btfsc	STATUS,Z
	goto	Adelante			; S�, se desea movimiento hacia adelante.
;
	movf	TeclaPulsada,W		; Recupera el contenido de la tecla pulsada.
	xorlw	TeclaAtras		; �Es la tecla del movimiento hacia atr�s?
	btfsc	STATUS,Z
	goto	Atras			; S�, se desea movimiento hacia atr�s.
;
	movf	TeclaPulsada,W		; Recupera el contenido de la tecla pulsada.
	xorlw	TeclaIzquierda		; �Es la tecla del movimiento hacia la izquierda?
	btfsc	STATUS,Z
	goto	Izquierda			; S�, se desea movimiento hacia la izquierda.
;
	movf	TeclaPulsada,W		; Recupera el contenido de la tecla pulsada.
	xorlw	TeclaDerecha		; �Es tecla del movimiento hacia la derecha?
	btfsc	STATUS,Z
	goto	Derecha			; S�, se desea movimiento hacia la derecha.
;
	movf	TeclaPulsada,W		; Recupera el contenido de la tecla pulsada.
	xorlw	TeclaParada		; �Es la tecla de parada?.
	btfss	STATUS,Z
	goto	Fin			; No es ninguna tecla de movimiento. Sale.
Parado
	bcf	SalidaAdelante		; Como se ha pulsado la tecla de parada se
	bcf	SalidaAtras		; desactivan todas las salidas.
	bcf	SalidaIzquierda
	bcf	SalidaDerecha
	movlw	MensajeParado
	goto	Visualiza
Adelante
	bcf	SalidaAtras
	bsf	SalidaAdelante
	bcf	SalidaIzquierda
	bcf	SalidaDerecha
	movlw	MensajeAdelante
	goto	Visualiza
Atras
	bcf	SalidaAdelante
	bsf	SalidaAtras
	bcf	SalidaIzquierda
	bcf	SalidaDerecha
	movlw	MensajeAtras
	goto	Visualiza
Izquierda
	bcf	SalidaAdelante
	bcf	SalidaAtras
	bsf	SalidaIzquierda
	bcf	SalidaDerecha
	movlw	MensajeIzquierda
	goto	Visualiza
Derecha
	bcf	SalidaAdelante
	bcf	SalidaAtras
	bcf	SalidaIzquierda
	bsf	SalidaDerecha
	movlw	MensajeDerecha

; Seg�n el estado de las salidas visualiza el estado del sistema en el visualizador LCD y en
; el monitor del ordenador.

Visualiza
	movwf	MensajeApuntado		; Guarda la posici�n del mensaje.
	call	LCD_Borra		; Borra la pantalla del modulo LCD.
	movf	MensajeApuntado,W	; Visualiza el mensaje en la pantalla
	call	LCD_Mensaje		; del visualizador LCD.
	call	RS232_LineasBlanco	; Borra la pantalla del ordenador.
	movf	MensajeApuntado,W
	call	RS232_Mensaje		; Lo visualiza en el HyperTerminal.
	call	RS232_LineasBlanco
Fin	return

	INCLUDE  <RS232.INC>
	INCLUDE  <RS232MEN.INC>
	INCLUDE  <LCD_4BIT.INC>
	INCLUDE  <LCD_MENS.INC>
	INCLUDE  <RETARDOS.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
