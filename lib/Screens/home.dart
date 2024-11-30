import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:quizz_app/Screens/form_data.dart';
import 'package:quizz_app/constants/colors.dart';
import 'package:quizz_app/custom_widgets.dart/form_data_tiles.dart';
import 'package:quizz_app/custom_widgets.dart/snackbar.dart';
import 'package:quizz_app/services/api_services.dart';
import 'package:quizz_app/services/firebase_services.dart';
import 'package:quizz_app/services/storage_services.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<dynamic> quizData = [];
  bool isLoading = false;
  String openAiModel = "gpt-3.5-turbo-0125";
  double totalTokenUsed = 0;
  double totalCost = 0;
  double totalResponses = 0;
  TextEditingController inputField = TextEditingController();

  @override
  void initState() {
    super.initState();
    getUsageDetails().then((usage) {
      totalTokenUsed = usage[0];
      totalCost = usage[1];
      totalResponses = usage[2];
    // print("usage details: $totalTokenUsed $totalCost $totalResponses");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [_modelSelector()],
        title: InkWell(
          onLongPress: () {
            _showBottomSheet();
          },
          child: Text(
            "History",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: () async {},
        child: _body(),
      ),
      persistentFooterButtons: [_bottomSearchBar()],
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "Total token used: $totalTokenUsed",
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                ),
              ),
              Text(
                "Total responses created: $totalResponses",
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                ),
              ),
              Text(
                "Total cost of all responses: \$ $totalCost",
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _modelSelector() {
    return Row(
      children: [
        const Text(
          "AI Model:",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          margin: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.blueAccent.withOpacity(0.1),
            border: Border.all(color: Colors.blueAccent),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton(
              value: openAiModel,
              hint: const Text("Select Model"),
              items: const [
                DropdownMenuItem(
                  value: "gpt-3.5-turbo-0125",
                  enabled: true,
                  child: Text("gpt-3.5-turbo-0125"),
                ),
                // DropdownMenuItem(
                //   value: "gpt-3.5-turbo-0613",
                //   child: Text("gpt-3.5-turbo-0613"),
                // ),
                DropdownMenuItem(
                  value: "gpt-3.5-turbo-1106",
                  child: Text("gpt-3.5-turbo-1106"),
                ),
                DropdownMenuItem(
                  value: "gpt-4o-mini",
                  child: Text("gpt-4o-mini"),
                ),
                DropdownMenuItem(
                  value: "chatgpt-4o-latest",
                  child: Text("chatgpt-4o-latest"),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  openAiModel = value ?? "gpt-3.5-turbo-0125";
                });
              },
              icon: const Padding(
                padding: EdgeInsets.only(left: 5),
                child: Icon(
                  Icons.arrow_drop_down_circle_outlined,
                  color: Colors.blueAccent,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _body() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Stack(
        children: [
          FutureBuilder(
            future: getListOfFormIds(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator.adaptive(),
                );
              } else if (snapshot.hasData) {
                final List<String> listFormIds = snapshot.data;
                final listOfFormIds = listFormIds.reversed.toList();
                print("saved forms: $listOfFormIds");
                if (listOfFormIds == [] || listOfFormIds.isEmpty) {
                  return const Center(
                    child: Text("No Data Found!"),
                  );
                } else {
                  return ListView.builder(
                    itemCount: listOfFormIds.length,
                    itemBuilder: (BuildContext context, int index) {
                      return FutureBuilder(
                        future: getStoredQuizData(listOfFormIds[index]),
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator.adaptive(),
                            );
                          } else if (snapshot.hasError) {
                            return const Center(
                              child: Text("Error while fetching data"),
                            );
                          } else if (snapshot.hasData) {
                            final List quizData = snapshot.data;
                            return formDataTileShort(
                              context,
                              quizData,
                              listOfFormIds[index],
                              () async {
                                // Remove the formId
                                final result = await deleteFormId(
                                    formId: listOfFormIds[index]);
                                setState(() {
                                  if (result) {
                                    snackbarToast(
                                      context: context,
                                      content: "Form Data Deleted.",
                                      icon: Icons.done,
                                    );
                                    print("Form deleted");
                                  } else {
                                    snackbarToast(
                                      context: context,
                                      content: "Error deleting form data.",
                                      icon: Icons.error,
                                    );
                                    print("Error deleting Form Data");
                                  }
                                });
                              },
                            );
                          } else {
                            return const Center(
                              child: Text("Error while getting saved data"),
                            );
                          }
                        },
                      );
                    },
                  );
                }
              } else if (snapshot.hasError || snapshot.data == []) {
                return const Center(
                  child: Text("Error while getting saved data"),
                );
              } else {
                return const Text("Error while getting saved data");
              }
            },
          ),
          (isLoading) ? loader() : const SizedBox(),
        ],
      ),
    );
  }

  Widget loader() {
    return const Center(
      child: CircularProgressIndicator.adaptive(),
    );
  }

  Widget _bottomSearchBar() {
    return Container(
      height: 50,
      width: double.infinity,
      alignment: Alignment.center,
      margin: const EdgeInsets.only(
        bottom: 20,
        right: 5,
        left: 5,
      ),
      decoration: BoxDecoration(
        color: inputFieldColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 10),
          const Icon(Icons.add),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: inputField,
                decoration: const InputDecoration(
                  hintText: "Add Google Form link",
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: _onTapSend,
            icon: const Icon(Icons.send),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }

  void _onTapSend() {
    setState(() {
      isLoading = true;
    });
    if (inputField.text.isNotEmpty) {
      // scrap data of google form
      fetchQuizData(
        googleFormLink: inputField.text,
        ifsuccessCode: (response) {
          setState(() {
            isLoading = true;
            quizData = jsonDecode(response.body);
            // print("Responce after scraping google form: $quizData");
          });
        },
      ).then((bool value) {
        if (value) {
          //Get answers from ai
          List<dynamic> generatedAnswers = [];
          Map<String, dynamic> usageDetails = {
            "token_used": 0,
            "total_cost": 0,
          };

          generateResponse(
            questions: quizData.sublist(1),
            openAiModel: openAiModel,
            ifsuccessCode: (response) async {
              final List<dynamic> responseBody = jsonDecode(response.body);
              final List<dynamic> answers =
                  responseBody.map((e) => e.toString()).toList();
              print("Got Response: $answers");
              generatedAnswers = answers.sublist(0, answers.length - 1);
              final tokenUsed = double.parse(answers.last);
              final usage = await updateUsageDetails(totalTokenUsed: tokenUsed);
              usageDetails['token_used'] = await usage['token_used'];
              usageDetails['total_cost'] = await usage['total_cost'];
              // print("Usage Data: $usageDetails");
            },
          ).then((value) {
            // Save QuizData
            saveQuizData(
              quizData: quizData,
              answersList: generatedAnswers,
              usageDetails: usageDetails,
            ).then((value) {
              // Navigate to show data screen
              if (value[0]) {
                setState(() {
                  isLoading = false;
                });
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FormData(
                      formId: value[1],
                    ),
                  ),
                );
                snackbarToast(
                  context: context,
                  content: "Form Data Saved.",
                  icon: Icons.done_all_rounded,
                );
              } else {
                setState(() {
                  isLoading = false;
                });
                // show popup error saving data
                snackbarToast(
                  context: context,
                  content: "Error saving data",
                  icon: Icons.error,
                );
              }
            });
          });
        } else {
          // show popup error scraping data
          setState(() {
            isLoading = false;
          });
          snackbarToast(
            context: context,
            content: "Error scraping form data",
            icon: Icons.error_outline,
          );
        }
      });
    } else {
      setState(() {
        isLoading = false;
      });
      snackbarToast(
          context: context,
          content: "Please Enter form Link",
          icon: Icons.error_outline);
      print("Please Enter Form Link");
    }
  }
}
