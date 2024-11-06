import 'package:http/http.dart' as http;
import 'package:http/http.dart';

Future<bool> fetchQuizData({
  String googleFormLink = "https://forms.gle/QTovj8DYWRXAQdu67",
  required void Function(Response response) ifsuccessCode,
}) async {
  try {
    if (googleFormLink.contains("forms.gle") ||
        googleFormLink.contains("docs.google.com")) {
      print("Getting quizz data...");
      final response = await http.get(
        Uri.parse(
          // 'http://10.0.2.2:8000/get_quiz_data?google_form_link=$googleFormLink',
          'http://192.168.137.1:8000/get_quiz_data?google_form_link=$googleFormLink',
        ),
      );

      if (response.statusCode == 200) {
        ifsuccessCode(response);
        return true;
      } else {
        throw Exception('Failed to load quiz data');
      }
    } else {
      throw Exception("Please Enter valid Google Form link");
    }
  } catch (e) {
    print("Failed to load quizz data $e");
    return false;
  }
}


Future<void> generateResponse({
  required void Function(Response response) ifsuccessCode,
}) async {
  try {
    print("Generating response from openai api...");
    final response = await http.get(
      Uri.parse(
        // 'http://10.0.2.2:8000/get_quiz_data?google_form_link=$googleFormLink',
        'http://192.168.137.1:8000/generate_response',
      ),
    );

    if (response.statusCode == 200) {
      print("Got Response: ${response.body}");
      ifsuccessCode(response);
    } else {
      throw Exception('Failed to generate response');
    }
  } catch (e) {
    print("Error while generating responce: $e");
  }
}
