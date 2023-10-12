;********************************** I2C_Reloj_01.asm ************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Programa para un reloj digital en tiempo real con puesta en hora. Visualiza los datos del
; reloj en formato:	"D�a  Mes  A�o" (Primera l�nea)
; 		"D�a_de_la_Semana   Horas:Minutos:Segundos", (Segunda l�nea)
; (por ejemplo	" 7 Diciemb. 2004" (Primera l�nea).
;		"Martes   8:47:39" (Segunda l�nea).
;
; La actualizaci�n del reloj se consigue leyendo el chip DS1307, que es un reloj y
; calendario en tiempo real compatible con bus I2C.
;
; El DS1307 se configura para que genere una se�al cuadrada de un 1 Hz por su pin SQW/OUT.
; Esta se�al se aplica al pin de interrupci�n INT del PIC16F84A de manera que genera una
; interrupci�n cada segundo, que es cuando realiza la lectura del DS1307 y la visualiza.
;
; La "PuestaEnHora" se logra mediante dos pulsadores: "MODO" e "INCREMENTAR".
; Su modo de operaci�n es:
;   1�	Pulsa MODO, los "A�os" se ponen intermitente y se ajustan mediante el
;	pulsador INCREMENTAR.
;   2�	Pulsa MODO y pasa a ajustar los "Meses" de forma similar.
;   3�	Se va pulsando MODO secuencialmente para ajustar del modo anteriormente
;	explicado los d�as del mes, los d�as de la semana, las horas y los minutos.
;   4�	Pulsa MODO y se acab� la "PuestaEnHora", pasando a visualizaci�n normal.
;
; Cuando se ajusta una variable de tiempo, �sta debe aparecer en intermitencia.
;
; Los pulsadores MODO e INCREMENTAR se conectan a l�neas del Puerto B y su
; funcionamiento se basa en interrupci�n por cambio en la l�nea del Puerto B:
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	Auxiliar					; Registro auxiliar.
	Intermitencia				; Para lograr la intermitencia.
						; Si es 0, apaga en intermitencia.
	FlagsAjuste				; Guarda los flags para establecer los
	ENDC					; ajustes de d�a, mes, a�o, hora, etc.

#DEFINE  ModoPulsador		PORTB,7		; Los pulsadores se conectan a estos
#DEFINE  IncrementarPulsador	PORTB,6		; pines del Puerto B.
#DEFINE  OndaCuadrada_DS1307	PORTB,0		; La onda cuadrada al pin RBO/INT.
#DEFINE  F_AjusteAnho		FlagsAjuste,5	; Flags para los diferentes modos de
#DEFINE  F_AjusteMes		FlagsAjuste,4	; ajustes.
#DEFINE  F_AjusteDia		FlagsAjuste,3
#DEFINE  F_AjusteDiaSemana	FlagsAjuste,2
#DEFINE  F_AjusteHora		FlagsAjuste,1
#DEFINE  F_AjusteMinuto		FlagsAjuste,0

; ZONA DE C�DIGOS ********************************************************************

	ORG 	0
	goto	Inicio
	ORG	4
	goto	ServicioInterrupcion

Mensajes
	addwf	PCL,F
MensajeLunes
	DT "Lunes   ", 0x00
MensajeMartes
	DT "Martes  ", 0x00
MensajeMiercoles
	DT "Mierc.  ", 0x00
MensajeJueves
	DT "Jueves  ", 0x00
MensajeViernes
	DT "Viernes ", 0x00
MensajeSabado
	DT "Sabado  ", 0x00
MensajeDomingo
	DT "Domingo ", 0x00
;
MensajeEnero
	DT "  Enero ", 0x00
MensajeFebrero
	DT " Febrero", 0x00
MensajeMarzo
	DT "  Marzo ", 0x00
MensajeAbril
	DT "  Abril ", 0x00
MensajeMayo
	DT "  Mayo  ", 0x00
MensajeJunio
	DT "  Junio ", 0x00
MensajeJulio
	DT "  Julio ", 0x00
MensajeAgosto
	DT " Agosto ", 0x00
MensajeSeptiembre
	DT "Septiem.", 0x00
MensajeOctubre
	DT "Octubre ", 0x00
MensajeNoviembre
	DT "Noviemb.", 0x00
MensajeDiciembre
	DT "Diciemb.", 0x00
MensajeBlanco
	DT "        ", 0x00		; Ocho espacios en blanco.
;
DiasSemana
	addwf	PCL,F
	nop				; No hay d�a 0 de la semana. Empiezan en
	retlw	MensajeLunes		; el d�a 1 de la semana (Lunes).
	retlw	MensajeMartes		; D�a 2 de la semana.
	retlw	MensajeMiercoles		; D�a 3 de la semana.
	retlw	MensajeJueves		; D�a 4 de la semana.
	retlw	MensajeViernes		; D�a 5 de la semana.
	retlw	MensajeSabado		; D�a 6 de la semana.
	retlw	MensajeDomingo		; D�a 7 de la semana.
Meses
	addwf	PCL,F
	nop				; No hay mes 0x00.
	retlw	MensajeEnero		; Empiezan en el mes 1 (Enero).
	retlw	MensajeFebrero		; Mes 0x02
	retlw	MensajeMarzo		; Mes 0x03
	retlw	MensajeAbril		; Mes 0x04
	retlw	MensajeMayo		; Mes 0x05
	retlw	MensajeJunio		; Mes 0x06
	retlw	MensajeJulio		; Mes 0x07
	retlw	MensajeAgosto		; Mes 0x08
	retlw	MensajeSeptiembre		; Mes 0x09
	nop				; Mes 0x0A	(Como el DS1307 trabaja en BCD,
	nop				; Mes 0x0B	estos meses se rellenan con
	nop				; Mes 0x0C	"nop").
	nop				; Mes 0x0D
	nop				; Mes 0x0E
	nop				; Mes 0x0F
	retlw	MensajeOctubre		; Mes 0x10
	retlw	MensajeNoviembre		; Mes 0x11
	retlw	MensajeDiciembre		; Mes 0x12
FinTablas

; Estas tablas y mensajes se sit�an al principio del programa con el prop�sito que no
; supere la posici�n 0FFh de memoria ROM de programa. De todas formas, en caso que as�
; fuera se visualizar�a el siguiente mensaje de error en el proceso de ensamblado:
;
	IF (FinTablas > 0xFF)
		ERROR	"Atenci�n: La tabla ha superado el tama�o de la p�gina de los"
		MESSG	"primeros 256 bytes de memoria ROM. NO funcionar� correctamente."
	ENDIF

; Instrucciones de inicializaci�n. ------------------------------------------------------
;
Inicio	call	LCD_Inicializa
	bsf	STATUS,RP0		; Acceso banco 1.
	bcf	OPTION_REG,NOT_RBPU	; Se activan las resistencias de Pull-Up del Puerto B.
	bsf	ModoPulsador		; Los pulsadores se configuran como entrada.
	bsf	IncrementarPulsador
	bsf	OndaCuadrada_DS1307
	bcf	OPTION_REG,INTEDG	; Interrupci�n INT activa por flanco de bajada.
	bcf	STATUS,RP0		; Acceso banco 0.
	clrf	FlagsAjuste		; Inicializa todos los flags de la puesta en hora.
	call	DS1307_Inicializa		; Configura la se�al cuadrada que genera el 
					; DS1307 en su pin SQW/OUT a 1 Hz.
;
; Ahora lee el bit 7 de los segundos para saber el estado anterior del reloj antes del
; reset. Este bit es el CH (Control Halt) y permite poner en marcha (CH=0) o parar el
; reloj (CH=1). Tras la lectura pueden ocurrir dos casos:
;     -	Si CH est� a 0 quiere decir que anteriormente el reloj ya se ha puesto en hora alguna
;	vez y est� en modo "respaldo". Es decir, ha fallado la alimentaci�n y el DS1307 se est�
;	alimentando por la bater�a conectada al pin "VBAT", aunque el reloj no se visualice en
;	la pantalla. Por tanto, no debe inicializarse porque se corromper�a el contenido del
;	DS1307 que ya est� en marcha.
;     -	Si CH est� a 1, quiere decir que estaba parado y es la primera vez que se pone en hora.
;
	call	DS1307_Lee		; Lee los segundos en el DS1307 y comprueba el
	btfss	Segundo,7		; valor del bit CH. Si es "1" salta toda la
	goto	AntesConBateria		; inicializaci�n de los registros y la puesta
					; en hora inicial.
	call	DS1307_CargaInicial	; Realiza la carga inicial a 1 Enero de 2004.
	movlw	b'10011000'		; Las interrupciones se deben habilitar despu�s
	movwf	INTCON			; de la carga inicial del DS1307.
	call	PuestaEnHoraReset		; Puesta en hora por primera vez.
	goto	Principal
	
AntesConBateria
	movlw	b'10011000'		; Habilita las interrupciones INT, RBI y la
	movwf	INTCON			; general GIE.

; La secci�n "Principal" de mantenimiento. Pasa al modo reposo y s�lo espera las interrupciones
; procedentes de la l�nea "SQW/OUT" del DS1307 que se producen cada segundo en funcionamiento
; normal y cada 500 ms cuando est� en la "PuestaEnHora".

Principal
	sleep
	goto	Principal

; Subrutina "ServicioInterrupcion" ------------------------------------------------------
;
; Detecta qu� ha producido la interrupci�n y ejecuta la subrutina de atenci�n correspondiente.

ServicioInterrupcion
	btfsc	INTCON,INTF		; Si es una interrupci�n procedente de la onda
	call	Reloj			; cuadrada del DS1307 actualiza la visualizaci�n.
	btfss	INTCON,RBIF		; Si es una interrupci�n RBI lee los pulsadores.
	goto	FinInterrupcion
	btfss	ModoPulsador		; �Est� presionado el pulsador de "MODO"?
	call	PuestaEnHora		; S�, pasa a poner en hora.
	btfss	IncrementarPulsador		; �Pulsado "INCREMENTAR"?
	call	Incrementar		; S�, pasa a incrementar el registro de tiempo
FinInterrupcion				; correspondiente.
	bcf	INTCON,RBIF		; Limpia los flags de reconocimiento de la
	bcf	INTCON,INTF		; interrupci�n.
	retfie

; Subrutina "Reloj" ---------------------------------------------------------------------
;
; Esta subrutina actualiza los registros Anho, Mes, Dia, DiaSemana, Hora, Minuto y Segundo
; leyendo el DS1307 a trav�s del bus I2C. Se ejecuta debido a la petici�n de interrupci�n de
; la se�al cuadrada de 1 Hz, que procede del pin "SQW/OUT" del DS1307 y se ha conectado al pin
; RB0/INT del PIC16F84A.
;
; Esta interrupci�n ocurre cada segundo si est� en visualizaci�n normal y cada 500 ms si est�
; en puesta en hora con el objetivo de conseguir la intermitencia.
;
; Si no est� en puesta en hora est� en funcionamiento normal, por tanto se limita a leer
; el DS1307 y a visualizar la hora.
;
Reloj	movf	FlagsAjuste,F		; Si no est� en puesta en hora se limita a
	btfsc	STATUS,Z		; leer el DS1307.
	goto	Leer_DS1307

; Si est� en alg�n modo de ajuste debe interrumpir cada 500 ms para lograr la intermitencia
; alternando la interrupci�n por flanco de subida o de bajada. Esto lo consigue mediante la
; operaci�n XOR del flag INTEDG con un "1", lo cual invierte este bit cada vez que ejecuta la
; instrucci�n y por tanto conmuta entre flanco ascendente y descendente.

	bsf	STATUS,RP0		; Acceso banco 1.
	movlw	b'01000000'		; El bit INTEDG est� en el lugar 6 del registro.
	xorwf	OPTION_REG,F
	bcf	STATUS,RP0		; Acceso banco 0.

; Adem�s complementa el registro Intermitencia para que se produzca la intermitencia
; cada 500 milisegundos cuando est� en la puesta en hora.

	comf	Intermitencia,F
	goto	ActualizaReloj		; Visualiza el reloj y sale.

Leer_DS1307

; No est� en ning�n modo de ajuste, sino en funcionamiento normal de reloj y pasa a leer los
; registros del reloj-calendario DS1307 a trav�s del bus I2C. Los registros del DS1307 ya
; trabajan en formato BCD, por tanto no hay que hacer ning�n tipo de conversi�n al leerlos.

	call	DS1307_Lee
ActualizaReloj				; Estas dos instrucciones se pueden
;	call	VisualizaReloj		; obviar, ya que a continuaci�n efectivamente 
;	return				; ejecuta la subrutina VisualizaReloj y
					; retorna.
; Subrutina "VisualizaReloj" ------------------------------------------------------------
;
; Visualiza el reloj en formato	"Dia  Mes  A�o" (Primera L�nea)
; 			"D�a_de_la_Semana Horas:Minutos:Segundos", (Segunda L�nea)
; Por ejemplo		" 7 Diciemb. 2004" (Primera Linea).
;			"Martes   8:47:39" (Segunda L�nea).

; La variable ajustada debe aparecer en intermitencia. Esto se logra con ayuda de cualquier
; bit del registro Intermitencia que conmuta cada 500 ms en la subrutina Reloj.
;
VisualizaReloj
	call	LCD_Linea1		; Se sit�a en la primera l�nea.
	btfss	F_AjusteDia		; �Est� en la puesta en hora?
	goto	EnciendeDia		; No. Pasa a visualizaci�n normal.
	btfss	Intermitencia,0		; S�. Pasa a intermitencia si procede.
	goto	ApagaDia			; Apaga en la intermitencia.
EnciendeDia
	movf	Dia,W			; Lo visualiza. El DS1307 ya lo da en BCD.
	call	LCD_Byte		; Visualiza rechazando cero de las decenas.
	goto	VisualizaMes
ApagaDia
	call	LCD_DosEspaciosBlancos	; Visualiza dos espacios en blanco.
;
VisualizaMes
	call	LCD_UnEspacioBlanco	; Visualiza un espacio en blanco.
	btfss	F_AjusteMes		; �Est� en la puesta en hora?
	goto	EnciendeMes		; No. Visualizaci�n normal.
	btfss	Intermitencia,0		; S�. Intermitencia si procede.
	goto	ApagaMes		; Apaga en la intermitencia.
EnciendeMes
	movf	Mes,W			; Lo visualiza.
	call	EscribeMes
	goto	VisualizaAnho
ApagaMes
	movlw	MensajeBlanco
	call	LCD_Mensaje		; Visualiza varios espacios en blanco.
;
VisualizaAnho
	btfss	F_AjusteAnho		; �Est� en la puesta en hora?
	goto	EnciendeAnho		; No. Visualizaci�n normal.
	btfss	Intermitencia,0		; S�. Intermitencia si procede.
	goto	ApagaAnho		; Apaga en la intermitencia.
EnciendeAnho
	call	LCD_UnEspacioBlanco	; Visualiza un espacio en blanco.
	movlw	0x20			; Visualiza el "20xx", del a�o "dos mil ...".
	call	LCD_Byte
	movf	Anho,W
	call	LCD_ByteCompleto
	goto	VisualizaDiaSemana
ApagaAnho
	movlw	MensajeBlanco
	call	LCD_Mensaje		; Visualiza varios espacios en blanco.
;
VisualizaDiaSemana
	call	LCD_Linea2		; Se sit�a en la segunda l�nea.
	btfss	F_AjusteDiaSemana		; �Est� en la puesta en hora?
	goto	EnciendeDiaSemana	; No. Visualizaci�n normal.
	btfss	Intermitencia,0		; S�. Intermitencia si procede.
	goto	ApagaDiaSemana		; Apaga en la intermitencia.
EnciendeDiaSemana
	movf	DiaSemana,W		; Lo visualiza.
	call	EscribeDiaSemana
	goto	VisualizaHoras
ApagaDiaSemana
	movlw	MensajeBlanco
	call	LCD_Mensaje		; Visualiza varios espacios en blanco.
;
VisualizaHoras
	btfss	F_AjusteHora		; �Est� en la puesta en hora?
	goto	EnciendeHoras		; No. Visualizaci�n normal.
	btfss	Intermitencia,0		; S�. Intermitencia si procede.
	goto	ApagaHoras		; Apaga las horas en la intermitencia.
EnciendeHoras
	movf	Hora,W			; Va a visualizar las horas. 
	call	LCD_Byte		; Visualiza rechazando cero de las decenas.
	goto	VisualizaMinutos
ApagaHoras
	call	LCD_DosEspaciosBlancos	; Visualiza dos espacios en blanco.
;
VisualizaMinutos
	movlw	':'			; Env�a ":" para separar datos.
	call	LCD_Caracter
	btfss	F_AjusteMinuto		; �Est� en la puesta en hora?.
	goto	EnciendeMinutos
	btfss	Intermitencia,0
	goto	ApagaMinutos
EnciendeMinutos
	movf	Minuto,W		; Visualiza minutos.
	call	LCD_ByteCompleto
	goto	VisualizaSegundos
ApagaMinutos
	call	LCD_DosEspaciosBlancos	; Visualiza dos espacios en blanco.
;
VisualizaSegundos
	movlw	':'			; Env�a ":" para separar datos.
	call	LCD_Caracter
	movf	Segundo,W		; Visualiza segundos.
	call	LCD_ByteCompleto
	return
;
; Subrutina "EscribeDiaSemana" ----------------------------------------------------------
;
; Escribe el d�a de la semana en la posici�n actual de la pantalla, utilizando la tabla
; "DiaSemana". Supone que el Lunes es el d�a 1 y el Domingo el 7. 
; En el registro W se le introduce el d�a de la semana num�rico y en la pantalla aparece el
; d�a de la semana en letras. As� por ejemplo si (W)=0x02 en la pantalla aparecer� "Martes".
;
; Primero comprueba que no ha superado el valor m�ximo para evitar problemas de saltos
; err�ticos con la llamada "call DiasSemana", en caso de una lectura defectuosa de este
; dato por parte del DS1307.
;
EscribeDiaSemana
	sublw	0x07			; �Ha superado su valor m�ximo?
	btfsc	STATUS,C
	goto	Llamada_a_DiasSemana
	movlw	0x01			; Lo inicializa si ha superado su valor m�ximo.
	movwf	DiaSemana
Llamada_a_DiasSemana
	movf	DiaSemana,W
	call	DiasSemana
	call	LCD_Mensaje
	return

; Subrutina "EscribeMes" ----------------------------------------------------------------
;
; Escribe el mes del a�o en la posici�n actual de la pantalla, utilizando la tabla "Meses". 
;
; Primero comprueba que no ha superado el valor m�ximo para evitar problemas de saltos
; err�tico con la llamada "call Meses", en caso de una lectura defectuosa de este dato
; por parte del DS1307.
;
; El DS1307 trabaja en BCD y la tabla en binario natural. Esto es un problema que se 
; soluciona con una correcta distribuci�n de la tabla "Meses".
;
EscribeMes
	sublw	0x12			; �Ha superado su valor m�ximo? (Observad que
	btfsc	STATUS,C		; trabaja en BCD).
	goto	Llamada_a_Meses
	movlw	0x01			; Lo inicializa si ha superado su valor m�ximo.
	movwf	Mes
Llamada_a_Meses
	movf	Mes,W			; Retorna el resultado en el registro W.
	call	Meses
	call	LCD_Mensaje
	return

; Subrutina "PuestaEnHora" --------------------------------------------------------------
;
; Subrutina de atenci�n a la interrupci�n producida por el pulsador MODO que pone en hora el 
; reloj. Cada vez que pulsa se desplaza el "1" a trav�s del registro FlagsAjuste, pasando a
; ajustar secuencialmente: a�os, meses, d�as, d�as de la semana, horas y minutos.
;
; Para comprender el funcionamiento de esta subrutina hay que saber que el registro FlagsModos
; contiene 5 flags que permite diferenciar cada uno de los ajustes de registros de tiempo:
; - "F_AjusteAnho":		bit 5 de FlagsAjuste, para ajustar los a�os.
; - "F_AjusteMes":	 	bit 4 de FlagsAjuste, para ajustar los meses.
; - "F_AjusteDia":	 	bit 3 de FlagsAjuste, para ajustar los d�as del mes.
; - "F_AjusteDiaSemana": 	bit 2 de FlagsAjuste, para ajustar los d�as de la semana.
; - "F_AjusteHora":	 	bit 1 de FlagsAjuste, para ajustar las horas.
; - "F_AjusteMinuto":	 	bit 0 de FlagsAjuste, para ajustar los minutos.
;
; As� pues el contenido del registro FlagAjuste identifica los siguientes ajustes:
; - (FlagsAjuste)=b'00100000'. Est� ajustando el registro Anho (A�os).
; - (FlagsAjuste)=b'00010000'. Est� ajustando el registro Mes.
; - (FlagsAjuste)=b'00001000'. Est� ajustando el registro Dia.
; - (FlagsAjuste)=b'00000100'. Est� ajustando el registro DiaSemana (Lunes, Martes, etc).
; - (FlagsAjuste)=b'00000010'. Est� ajustando el registro Hora.
; - (FlagsAjuste)=b'00000001'. Est� ajustando el registro Minuto.
; - (FlagsAjuste)=b'00000000'. Est� en visualizaci�n normal del reloj en tiempo real.
;
; Pueden ocurrir tres casos:
;     -	Que pulse "MODO" estando en modo de visualizaci�n normal identificado porque
;	(FlagsAjuste)=b'0000000'. En este caso debe activar el flag F_AjusteAnho, es decir,
;	carga (FlagsAjuste)=b'00100000', ya que el flag F_AjusteAnho es el bit 5 del registro
;	FlagsAjuste.
;     -	Que pulse "MODO" estando ya en la puesta en hora, en cuyo caso debe pasar al
;	ajuste del siguiente registro de tiempo. �sto lo hace mediante un desplazamiento
;	a derechas. As� por ejemplo, si antes estaba ajustando los meses, es decir: 
;	(FlagsAjuste)=b'00010000', pasar� a (FlagsAjuste)=b'00001000' que se identifica
;	como ajuste de los d�as del mes.
;     -	Que pulse "MODO" estando en el �ltimo ajuste correspondiente a los minutos,
;	(FlagsAjuste)=b'00000001', pasar� a (FlagsAjuste)=b'00000000', indicando que la
; 	puesta en hora ha terminado y pasa a visualizaci�n normal del reloj en tiempo real.
;
PuestaEnHora
	call	Retardo_20ms		; Espera a que se estabilicen niveles de tensi�n.
	btfsc	ModoPulsador		; Si es un rebote sale fuera.
	goto	FinPuestaEnHora
PuestaEnHoraReset				; Al pulsar "MODO" se apaga la variable de
	clrf	Intermitencia		; tiempo que se va a ajustar.
	btfsc	F_AjusteMinuto		; Si antes estaba en ajuste de minutos es que
	goto	FuncionamientoNormal	; ha terminado. Graba datos en el DS1307 y sale.
	movf	FlagsAjuste,F		; Si antes estaba en funcionamiento normal ahora
	btfss	STATUS,Z 		; pasa a ajustar el a�o.
	goto	AjustaSiguiente		; Sino pasa a ajustar la variable de tiempo siguiente.
	bsf	F_AjusteAnho		; Pasa a ajustar el a�o.
	clrf	Segundo			; Inicializa contador de segundos.
	goto	FinPuestaEnHora
AjustaSiguiente				; Desplaza un uno a la derecha del registro
	bcf	STATUS,C		; FlagsAjuste para ajustar secuencialmente cada
	rrf	FlagsAjuste,F		; uno de los registros de tiempo: a�o, mes, d�a,
	goto	FinPuestaEnHora		; d�a de la semana, hora y minuto.
;
; Lo siguiente se ejecuta si ya ha acabado el ajuste de la hora, es decir, pasa a
; funcionamiento normal. En este caso hay que realizar tres operaciones:
;     -	Fijar la interrupci�n INT solo por flanco de bajada.
;     -	Inicializar a cero todos los flags de ajuste contenidos en (FlagsAjuste).
;     -	Escribir el DS1307 con los datos de las variables de tiempo contenidas en la
;	memor�a RAM del microcontrolador.
;
FuncionamientoNormal
	bsf	STATUS,RP0		; Acceso banco 1.
	bcf	OPTION_REG,INTEDG	; Interrupci�n INT activa por flanco de bajada.
	bcf	STATUS,RP0		; Acceso banco 0.
	clrf	FlagsAjuste		; Inicializa los flags de ajuste.
	call	DS1307_Escribe		; Graba los datos en el DS1307.
FinPuestaEnHora
	call	VisualizaReloj		; Visualiza los datos del reloj digital.
	btfss	ModoPulsador		; Ahora espera deje de pulsar.
	goto	FinPuestaEnHora
	return
	
; Subrutina "Incrementar" ---------------------------------------------------------------
;
; Subrutina de atenci�n a la interrupci�n por cambio de la l�nea RB6 al cual se ha
; conectado el pulsador "INCREMENTAR".
;
; Incrementa seg�n corresponda una sola de las siguientes variables: (Anho), (Mes),
; (Dia), (DiaSemana), (Hora) o (Minuto).

Incrementar
	call	Retardo_20ms		; Espera a que se estabilice el nivel de tensi�n.	
	btfsc	IncrementarPulsador		; Si es un rebote sale fuera.
	goto	FinIncrementar
	btfsc	F_AjusteAnho
	call	IncrementaAnhos
	btfsc	F_AjusteMes
	call	IncrementaMeses
	btfsc	F_AjusteDia
	call	IncrementaDias
	btfsc	F_AjusteDiaSemana
	call	IncrementaDiasSemana
	btfsc	F_AjusteHora
	call	IncrementaHoras
	btfsc	F_AjusteMinuto
	call	IncrementaMinutos
	movlw	b'11111111'
	movwf	Intermitencia		; Visualiza siempre mientras incrementa.
	call	VisualizaReloj		; Visualiza mientras espera que deje
	call	Retardo_200ms		; de pulsar.
	btfss	IncrementarPulsador		; Mientras permanezca pulsado
	goto	Incrementar		; incrementar� el d�gito.
FinIncrementar
	return

; Subrutina "IncrementaMinutos" ---------------------------------------------------------
;
; Incrementa el valor de la variable Minutos. Si supera los 0x59, lo resetea.
; Este incremento se debe realizar en BCD para ello utiliza la subrutina AjusteBCD.

IncrementaMinutos
	incf	Minuto,F			; Incrementa los minutos.
	movf	Minuto,W		; Lo pasa a BCD.
	call	AjusteBCD
	movwf	Minuto			; Lo guarda.
	sublw	0x59			; �Ha superado su valor m�ximo?
	btfss	STATUS,C
	clrf	Minuto			; Lo inicializa si ha superado su valor m�ximo.
	return

; Subrutina "IncrementaHoras" -----------------------------------------------------------
;
IncrementaHoras
	incf	Hora,F			; Incrementa las Horas.
	movf	Hora,W			; Ahora hace el ajuste BCD.
	call	AjusteBCD
	movwf	Hora			; Lo guarda.
	sublw	0x23			; �Ha superado su valor m�ximo?
	btfss	STATUS,C
	clrf	Hora			; Lo inicializa si ha superado su valor m�ximo.
	return

; Subrutina "IncrementaDiasSemana" ------------------------------------------------------
;
IncrementaDiasSemana
	incf	DiaSemana,F
	movf	DiaSemana,W
	sublw	.7			; �Ha superado su valor m�ximo?
	btfsc	STATUS,C
	goto	FinIncrementaDiasSemana
	movlw	.1			; Lo inicializa si ha superado su valor m�ximo.
	movwf	DiaSemana
FinIncrementaDiasSemana
	return

; Subrutina "IncrementaDias" ------------------------------------------------------------
;
IncrementaDias
	incf	Dia,F			; Incrementa.
	movf	Dia,W			; Ahora hace el ajuste BCD.
	call	AjusteBCD
	movwf	Dia			; Lo guarda.
	sublw	0x31			; �Ha superado su valor m�ximo?
	btfsc	STATUS,C
	goto	FinIncrementaDias
	movlw	.1			; Lo inicializa si ha superado su valor m�ximo.
	movwf	Dia
FinIncrementaDias
	return

; Subrutina "IncrementaMeses" -----------------------------------------------------------
;
IncrementaMeses
	incf	Mes,F			; Incrementa.
	movf	Mes,W
	call	AjusteBCD		; Ajusta a BCD.
	movwf	Mes			; Lo guarda.
	sublw	0x12			; �Ha superado su valor m�ximo?
	btfsc	STATUS,C
	goto	FinIncrementaMeses
	movlw	.1			; Lo inicializa si ha superado su valor m�ximo.
	movwf	Mes
FinIncrementaMeses
	return

; Subrutina "IncrementaAnhos" ------------------------------------------------------------
;
; Incrementa el valor de la variable (Anhos). Cuando llega a 0x30 (BCD), lo resetea.
; Es decir, llega hasta el a�o 2030, que se ha considerado suficientemente alto.
; Este incremento se debe realizar en BCD para ello utiliza la subrutina AjusteBCD.
;
IncrementaAnhos
	incf	Anho,F			; Incrementa.
	movf	Anho,W			; Ahora hace el ajuste BCD.
	call	AjusteBCD
	movwf	Anho			; Lo guarda.
	sublw	0x30			; �Ha superado su valor m�ximo?.
	btfss	STATUS,C		; Si no llega a su m�ximo sale.
	clrf	Anho			; Lo inicializa si ha superado su valor m�ximo.
	return

; Subrutina "AjusteBCD" -----------------------------------------------------------------
;
; Esta subrutina pasa a BCD el dato de entrada. Para ello detecta si las unidades superan
; el valor "9", en cuyo caso le suman 6 para pasarlo a BCD. Por ejemplo, si previamente
; (Minuto)=0x19, al incrementarle resulta (Minuto)=0x1A que no es un c�digo v�lido BCD, si se
; le suma 6 resulta (Minuto)=0x1A+0x06=0x20 que es un c�digo v�lido BCD.
;
; Entrada:	En (W) el c�digo a convertir
; Salida:	En (W) el c�digo convertido en BCD.
;
AjusteBCD
	movwf	Auxiliar			; Guarda el valor del n�mero a convertir.
	andlw	b'00001111'		; Se queda con su parte baja.
	sublw	.9			; Comprueba si pasa de nueve.
	btfsc	STATUS,C
	goto	NoSuperaNueve
	movlw	.6			; S� lo ha superado, por tanto le suma 6.
	addwf	Auxiliar,F
NoSuperaNueve
	movf	Auxiliar,W		; Retorna el resultado en el registro (W).
	return

	INCLUDE <BUS_I2C.INC>		; Subrutinas de control del bus I2C.
	INCLUDE <DS1307.INC>		; Subrutinas de control del DS1307.
	INCLUDE <RETARDOS.INC>
	INCLUDE <LCD_4BIT.INC>
	INCLUDE <LCD_MENS.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
