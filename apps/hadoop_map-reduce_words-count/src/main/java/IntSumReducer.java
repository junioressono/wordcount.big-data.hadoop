import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Reducer;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

public class IntSumReducer extends Reducer<Text, IntWritable, Text, IntWritable> {

    private final static IntWritable one = new IntWritable(1);

    public void reduce(IntWritable key, Iterable<Text> values, Context context)
            throws IOException, InterruptedException {
        int sum = 0;
        Map<Text, IntWritable> words = new HashMap<>();
        for (Text value : values) {
            System.out.println("value : " + value);
            //sum += value.get();
            words.put(value, one);
        }
        System.out.println("RESULT : " + words.size());
        context.write(new Text("WORDS"), new IntWritable(words.size()));
    }
}
