#include "Timer.h"
#include "SmartLights.h"
#include "printf.h" 
 
module SmartLightsC @safe() {
  uses {
    interface Leds;
    interface Boot;
    interface Receive;
    interface AMSend;
    interface SplitControl as AMControl;
    interface Packet;
  }
}
implementation {

  message_t packet;
  bool locked;
  uint8_t i;
  

  event void Boot.booted() {
    call AMControl.start(); //start the AMControl interface of the radio
  }

  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) { //started with no errors
    }
    else {
      call AMControl.start();
    }
  }
  
  event void AMControl.stopDone(error_t err) { //stop the radio
    // do nothing
  }
  
  event message_t* Receive.receive(message_t* bufPtr, void* payload, uint8_t len) {
    
    if (len != sizeof(light_msg_t)) {
    	printf("Packet malformed");
       	printfflush();
    	return bufPtr;
    }else {

      light_msg_t* rcm = (light_msg_t*)payload; //extract the payload of the received packet
      light_msg_t* new_pack = (light_msg_t*) (call Packet.getPayload(&packet, sizeof(light_msg_t))); //create payload of the size we want
 
      printf("Message received by mote %u from sender: %u.\n",TOS_NODE_ID, (rcm->senderID));
      printfflush();
   
      //check if senderID is the controller(1) or the previous numerical mote
      if ((rcm->senderID==1) || (rcm->senderID==TOS_NODE_ID-1))
      {
      
        for (i = 0; i < 9; i++) {
            new_pack->pattern_vector[i]=rcm->pattern_vector[i]; //save in pattern_vector of the light node the values of array patter_vector sent by the controller
        }
       	
       	if(rcm->pattern_vector[TOS_NODE_ID-2]==0){
       		call Leds.led0Off();
       		printf("LEDs of node %u off.\n",TOS_NODE_ID);
       		printfflush();
       		
       		if((rcm->senderID==3) || (rcm->senderID==6) || (rcm->senderID==9)){
				//i'm in the last node of the branch: do nothing
			} else {
				new_pack->senderID=TOS_NODE_ID;
				printf("Increment the senderID of the packet of mote %u to value %u.\n",TOS_NODE_ID, TOS_NODE_ID);
       			printfflush();
       	
       			if (call AMSend.send(TOS_NODE_ID+1, &packet, sizeof(light_msg_t)) == SUCCESS) {	//send the message to the following mote
					locked = TRUE; //free variable
					printf("Packet sent by %u.\n", TOS_NODE_ID);
					printfflush();
    			}
			}
       	}else{
       		call Leds.led0On();
       		printf("LEDs of node %u on.\n",TOS_NODE_ID);
       		printfflush();
       		if( (rcm->senderID==3) || (rcm->senderID==6) || (rcm->senderID==9)){
				//i'm in the last node of the branch: do nothing
			} else {
				new_pack->senderID=TOS_NODE_ID;
				printf("Increment the senderID of the packet of mote %u to value %u.\n",TOS_NODE_ID, TOS_NODE_ID);
       			printfflush();
       	
       			if (call AMSend.send(TOS_NODE_ID+1, &packet, sizeof(light_msg_t)) == SUCCESS) {	
					locked = TRUE; //free variable
					printf("Packet sent by %u.\n", TOS_NODE_ID);
					printfflush();
    			}
			}
       	}
	}
    return bufPtr;
  	}
  }


  event void AMSend.sendDone(message_t* bufPtr, error_t error) {
    if (&packet == bufPtr) {
      locked = FALSE;
    }
  }

}