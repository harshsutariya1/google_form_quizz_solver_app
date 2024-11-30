import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

var uuid = const Uuid();

String generateId() {
  return uuid.v1();
}

Future<List<String>> getListOfFormIds() async {
  final SharedPreferences sp = await SharedPreferences.getInstance();
  // {"formIds": ["formId", "formId", "formId", "formId",...]}
  return sp.getStringList("formIds") ?? [];
}

Future<List<String>> getFormData(String formID) async {
  final SharedPreferences sp = await SharedPreferences.getInstance();
  // {"formId": ["formLink", "formHeader", "questionsListId", "tokenUsed", "totalCost"]}
  return sp.getStringList(formID) ?? [];
}

Future<List<String>> getQuestionIds(String questionsListId) async {
  final SharedPreferences sp = await SharedPreferences.getInstance();
  // {"questionsListId": ["questionId", "questionId",...]}
  return sp.getStringList(questionsListId) ?? [];
}

Future<List<String>> getQuestionData(String questionId) async {
  final SharedPreferences sp = await SharedPreferences.getInstance();
  // {"questionId": ["questionText","questionOptionsId","questionAnswer",...]}
  return sp.getStringList(questionId) ?? [];
}

Future<List<String>> getQuestionOptions(String questionOptionsId) async {
  final SharedPreferences sp = await SharedPreferences.getInstance();
  // {"questionOptionsId": ["optionText","optionText","optionText",...]
  final result = sp.getStringList(questionOptionsId);
  return result ?? [];
}

//____________________________________________________________________________//
//____________________________________________________________________________//
//____________________________________________________________________________//

Future<String> setQuestionOptionsData({required List<String> options}) async {
  final SharedPreferences sp = await SharedPreferences.getInstance();
  final String uuid = generateId();
  final result = await sp.setStringList(uuid, options);
  return result ? uuid : "";
}

Future<String> setQuestionData({
  required String questionText,
  required String questionOptionsId,
  required String questionAnswer,
}) async {
  final SharedPreferences sp = await SharedPreferences.getInstance();
  final String uuid = generateId();
  final result = await sp.setStringList(uuid, [
    questionText,
    questionOptionsId,
    questionAnswer,
  ]);
  return result ? uuid : "";
}

Future<String> setQuestionsIdsList({required List<String> questionIds}) async {
  final SharedPreferences sp = await SharedPreferences.getInstance();
  final String uuid = generateId();
  final result = await sp.setStringList(uuid, questionIds);
  return result ? uuid : "";
}

Future<String> setFormData({
  required String formLink,
  required String formHeader,
  required String questionsListId,
  required String tokenUsed,
  required String totalCost,
}) async {
  final SharedPreferences sp = await SharedPreferences.getInstance();
  final String uuid = generateId();
  final result = await sp.setStringList(uuid, [
    formLink,
    formHeader,
    questionsListId,
    tokenUsed,
    totalCost,
  ]);
  return result ? uuid : "";
}

Future<bool> storeFormId({required String formId}) async {
  final SharedPreferences sp = await SharedPreferences.getInstance();
  List<String> storedFormIds = await getListOfFormIds();
  storedFormIds.add(formId);
  return await sp.setStringList("formIds", storedFormIds);
}

Future<bool> deleteFormId({required String formId}) async {
  final SharedPreferences sp = await SharedPreferences.getInstance();
  final List<String> listOfFormId = await getListOfFormIds();
  final bool result = listOfFormId.remove(formId) &&
      await sp.remove(formId) &&
      await sp.setStringList("formIds", listOfFormId);
  return result;
}

void clearAllStoredSp() async {
  final SharedPreferences sp = await SharedPreferences.getInstance();
  sp.clear();
}

//____________________________________________________________________________//
//____________________________________________________________________________//
//____________________________________________________________________________//

Future<List<dynamic>> saveQuizData({
  required List<dynamic> quizData,
  required List<dynamic> answersList,
  required Map<String, dynamic> usageDetails,
}) async {
  try {
    final formLink = quizData[0]['form_link'];
    final formHeader = quizData[0]['header'];
    final tokenUsed = usageDetails["token_used"];
    final totalCost = usageDetails["total_cost"];
    print("Saved values: tokenUsed: $tokenUsed and totalCost: $totalCost");
    final List<dynamic> questionsList = quizData.sublist(1);

    if (questionsList.length == answersList.length) {
      List<String> questionsIdList = [];
      for (var question in questionsList) {
        // Convert options to List<String>
        List<String> options = List<String>.from(question['options']);

        // Set question options and get the ID
        final questionOptionsId =
            await setQuestionOptionsData(options: options);

        // Set question data and get the ID
        final questionId = await setQuestionData(
          questionText: question['question'],
          questionOptionsId: questionOptionsId,
          questionAnswer: answersList[questionsList.indexOf(question)],
        );

        questionsIdList.add(questionId);
      }

      // Set list of question IDs
      final questionsListId =
          await setQuestionsIdsList(questionIds: questionsIdList);

      // Set form data
      final formId = await setFormData(
        formLink: formLink,
        formHeader: formHeader,
        questionsListId: questionsListId,
        tokenUsed: tokenUsed.toString(),
        totalCost: totalCost.toString(),
      );

      // Store form ID
      bool result = await storeFormId(formId: formId);
      print("Store form id method returned: $result");
      return [result, formId];
    } else {
      throw Exception("Questions and answers list must be of the same length");
    }
  } catch (e) {
    print("Error while saving form data: $e");
    return [false, "NA"];
  }
}

Future<List<dynamic>> getStoredQuizData(String formId) async {
  try {
    List<dynamic> formData = [];
    String formLink = "";
    String formHeader = "";
    String questionsListId = "";
    String tokenUsed = "";
    String totalCost = "";

    // Step 1: Fetch form data (link, header, questionsListId)
    List<String> formValues = await getFormData(formId);
    // print(formValues);
    formLink = formValues[0];
    formHeader = formValues[1];
    questionsListId = formValues[2];
    tokenUsed = formValues[3];
    totalCost = formValues[4];

    // Add form data to the result list
    formData.add({
      "form_link": formLink,
      "header": formHeader,
      "token_used": tokenUsed,
      "total_cost": totalCost,
    });

    // Step 2: Fetch question IDs based on questionsListId
    List<String> questionIdList = await getQuestionIds(questionsListId);

    // Step 3: Iterate through each question ID and fetch question data
    for (String questionId in questionIdList) {
      List<String> questionData = await getQuestionData(questionId);
      String questionText = questionData[0];
      String questionOptionsId = questionData[1];
      String questionAnswer = questionData[2];

      // Step 4: Fetch options based on questionOptionsId
      List<String> questionOptions =
          await getQuestionOptions(questionOptionsId);

      // Step 5: Add question data to the result list
      formData.add({
        'question': questionText,
        'options': questionOptions,
        'answer': questionAnswer,
      });
    }

    return formData;
  } catch (e) {
    print("Error Getting Stored Quiz Data: $e");
    return [];
  }
}
