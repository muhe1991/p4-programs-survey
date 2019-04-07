
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include <iostream>
//#include <vector.h>
#include <list>

#include "PCAPReader.h"

using namespace std;

#define MAX_K 8
#define MAX_ALPHA_NUM 20
#define MAX_ELEMENT_TYPES 15
#define MAX_COUNT_VAL 32
#define MAX_MUL_VAL 1000


#define MAX_HIST_VAL 5000


unsigned int hash_ip(unsigned int addr, int width) {
    unsigned int mask = 0xFFFFFFFF;
    //cout<<"mask  :"<<mask<<endl;
    mask = mask << (32-width);
    unsigned int masked_addr = addr & mask;
    //cout<<"mask:"<<mask<<"   "<<addr<<"  "<<masked_addr<<endl;
    masked_addr = masked_addr >> (32-width);
    return masked_addr;
    
}

int main() {

    int m;
    int bits_per_bucket = 4;

    int i, j;
    
    int mul, cnt;    
    int max_mul_print_bound = 200;
    
    int hist_mul[MAX_MUL_VAL][2];
    
    int size = 3113;
    int hash_width = 3;
    
    
    int offset = 0;//2000;
    int jump = 100;
    int total = 0;
    
    //int max_packets = 100; //1024 * 512;
    int max_packets = 14990000;//720924;
    int packets_processed = 0;
    int max_src_ip_in_bucket_cnt;
    int max_dst_per_src, dst_per_src;
    int place;
    unsigned int src_ip_cur;
    int debug = 0;
    list<Packet>::iterator iter;

    int log_orig = 0;
    int log_hashed = 0;
    int log_summary = 0;
    int pkt_index = -1;
    
    const char* pcap_file_name = "/Users/orir/data.caida.org/datasets/passive-2015/equinix-chicago/20150917-130000.UTC/equinix-chicago.dirA.20150917-125911.UTC.anon.pcap";

   // const char* pcap_file_name = "/Users/orir/a.pcap";

    Packet p;
    

    std::list <Packet> *p_list = new list<Packet> [size];
    
    std::list <unsigned int> *src_ip_list = new list<unsigned int> [size];
    
    std::list <Packet> *hashed_p_list = new list<Packet> [size];
    
    int* Src_cnt = new int[size];
    //int* hashed_src_cnt = new int[size];
    int* hist_val = new int[MAX_HIST_VAL];
    int* hashed_hist_val = new int[MAX_HIST_VAL];
    
    Packet pp;

   	PCAPReader p_reader(pcap_file_name);
   	
	for (int i=0;i<offset;i++) {
		p_reader.read_packet(p);
        pkt_index++;
    }
    
	//printf("Insertion:\n");
	
    
	packets_processed  = 0; 
	
    for (int place = 0; place < size; place++) {
        p_list[place].clear();
        src_ip_list[place].clear();
        hashed_p_list[place].clear();
        
    }
    
    for (i = 0; i < size; i++) {
        Src_cnt[i] = 0;
    }

    
    for (i = 0; i < MAX_HIST_VAL; i++) {
        hist_val[i] = 0;
        hashed_hist_val[i] = 0;
    }

    
    while (packets_processed < max_packets){
          
          for (int i=0;i<jump;i++) {
              p_reader.read_packet(p);
              pkt_index++;
              packets_processed++;
          }
        //if (!p.valid) {
        //        cout<<"@@@"<< packets_processed<<endl;
        //}
          if (p.valid) {
              
              
              //std::cout<<p.source_ip<<"  "<<p.dest_ip<<endl;
     
             total++;
 			 place = (p.source_ip) % size;
  			 
              bool new_flow = true;
              bool new_source_ip= true;
              bool new_hashed_flow= true;
              
   			 
         // is this the "flow criteria? - IS THIS IT?
        // why is there an array of lists? each associated with src ip list, flow list and hashed flow list
   			 for(iter=p_list[place].begin(); iter!=p_list[place].end() && new_flow; iter++) {
                 pp = (Packet)*iter;
                 
                 if ((p.source_ip == pp.source_ip) && (p.dest_ip == pp.dest_ip) ){
                     new_flow = false;
                 }
                 if (p.source_ip == pp.source_ip){
                     new_source_ip = false;
                 }
                 
                 if ((p.source_ip == pp.source_ip) && (hash_ip(p.dest_ip,hash_width) == hash_ip(pp.dest_ip,hash_width))){
                     new_hashed_flow = false;
                 }
                 //cout<<p.source_port<<" "<<p.dest_port<<" "<<pkt_index<<endl;
   			 }
              cout<<p.source_port<<" "<<p.dest_port<<" "<<pkt_index<<endl;
              if (new_flow) {
                  p_list[place].push_back(p);
              }
              if (new_source_ip) {
                  src_ip_list[place].push_back(p.source_ip);
                  Src_cnt[place]++;
              }
              
              if (new_hashed_flow) {
                  hashed_p_list[place].push_back(p);
              }
              //if (new_flow != new_hashed_flow) {
              //    cout<<"!!"<<new_flow<<" "<<new_hashed_flow;
              //}
          }
   	}
    
    max_src_ip_in_bucket_cnt= 0;
    
    // which out of the "size" places has the most sources associated with it
    for (i = 0; i < size; i++) {
        if (Src_cnt[i] >  max_src_ip_in_bucket_cnt) {
            max_src_ip_in_bucket_cnt = Src_cnt[i];
        }
    }
    
    //std::cout<<"max_src_ip_in_bucket "<< max_src_ip_in_bucket_cnt<<endl;
    
    max_dst_per_src = 0;
    
    
    list<unsigned int>::iterator src_iter;
    
    for (place = 0; place < size; place++) {
        
        // unique source ip list
        for(src_iter=src_ip_list[place].begin(); src_iter!=src_ip_list[place].end(); src_iter++) {
            src_ip_cur = (unsigned int)*src_iter;
            dst_per_src = 0;
            
            // all packets for a given source ip, check if that source equals packet list at same place
            // wont it be equal??
            for(iter=p_list[place].begin(); iter!=p_list[place].end(); iter++) {
                pp = (Packet)*iter;
                if (src_ip_cur == pp.source_ip) {
                    dst_per_src += 1;
                    if (log_orig) {
                        cout<<pp.dest_ip<<" ";
                    }
                }
            }
            if (log_orig) {
                cout<<endl;
            }
            if (dst_per_src > max_dst_per_src) {
                max_dst_per_src = dst_per_src;
            }
            
            hist_val[dst_per_src] += 1;
            
            // relationship between p_list and pp?
            if (debug) {
                if (dst_per_src >= 30) {
                    std::cout<< "Src: "<< src_ip_cur << " [";
                    for(iter=p_list[place].begin(); iter!=p_list[place].end(); iter++) {
                        pp = (Packet)*iter;
                        if (src_ip_cur == pp.source_ip) {
                            std::cout<<pp.dest_ip<<", ";
                        }
 
                    }
                    std::cout<< "]"<<endl<<endl;
                }
            }
        }
    }
    
    
    
    //std::cout<<"max_dst_per_src X "<< max_dst_per_src<<endl;
    
    if (log_summary) {
        std::cout<<"Original: ";
        for (i = 0; i < MAX_HIST_VAL; i++) {
            if (hist_val[i]) {
                std::cout<<"("<<i<<","<< hist_val[i]<<")"<<" ";
            }
        }
        std::cout<<endl;
    }
    
    
    max_dst_per_src = 0;
    for (place = 0; place < size; place++) {
        
        for(src_iter=src_ip_list[place].begin(); src_iter!=src_ip_list[place].end(); src_iter++) {
            src_ip_cur = (unsigned int)*src_iter;
            dst_per_src = 0;
            for(iter=hashed_p_list[place].begin(); iter!=hashed_p_list[place].end(); iter++) {
                pp = (Packet)*iter;
                if (src_ip_cur == pp.source_ip) {
                    dst_per_src += 1;
                    if (log_hashed) {
                        cout<<hash_ip(pp.dest_ip,hash_width)<<" ";
                    }
                }
            }
            if (log_hashed) {
                cout<<endl;
            }
            if (dst_per_src > max_dst_per_src) {
                max_dst_per_src = dst_per_src;
            }
            
            hashed_hist_val[dst_per_src] += 1;
            
            
            if (debug) {
                if (dst_per_src >= 30) {
                    std::cout<< "Src: "<< src_ip_cur << " [";
                    for(iter=hashed_p_list[place].begin(); iter!=hashed_p_list[place].end(); iter++) {
                        pp = (Packet)*iter;
                        if (src_ip_cur == pp.source_ip) {
                            std::cout<<pp.dest_ip<<", ";
                        }
                        
                    }
                    std::cout<< "]"<<endl<<endl;
                }
            }
        }
    }
    
    
    
    //std::cout<<"max_dst_per_src XX "<< max_dst_per_src<<endl;
    if (log_summary) {
        std::cout<<"Hashed: ";
        for (i = 0; i < MAX_HIST_VAL; i++) {
            if (hashed_hist_val[i]) {
                std::cout<<"("<<i<<","<< hashed_hist_val[i]<<")"<<" ";
            }
        }
        std::cout<<endl;
    }
    return 0;
}