

#include "PCAPReader.h"
#include "string.h"

PCAPReader::PCAPReader (char const* filename) {
    
	//strcpy_s(fname,FILE_NAME_LEN,filename) ;
    //strncpy(fname,filename,FILE_NAME_LEN) ;
    //f = fopen(fname,"rb");
    //printf("file: %s\n", filename);
    f = fopen(filename, "rb");
    if (f == NULL) {
        printf("There are problems with file\n");
    }
    
   fread(&header,sizeof(pcap_header),1,f);
   
    packet_counter = 0;
}

void PCAPReader::read_packet(Packet &p){

	packet_counter++;
	p.valid = true;

	packet_header p_header;
	fread(&p_header,sizeof(packet_header),1,f);
	int cur_pos = ftell(f);
	IP_header ip_header;
	fread(&ip_header,sizeof(IP_header),1,f);
	if (ip_header.version_IHL != 0x45){
		p.valid = false;
		fseek(f,cur_pos+p_header.size_in_file,SEEK_SET);
		return;
	};

	p.time = (double)p_header.time_sec + (double)p_header.time_msec / 1e6 ;
    
    //printf("Time: %d,  %d \n", p_header.time_sec, p_header.time_msec);
    
	p.dest_ip = ip_header.DestinationIP;
	p.source_ip = ip_header.SourceIP;
    
    
    
    // Only for masking
    //int hash_width = 12;
    //unsigned int mask = 0xFFFFFFFF;
    //mask = mask << (32-hash_width);
    //p.dest_ip = p.dest_ip & mask;
    //p.source_ip = p.source_ip & mask;
    
    
    
    
    
    
    
    
    
    
	p.protocol = ip_header.protocol;

	switch (p.protocol) {
		case 6: 
			TCP_header tcp_header;
			fread(&tcp_header,sizeof(TCP_header),1,f);
			p.source_port = tcp_header.source_port;
			p.dest_port = tcp_header.destination_port;
            
            p.dest_ip = p.dest_port; // Delete
            break;
		case 17: UDP_header udp_header;
			fread(&udp_header,sizeof(UDP_header),1,f);
			p.source_port = udp_header.source_port;
			p.dest_port = udp_header.destination_port;
            
            p.dest_ip = p.dest_port; // Delete
			break;
		default:
			p.valid = false;
			break;
	}
	fseek(f,cur_pos+p_header.size_in_file,SEEK_SET);
}

PCAPReader::~PCAPReader () {
	fclose(f);	
}
