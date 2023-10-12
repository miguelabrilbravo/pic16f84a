;************************************** Teclado_09.asm **********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Cerradura Electr�nica: la salida se activa cuando una clave de varios digitos introducida
; por teclado sea correcta. El esquema se describe en la figura 19-7.
;
; Tiene una salida "CerraduraSalida" que, cuando se habilita, activa durante unos segundos
; el electroim�n de la cerradura permitiendo la apertura de la puerta:
;   - Si (CerraduraSalida) = 1, la puerta se puede abrir.
;   - Si (CerraduraSalida) = 0, la puerta no se puede abrir.
;
;Funcionamiento:
; - En pantalla visualiza "Introduzca CLAVE". Seg�n se va escribiendo, visualiza asteriscos '*'.
; - Cuando termine de escribir la clave pueden darse dos posibilidades:
;     -	Si la clave es incorrecta la cerradura sigue inactivada, en pantalla aparece el mensaje
;	"Clave INCORRECTA" durante unos segundos y tiene que repetir de nuevo el proceso.
;     -	Si la clave es correcta la cerradura se activa durante unos segundos y la puerta
;	puede ser abierta. En pantalla aparece: "Clave CORRECTA" (primera l�nea) y "Abra
;	la puerta" (segunda l�nea). Pasados unos segundos, se repite el proceso.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	ENDC

; La clave puede tener cualquier tama�o y su longitud se calcula:

#DEFINE  LongitudClave	(FinClaveSecreta-ClaveSecreta)
#DEFINE  CerraduraSalida	PORTA,3

; ZONA DE C�DIGOS ********************************************************************

	ORG	0
	goto 	Inicio
	ORG	4
	goto	ServicioInterrupcion

Mensajes
	addwf	PCL,F
MensajeTeclee
	DT	"Teclee CLAVE:", 0x00
MensajeClaveCorrecta
	DT	"Clave CORRECTA", 0x00
MensajeAbraPuerta
	DT	"Abra la puerta", 0x00
MensajeClaveIncorrecta
	DT	"Clave INCORRECTA", 0x00
;
LeeClaveSecreta
	addwf	PCL,F
ClaveSecreta
	DT	4h,5h,6h,0Eh		; Ejemplo de clave secreta.
	DT	7h,8h
FinClaveSecreta

Inicio	call	LCD_Inicializa
	bsf	STATUS,RP0
	bcf	CerraduraSalida		; Define como salida.
	bcf	STATUS,RP0
	call	Teclado_Inicializa		; Configura las l�neas del teclado.
	call	InicializaTodo		; Inicializa el resto de los registros.
	movlw	b'10001000'		; Habilita la interrupci�n RBI y la general.
	movwf	INTCON
Principal
	sleep				; Espera en modo bajo consumo que pulse alguna tecla.
	goto	Principal

; Subrutina "ServicioInterrupcion" ------------------------------------------------------
;
	CBLOCK
	ContadorCaracteres
	GuardaClaveTecleada
	ENDC

ServicioInterrupcion
	call	Teclado_LeeHex		; Obtiene el valor hexadecimal de la tecla pulsada.
;
; Seg�n va introduciendo los d�gitos de la clave, estos van siendo almacenados a partir de
; las posiciones RAM "ClaveTecleada" mediante direccionamiento indirecto y utilizando el 
; FSR como apuntador. Por cada d�gito le�do en pantalla se visualiza un asterisco.
;
	movwf	INDF			; Almacena ese d�gito en memoria RAM con
					; con direccionamiento indirecto apuntado por FSR.
	movlw	'*'			; Visualiza asterisco.
	call	LCD_Caracter
	incf	FSR,F			; Apunta a la pr�xima posici�n de RAM.
	incf	ContadorCaracteres,F	; Cuenta el n�mero de teclas pulsadas.
	movlw	LongitudClave		; Comprueba si ha introducido tantos caracteres
	subwf	ContadorCaracteres,W	; como longitud tiene la clave secreta.
	btfss	STATUS,C		; �Ha terminado de introducir caracteres?
	goto	FinInterrupcion		; No, pues lee el siguiente car�cter tecleado.
;
; Si ha llegado aqu� es porque ha terminado de introducir el m�ximo de d�gitos. Ahora
; procede a comprobar si la clave es correcta. Para ello va comparando cada uno de los
; d�gitos almacenados en las posiciones RAM a partir de "ClaveTecleada" con el valor
; correcto de la clave almacenado en la posici�n ROM "ClaveSecreta".
;
; Para acceder a las posiciones de memoria RAM a partir de "ClaveTecleada" utiliza
; direccionamiento indirecto siendo FSR el apuntador.
;
; Para acceder a memoria ROM "ClaveSecreta" se utiliza direccionamiento indexado con el
; el registro ContadorCaracteres como apuntador.
;
	call	LCD_Borra		; Borra la pantalla.
	clrf	ContadorCaracteres		; Va a leer el primer car�cter almacenado en ROM.
	movlw	ClaveTecleada		; Apunta a la primera posici�n de RAM donde se ha
	movwf	FSR			; guardado la clave tecleada.
ComparaClaves
	movf	INDF,W			; Lee la clave tecleada y guardada en RAM.
	movwf	GuardaClaveTecleada	; La guarda para compararla despu�s.
	movf	ContadorCaracteres,W	; Apunta al car�cter de ROM a leer.
	call	LeeClaveSecreta		; En (W) el car�cter de la clave secreta.
	subwf	GuardaClaveTecleada,W	; Se comparan.
	btfss	STATUS,Z		; �Son iguales?, �Z=1?
	goto	ClaveIncorrecta		; No, pues la clave tecleada es incorrecta.
	incf	FSR,F			; Apunta a la pr�xima posici�n de RAM.
	incf	ContadorCaracteres,F	; Apunta a la pr�xima posici�n de ROM.
	movlw	LongitudClave		; Comprueba si ha comparado tantos caracteres
	subwf	ContadorCaracteres,W	; como longitud tiene la clave secreta.
	btfss	STATUS,C		; �Ha terminado de comparar caracteres?
	goto	ComparaClaves		; No, pues compara el siguiente car�cter.
ClaveCorrecta				; La clave ha sido correcta. Aparecen los mensajes
	movlw	MensajeClaveCorrecta	; correspondientes y permite la apertura de la
	call	LCD_Mensaje		; puerta durante unos segundos.
	call	LCD_Linea2
	movlw	MensajeAbraPuerta
	call	LCD_Mensaje
	bsf	CerraduraSalida		; Activa la cerradura durante unos segundos.
	goto	Retardo
ClaveIncorrecta
	movlw	MensajeClaveIncorrecta
	call	LCD_Mensaje
Retardo
	call	Retardo_2s
	call	Retardo_1s
InicializaTodo
	bcf	CerraduraSalida		; Desactiva la cerradura.
	clrf	ContadorCaracteres		; Inicializa este contador.
	movlw	ClaveTecleada		; FSR apunta a la primera direcci�n de la RAM
	movwf	FSR			; donde se va a almacenar la clave tecleada.
	call	LCD_Borra		; Borra la pantalla.
	movlw	MensajeTeclee		; Aparece el mensaje para que introduzca la clave. 
	call	LCD_Mensaje
	call	LCD_Linea2		; Los asteriscos se visualizan en la segunda l�nea.
FinInterrupcion
	call	Teclado_EsperaDejePulsar
	bcf	INTCON,RBIF
	retfie	

	INCLUDE  <TECLADO.INC>
	INCLUDE  <LCD_4BIT.INC>
	INCLUDE  <LCD_MENS.INC>
	INCLUDE  <RETARDOS.INC>

; Las posiciones de memoria RAM donde se guardar� la clave le�da se definen al final, despu�s
; de los Includes, ya que van a ocupar varias posiciones de memoria mediante el 
; direccionamiento indirecto utilizado.

	CBLOCK
	ClaveTecleada
	ENDC

	END				; Fin del programa.
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
