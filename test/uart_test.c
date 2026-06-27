/* Just prints out using UART */
   
#include <avr/io.h>
#include <stdio.h>
#include <util/delay.h>
#include "uart.c"

int main(void)
{
  uart_init();

  while(1) {
    printf("Henlow planet %f \n", 1.0f);
  }
  return 0;
}
