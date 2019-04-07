import java.util.*;
import java.io.File;
import java.io.FileNotFoundException;

public class GetFrequencyTable{
	public static void main(String[] args){
		HashMap<Integer, Integer> frequencyTracker = new HashMap<Integer, Integer>();
		
		Scanner scanner = new Scanner(System.in);
		String line;
		while (scanner.hasNextLine())
		{
			line = scanner.nextLine();
			int N = Integer.parseInt(line);     

			if (frequencyTracker.containsKey(N)){
				frequencyTracker.put(N, frequencyTracker.get(N) + 1);
			}
			else
				frequencyTracker.put(N, 1);						
		}
		scanner.close();
		double total = 0;
		for (Integer n : frequencyTracker.keySet()){
			System.out.println(n + "," + frequencyTracker.get(n));
			total += (double) frequencyTracker.get(n);
		}
		System.out.println(total);
	}
}