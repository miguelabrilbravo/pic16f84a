;**************************** Librería "BUS_1LIN.INC" *********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Estas subrutinas permiten realizar las tareas básicas de control del bus de una sola línea
; según el protocolo del fabricante de semiconductores Dallas Semiconductors.
;
; ZONA DE DATOS **********************************************************************

	CBLOCK
	Bus1Linea_Dato			; Guarda dato a transmitir o recibir por el bus.
	Bus1Linea_ContadorBits		; Cuenta los bits a transmitir o a recibir.
	ENDC

#DEFINE  Bus1Linea	PORTB,3		; Línea donde se conecta el DS1820.

; Subrutina "Bus1Linea_AltaImpedancia" --------------------------------------------------
;
; Configura la línea única de 1-Wire Bus como entrada. Lo pone en alta impedancia.

Bus1Linea_AltaImpedancia
	bsf	STATUS,RP0
	bsf	Bus1Linea		; La línea como entrada, por tanto, en alta
	bcf	STATUS,RP0		; impedancia.
	return

; Subrutina "Bus1Linea_Bajo" ------------------------------------------------------------
;
; Mantiene el pin de datos del Bus de 1 línea en bajo.
 
Bus1Linea_Bajo
	bsf	STATUS,RP0
	bcf	Bus1Linea		; La línea como salida.
	bcf	STATUS,RP0
	bcf	Bus1Linea		; Pasa a bajo.
	return

; Subrutina "Bus1Linea_Reset" -----------------------------------------------------------
;
; Envía un impulso de Reset al dispositivo conectado en el bus de 1 línea y después
; espera recibir un impulso de Presence". Esto consiste en:
; 1º.	El PIC manda un impulso en bajo durante unos 500 µs. (El protocolo permite entre 480
;	y 960 µs).
; 2º. 	El PIC pasa a modo entrada, espera 20 µs. (El protocolo fija entre 15 y 60 µs).
; 3º. 	El PIC lee la línea de entrada y si es bajo está correcto (pulso de "Presence").
;	Se interpreta como que el procedimiento está correctamente inicializado.

Bus1Linea_Reset
	call	Bus1Linea_AltaImpedancia	; Empieza en alto para conseguir el flanco de
					; bajada con la siguiente instrucción.
	call	Bus1Linea_Bajo		; El bus de 1 línea en bajo durante 500 µs.
	call	Retardo_500micros
	call	Bus1Linea_AltaImpedancia	; Permanece en alta impedancia (nivel alto por
	call	Retardo_20micros		; las resistencias de Pull-Up) durante unos µs.
Bus1Linea_EsperaLeerBajo
	btfsc	Bus1Linea		; Espera a que el dispositivo le envíe el pulso
	goto	Bus1Linea_EsperaLeerBajo	; en bajo de "Presence".
Bus1Linea_EsperaLeerAlto
	btfss	Bus1Linea		; Y ahora el dispositivo lo debe poner en alto.
	goto	Bus1Linea_EsperaLeerAlto
	return

; Subrutina "Bus1Linea_EscribeByte" -----------------------------------------------------
;
; El maestro escribe un byte al esclavo conectado al bus de 1 línea comenzando por el bit LSB.
; Consiste en enviar 8 bits, repitiendo 8 veces la siguiente secuencia:
; 1º	El PIC manda un impulso en bajo durante unos microsegundos. (El protocolo fija un
;	mínimo de 1 µs y sin exceder con lo que viene a continuación de 60 µs) A continuación:
;	- Si va a enviar un "0" permanece en bajo durante 50 µs.
;	- Si va a escribir un "1" se pone en alta impedancia durante 50 µs. (El protocolo
;	  permite unos valores entre 15 y 60 µs para ambos casos).
; 2º 	Para escribir otro bit se pone en alta impedancia durante unos µs. (El protocolo
;	establece un mínimo de 1 µs).
;
; Entrada:	En (W) el dato a enviar.

Bus1Linea_EscribeByte
	movwf	Bus1Linea_Dato		; Guarda el byte a transmitir.
	movlw	0x08			; 8 bits a transmitir.
	movwf	Bus1Linea_ContadorBits
	call	Bus1Linea_AltaImpedancia	; Empieza en alta impedancia.
Bus1Linea_EnviaBit
	call	Bus1Linea_Bajo		; Flanco de bajada.
;
; Pregunta por el valor del bit a transmitir.
;
	rrf	Bus1Linea_Dato,F		; Lleva el bit de menor peso LSB al Carry. 
	btfss	STATUS,C		; ¿Es un "1" el bit a transmitir?.
	goto	Bus1Linea_EnviaCero	; No, pues envía un "0".	
Bus1Linea_EnviaUno
	call	Bus1Linea_AltaImpedancia	; Transmite un "1".
	goto	Bus1Linea_Espera50us
Bus1Linea_EnviaCero
	call	Bus1Linea_Bajo		; Transmite un "0".
Bus1Linea_Espera50us
	call	Retardo_50micros
	call	Bus1Linea_AltaImpedancia	; Flanco de subida.
	decfsz	Bus1Linea_ContadorBits,1	; Comprueba que es el último bit.
	goto	Bus1Linea_EnviaBit	; Como no es el último bit repite la operación.
	return
;
; Subrutina "Bus1Linea_LeeByte" ---------------------------------------------------------
;
; El microcontrolador maestro lee un byte del dispositivo esclavo conectado al bus de
; 1 línea. Consiste en leer 8 bits, repitiendo 8 veces la siguiente secuencia:
; 1º	El PIC manda un pulso en bajo durante unos µs. (El protocolo fija un mínimo de 1 µs).
; 2º 	El PIC se pone en entrada (alta impedancia) durante otros 10 µs (con un total de 15 µs
;	desde el flanco de bajada) para proceder a la lectura de la línea.
; 3º	El PIC espera 50 µs para realizar la siguiente lectura (total unos 65 µs desde el
;	flanco de bajada). El protocolo fija que las lecturas se harán cada 60 µs ó más.
;
; Salida:	En (W) el dato leído.

Bus1Linea_LeeByte
	movlw	0x08			; 8 bits a recibir.
	movwf	Bus1Linea_ContadorBits
	call	Bus1Linea_AltaImpedancia	; Empieza en alta impedancia.
Bus1Linea_LeeBit
	call	Bus1Linea_Bajo		; Flanco de bajada.
	call	Bus1Linea_AltaImpedancia
	call	Retardo_10micros		; Añadiendo las instrucciones anteriores, supone
					; un total de 15 µs desde el flanco de bajada.
	bcf	STATUS,C		; Ahora lee el pin. En principio supone que es 0.
	btfsc	Bus1Linea		; ¿Realmente es cero?.
	bsf	STATUS,C		; No, pues cambia a uno.
	rrf	Bus1Linea_Dato,1		; Introduce el bit en el registro.
	call	Retardo_50micros		; Espera.
	call	Bus1Linea_AltaImpedancia	; Flanco de subida del pulso positivo.
	decfsz 	Bus1Linea_ContadorBits,1	; Comprueba que es el último bit.
	goto	Bus1Linea_LeeBit		; Si no es el último bit pasa a leer el siguiente.
	movf	Bus1Linea_Dato,W		; El resultado en el registro W.
	return
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
