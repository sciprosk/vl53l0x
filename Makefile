all: uart_test.hex

uart_test.hex: uart_test.elf
	avr-objcopy uart_test.elf -O ihex uart_test.hex

uart_test.elf: uart_test.o uart.o
	avr-ld -o uart_test.elf uart_test.o uart.o

uart_test.o: uart_test.s
	avr-as -mmcu=atmega328p -o uart_test.o uart_test.s

uart.o: uart.s
	avr-as -mmcu=atmega328p -o uart.o uart.s

deploy:
	avrdude -c arduino -P /dev/ttyACM0 -b 115200 -p atmega328p -D -U flash:w:uart_test.hex:i

clean:
	rm -fr uart.o uart_test.o uart_test.elf uart_test.hex

.PHONY: all clean deploy
