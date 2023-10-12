;************************************** LCD_08.asm ************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Mientras se mantenga presionado el pulsador conectado al pin RA4, se incrementa un contador
; visualizado en la pantalla en tres formatos: decimal, hexadecimal y binario. Un ejemplo:
; Primera Línea:	"CE   206"
; Segunda Línea:	"11001110"
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE <P16F84A.INC>

	CBLOCK  0x0C
	Contador			; El contador a visualizar.
	Auxiliar
	Desplaza
	ENDC

#DEFINE  Pulsador PORTA,4		; Línea donde se conecta el pulsador.

; ZONA DE CÓDIGOS ********************************************************************

	ORG	0			; El programa comienza en la dirección 0.
Inicio
	call	LCD_Inicializa
	bsf	STATUS,RP0
	bsf	Pulsador		; Línea del pulsador configurada como entrada. 
	bcf	STATUS,RP0
	clrf	Contador		; Inicializa el contador y
	call	VisualizaContador	; lo visualiza.
Principal
	btfsc	Pulsador		; Lee el pulsador.
	goto	Fin			; Si no pulsa salta a final.
	call	Retardo_20ms		; Espera a que se estabilicen los niveles de tensión.
	btfsc	Pulsador		; Vuelve a leer el pulsador.
	goto	Fin
	incf	Contador,F		; Incrementa el contador.
	call	VisualizaContador
	call	Retardo_200ms		; Se incrementará de nuevo cuando pase este 
Fin	goto	Principal		; tiempo.

; Subrutina "VisualizaContador" --------------------------------------------------------

VisualizaContador
	call	LCD_Borra		; Borra la pantalla.
	movf	Contador,W		; A continuación visualiza el contador.
	call	LCD_ByteCompleto	; Visualiza en hexadecimal.
	call	LCD_TresEspaciosBlancos	; Como separador.
	movf	Contador,W		; Ahora se visualiza en decimal.
	call	BIN_a_BCD		; Primero se convierte a BCD.
	movwf	Auxiliar		; Guarda las decenas y unidades.
	movf	BCD_Centenas,W		; Visualiza centenas.
	call	LCD_Nibble
	movf	Auxiliar,W		; Visualiza las decenas y unidades.
	call	LCD_ByteCompleto
;
	call	LCD_Linea2		; En la segunda línea para visualizar en binario.
	movlw	.8			; Utiliza el registro auxiliar como contador del
	movwf	Auxiliar		; número de bits que se va visualizando por la 
	movf	Contador,W		; pantalla.
	movwf	Desplaza
VisualizaBit
	rlf	Desplaza,F		; El bit a visualizar pasa al Carry .
	movlw	'1'			; En principio supone que es un uno.
	btfss	STATUS,C		; Comprueba su valor.
	movlw	'0'			; Ha sido cero.
	call	LCD_Caracter		; Lo visualiza.
	decfsz	Auxiliar,F		; ¿Ha terminado de visualizar los 8 bits?
	goto	VisualizaBit		; No, sigue visualizando otro bit.
	return

	INCLUDE  <LCD_4BIT.INC>
	INCLUDE  <RETARDOS.INC>
	INCLUDE  <BIN_BCD.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
