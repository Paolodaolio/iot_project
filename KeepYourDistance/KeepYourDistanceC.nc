#include "printf.h"
#include "KeepYourDistance.h"
#include "Timer.h"
/**
 * Implementation of Challenge #5
 * 
 * @author Paolo Daolio
 * @author Fabrizio Siciliano
 * @date   May 6 2021 
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
	node_t* motes[MOTES];
	message_t packet;
	
	event void Boot.booted() {
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

	event void AMControl.stopDone(error_t error) {
	}


	event void MilliTimer.fired() {
			allert_msg_t* amsg = (allert_msg_t*)call Packet.getPayload(&packet, sizeof(allert_msg_t));
			if(amsg == NULL) {
				return;
			}
			amsg->senderId = TOS_NODE_ID;
			if(call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(allert_msg_t)) == SUCCESS) {
				dbg("KeepYourDistance", "KYD: packet from mote %u sent\n", TOS_NODE_ID);
			}
		}

	event message_t* Receive.receive(message_t* bufPtr, void* payload, uint8_t len) {
		nx_uint32_t ts;
		dbg("KeepYourDistance", "Received packet of length %u.\n", len);
		if(len != sizeof(allert_msg_t)) { 
			return bufPtr; 
		} else {
			allert_msg_t* amsg = (allert_msg_t*)payload;
			ts = call LocalTime.get(); 
			if (motes[amsg->senderId]==NULL){   									// USIAMO ID COME INDICE PER L'ARRAY
				node_t* tmp = (node_t*)malloc(sizeof(node_t));
				tmp -> counter = 1;
				tmp -> timestamp = ts;
				motes[amsg->senderId] = tmp;
				printf("MOTE %u INIT at index %u\n", TOS_NODE_ID, amsg-> senderId);
				printfflush();
				}
			else{
				if(call LocalTime.get() - motes[amsg->senderId]->timestamp < THRESHOLD){
					motes[amsg->senderId]->counter++; 
					printf("MOTE %u increased counter of %u to %u\n", TOS_NODE_ID, amsg-> senderId, motes[amsg->senderId]->counter);
					printfflush();
					}
				else{
					motes[amsg->senderId]->counter=1;  // RESET TODO DBG HERE PLZ
					printf("MOTE %u reset counter of %u to 1\n", TOS_NODE_ID, amsg-> senderId);
				}
			motes[amsg->senderId]->timestamp = ts;
			}
			if (motes[amsg->senderId]->counter >= 10){
				printf("MOTE#%u exceed counter with MOTE#%u \n",TOS_NODE_ID,amsg->senderId);
				printfflush();
			
			}
		
		} 
		return bufPtr;
	}

	event void AMSend.sendDone(message_t* bufPtr, error_t error) {
		// do nothing
	}
	
}
