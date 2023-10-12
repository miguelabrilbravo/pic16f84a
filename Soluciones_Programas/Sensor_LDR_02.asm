;******************************** Sensor_LDR_02.asm *************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; Programa de un interruptor crepuscular: una lámpara se matendrá encendida mientras sea 
; de noche. Una LDR detectará la luz ambiente (sin que le llegue la luz de la lámpara que
; pretende controlar) y estará conectada a la entrada Trigger Schmitt RA4.
; Cuando la LDR detecte oscuridad, el sistema activará una lámpara:
; - LDR iluminada --> Entrada PIC = "0" --> Lámpara apagada.
; - LDR en oscuridad -->  Entrada PIC = "1" --> Lámpara encendida.
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C
	ENDC

#DEFINE  Lampara	PORTB,1			; Línea donde se conecta la salida.
#DEFINE  LDR 	PORTA,4 		; Entrada Trigger Schmitt del PIC donde se conecta
					; la LDR.
; ZONA DE CÓDIGOS ********************************************************************

	ORG 	0
Inicio
	bsf	STATUS,RP0		; Acceso al Banco 1.
	bsf	LDR			; Configurada como entrada.
	bcf	Lampara			; Configurada como salida.
	bcf	STATUS,RP0		; Acceso al Banco 0.
	bcf	Lampara			; En principio lámpara apagada.
Principal
	btfss	LDR			; ¿Entrada=1?, ¿LDR en oscuridad?
	goto	ApagaLampara		; No, LDR iluminada por el sol. Apaga la lámpara.
EnciendeLampara
	call	Retardo_20s		; Espera este tiempo para confirmar la oscuridad.
	btfss	LDR			; ¿Entrada=1?, ¿LDR sigue en oscuridad?
	goto	Fin			; No, sale fuera.
	bsf	Lampara			; Sí, enciende la lámpara.
	goto	Fin	
ApagaLampara
	call	Retardo_20s		; Espera este tiempo para confirmar la luz del sol.
	btfsc	LDR			; ¿Entrada=0?, ¿LDR sigue iluminada por luz del sol?
	goto	Fin			; No, sale fuera.
	bcf	Lampara			; Sí, apaga lámpara.
Fin	call	Retardo_20s		; Permanece en el estado anterior al menos este tiempo.
	goto	Principal
	
	INCLUDE   <RETARDOS.INC>
	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. López.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
