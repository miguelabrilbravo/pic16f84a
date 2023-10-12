;************************************ BCD_01.asm ****************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Un n�mero binario de 8 bits es convertido a BCD. El resultado se guarda en tres posiciones
; de memorias llamadas Centenas, Decenas y Unidades. Adem�s al final las unidades estar�n en el
; nibble bajo del registro W y las decenas en el nibble alto. En los diodos LEDs conectados al
; puerto de salida se visualizar�n las decenas y las unidades.
;
; El m�ximo n�mero a convertir ser�el 255 que es el m�ximo valor que puede adquirir el
; n�mero binario de entrada de 8 bits. 
;
; El procedimiento utilizado es mediante restas de 10 tal como se explica en el siguiente
; ejemplo que trata de la conversi�n del n�mero 124 a BCD:
;
; (Centenas)	(Decenas)	(Unidades)	�(Unidades)<10?	      �(Decenas)=10?
; ----------	---------	----------	--------------	-------------------------
;
;    0	 	   0		   124		NO, resta 10	Incrementa (Decenas).
;    0		   1		   114 		NO, resta 10 	NO. Incrementa (Decenas).
;    0		   2		   104		NO, resta 10	NO. Incrementa (Decenas).
;    0	  	   3		    94		NO, resta 10	NO. Incrementa (Decenas).
;    0		   4		    84		NO, resta 10	NO. Incrementa (Decenas).
;    0		   5		    74 		NO, resta 10 	NO. Incrementa (Decenas).
;    0		   6		    64 		NO, resta 10 	NO. Incrementa (Decenas).
;    0		   7		    54 		NO, resta 10 	NO. Incrementa (Decenas).
;    0		   8		    44 		NO, resta 10 	NO. Incrementa (Decenas).
;    0		   9		    34 		NO, resta 10 	NO. Incrementa (Decenas).
;    1		   0		    24 		NO, resta 10 	S�. (Decenas)=0, y adem�s
;								    incrementa (Centenas)
;    1		   1		    14 		NO, resta 10 	NO. Incrementa (Decenas)
;    1		   2		     4 		S�, se acab�. 
;
; El n�mero a convertir ser� la constante "Numero".
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK	0x0C			; La zona de memoria de usuario comienza en esta
	Centenas				; direcci�n de memoria RAM de datos.
	Decenas				; Posici�n 0x0D de RAM.
	Unidades				; Posici�n 0x0E de RAM.	
	ENDC

Numero	EQU	.124			; Por ejemplo.

; ZONA DE C�DIGOS ********************************************************************

	ORG 	0			; El programa comienza en la direcci�n 0.
Inicio
	bsf	STATUS,RP0		; Acceso al Banco 1.
	clrf	TRISB			; Las l�neas del Puerto B se configuran como salida.
	bcf	STATUS,RP0		; Acceso al Banco 0.
Principal
	clrf	Centenas			; Carga los registros con el resultado inicial.
	clrf	Decenas			; En principio (Centenas)=0 y (Decenas)=0.
	movlw	Numero
	movwf	Unidades			; Se carga el n�mero binario a convertir.
BCD_Resta10
	movlw	.10			; A las unidades se les va restando 10 en cada
	subwf	Unidades,W		; pasada. (W)=(Unidades)-10.
	btfss	STATUS,C		; �(C)=1?, �(W) positivo?, �(Unidades)>=10?.
	goto 	BIN_BCD_Fin		; No, es menor de 10. Se acab�.
BCD_IncrementaDecenas
	movwf	Unidades			; Recupera lo que queda por restar.
	incf	Decenas,F		; Incrementa las decenas y comprueba si llega a
	movlw	.10			; 10. Lo hace mediante una resta.
	subwf	Decenas,W		; (W)= (Decenas)-10.
	btfss	STATUS,C		;  �(C)=1?, �(W) positivo?, �(Decenas)>=10?.
	goto	BCD_Resta10		; No. Vuelve a dar otra pasada, rest�ndole 10.
BCD_IncrementaCentenas
	clrf	Decenas			; Pone a cero las decenas 
	incf	Centenas,F		; e incrementa las centenas.
	goto	BCD_Resta10		; Otra pasada, resta 10 al n�mero a convertir.
BIN_BCD_Fin
	swapf	Decenas,W		; En el nibble alto de W tambi�n las decenas.
	addwf	Unidades,W		; En el nibble bajo de W las unidades.
	movwf	PORTB			; Se visualiza por el puerto de salida.
	sleep				; Se queda permanentemente en reposo.

	END				; Fin del programa.

;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
