import org.apache.spark.SparkConf;
import org.apache.spark.api.java.JavaPairRDD;
import org.apache.spark.api.java.JavaRDD;
import org.apache.spark.api.java.JavaSparkContext;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import scala.Tuple2;

import java.util.Arrays;
import java.util.List;

public class WordCountTask {
    private static final Logger LOGGER = LoggerFactory.getLogger(WordCountTask.class);

    public static void main(String[] args) {
        new WordCountTask().run(args[0], args[1]);
    }

    private void run(String inputFilePath, String outputDir) {
        SparkConf conf = new SparkConf()
                .setAppName(WordCountTask.class.getName())
                .setMaster("local[*]");
        JavaSparkContext spark = new JavaSparkContext(conf);

        JavaRDD<String> docs = spark.textFile(inputFilePath);

        JavaRDD<String> low = docs.map(line -> line.toLowerCase());
        JavaRDD<String>  words = docs.flatMap(line -> Arrays.asList(line.split(" ")).iterator());
        JavaPairRDD<String, Integer> counts = words.mapToPair(word -> new Tuple2<>(word, 1));

        JavaPairRDD<String, Integer> words_frequence = counts.reduceByKey((a, b) -> a + b);

//        Comparable<> result = words_frequence.top(2);
//
//        for (Object item : result) {
//            System.out.println(item.toString());
//        }

        words_frequence.saveAsTextFile(outputDir);
    }
}
