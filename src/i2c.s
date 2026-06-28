; I2C API functions implementation.
; Basic protocol-related literals.
.equ F_CPU, 16000000  ; 16 MHz core clock
.equ I2C_FREQ, 100000 ; 100 kHz standard mode
.equ TWBR_VAL, (((F_CPU / I2C_FREQ) - 16) / 2)

; Memory-mapped registers.
.equ TWBR, 0x00B8 ; Bit Rate Register
.equ TWSR, 0x00B9 ; Status Register
.equ TWDR, 0x00BB ; Data Register
.equ TWCR, 0x00BC ; Control Register

; Bit numbers in registers (0-based)
; TWSR:
.equ TWSP0, 0
.equ TWSP1, 1
; TWCR:
.equ TWINT, 7
.equ TWSTA, 5
.equ TWSTO, 4
.equ TWEN , 2

.text
.align(1) ; 2^1=16-bit alignment for the flash memory

	.global i2c_init
	.type i2c_init, @function
; void i2c_init(void)
i2c_init:
	; Set pre-scaler value to 1
	ldi r16, 0x0;
	sts TWSR, r16
	; Set the bit rate to 100 kHz
	ldi r16, TWBR_VAL ; must fit in 8 bits
	sts TWBR, r16
	ret
	.size i2c_init, . - i2c_init

; Blocking write, no error handling for now.
	.global i2c_putc
	.type i2c_putc, @function
; void i2c_putc(char addr, char data)
; AVR ABI: addr -> R24, data -> R22
i2c_putc:
	; START condition:
	ldi r16, (1 << TWINT) | (1 << TWSTA) | (1 << TWEN)
	sts TWCR, r16
1:	; Block forever until done.
	lds r16, TWCR
	sbrs r16, TWINT
	rjmp 1b
	; WRITE to the address:
	lsl r24
	sts TWDR, r24
	ldi r16, (1 << TWINT) | (1 << TWEN)
	sts TWCR, r16
2:	; Block forever until done.
	lds r16, TWCR
	sbrs r16, TWINT
	rjmp 2b
	; WRITE byte:
	sts TWDR, r22
	ldi r16, (1 << TWINT) | (1 << TWEN)
	sts TWCR, r16
3:	; Block forever until done.
	lds r16, TWCR
	sbrs r16, TWINT
	rjmp 3b
	; STOP condition:
	ldi r16, (1 << TWINT) | (1 << TWSTO) | (1 << TWEN)
	sts TWCR, r16
	; No wait after STOP.
	ret
.size i2c_putc, . - i2c_putc

; Blocking read call without error hadnling.
	.global i2c_getc
	.type i2c_getc, @function
; unsigned char i2c_getc(unsigned char addr)
i2c_getc:
	; START condition:
	ldi r16, (1 << TWINT) | (1 << TWSTA) | (1 << TWEN)
	sts TWCR, r16
1:	; Block until START is asserted by the hardware.
	lds r16, TWCR
	sbrs r16, TWINT
	rjmp 1b
	; READ from the address:
	lsr r24
	; Set the read bit in the address frame.
	ori r24, 0x1
	sts TWDR, r24
	; This triggers the transaction.
	ldi r16, (1 << TWINT) | (1 << TWEN)
	sts TWCR, r16
2:	; Block until done with the address frame.
	lds r16, TWCR
	sbrs r16, TWINT
	rjmp 2b
	; Now, we should have data
	lds r24, TWDR
	; STOP condition, no wait:
	ldi r16, (1 << TWINT) | (1 << TWSTO) | (1 << TWEN)
	sts TWCR, r16
	ret
	.size i2c_getc, . - i2c_getc
