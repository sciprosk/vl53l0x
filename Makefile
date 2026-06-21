
main: main.c
	# 1. compile into elf
	avr-gcc -mmcu=atmega328p -DF_CPU=16000000 -o main.elf main.c -Os
	# 2. objcopy to convert to ihex
	avr-objcopy main.elf -O ihex main.hex
	# 3. flag using avr-dude
	avrdude -c arduino -P /dev/ttyACM0 -b 115200 -p atmega328p -D -U flash:w:main.hex:i
