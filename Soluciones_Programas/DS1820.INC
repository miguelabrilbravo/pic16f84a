;**************************** Librería "DS1820.INC" ***********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Estas subrutinas permiten realizar las tareas de manejo del sensor de temperatura DS1820.
; Este sensor transmite la información vía serie a través de un 1-Wire Bus.
;
; ZONA DE DATOS **********************************************************************

	CBLOCK
	DS1820_Temperatura			; Primer byte leído del termómetro DS1820.
	DS1820_TemperaturaSigno			; Segundo byte leído del termómetro DS1820.
	DS1820_TemperaturaDecimal		; Parte decimal de la temperatura medida.
	ENDC

DS1820_Skip_ROM_Command	EQU	0xCC	; Comandos del DS1820.
DS1820_Read_Scratchpad_Command	EQU	0xBE
DS1820_Convert_T_Command	EQU	0x44
;
; Subrutina "DS1820_Inicializa" ---------------------------------------------------------
;
; Inicializa el DS1820 para que comience la conversión de temperatura.
;
DS1820_Inicializa
	call	Bus1Linea_Reset		; Primero los pulsos de Reset y Presence.
	movlw	DS1820_Skip_ROM_Command ; Salta los comandos de ROM ya que hay
	call	Bus1Linea_EscribeByte	; conectado un único dispositivo al bus.
	movlw	DS1820_Convert_T_Command ; Para que comience la conversión de temperatura.
	call	Bus1Linea_EscribeByte
	return

; Subrutina "DS1820_LeeTemperatura" -----------------------------------------------------
;
; El DS1820 lee la temperatura en un formato ejemplarizado como sigue:
;
; +125,0 ºC	00000000 11111010
; + 25,5 ºC	00000000 00110011
; + 25,0 ºC	00000000 00110010
; +  0,5 ºC	00000000 00000001
; +  0,0 ºC	00000000 00000000
; -  0,5 ºC	11111111 11111111
; - 25,0 ºC	11111111 11001110
; - 55,0 ºC	11111111 10010010
;
; Se observa que:
;     -	El formato es de dos bytes. El primer byte es el de signo.
;     -	Las temperaturas positivas comienzan con 1 byte todo a cero: "00000000 xxxxxxxx".
;     -	Las temperaturas negativas comienzan con 1 byte todo a uno : "11111111 xxxxxxxx".
;     -	Las temperaturas "xx.0 ºC" terminan en cero: "xxxxxxx0".
;     -	Las temperaturas "xx.5 ºC" terminan en uno : "xxxxxxx1".
;     -	El valor de la temperatura está contenido en los 7 bits de mayor peso del byte bajo.
;	Por ejemplo: +25ºC = xxxxxxxx 0011001x = 25 en decimal. Por tanto, para obtener el
;	valor de la temperatura habrá que desplazar un lugar hacia la derecha los bits del
;	byte bajo.
;     -	Las temperaturas negativas vienen dadas en complemento a 2. Por tanto para obtener
;	su valor absoluto habrá que negarlas.
;
; Esta subrutina lee la temperatura proporcionando tres datos: 
;
; Salida:	- En el registro DS1820_Temperatura, el valor de la temperatura en valor absoluto.
;	- En el registro DS1820_TemperaturaDecimal, la parte decimal del valor de la temperatura.
;	- En (DS1820_TemperaturaSigno)=b'11111111' si la temperatura es negativa y
;	  (DS1820_TemperaturaSigno)=b'00000000' si es positiva.
;
DS1820_LeeTemperatura
	call	Bus1Linea_Reset		; Primero los pulsos de "Reset" y "Presence".
	movlw	DS1820_Skip_ROM_Command ; Salta los comandos de ROM ya que hay
	call	Bus1Linea_EscribeByte	; conectado un único dispositivo al bus.
	movlw	DS1820_Read_Scratchpad_Command ; Va a leer la primera posición de memoria,
	call	Bus1Linea_EscribeByte	; donde se localiza el valor de la temperatura.
	call	Bus1Linea_LeeByte		; Lee la temperatura en 
	movwf	DS1820_Temperatura	; complemento a 2.
	call	Bus1Linea_LeeByte		; Ahora lee el segundo byte que indica el signo
	movwf	DS1820_TemperaturaSigno	; de la temperatura.
	call	Bus1Linea_Reset		; Y para terminar, resetea el dispositivo.
;
; Ahora deduce si la temperatura es positiva o negativa y halla su valor absoluto.
;
	btfss	DS1820_TemperaturaSigno,7	; Si cualquier bit es "1": temperatura negativa.
	goto	DS1820_FinLeeTemperatura	; La temperatura es positiva y salta.
DS1820_TemperaturaNegativa
	movf	DS1820_Temperatura,W	; La niega para convertirla a su valor
	sublw	0x00			; absoluto. Para ello, simplemente le resta de
	movwf	DS1820_Temperatura	; cero.
DS1820_FinLeeTemperatura
	bcf	STATUS,C		; Para no corromper luego el MSB.
	rrf	DS1820_Temperatura,F	; Obtiene el valor absoluto de la temperatura.
	movlw	.5
	btfss	STATUS,C		; Si el bit LSB es "1", la temperatura
	clrw				; medida es "xx.5ºC" sino "xx.0ºC".
	movwf	DS1820_TemperaturaDecimal
	movf	DS1820_Temperatura,W	; En (W) la parte entera del valor absoluto de la
	return				; temperatura.
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
