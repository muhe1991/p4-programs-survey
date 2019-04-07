import java.util.*;
import java.io.File;
import java.io.FileNotFoundException;

public class FindFlowSize{
	public static HashMap<String, Integer> trackPacketData(String filename){
		HashMap<String, Integer> tracker = new HashMap<String, Integer>();
		File file = new File(filename);
		try
		{
			Scanner scanner = new Scanner(file);
			String line;
			int linenumber = 0;
			String[] fields = new String[24];
			int value = 1;
			while (scanner.hasNextLine())
			{
				line = scanner.nextLine();

				fields = line.split(",");

				if (fields.length < 5)
					continue;

				if (fields[1].equals("ip.dst"))
					continue;

				if (fields[1].equals(""))
					continue;

				String srcipString = Long.toString(FlowDataParser.convertAddressToLong(fields[0])); // caida default
				String dstipString = Long.toString(FlowDataParser.convertAddressToLong(fields[1]));;
				fields[0] = srcipString;
				fields[1] = dstipString;
				String fivetuple = "";
				for (int i = 0; i < 5; i++){
					if (fields[i].equals("")){
						fivetuple = "";
						break;
					}
					else fivetuple += fields[i];
				}
				/*if (!filename.contains("Caida")){
					srcipString = fields[3];
				}

				if (srcipString.length() == 0)
					continue;*/
				String id = fivetuple;
				if (!id.equals("")){
					if (!filename.contains("Caida")){
						value = Integer.parseInt(fields[11]);
					}

					if (tracker.containsKey(id))
						tracker.put(id, tracker.get(id) + value);
					else
						tracker.put(id, value);
				}
				
			}
			scanner.close();
			return tracker;
		}
		catch (FileNotFoundException e)
		{
			System.err.format("Exception occurred trying to read '%s'.", filename);
			e.printStackTrace();
			return null;
		}
	}

	public static void main(String[] args){
		// read the flows to be lost from a file mentioned in the command line and create a new stream with that flow lost
		HashSet<String> flowsToBeTracked = new HashSet<String>();
		ArrayList<String> flows = new ArrayList<String>();
		/*File file = new File(args[1]);
		try
		{
			Scanner scanner = new Scanner(file);
			String line;
			//int linenumber = 0;
			//String[] fields = new String[24];
			while (scanner.hasNextLine())
			{
				line = scanner.nextLine();
				flowsToBeTracked.add(line);
				flows.add(line);
			}
			scanner.close();
		}
		catch (FileNotFoundException e)
		{
			System.err.format("Exception occurred trying to read '%s'.", args[1]);
			e.printStackTrace();
			return;
		}*/

		HashMap<String, Integer> tracker = trackPacketData(args[0]);

		for (String s : tracker.keySet())
			System.out.println(s + "," + tracker.get(s) + ",");
	}
}