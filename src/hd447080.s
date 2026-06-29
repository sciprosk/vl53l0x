; Hitachi HD44780 Display Driver with I2C expander API

; The 8-bits that go down into I2C are split into two
; 4-bit nibbles as follows: the upper 4 bits are data
; and lower 4 bits are wired to the LCD control pins:
; |D7 D6 D5 D4 | C3 C2 C1 C0 |

; Basic control bits
.equ LCD_BACKLIGHT, 3
.equ LCD_EN       , 2
.equ LCD_RW       , 1
.equ LCD_RS       , 0

; Basic command categories:
.equ LCD_CLEAR_DISPLAY, 0x01

.text
.align(1)

; Low-level API:

; Commands are written on a falling edge of the E-pin (LCD_EN).
; We write 4 bits through the I2C with LCD_EN asserted,
; keep it stable for some delay time, and then then repeat the
; same data with LCD_EN set to zero.  The data should be written
; on the falling edge when E-pin is changing.
;
; This is the most basic API function that triggers the write
; of the 4-bits.
;
; void lcd_write_nibble(unsigned char addr, unsigned char data)
;    addr: 7-bit I2C address of the device
;    data: should be in the upper 4 bits of the byte
	.global lcd_write_nibble
	.type lcd_write_nibble, @function
lcd_write_nibble:
	; Toggle E-pin high.
	ori r22, (1 << LCD_BACKLIGHT) | (1 << LCD_EN)
	push r24
	push r22
	call i2c_putc
	; Delay for about 16 cycles to stabilize the E pin
	ldi r16, 0x08
1:
	dec r16
	brne 1b
	pop r22
	pop r24
	; Toggle E-pin low.  Data is written on falling edge.
	andi r22, ~(1 << LCD_EN)
	call i2c_putc
	; Delay for about 512 cycles. Does not be exact,
	; just long enough.
	ldi r18, 0x2
2:
	ldi r16, 0xFF
3:
	dec r16
	brne 3b
	dec r18
	brne 2b
	ret
	.size lcd_write_nibble, . - lcd_write_nibble

; The following writes an 8-bit command in the display driver
; by doing two transfers of 4-bits.  The command register is
; selected by setting the RS bit low.
;
; void lcd_write_command(unsigned char addr, unsigned char cmd)
;
	.global lcd_write_command
	.type lcd_write_command, @function
lcd_write_command:
	; Save the content of r22 to use the lower nibble later.
	push r22
	; Mask out the upper nibble. For writing a command,
	; We don't set the LCD_RS bit.
	andi r22, 0xf0
	; Address maybe clobber by the call
	push r24
	rcall lcd_write_nibble
	pop r24
	pop r22
	; There is a cool instruction for swapping nibbles.
	swap r22
	; Mask out lower four bits again.
	andi r22, 0xf0
	rcall lcd_write_nibble
	ret
	.size lcd_write_command, . - lcd_write_command

; Writes a byte into the display driver's data register by
; doing two 4-bit transfers.  The data register is selecte
; by setting the RS bit in the lower nibble of each
; transfer.  Otherwise, same as the lcd_write_command above.
	.global lcd_write_data
	.type lcd_write_data, @function
lcd_write_data:
	push r22
	andi r22, 0xf0
	; Now we set the RS bit to write into the data register.
	ori r22, 1 << LCD_RS
	push r24
	rcall lcd_write_nibble
	pop r24
	pop r22
	swap r22
	andi r22, 0xf0
	; And set the RS bit again for the lower nibble too.
	ori r22, 1 << LCD_RS
	rcall lcd_write_nibble
	ret
	.size lcd_write_data, . - lcd_write_data
