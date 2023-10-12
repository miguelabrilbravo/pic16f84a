;************************************* Fibonacci.asm ************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Los términos de la secuencia de Fibonacci son: 0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, ...
; En esta secuencia cada número es la suma de los dos términos que le preceden. Por ejemplo,
; el término que sigue al 55 será 34 + 55= 89.
;
; Obtener el último término de la secuencia de Fibonacci menor de 256 y sacar ese valor
; por el puerto de salida. 
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	Penultimo			; Ocupa la posición 0x0C de RAM.
	Ultimo				; Ocupa la posición 0x0D de RAM.
	Suma				; Ocupa la posición 0x0E de RAM.
	ENDC

; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0			; El programa comienza en la dirección 0.
Inicio
	bsf	STATUS,RP0		; Acceso al Banco 1.
	clrf	TRISB			; Las líneas del Puerto B se configuran como salida.
	bcf	STATUS,RP0		; Acceso al Banco 0.
Principal
	clrf	Penultimo		; Asigna 0 al penúltimo término de Fibonacci y
	movlw	.1			; 1 al último. Son las "semillas".
SigueSumando
	movwf	Ultimo			; Asigna (W) al (Ultimo) término de Fibonacci.
	addwf	Penultimo,W		; Suma términos último y penúltimo.
	movwf	Suma			; (Suma)=(Penultimo)+(Ultimo).
	btfsc	STATUS,C		; ¿C=0?, ¿(W)<256?
	goto	Fin			; No, por tanto ha excedido del máximo y sale.
	movf	Ultimo,W		; Sí, por tanto el (Ultimo) pasa al (Penultimo).
	movwf	Penultimo
	movf	Suma,W			; Y la (Suma) al (Ultimo).
	goto	SigueSumando
Fin	movfw	Ultimo			; En (Ultimo) el término de Fibonacci buscado.
	movwf	PORTB			; Resultado se visualiza por el puerto de salida.
	sleep

	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
