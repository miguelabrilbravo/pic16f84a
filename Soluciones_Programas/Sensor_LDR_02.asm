;******************************** Sensor_LDR_02.asm *************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Programa de un interruptor crepuscular: una l�mpara se matendr� encendida mientras sea 
; de noche. Una LDR detectar� la luz ambiente (sin que le llegue la luz de la l�mpara que
; pretende controlar) y estar� conectada a la entrada Trigger Schmitt RA4.
; Cuando la LDR detecte oscuridad, el sistema activar� una l�mpara:
; - LDR iluminada --> Entrada PIC = "0" --> L�mpara apagada.
; - LDR en oscuridad -->  Entrada PIC = "1" --> L�mpara encendida.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	ENDC

#DEFINE  Lampara	PORTB,1			; L�nea donde se conecta la salida.
#DEFINE  LDR 	PORTA,4 		; Entrada Trigger Schmitt del PIC donde se conecta
					; la LDR.
; ZONA DE C�DIGOS ********************************************************************

	ORG 	0
Inicio
	bsf	STATUS,RP0		; Acceso al Banco 1.
	bsf	LDR			; Configurada como entrada.
	bcf	Lampara			; Configurada como salida.
	bcf	STATUS,RP0		; Acceso al Banco 0.
	bcf	Lampara			; En principio l�mpara apagada.
Principal
	btfss	LDR			; �Entrada=1?, �LDR en oscuridad?
	goto	ApagaLampara		; No, LDR iluminada por el sol. Apaga la l�mpara.
EnciendeLampara
	call	Retardo_20s		; Espera este tiempo para confirmar la oscuridad.
	btfss	LDR			; �Entrada=1?, �LDR sigue en oscuridad?
	goto	Fin			; No, sale fuera.
	bsf	Lampara			; S�, enciende la l�mpara.
	goto	Fin	
ApagaLampara
	call	Retardo_20s		; Espera este tiempo para confirmar la luz del sol.
	btfsc	LDR			; �Entrada=0?, �LDR sigue iluminada por luz del sol?
	goto	Fin			; No, sale fuera.
	bcf	Lampara			; S�, apaga l�mpara.
Fin	call	Retardo_20s		; Permanece en el estado anterior al menos este tiempo.
	goto	Principal
	
	INCLUDE   <RETARDOS.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
