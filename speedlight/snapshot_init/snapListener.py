import socket
import struct
import sys

import dpkt


def createListeningSocket(iface):
    try:
        s = socket.socket(socket.PF_PACKET, socket.SOCK_RAW, socket.htons(0x0003))
        # s.setblocking(0)
        s.bind((iface, 0))
        # s.listen(5)
        return s
    except socket.timeout:
        print "socket timed out."

def parseNotificationChannel(pktBytes):
    eth = dpkt.ethernet.Ethernet(pktBytes)

    try:
        msgType, port, neighbor, formerId, currentId, formerLastSeen, currentLastSeen \
         = struct.unpack("!BHHHHHH", eth.data[0:13])
    except:
        return None, None, None, None, None, None, None

    print "[Notification] type: %s port: %s neighbor: %s former Id: %s current Id: %s former last seen: %s current last seen: %s" \
        %(msgType, port, neighbor, formerId, currentId, formerLastSeen, currentLastSeen)

    return msgType, port, neighbor, formerId, currentId, formerLastSeen, currentLastSeen

def parseNotification(pktBytes):
    eth = dpkt.ethernet.Ethernet(pktBytes)

    try:
        msgType, port, currentId \
         = struct.unpack("!BHH", eth.data[0:5])
    except:
        return None, None, None

    print "[Notification] type: %s port: %s current Id: %s" %(msgType, port, currentId)
    return msgType, port, currentId


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print 'Incorrect input arguments: program_name'
        sys.exit(1)

    program_name = sys.argv[1]

    mySocket = createListeningSocket('veth0')

    print "Waiting for notifications..."

    while True:
        try:
            packet, addr = mySocket.recvfrom(4096)
        except socket.timeout:
            continue

        if '_WC' in program_name:
            notificationData = parseNotificationChannel(packet)
        else:
            notificationData = parseNotification(packet)

