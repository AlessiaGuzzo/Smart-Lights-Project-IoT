#ifndef SMART_LIGHTS_H
#define SMART_LIGHTS_H

typedef nx_struct light_msg {
  nx_uint16_t pattern_vector[9];
  nx_uint16_t senderID;
} light_msg_t;

enum {
  AM_RADIO_COUNT_MSG = 6,
};

#endif