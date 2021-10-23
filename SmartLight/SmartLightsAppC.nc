#include "SmartLights.h"

configuration SmartLightsAppC {}
implementation {
  components MainC, SmartLightsC as App, LedsC;
  components new AMSenderC(AM_RADIO_COUNT_MSG);
  components new AMReceiverC(AM_RADIO_COUNT_MSG);
  components new TimerMilliC();
  components PrintfC;
  components SerialStartC;
  components ActiveMessageC;
  
  App.Boot -> MainC.Boot;
  App.Receive -> AMReceiverC;
  App.AMSend -> AMSenderC;
  App.AMControl -> ActiveMessageC;
  App.Leds -> LedsC;
  App.Packet -> AMSenderC;
}