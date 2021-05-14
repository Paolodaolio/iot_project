/**
 *  Source file for implementation of module sendAckC in which
 *  the node 1 send a request to node 2 until it receives a response.
 *  The reply message contains a reading from the Fake Sensor.
 *
 *  @author Luca Pietro Borsani
 */

#include "sendAck.h"
#include "Timer.h"

module sendAckC @safe(){

  uses {
  /****** INTERFACES *****/
	interface Boot; 
	interface Receive;
    interface AMSend;
    interface PacketAcknowledgements;
    interface Timer<TMilli> as MilliTimer;
    interface SplitControl as AMControl;
    interface Packet;
	interface Read<uint16_t>;
  }

} implementation {

  uint8_t counter=0;
  uint8_t rec_id;
  message_t packet;
  void sendReq();
  void sendResp();
  
  
  //***************** Send request function ********************//
  void sendReq(){
	/* This function is called when we want to send a request
	 *
	 * STEPS:
	 * 1. Prepare the msg
	 * 2. Set the ACK flag for the message using the PacketAcknowledgements interface
	 *     (read the docs)
	 * 3. Send an UNICAST message to the correct node ??
	 * X. Use debug statements showing what's happening (i.e. message fields)
	 */
	my_msg_t* rcm = (my_msg_t*)call Packet.getPayload(&packet, sizeof(my_msg_t));
	if (rcm == NULL) {
		return;
	  }
	rcm -> counter = counter;
	rcm -> type = REQ;
 	dbg("radio_pack","[sendReq] - Preparing the message... \n");
	if(call PacketAcknowledgements.requestAck(&packet) == SUCCESS) {
		if(call AMSend.send(2, &packet,sizeof(my_msg_t)) == SUCCESS){
			dbg("radio_send", "[sendReq] - Packet passed to lower layer successfully!\n");
			dbg("radio_send","[sendReq] - >>>Pack\n");
			dbg_clear("radio_send","\t\t[sendReq] - Payload Sent\n" );
			dbg_clear("radio_send", "\t\t[sendReq] - counter: %hhu \n ", rcm->counter);
			dbg_clear("radio_send", "\t\t[sendReq] - type: %hhu \n", rcm->type);
		}
	}
}        

  //****************** Task send response *****************//
  void sendResp() {
  	/* This function is called when we receive the REQ message.
  	 * Nothing to do here. 
  	 * `call Read.read()` reads from the fake sensor.
  	 * When the reading is done it raise the event read one.
  	 */
	call Read.read();
  }

  //***************** Boot interface ********************//
  event void Boot.booted() {
    dbg("boot","[Boot] - Application booted.\n");
    call AMControl.start();
  }

  //***************** SplitControl interface ********************//
  event void AMControl.startDone(error_t err){
	if (err == SUCCESS) {
		  dbg("radio","[startDone] - Radio on on node %d!\n", TOS_NODE_ID);
		  call MilliTimer.startPeriodic(1000);
	} else {
		  dbgerror("radio", "[startDone] - Radio failed to start, retrying...\n");
		  call AMControl.start();
	}
  }

  
  event void AMControl.stopDone(error_t err){
	dbg("boot", "[stopDone] - Radio stopped!\n");
  }

  //***************** MilliTimer interface ********************//
  event void MilliTimer.fired() {
  // Send only if node id is 1
  	if (TOS_NODE_ID == 1){
		my_msg_t* rcm = (my_msg_t*)call Packet.getPayload(&packet, sizeof(my_msg_t));
	
		dbg("timer", "[fired] - Timer fired, counter is %hu.\n", counter);

		if (rcm == NULL) {
			return;
		}
		rcm->counter = counter;
		sendReq();
		counter++;
	}
  }


  //********************* AMSend interface ****************//
  event void AMSend.sendDone(message_t* buf,error_t err) {
	/* This event is triggered when a message is sent 
	 *
	 * STEPS:
	 * 1. Check if the packet is sent
	 * 2. Check if the ACK is received (read the docs)
	 * 2a. If yes, stop the timer. The program is done
	 * 2b. Otherwise, send again the request
	 * X. Use debug statements showing what's happening (i.e. message fields)
	 */
	  my_msg_t* msg = (my_msg_t*)call Packet.getPayload(&packet, sizeof(my_msg_t));
	  if (&packet == buf && err == SUCCESS) {
      	dbg("radio_send", "[sendDone] - Packet sent...");
      	dbg_clear("radio_send", " at time %s \n", sim_time_string());
      	
      	if (call PacketAcknowledgements.wasAcked(buf)){
      			dbg("radio_rec", "\t\t[sendDone] - Payload of received message:\n");
     			dbg("radio_rec", "\t\t[sendDone] - counter: %u\n", msg -> counter);
     			dbg("radio_rec", "\t\t[sendDone] - sensor: %u\n", msg -> sensor);
	     		dbg("radio_rec", "\t\t[sendDone] - type: %u\n", msg -> type);
      		if (msg->type == RESP){
	      		dbg("radio_pack", "[sendDone] - Message acked RESP\n");
  		     	/*dbg("radio_rec", "\tType of message is %u\n", msg -> type);
     			dbg("radio_rec", "\tCounter of message is %u\n", msg -> counter);
     			dbg("radio_rec", "\tSensor of message is %u\n", msg -> sensor);*/
      			} else{
		  		dbg("radio_pack", "[sendDone] - Message acked REQ, stopping timer\n");
		  		call MilliTimer.stop();
      	  	}
      	  }
    	} else {
      		dbgerror("radio_send", "[sendDone] - packet not acked");
      		dbgerror("radio_send", "sending request again\n");
      		sendReq();
      }
  }
  

  event message_t* Receive.receive(message_t* buf,void* payload, uint8_t len) {
	/* This event is triggered when a message is received 
	 *
	 * STEPS:
	 * 1. Read the content of the message
	 * 2. Check if the type is request (REQ)
	 * 3. If a request is received, send the response
	 * X. Use debug statements showing what's happening (i.e. message fields)
	 */
	 dbg("radio_rec", "[receive] - Message received with length %u, processing...\n", sizeof(my_msg_t));
     if (len != sizeof(my_msg_t)) {return buf;}
     else { 
     	my_msg_t* msg = (my_msg_t*)payload;
		dbg("radio_rec", "[receive] - Received packet at time %s\n", sim_time_string());
		dbg("radio_rec", "[receive] - >>>Pack \n", call Packet.payloadLength( buf ));
		dbg_clear("radio_rec","\t\t[receive] - Payload: \n" );
		dbg_clear("radio_rec", "\t\t[receive] - counter: %hhu \n", msg->counter);
		dbg_clear("radio_rec", "\t\t[receive] - type: %hhu \n", msg->type);
		dbg_clear("radio_rec", "\t\t[receive] - sensor: %u\n", msg->sensor);
     	
	 	if (msg -> type == REQ){	
 			dbg("radio_rec", "[receive] - message received is REQ\n");
	 		counter = msg -> counter;
	  		sendResp();	
			}
	  	}
	  	return buf;
  	}

  
  
  
  //************************* Read interface **********************//
  event void Read.readDone(error_t result, uint16_t data) {
	/* This event is triggered when the fake sensor finish to read (after a Read.read()) 
	 *
	 * STEPS:
	 * 1. Prepare the response (RESP)
	 * 2. Send back (with a unicast message) the response
	 * X. Use debug statement showing what's happening (i.e. message fields)
	 */
 	 my_msg_t* rcm = (my_msg_t*)call Packet.getPayload(&packet, sizeof(my_msg_t));
	 rcm -> type = RESP;
	 rcm -> sensor = data;
	 rcm -> counter = counter;
	 dbg("radio_send", "[readDone] - Data ready to be sent\n");
	 if(call PacketAcknowledgements.requestAck(&packet) == SUCCESS) {
		 if (call AMSend.send(1, &packet, sizeof(my_msg_t)) == SUCCESS) {
			dbg("radio_send", "[readDone] - Sending packet...");	
			dbg_clear("radio_send", " at time %s \n", sim_time_string());
			}
		}
	}
}
	
	
	
	
