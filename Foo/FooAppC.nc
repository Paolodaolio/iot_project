#include "Foo.h"

/**
 * Implementation of Challenge #5
 * 
 * @author Paolo Daolio
 * @author Fabrizio Siciliano
 * @date   May 6 2021 
*/

configuration FooAppC {

}

implementation {
    components MainC, FooC as App, LedsC;
    components new AMSenderC(AM_RADIO_COUNT_MSG);
    components new AMReceiverC(AM_RADIO_COUNT_MSG);
    components new TimerMilliC();
    components ActiveMessageC;
    
    App.Boot -> MainC.Boot;

    App.Receive -> AMReceiverC;
    App.AMSend -> AMSenderC;
    App.AMControl -> ActiveMessageC;
    App.Leds -> LedsC;
    App.MilliTimer -> TimerMilliC;
    App.Packet -> AMSenderC;
}
