#define INST_SIZE 32
#define PROPOSAL_SIZE 16
#define VALUE_SIZE 32
#define ACPT_SIZE 16
#define MSGTYPE_SIZE 16
#define INST_COUNT 64000

#define PHASE_1A 1
#define PHASE_1B 2
#define PHASE_2A 3
#define PHASE_2B 4

header_type ethernet_t {
    fields {
        dstAddr : 48;
        srcAddr : 48;
        etherType : 16;
    }
}

header_type ipv4_t {
    fields {
        version : 4;
        ihl : 4;
        diffserv : 8;
        totalLen : 16;
        identification : 16;
        flags : 3;
        fragOffset : 13;
        ttl : 8;
        protocol : 8;
        hdrChecksum : 16;
        src : 32;
        dst: 32;
    }
}

header_type udp_t {
    fields {
        srcPort : 16;
        dstPort : 16;
        length_ : 16;
        checksum : 16;
    }
}

// Headers for Paxos

header_type paxos_t {
    fields {
        inst      : INST_SIZE;
        proposal  : PROPOSAL_SIZE;
        vproposal : PROPOSAL_SIZE;
        acpt      : ACPT_SIZE;
        msgtype   : MSGTYPE_SIZE;
        val       : VALUE_SIZE;
        fsh       : 32;  // Forwarding start (h: high bits, l: low bits)
        fsl       : 32;
        feh       : 32;  // Forwarding end
        fel       : 32;
        csh       : 32;  // Coordinator start
        csl       : 32;
        ceh       : 32;  // Coordinator end
        cel       : 32;
        ash       : 32;  // Acceptor start
        asl       : 32;
        aeh       : 32; // Acceptor end
        ael       : 32;
    }
}
