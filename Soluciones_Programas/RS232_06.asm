;************************************ RS232_06.asm **************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Este programa env�a varios mensajes grabados en la memoria de programa del
; microcontrolador al ordenador. Cada mensaje permanecer� en pantalla durante unos
; segundos hasta que sea sustituido por el siguiente.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	ENDC

RetornoCarro	EQU	.13		; C�digo de tecla "Enter" o "Retorno de Carro".
CambioLinea	EQU	.10		; C�digo para el cambio de l�nea.

; ZONA DE C�DIGOS ********************************************************************

	ORG	0
	goto	Inicio

Mensajes				; Los mensajes se ponen al principio para no
	addwf	PCL,F			; superar la posici�n 0xFF de memoria de programa.
Mensaje0
	DT "   �Quieres trabajar en dos a�os?."
	DT RetornoCarro, CambioLinea
	DT "�Quieres aprender hacer estos mensajes?",0x00
Mensaje1
	DT "  �Pues estudia CICLOS FORMATIVOS!.",0x00
Mensaje2
	DT "En el I.E.S. ISAAC PERAL de Torrejon de Ardoz"
	DT RetornoCarro, CambioLinea
	DT "  se puede estudiar el Ciclo Formativo "
	DT RetornoCarro, CambioLinea
	DT "  DESARROLLO de PRODUCTOS ELECTRONICOS.", 0x00
FinMensajes
	IF (FinMensajes > 0xFF)
		ERROR	"ATENCION: La tabla ha superado el tama�o de la p�gina de los"
		MESSG	"primeros 255 bytes de memoria ROM. NO funcionar� correctamente."
	ENDIF

Inicio
	call	RS232_Inicializa
Principal
	movlw	Mensaje0		; Carga la primera posici�n del mensaje.
	call	VisualizaMensaje	; Lo visualiza en el ordenador.
	movlw	Mensaje1		; El mismo procedimiento para las siguientes.
	call	VisualizaMensaje
	movlw	Mensaje2
	call	VisualizaMensaje
	goto	Principal

VisualizaMensaje	
	call	RS232_Mensaje		; Lo visualiza en el ordenador.
	call	RS232_LineasBlanco	; Visualiza unas l�neas en blanco despu�s del
	call	Retardo_2s		; mensaje durante este tiempo.
	call	Retardo_1s
	call	RS232_LineasBlanco	; L�neas en blanco al principio del pr�ximo mensaje.
	return

	INCLUDE  <RS232MEN.INC>
	INCLUDE  <RS232.INC>
	INCLUDE  <LCD_4BIT.INC>
	INCLUDE  <RETARDOS.INC>
	END

;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
