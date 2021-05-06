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
		interface SplitControl as AMControl;
		interface Packet;
	}
}

implementation {
	message_t packet;
	bool locked;
	uint16_t counter = 0;
	// TODO: this must be initialized in some way
	// Note to self: neighbor discovery??
	uint16_t id = 0;

	event void Boot.booted() {
		call AMControl.start();
	}

	event void AMControl.startDone(error_t err) {
	    if (err == SUCCESS) {
	    	// The timer should be parametrized from somewhere
	    	// Note to self: neighbor discovery??
	    	switch(id % 3){
	    		case 0:
	    			call MilliTimer.startPeriodic(); // 1 Hz
    				break;
				case 1:
					call MilliTimer.startPeriodic(); // 3 Hz
    				break;
				case 2:
					call MilliTimer.startPeriodic(); // 5 Hz
    				break;
				default:
					// Never reached
					dbg("FooC", "FooC: start done, but id is not in range 0-2. Id: %hu.\n", id);
					break;
	    	}
	    }
	    else {
	      call AMControl.start();
	    }
	}

	event void AMControl.stopDone(error_t error) {
		// Do nothing (?)
	}

	// Let's suppose that the timer has been fixed and each mote has its own frequency
	// What happens when the timer fires?
	event void MilliTimer.fired() {
		if(locked) {
			return;
		}

		radio_msg* rmsg = (radio_msg*)call Packet.getPayload(&packet, sizeof(radio_msg));
		if(msg == NULL) {
			// Couldn't find anything in the payload.
			return;
		}

		msg->counter = counter;
		msg->senderId = id;
		if(call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(radio_msg)) == SUCCESS) {
			dbg("FooC", "FooC: packet from mote %hu sent with counter %hu.\n", id, counter);	
			counter++;
			locked = TRUE;
		}
	}

	event message_t* Receive.receive(message_t* bufPtr, void* payload, uint8_t len) {
		dbg("FooC", "Received packet of length %hhu.\n", len);
		if(len != sizeof(radio_msg)) { return bufPtr; }

		radio_msg* rmsg = (radio_msg*)payload;

		// Here we can turn on/off the leds

		return bufPtr;
	}

	event void AMSend.sendDone(radio_msg* bufPtr, error_t error) {
		if(&packet == bufPtr) {
			locked = FALSE;
		}
	}
}