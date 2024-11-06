import 'package:flutter/material.dart';
import 'package:quizz_app/Screens/form_data.dart';

Widget formDataTileShort(
  BuildContext context,
  List quizData,
  String currentFormId,
  void Function() onTapDelete,
) {
  final List questions = quizData.sublist(1);
  // print("questions: $questions");
  return InkWell(
    onTap: () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => FormData(formId: currentFormId),
        ),
      );
    },
    child: Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              onPressed: onTapDelete,
              icon: const Icon(Icons.delete_forever_rounded),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Header: ${quizData[0]['header']}",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text("No of Questions: ${questions.length}"),
              const Divider(),
              ...questions.asMap().entries.map((entry) {
                int index = entry.key;
                var question = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                      "Question ${index + 1}: ${(index > 2) ? " . . ." : question['question']}"),
                );
              }),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget formDataTileLong(
  BuildContext context,
  List formData,
) {
  final List questions = formData.sublist(1);
  return Container(
    padding: const EdgeInsets.all(10),
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Header: ${formData[0]['header']}",
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          Text("\nNo of Questions: ${questions.length}"),
          const Divider(
            thickness: 2,
          ),
          const SizedBox(height: 10),
          ...questions.asMap().entries.map((entry) {
            int index = entry.key;
            var question = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Question ${index + 1}: ",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      "${question['question']}".isEmpty
                          ? "NA"
                          : "${question['question']}",
                      style: Theme.of(context).textTheme.titleMedium,
                      softWrap: true,
                    ),
                    Text(
                      "Options: ${question['options'] ?? "NA"}",
                      style: Theme.of(context).textTheme.titleMedium,
                      softWrap: true,
                    ),
                    Text(
                      "${question['answer']}".isEmpty
                          ? "Answer: NA"
                          : "Answer: ${question['answer']}",
                      style: Theme.of(context).textTheme.titleMedium,
                      softWrap: true,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    ),
  );
}
