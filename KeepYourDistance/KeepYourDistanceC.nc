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
	node_t motes[MOTES];
	message_t packet;
	nx_uint8_t msgCount;
	
	nx_uint16_t findElement(nx_uint8_t id) {
		nx_uint16_t i;
		for(i = 0; i < MOTES; i ++){
			if(motes[i].id == id) return i;
		}
		return MOTES + 1;
	}  
	
	nx_uint16_t findFirstAvl() {
		nx_uint16_t i;
		for(i = 0; i<MOTES; i++) {
			if(motes[i].counter == 0) return i;
		}
		return MOTES + 1; //should never be reached
	}
	
	event void Boot.booted() {
		nx_uint16_t i;
		for(i = 0; i<MOTES; i++) {
			// array initialization
			motes[i].id = 0;
			motes[i].counter = 0;
			motes[i].timestamp = 0;
		}
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
				printf("KYD: packet from mote %u sent\n", TOS_NODE_ID);
				printfflush();
			}
		}

	event message_t* Receive.receive(message_t* bufPtr, void* payload, uint8_t len) {
		//nx_uint32_t ts;
		//nx_uint16_t savedIndex, firstAvlIndex;
		if(len != sizeof(allert_msg_t)) { 
			printf("[MOTE#%u]: received packet length not valid!\n",TOS_NODE_ID);
			printfflush();
			return bufPtr; 
		} else {
			allert_msg_t* amsg = (allert_msg_t*)payload;
			//ts = call LocalTime.get();
			printf("MOTE# %u met MOTE# %u at time %u with counter %u\n",TOS_NODE_ID,amsg->senderId, call LocalTime.get(), amsg->msgCount);
			printfflush();
			/*savedIndex = findElement(amsg->senderId);
			printf("[MOTE#%u]: Index found is: %u\n",TOS_NODE_ID, savedIndex);
			printfflush();
			if (savedIndex == MOTES + 1){  
				// no previously saved motes
				firstAvlIndex = findFirstAvl();
				motes[firstAvlIndex].timestamp = ts;
				motes[firstAvlIndex].counter = 1;
				motes[firstAvlIndex].msgCount = amsg->msgCount;
				motes[firstAvlIndex].id = amsg->senderId;
				printf("[MOTE#%u]: INIT index %u\n", TOS_NODE_ID, firstAvlIndex);
				printfflush();
				}
			else{
				if((motes[firstAvlIndex].msgCount == (amsg->msgCount + 1) % 256) && (call LocalTime.get() - motes[savedIndex].timestamp <= THRESHOLD)){ 
					motes[savedIndex].counter++; 
					printf("MOTE %u increased counter of %u to %u\n", TOS_NODE_ID, amsg-> senderId, motes[savedIndex].counter);
					printfflush();
					}
				else{
					motes[savedIndex].counter=1; 
					printf("MOTE %u reset counter of %u to 1\n", TOS_NODE_ID, amsg-> senderId);
				}
				motes[savedIndex].timestamp = ts;
				motes[savedIndex].msgCount = amsg->msgCount;
			}
			
			if (motes[savedIndex].counter >= 10){
				printf("MOTE#%u exceed counter with MOTE#%u \n",TOS_NODE_ID,amsg->senderId);
				printfflush();
			
			}*/
		
		} 
		return bufPtr;
	}

	event void AMSend.sendDone(message_t* bufPtr, error_t error) {
		// do nothing
	}
	
}
