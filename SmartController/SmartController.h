#ifndef SMART_CONTROLLER_H
#define SMART_CONTROLLER_H

typedef nx_struct smartl_msg {
  nx_uint16_t  pattern_vector[9];
  nx_uint16_t senderID; 
} light_msg_t;

enum {
  AM_RADIO_COUNT_MSG = 6,
};

#endif