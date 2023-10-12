;************************************ Retardo_01.asm ************************************
;
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
;
; El LED conectado a la l�nea 0 del puerto de salida se enciende durante 400 ms y se
; apaga durante 300 ms. 
;
; ZONA DE DATOS **********************************************************************

	__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
	LIST	   P=16F84A
	INCLUDE  <P16F84A.INC>

	CBLOCK  0x0C			; En esta posici�n empieza la RAM de usuario.
	ENDC

#DEFINE  LED	PORTB,0

; ZONA DE C�DIGOS *******************************************************************

	ORG	0
Inicio
	bsf	STATUS,RP0		; Acceso al Banco 1.
	bcf	LED			; L�nea del LED configurada como salida.
	bcf	STATUS,RP0		; Acceso al Banco 0.
Principal
	bsf	LED			; Enciende el LED
	call	Retardo_200ms		; durante la suma de este tiempo.
	call	Retardo_200ms
	bcf	LED			; Lo apaga durante la suma de los siguientes
	call	Retardo_200ms		; retardos.
	call	Retardo_100ms
	goto 	Principal
	
; Subrutinas "Retardo_200ms" y "Retardo_100ms"-------------------------------------------
;
	CBLOCK
	R_ContA				; Contadores para los retardos.
	R_ContB
	ENDC

Retardo_200ms				; La llamada "call" aporta 2 ciclos m�quina.
	movlw	d'200'			; Aporta 1 ciclo m�quina. Este es el valor de "M".
	goto	Retardos_ms		; Aporta 2 ciclos m�quina.
Retardo_100ms				; La llamada "call" aporta 2 ciclos m�quina.
	movlw	d'100'			; Aporta 1 ciclo m�quina. Este es el valor de "M".
	goto	Retardos_ms		; Aporta 2 ciclos m�quina.
Retardo_1ms				; La llamada "call" aporta 2 ciclos m�quina.
	movlw	d'1'			; Aporta 1 ciclo m�quina. Este es el valor de "M".
;
; El pr�ximo bloque "Retardos_ms" tarda:
; 1 + M + M + KxM + (K-1)xM + Mx2 + (K-1)Mx2 + (M-1) + 2 + (M-1)x2 + 2 =
; = (2 + 4M + 4KM) ciclos m�quina. Para K=249 y M=1 supone 1002 ciclos m�quina
; que a 4 MHz son 1002 �s = 1 ms.
;
Retardos_ms
	movwf	R_ContB			; Aporta 1 ciclo m�quina.
R1ms_BucleExterno
	movlw	d'249'			; Aporta Mx1 ciclos m�quina. Este es el valor de "K".
	movwf	R_ContA			; Aporta Mx1 ciclos m�quina.
R1ms_BucleInterno
	nop				; Aporta KxMx1 ciclos m�quina.
	decfsz	R_ContA,F		; (K-1)xMx1 cm (cuando no salta) + Mx2 cm (al saltar).
	goto	R1ms_BucleInterno 		; Aporta (K-1)xMx2 ciclos m�quina.
	decfsz	R_ContB,F		; (M-1)x1 cm (cuando no salta) + 2 cm (al saltar).
	goto	R1ms_BucleExterno 	; Aporta (M-1)x2 ciclos m�quina.
	return				; El salto de retorno aporta 2 ciclos m�quina.
;
;En total estas subrutinas tardan:
; - Retardo_200ms:	2 + 1 + 2 + (2 + 4M + 4KM) = 200007 cm = 200 ms. (M=200 y K=249).
; - Retardo_100ms:	2 + 1 + 2 + (2 + 4M + 4KM) = 100007 cm = 100 ms. (M=100 y K=249).
; - Retardo_1ms  :	2 + 1     + (2 + 4M + 4KM) =   1005 cm =   1 ms. (M=  1 y K=249).

	END
	
;	===================================================================
;	  Del libro "MICROCONTROLADOR PIC16F84. DESARROLLO DE PROYECTOS"
;	  E. Palacios, F. Remiro y L. L�pez.
; 	  Editorial Ra-Ma.  www.ra-ma.es
;	===================================================================
