/*==================================================
  Prints out the distance via UART
  
  Connect:
  A4 -> SDA
  A5 -> SCL
==================================================*/

/*--------------------------------------------------
 (trying one translation unit right
 now b/c it simpler build-system-wise)
  
  VL53L0X source files
..................................................*/
#include "millis.c"
#include "debugPrint.c"
#include "i2cmaster.c"
#include "VL53L0X.c"

/*--------------------------------------------------
  Our source files
 ..................................................*/
#include "uart.c"
/*..................................................*/

void init(void) {
  uart_init();
  //--------------------------------------------------
  // GPIOs
  //--------------------------------------------------
  //CBI( UCSR0B, RXEN0 );		// Disable UART RX
  //DDRD =  (1<<PIN_UART_TX);	// Set UART TX as output
  // Enable weak pullups on I2C lines
  PORTC = (1<<PIN_I2C_SCL) | (1<<PIN_I2C_SDA);
  //--------------------------------------------------
  // Init the other modules
  //--------------------------------------------------
  i2c_init();
  initMillis();
  sei();
}

int main(){
	statInfo_t xTraStats;
	init();

	printf("\n\n---------------------------------------\n");
	printf(" Hello world, this is vl53l0xExample ! \n");
	printf("---------------------------------------\n");
	printf("\n");

	initVL53L0X(1);
	// lower the return signal rate limit (default is 0.25 MCPS)
	// setSignalRateLimit(0.1);
	// increase laser pulse periods (defaults are 14 and 10 PCLKs)
	// setVcselPulsePeriod(VcselPeriodPreRange, 18);
	// setVcselPulsePeriod(VcselPeriodFinalRange, 14);
	setMeasurementTimingBudget( 200 * 1000UL );		// integrate over 200 ms per measurement

	// Main loop	
	while(1){
		readRangeSingleMillimeters( &xTraStats );	// blocks until measurement is finished
		printf("dist    = %i\n", xTraStats.rawDistance);

		if ( timeoutOccurred() ) {
			printf(" !!! Timeout !!! \n");
		}
	}
	return 0;
}
