;************************************* Fibonacci.asm ************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Los t�rminos de la secuencia de Fibonacci son: 0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, ...
; En esta secuencia cada n�mero es la suma de los dos t�rminos que le preceden. Por ejemplo,
; el t�rmino que sigue al 55 ser� 34 + 55= 89.
;
; Obtener el �ltimo t�rmino de la secuencia de Fibonacci menor de 256 y sacar ese valor
; por el puerto de salida. 
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	Penultimo			; Ocupa la posici�n 0x0C de RAM.
	Ultimo				; Ocupa la posici�n 0x0D de RAM.
	Suma				; Ocupa la posici�n 0x0E de RAM.
	ENDC

; ZONA DE C�DIGOS ********************************************************************

	ORG 	0			; El programa comienza en la direcci�n 0.
Inicio
	bsf	STATUS,RP0		; Acceso al Banco 1.
	clrf	TRISB			; Las l�neas del Puerto B se configuran como salida.
	bcf	STATUS,RP0		; Acceso al Banco 0.
Principal
	clrf	Penultimo		; Asigna 0 al pen�ltimo t�rmino de Fibonacci y
	movlw	.1			; 1 al �ltimo. Son las "semillas".
SigueSumando
	movwf	Ultimo			; Asigna (W) al (Ultimo) t�rmino de Fibonacci.
	addwf	Penultimo,W		; Suma t�rminos �ltimo y pen�ltimo.
	movwf	Suma			; (Suma)=(Penultimo)+(Ultimo).
	btfsc	STATUS,C		; �C=0?, �(W)<256?
	goto	Fin			; No, por tanto ha excedido del m�ximo y sale.
	movf	Ultimo,W		; S�, por tanto el (Ultimo) pasa al (Penultimo).
	movwf	Penultimo
	movf	Suma,W			; Y la (Suma) al (Ultimo).
	goto	SigueSumando
Fin	movfw	Ultimo			; En (Ultimo) el t�rmino de Fibonacci buscado.
	movwf	PORTB			; Resultado se visualiza por el puerto de salida.
	sleep

	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
