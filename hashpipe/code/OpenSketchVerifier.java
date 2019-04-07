import java.util.*;
import java.io.File;
import java.io.FileNotFoundException;

/* high level procedure that uses packet info from a csv file, parses it,
   induces loss on it, and produces a sketch for the lost packet on which
   the big loser identification process is performed 

   initially written for the sketches to all be reversible so that the 
   reversibility procedure would identify the lossy buckets - unused 
   code in the context of the hash table approach*/
public class OpenSketchVerifier{

	public static void runVerification(int tableSize, String openSketchResultsFile, String sizeBySrcipFile){
		HashSet<String> expectedHH = new HashSet<String>();
		HashMap<String, Integer> flowSizes = new HashMap<String, Integer>();
		int expectedSize = 0;
		int observedSize = 0;
		int numWithin1Dev = 0;
		int numWithin2Dev = 0;
		double theoreticalProb = 0;
		int numberOfFalsePositives = 0;
		int numberOfFalseNegatives = 0;
		int underEstimatedFlows = 0;
		double underEstimateAmount = 0;
		int missingFromTable = 0;
		long bigLoserPacketReported = 0;
		long bigLoserPacketCount = 0;
		float occupiedSlots = 0;
		int threshold = 0;
		double cumDeviation = 0;
		int notPresent = 0;

		HashMap<String, Integer> observedHH = new HashMap<String, Integer>();
		File file2 = new File(openSketchResultsFile);
		try
		{
			Scanner scanner = new Scanner(file2);
			String line;
			String[] fields = new String[24];
			while (scanner.hasNextLine())
			{
				line = scanner.nextLine();
				fields = line.split(" ");
				if (fields[0].contains("threshold:"))
					threshold = Integer.parseInt(fields[1]);
				else if (fields[0].equals("is") && fields[1].equals("heavy")){
					String srcip = fields[2].substring(2, fields[2].length() - 1);
					//System.out.println(srcip);
					//System.out.println(srcip);
					observedHH.put(srcip, Integer.parseInt(fields[3]));
				}
			}
			scanner.close();
		}
		catch (FileNotFoundException e)
		{
			System.err.format("Exception occurred trying to read '%s'.", openSketchResultsFile);
			e.printStackTrace();
			return;
		}

				// read the flows to be lost from a file mentioned in the command line and create a new stream with that flow lost
		int totalPacketsLost = 0;
		File file = new File(sizeBySrcipFile);
		try
		{
			Scanner scanner = new Scanner(file);
			String line;
			//int linenumber = 0;
			String[] fields = new String[24];
			while (scanner.hasNextLine())
			{
				line = scanner.nextLine();
				fields = line.split(",");
				String srcip = fields[0];
				int packetCount = Integer.parseInt(fields[1]);
				totalPacketsLost+= Integer.parseInt(fields[1]);
				if (packetCount > threshold)
					expectedHH.add(srcip);
				flowSizes.put(srcip, packetCount);
			}
			scanner.close();
		}
		catch (FileNotFoundException e)
		{
			System.err.format("Exception occurred trying to read '%s'.", sizeBySrcipFile);
			e.printStackTrace();
			return;
		}

		ArrayList<FlowWithCount> outputFlowsList = new ArrayList<FlowWithCount>();

		int bigLoserPacketsLost = 0;
		int flag = 0;
		double deviation = 0;
		double denominator = 0;
		double curUnderEstimation = 0;

		double presentInTable = 0;
		for (String flowid : expectedHH){
			if (!observedHH.containsKey(flowid)){
				System.out.println(flowid);
				numberOfFalseNegatives++;
			}
			else
				bigLoserPacketReported += flowSizes.get(flowid);
			bigLoserPacketCount += flowSizes.get(flowid);
		}

		expectedSize = expectedHH.size();
		observedSize = observedHH.size();

		/* check where within u + sigma this lies*/
		for (String flowid : observedHH.keySet()){
			//System.out.println("hello");
			//System.out.println(FlowDataParser.convertLongToAddress(flowid));
			if (!expectedHH.contains(flowid)){
				//System.out.println(FlowDataParser.convertLongToAddress(flowid));
				numberOfFalsePositives++;
			}
			if (flowSizes.get(flowid) == null)
				notPresent++;
			else {
				deviation += Math.abs(observedHH.get(flowid) - flowSizes.get(flowid));
				if (observedHH.get(flowid) - flowSizes.get(flowid) < 0){
					underEstimatedFlows++;
					curUnderEstimation += Math.abs(observedHH.get(flowid) - flowSizes.get(flowid));
				}
				denominator += flowSizes.get(flowid);
			}
				//System.out.println(FlowDataParser.convertLongToAddress(flowid));
			//System.out.print(observedHH.get(flowid));
			//System.out.print(" flowid=" + flowid + " " + flowSizes.get(flowid));
		
			// deviation calculation
			

		}

		cumDeviation += deviation/denominator;
		underEstimateAmount += curUnderEstimation/denominator;

		System.out.print(tableSize + "," + threshold + ",");
		System.out.print((double) numberOfFalsePositives/observedSize + ",");
		System.out.print((double) numberOfFalseNegatives/expectedSize + ",");
		System.out.print(expectedSize + "," + observedSize + "," + (double) bigLoserPacketReported/bigLoserPacketCount);
		System.out.print("," + cumDeviation);
		//+ "," + occupiedSlots[k_index]/tableSize/numberOfTrials + "," + duplicates[k_index]/tableSize/numberOfTrials);
		//System.out.print("," + (double) missingFromTable[k_index]/numberOfTrials/expectedSize[k_index] + "," + cumProblematicEvictionFraction/numberOfTrials);
		System.out.println((double) underEstimatedFlows/observedSize + "," + (double) underEstimateAmount + "," + notPresent);

		/*for (int r : rankToFrequency.keySet())
			System.err.println(r + "," + rankToFrequency.get(r));*/

		//lostFlowHashTable.printBuckets();
	}

	public static void main(String[] args){
		int tableSize = Integer.parseInt(args[2]);
		runVerification(tableSize, args[0], args[1]);
	}
}