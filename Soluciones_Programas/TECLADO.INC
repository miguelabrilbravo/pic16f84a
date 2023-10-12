;**************************** Librería "TECLADO.INC" ***********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Librería de subrutinas para la gestión de un teclado organizado en una matriz de 4 x 4 y 
; conectado al Puerto B según la disposición siguiente y explicada en la figura 19-2 del libro:
;
;	 	 RB4 RB5 RB6 RB7
;		   ^    ^    ^    ^
;		|----|----|----|----|
;	RB0 -->	|  0 |  1 |  2 |  3 |
;		|----|----|----|----|
;	RB1 -->	|  4 |  5 |  6 |  7 |
;		|----|----|----|----|
;	RB2 -->	|  8 |  9 | 10 | 11 |
;		|----|----|----|----|
;	RB3 -->	| 12 | 13 | 14 | 15 |
;		|----|----|----|----|
;
; Los números que se han dibujado dentro de cada cuadrado son el orden de las teclas
; que no tienen por qué coincidir con lo serigrafiado sobre ellas. El paso del número de orden
; de la tecla al valor que hay serigrafiado sobre la misma se hace con una tabla de conversión.
;
; ZONA DE DATOS **********************************************************************
;
	CBLOCK
	Tecl_TeclaOrden			; Orden de la tecla a chequear.
	ENDC

Tecl_UltimaTecla	EQU	d'15'		; Valor de orden de la última tecla utilizada.

; Subrutina "Teclado_LeeHex" ************************************************************
;
; Cada tecla tiene asignado un número de orden que es contabilizado en la variable
; Tecl_TeclaOrden. Para convertir a su valor según el tipo de teclado en concreto se
; utiliza una tabla de conversión. 
; A continuación se expone la relación entre el número de orden de la tecla y los
; valores correspondientes para el teclado hexadecimal más utilizado.
;
;	    ORDEN DE TECLA:		TECLADO HEX. UTILIZADO:
;		 0   1   2   3 			1  2  3  F
;		 4   5   6   7 			4  5  6  E
;		 8   9  10  11 			7  8  9  D
;		12  13  14  15 			A  0  B  C
;
; Así, en este ejemplo, la tecla "7" ocupa el orden 8, la tecla "F" ocupa el orden 3 y la
; tecla "9" el orden 10.

; Si cambia el teclado también hay cambiar de tabla de conversión.
;
; Entrada:	En (W) el orden de la tecla pulsada.
; Salida:	En (W) el valor hexadecimal para este teclado concreto.
;
Teclado_LeeHex
	call	Teclado_LeeOrdenTecla	; Lee el Orden de la tecla pulsada.
	btfss	STATUS,C		; ¿Pulsa alguna tecla?, ¿C=1?
	goto	Tecl_FinLeeHex		; No, por tanto sale.
	call	Tecl_ConvierteOrdenEnHex	; Lo convierte en su valor real mediante tabla.
	bsf	STATUS,C		; Vuelve a posicionar el Carry, porque la
Tecl_FinLeeHex				; instrucción "addwf PCL,F" lo pone a "0".
	return
;
Tecl_ConvierteOrdenEnHex			; Según el teclado utilizado resulta:
	addwf	PCL,F
	DT	1h,2h,3h,0Fh		; Primera fila del teclado.
	DT	4h,5h,6h,0Eh		; Segunda fila del teclado
	DT	7h,8h,9h,0Dh		; Tercera fila del teclado.
	DT	0Ah,0h,0Bh,0Ch		; Cuarta fila del teclado.
Teclado_FinTablaHex
;
; Esta tabla se sitúa al principio de la librería con el propósito de que no supere la
; posición 0FFh de memoria ROM de programa. De todas formas, en caso que así fuera 
; visualizaría el siguiente mensaje de error en el proceso de ensamblado:
;
	IF (Teclado_FinTablaHex > 0xFF)
		ERROR	"Atención: La tabla ha superado el tamaño de la página de los"
		MESSG	"primeros 256 bytes de memoria ROM. NO funcionará correctamente."
	ENDIF
	
; Subrutina "Teclado_Inicializa" --------------------------------------------------------
;
; Esta subrutina configura las líneas del Puerto B según la conexión del teclado realizada
; y comprueba que no hay pulsada tecla alguna al principio.

Teclado_Inicializa
	bsf	STATUS,RP0		; Configura las líneas del puerto:
	movlw	b'11110000'		; <RB7:RB4> entradas, <RB3:RB0> salidas
	movwf	PORTB
	bcf	OPTION_REG,NOT_RBPU	; Habilita resistencia de Pull-Up del Puerto B.
	bcf	STATUS,RP0		; Acceso al banco 0.
;	call	Teclado_EsperaDejePulsar
;	return
;
; Subrutina "Teclado_EsperaDejePulsar" --------------------------------------------------
;
;Permanece en esta subrutina mientras siga pulsada la tecla.
;
Teclado_Comprobacion	EQU	b'11110000'

Teclado_EsperaDejePulsar:
	movlw	Teclado_Comprobacion	; Pone a cero las cuatro líneas de salida del 
	movwf	PORTB			; Puerto B.
Teclado_SigueEsperando
	call	Retardo_20ms		; Espera a que se estabilicen los niveles de tensión.
	movf	PORTB,W		; Lee el Puerto B.
	sublw	Teclado_Comprobacion	; Si es lo mismo que escribió es que ya no pulsa 
	btfss	STATUS,Z		; tecla alguna.
	goto	Teclado_SigueEsperando
	return
;
; Subrutina "Teclado_LeeOrdenTecla" -----------------------------------------------------
;
; Lee el teclado, obteniendo el orden de la tecla pulsada. 
;
; Salida:	En (W) el número de orden de la tecla pulsada. Además Carry se pone a "1" si
;		se pulsa una tecla ó a "0" si no se pulsa tecla alguna.
;
Teclado_LeeOrdenTecla:
	clrf	Tecl_TeclaOrden		; Todavía no ha empezado a chequear el teclado.
	movlw	b'11111110'		; Va a chequear primera fila.
Tecl_ChequeaFila				; (Ver esquema de conexión).
	movwf	PORTB			; Activa la fila correspondiente.
Tecl_Columna1
	btfss	PORTB,4			; Chequea la 1ª columna buscando un cero. 
	goto	Tecl_GuardaValor		; Sí, es cero y por tanto guarda su valor y sale.
	incf	Tecl_TeclaOrden,F		; Va a chequear la siguiente tecla.
Tecl_Columna2				; Repite proceso para las siguientes 
	btfss	PORTB,5			; columnas.
	goto	Tecl_GuardaValor
	incf	Tecl_TeclaOrden,F
Tecl_Columna3		
	btfss	PORTB,6
	goto	Tecl_GuardaValor
	incf	Tecl_TeclaOrden,F
Tecl_Columna4		
	btfss	PORTB,7
	goto	Tecl_GuardaValor
	incf	Tecl_TeclaOrden,F
;
; Comprueba si ha chequeado la última tecla, en cuyo caso sale. Para ello testea si
; el contenido del registro Tecl_TeclaOrden es igual al número de teclas del teclado.
;
Tecl_TerminaColumnas
	movlw	Tecl_UltimaTecla
	subwf	Tecl_TeclaOrden,W		; (W) = (Tecl_TeclaOrden)-Tecl_UltimaTecla.
	btfsc	STATUS,C		; ¿C=0?, ¿(W) negativo?, ¿(Tecl_TeclaOrden)<15?
	goto	Tecl_NoPulsada		; No, se ha llegado al final del chequeo.
	bsf	STATUS,C		; Sí. Va a chequear la siguiente fila.
	rlf	PORTB,W		; Apunta a la siguiente fila.
	goto	Tecl_ChequeaFila	
Tecl_NoPulsada
	bcf	STATUS,C		; Posiciona C=0, indicando que no ha pulsado
	goto	Tecl_FinTecladoLee	; tecla alguna y sale.
Tecl_GuardaValor
	movf	Tecl_TeclaOrden,W		; El orden de la tecla pulsada en (W) y sale.
	bsf	STATUS,C		; Como hay tecla tecla pulsada, pone C=1. 
Tecl_FinTecladoLee
	return
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
