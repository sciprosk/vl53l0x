	.text
	eor r1, r1 ; zero register
	rcall uart_init
main:
	ldi r30, lo8(str)
	ldi r31, hi8(str)
.Lputs:
	lpm r24, Z+
	sub r24, r1
	breq 1f
	rcall uart_putc
	rjmp .Lputs
1:
	rcall delay
	rjmp main
	
; Delay loop:
delay:
	ldi r16, 0x1f
1:
	ldi r18, 0xff
2:
	ldi r20, 0xff
3:
	dec r20
	brne 3b
	dec r18
	brne 2b
	dec r16
	brne 1b
	ret

str: .asciz "Hello, World!\n"
.align 1
