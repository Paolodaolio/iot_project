#define NEW_PRINTF_SEMANTICS

#include "KeepYourDistance.h"
#include "printf.h"
/**
 * Implementation of Challenge #5
 * 
 * @author Paolo Daolio
 * @author Fabrizio Siciliano
 * @date   May 6 2021 
*/

configuration KeepYourDistanceAppC {

}

implementation {
    components MainC;
    components LocalTimeMilliC;
    components KeepYourDistanceC as App;
    components new AMSenderC(AM_RADIO_COUNT_MSG);
    components new AMReceiverC(AM_RADIO_COUNT_MSG);
    components new TimerMilliC();
    components PrintfC;
    components SerialStartC;
    components ActiveMessageC;
    
    App.Boot -> MainC.Boot;
    App.LocalTime -> LocalTimeMilliC;
    App.Receive -> AMReceiverC;
    App.AMSend -> AMSenderC;
    App.AMControl -> ActiveMessageC;
    App.MilliTimer -> TimerMilliC;
    App.Packet -> AMSenderC;
}
