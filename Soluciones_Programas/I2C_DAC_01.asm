;**************************************** I2C_DAC_01.asm ******************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; En la salida anal�gica del PCF8591 est� conectado un diodo LED en serie con una resistencia
; de unos 100 ohmios. Desde la posici�n de apagado, el LED comienza a encenderse
; paulatinamente hasta llegar a su luminosidad m�xima, alcanzada la cual volver� a apagarse
; repitiendo el ciclo.
;
; Para ello, la tensi�n en la salida comienza en 1500 mV (1,5 V), que es el nivel de umbral de
; luminosidad del LED, asciende en pasos de 10 mV hasta alcanzar 2500 mV (2,5 V) para volver
; a caer a 1,5 V y repetir el ciclo.
;
; En cada paso estar� unos 50 ms. El total de cada ciclo durar� pues unos 5 segundos ya que
; de 1500 a 2500 hay 100 pasos de 10 mV, multiplicado por los 50 ms que dura cada paso
; resulta 5000 ms en total.
;
; El DAC va a utilizar un contador auxiliar que contiene el valor digital a convertir. Se
; incrementa cada vez que ejecuta la subrutina principal, desde 150 hasta 250 y repite el ciclo.
;
; Como el PCF8591 del esquema trabaja con una resoluci�n de LSB=10mV, el valor del contador
; ser� 10 veces menor que la tensi�n anal�gica deseada a la salida expresada en milivoltios.
; As� por ejemplo, si (Contador)=147 el valor de la tensi�n de salida ser� igual a:
; VOUT = LSB x Digital = 10 x 147 = 1470 mV = 1,47 V.
;
; Por tanto, como (Contador) var�a de 150 a 250 en pasos de 1, la tensi�n anal�gica de salida
; var�a desde 1500 mV (1,50 V) hasta 2500 mV (2,50 V) en pasos de 10 mV (0,01 V),  produciendo
; un aumento paulatino de la tensi�n en la salida anal�gica y de la luminosidad del LED.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK   0x0C
	ENDC

PCF8591_DireccionEscritura	EQU	b'10011110'

; ZONA DE C�DIGOS ********************************************************************

	ORG 	0
Inicio
	call	CargaInicialContador
	call	I2C_EnviaStart		; Envia condici�n de Start.
	movlw	PCF8591_DireccionEscritura	; Apunta al dispositivo.
	call	I2C_EnviaByte
	movlw	b'01000000'		; Carga la palabra de control activando la 
	call	I2C_EnviaByte		; salida anal�gica.
Principal
	call	IncrementaContador
	call	I2C_EnviaByte		; Convierte el dato d�gital de entrada a tensi�n
	call	Retardo_50ms		; anal�gica presente en el pin AOUT.
	goto	Principal

; Subrutina "IncrementaContador" --------------------------------------------------------

	CBLOCK
	Contador
	ENDC

ValorMinimo	EQU	.150
ValorMaximo	EQU	.250
SaltoIncremento	EQU	.1

IncrementaContador
	movlw	SaltoIncremento		; Incrementa el valor deseado.
	addwf	Contador,F
	btfsc	STATUS,C		; Si se desborda realiza la carga inicial.
	goto	CargaInicialContador
	movf	Contador,W		; �Ha llegado a su valor m�ximo?
	sublw	ValorMaximo		; (W) = ValorMaximo - (Contador)
	btfsc	STATUS,C		; �C=0?, �(W) negativo?, �ValorMaximo<(Contador)?
	goto	FinIncrementar		; No, resulta ValorMaximo>=(Contador) y sale.
CargaInicialContador
	movlw	ValorMinimo		; S�, entonces inicializa el registro.
	movwf	Contador
FinIncrementar
	movf	Contador,W		; El resultado en (W).
	return

	INCLUDE   <BUS_I2C.INC>
	INCLUDE   <RETARDOS.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
