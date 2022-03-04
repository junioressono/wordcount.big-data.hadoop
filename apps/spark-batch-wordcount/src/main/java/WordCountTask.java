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
                .setAppName(WordCountTask.class.getName());
                //.setMaster("local[*]");
        JavaSparkContext spark = new JavaSparkContext(conf);

        String linesSeparators = "\t";

        JavaRDD<String> doc_lines = spark.textFile(inputFilePath);
        JavaRDD<String> doc_lower_lines = doc_lines.map(line -> line.toLowerCase());

        JavaRDD<String>  words = doc_lower_lines.flatMap(line -> Arrays.asList(line.split(linesSeparators)).iterator());
        JavaPairRDD<String, Integer> words_map = words.mapToPair(word -> new Tuple2<>(word, 1));

        JavaPairRDD<String, Integer> words_count = words_map.reduceByKey((a, b) -> a + b);
        JavaPairRDD<Integer, String> words_swapped = words_count.mapToPair(t -> new Tuple2<>(t._2, t._1));
        JavaPairRDD<Integer, String> words_sorted = words_swapped.sortByKey(false);

        words_sorted
                .mapToPair(t -> new Tuple2<>(t._2, t._1))
                .saveAsTextFile(outputDir);

        List<Tuple2<Integer, String>> result_take = words_sorted.take(2);
        System.out.println("RESULT TAKE");
        for (Object item : result_take) {
            System.out.println(item.toString());
        }

        /*List<Tuple2<Integer, String>> result_top = words_swapped.top(2);
        System.out.println("RESULT TOP");
        for (Object item : result_top) {
            System.out.println(item.toString());
        }*/
    }
}
