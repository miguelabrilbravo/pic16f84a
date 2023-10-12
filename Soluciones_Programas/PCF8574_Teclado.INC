;*************************** Librería "PCF8574_Teclado.INC" ***************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Librería de subrutinas para la gestión de un teclado organizado en una matriz de 4 x 4 y
; conectado a un bus I2C a través de un PCF8574 tal como se muestra en el esquema.
; El teclado está conectado al puerto del expansor PCF8574, siendo su disposición:
;
;	 	  P4  P5  P6  P7
;		   ^    ^    ^    ^
;		|     |     |     |     |
;		|----|----|----|----|
;	P0 -->	|  0 |  1 |  2 |  3 |
;		|----|----|----|----|
;	P1 -->	|  4 |  5 |  6 |  7 |
;		|----|----|----|----|
;	P2 -->	|  8 |  9 | 10| 11|
;		|----|----|----|----|
;	P3 -->	| 12| 13| 14| 15|
;		|----|----|----|----|
;
; El número que se indica dentro de cada cuadrado es el número de orden de la tecla que no
; tiene por qué coincidir con lo serigrafiado sobre ella. El número de orden de la tecla
; se convierte al valor serigrafiado mediante una tabla de conversión.
;
; ZONA DE DATOS **********************************************************************
;
	CBLOCK
	Tecl_TeclaOrden			; Orden de la tecla a chequear.
	ENDC

PCF8574_DireccionLectura	EQU	b'01000001'
PCF8574_DireccionEscritura	EQU	b'01000000'

Tecl_NumeroTeclas	EQU	d'16'		; Número de pulsadores del teclado.

#DEFINE  PCF8574_INT	PORTB,0		; Línea donde se conecta la línea de 
					; interrupción del expansor de bus I2C.
; Subrutina "Teclado_LeeHex" ------------------------------------------------------------
;
; A cada tecla se le asigna un número de orden que se va contabilizando en la variable
; Tecl_TeclaOrden. Para convertir a su valor cada tipo de teclado se utiliza una tabla de
; conversión. 
;
; A continuación se expone la relación entre el número de orden de la tecla y los valores
; correspondientes para el teclado hexadecimal más utilizado.
;
;	        ORDEN DE TECLA:		   TECLADO HEX. UTILIZADO:
;		 0   1   2   3 			1  2  3  F
;		 4   5   6   7 			4  5  6  E
;		 8   9  10  11 			7  8  9  D
;		12  13  14  15 			A  0  B  C
;
; En este ejemplo, la tecla "7" ocupa el orden 8, la tecla "F" ocupa el orden 3 y la tecla
; "9" el orden 10.

; En teclados con otra serigrafía basta con cambiar de tabla de conversión.
;
; Entrada:	En (W) el orden de la tecla pulsada.
; Salida:	En (W) el valor hexadecimal para este teclado concreto.
;
Teclado_LeeHex
	call	Teclado_LeeOrdenTecla	; Lee el Orden de la tecla pulsada
	btfss	STATUS,C		; ¿Pulsa alguna tecla?, ¿C=1?
	goto	Tecl_FinLeeHex		; No, por tanto sale.
	call	Tecl_ConvierteOrdenEnHex	; Lo convierte en su valor real mediante tabla.
	bsf	STATUS,C		; Vuelve a posicionar el Carry porque la
Tecl_FinLeeHex				; instrucción "addwf PCL,F" lo pone a "0".
	return
;
Tecl_ConvierteOrdenEnHex:			; Según el teclado utilizado resulta:
	addwf	PCL,F
	DT	1h,2h,3h,0Fh		; Primera fila del teclado.
	DT	4h,5h,6h,0Eh		; Segunda fila del teclado
	DT	7h,8h,9h,0Dh		; Tercera fila del teclado.
	DT	0Ah,0h,0Bh,0Ch		; Cuarta fila del teclado.
Teclado_FinTablaHex
;
; Esta tabla se sitúa al principio de la librería con el propósito de que no supere la
; posición 0FF de memoria ROM de programa. De todas formas, en caso de que así fuera se
; visualizaría el siguiente mensaje de error en el proceso de ensamblado:
;
	IF (Teclado_FinTablaHex-1 > 0xFF)
		ERROR	"¡Cuidado!. La tabla ha superado el tamaño de la página de los"
		MESSG	"primeros 256 bytes de memoria ROM. NO funcionará correctamente."
	ENDIF

; Subrutina "Teclado_Inicializa" --------------------------------------------------------
;
Teclado_Inicializa
	bsf	STATUS,RP0		; Acceso al Banco 1.
	bsf	PCF8574_INT 		; La línea RB0/INT se configura como entrada.
	bcf	OPTION_REG,NOT_RBPU	; Habilita las resistencias de Pull-Up del Puerto B.
	bcf	OPTION_REG,INTEDG	; Interrupción INT activa por flanco de bajada.
	bcf	STATUS,RP0		; Acceso al Banco 0.
;	call	Teclado_EsperaDejePulsar
;	return

; Subrutina "Teclado_EsperaDejePulsar" --------------------------------------------------
;
; Permanece en esta subrutina mientras siga pulsada la tecla y deja en el puerto una
; combinación que permite la interrupción de la próxima pulsación.
;
Teclado_Comprobacion	EQU	b'11110000'

Teclado_EsperaDejePulsar:
	movlw	Teclado_Comprobacion	; Pone a cero las cuatro líneas de salida del puerto
	call	PCF8574_Escribe		; para que se produzca una interrupción cuando se
Teclado_SigueEsperando			; presione alguna tecla.
	call	Retardo_20ms
	call	PCF8574_Lee		; Lee el puerto.
	sublw	Teclado_Comprobacion	; Si es lo mismo que lanzó es que ya no pulsa 
	btfss	STATUS,Z		; tecla alguna.
	goto	Teclado_SigueEsperando
	return
;
; Subrutina "Teclado_LeeOrdenTecla" -----------------------------------------------------
;
; Lee el teclado, obteniendo el orden de la tecla pulsada. 
;
; Salida:	En (W) el número de orden de la tecla pulsada. 
;	Además el flag Carry indica si se ha pulsado o no una tecla:
;	- Si se pulsa una tecla, (Carry)=1.
;	- Si no se pulsa tecla alguna, (Carry)=0.

	CBLOCK
	Tecl_I2C_DatoLeido		; Guarda el dato leído.
	Tecl_I2C_FilaChequear		; Fila que va a ser chequeada.
	ENDC

Teclado_LeeOrdenTecla:
	clrf	Tecl_TeclaOrden		; Todavía no ha empezado a chequear el teclado.
	movlw	b'11111110'		; Va a chequear primera fila.
	movwf	Tecl_I2C_FilaChequear
Tecl_ChequeaFila				; (Ver esquema de conexión).
	call	PCF8574_Escribe		; Activa la fila correspondiente.
	call	PCF8574_Lee		; Lee el puerto.
	movwf	Tecl_I2C_DatoLeido	; Guarda la lectura efectuada.
Tecl_Columna1
	btfss	Tecl_I2C_DatoLeido,4	; Chequea 1ª columna buscando un cero. 
	goto	Tecl_GuardaValor		; Sí, es cero. Salta a guardar su valor y sale.
	incf	Tecl_TeclaOrden,F		; No es cero. Va a chequear la siguiente tecla.
Tecl_Columna2				; Repite proceso para las siguientes 
	btfss	Tecl_I2C_DatoLeido,5	; columnas.
	goto	Tecl_GuardaValor
	incf	Tecl_TeclaOrden,F
Tecl_Columna3
	btfss	Tecl_I2C_DatoLeido,6
	goto	Tecl_GuardaValor
	incf	Tecl_TeclaOrden,F
Tecl_Columna4
	btfss	Tecl_I2C_DatoLeido,7
	goto	Tecl_GuardaValor
	incf	Tecl_TeclaOrden,F
;
; Comprueba si ha chequeado la última tecla en cuyo caso sale. Para ello comprueba si
; el contenido del registro Tecl_TeclaOrden es igual al número de teclas del teclado.
;
Tecl_TerminaColumnas
	movlw	Tecl_NumeroTeclas
	subwf	Tecl_TeclaOrden,W
	btfsc	STATUS,Z
	goto	Tecl_NoPulsada		; Sí, se ha llegado al final del chequeo.
	bsf	STATUS,C		; No. Va a chequear la siguiente fila.
	rlf	Tecl_I2C_FilaChequear,F	; Apunta a la siguiente fila.
	movf	Tecl_I2C_FilaChequear,W
	goto	Tecl_ChequeaFila
Tecl_NoPulsada
	bcf	STATUS,C		; Posiciona C=0, indicando que no ha pulsado
	goto	Tecl_FinTecladoLee	; tecla alguna y sale.
Tecl_GuardaValor
	movf	Tecl_TeclaOrden,W		; El orden de la tecla pulsada en (W).
	bsf	STATUS,C		; Como hay tecla pulsada pone C=1. 
Tecl_FinTecladoLee
	return
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
