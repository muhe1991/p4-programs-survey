import java.util.*;
import java.io.File;
import java.io.FileNotFoundException;

public class CleanupFile{
	public static void main(String[] args){
		// read the flows to be lost from a file mentioned in the command line and create a new stream with that flow lost
		File file = new File(args[0]);
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
				if (linenumber++ == 0)
					continue;

				fields = line.split(",");

				if (fields.length < 5)
					continue;

				String srcipString = fields[0]; // caida default
				if (!args[0].contains("Caida")){
					srcipString = fields[3];
				}

				if (srcipString.length() == 0)
					continue;
				System.out.println(line);				
			}
			scanner.close();
		}
		catch (FileNotFoundException e)
		{
			System.err.format("Exception occurred trying to read '%s'.", args[0]);
			e.printStackTrace();
		}
	}
}