;*********************************** Indirecto_02.asm ***********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Este programa comprueba el funcionamiento de la lectura y escritura en la memoria de 
; datos mediante direccionamiento indirecto.
;
; Se trata de escribir, a partir de la última dirección ocupada de memoria RAM de datos
; hasta el final, el contenido con el valor de la dirección. Así, por ejemplo, en la
; dirección 20h se escribe "20", en la dirección 21h se escribe "21", en la dirección 22h
; se escribe "22" y así sucesivamente. Se escribirá hasta la dirección 4Fh que son las
; direcciones implementadas en PIC16F84A.
;
; A continuación se procederá a la lectura de la memoria RAM de datos completa, desde la
; la dirección 00h hasta la 4Fh. En la pantalla se visualizará la dirección y su
; contenido. Observar que direcciones de 00h a 0Bh corresponden al SFR. Cada
; visualización se mantendrá durante medio segundo en pantalla.
;
; En los contadores se carga siempre un valor más, porque la instrucción
; "decfsz RAM_Contador,F" salta cuando es cero y no permite visualizar el contenido del
; último registro.
 
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF  &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK	0x0C
	RAM_Dato			; Dato a escribir o leer.
	RAM_Contador
	ENDC

RAM_UltimaDireccion	EQU	4Fh	; Ultima dirección utilizada.

; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0
Inicio
	call	LCD_Inicializa
	movlw	RAM_PrimeraLibre	; Este es la primer dato a escribir en la RAM.
	movwf	RAM_Dato
	movlw	RAM_UltimaDireccion-RAM_PrimeraLibre+1 ; Número de posiciones a escribir.
	movwf	RAM_Contador
	movlw	RAM_PrimeraLibre
	movwf	FSR			; Primera dirección de memoria RAM a escribir
RAM_Escribe
	movf	RAM_Dato,W		; Escribe el contenido de RAM_Dato en posición
	movwf	INDF			; apuntada por FSR.
	incf	FSR,F			; Apunta a la siguiente dirección de memoria.
	incf	RAM_Dato,F		; Incrementa el dato a cargar.
	decfsz	RAM_Contador,F
	goto	RAM_Escribe
;
; El programa principal procede a leer la RAM desde la dirección 0.
;
Principal
	movlw	RAM_UltimaDireccion+1 	; Número de posiciones a leer.
	movwf	RAM_Contador
	movlw	0			; Primera dirección a leer.
	movwf	FSR
RAM_Lee
	movf	INDF,W			; Lee el contenido de RAM_Dato en posición
	movwf	RAM_Dato		; apuntada por FSR.
	call	VisualizaRAM
	incf	FSR,F			; Apunta a la siguiente dirección de memoria.
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
	movf	FSR,W			; Visualiza el número de la posición
	call	LCD_ByteCompleto
	call	LCD_Linea2
	movlw	MensajeContenido
	call	LCD_Mensaje
	movf	RAM_Dato,W		; Visualiza el contenido de la posición
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

	INCLUDE  <RETARDOS.INC>		; Estos includes también reservan posiciones de
	INCLUDE  <LCD_4BIT.INC>		; memoria RAM. Por tanto la última posición habrá 
	INCLUDE  <LCD_MENS.INC>		; que definirla después de éstos.

	CBLOCK
	RAM_PrimeraLibre		; Ultima posición de RAM ocupada por una variable.
	ENDC

	END

;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
