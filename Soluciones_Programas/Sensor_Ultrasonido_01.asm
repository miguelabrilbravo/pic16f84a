;********************************** Sensor_ Ultrasonido_01.asm **************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Programa para un medidor de distancias hasta un objeto utilizando sensor por ultrasonido SRF04.
;
; Para el control del sensor en primer lugar se genera un  pulso de 10 µs a nivel alto por la
; línea RA3 que se conecta a la entrada de disparo del sensor. Seguidamente se espera a que en el
; sensor se ponga un nivel alto en la salida ECO que se conecta a la línea RA4 y se utilizan las
; interrupciones por desbordamiento del Timer 0 para medir el tiempo que está en alto el pulso.
; Seguidamente se visualiza en el módulo LCD el valor de la distancia hasta el objeto expresada en
; centímetros.
;
; Por cada centímetro de distancia al objeto el SRF04 aumenta 60 µs la anchura del pulso.
; En este programa la distancia mínima es 3 cm y la máxima 250 cm.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	Distancia				; Se expresará en centímetros.
	ENDC

#DEFINE  Disparo	PORTA,3			; Disparo para iniciar la medida.
#DEFINE  Eco		PORTA,4		; Pulso cuya anchura hay que medir.

MinimaDistancia	EQU	.3
MaximaDistancia	EQU	.250
TMR0_Carga60micros	EQU	-d'27'	; Valor obtenido experimentalmente con la
					; ventana Stopwatch para una interrupción del
; Timer 0 cada 60 µs.  Si no mide correctamente por las tolerancias de los componentes habrá
; que hacer un ajuste fino de este valor, comprobándolo sobre las condiciones reales.
;
; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0
	goto	Inicio
	ORG	4
	goto	ServicioInterrupcion

Mensajes
	addwf	PCL,F
MensajeDistancia
	DT "   Distancia: ", 0x00
MensajeCentimetro
	DT " cm", 0x00
MensajeDistanciaMenor
	DT "Dist. MENOR de:", 0x00
MensajeDistanciaMayor
	DT "Dist. MAYOR de:", 0x00
Inicio
	call	LCD_Inicializa
	bsf	STATUS,RP0
	bcf	Disparo
	bsf	Eco
	movlw	b'00000000'		; Prescaler de 2 para el TMR0.
	movwf	OPTION_REG
	bcf	STATUS,RP0
	bcf	Disparo			; Inicializa línea de disparo en bajo.
Principal
	clrf	Distancia			; Inicializa el registro.
	bsf	Disparo			; Comienza el pulso de disparo.
	call	Retardo_20micros		; Duración del pulso.
	bcf	Disparo			; Final del pulso de disparo.
Espera_Eco_1
	btfss	Eco			; Si ECO=0, espera el flanco de subida de la señal
	goto	Espera_Eco_1		; de salida del sensor.
	movlw	TMR0_Carga60micros	; Ya se ha producido el flanco de subida.
	movwf	TMR0			; Carga el Timer 0.
	movlw	b'10100000'		; Autoriza interrupción del TMR0 (T0IE).
	movwf	INTCON
Espera_Eco_0
	btfsc	Eco			; Espera flanco de bajada de la señal de la salida
	goto	Espera_Eco_0		; del SRF04.
	clrf	INTCON			; Se ha producido el flanco de bajada. Prohíbe interrup.
	call	Visualiza			; Visualiza la distancia.
	call	Retardo_2s		; Espera un tiempo hasta la próxima medida.
Fin	goto	Principal
	
; Subrutina "ServicioInterrupcion" ------------------------------------------------------
;
; Se ejecuta debido a la petición de interrupción del Timer 0 cada 60 µs que es el incremento
; de la anchura de pulso por centímetro de distancia medido. La variable "Distancia" contiene el
; valor de la distancia expresada en centímetros.
;
ServicioInterrupcion
  	movlw	TMR0_Carga60micros	; Carga el Timer 0.
	movwf	TMR0
	movlw	.1			; Se utiliza instrucción "addwf", en lugar de "incf"
	addwf	Distancia,F		; para posicionar flag de Carry.
	movlw	MaximaDistancia		; En caso de desbordamiento carga su máximo valor.
	btfsc	STATUS,C
	movwf	Distancia
	bcf	INTCON,T0IF
	retfie

; Subrutina "Visualiza" -----------------------------------------------------------------
;
; Visualiza la distancia expresada en centímetros. Se hace de manera que cuando haya que
; visualizar un número mayor de 99 las decenas siempre se visualicen aunque sean cero.
; Y cuando sea menor de 99 las decenas no se visualicen si es cero.
;
; Si la distancia es menor de 3 cm o mayor de 250 cm aparece un mensaje de error.
;
Visualiza
	call	LCD_Borra		; Borra la pantalla anterior.
	movlw	MinimaDistancia		; Va a comprobar si es menor del mínimo admisible.
	subwf	Distancia,W		; (W)=(Distancia)-MinimaDistancia
	btfss	STATUS,C		; ¿C=1?, ¿(W) positivo?, ¿(Distancia)>=MinimaDistancia?
	goto	DistanciaMenor		; No ha resultado menor, y salta al mensaje de error.
	movf	Distancia,W		; Va a comprobar si es mayor del máximo admisible.
	sublw	MaximaDistancia		; (W)=MaximaDistancia-(Distancia)
	btfsc	STATUS,C		; ¿C=0?, ¿(W) negativo?, ¿MaximaDistancia<(Distancia)?
	goto	DistanciaFiable		; No, la medida de la distancia entra dentro del rango.
;
DistanciaMayor
	movlw	MaximaDistancia		; La distancia es mayor que el máximo.
	movwf	Distancia
	movlw	MensajeDistanciaMayor
	goto	VisualizaDistancia
;
DistanciaMenor
	movlw	MinimaDistancia		; La distancia es menor del mínimo fiable.
	movwf	Distancia
	movlw	MensajeDistanciaMenor
	goto	VisualizaDistancia
DistanciaFiable
	movlw	MensajeDistancia
VisualizaDistancia
	call	LCD_Mensaje
	movlw	.5			; Centra la medida de la distancia en la segunda línea 
	call	LCD_PosicionLinea2	; de la pantalla.
	movf	Distancia,W
	call	BIN_a_BCD		; Lo pasa a BCD.
	movf	BCD_Centenas,W		; Primero las centenas.
	btfss	STATUS,Z		; Si son cero no visualiza las centenas.
	goto	VisualizaCentenas
	movf	Distancia,W		; Vuelve a recuperar este valor.
	call	BIN_a_BCD		; Lo pasa a BCD.
	call	LCD_Byte		; Visualiza las decenas y unidades.
	goto	Visualiza_cm
VisualizaCentenas
	call	LCD_Nibble		; Visualiza las centenas.
	movf	Distancia,W		; Vuelve a recuperar este valor.
	call	BIN_a_BCD		; Lo pasa a BCD.
	call	LCD_ByteCompleto	; Visualiza las decenas (aunque sea cero) y
Visualiza_cm				; unidades.
	movlw	MensajeCentimetro
	call	LCD_Mensaje
	return

	INCLUDE  <RETARDOS.INC>
	INCLUDE  <LCD_4BIT.INC>
	INCLUDE  <LCD_MENS.INC>
	INCLUDE  <BIN_BCD.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
