;**************************************** I2C_DAC_02.asm ******************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; En la salida analógica del PCF8591 que trabaja como DAC se obtiene una tensión seleccionada
; por un pulsador conectado a la línea RB6 del PIC. La tensión varía entre 0,50 y 2,50 V en
; saltos de 0,25 V y se visualiza en el módulo LCD.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK   0x0C
	ENDC

PCF8591_DireccionEscritura	EQU	b'10011110'

#DEFINE   IncrementarPulsador	PORTB,6
;
; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0
	goto	Inicio
	ORG	4
	goto	ServicioInterrupcion

Mensajes
	addwf	PCL,F
MensajeTension
	DT "Tension: ", 0x00
MensajeVoltios
	DT " V.   ", 0x00
Inicio
	call	LCD_Inicializa
	bsf	STATUS,RP0
	bsf	IncrementarPulsador	; Se configura como entrada.
	bcf	STATUS,RP0
	call	CargaInicialContador	; Realiza la carga inicial del contador.
	call	PCF8591_DAC		; Lo envía al DAC para su conversión.
	call	Visualiza			; Y lo visualiza en la pantalla.
	movlw	b'10001000'		; Activa interrupción por cambio en las
	movwf	INTCON			; líneas del Puerto B (RBIE) y la general (GIE).
Principal
	sleep				; Pasa a modo de reposo.
	goto	Principal

; Subrutina "ServicioInterrupcion" ------------------------------------------------------
;
; Incrementa el registro Contador cada vez que se presiona el pulsador "INCREMENTAR".
;
; Como el PCF8591 del esquema trabaja con una resolución de LSB=10mV el valor del (Contador)
; será 10 veces menor que la tensión analógica deseada a la salida expresada en milivoltios.
; Así por ejemplo, si (Contador)=147 el valor de la tensión de salida será igual a:
; VOUT = LSB x Digital = 10 x 147 = 1470 mV = 1,47 V.
;
ServicioInterrupcion
	call	Retardo_20ms		; Espera a que se estabilicen los niveles de tensión.	
	btfsc	IncrementarPulsador	; Si es un rebote sale fuera.
	goto	FinInterrupcion
IncrementarTensionDeseada
	call	IncrementaContador		; Aumenta el valor del contador.
	call	PCF8591_DAC		; Lo envía al DAC para su conversión.
	call	Visualiza			; Visualiza mientras espera que deje
	call	Retardo_100ms		; de pulsar durante este tiempo.
	btfss	IncrementarPulsador	; Mientras permanezca pulsado
	goto	IncrementarTensionDeseada	; incrementará el dígito.
FinInterrupcion
	bcf	INTCON,RBIF
	retfie

; Subrutina "PCF8591_DAC" ---------------------------------------------------------------
;
; Escribe en el PCF8591 con el dato del registro W para su conversión a tensión analógica.

	CBLOCK
	PCF8591_Dato			; Guarda el dato que tiene que enviar.
	ENDC

PCF8591_DAC
	movwf	PCF8591_Dato		; Guarda el dato a enviar.
	call	I2C_EnviaStart		; Envía condición de Start.
	movlw	PCF8591_DireccionEscritura	; Apunta al dispositivo.
	call	I2C_EnviaByte
	movlw	b'01000000'		; Carga la palabra de control activando la 
	call	I2C_EnviaByte		; salida analógica.
	movf	PCF8591_Dato,W		; Escribe el dato dos veces para que la
	call	I2C_EnviaByte		; conversión sea correcta tal como se indica en
	movf	PCF8591_Dato,W		; los cronogramas del fabricante.
	call	I2C_EnviaByte
	call	I2C_EnviaStop		; Termina.
	movf	PCF8591_Dato,W		; En (W) se recupera de nuevo el dato de entrada.
	return

; Subrutinas "IncrementaContador" y "CargaInicialContador" ------------------------------
;
	CBLOCK
	Contador
	ENDC

ValorMinimo	EQU	d'50'		; El valor mínimo de tensión será 0,5 V.
ValorMaximo	EQU	d'250'		; El valor máximo de tensión será 2,5 V.
SaltoIncremento	EQU	d'25'		; El incremento se producirá en saltos de 0,25 V.

IncrementaContador
	movlw	SaltoIncremento		; Incrementa el valor deseado.
	addwf	Contador,F
	btfsc	STATUS,C		; Si se desborda realiza la carga inicial.
	goto	CargaInicialContador
	movf	Contador,W		; ¿Ha llegado a su valor máximo?
	sublw	ValorMaximo		; (W) = ValorMaximo - (Contador).
	btfsc	STATUS,C		; ¿C=0?, ¿(W) negativo?, ¿ValorMaximo<(Contador)?
	goto	FinIncrementar		; No, resulta ValorMaximo>=(Contador) y sale.
CargaInicialContador
	movlw	ValorMinimo		; Sí, entonces inicializa el registro.
	movwf	Contador
FinIncrementar
	movf	Contador,W		; En (W) el resultado.
	return

; Subrutinas "Visualiza" ----------------------------------------------------------------
;
; Visualiza el valor que se le introduce por el registro de trabajo W en formato de tensión.
; Hay que tener en cuenta que el PCF8591 del esquema trabaja con una resolución de LSB=10mV,
; el valor de entrada será 10 veces menor que la tensión real expresada en milivoltios.
; Así por ejemplo, si (W)=147 el valor de la tensión será igual a: VOUT = LSB x Digital =
; = 10 x 147 = 1470 mV = 1,47 V, que es lo que se debe visualizar en la pantalla.
;
; En conclusión:
; - Las centenas del valor de entrada corresponden a las unidades de voltio.
; - Las decenas del valor de entrada corresponden a las décimas de voltio.
; - Las unidades del valor de entrada corresponden a las centésimas de voltios.

	CBLOCK
	Auxiliar
	ENDC

Visualiza
	movwf	Auxiliar			; Lo guarda.
	call	LCD_Linea1		; Se sitúa al principio de la primera línea.
	movlw	MensajeTension		; Visualiza la tensión deseada.
	call	LCD_Mensaje
	movf	Auxiliar,W		; Recupera el dato a visualizar y lo
	call	BIN_a_BCD		; pasa a BCD.
	movf	BCD_Centenas,W		; Visualiza las centenas que corresponden a las
	call	LCD_Nibble		; unidades de voltios.
	movlw	'.'			; Visualiza el punto decimal.
	call	LCD_Caracter
	movf	BCD_Decenas,W		; Visualiza las decenas que corresponden a las
	call	LCD_Nibble		; décimas de voltios.
	movf	BCD_Unidades,W		; Visualiza las unidades que corresponden a las
	call	LCD_Nibble		; centésimas de voltios.
	movlw	MensajeVoltios
	call	LCD_Mensaje
	return
;
	INCLUDE   <BUS_I2C.INC>
	INCLUDE   <RETARDOS.INC>
	INCLUDE   <BIN_BCD.INC>
	INCLUDE   <LCD_4BIT.INC>
	INCLUDE   <LCD_MENS.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
