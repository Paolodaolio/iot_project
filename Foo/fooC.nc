#include "foo.h"

/**
* Implementation of Challenge #5 
* by Paolo Daolio 
* and Fabrizio Siciliano
*/

module RadioLEDs @safe() {
	uses {
		interface Leds;
		interface Boot;
		interface Receive;
		interface Timer<TMilli> as MilliTimer;
		interface AMSend;
		interface SplitControl as AMControl; //what the heck is this?
		interface Packet;
	}
}

implementation {
	radio_msg message;
	bool locked;
	uint8_t counter = 0;

	event void Boot.booted() {
		call AMControl.start();
	}

	event void AMControl.startDone(error_t err) {
	    if (err == SUCCESS) {
	    	// The timer should be parametrized from somewhere
	      	call MilliTimer.startPeriodic(250);
	    }
	    else {
	      call AMControl.start();
	    }
	  }

	event void AMSend.sendDone(radio_msg* bufPtr, error_t error) {
		if(&packet == bufPtr) {
			locked = TRUE;
		}
	}
}