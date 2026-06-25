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

; Basic commands:
.equ LCD_CLEAR_DISPLAY 0x01

; Low-level API:
; void lcd_write_nibble(char data)
	.global lcd_write_nibble
	.type lcd_write_nibble, @function
lcd_write_nibble:
	;; TODO:
	mov r24, r22
	ori r22, (1 << LCD_BACKLIGHT) | (1 << LCD_EN)
	ldi r24, LCD_I2C_ADDR
	call i2c_putc
	;; Delay 1us
	andi r22, ~(1 << LCD_EN)
	call i2c_putc
	;; Delay 50us
	ret
	.size lcd_write_nibble, . - lcd_write_nibble
