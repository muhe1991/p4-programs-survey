import java.util.*;
import java.io.File;
import java.io.FileNotFoundException;

/* parser to parse flow data from a csv file
into a packetStream which is represented by a HashSet */

public class P4RegisterOutputParser{
	public static void main(String args[]){
		File file = new File(args[0]);
		try
		{
			Scanner scanner = new Scanner(file);
			int linenumber = 0;
			String line = scanner.nextLine(); // skip first line
			String[] fields = new String[24];
			while (scanner.hasNextLine())
			{
				line = scanner.nextLine();
				linenumber++;
				if (linenumber %5 != 3)
					continue;

				fields = line.split(" ");
				//System.out.println(fields.length);
				if (fields.length < 3)
					continue;

				if (fields[1].contains("flow")){
					System.out.print(fields[3] + ",");
				}
				else// packet counter for stage 1
					System.out.print(fields[3] +",,");
				
				if (linenumber %20 == 18)
					System.out.println();
			}
			scanner.close();
			return;
		}
		catch (FileNotFoundException e)
		{
			System.err.format("Exception occurred trying to read '%s'.", args[0]);
			e.printStackTrace();
			return;
		}
	}
}