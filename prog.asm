;; Program przedstawia działanie aktywnych opóźnień
;; dla mikrokontrolera PIC16F877A
;; Przyjęto, że procesora taktowany jest z częstotliwością 4 MHz
;; oraz że jeden cykl rozkazowy trwa 1 µs
	#include <p16f877A.inc> ; definicje specyficzne dla mikrokontrolera

	; ustawienie bitow konfiguracyjnych
	__CONFIG _XT_OSC & _WDT_OFF & _PWRTE_ON & _BODEN_OFF & _LVP_OFF

RST 	CODE 	0x000 	; wektor resetu procesora
	pagesel 	main 	; wybór strony pamięci programu
	goto 		main 	; skok do początku programu

PGM 	CODE			; poczatek sekcji kodu

;; Zmienne potrzebne dla działania procedur delay i delay2
DELAY_X	equ	0x20
DELAY_Y equ 0x21
COUNT	equ 0x22
COUNT2	equ 0x23
COUNT3	equ 0x24

;; Procedura odmierza od 14 do 2554 cykli
;; przyjmuje jeden parametr w rejestrze W
;; Do działania wymaga zmiennej COUNT
;; Odmierzana liczba cykli: CYCLE = 4 + 10 * W
;;                          W = (CYCLE-4)/10
delay:
	movwf	COUNT		; COUNT := W
loop_1:
		goto	$+1		; opóźnienie – 7 cykli
		goto	$+1		; ...
		goto	$+1		; ...
		nop	
		decfsz	COUNT, 1 ; COUNT:=COUNT-1
		goto	loop_1	 ; COUNT!=0 -> loop_1
	return				 ; COUNT==0 -> return

;; Procedura pozwala na odczekanie 26 do 166334974 cykli
;; Przyjmuje trzy parametry:
;; DELAY_X, DELAY_Y - dwie zmienne w pamięci
;; W                - wartość z rejestru W
;; do działania wymaga dwóch zmiennych COUNT2 i COUNT3 oraz
;; określonej wyżej procedury delay
;; Odmierzana liczba cykli:
;;  4 + W * (4 + DELAY_X * (8 + 10 * DELAY_Y))
;; https://github.com/radomik/CycleCount/blob/master/delays.c
delay2:
	movwf	COUNT3			; liczba kroków pętli zewnętrznej (z rejestru W)
loop_3_1:
		movf	DELAY_X,0	; liczba kroków pętli wewnętrznej
		movwf	COUNT2
loop_3_2:
			movf	DELAY_Y,0
			call	delay
			decfsz	COUNT2, 1
			goto	loop_3_2
		decfsz 	COUNT3, 1
		goto	loop_3_1
	return


;; 50us @ 4 MHz, 50 cykli po 1us, brak parametrów
delay_50us:			; call delay_50us (2 cykle)
	movlw	d'4'	; (1 cykl)
	call	delay	; 4 + 10*W = 4+10*4 = 44 cykle
	nop				; (1 cykl)
	return			; (2 cykle)

;; 51ms @ 4 MHz, 51000 cykli po 1us, brak parametrów
delay_51ms:			; call delay_51ms (2 cykle)
	movlw	d'3'	; parametr DELAY_X (1 cykl)
	movwf	DELAY_X ; zapisanie DELAY_X (1 cykl)
	movlw	d'45'	; parametr DELAY_Y (1 cykl)
	movwf	DELAY_Y ; zapisanie DELAY_Y (1 cykl)
	movlw	d'37'	; parametr W (1 cykl)
	call	delay2	; 50990 cykli (patrz wzór przed procedurą)
	nop				; (1 cykl)
	return			; (2 cykle)

;; 561ms @ 4 MHz, 561000 cykli po 1us, brak parametrów
delay_561ms:		; call delay_561ms (2 cykle)
	movlw	d'156'	; parametr DELAY_X (1 cykl)
	movwf	DELAY_X	; zapisanie DELAY_X (1 cykl)
	movlw	d'179'	; parametr DELAY_Y (1 cykl)
	movwf	DELAY_Y	; zapisanie DELAY_Y (1 cykl)
	movlw	d'2'	; parametr W (1 cykl)
	call	delay2	; 560988 cykli
	goto	$+1		; (2 cykle)
	nop				; (1 cykl)
	return			; (2 cykle)

;; 2,2s @ 4 MHz, 2200000 cykli po 1us, brak parametrów
delay_2_20s:		; call delay_2_20s (2 cykle)
	movlw	d'11'	; parametr DELAY_X (1 cykl)
	movwf	DELAY_X	; zapisanie DELAY_X (1 cykl)
	movlw	d'85'	; parametr DELAY_Y (1 cykl)
	movwf	DELAY_Y	; zapisanie DELAY_Y (1 cykl)
	movlw	d'233'	; parametr W (1 cykl)
	call	delay2	; 2199990 cykli
	nop				; (1 cykl)
	return			; (2 cykle)
	
main:
	bcf 	STATUS, RP0	; wybór banku 0
	
	call 	delay_50us	
	call	delay_51ms
	call	delay_561ms
	call 	delay_2_20s

	goto 	$ 			; pętla bez końca - zatrzymanie mikrokontrolera
 end 					; dyrektywa END kończy treść programu
