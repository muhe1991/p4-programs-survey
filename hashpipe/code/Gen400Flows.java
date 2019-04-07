import java.util.*;
import java.io.File;
import java.io.FileNotFoundException;

public class Gen400Flows{
	public static void main(String[] args){
		// read the flows to be lost from a file mentioned in the command line and create a new stream with that flow lost
		// HashSet<String> flowsToBeTracked = new HashSet<String>();
		ArrayList<String> flows = new ArrayList<String>();
		File file = new File(args[0]);
		try
		{
			Scanner scanner = new Scanner(file);
			String line;
			//int linenumber = 0;
			//String[] fields = new String[24];
			while (scanner.hasNextLine())
			{
				line = scanner.nextLine();
				//flowsToBeTracked.add(line);
				flows.add(line);
			}
			scanner.close();
		}
		catch (FileNotFoundException e)
		{
			System.err.format("Exception occurred trying to read '%s'.", args[1]);
			e.printStackTrace();
			return;
		}

		HashSet<String> flowsToBeLost = new HashSet<String>();

		while (flowsToBeLost.size() < 400){
			int index = (int) (Math.random() * 400);
			if (!flowsToBeLost.contains(flows.get(index)))
				flowsToBeLost.add(flows.get(index));
		}

		for (String s : flowsToBeLost){
			System.out.println(s);
		}
	}
}