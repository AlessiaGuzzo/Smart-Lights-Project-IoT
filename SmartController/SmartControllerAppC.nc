#include "SmartController.h"

configuration SmartControllerAppC {}
implementation {
  components MainC, SmartControllerC as App, LedsC;
  components new AMSenderC(AM_RADIO_COUNT_MSG);
  //components new AMReceiverC(AM_RADIO_COUNT_MSG);
  components new TimerMilliC() as OnTimer;
  components new TimerMilliC() as OffTimer;
  components PrintfC;
  components SerialStartC;
  components ActiveMessageC;
  
  App.Boot -> MainC.Boot;
  App.AMSend -> AMSenderC;
  App.AMControl -> ActiveMessageC;
  App.Leds -> LedsC;
  App.Timer0 -> OffTimer;
  App.Timer1 -> OnTimer;
  App.Packet -> AMSenderC;
}