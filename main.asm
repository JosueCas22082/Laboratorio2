;**********************************************************************************************************************
;Universidad del Valle de Guatemala
;Programación de Microcontroladores 
;Laboratorio2.asm
;Josué Castro
;Creado: 2/02/2024 
;
;**********************************************************************************************************************
;ENCABEZADO
;**********************************************************************************************************************

.include "m328pdef.inc" 
.equ F_CPU = 16000000  ; Frecuencia del oscilador en Hz
.equ debounce_delay = 5 ; Retardo antirrebote en milisegundos

.equ SEG_A = 0 
.equ SEG_B = 1 
.equ SEG_C = 2 
.equ SEG_D = 3 
.equ SEG_E = 4 
.equ SEG_F = 5 
.equ SEG_G = 6 
.equ SEG_DP = 7 ; Definir el bit correspondiente al punto decimal

.org 0x00 ; Dirección de inicio del programa

ldi r16, 0xFF ; Configurar puerto B como salida para el display de 7 segmentos
out DDRB, r16

ldi r16, (1 << PD2) | (1 << PD3) ; Configurar PD2 y PD3 como entrada para los botones
out DDRD, r16

ldi r16, (1 << PD2) | (1 << PD3) ; Activar resistencias de pull-up para los botones
out PORTD, r16

main_loop:
    ; Leer el estado de los botones
    in r16, PIND

    ; Incrementar el contador cuando se presiona el botón de incremento
    sbrs r16, PD2
    rjmp decrement_button_pressed

    ; Antirrebote para el botón de incremento
    call debounce
    sbrc r16, PD2 ; Verificar si el botón sigue presionado después del retardo
    rjmp main_loop

    ; Incrementar el contador binario de 4 bits
    in r16, PORTB
    inc r16
    cpi r16, 16 ; Si el contador alcanza 16, reiniciar a 0
    breq reset_counter
    out PORTB, r16
    rjmp wait_for_button_release

decrement_button_pressed:
    ; Antirrebote para el botón de decremento
    call debounce
    sbrc r16, PD3 ; Verificar si el botón sigue presionado después del retardo
    rjmp main_loop

    ; Decrementar el contador binario de 4 bits
    in r16, PORTB
    dec r16
    cpse r16, r1 ; Si el contador es 255, reiniciar a 15
    out PORTB, r1
    rjmp wait_for_button_release

reset_counter:
    ; Restaurar el contador a 0
    ldi r16, 0
    out PORTB, r16

wait_for_button_release:
    ; Esperar hasta que los botones sean liberados
    sbis PIND, PD2
    rjmp wait_for_button_release
    sbis PIND, PD3
    rjmp wait_for_button_release

    rjmp main_loop

debounce:
    ; Implementar retardo antirrebote utilizando Timer0
    ldi r17, debounce_delay
debounce_loop:
    ldi r16, 244 ; Cargar un valor para 1 ms a 16 MHz con prescaler 1024
    wait_1ms:
        dec r16
        brne wait_1ms
        dec r17
        brne debounce_loop
    ret
