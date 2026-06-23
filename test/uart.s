; https://sourceware.org/binutils/docs/as/

; Literals for UART configuration
.equ F_CPU, 16000000 ; main clock frequency, Hz
.equ BAUD, 9600      ; baud rate
.equ UBRR_VAL, (F_CPU / 16 / BAUD - 1)

; Register usage
.equ UCSR0A, 0x00c0
.equ UCSR0B, 0x00c1
.equ UCSR0C, 0x00c2
.equ UBRR0L, 0x00c4
.equ UBRR0H, 0x00c5
.equ UDR0,   0x00c6

; Bit numbers in registers (0-based)
.equ UDRE0,  5
.equ TXEN0,  3
.equ UCSZ01, 2
.equ UCSZ00, 1

; API functions

	.text
	.global uart_init
	.type uart_init, @function
; void uart_init(void)
uart_init:
	; Set baud rate.
	ldi r16, hi8(UBRR_VAL)
	sts UBRR0H, r16
	ldi r16, lo8(UBRR_VAL)
	sts UBRR0L, r16
	; Enable transmitter.
	; The default values in UCSR0B are all zeros,
	; we can write directly, without read-modify-write.
	ldi r16, 1 << TXEN0
	sts UCSR0B, r16
	; Set 8-bit frames without the parity bit.
	; Same as above: direct write without read-modify-write.
	ldi r16, (1 << UCSZ01) | (1 << UCSZ00)
	sts UCSR0C, r16
	ret
	.size uart_init, . - uart_init

	.text
	.global uart_putc
	.type uart_putc, @function
; void uart_putc(char)
uart_putc:
	; Await indefinitely until available.
	lds r16, UCSR0A
	andi r16, 1 << UDRE0
	breq uart_putc
	; Send data
	sts UDR0, r24
	ret
	.size uart_putc, . - uart_putc
