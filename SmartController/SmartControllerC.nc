#include "Timer.h"
#include "SmartController.h"
#include "printf.h" 
#define T_NEXT_SEND 50
#define T_NEXT_PATTERN 5000
 
module SmartControllerC @safe() {
  uses {
    interface Leds;
    interface Boot;
    interface AMSend;
    interface Timer<TMilli> as Timer0; //OffTimer
    interface Timer<TMilli> as Timer1; //OnTimer
    interface SplitControl as AMControl;
    interface Packet;
  }
}
implementation {

  message_t packet;
  uint8_t pattern = 1; //variable used to manage the pattern schedule
  uint8_t mex_num = 2; //variable used to manage the UNICAST messages sending phase
  uint8_t i,j;
  
  bool locked=FALSE;
  uint16_t pattern_vector_triangle[] = {0, 0, 1, 0, 1, 1, 0, 0, 1}; 
  uint16_t pattern_vector_cross[] = {1, 0, 1, 0, 1, 0, 1, 0, 1};
  uint16_t pattern_vector_diamond[] = {0, 1, 0, 1, 0, 1, 0, 1, 0};
  uint16_t pattern_vector_off[] = {0, 0, 0, 0, 0, 0, 0, 0, 0};   
 


  event void Boot.booted() {
	printf("The Application is booted.\n");
	printfflush();
    call AMControl.start(); //start the AMControl interface of the radio
   	call Timer0.stop();
   	call Timer1.stop();
  }
  
  
  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) { //started with no errors
    	call Timer0.startOneShot(3000);
    	printf("Radio ON!\n");
		printfflush();
    }else{
    	printf("Radio error trying to turning on again...\n");
		printfflush();
      	call AMControl.start();
    }
  }
  
  
  //Manage the event OffTimer fired
  event void Timer0.fired() {
	printf("OffTime fired.\n");
	printfflush();
	
	if (locked) {
    	return;
    } else {
    	light_msg_t* rcm = (light_msg_t*)call Packet.getPayload(&packet, sizeof(light_msg_t)); //create payload of the size we want
    	if (rcm == NULL) {
			return;
    	}

    	rcm->senderID = TOS_NODE_ID; //put ID of the sender mote to senderID
	
		for (i = 0; i < 9; i++) { //assign the correspondent pattern
       		rcm->pattern_vector[i] = pattern_vector_off[i];
    	}
    		
		//send UNICAST packet to 2,5,8
		if(mex_num==2){
    		if (call AMSend.send(2, &packet, sizeof(light_msg_t)) == SUCCESS) {
				locked = TRUE; //free variable
				mex_num=5;   
				printf("Packet sent by %u to 2 with off pattern.\n", TOS_NODE_ID);
				printfflush();    
				call Timer0.startOneShot(T_NEXT_SEND); 			
    		}
		}
    			
   		if(mex_num==5){	
   			if (call AMSend.send(5, &packet, sizeof(light_msg_t)) == SUCCESS) {	
				locked = TRUE; //free variable
				mex_num=8;
				printf("Packet sent by %u to 5 with off pattern.\n", TOS_NODE_ID);
				printfflush();
				call Timer0.startOneShot(T_NEXT_SEND);
			}
		}
 
 		if(mex_num==8){
    		if (call AMSend.send(8, &packet, sizeof(light_msg_t)) == SUCCESS) {	
				locked = TRUE; //free variable
				mex_num=2; 
				printf("Packet sent by %u to 8 with off pattern.\n", TOS_NODE_ID);
				printfflush();
				call Timer1.startOneShot(T_NEXT_PATTERN); 		
    		}
		}				
    }
  }
	
  //Manage the event OnTimer fired
  event void Timer1.fired() { 
  	printf("OnTime fired.\n");
	printfflush();
	if (locked) {
    	return;
    } else {
    	light_msg_t* rcm = (light_msg_t*)call Packet.getPayload(&packet, sizeof(light_msg_t)); //create payload of the size we want
    	if (rcm == NULL) {
			return;
    	}

    	rcm->senderID = TOS_NODE_ID; //put ID of the sender mote to senderID
      		
		if (pattern == 1) {
		
	    	for (i = 0; i < 9; i++) { //assign the correspondent pattern
            		rcm->pattern_vector[i] = pattern_vector_triangle[i];
        		}
	    
	    	//send UNICAST packet to 2,5,8
	    	if(mex_num==2){
    			if (call AMSend.send(2, &packet, sizeof(light_msg_t)) == SUCCESS) {	
					locked = TRUE; //free variable
					mex_num=5;   
					printf("Packet sent by %u to 2 with triangle pattern.\n", TOS_NODE_ID);
					printfflush(); 
					call Timer1.startOneShot(T_NEXT_SEND);   			
    			}
    		}
    			
    		if(mex_num==5){	
    			if (call AMSend.send(5, &packet, sizeof(light_msg_t)) == SUCCESS) {	
					locked = TRUE; //free variable
					mex_num=8;
					printf("Packet sent by %u to 5 with triangle pattern.\n", TOS_NODE_ID);
					printfflush();
					call Timer1.startOneShot(T_NEXT_SEND);
    			}
    		}
 
 			if(mex_num==8){
    			if (call AMSend.send(8, &packet, sizeof(light_msg_t)) == SUCCESS) {	
					locked = TRUE; //free variable
					mex_num=2;
					printf("Packet sent by %u to 8 with triangle pattern.\n", TOS_NODE_ID);
					printfflush();
					pattern++;
					call Timer0.startOneShot(T_NEXT_PATTERN); 
				}
			}

		} else if (pattern == 2) {
		
	    	for (i = 0; i < 9; i++) { //assign the correspondent pattern
            	rcm->pattern_vector[i] = pattern_vector_cross[i];
        	}
        	
        	//send UNICAST packet to 2,5,8	
	    	if(mex_num==2){
    			if (call AMSend.send(2, &packet, sizeof(light_msg_t)) == SUCCESS) {	
					locked = TRUE; //free variable
					mex_num=5;
					printf("Packet sent by %u to 2 with cross pattern.\n", TOS_NODE_ID);
					printfflush();    
					call Timer1.startOneShot(T_NEXT_SEND);		
    			}
    		}
    			
    		if(mex_num==5){	
    			if (call AMSend.send(5, &packet, sizeof(light_msg_t)) == SUCCESS) {	
					locked = TRUE; //free variable
					mex_num=8; 
					printf("Packet sent by %u to 5 with cross pattern.\n", TOS_NODE_ID);
					printfflush();
					call Timer1.startOneShot(T_NEXT_SEND);
    			}
    		}
 
 			if(mex_num==8){
    			if (call AMSend.send(8, &packet, sizeof(light_msg_t)) == SUCCESS) {	
					locked = TRUE; //free variable
					mex_num=2; 
					printf("Packet sent by %u to 8 with cross pattern.\n", TOS_NODE_ID);
					printfflush();
					pattern++;
					call Timer0.startOneShot(T_NEXT_PATTERN); 
    			}
    		}

    	} else if (pattern == 3) {
    	
	    	for (i = 0; i < 9; i++) { //assign the correspondent pattern
            	rcm->pattern_vector[i] = pattern_vector_diamond[i];
        	}
        	
        	//send UNICAST packet to 2,5,8
	    	if(mex_num==2){
    			if (call AMSend.send(2, &packet, sizeof(light_msg_t)) == SUCCESS) {	
					locked = TRUE; //free variable
					mex_num=5;
        			printf("Packet sent by %u to 2 with diamond pattern.\n", TOS_NODE_ID);
					printfflush(); 
					call Timer1.startOneShot(T_NEXT_SEND);   			
    			}
    		}
    			
    		if(mex_num==5){	
    			if (call AMSend.send(5, &packet, sizeof(light_msg_t)) == SUCCESS) {	
					locked = TRUE; //free variable
					mex_num=8;   
					printf("Packet sent by %u to 5 with diamond pattern.\n", TOS_NODE_ID);
					printfflush();
					call Timer1.startOneShot(T_NEXT_SEND);
    			}
    		}
 
 			if(mex_num==8){
    			if (call AMSend.send(8, &packet, sizeof(light_msg_t)) == SUCCESS) {	
					locked = TRUE; //free variable
					mex_num=2;   
					printf("Packet sent by %u to 8 with diamond pattern.\n", TOS_NODE_ID);
					printfflush();
					pattern=1;
					call Timer0.startOneShot(T_NEXT_PATTERN);				
    			}
    		}
		}
    }
  }
  
  
  event void AMControl.stopDone(error_t err) { //stop the radio
    // do nothing
  }


  event void AMSend.sendDone(message_t* bufPtr, error_t error) {
  	printf("Send Done!"); 
	printfflush();
    if (&packet == bufPtr) {
      locked = FALSE;
    }
  }
  
}