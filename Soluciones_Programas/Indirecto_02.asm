;*********************************** Indirecto_02.asm ***********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Este programa comprueba el funcionamiento de la lectura y escritura en la memoria de 
; datos mediante direccionamiento indirecto.
;
; Se trata de escribir, a partir de la �ltima direcci�n ocupada de memoria RAM de datos
; hasta el final, el contenido con el valor de la direcci�n. As�, por ejemplo, en la
; direcci�n 20h se escribe "20", en la direcci�n 21h se escribe "21", en la direcci�n 22h
; se escribe "22" y as� sucesivamente. Se escribir� hasta la direcci�n 4Fh que son las
; direcciones implementadas en PIC16F84A.
;
; A continuaci�n se proceder� a la lectura de la memoria RAM de datos completa, desde la
; la direcci�n 00h hasta la 4Fh. En la pantalla se visualizar� la direcci�n y su
; contenido. Observar que direcciones de 00h a 0Bh corresponden al SFR. Cada
; visualizaci�n se mantendr� durante medio segundo en pantalla.
;
; En los contadores se carga siempre un valor m�s, porque la instrucci�n
; "decfsz RAM_Contador,F" salta cuando es cero y no permite visualizar el contenido del
; �ltimo registro.
 
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF  &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK	0x0C
	RAM_Dato			; Dato a escribir o leer.
	RAM_Contador
	ENDC

RAM_UltimaDireccion	EQU	4Fh	; Ultima direcci�n utilizada.

; ZONA DE C�DIGOS ********************************************************************

	ORG 	0
Inicio
	call	LCD_Inicializa
	movlw	RAM_PrimeraLibre	; Este es la primer dato a escribir en la RAM.
	movwf	RAM_Dato
	movlw	RAM_UltimaDireccion-RAM_PrimeraLibre+1 ; N�mero de posiciones a escribir.
	movwf	RAM_Contador
	movlw	RAM_PrimeraLibre
	movwf	FSR			; Primera direcci�n de memoria RAM a escribir
RAM_Escribe
	movf	RAM_Dato,W		; Escribe el contenido de RAM_Dato en posici�n
	movwf	INDF			; apuntada por FSR.
	incf	FSR,F			; Apunta a la siguiente direcci�n de memoria.
	incf	RAM_Dato,F		; Incrementa el dato a cargar.
	decfsz	RAM_Contador,F
	goto	RAM_Escribe
;
; El programa principal procede a leer la RAM desde la direcci�n 0.
;
Principal
	movlw	RAM_UltimaDireccion+1 	; N�mero de posiciones a leer.
	movwf	RAM_Contador
	movlw	0			; Primera direcci�n a leer.
	movwf	FSR
RAM_Lee
	movf	INDF,W			; Lee el contenido de RAM_Dato en posici�n
	movwf	RAM_Dato		; apuntada por FSR.
	call	VisualizaRAM
	incf	FSR,F			; Apunta a la siguiente direcci�n de memoria.
	decfsz	RAM_Contador,F		; Si no ha llegado al final pasa a leer la
	goto	RAM_Lee			; siguiente.
	goto	Principal
;
; Subrutina "VisualizaRAM" --------------------------------------------------------------
;
VisualizaRAM
	call	LCD_Linea1		; Pasa a visualizarla.
	movlw	MensajeDireccion
	call	LCD_Mensaje
	movf	FSR,W			; Visualiza el n�mero de la posici�n
	call	LCD_ByteCompleto
	call	LCD_Linea2
	movlw	MensajeContenido
	call	LCD_Mensaje
	movf	RAM_Dato,W		; Visualiza el contenido de la posici�n
	call	LCD_ByteCompleto
	call	Retardo_500ms
	return

; "Mensajes" ----------------------------------------------------------------------------
;
Mensajes
	addwf	PCL,F
MensajeDireccion
	DT "Direccion: ", 0x00
MensajeContenido
	DT "Contenido: ", 0x00

	INCLUDE  <RETARDOS.INC>		; Estos includes tambi�n reservan posiciones de
	INCLUDE  <LCD_4BIT.INC>		; memoria RAM. Por tanto la �ltima posici�n habr� 
	INCLUDE  <LCD_MENS.INC>		; que definirla despu�s de �stos.

	CBLOCK
	RAM_PrimeraLibre		; Ultima posici�n de RAM ocupada por una variable.
	ENDC

	END

;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
