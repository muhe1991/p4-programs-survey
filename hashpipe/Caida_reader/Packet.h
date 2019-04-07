
#ifndef PACKET_H
#define PACKET_H

class Packet {
public:
	double time; //not important right now.
	unsigned int source_ip;
	unsigned int dest_ip;
	unsigned short source_port;
	unsigned short dest_port;
	unsigned char protocol;
	bool valid;
	int instances;
	int serial_number;
	bool operator==(const Packet &other) const {
		return ((other.source_ip == this->source_ip)&&
			(other.dest_ip == this->dest_ip)&&
			(other.source_port == this->source_port)&&
			(other.dest_port == this->dest_port)&&
			(other.protocol == this->protocol));
	}


};


#endif
