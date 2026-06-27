#include "uart.h"

static void uart_transmit(uint8_t data) {
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

void uart_init() {
  uint16_t ubrr = (F_CPU / 16 / BUAD -1);
  UBRR0H = (uint8_t)(ubrr >> 8);
  UBRR0L = (uint8_t)ubrr;

  UCSR0B = (1 << TXEN0) | (1 << RXEN0);
  UCSR0C = (1 << UCSZ01) | (1 << UCSZ00);

  stdout = &uart_stdio;
  stdin = &uart_stdio;
  stderr = &uart_stdio;
}
