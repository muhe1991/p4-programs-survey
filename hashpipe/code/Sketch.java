import java.*;
import java.util.Arrays;
import java.math.BigInteger;

/* count min sketch that is used to maintain a summary data structure
   to estimate the frequency of occurence of certain items in a data
   stream

   used in this context to count the number of packets per flow that
   have been lost

	initially used to simulate reversible sketches too - hence, there
	is some commented out code that belongs to that technique
*/
public class Sketch{
	private int size;							// K or the max number of buckets in a hash table
	private int numberOfHashFunctions; 		 	// H
	private int totalNumberOfKeys;				// N or the total number of distinct keys
	private int mangler; 						// random odd number between 0 and n - 1
	private int totalNumberOfPackets; 			// total number of packets for which the sketch data has been currently collected
	
	// main data structure that maintains the sketch
	// i,jth index contains the number of packets that hashed to the the jth bucket when hashed with the ith hash function 
	private long[][]	hashMatrix; 

	// a and b to compute the hashFunctions needed, every ith index in the hashSeedA and hashSeedB arrays are
	//used to form a linear combination to get a hashfunction of the form ((ax + b) %p) %size
	private final int[] hashSeedA;
	private final int[] hashSeedB;
	private final BigInteger[] bigHashSeedA;
	private final BigInteger[] bigHashSeedB;
	private final int[] hashSeedA2;
	private final int[] hashSeedB2;
	private final int p;
	private final BigInteger bigP;
	private final long primeNumber;

	public Sketch(int size, int numberOfHashFunctions, int totalNumberOfKeys){
		this.size = size;
		this.numberOfHashFunctions = numberOfHashFunctions;
		this.totalNumberOfKeys = totalNumberOfKeys;
		this.mangler = (int) Math.random()*(totalNumberOfKeys - 1);
		hashMatrix = new long[numberOfHashFunctions][size];
		this.totalNumberOfPackets = 0;

		this.p = 9029;
		primeNumber = 39916801;
		bigP = new BigInteger(Long.toString(primeNumber));


		final int hashA[] = { 	10273, 8941, 11597, 9203, 12289, 11779,
								421, 	199, 	79,	83,	89,	97,	101,	103,	107,	109,	113,
								127,	131,	137,	139,	149,	151,	157,	163,	167,	173,
								179,	181,	191,	193,	197,	199,	211,	223,	227,	229,
								233,	239,	241,	251,	257,	263,	269,	271,	277,	281,
								283,	293,	307,	311,	313,	317,	331,	337,	347,	349,
								353,	359,	367,	373,	379,	383,	389,	397,	401,	409,
								419,	421,	431,	433,	439,	443,	449,	457,	461,	463,
								467,	479,	487,	491,	499,	503,	509,	521,	523,	541,
								547,	557,	563,	569,	571,	577,	587,	593,	599,	601,
								1153,	1163,	1171,	1181,	1187,	1193,	1201,	1213,	1217,	1223,
								1229,	1231,	1237,	1249,	1259,	1277,	1279,	1283,	1289,	1291,
								1297,	1301,	1303,	1307,	1319,	1321,	1327,	1361,	1367,	1373,
								1381,	1399,	1409,	1423,	1427,	1429,	1433,	1439,	1447,	1451};

			//421, 149, 311, 701, 557, 1667, 773, 2017, 1783, 883, 307, 199, 2719, 2851, 1453};
		final int hashB[] = {   12037, 12289, 9677, 11447, 8837, 10847, 
			                    73, 	3079, 	613,	617,	619,	631,	641,	643,	647,	653,	659,
								661,	673,	677,	683,	691,	701,	709, 	719,	727,	733,
								739,	743,	751,	757,	761,	769,	773,	787,	797,	809,
								811,	821,	823,	827,	829,	839,	853,	857,	859, 	863,
								877,	881,	883,	887,	907,	911,	919,	929,	937,	941,
								947, 	953,	967,	971,	977,	983, 	991,	997, 	1009,	1013,
								1019,	1021,	1031,	1033,	1039,	1049,	1051,	1061,	1063,	1069,
								1087,	1091,	1093,	1097,	1103,	1109,	1117,	1123,	1129,	1151,
								1153,	1163,	1171,	1181,	1187,	1193,	1201,	1213,	1217,	1223,
								1453,	1459,	1471,	1481,	1483,	1487,	1489,	1493,	1499,	1511,
								1523,	1531,	1543,	1549,	1553,	1559,	1567,	1571,	1579,	1583,
								1597,	1601,	1607,	1609,	1613,	1619,	1621,	1627,	1637,	1657,
								3221, 	3229, 	3251, 	3253, 	3257,	3259, 	3271, 	3299,	3301, 	3307, 
		
								3313, 	3319, 	3323, 	3329, 	3331};
		hashSeedA = new int[numberOfHashFunctions];
		hashSeedB = new int[numberOfHashFunctions];
		for (int i = 0; i < numberOfHashFunctions; i++){
			hashSeedA[i] = (int) (Math.random()* primeNumber);
			hashSeedB[i] = (int) (Math.random() * primeNumber);
		}

		bigHashSeedA = new BigInteger[numberOfHashFunctions];
		bigHashSeedB = new BigInteger[numberOfHashFunctions];
		for (int i = 0; i < numberOfHashFunctions; i++){
			bigHashSeedA[i] = new BigInteger(Long.toString((long) (Math.random()* primeNumber)));
			bigHashSeedB[i] = new BigInteger(Long.toString((long) (Math.random() * primeNumber)));
		}
		//this.hashSeedA = hashA;
		//this.hashSeedB = hashB;

		/*this.p = 32561; /*20117;
		int hashA[] = {  701, 557, 1667, 773, 2017, 1783, 883, 307, 199, 2719, 2851, 1453, 421, 149, 311, 8461, 9839, 10597, 9241, 7027, 11329};
		this.hashSeedA = hashA;
		int hashB[] = {  31, 151, 3359, 643, 1103, 73, 109, 233, 2927, 3061, 409, 3079, 2341, 179, 1213, 9871, 10159, 7577, 8147, 11113, 9901};
		this.hashSeedB = hashB;*/

		int hash2A[] = {  2311, 991, 3119, 2791, 3083, 1663, 8689, 9907, 8293, 12227, 11161, 8537, 7951, 8117, 9203, 8111, 11677, 3761, 5099};
		this.hashSeedA2 = hash2A;
		int hash2B[] = {  2119, 4073, 5651, 3407, 2063, 5527, 5839, 3557, 2063, 6101, 3351, 5743, 8117, 7393, 8681, 9901, 10103, 8707, 9679};
		this.hashSeedB2 = hash2B;

		// a and b to compute the hashFunctions needed, every ith index in the hashSeedA and hashSeedB arrays are
		//used to form a linear combination to get a hashfunction of the form ((ax + b) %p) %size
		/*long[] hashSeedA = { 421, 149, 151, 59032440799460394L,
		      1380096083914250750L,
		      9216393848249138261L,
		      1829347879307711444L,
		      9218705108064111365L};

		this.hashSeedA = hashSeedA;
		
		long[] hashSeedB = {73L, 109L, 87L,
			  832108633134565846L,
		      9207888196126356626L,
		      1106582827276932161L,
		      7850759173320174309L,
		      8297516128533878091L};
		this.hashSeedB = hashSeedB;*/
	}

	public int getSize(){
		return size;
	}

	public int getNumberOfHashFunctions(){
		return numberOfHashFunctions;
	}

	public long[][] getMatrix(){
		return hashMatrix;
	}

	public int getTotalNumberofPackets(){
		return totalNumberOfPackets;
	}

	private int hash(long word, int hashFunctionIndex){
		//System.out.println(word.substring(25));
		//System.out.println(hashSeedA[hashFunctionIndex]*word + hashSeedB[hashFunctionIndex]);
		return (int) ((hashSeedA[hashFunctionIndex]*word + hashSeedB[hashFunctionIndex]) % primeNumber) % size;
	}

	private int bighash(String id, int hashFunctionIndex){
		//System.out.println(word.substring(25));
		//System.out.println(hashSeedA[hashFunctionIndex]*word + hashSeedB[hashFunctionIndex]);
		BigInteger bigint = new BigInteger(id);
		bigint = bigint.multiply(bigHashSeedA[hashFunctionIndex]);
		bigint = bigint.add(bigHashSeedB[hashFunctionIndex]);
		bigint = bigint.mod(bigP);
		bigint = bigint.mod(new BigInteger(Integer.toString(size)));
		int curKeyIndex = bigint.intValue();
		return curKeyIndex;
	}

	private int hashTwo(long word, int hashFunctionIndex){
		//System.out.println(word.substring(25));
		//System.out.println(hashSeedA[hashFunctionIndex]*word + hashSeedB[hashFunctionIndex]);
		return (int) ((hashSeedA2[hashFunctionIndex]*word + hashSeedB2[hashFunctionIndex]) % p) % 2;
	}

	// update the sketch to reflect that a packet with the id has been received
	// asume updateCount is called on a packet only once
	public void updateCount(long flowid){
		totalNumberOfPackets++;

		// hash the ip and update the appropriate counters
		for (int i = 0; i < numberOfHashFunctions; i++){
			// hash word by word numberofHashFunctions times independently
			int hashbucket = hash(flowid, i);
			//System.out.println(hashbucket + " " + flowid);
			hashMatrix[i][hashbucket]++; 
		}
	}

	// update the sketch to reflect that a packet with the id has been received
	// asume updateCount is called on a packet only once
	// return an estimate for the flowid associated with the packet p
	public void updateCountInSketch(long flowid){
		//long flowid = p.getSrcIp();
		//String flowid = p.fivetuple();

		totalNumberOfPackets++;

		// hash the ip and update the appropriate counters
		for (int i = 0; i < numberOfHashFunctions; i++){
			// hash word by word numberofHashFunctions times independently
			int hashbucket = hash(flowid, i);
			hashMatrix[i][hashbucket]++; 
		}
	}

	// update the sketch to reflect that a packet with the id has been received
	// asume updateCount is called on a packet only once
	// return an estimate for the flowid associated with the packet p
	public void updateCountInSketchBigHash(String flowid){
		//long flowid = p.getSrcIp();
		//String flowid = p.fivetuple();

		totalNumberOfPackets++;

		// hash the ip and update the appropriate counters
		for (int i = 0; i < numberOfHashFunctions; i++){
			// hash word by word numberofHashFunctions times independently
			int hashbucket = bighash(flowid, i);
			hashMatrix[i][hashbucket]++; 
		}
	}

	// update the count-sketch to reflect that a packet with the id has been received
	// based on the output of another hash function, this update value could be +- 1
	public void updateCountInCountSketch(long flowid){
		//long flowid = p.getSrcIp();
		//String flowid = p.fivetuple();

		totalNumberOfPackets++;

		// hash the ip and update the appropriate counters
		for (int i = 0; i < numberOfHashFunctions; i++){
			// hash word by word numberofHashFunctions times independently
			int hashbucket = hash(flowid, i);
			if (hashTwo(flowid, i) == 0)
				hashMatrix[i][hashbucket]++; 
			else
				hashMatrix[i][hashbucket]--; 
		}
	}


	// subtract the sketch represented by otherTable from this table and store the result in this table
	public void subtract(Sketch otherTable) throws Exception{
		if (otherTable.getSize() != size || otherTable.getNumberOfHashFunctions() != numberOfHashFunctions)
			throw new Exception("incompatible sizes");

		for (int i = 0; i < numberOfHashFunctions; i++)
			for (int j = 0; j < size; j++){
				this.hashMatrix[i][j] -= otherTable.getMatrix()[i][j];
			}

		this.totalNumberOfPackets -= otherTable.totalNumberOfPackets;
	}

	// get median from a list of numbers code from http://stackoverflow.com/questions/7121188/mean-median-mode-range-java
	public long getMedian(long[] numberList) {
		int factor = numberList.length - 1;
		long[] first = new long[factor / 2];
		long[] last = new long[first.length];
		long[] middleNumbers = new long[1];
		for (int i = 0; i < first.length; i++) {
		    first[i] = numberList[i];
		}
		int j = last.length - 1;
		for (int i = numberList.length - 1; i > 0; i--) {
		    last[j--] = numberList[i];
		}
		for (int i = 0; i <= numberList.length; i++) {
		    if (numberList[i] != first[i] || numberList[i] != last[i]) middleNumbers[i] = numberList[i];
		}
		if (numberList.length % 2 == 0) {
		    long total = middleNumbers[0] + middleNumbers[1];
		    return total / 2;
		} else {
		    return middleNumbers[0];
		}
	}

	// query an estimate for the loss of this flow identified by its flow id
	// using the count-min approach
	public long estimateCountinCountSketch(long flowid){
		long[] listOfCountValues = new long[numberOfHashFunctions];
		for (int i = 0; i < numberOfHashFunctions; i++){
			int hashbucket = hash(flowid, i);
			listOfCountValues[i] = hashMatrix[i][hashbucket];
		}
		Arrays.sort(listOfCountValues);
		return listOfCountValues[listOfCountValues.length/2];
	}

	// query an estimate for the loss of this flow identified by its flow id
	// using the count-min approach
	public long estimateCount(long flowid){
		long min = hashMatrix[0][hash(flowid, 0)];
		for (int i = 1; i < numberOfHashFunctions; i++){
			int hashbucket = hash(flowid, i);
			if (hashMatrix[i][hashbucket] < min)
				min = hashMatrix[i][hashbucket];
		}
		return min;
	}

	// query an estimate for the loss of this flow identified by its flow id
	// using the count-min approach
	public long estimateCountBigHash(String flowid){
		long min = hashMatrix[0][bighash(flowid, 0)];
		for (int i = 1; i < numberOfHashFunctions; i++){
			int hashbucket = bighash(flowid, i);
			if (hashMatrix[i][hashbucket] < min)
				min = hashMatrix[i][hashbucket];
		}
		return min;
	}


	// reset the sketch by setting all counters to 0
	public void reset(){
		for (int i = 0; i < numberOfHashFunctions; i++){
			for (int j = 0; j < size; j++)
				hashMatrix[i][j] = 0;
		}
	}

	// get the occupancy - number of occupied slots in the cm sketch as a fraction of total slots
	public double getOccupancy(){
		double occupiedSlots = 0;
		for (int i = 0; i < numberOfHashFunctions; i++){
			for (int j = 0; j < size; j++)
				if (hashMatrix[i][j] != 0)
					occupiedSlots++;
		}
		return occupiedSlots/(numberOfHashFunctions*size);
	}
} 