CC = 	avr-gcc

main: src/main.c bin
	@echo --------------------------------------------------
	@echo 1. compile into elf
	@echo ..................................................
	avr-gcc -mmcu=atmega328p -DF_CPU=16000000 -o bin/main.elf src/main.c -Os
	@echo --------------------------------------------------	
	@echo 2. objcopy to convert to ihex
	@echo ..................................................	
	avr-objcopy bin/main.elf -O ihex bin/main.hex
	@echo --------------------------------------------------
	@echo 3. flash using avr-dude
	@echo ..................................................	
	avrdude -c arduino -P /dev/ttyACM0 -b 115200 -p atmega328p -D -U flash:w:bin/main.hex:i

bin:
	mkdir bin
