/*Data Structure used as a building block for the hash table
 that tracks the lossy packets*/

public class FlowIdWithCount implements Comparable<FlowIdWithCount>{
		long count;
		String flowid;

		public FlowIdWithCount(String flowid ,long count){
			this.count = count;
			this.flowid = flowid;
		}

		public static void reset(FlowIdWithCount[] buckets){
			for (int i = 0; i < buckets.length; i++){
				buckets[i].flowid = "";
				buckets[i].count = 0;
			}
		}

		public int compareTo(FlowIdWithCount that){
			// descending order
			return Long.compare(that.count, this.count);
		}
	}