import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapred.FileInputFormat;
import org.apache.hadoop.mapred.FileOutputFormat;
import org.apache.hadoop.mapred.JobConf;
import org.apache.hadoop.mapreduce.Job;

import java.io.IOException;

public class WordCount {
    public static void main(String[] args)
            throws IOException, InterruptedException, ClassNotFoundException {

        Configuration conf = new Configuration();

        Job job = Job.getInstance(conf, "word count");

        job.setJarByClass(WordCount.class);
        job.setMapperClass(TokenizerMapper.class);
        //job.setCombinerClass(IntSumReducer.class);
        job.setReducerClass(IntSumReducer.class);

        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(IntWritable.class);

        Path inputPath = new Path(args[0]);
        System.out.println("inputPath : " + inputPath);

        FileInputFormat.addInputPath((JobConf) job.getConfiguration(), inputPath);
        FileOutputFormat.setOutputPath((JobConf) job.getConfiguration(), new Path(args[1]));

        System.exit(job.waitForCompletion(true) ? 0 : 1);

    }
}
