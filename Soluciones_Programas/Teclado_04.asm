;************************************** Teclado_04.asm **********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Supone un teclado con los 16 primeros caracteres del alfabeto español. Por tanto hay
; que cambiar la tabla respecto de los ejercicios anteriores. Lo que se va escribiendo por 
; el teclado aparece en pantalla como si fuera un teclado alfabético.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	ENDC

; ZONA DE CÓDIGOS ********************************************************************

	ORG	0
	goto 	Inicio
	ORG	4
	goto	ServicioInterrupcion
Inicio
	call	LCD_Inicializa
	call	Teclado_Inicializa	; Configura líneas del teclado.
	movlw	b'10001000'		; Habilita la interrupción RBI y la general.
	movwf	INTCON
Principal
	sleep
	goto	Principal

; Subrutina "ServicioInterrupcion" ------------------------------------------------------
;
; La subrutina de atención a la interrupción obtiene el valor ASCII de la tecla pulsada.
; A continuación se expone la relación entre el número de orden de la tecla y los valores
; correspondientes para el teclado supuesto.
;
;	     ORDEN DE TECLA:		    TECLADO UTILIZADO:
;		 0   1   2   3 			A  B  C  D
;		 4   5   6   7 			E  F  G  H
;		 8   9  10  11 			I  J  K  L
;		12  13  14  15 			M  N  O  P
;
ServicioInterrupcion
	call	Teclado_LeeOrdenTecla		; Lee el Orden de la tecla pulsada
	call	Tecl_ConvierteOrdenEnASCII	; Lo convierte en su valor ASCII mediante
	call	LCD_Caracter			; una tabla, y lo visualiza.
	call	Teclado_EsperaDejePulsar	; Para que no se repita el mismo caracter.
	bcf	INTCON,RBIF			; Limpia flag.
	retfie

Tecl_ConvierteOrdenEnASCII:			; Según el teclado utilizado resulta:
	addwf	PCL,F
	DT	"ABCD"				; Primera fila del teclado.
	DT	"EFGH"				; Segunda fila del teclado.
	DT	"IJKL"				; Tercera fila del teclado.
	DT	"MNÑO"				; Cuarta fila del teclado.

	INCLUDE  <TECLADO.INC>
	INCLUDE  <LCD_4BIT.INC>
	INCLUDE  <RETARDOS.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
