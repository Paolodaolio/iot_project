#ifndef KEEPYOURDISTANCE_H
#define KEEPYOURDISTANCE_H

typedef nx_struct allert_msg{
	nx_uint8_t senderId;
	nx_uint8_t msgCount;
} allert_msg_t;

typedef nx_struct node{
    nx_uint8_t id; 					// sender id
	nx_uint8_t counter; 			// counter related to the id-mote
	nx_uint32_t timestamp;			// timestamp of the received msg
} node_t;

enum {
  AM_RADIO_COUNT_MSG = 6,
  MOTES = 5,
  THRESHOLD = 1000,
};
#endif
