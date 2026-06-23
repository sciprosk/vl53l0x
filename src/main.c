/*--------------------------------------------------
  VL53L0X source files
..................................................*/
#include "millis.c"
#include "debugPrint.c"
#include "i2cmaster.c"
#include "VL53L0X.c"
/*..................................................*/

#include <avr/io.h>
#include <stdio.h>
#include <util/delay.h>

void uart_init(uint32_t buad) {
  uint16_t ubrr = (F_CPU / 16 / buad -1);
  UBRR0H = (uint8_t)(ubrr >> 8);
  UBRR0L = (uint8_t)ubrr;

  UCSR0B = (1 << TXEN0) | (1 << RXEN0);
  UCSR0C = (1 << UCSZ01) | (1 << UCSZ00);
}

void uart_transmit(uint8_t data) {
  while(!(UCSR0A & (1 << UDRE0)));
  UDR0 = data;
}

static int uart_putchar(char c, FILE *stream) {
  if (c == '\n') {
      uart_transmit('\r');
  }

  uart_transmit((uint8_t)c);
  return 0;
}

static int uart_getchar(FILE *stream) {
  return 0;
}

static FILE uart_stdio = FDEV_SETUP_STREAM(uart_putchar, uart_getchar, _FDEV_SETUP_RW);

int main(void)
{
  uart_init(9600);
  stdout = &uart_stdio;
  stdin = &uart_stdio;
  stderr = &uart_stdio;

  while(1) {
    printf("Henlow planet %f \n", 1.0f);
  }
  return 0;
}
