#include "uart.h"

/*--------------------------------------------------
  Uses functions defined in uart.s
..................................................*/
extern void uart_init();
extern void uart_putc(char c);
/*--------------------------------------------------*/

static int uart_putchar(char c, FILE *stream) {
  if (c == '\n') {
    uart_putc('\r');
  }

  uart_putc((uint8_t)c);
  return 0;
}

static int uart_getchar(FILE *stream) {
  return 0;
}

static FILE uart_stdio = FDEV_SETUP_STREAM(uart_putchar, uart_getchar, _FDEV_SETUP_RW);

void initUART() {
  uart_init();
  
  stdout = &uart_stdio;
  stdin = &uart_stdio;
  stderr = &uart_stdio;
}
