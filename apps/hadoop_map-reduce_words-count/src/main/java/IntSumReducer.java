import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Reducer;

import java.io.IOException;
import java.util.ArrayList;

public class IntSumReducer extends Reducer<Text, IntWritable, Text, IntWritable> {

    public void reduce(Text key, Iterable<IntWritable> values, Context context)
            throws IOException, InterruptedException {
        ArrayList<IntWritable> words_count = new ArrayList<>();
        values.forEach(value -> words_count.add(value));
        context.write(new Text(key), new IntWritable(words_count.size()));

        System.out.println("WORD => " + key + " : " + words_count.size());
    }
}
