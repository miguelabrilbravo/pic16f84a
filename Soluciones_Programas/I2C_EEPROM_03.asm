;************************************ I2C_EEPROM_03.asm *******************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Lee los mensajes grabados en las 10 primeras p�ginas de la memoria 28LC256 y los visualiza
; en la pantalla del m�dulo LCD.
;
; Los mensajes han tenido que ser previamente grabados en la memoria 24LC256 con alg�n
; sotfware espec�fico como el IC-Prog, o mediante el procedimiento explicado en el programa
; I2C_EEPROM_01.asm, de la siguiente forma:
;  - El mensaje 0, a partir de la direcci�n 0000h.
;  - El mensaje 1, a partir de la direcci�n 0100h.
;  - El mensaje 2, a partir de la direcci�n 0200h.
;		... ...
;	(y asi sucesivamente hasta un m�ximo de..)	
;
;  - El mensaje 127, a partir de la direcci�n 7F00h.
;
; La longitud de cada mensaje est� limitada por la extensi�n de los 128 bytes que ocupa
; una p�gina de la memoria 24LC256. Cada mensaje debe terminar con el c�digo 0x00.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK	0x0C
	Apuntador			; Apunta al n�mero de p�gina donde se almacenan
	ENDC				; cada uno de los mensajes en la 24LC256.
	
UltimoMensaje	EQU	.10		; Se�ala el n�mero del �ltimo mensaje.

; ZONA DE C�DIGOS ********************************************************************

	ORG	0
Inicio
 	call	LCD_Inicializa
	clrf	Apuntador		; Inicializa el contador
Principal
	movf	Apuntador,W		; Apunta al inicio de cada mensaje ya que esta
	call	M24LC256_Mensaje_a_LCD	; subrutina lo carga en (M24LC256_AddressHigh).
	call	Retardo_2s		; Visualiza el mensaje durante este tiempo.
	incf	Apuntador,F		; Apunta al siguiente mensaje.
	movf	Apuntador,W		; Comprueba si ha llegado al �ltimo mensaje.
	sublw	UltimoMensaje		; (W)=UltimoMensaje-(Apuntador).
	btfss	STATUS,C		; �C=1?, �(W) positivo?
	clrf	Apuntador		; Ha resultado UltimoMensaje<(Apuntador).
	goto	Principal

	INCLUDE  <BUS_I2C.INC>		; Subrutinas de control del bus I2C.
	INCLUDE  <M24LC256.INC>	; Subrutinas de control de la memoria 24LC256.
	INCLUDE  <RETARDOS.INC>
	INCLUDE  <LCD_4BIT.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
