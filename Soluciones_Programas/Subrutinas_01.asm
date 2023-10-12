;*********************************** Subrutinas_01.asm **********************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Un n�mero binario de 8 bits es convertido a BCD. El resultado se guarda en tres
; posiciones de memorias RAM de datos llamadas Centenas, Decenas y Unidades.
; Finalmente tambi�n las unidades y las decenas se visualizar�n en los diodos LEDs
; conectados al Puerto B. El n�mero a convertir ser� la constante "Numero".
;
; Realizar este programa utilizando una subrutina que se llame BIN_a_BCD.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK	0x0C			; En esta posici�n empieza la RAM de usuario.
	ENDC

Numero	EQU	.124			; Por ejemplo.

; ZONA DE C�DIGOS ********************************************************************

	ORG 	0			; El programa comienza en la direcci�n 0.
Inicio
	bsf	STATUS,RP0		; Acceso al Banco 1.
	clrf	TRISB			; Las l�neas del Puerto B se configuran como salida.
	bcf	STATUS,RP0		; Acceso al Banco 0.
Principal
	movlw	Numero
	call	BIN_a_BCD
	movwf	PORTB			; El resultado se visualiza por la salida.
	goto	$			; Se queda permanentemente en este bucle.

; Subrutina "BIN_a_BCD" -----------------------------------------------------------------
;
; Un n�mero binario de 8 bits es convertido en BCD. El procedimiento utilizado es mediante
; restas de 10, tal como se explic� en el cap�tulo 9.
;
; Entrada:	En el registro W el n�mero binario a convertir.
; Salidas:	En (Centenas), (Decenas) y (Unidades).
;	Tambi�n las decenas (nibble alto) y unidades (nibble bajo) en el registro (W).

	CBLOCK				; En las subrutinas no se debe fijar la direcci�n
	Centenas				; de la RAM de usuario. Definida a continuaci�n de
	Decenas				; la �ltima asignada.
	Unidades	
	ENDC
;
BIN_a_BCD
	clrf	Centenas			; Carga los registros con el resultado inicial.
	clrf	Decenas			; En principio (Centenas)=0 y (Decenas)=0.
	movwf	Unidades			; Se carga el n�mero binario a convertir.
Resta10
	movlw	.10			; A las unidades se le va restando 10 en cada
	subwf	Unidades,W		; pasada. (W)=(Unidades)-10.
	btfss	STATUS,C		; �(Unidades)>=10?, �(W) positivo?, �C=1?
	goto 	Fin_BIN_BCD		; No, es menor de 10. Se acab�.
IncrementaDecenas
	movwf	Unidades			; Recupera lo que queda por restar.
	incf	Decenas,F		; Incrementa las decenas y comprueba si ha
	movlw	.10			; llegado a 10. Lo hace mediante una resta.
	subwf	Decenas,W		; (W)=(Decenas)-10).
	btfss	STATUS,C		; �C=1?, �(W) positivo?, �C=1?
	goto	Resta10			; No. Vuelve a dar otra pasada, rest�ndole 10.
IncrementaCentenas
	clrf	Decenas			; Pone a cero las decenas 
	incf	Centenas,F		; e incrementa las centenas.
	goto	Resta10			; Otra pasada: Resta 10 al n�mero a convertir.
Fin_BIN_BCD
	swapf	Decenas,W		; En el nibbe alto de (W) tambi�n las decenas.
	addwf	Unidades,W		; En el nibble bajo de (W) las unidades.
	return				; Vuelve al programa principal.

	END				; Fin del programa.
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
