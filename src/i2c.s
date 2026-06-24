; I2C API functions implementation.

; Basic protocol-related literals.
.equ F_CPU, 16000000  ; 16 MHz core clock
.equ I2C_FREQ, 100000 ; 100 kHz standard mode
.equ TWBR_VAL, (((F_CPU / I2C_FREQ) - 16) / 2)

; Memory-mapped registers.
.equ TWBR, 0x00B8 ; Bit Rate Register
.equ TWSR, 0x00B9 ; Status Register
.equ TWCR, 0x00BC ; Control Register

; Bit numbers in registers (0-based)
.equ TWSP0, 0
.equ TWSP1, 1
.equ TWINT, 7
.equ TWSTA, 5
.equ TWEN, 2


.text
.align(1) ; 2^1=16-bit alignment for the flash memory

	.global i2c_init
	.type i2c_init, @function
; void i2c_init(void)
i2c_init:
	; Set pre-scaler value to 1
	ldi r16, (1 << TWSP1) | (1 << TWSP0)
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
	ldi r16, (1 << TWINT) | (1 < TWSTA) | (1 << TWEN)
	sts TWCR, r16
	; Block forever until done.
1:
	lds r16, TWCR
	andi r16, (1 << TWINT)
	brne 1b
	; WRITE address
	; WRITE byte
	; STOP condition
	ret
	.size i2c_putc, . - i2c_putc
