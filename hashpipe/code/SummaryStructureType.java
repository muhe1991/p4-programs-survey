/*+----------------------------------------------------------------------
 ||
 ||  Class SummaryStructureType
 ||
 ||  Author:  Vibhaa Sivaraman
 ||
 ||  Purpose:  To define a series of enums corresponding to the methods of
 ||  performing eviction in case of memory shortage in the dleft-based table
 ||  used heavily in the "DleftHashTable.java" to perform different methods of
 ||  eviction
 ||
 ||  Inherits From:  None
 ||
 ||  Interfaces:  None
 ||
 ++-----------------------------------------------------------------------*/

public enum SummaryStructureType{ 
	// basic dleft approach where the hash table is divided into d stages
	// incoming flow is placed in its place if already present 
	// and a new flow is hashed d ways and entered into one of the empty
	// locations if it exists, otherwise the flow is dropped
	DLeft, 

	// baseline case on top of dleft, where the incoming flow is placed 
	// in the location of the minimum of the d locations (or compared to the
	// minimum if the frequency is known like in the aggregate case) and the
	// associated frequency of the new element is either 1 or the precise 
	// frequency (in the aggregate case)
	BasicHeuristic, 

	// same as above, except that the frequency of the new element inserted
	// is 1 + minfrequency (of element just evicted) - not applicable for the
	// aggregate case
	MinReplacementHeuristic,

	// dleft + preferrential eviction where the incoming flow's frequency is 
	// estimated (using a count-min sketch) and compared against the minimum
	//  before the minimum amongst the d locations is evicted
	// EvictionWithCount maintains the count in addition to the keys in the
	// table, EvictionWithoutCount doesn't
	EvictionWithCount, 
	EvictionWithoutCount, 

	// Rolling Min Based approaches use the idea that we compute the minimum
	// on the fly by replacing the value in the first stage, 
	// reading the value from the second stage and carrying over the 
	// minimum among the two to the next stage and so on and so forth 

	// RollingMinWithBloomFilter has a bloom filter in the beginning
	// unused really, but places the incoming flow in the first stage (with value 1), 
	// evicts the one in its place, carries it over to the next stage until an empty
	// location is found. It parallely checks if the incoming flow is already 
	// present in one of the later table stages and coalesces that value with
	// with the newly inserted value in the first table stage - NOT FEASIBLE 
	// AT LINE RATE
	RollingMinWithBloomFilter, 

	// RollingMinWithoutCoalescence has a bloom filter in the beginning
	// unused really, but places the incoming flow in the first stage (with value 1), 
	// evicts the one in its place, carries it over to the next stage until an empty
	// location is found. It parallely checks if the incoming flow is already 
	// present in one of the later table stages, but doesn't coalesce the value. 
	// Instead it increments the later values so that they all reflect the current 
	// best value, since it involves two lookups - also referred to as MULTILOOKUP
	// FEASIBLE AT LINE RATE with multi-ported memory
	RollingMinWihoutCoalescense, 

	// RollingMinSingleLookup is similar to multilookup, but performs exactly one
	// lookup at each stage, so doesn't check if the incoming key is present at any
	// later table stages, but just the key currently evicted from the previous stage
	// if it is naturally found in the next table stage, the two values are coalesced
	// FEASIBLE AT LINE RATE
	RollingMinSingleLookup, 

	// Similar to above except that the memory isn't evenly split amongst all d stages
	// of the hash table, the first stage has 10% more than the next and so on and so
	// forth until the last one
	AsymmetricDleftSingleLookUp,

	// Replaces the minimum across the entire table by scanning the entire table
	// for the existence of the incoming flow and simultaneously finding the minimum
	// of the table and replacing it - if there is an empty location, that will be 
	// caught in the minimum case since it would have count - 0
	// inspired by the Space-Saving Algorithm
	OverallMinReplacement,


	// Count-Min sketch based approaches where the basic idea is that we maintain the
	// counts for all values across the counters of the count min sketch. When the 
	// estimate for a particular flow (minimum amongst the counters it hashes to) exceeds
	// the threshold, we report it to the controller

	// reports the flow always when a flow exceeds the threshold. Maintains no notion of
	// the keys to control how often the reporting happens
	CountMinCacheNoKeys,

	// reports the flow always when a flow exceeds threshold as long as the "reported bit"
	// in the second set of counters isn't set - no notion of keys - not used much
	CountMinCacheNoKeysReportedBit,

	// has a cache of the keys following the count min sketch to track what keys have 
	// already been reported and what is new to control how much information is reported
	// to the controller
	CountMinCacheWithKeys,

	CountMinWithHeap,
	// maintains the current key, a "count" and total count of all packets that hased
	// to this location at every single bucket. If the incoming flow that hashes here
	// (only one hash function) matches the key, we increment "count" otherwise we
	// decrement it. We replace/overwrite the key only when the count hits a zero.
	// Claim - if there is a key that hashes to this location more than 50% of the time
	// that packets hash here, that will be left in this location at the end of this 
	// process  
	GroupCounters,

	// data structure that emulates Sample and HOld algorithm from Estan and Varghese's paper
	SampleAndHold, 

	// data structure for univMon with logN substreams
	UnivMon
};