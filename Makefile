CC 		= 	avr-gcc
INC 	=	-Imodules/vl53l0x-non-arduino/ -Imodules/vl53l0x-non-arduino/util/ -Isrc/
F_CPU	= 	16000000

define build-and-deploy
# $(1) is the source filename (w/o extension)
# $(2) is the directory (src or test)
	@echo --------------------------------------------------
	@echo 1. compile into elf
	@echo ..................................................
	avr-gcc -mmcu=atmega328p -DF_CPU=$(F_CPU) $(INC) -o bin/$(1).elf $(2)/$(1).c -Os
	@echo --------------------------------------------------	
	@echo 2. objcopy to convert to ihex
	@echo ..................................................	
	avr-objcopy bin/$(1).elf -O ihex bin/$(1).hex
	@echo --------------------------------------------------
	@echo 3. flash using avr-dude
	@echo ..................................................	
	avrdude -c arduino -P /dev/ttyACM0 -b 115200 -p atmega328p -D -U flash:w:bin/$(1).hex:i
endef

tof_test: test/tof_test.c bin
	$(call build-and-deploy,tof_test,test)

uart_test: test/uart_test.c bin
	$(call build-and-deploy,uart_test,test)

bin:
	mkdir bin
