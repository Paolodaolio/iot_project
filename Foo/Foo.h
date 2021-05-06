#ifndef FOO_H
#define FOO_H

typedef nx_struct radio_msg {
	nx_uint16_t counter;
	nx_uint16_t senderId;
} radio_msg_t;

enum {
  AM_RADIO_COUNT_MSG = 20,
};
#endif
