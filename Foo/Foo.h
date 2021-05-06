#ifndef FOO_H
#define FOO_H

typedef nx_struct radio_count_msg {
	nx_uint16_t counter;
	nx_uint16_t senderId;
} radio_count_msg_t;

enum {
  AM_RADIO_COUNT_MSG = 20,
};
#endif
