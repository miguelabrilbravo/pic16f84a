;************************************ RS232_10.asm **************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; SISTEMA DE MONITORIZACI�N: Se trata de leer el estado de las entradas conectadas a las
; l�neas <RB7:RB4> del Puerto B y se env�a por el puerto RS232 a un terminal para monitorizar
; el estado de los mismos.
; Se utilizar� las interrupciones por cambio de nivel en una l�nea del Puerto B, por ello
; las entradas deben conectarse a la parte alta del Puerto B.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK	0x0C
	ENDC

RetornoCarro	EQU	.13		; C�digo de tecla "Enter" o "Retorno de Carro".
CambioLinea	EQU	.10		; C�digo para el cambio de l�nea.

#DEFINE  Entrada0  PORTB,4		; Define d�nde se sit�an las entradas.
#DEFINE  Entrada1  PORTB,5
#DEFINE  Entrada2  PORTB,6
#DEFINE  Entrada3  PORTB,7

; ZONA DE CODIGOS ********************************************************************

	ORG	0
	goto	Inicio
	ORG	4			; Aqu� se sit�a el vector de interrupci�n para 
	goto	LeeEntradasVisualiza	; atender las subrutinas de interrupci�n.

Mensajes					; Los mensajes no deben sobrepasar las 256 
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
	bsf	STATUS,RP0		; Configura como entrada las 4 l�neas correspondientes
	bsf	Entrada0			; del Puerto B respetando la configuraci�n del
	bsf	Entrada1			; resto de las l�neas.
	bsf	Entrada2
	bsf	Entrada3
	bcf	OPTION_REG,NOT_RBPU	; Activa las resistencias de Pull-Up del Puerto B.	
	bcf	STATUS,RP0
	call	RS232_LineasBlanco	; Visualiza unas cuantas l�neas en blanco
	call	RS232_LineasBlanco	; para limpiar la pantalla.
	call	LeeEntradasVisualiza	; Lee las entradas y visualiza por primera vez.
	movlw	b'10001000'		; Habilita la interrupci�n RBI y la general.
	movwf	INTCON
Principal
	sleep				; Espera en modo de bajo consumo que se
	goto	Principal			; modifique una entrada.

; Subrutina de Servicio a la Interrupcion" ----------------------------------------------
;
; Lee el estado de las entradas y las monitoriza en la pantalla del HyperTerminal.

LeeEntradasVisualiza
	call	RS232_LineasBlanco	
	movlw	MensajeEntradas		; Nombre de las entradas.
	call	RS232_Mensaje		; Lo visualiza en el ordenador.
LeeEntrada3
	btfss	Entrada3			; �Entrada = 1?, �Entrada = Abierta?
	goto 	Entrada3Cerrado 		; No, est� cerrada.
	call	VisualizaAbierto
	goto	LeeEntrada2
Entrada3Cerrado
	call	VisualizaCerrado
LeeEntrada2
	btfss	Entrada2			; Se repite el procedimiento para las
	goto 	Entrada2Cerrado 		; dem�s entradas.
	call	VisualizaAbierto
	goto	LeeEntrada1
Entrada2Cerrado
	call	VisualizaCerrado
LeeEntrada1
	btfss	Entrada1	
	goto 	Entrada1Cerrado 
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
	bcf	INTCON,RBIF		; Limpia el flag de reconocimiento de la
	retfie				; interrupci�n.
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
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
