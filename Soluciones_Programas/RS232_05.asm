;************************************ RS232_05.asm **************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Este programa env�a un mensaje grabado en la memoria de programa del microcontrolador al
; ordenador. Es decir, en el monitor del ordenador aparecer� el mensaje grabado en el PIC.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	ENDC

RetornoCarro	EQU	.13		; C�digo de tecla "Enter" o "Retorno de Carro".
CambioLinea	EQU	.10		; C�digo para el cambio de l�nea.

; ZONA DE C�DIGOS ********************************************************************

	ORG	0
Inicio
	call	LCD_Inicializa		; Inicializa el modulo LCD y las l�neas que se
	call	RS232_Inicializa		; van a utilizar en la comunicaci�n con el puerto
Principal					; serie RS232.
	movlw	Mensaje0			; Carga la primera posici�n del mensaje.
	call	RS232_Mensaje		; Lo visualiza en el ordenador.
	call	Retardo_5s
	goto	Principal
;
; "Mensajes" ----------------------------------------------------------------------------
;
Mensajes
	addwf	PCL,F
Mensaje0
	DT RetornoCarro
	DT " En el I.E.S. ISAAC PERAL de Torrejon de Ardoz"
	DT RetornoCarro, CambioLinea
	DT "      se puede estudiar el Ciclo Formativo"
	DT RetornoCarro, CambioLinea
	DT "      DESARROLLO de PRODUCTOS ELECTRONICOS."
	DT CambioLinea, CambioLinea, CambioLinea, 0x00 

	INCLUDE  <RS232.INC>
	INCLUDE  <RS232MEN.INC>
	INCLUDE  <LCD_4BIT.INC>
	INCLUDE  <RETARDOS.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
