;************************************ RS232_07.asm **************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; En el monitor del ordenador se visualizan mensajes grabados en la memoria de programa del
; microcontrolador. El cambio de mensaje se ejecuta cada vez que se pulse la tecla Enter.

; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	ENDC

RetornoCarro	EQU	.13		; Código de tecla "Enter" o "Retorno de Carro".
CambioLinea	EQU	.10		; Código para el cambio de línea.

; ZONA DE CÓDIGOS ********************************************************************

	ORG	0
	goto	Inicio

Mensajes				; Los mensajes se ponen al principio para no
	addwf	PCL,F			; superar la posición 0xFF de memoria de programa.
Mensaje0
	DT "   ¿Quieres trabajar en dos años?."
	DT RetornoCarro, CambioLinea
	DT "¿Quieres aprender hacer estos mensajes?",0x00
Mensaje1
	DT "  ¡Pues estudia CICLOS FORMATIVOS!.",0x00
Mensaje2
	DT "En el I.E.S. ISAAC PERAL de Torrejon de Ardoz"
	DT RetornoCarro, CambioLinea
	DT "  se puede estudiar el Ciclo Formativo "
	DT RetornoCarro, CambioLinea
	DT "  DESARROLLO de PRODUCTOS ELECTRONICOS.", 0x00
FinMensajes
	IF (FinMensajes > 0xFF)
		ERROR	"ATENCION: La tabla ha superado el tamaño de la página de los"
		MESSG	"primeros 255 bytes de memoria ROM. NO funcionará correctamente."
	ENDIF

Inicio
	call	RS232_Inicializa
	call	RS232_LineasBlanco	; Visualiza unas cuantas líneas en blanco.
Principal
	movlw	Mensaje0		; Carga la primera posición del mensaje.
	call	Visualiza_y_Espera	; Lo visualiza en el ordenador y espera
	movlw	Mensaje1		; pulse "Enter".
	call	Visualiza_y_Espera
	movlw	Mensaje2	
	call	Visualiza_y_Espera
	goto	Principal
	
Visualiza_y_Espera
	call	RS232_Mensaje		; Lo visualiza en el ordenador.
	call	RS232_LineasBlanco	; Visualiza unas líneas en blanco.
EsperaPulseEnter
	call	RS232_LeeDato		; Lee el teclado del ordenador.
	xorlw	RetornoCarro		; Si no ha pulsado el "Enter" vuelve a 
	btfss	STATUS,Z		; leer de nuevo
	goto	EsperaPulseEnter
	call	RS232_LineasBlanco	; Líneas en blanco al principio del próximo mensaje.
	return

	INCLUDE  <RS232MEN.INC>
	INCLUDE  <RS232.INC>
	INCLUDE  <RETARDOS.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================

