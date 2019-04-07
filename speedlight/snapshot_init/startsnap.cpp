/* Copyright 2018-present University of Pennsylvania
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/**
 * Initializes a snapshot on the local node.  See usage notes for parameters.
 **/

#include <arpa/inet.h>
#include <linux/if_packet.h>
#include <linux/ip.h>
#include <linux/udp.h>
#include <net/if.h>
#include <netinet/ether.h>
#include <sys/ioctl.h>

#include <assert.h>
#include <sched.h>
#include <string.h>
#include <time.h>
#include <unistd.h>

#include <chrono>
#include <iostream>
#include <vector>


using namespace std;
using namespace std::chrono;

unsigned short csum(unsigned short *buf, int nwords)
{
    unsigned long sum;
    for(sum=0; nwords>0; nwords--)
        sum += *buf++;
    sum = (sum >> 16) + (sum &0xffff);
    sum += (sum >> 16);
    return (unsigned short)(~sum);
}

void makePacketBase(struct mmsghdr* sendbuf, char** snapshot_id_ptrs,
                    unsigned short** ip_hdr_ptrs, unsigned short** cksum_ptrs,
                    const vector<int>& iterationList,
                    struct sockaddr_ll* socket_address) {
    struct msghdr* headers = new struct msghdr[iterationList.size()];
    struct iovec* contents = new struct iovec[iterationList.size()];

    memset(sendbuf, 0, sizeof(struct mmsghdr) * iterationList.size());
    memset(headers, 0, sizeof(struct msghdr) * iterationList.size());
    memset(contents, 0, sizeof(struct iovec) * iterationList.size());


    // Construct a single header that we'll copy later
    char sample_packet[1024];
    memset(sample_packet, 0, 1024);
    size_t tx_len = 0;
    size_t snapshot_id_offset;
    size_t cksum_offset;
    char* port_ptr;

    // Ethernet header
    struct ether_header *eh = (struct ether_header *) sample_packet;
    eh->ether_shost[0] = 0x00;
    eh->ether_shost[1] = 0x00;
    eh->ether_shost[2] = 0x00;
    eh->ether_shost[3] = 0x00;
    eh->ether_shost[4] = 0x00;
    eh->ether_shost[5] = 0x00;
    eh->ether_dhost[0] = 0x00;
    eh->ether_dhost[1] = 0x00;
    eh->ether_dhost[2] = 0x00;
    eh->ether_dhost[3] = 0x00;
    eh->ether_dhost[4] = 0x00;
    eh->ether_dhost[5] = 0x00;
    eh->ether_type = htons(ETH_P_IP);
    tx_len += sizeof(struct ether_header);

    // IP Header
    struct iphdr *iph = (struct iphdr *) (sample_packet + sizeof(struct ether_header));
    iph->ihl = 7;
    iph->version = 4;
    iph->tos = 0; // Low delay
    iph->id = htons(11111);
    iph->frag_off = 0x00;
    iph->ttl = 0xff; // hops
    iph->protocol = IPPROTO_TCP;
    /* Source IP address */
    iph->saddr = inet_addr("0.0.0.0");
    /* Destination IP address */
    iph->daddr = inet_addr("0.0.0.0");
    tx_len += sizeof(struct iphdr);

    // IP options (snapshot header)
    char *ip_options = sample_packet + tx_len;
    ip_options[0] = 0xde;
    ip_options[1] = 0x30;
    ip_options[2] = 0x00;
    ip_options[3] = 0x00;
    snapshot_id_offset = &ip_options[3] - sample_packet;
    ip_options[4] = 0x00;
    ip_options[5] = 0x00;
    port_ptr = &ip_options[5];
    ip_options[6] = 0x00;
    ip_options[7] = 0x00;
    tx_len += 8;

    // UDP header
    struct udphdr *udph = (struct udphdr *) (sample_packet + tx_len);
    udph->source = htons(11111);
    udph->dest = htons(80);
    udph->check = 0; // skip
    tx_len += sizeof(struct udphdr);

    sample_packet[tx_len++] = 0xde;
    sample_packet[tx_len++] = 0xad;
    sample_packet[tx_len++] = 0xbe;
    sample_packet[tx_len++] = 0xef;

    udph->len = sizeof(struct udphdr) + 4;
    iph->tot_len = htons(tx_len - sizeof(struct ether_header));

    cksum_offset = (char*)&iph->check - sample_packet;


    // Create all packets at once
    for (int i = 0; i < iterationList.size(); ++i) {
        *port_ptr = 0x00 + iterationList[i];
        char* packet = new char[tx_len];
        memcpy(packet, sample_packet, tx_len);
        contents[i].iov_base = packet;
        contents[i].iov_len = tx_len;

        headers[i].msg_iov = &contents[i];
        headers[i].msg_iovlen = 1;
        headers[i].msg_name = socket_address;
        headers[i].msg_namelen = sizeof(struct sockaddr_ll);
        sendbuf[i].msg_hdr = headers[i];

        snapshot_id_ptrs[i] = packet + snapshot_id_offset;
        ip_hdr_ptrs[i] = (unsigned short*) packet + sizeof(struct ether_header);
        cksum_ptrs[i] = (unsigned short*) packet + cksum_offset;
    }
}

void setupMessages(char** snapshot_id_ptrs, unsigned short** ip_hdr_ptrs,
                   unsigned short** cksum_ptrs,
                   const int snapshot_id, const int num_messages) {
    for (int i = 0; i < num_messages; ++i) {
        *snapshot_id_ptrs[i] = 0x00 + snapshot_id;
        *cksum_ptrs[i] = csum(ip_hdr_ptrs[i], (sizeof(struct iphdr)+8)/2);
    }
}

int main(int argc, char *argv[])
{
    cout << "Starting startsnap.cpp" << endl;

    string if_name = "veth1";
    int interval_ms = 30000;
    int ss_begin = 1;
    int ss_end = 2;

    int c;
    while ((c = getopt(argc, argv, "d:i:b:e:")) != -1) {
        switch (c) {
            case 'd':
                if_name = optarg;
                break;
            case 'i':
                interval_ms = atoi(optarg);
                break;
            case 'b':
                ss_begin = atoi(optarg);
                break;
            case 'e':
                ss_end = atoi(optarg);
                break;
        }
    }

    if (argc < optind + 4) {
        cout << "Usage ./startsnap [-dibe] HH MM port_begin port_end\n"
             << "\t-d pci_intf\n"
             << "\t-i interval (ms)\n"
             << "\t-b ss_begin\n"
             << "\t-e ss_end\n";
        exit(1);
    }

    int target_hours = atoi(argv[optind++]);
    int target_minutes = atoi(argv[optind++]);
    int port_begin = atoi(argv[optind++]);
    int port_end = atoi(argv[optind++]);

    assert(port_end > port_begin);
    assert(ss_end > ss_begin);

    struct sched_param sp;
    memset( &sp, 0, sizeof(sp) );
    sp.sched_priority = 99;
    if (sched_setscheduler( 0, SCHED_FIFO, &sp ) < 0) {
        perror("sched_setscheduler");
    }

    vector<int> iterationList;
    for (int i = port_begin; i < port_end; ++i) {
        iterationList.push_back(i);
    }

    /*
     * Create the raw socket to the switch
     */
    int sock;
    struct sockaddr_ll socket_address;
    // Open RAW socket to send on
    if ((sock = socket(AF_PACKET, SOCK_RAW, IPPROTO_RAW)) == -1) {
        perror("socket");
    }

    int optval = 7; // valid values are in the range [1,7]  
                    // 1- low priority, 7 - high priority  
    if (setsockopt(sock, SOL_SOCKET, SO_PRIORITY, &optval, sizeof(optval)) < 0) {
        perror("setsockopt");
    }

    /*
     * Craft the raw socket address
     */
    struct ifreq if_idx;
    memset(&if_idx, 0, sizeof(struct ifreq));
    strncpy(if_idx.ifr_name, if_name.c_str(), IFNAMSIZ-1);

    if (ioctl(sock, SIOCGIFINDEX, &if_idx) < 0) {
        perror("SIOCGIFINDEX");
    }

    // Set up the destination socket info
    socket_address.sll_ifindex = if_idx.ifr_ifindex;
    socket_address.sll_halen = ETH_ALEN;
    socket_address.sll_addr[0] = 0x00;
    socket_address.sll_addr[1] = 0x00;
    socket_address.sll_addr[2] = 0x00;
    socket_address.sll_addr[3] = 0x00;
    socket_address.sll_addr[4] = 0x00;
    socket_address.sll_addr[5] = 0x00;

    /*
     * Craft the base packet.  Can fill in the snapshot ID, port, and cksum
     * later using pointers into the sendbuf.
     */
    struct mmsghdr sendbuf[iterationList.size()];
    char* snapshot_id_ptrs[iterationList.size()];
    unsigned short* ip_hdr_ptrs[iterationList.size()];
    unsigned short* cksum_ptrs[iterationList.size()];

    makePacketBase(sendbuf, snapshot_id_ptrs, ip_hdr_ptrs, cksum_ptrs,
                   iterationList, &socket_address);

    /*
     * Set up timestamps for accurate sending.
     */
    time_t t = time(NULL);
    struct tm lt = {0};
    localtime_r(&t, &lt);
    long long utc_offset = lt.tm_gmtoff * 1000;

    auto interval = chrono::milliseconds(interval_ms);
    auto target_time = duration_cast<milliseconds>(system_clock::now().time_since_epoch());
    target_time -= milliseconds((target_time.count() + utc_offset) % 86400000);

    target_time += hours(target_hours);
    target_time += minutes(target_minutes);

    target_time -= interval;
    cout << "Waiting for " << (target_time - system_clock::now().time_since_epoch()).count()/1000000000 << endl;
    while (target_time > system_clock::now().time_since_epoch()) {
        sched_yield();
    }
    target_time += interval;

    for (int i = ss_begin; i < ss_end; ++i) {
        setupMessages(snapshot_id_ptrs, ip_hdr_ptrs, cksum_ptrs,
                      i, iterationList.size());

        while (target_time > system_clock::now().time_since_epoch()) {
            asm volatile("pause");
        }

        if (sendmmsg(sock, sendbuf, iterationList.size(), 0) < 0) {
            perror("sendmmsg");
        }
        target_time += interval;

        sched_yield();
    }
}
