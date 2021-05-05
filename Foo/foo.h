#ifndef FOO_H
#define FOO_H


typedef nx_struct radio_msg {
	/* Just trying some stuff */
	nx_uint16_t counter;
	nx_uint16_t senderId;
} radio_msg;

/* Just a reference, not used but already implemented by the TOS libraries
typedef nx_struct cc2420_header_t {
	nxle_uint8_t length;
	nxle_uint16_t fcf;
	nxle_uint8_t dsn;
	nxle_uint16_t destpan;
	nxle_uint16_t dest;
	nxle_uint16_t src;
	nxle_uint8_t network; // optionally included with 6LowPAN
	layer
	nxle_uint8_t type;
} cc2420_header_t;

typedef nx_struct cc2420_metadata_t {
	nx_uint8_t tx_power;
	nx_uint8_t rssi;
	nx_uint8_t lqi;
	nx_bool crc;
	nx_bool ack;
	nx_uint16_t time;
} cc2420_metadata_t;
*/
#endif