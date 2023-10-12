;************************************ RS232_09.asm **************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; SISTEMA DE MONITORIZACIÓN: Se trata de leer el estado de las entradas conectadas a las
; líneas <RB7:RB4> del Puerto B y se envía por el puerto RS232 a un terminal para monitorizar
; el estado de los mismos. El estado de las entradas se mostrará cada 5 segundos.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK	0x0C
	ENDC

RetornoCarro	EQU	.13		; Código de tecla "Enter" o "Retorno de Carro".
CambioLinea	EQU	.10		; Código para el cambio de línea.

#DEFINE  Entrada0	PORTB,4		; Define dónde se sitúan las entradas.
#DEFINE  Entrada1	PORTB,5
#DEFINE  Entrada2	PORTB,6
#DEFINE  Entrada3	PORTB,7

; ZONA DE CODIGOS ********************************************************************

	ORG	0
	goto	Inicio

Mensajes				; Los mensajes no deben sobrepasar las 256 
	addwf	PCL,F			; primeras posiciones de memoria de programa.
MensajeEntradas
	DT RetornoCarro, CambioLinea
	DT "Entrada 3    Entrada 2    Entrada 1    Entrada 0"
	DT RetornoCarro, CambioLinea
	DT "---------    ---------    ---------    ---------"
	DT RetornoCarro, CambioLinea, 0x00
MensajeAbierto
	DT " Abierto     ", 0x00
MensajeCerrado
	DT " Cerrado     ", 0x00

Inicio
	call	RS232_Inicializa
	bsf	STATUS,RP0		; Configura como entrada las 4 líneas correspondientes
	bsf	Entrada0		; del Puerto B respetando la configuración del
	bsf	Entrada1		; resto de las líneas.
	bsf	Entrada2
	bsf	Entrada3
	bcf	OPTION_REG,NOT_RBPU	; Activa las resistencias de Pull_Up del Puerto B.	
	bcf	STATUS,RP0
	call	RS232_LineasBlanco	; Visualiza unas cuantas líneas en blanco.
Principal
	call	RS232_LineasBlanco	; Para limpiar la pantalla.
	call	LeeEntradasVisualiza	; Lee las entradas y las visualiza.
	call	Retardo_5s		; Cada cierto tiempo.
	goto	Principal

; Subrutina "LeeEntradasVisualiza" ------------------------------------------------------
;
; Lee el estado de las entradas y las monitoriza en la pantalla del HyperTerminal.

LeeEntradasVisualiza
	call	RS232_LineasBlanco	; Visualiza unas cuantas líneas en blanco.
	movlw	MensajeEntradas		; Nombre de las entradas.
	call	RS232_Mensaje		; Lo visualiza en el HyperTerminal.
LeeEntrada3
	btfss	Entrada3		; ¿Entrada = 1?, ¿Entrada = Abierta?
	goto 	Entrada3Cerrado 	; No, está cerrada.
	call	VisualizaAbierto
	goto	LeeEntrada2
Entrada3Cerrado
	call	VisualizaCerrado
LeeEntrada2
	btfss	Entrada2		; Se repite el procedimiento para las
	goto 	Entrada2Cerrado 	; demás entradas.
	call	VisualizaAbierto
	goto	LeeEntrada1
Entrada2Cerrado
	call	VisualizaCerrado
LeeEntrada1
	btfss	Entrada1
	goto	Entrada1Cerrado
	call	VisualizaAbierto
	goto	LeeEntrada0
Entrada1Cerrado
	call	VisualizaCerrado
LeeEntrada0
	btfss	Entrada0
	goto 	Entrada0Cerrado
	call	VisualizaAbierto
	goto	FinVisualiza
Entrada0Cerrado
	call	VisualizaCerrado
FinVisualiza
	call	RS232_LineasBlanco
	return
;
VisualizaAbierto
	movlw	MensajeAbierto		; Visualiza el mensaje "Abierto"
	call	RS232_Mensaje		; en el HyperTerminal.
	return
VisualizaCerrado
	movlw	MensajeCerrado		; Visualiza el mensaje "Cerrado"
	call	RS232_Mensaje		; en el HyperTerminal.
	return

	INCLUDE  <RS232.INC>
	INCLUDE  <RS232MEN.INC>
	INCLUDE  <RETARDOS.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
