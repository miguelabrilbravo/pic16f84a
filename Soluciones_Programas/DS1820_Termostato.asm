;********************************* DS1820_Termostato.asm ******************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Programa de control para un term�metro y termostato digital. Utiliza el sensor de temperatura
; DS1820 que transmite la informaci�n v�a serie a trav�s de un bus de una sola l�nea seg�n un
; protocolo del fabricante de semiconductores Dallas Semiconductors.
;
; El ajuste de la temperatura a la que conmuta el termostato se logra mediante dos pulsadores:
; "MODO" e "INCREMENTAR", que se conectan a pines del Puerto B y cuyo funcionamiento se basa en
; interrupci�n por cambio en la l�nea del Puerto B.
;
; Se maneja de la siguiente forma:
;     -	En estado de reposo funciona s�lo como term�metro. Aparece la temperatura en pantalla
;	del m�dulo LCD. La salida del termostato est� apagada.
;     -	Pulsa "MODO" y se ajusta la temperatura deseada mediante el pulsador "INCREMENTAR".
;     -	Vuelve a pulsar "MODO", se activa el termostato. Si la temperatura medida es menor que
;	la deseada enciende la carga, que puede ser un calefactor. Si la temperatura medida es
;	mayor que la deseada, apaga la carga.
;     -	Si se vuelve a pulsar "MODO", apaga la carga y pasa a funcionar s�lo como term�metro.
;
; As� pues, en el circuito se distinguen tres modos de funcionamiento que se identifican
; mediante tres flags:
; A)	Modo "Termostato_OFF", donde funciona como term�metro normal sin termostato. Se
;	reconoce por el flag F_Termostato_OFF.
; B)	Modo "Termostato_Ajuste", donde se ajusta la temperatura deseada cuando funcione
;	como termostato. Se reconoce por el flag F_Termostato_Ajuste.
; C)	Modo "Termostato_ON", donde funciona como term�metro normal con termostato. Se
;	reconoce por el flag F_Termostato_ON.
;
; El programa consigue que est� activado uno solo de los flags anteriores.
;
; Al apagar el sistema debe conservar el valor de la temperatura deseada en el termostato
; para la pr�xima vez que se encienda.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK	0x0C
	TemperaturaDeseada
	Registro50ms				; Guarda los incrementos cada 50 ms.
	FlagsModos				; Guarda los flags para establecer los
	ENDC					; modos de trabajo.

	ORG	0x2100				; Corresponde a la direcci�n 0 de la zona
						; EEPROM de datos. Aqu� se va a guardar el
	DE	.24				; la temperatura deseada. En principio 24 �C.

#DEFINE  SalidaTermostato 		PORTB,1		; Carga controlada por el termostato.
#DEFINE  Zumbador	 	PORTB,2		; Aqu� se conecta el zumbador.
#DEFINE  ModoPulsador		PORTB,7		; Los pulsadores se conectan a estos
#DEFINE  IncrementarPulsador	PORTB,6		; pines del puerto B.
#DEFINE  F_Termostato_ON		FlagsModos,2	; Flags utilizados en el ajuste de la
#DEFINE  F_Termostato_Ajuste	FlagsModos,1	; temperatura del termostato.
#DEFINE  F_Termostato_OFF	FlagsModos,0

TMR0_Carga50ms	EQU	-d'195'			; Para conseguir interrupci�n cada 50 ms.
Carga2s		EQU	d'40'			; Leer� cada 2s = 40 x 50ms = 2000ms.	

; ZONA DE C�DIGOS ********************************************************************

	ORG 	0
	goto	Inicio
	ORG	4
	goto	ServicioInterrupcion

Mensajes
	addwf	PCL,F
MensajePublicitario
	DT "IES. ISAAC PERAL", 0x00
MensajeTermostato_ON
	DT "Termostato: ", 0x00
MensajeTermostato_Ajuste
	DT "Temper. deseada", 0x00
MensajeGradoCentigrado
	DT "�C  ", 0x00			; En pantalla LCD: "�C  "

Inicio	call	LCD_Inicializa
	bsf	STATUS,RP0
	movlw	b'00000111'		; Prescaler de 256 para el TMR0 y habilita
	movwf	OPTION_REG		; resistencias de Pull-Up del Puerto B.
	bsf	ModoPulsador		; Se configuran como entrada.
	bsf	IncrementarPulsador
	bcf	SalidaTermostato		; Se configuran como salida.
	bcf	Zumbador
	bcf	STATUS,RP0
	call	LCD_Linea1		; Se sit�a al principio de la primera l�nea.
	movlw	MensajePublicitario
	call	LCD_Mensaje
	call	DS1820_Inicializa		; Comienza la conversi�n del term�metro y pone
	call	ModoTermostato_OFF	; este modo de funcionamiento.
	movlw	TMR0_Carga50ms		; Carga el TMR0 en complemento a 2.
	movwf	TMR0
	movlw	Carga2s			; Y el registro cuyo decremento contar� los 2 s.
	movwf	Registro50ms
	clrw				; Lee la posici�n 0x00 de memoria EEPROM de datos
	call	EEPROM_LeeDato		; donde se guarda la temperatura deseada de la �ltima
	movwf	TemperaturaDeseada		; vez que se ajust�.
	movlw	b'10101000'		; Activa interrupci�n del TMR0 (T0IE), por cambio de
	movwf	INTCON			; l�neas del Puerto B (RBIE) y la general (GIE)
;
; La secci�n "Principal" es mantenimiento. S�lo espera las interrupciones.
; No se puede poner en modo de bajo consumo porque la instrucci�n "sleep" detiene el Timer 0.

Principal
	goto	Principal

; Subrutina "ServicioInterrupcion" ------------------------------------------------------
;
; Detecta qu� ha producido la interrupci�n y ejecuta la subrutina de atenci�n correspondiente.

ServicioInterrupcion
	btfsc	INTCON,T0IF		; Si es una interrupci�n producida por el Timer 0
	call	Termometro		; lee el term�metro y actualiza termostato.
	btfss	INTCON,RBIF		; Si es una interrupci�n RBI lee los pulsadores.
	goto	FinInterrupcion
	btfss	ModoPulsador		; �Est� presionado el pulsador de "AJUSTE"?
	call	CambiarModo		; S�. Ajusta la temperatura deseada en el termostato.
	btfss	IncrementarPulsador	; �Pulsado "INCREMENTAR"?
	call	IncrementarTempDeseada	; S�, pasa a incrementar la temperatura deseada.
FinInterrupcion
	bcf	INTCON,RBIF		; Limpia los flags de reconocimiento.
	bcf	INTCON,T0IF
	retfie

; Subrutina "Termometro" ----------------------------------------------------------------
;
; Esta subrutina lee y visualiza el term�metro cada 2 segundos aproximadamente. Se ejecuta
; debido a la petici�n de interrupci�n del Timer 0, cada 50 ms. Para conseguir una
; temporizaci�n de 2 s, habr� que repetir 40 veces el lazo de 50 ms (40x50ms=2000ms=2s).
;
; Tambi�n act�a sobre la salida del termostato posicion�ndola adecuadamente.

Termometro
	movlw	TMR0_Carga50ms
	movwf	TMR0			; Recarga el TMR0.
	decfsz	Registro50ms,F		; Decrementa el contador.
	goto	FinInterrupcion		; No han pasado 2 segundos, por tanto sale.
	movlw	Carga2s			; Repone este contador nuevamente.
	movwf	Registro50ms
	call	DS1820_LeeTemperatura	; Lee la temperatura.
	call	DS1820_Inicializa		; Comienza conversi�n para la siguiente lectura.
	call	Termostato		; Act�a sobre el termostato.
;	call	Visualiza			; Como esta subrutina se escribe a continuaci�n
;	return				; se ahorra estas dos instrucciones y ahorra 
					; tambi�n espacio en la pila.
; Subrutina "Visualiza" -----------------------------------------------------------------
;
; Visualiza el term�metro en tres formatos posibles:
; A)	Con el termostato desactivado, modo "Termostato_OFF". Por ejemplo:
; 				"IES. Isaac Peral" (Primera l�nea)
;				"       24.5�C   " (Segunda l�nea).
;		Donde en la primera l�nea se visualiza un mensaje publicitario y en la
;		segunda l�nea la temperatura medida actual.
; B)	Ajuste del termostato, modo "Termostato_Ajuste". Por ejemplo:
;	 			"Temper. deseada" (Primera l�nea)
;				"        25�C     " (Segunda l�nea).
; 		Donde en la segunda l�nea visualiza la temperatura que se desea ajustar.
; C)	Con el termostato activado, modo "Termostato_ON". Por ejemplo:
; 				"Termostato: 25�C" (Primera l�nea)
;				"      23.5�C    " (Segunda l�nea).
; 		Donde en la primera l�nea se visualiza la temperatura que se desea
;		ajustar y en la segunda l�nea la temperatura medida actual.
Visualiza
	btfsc	F_Termostato_OFF
	goto	VisualizaTermometro
	btfsc	F_Termostato_Ajuste
	goto	VisualizaTermostato_Ajuste
	btfsc	F_Termostato_ON
	goto	VisualizaTermostato_ON
	return

; "VisualizaTermostato_ON" --------------------------------------------------------------
;
; Visualiza el valor de la temperatura deseada en la primera l�nea y el valor de la
; temperatura medida en la segunda l�nea.
; 
VisualizaTermostato_ON
	call	LCD_Linea1
	movlw	MensajeTermostato_ON
	call	LCD_Mensaje
	call	VisualizaTemperaturaDeseada
	call	VisualizaTemperaturaMedida
	return

; "VisualizaTermostatoAjuste" y "VisualizaTemperaturaDeseada" ---------------------------
;
; Visualiza en la pantalla el formato propio de este modo.
; 
; Entradas:	(TemperaturaDeseada) temperatura ajustada en la subrutina Incrementar.

VisualizaTermostato_Ajuste
	call	LCD_Linea1		; Se sit�a al principio de la primera l�nea.
	movlw	MensajeTermostato_Ajuste	; Visualiza mensaje en la primera l�nea.
	call	LCD_Mensaje
	movlw	.6			; Se coloca para centrar visualizaci�n en la 
	call	LCD_PosicionLinea2	; segunda l�nea.
VisualizaTemperaturaDeseada
	movf	TemperaturaDeseada,W
	call	BIN_a_BCD		; La pasa a BCD.
	call	LCD_Byte		; Visualiza, apagando los ceros no significativos.
	movlw	MensajeGradoCentigrado	; En pantalla aparece "�C  ".
	call	LCD_Mensaje
	return

; "VisualizaTermometro" y ""VisualizaTemperaturaMedida" ---------------------------------
;
; En la primera l�nea se visualiza un mensaje publicitario y en la segunda l�nea la
; temperatura medida
;
; Entradas:  -	(DS1820_Temperatura), temperatura medida en valor absoluto.
;	     -	(DS1820_TemperaturaDecimal), parte decimal de la temperatura medida.
;	     -	(DS1820_Signo), registro con el signo de la temperatura. Si es igual a
;		b'00000000' la temperatura es positiva. Si es b'11111111' resulta que
;		la temperatura es negativa.
;
VisualizaTermometro
	call	LCD_Linea1		; Se sit�a al principio de la primera l�nea.
	movlw	MensajePublicitario
	call	LCD_Mensaje
VisualizaTemperaturaMedida
	movlw	.5			; Se coloca para centrar visualizaci�n en la
	call	LCD_PosicionLinea2	; segunda l�nea.
	btfss	DS1820_TemperaturaSigno,7 ; �Temperatura negativa?
	goto	TemperaturaPositiva		; No, es positiva.
TemperaturaNegativa:
	movlw 	'-'			; Visualiza el signo "-" de temperatura negativa.
	call	LCD_Caracter
TemperaturaPositiva
	movf	DS1820_Temperatura,W
	call	BIN_a_BCD		; La pasa a BCD.
	call	LCD_Byte		; Visualiza apagando los ceros no significativos.
	movlw	'.'			; Visualiza el punto decimal.
	call	LCD_Caracter
	movf	DS1820_TemperaturaDecimal,W ; Visualiza la parte decimal.
	call	LCD_Nibble
	movlw	MensajeGradoCentigrado	; En pantalla LCD aparece "�C  ".
	call	LCD_Mensaje
	return

; Subrutina "Termostato" ----------------------------------------------------------------
;
; Controla una carga en funci�n del valor de la temperatura medida respecto de la temperatura
; deseada. Para evitar inestabilidad en la salida, tendr� un peque�o ciclo de hist�resis.
; As� por ejemplo, si la temperatura deseada es 24 �C la carga se activar� cuando la
; temperatura baje o sea igual a 23,5 �C y se apagar� cuando la supere o sea igual a 25�C.
; Si la temperatura medida est� entre esos m�rgenes (23,5 y 25�C), se queda en el estado
; anterior, tanto si est� encendida como apagada.
;
; Para temperaturas negativas la salida se debe activar siempre.
;
; Entradas:   -	(DS1820_Temperatura), temperatura medida en valor absoluto.
;	     -	(TemperaturaDeseada), temperatura a partir de la cual se tomar�n
;		decisiones sobre la salida.
;	     -	(DS1820_Signo), registro con el signo de la temperatura medida. Si es cero
;		la temperatura es positiva y todos sus bits son "1", es negativa.
;
; Salida:    -	Su funcionamiento:
;	 	     -	Estando apagada, si la temperatura medida desciende por debajo de la
;			temperatura deseada la salida se activar�.
;		     -	Estando encendida, si la temperatura medida supera la deseada la
;			salida se apagar�.
;		     -	Si las temperaturas medidas y deseada son iguales se queda en estado
;			anterior, tanto si est� encendida como si est� apagada.
;		     -	Para temperaturas negativas la salida se debe activar siempre.
Termostato
	btfss	F_Termostato_ON		; Si el termostato no est� activado salta a
	goto	ApagaCarga		; apagar la carga.
	btfsc	DS1820_TemperaturaSigno,7	; Con temperaturas negativas pasa a activar
	goto	EnciendeCarga		; la carga.
	btfss	SalidaTermostato		; Comprueba el estado actual de la salida para
	goto	SalidaEstabaApagada	; actuar en consecuencia.
SalidaEstabaActivada			; Pasa a comprobar si tiene que apagar la carga.
	movf	DS1820_Temperatura,W
	subwf	TemperaturaDeseada,W	; (W)=(TemperaturaDeseada)-(DS1820_Temperatura).
	btfsc	STATUS,C		; �(TemperaturaDeseada)<(DS1820_Temperatura)?	
	goto	FinTermostato		; S�, por tanto, lo deja encendido y sale.
	call	Pitido			; Pitido cada vez que conmuta la carga.
ApagaCarga
	bcf	SalidaTermostato		; Apaga la salida y sale.
	goto	FinTermostato
SalidaEstabaApagada			; Pasa a comprobar si tiene que encender la carga
	movf	TemperaturaDeseada,W
	subwf	DS1820_Temperatura,W	; (W)=(DS1820_Temperatura)-(TemperaturaDeseada).
	btfsc	STATUS,C		; �(DS1820_Temperatura)<(TemperaturaDeseada)?	
	goto	FinTermostato		; S�, la deja apagada y sale.
EnciendeCarga
	call	Pitido			; Pitido cada vez que activa la carga.
	bsf	SalidaTermostato
FinTermostato
	return

; Subrutinas "CambiarModo" y "ModoTermostato_OFF" -----------------------------------------
;
; Subrutina de atenci�n a la interrupci�n producida por el pulsador "MODO" que cambia el modo
; de funcionamiento. Cada vez que pulsa pasa por los modos "Termostato_Ajuste", "Termostato_ON",
; "Termostato_OFF" y vuelta repetir.
;
; El ajuste de la temperatura deseada en el termostato se logra mediante dos pulsadores: "MODO"
; e "INCREMENTAR" conectados a pines del Puerto B.

; Al principio aparecer� s�lo el term�metro y el termostato estar� desactivado: modo
; "Termostato_OFF"
;
; Para comprender el funcionamiento de esta subrutina, hay que saber que el registro FlagsModos
; contiene 3 flags que permiten diferenciar cada uno de los modos de funcionamiento:
; A)	Modo "Termostato_OFF", donde funciona como term�metro normal sin termostato. Se
;	reconoce por el flag F_Termostato_OFF, que es el bit 0 del registro FlagsModos.
; B)	Modo "Termostato_Ajuste", donde se ajusta la temperatura deseada cuando funcione
;	como termostato. Se reconoce por el flag F_Termostato_Ajuste, que es el bit 1 del
;	registro FlagsModos.
; C)	Modo "Termostato_ON", donde funciona como term�metro normal y, adem�s, como termostato.
;	Se reconoce por el flag F_Termostato_ON, que es el bit 2 del registro FlagsModos.
;
; As� pues, el contenido del registro (FlagsModos) identifica los siguientes modos de
; funcionamiento:
; - (FlagsModos)=b'00000001'. Est� en el modo "Termostato_OFF".
; - (FlagsModos)=b'00000010'. Est� en el modo "Termostato_Ajuste".
; - (FlagsModos)=b'00000100'. Est� en el modo "Termostato_ON".

; Pueden darse dos casos:
;     -	Que pulse "AJUSTE" estando en el modo m�s alto, "Termostato_ON",
;	(FlagsModos)=b'00000100'. En este caso debe pasar al modo inicial 
;	"Termostato_OFF" poniendo (FlagsModos)=b'00000001'.
;     -	Que pulse "AJUSTE" estando ya en cualquiera de los otros dos modos, en cuyo caso debe
;	pasar al siguiente modo. Esto lo hace mediante un desplazamiento a izquierdas. As�, por
;	ejemplo, si antes estaba en modo "Termostato_OFF", (FlagsModos)=b'00000001', pasar� a
;	(FlagsModos)=b'00000010' que identifica al modo "Termostato_Ajuste".
;
CambiarModo
	call	Retardo_20ms		; Espera a que se estabilicen niveles de tensi�n.
	btfsc	ModoPulsador		; Si es un rebote, sale fuera.
	goto	FinCambiarModo
	call	PitidoCorto		; Cada vez que pulsa se oye un pitido.
	btfss	F_Termostato_ON		; Detecta si est� en el �ltimo modo.
	goto	ModoSiguiente		; Si no, pasa al modo siguiente.
ModoTermostato_OFF
	call	Pitido			; Pitido cada vez que conmuta la carga.
	bcf	SalidaTermostato		; Apaga la carga.
	movlw	b'00000001'		; Actualiza el registro FlagsModos pasando al
	movwf	FlagsModos		; modo inicial "Termostato_OFF".
	goto	BorraPantalla
ModoSiguiente				; Desplaza un "1" a la izquierda del registro
	bcf	STATUS,C		; FlagsModos para ajustar secuencialmente
	rlf	FlagsModos,F		; cada uno de los modos de funcionamiento.
BorraPantalla
	call	LCD_Borra		; Borra la pantalla anterior.
FinCambiarModo
	call	Visualiza
	btfss	ModoPulsador		; Ahora espera a que deje de pulsar.
	goto	FinCambiarModo
	return

; Subrutina "IncrementarTempDeseada" ----------------------------------------------------
;
; Subrutina de atenci�n a la interrupci�n por cambio de la l�nea RB6 a la cual se ha conectado
; el pulsador "INCREMENTAR". Estando en el modo "Termostato_Ajustar" incrementa el valor de
; la temperatura deseada entre unos valores m�ximo y m�nimo.
;
; Al final debe guardar el valor de la temperatura deseada en memoria EEPROM de datos para
; preservar su valor en caso que desaparezca la alimentaci�n.
;
TemperaturaMinima   EQU	.20
TemperaturaMaxima   EQU	.36

IncrementarTempDeseada
	call	Retardo_20ms		; Espera a que se estabilicen niveles de tensi�n.	
	btfsc	IncrementarPulsador	; Si es un rebote sale fuera.
	goto	FinIncrementar
	btfss	F_Termostato_Ajuste	; Si no est� en modo "Termostato_Ajuste" sale
	goto	FinIncrementar		; fuera.
	call	PitidoCorto		; Pitido cada vez que pulsa.
	incf	TemperaturaDeseada,F	; Incrementa el valor de la temperatura deseada.
	movlw	TemperaturaMaxima	; �Ha llegado a la temperatura m�xima de ajuste?.
	subwf	TemperaturaDeseada,W	; (W) = (TemperaturaDeseada) - TemperaturaMaxima.
	btfss	STATUS,C		; �(TemperaturaDeseada)>=TemperaturaMaxima?
	goto	VisualizaIncremento	; No, pasa a visualizarlo.
	movlw	TemperaturaMinima		; S�, entonces inicializa el registro.
	movwf	TemperaturaDeseada
VisualizaIncremento
	call	Visualiza			; Visualiza mientras espera a que deje
	call	Retardo_200ms		; de pulsar.
	btfss	IncrementarPulsador	; Mientras permanezca pulsado,
	goto	IncrementarTempDeseada	; incrementa el d�gito.
	clrw				; Salva el valor de la temperatura deseada en la 
	movwf	EEADR			; posici�n 00h de la EEPROM de datos. Se conserva
	movf	TemperaturaDeseada,W	; aunque se apague la alimentaci�n.
	call	EEPROM_EscribeDato
FinIncrementar
	return

; Subrutina de pitidos ------------------------------------------------------------------
;
PitidoLargo
	bsf	Zumbador
	call	Retardo_500ms
Pitido	bsf	Zumbador
	call	Retardo_200ms
PitidoCorto
	bsf	Zumbador
	call	Retardo_20ms
	bcf	Zumbador
	return
;
	INCLUDE  <BUS_1LIN.INC>	; Subrutinas de control del bus de 1 l�nea.
	INCLUDE  <DS1820.INC>		; Subrutinas de control del term�metro digital.
	INCLUDE  <RETARDOS.INC>
	INCLUDE  <BIN_BCD.INC>
	INCLUDE  <LCD_4BIT.INC>
	INCLUDE  <LCD_MENS.INC>
	INCLUDE  <EEPROM.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
