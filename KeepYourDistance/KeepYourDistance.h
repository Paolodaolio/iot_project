#ifndef KEEPYOURDISTANCE_H
#define KEEPYOURDISTANCE_H

typedef nx_struct allert_msg{
	nx_uint8_t senderId;
	nx_uint32_t msgCount;
} allert_msg_t;

enum {
  AM_RADIO_COUNT_MSG = 6,
};
#endif
