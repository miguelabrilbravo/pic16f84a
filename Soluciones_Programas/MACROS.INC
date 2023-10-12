;***************************** Librería "MACROS.INC" **********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Estas son algunas macros útiles y de frecuente uso.
;
; Macro "Incrementa" --------------------------------------------------------------------
;
; Incrementa el valor del (Registro). Pueden ocurrir dos casos:
;     -	Que (Registro) no supere el valor "Maximo", entonces salta a la etiqueta apuntada
;	por el argumento "Salto". El flag Carry se pone a "1".
;     -	Que (Registro) supere el valor "Maximo", entonces se inicializa con el valor de
;	del argumento "Minimo". El flag Carry se pone a "0".
;
Incrementa	MACRO	Registro, Minimo, Maximo, Salto
	incf	Registro,F		; Incrementa el valor del registro.
	movf	Registro,W		; ¿Ha llegado a su valor máximo?
	sublw	Maximo			; (W)=Maximo-(Registro).
	btfsc	STATUS,C		; ¿C=0?, ¿(W) negativo?, ¿Maximo<(Registro)?
	goto	Salto			; No, Es Maximo>=(Registro) y salta.
	movlw	Minimo			; Sí, ha resultado Maximo<(Registro), entonces
	movwf	Registro			; inicializa el registro.
	ENDM

; Macro "SaltaSiIgual" ------------------------------------------------------------------
;
; Compara el valor del (Registro) con una "Constante". Si:
;     -	(Registro)=Constante, salta a la dirección indicada por el argumento "Salto" y el
;	flag Z se pone a "1".
;     -	(Registro)distinto "Constante", no salta y el flag Z se pone a "0".

SaltaSiIgual	MACRO	Registro, Constante, Salto
	movlw	Constante			; Va a realizar la comparación mediante resta.
	subwf	Registro,W		; (W)=(Registro)-Constante
	btfsc	STATUS,Z		; ¿Z=0?, ¿(W) distinto 0?, ¿(Registro) distinto Constante?
	goto	Salto			; Ha resultado (Registro)=Constante y salta.
	ENDM

; Macro "SaltaSiMayor" ------------------------------------------------------------------
;
; Compara el valor del (Registro) con una "Constante". Si:
;   -	(Registro)>Constante, salta a la dirección indicada por el argumento "Salto" y el
;	flag Carry se pone a "0".
;   -	(Registro)<=Constante, no salta y el flag Carry se pone a "1".

SaltaSiMayor	MACRO	Registro, Constante, Salto
	movf	Registro,W		; Va a realizar la comparación mediante resta.
	sublw	Constante			; (W)=Constante-(Registro).
	btfss	STATUS,C		; ¿C=1?, ¿(W) positivo?, ¿Constante>=(Registro)?
	goto	Salto			; Ha resultado Constante<(Registro) y salta.
	ENDM

; Macro "SaltaSiMenor" ------------------------------------------------------------------
;
; Compara el valor del (Registro) con una "Constante". Si:
;   -	(Registro)<Constante, salta a la dirección indicada por el argumento "Salto" y el
;	flag Carry se pone a "0".
;   -	(Registro)>=Constante, no salta y el flag Carry se pone a "1".

SaltaSiMenor	MACRO	Registro, Constante, Salto
	movlw	Constante			; Va a realizar la comparación mediante resta.
	subwf	Registro,W		; (W)=(Registro)-Constante
	btfss	STATUS,C		; ¿C=1?, ¿(W) positivo?, ¿(Registro)>=Constante?
	goto	Salto			; Ha resultado (Registro)<Constante y salta.	
	ENDM

; Macro "VisualizaBCD" -------------------------------------------------------------
;
; Visualiza en la pantalla del módulo LCD el contenido de un (Registro) expresado en BCD.
;	
VisualizaBCD	MACRO	Registro	
	movf	Registro,W
	call	BIN_a_BCD		; Se debe visualizar en BCD.
	call	LCD_Byte		; Con decena apagada si es cero.
	ENDM
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
