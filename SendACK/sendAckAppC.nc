/**
 *  Configuration file for wiring of sendAckC module to other common 
 *  components needed for proper functioning
 *
 *  @author Luca Pietro Borsani
 */

#include "sendAck.h"


configuration sendAckAppC {}

implementation {


/****** COMPONENTS *****/
  components MainC, sendAckC as App;
  components new AMSenderC(AM_MY_MSG);
  components new AMReceiverC(AM_MY_MSG);
  components new TimerMilliC();
  components ActiveMessageC;
  components new FakeSensorC();

/****** INTERFACES *****/
  App.Boot -> MainC.Boot;

  /****** Wire the other interfaces down here *****/
  App.Receive -> AMReceiverC;
  App.Packet -> AMSenderC;
  App.AMSend -> AMSenderC;
  App.AMControl -> ActiveMessageC;
  App.MilliTimer -> TimerMilliC;
  App.Read -> FakeSensorC;
  
  App.PacketAcknowledgements ->AMSenderC;	

}

