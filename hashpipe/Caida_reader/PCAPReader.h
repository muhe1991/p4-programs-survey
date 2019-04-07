#ifndef PCAPReader_H
#define PCAPReader_H

#include "stdio.h"
#include "Packet.h"


typedef struct pcap_header {
	unsigned int magic;
	short major_ver;
	short minor_ver;
	unsigned int unused1;
	unsigned int unused2;
	unsigned int maximum_saved;
	unsigned int link_type;
} pcap_header;

typedef struct packet_header {
	unsigned int time_sec;
	unsigned int time_msec;
	unsigned int size_in_file;
	unsigned int orig_size;
} packet_header ;

typedef struct IP_header {
	unsigned char version_IHL;
	unsigned char services;
	unsigned short total_length;
	unsigned short identification;
	unsigned short flags_fragOffset;
	unsigned char TTL;
	unsigned char protocol;
	unsigned short header_checksum;
	unsigned int SourceIP;
	unsigned int DestinationIP;
} IP_header ;


typedef struct TCP_header {
	unsigned short source_port;
	unsigned short destination_port;
	unsigned int seq_number;
	unsigned int ack_number;
	unsigned int unused1;
	unsigned int unused2;
} TCP_header ;


typedef struct UDP_header {
	unsigned short source_port;
	unsigned short destination_port;
	unsigned short length;
	unsigned short checksum;
} UDP_header ;

class PCAPReader {

#define FILE_NAME_LEN 255

private:
	FILE* f;
	char fname[FILE_NAME_LEN];
	char temp[1024];
	pcap_header header;
	int packet_counter;
public:
	PCAPReader(char const* filename);
	void read_packet(Packet &p);
	~PCAPReader() ;
};

#endif
