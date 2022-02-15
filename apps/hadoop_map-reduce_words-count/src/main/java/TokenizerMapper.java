import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;

import java.io.IOException;
import java.util.StringTokenizer;

public class TokenizerMapper extends Mapper<Object, Text, Text, IntWritable> {

    private Text word = new Text();
    private final static IntWritable one = new IntWritable(1);

    public void map(Object key, Text value, Mapper.Context context)
            throws IOException, InterruptedException {
        StringTokenizer entry = new StringTokenizer(value.toString());
        while (entry.hasMoreTokens()) {
            word.set(entry.nextToken());
            context.write(word, one);
        }
    }
}
