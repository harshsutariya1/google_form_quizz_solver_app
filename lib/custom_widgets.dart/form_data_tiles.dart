import 'package:flutter/material.dart';
import 'package:quizz_app/Screens/form_data.dart';
import 'package:quizz_app/services/api_services.dart';

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
      padding: const EdgeInsets.only(
        top: 10,
        right: 10,
        left: 10,
      ),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border.all(color: Colors.grey),
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
                "${quizData[0]['header']}",
                // style: Theme.of(context).textTheme.headlineMedium,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 22,
                ),
              ),
              Text("No of Questions: ${questions.length}"),
              const Divider(),
              ...questions.asMap().entries.map((entry) {
                int index = entry.key;
                var question = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: (index < 2)
                      ? Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                  text: "Question ${index + 1}:",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  )),
                              TextSpan(
                                text: "  ${question['question']}",
                                style: const TextStyle(),
                              ),
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )
                      : (index < 3)
                          ? const Text(" . . .")
                          : null,
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
  final formDetails = formData.first;
  print(formDetails);
  return Container(
    padding: const EdgeInsets.all(10),
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${formData[0]['header']}",
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("\nNo of Questions: ${questions.length}"),
              TextButton(
                onPressed: () {
                  // selenium code
                  autoFillGoogleForm(googleFormLink: formDetails['form_link'],ifsuccessCode: (response) {});
                },
                child: const Text("Open Google Form"),
              ),
            ],
          ),
          const Divider(thickness: 2),
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
                    const Text(
                      "Options:",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                      softWrap: true,
                    ),
                    ...question['options'].asMap().entries.map((entry) {
                      // int index = entry.key;
                      var option = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.circle,
                              size: 18,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 20),
                            Text(
                              option,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      );
                    }),
                    const Text(
                      "Answer: ",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                      softWrap: true,
                    ),
                    Text(
                      "${question['answer']}".isEmpty
                          ? "NA"
                          : "${question['answer']}",
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
