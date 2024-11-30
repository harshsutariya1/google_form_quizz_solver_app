import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:quizz_app/services/firebase_services.dart';

Future<bool> fetchQuizData({
  String googleFormLink = "https://forms.gle/QTovj8DYWRXAQdu67",
  required void Function(Response response) ifsuccessCode,
}) async {
  try {
    if (googleFormLink.contains("forms.gle") ||
        googleFormLink.contains("docs.google.com")) {
      print("Getting quizz data...");
      final apiLink = await getSecrets(laptopLocalhostIpLink: true);
      final response = await http.get(
        Uri.parse(
          '$apiLink/get_quiz_data?google_form_link=$googleFormLink',
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

Future<bool> autoFillGoogleForm({
  String googleFormLink = "https://forms.gle/QTovj8DYWRXAQdu67",
  required void Function(Response response) ifsuccessCode,
}) async {
  try {
    if (googleFormLink.contains("forms.gle") ||
        googleFormLink.contains("docs.google.com")) {
      print("Opening Google form...");
      final apiLink = await getSecrets(laptopLocalhostIpLink: true);
      final response = await http.get(
        Uri.parse(
          '$apiLink/auto_fill_googleForm?google_form_link=$googleFormLink',
        ),
      );

      if (response.statusCode == 200) {
        ifsuccessCode(response);
        return true;
      } else {
        throw Exception('Failed to open link');
      }
    } else {
      throw Exception("Please Enter valid Google Form link");
    }
  } catch (e) {
    print("Failed to open link: $e");
    return false;
  }
}

Future<void> generateResponse({
  required List questions,
  required String openAiModel,
  required void Function(Response response) ifsuccessCode,
}) async {
  try {
    print("\nGenerating response from OpenAI API...");
    final openAiApiKey = await getSecrets(openAiApiKey: true);
    final apiLink = await getSecrets(laptopLocalhostIpLink: true);
    // Convert the questions list to JSON format
    final body = jsonEncode({
      'questions': questions,
      'openAiModel': openAiModel,
      'openAiApiKey': openAiApiKey,
    });
    final response = await http.post(
      Uri.parse('$apiLink/generate_response'),
      headers: {
        'Content-Type': 'application/json', // Set content type to JSON
      },
      body: body,
    );

    if (response.statusCode == 200) {
      // print("Got Response: ${response.body}");
      ifsuccessCode(response);
    } else {
      throw Exception('Failed to generate response');
    }
  } catch (e) {
    print("Error while generating response: $e");
  }
}
