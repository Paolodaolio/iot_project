#include "printf.h"
#include "KeepYourDistance.h"
#include "Timer.h"
/**
 * Implementation of IoT project
 * 
 * @author Paolo Daolio
 * @author Fabrizio Siciliano
 * @date   June 29 2021 
*/

module KeepYourDistanceC @safe() {
	uses {
		interface Boot;
		interface Receive;
		interface Timer<TMilli> as MilliTimer;
		interface AMSend;

		interface SplitControl as AMControl;
		interface Packet;
		interface LocalTime<TMilli>;
	}
}

implementation {

	message_t packet;
	nx_uint32_t msgCount;	
	
	event void Boot.booted() {
		msgCount = 0;
		call AMControl.start();
	}
	
	event void AMControl.startDone(error_t err) {
	    if (err == SUCCESS) {	    	
    		call MilliTimer.startPeriodic(500); // 0.5 Hz
	    }
	    else {
	      call AMControl.start();
	    }
	}

	event void AMControl.stopDone(error_t error) {}

	event void MilliTimer.fired() {
			allert_msg_t* amsg = (allert_msg_t*)call Packet.getPayload(&packet, sizeof(allert_msg_t));
			if(amsg == NULL) {
				return;
			}
			amsg->senderId = TOS_NODE_ID;
			amsg->msgCount = msgCount;
			msgCount++;
			if(call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(allert_msg_t)) == SUCCESS) {
			}
		}

	event message_t* Receive.receive(message_t* bufPtr, void* payload, uint8_t len) {
		if(len != sizeof(allert_msg_t)) { 
			printf("[MOTE#%u]: received packet length not valid!\n",TOS_NODE_ID);
			printfflush();
			return bufPtr; 
		} else {
			allert_msg_t* amsg = (allert_msg_t*)payload;
			printf("MOTE# %u met MOTE# %u with counter %u\n",TOS_NODE_ID,amsg->senderId, amsg->msgCount);
			printfflush();
		} 
		return bufPtr;
	}

	event void AMSend.sendDone(message_t* bufPtr, error_t error) {
		// do nothing
	}
	
}
