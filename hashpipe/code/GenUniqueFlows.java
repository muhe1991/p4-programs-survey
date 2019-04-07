import java.util.*;
import java.io.File;
import java.io.FileNotFoundException;

public class GenUniqueFlows{
	public static void main(String[] args){
		// read the flows to be lost from a file mentioned in the command line and create a new stream with that flow lost
		HashSet<String> flows = new HashSet<String>();
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

				String[] fields = line.split(",");

				String srcipString = fields[3];

				if (!flows.contains(srcipString))
					flows.add(srcipString);
			}
			scanner.close();
		}
		catch (FileNotFoundException e)
		{
			System.err.format("Exception occurred trying to read '%s'.", args[1]);
			e.printStackTrace();
			return;
		}

		for (String s : flows)
			System.out.println(s);
	}
}