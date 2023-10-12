;***************************** Librería "RS232.INC" *************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Estas subrutinas permiten realizar las tareas básicas de control de la transmisión
; seríe asincrona según normas RS-232.
;
; Los parámetros adoptados para la comunicación son los siguientes:
; - Velocidad de transmisión de 9600 baudios. La duración de cada bit será 104 µs.
; - Un bit de inicio o Start a nivel bajo.
; - Dato de 8 bits.
; - Sin paridad.
; - Dos bits de final o Stop a nivel alto.
;
; El tiempo entre bit y bit  debe coincidir con el periodo de la señal leída o enviada.
; Como la velocidad de transmisión o recepción es de 9600 baudios, el periodo será:
; 1/9600 Baudios = 104 µs. Se utilizará pues la subrutina Retardos_100micros.

	CBLOCK
	RS232_ContadorBits
	RS232_Dato
	ENDC

#DEFINE  RS232_Entrada	PORTA,3		; Línea por la que se reciben los datos.
#DEFINE  RS232_Salida	PORTA,4		; Línea por la que se envían los datos.
;
; Subrutina "RS232_Inicializa" -------------------------------------------------------------
;
; Configura las líneas de salida y entrada del microcontrolador.

RS232_Inicializa
	bsf	STATUS,RP0
	bsf	RS232_Entrada		; Esta línea se configura como entrada.
	bcf	RS232_Salida		; Esta línea se configura como salida.
	bcf	STATUS,RP0
	return

; Subrutina "RS232_LeeDato" -------------------------------------------------------------
;
; El microcontrolador lee el dato por la línea de entrada comenzando por el bit de menor
; peso. El dato leído se envía finalmente en el registro de trabajo W.
;
; El ordenador parte siempre de un nivel alto, que es el estado que tiene cuando no 
; envía información. La secuencia utilizada es:
; 1º 	Espera que se ejecute el pulso negativo del bit Start o flanco de bajada.
; 2º	Deja pasar un tiempo una y media veces mayor que el periodo de transmisión para
;	saltarse el bit de Start y lee el primer bit en su mitad.
; 3º	Lee el resto de los bits de datos, esperando un tiempo igual a la duración del
;	periodo entre lectura y lectura para testearlos en mitad del bit.
;
; Salida: En el registro de trabajo W el byte leído.

RS232_LeeDato
	movlw	d'8'			; Número de bits a recibir.
	movwf	RS232_ContadorBits
RS232_EsperaBitStart
	btfsc	RS232_Entrada 		; Lee la entrada y espera a que sea "0".
	goto	RS232_EsperaBitStart	; No, pues espera el nivel bajo.
	call 	Retardo_100micros		; El primer bit debe leerlo un tiempo igual a una
	call 	Retardo_50micros 		; vez y media el periodo de transmisión.
RS232_LeeBit
	bcf	STATUS,C		; Ahora lee el pin. En principio supone que es 0.
	btfsc	RS232_Entrada		; ¿Realmente es cero?
	bsf	STATUS,C		; No, pues cambia a "1".
	rrf	RS232_Dato,F		; Introduce el bit en el registro de lectura.
	call	Retardo_100micros		; Los siguientes bits los lee un periodo más tarde.
	decfsz 	RS232_ContadorBits,F	; Comprueba que es el último bit.
	goto	RS232_LeeBit		; Si no es el último bit pasa a leer el siguiente.
	call	Retardo_200micros		; Espera un tiempo igual al los 2 bits de Stop.
	movf	RS232_Dato,W		; El resultado en el registro W.
	return	

; Subrutinas "RS232_EnviaDato" y "RS232_EnviaNúmero" -------------------------------------
;
; El microcontrolador envía un dato por la línea de salida comenzando por el bit de menor
; peso. En dato enviado será el que le llegue a través del registro de trabajo W.
; 1º.	Envía un "0" durante un tiempo igual al periodo de la velocidad de transmisión.
;	Este es el bit de "Start".
; 2º.	Envía el bit correspondiente:
; 	- Si va a enviar un "0" permanece en bajo durante el periodo correspondiente.
;	- Si va a escribir un "1" permanece en alto durante el periodo correspondiente.
; 3º.	Envía dos bits "1" durante un tiempo igual al período de la velocidad de 
;	transmisión cada uno. Estos son los dos bits de Stop.
;
; Entrada:	En (W) el dato a enviar.

RS232_EnviaNumero			; Envía el código ASCII de un número.
	addlw	'0'			; Lo pasa a código ASCII sumándole el ASCII del 0.
RS232_EnviaDato
	movwf	RS232_Dato		; Guarda el contenido del byte a transmitir.
	movlw	d'8'			; Este es el número de bits a transmitir.
	movwf	RS232_ContadorBits
	bcf	RS232_Salida		; Bit de Start.
	call	Retardo_100micros
RS232_EnviaBit				; Comienza a enviar datos.
	rrf	RS232_Dato,F		; Lleva el bit que se quiere enviar al Carry para
	btfss	STATUS,C		; deducir su valor. ¿Es un "1" el bit a transmitir?
	goto	RS232_EnviaCero		; No, pues envía un "0".
RS232_EnviaUno
	bsf	RS232_Salida		; Transmite un "1".
	goto	RS232_FinEnviaBit
RS232_EnviaCero
	bcf	RS232_Salida		; Transmite un "0".
RS232_FinEnviaBit
	call	Retardo_100micros		; Este es el tiempo que estará en alto o bajo.
	decfsz 	RS232_ContadorBits,F	; Comprueba que es el último bit.
	goto	RS232_EnviaBit		; Como no es el último bit repite la operación.
	bsf	RS232_Salida		; Envía dos bits de Stop.
	call	Retardo_200micros
	return
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
