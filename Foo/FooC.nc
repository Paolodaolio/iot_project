#include "Foo.h"
#include "Timer.h"
/**
 * Implementation of Challenge #5
 * 
 * @author Paolo Daolio
 * @author Fabrizio Siciliano
 * @date   May 6 2021 
*/

module FooC @safe() {
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

	event void Boot.booted() {
		call AMControl.start();
	}

	event void AMControl.startDone(error_t err) {
	    if (err == SUCCESS) {
	    	switch(TOS_NODE_ID){
	    		case 1:
	    			call MilliTimer.startPeriodic(1000); // 1 Hz
    				break;
			case 2:
				call MilliTimer.startPeriodic(333); // 3 Hz
    				break;
			case 3:
				call MilliTimer.startPeriodic(200); // 5 Hz
    				break;
			default:
				// Never reached
				dbg("FooC", "FooC: start done, but TOS_NODE_ID is not in range 0-2. Id: %hu.\n", TOS_NODE_ID);
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
		} else {
			radio_count_msg_t* rmsg = (radio_count_msg_t*)call Packet.getPayload(&packet, sizeof(radio_count_msg_t));
			if(rmsg == NULL) {
				// Couldn't find anything in the payload.
				return;
			}

			rmsg->counter = counter;
			rmsg->senderId = TOS_NODE_ID;
			if(call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(radio_count_msg_t)) == SUCCESS) {
				dbg("FooC", "FooC: packet from mote %hu sent with counter %hu.\n", TOS_NODE_ID, counter);
				locked = TRUE;
			}
		}
	}

	event message_t* Receive.receive(message_t* bufPtr, void* payload, uint8_t len) {
		dbg("FooC", "Received packet of length %hhu.\n", len);
		if(len != sizeof(radio_count_msg_t)) { 
			return bufPtr; 
		} else {
			radio_count_msg_t* rmsg = (radio_count_msg_t*)payload;

			// Here we can turn on/off the leds

			if(rmsg->counter % 10 == 0) {
				call Leds.led0Off();
				call Leds.led1Off();
				call Leds.led2Off();
				// turn off all LEDs
			} else {
				switch(rmsg->senderId) {
					case 1:
						// toggle LED0
						call Leds.led0Toggle();
						break;
					case 2:
						// toggle LED1
						call Leds.led1Toggle();
						break;
					case 3:
						// toggle LED2
						call Leds.led2Toggle();
						break;
					default:
						// all other senders must be ignored
						break;
				}
			}
		}
		counter++;
		return bufPtr;
	}

	event void AMSend.sendDone(message_t* bufPtr, error_t error) {
		if(&packet == bufPtr) {
			locked = FALSE;
		}
	}
}
