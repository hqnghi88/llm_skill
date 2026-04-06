import java.io.*;
import java.util.*;

public class KMSAgent {
    public static void main(String[] args) {
        if (args.length == 0) {
            System.out.println("Usage: java KMSAgent \"Your question here\"");
            return;
        }
        String question = args[0];
        Map<String, String> kmsMap = new HashMap<>();
        try (InputStream is = KMSAgent.class.getResourceAsStream("kms.txt");
             BufferedReader reader = new BufferedReader(new InputStreamReader(is))) {
            String line;
            while ((line = reader.readLine()) != null) {
                String[] parts = line.split("=", 2);
                if (parts.length == 2) {
                    kmsMap.put(parts[0].trim(), parts[1].trim());
                }
            }
        } catch (IOException e) {
            System.out.println("Error loading KMS file: " + e.getMessage());
            return;
        }

        String answer = kmsMap.get(question);
        if (answer != null) {
            System.out.println(answer);
        } else {
            System.out.println("I don't know the answer to that question.");
        }
    }
}