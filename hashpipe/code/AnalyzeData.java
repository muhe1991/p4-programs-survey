import java.util.*;
import java.io.File;
import java.io.FileNotFoundException;

public class AnalyzeData{
	private static class ExpSetting{
		public int k;
		public int d;
		public double m;
		public int rep;
		//private SummaryStructureType type;

		public ExpSetting(int k, int D, double m, int rep){
			this.k = k;
			this.d = D;
			this.m = m;
			//this.type = type;
			this.rep = rep;
		}

		@Override
    	public boolean equals(Object o) {
        	if (this == o) return true;
        	if (!(o instanceof ExpSetting)) return false;
        	ExpSetting that = (ExpSetting) o;
        	return k == that.k && d == that.d && m == that.m && that.rep == rep;
   		}

		@Override
		public int hashCode() {
			String s = Integer.toString(k);
			s += Integer.toString(d);
			s += Double.toString(m);
			//s += Integer.toString(m);
			s += Integer.toString(rep);
		    return s.hashCode();
		}
	}

	public static double getMean(ArrayList<Double> data){
		double sum = 0.0;
        for(double a : data)
            sum += a;
        return sum/data.size();
	}

	public static double getStdDev(ArrayList<Double> data)
    {
        double mean = getMean(data);
        double temp = 0;
        for(double a :data)
            temp += (a-mean)*(a-mean);
        double var = temp/data.size();
        return Math.sqrt(var);
    }

	public static void main(String[] args){
		HashMap<ExpSetting, ArrayList<Double>> expToFalseNegs = new HashMap<ExpSetting, ArrayList<Double>>();
		HashMap<ExpSetting, ArrayList<Double>> expToFalsePos = new HashMap<ExpSetting, ArrayList<Double>>();
		HashMap<ExpSetting, ArrayList<Double>> expToWeightedFalseNegs = new HashMap<ExpSetting, ArrayList<Double>>();
		HashMap<ExpSetting, ArrayList<Double>> expToDuplicates = new HashMap<ExpSetting, ArrayList<Double>>();
		
		File file = new File(args[0]);
		try {

			Scanner scanner = new Scanner(file);
			String line;
			while (scanner.hasNextLine())
			{
				line = scanner.nextLine();
				String[] fields = line.split(",");

				if (fields.length < 10)
					continue;

				if (!fields[0].matches("[0-9]+"))
					continue;

				int offset = 0;
				if (args[1].equals("SH") || args[1].equals("CM"))
					offset = 1;


				int m = Integer.parseInt(fields[0]);
				int k = Integer.parseInt(fields[1 + offset]);
				int d = Integer.parseInt(fields[2 + offset]);
				int rep = Integer.parseInt(fields[6 + offset]);
				double falseNeg = Double.parseDouble(fields[4 + offset]);
				double falsePos = Double.parseDouble(fields[3 + offset]);
				double weightedFalseNeg = 1 - Double.parseDouble(fields[7 + offset]);
				double duplicates = Double.parseDouble(fields[fields.length - 1]);

				/*if (args[1].equals("CM"))
					m = m*2/15;*/

				double mNew = (double) m*140/8000;
				ExpSetting newexp = new ExpSetting(k, d, mNew, rep);

				ArrayList<Double> curList1  = null;
				ArrayList<Double> curList2 = null;
				ArrayList<Double> curList3 = null;
				ArrayList<Double> curList4 = null;

				if (expToFalseNegs.containsKey(newexp)){
					curList1 = expToFalseNegs.get(newexp);
					curList1.add(falseNeg);
				}
				else {
					curList1 = new ArrayList<Double>();
					curList1.add(falseNeg);
				}

				if (expToFalsePos.containsKey(newexp)){
					curList3 = expToFalsePos.get(newexp);
					curList3.add(falsePos);
				}
				else {
					curList3 = new ArrayList<Double>();
					curList3.add(falsePos);
				}

				if (expToWeightedFalseNegs.containsKey(newexp)){
					curList2 = expToWeightedFalseNegs.get(newexp);
					curList2.add(weightedFalseNeg);
				}
				else {
					curList2 = new ArrayList<Double>();
					curList2.add(weightedFalseNeg);
				}


				if (expToDuplicates.containsKey(newexp)){
					curList4 = expToDuplicates.get(newexp);
					curList4.add(duplicates);
				}
				else {
					curList4 = new ArrayList<Double>();
					curList4.add(duplicates);
				}

				expToFalseNegs.put(newexp, curList1);
				expToWeightedFalseNegs.put(newexp, curList2);
				expToFalsePos.put(newexp, curList3);
				expToDuplicates.put(newexp, curList4);
			}
			scanner.close();
		}
		catch (FileNotFoundException e)
		{
			System.err.format("Exception occurred trying to read '%s'.", args[0]);
			e.printStackTrace();
			return;
		}

		//System.out.println("tablesize" +"," + "K, D," + "Mean False Negs" + "," + "StdDev False Negs" + "," + "Mean Weighted FN," + "STDDev Weighted FN");
		ArrayList<Double> curList1  = null;
		ArrayList<Double> curList2 = null;
		ArrayList<Double> curList3 = null;
		ArrayList<Double> curList4 = null;
		for (ExpSetting e : expToFalseNegs.keySet()){
			curList1 = expToFalseNegs.get(e);
			curList2 = expToWeightedFalseNegs.get(e);
			curList3 = expToFalsePos.get(e);
			curList4 = expToDuplicates.get(e);

			System.out.print(e.m +" " + e.k + " " + e.d + " " + getMean(curList1)*100 + " " + getStdDev(curList1) + " " + getMean(curList2)*100 + " " + getStdDev(curList2));
			System.out.println(" " + getMean(curList3) *100+ " " + getStdDev(curList3) + " " + getMean(curList4) *100+ " " + getStdDev(curList4));
		}
	}
}