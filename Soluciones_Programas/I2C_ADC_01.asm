;**************************************** I2C_ADC_01.asm ******************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; El microcontrolador lee constantemente la entrada anal�gica ANI0 del PCF8591 y
; visualiza la tensi�n en la pantalla del m�dulo LCD.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK   0x0C
	ENDC

PCF8591_DireccionEscritura	EQU	b'10011110'
PCF8591_DireccionLectura	EQU	b'10011111'
;
; ZONA DE C�DIGOS ********************************************************************

	ORG	0
Inicio
	call	LCD_Inicializa
	call	I2C_EnviaStart		; Va a configurar el PCF8591.
	movlw	PCF8591_DireccionEscritura	; Apunta al dispositivo.
	call	I2C_EnviaByte
	movlw	b'00000000'		; Carga la palabra de control utilizando la 
	call	I2C_EnviaByte		; entrada AIN0 en modo simple.
	call	I2C_EnviaStop		; Termina la configuraci�n
;
	call	I2C_EnviaStart		; Comienza a leer.
	movlw	PCF8591_DireccionLectura	; Apunta al dispositivo.
	call	I2C_EnviaByte
	call	I2C_LeeByte		; La primera lectura es incorrecta y por lo tanto
Principal				; la desecha.
	call	I2C_LeeByte		; Lee la entrada anal�gica.
	call	Visualiza			; La visualiza.
	goto	Principal

; Subrutinas "Visualiza" ----------------------------------------------------------------
;
; Visualiza el valor que se le introduce por el registro de trabajo W en formato de tensi�n.
; Hay que tener en cuenta que el PCF8591 del esquema trabaja con una resoluci�n de
; LSB=10mV, el valor de entrada ser� 10 veces menor que la tensi�n real expresada en
; milivoltios. As� por ejemplo, si (W)=147 el valor de la tensi�n ser� igual a:
; VAIN = LSB x Digital = 10 x 147 = 1470 mV = 1,47 V, que es lo que se debe visualizar
; en la pantalla.
;
; En conclusi�n:
; - Las centenas del valor de entrada corresponden a las unidades de voltio.
; - Las decenas del valor de entrada corresponden a las d�cimas de voltio.
; - Las unidades del valor de entrada corresponden a las cent�simas de voltios.

	CBLOCK
	Auxiliar
	ENDC

Visualiza
	movwf	Auxiliar			; Lo guarda.
	call	LCD_Linea1		; Se sit�a al principio de la primera l�nea.
	movlw	MensajeTension		; Visualiza la tensi�n deseada.
	call	LCD_Mensaje
	movf	Auxiliar,W		; Recupera el dato a visualizar y lo
	call	BIN_a_BCD		; pasa a BCD.
	movf	BCD_Centenas,W		; Visualiza las centenas que corresponden a las
	call	LCD_Nibble		; unidades de voltios.
	movlw	'.'			; Visualiza el punto decimal.
	call	LCD_Caracter
	movf	BCD_Decenas,W		; Visualiza las decenas que corresponden a las
	call	LCD_Nibble		; d�cimas de voltios.
	movf	BCD_Unidades,W		; Visualiza las unidades que corresponden a las
	call	LCD_Nibble		; cent�simas de voltios.
	movlw	MensajeVoltios
	call	LCD_Mensaje
	return
	
Mensajes
	addwf	PCL,F
MensajeTension
	DT "Tension: ", 0x00
MensajeVoltios
	DT " V.   ", 0x00	

	INCLUDE  <BUS_I2C.INC>
	INCLUDE  <RETARDOS.INC>
	INCLUDE  <BIN_BCD.INC>
	INCLUDE  <LCD_4BIT.INC>
	INCLUDE  <LCD_MENS.INC>
	END

;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
