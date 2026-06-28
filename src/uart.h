/*
  For setting up UART and connecting it to stdout.

   NOTE: The underling setup is implemented in assembly (uart.s)
*/

#ifndef UART_H
#define UART_H

#define BUAD 9600

#include <stdio.h>

/* Initializes registers for uart and hooks it up to stdout */
void initUART();

#endif
