/*
 * packet.hpp
 *
 *  Created on: Jun 30, 2012
 *      Author: snikolenko
 */

#ifndef PACKET_HPP_
#define PACKET_HPP_

#include <ostream>
#include <iomanip>

using namespace std;

template <typename T> class Packet {
public:
	int arrival; // arrival time
	double l; // length
	T r; // required work
	bool touched; // has been already processed at least once

	Packet( T inp_r ) : arrival(-1), l(1), r(inp_r), touched(false) {}
	Packet( T inp_r, double inp_l ) : arrival(-1), l(inp_l), r(inp_r), touched(false) {}
	Packet( const Packet<int> & p ) : arrival(p.arrival), l(p.l), r(p.r), touched(false) {}

	void setArrival(int arr) { arrival = arr; }

	void dec() { r--; touched = true; }
	bool operator == ( int i ) const { return (r == i); }
	bool operator < ( const Packet & p ) const { return (r < p.r); }
	bool operator > ( const Packet & p ) const { return (r > p.r); }
	bool operator == ( const Packet & p ) const { return (r == p.r); }
	bool operator < ( int p ) const { return (r < p); }
	bool operator > ( int p ) const { return (r > p); }
};

typedef Packet<int> IntPacket;
typedef Packet<float> FractionalPacket;

template <typename T> ostream& operator<< (ostream& os, const Packet<T> & p) {
	if (p.l > 1) {
		os << p.r << ":" << setprecision(2) << p.l << "(" << p.arrival << ")";
	} else {
		os << p.r << "(" << p.arrival << ")";
	}
	return os;
}

template <typename T> bool sortWork(const Packet<T> & i, const Packet<T> & j) { return (i.r<j.r); }
template <typename T> bool sortLength(const Packet<T> & i, const Packet<T> & j) { return (i.l>j.l); }
template <typename T> bool sortValue(const Packet<T> & i, const Packet<T> & j) { return ( (i.l / (float)i.r) > (j.l / (float)j.r)); }

#endif /* PACKET_HPP_ */
